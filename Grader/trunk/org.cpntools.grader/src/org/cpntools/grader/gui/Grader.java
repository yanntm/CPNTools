package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.prefs.Preferences;

import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.grader.model.ConfigurationTestSuite;
import org.cpntools.grader.model.ParserException;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.TestSuite;
import org.cpntools.grader.signer.gui.FileChooser;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.tester.Tester;

/**
 * @author michael
 */
public class Grader {

	private static final String MODEL_FILE = "base_model_file";
	private static final String MODEL_DIR = "model_directory";
	private static final String STUDENT_IDS = "student_ids";
	private static final String CONFIG = "config";
	private static int progress;

	public static class ResultData {
		private final File file;
		private final List<Report> result;

		public ResultData(final File f, final List<Report> result) {
			file = f;
			this.result = result;

		}

		public File getFile() {
			return file;
		}

		public List<Report> getResult() {
			return result;
		}
	}

	/**
	 * @param args
	 */
	public static void main(final String[] args) {
		System.setProperty("apple.laf.useScreenMenuBar", "true");
		System.setProperty("com.apple.mrj.application.apple.menu.about.name", "Grade/CPN");
		final Preferences p = Preferences.userNodeForPackage(Grader.class);
		final FileChooser configuration = new FileChooser("Configuration", p.get(CONFIG, ""), true);
		final SetupDialog setup = new SetupDialog(p.get(MODEL_FILE, ""), p.get(MODEL_DIR, ""), p.get(STUDENT_IDS, "")) {
			@Override
			protected void update(final File outputDir) {
				if (configuration.getSelected().getName().equals("")) {
					for (final File f : outputDir.listFiles(new FilenameFilter() {
						@Override
						public boolean accept(final File arg0, final String arg1) {
							return arg1.endsWith(".cfg");
						}

					})) {
						configuration.setSelected(f);
					}
				}
			}
		};
		final JPanel bottom = new JPanel(new BorderLayout());
		setup.getFiles().add(bottom, BorderLayout.SOUTH);
		bottom.add(configuration);
		final JPanel threads = new JPanel(new FlowLayout());
		bottom.add(threads, BorderLayout.SOUTH);
		final JTextField noThreads = new JTextField("" + Runtime.getRuntime().availableProcessors(), 4);
		threads.add(noThreads);
		threads.add(new JLabel("Number of grader threads"));
		setup.setVisible(true);
		p.put(MODEL_FILE, setup.getBase().getAbsolutePath());
		p.put(MODEL_DIR, setup.getModels().getAbsolutePath());
		p.put(STUDENT_IDS, setup.getTextIds());
		p.put(CONFIG, configuration.getSelected().getAbsolutePath());

		if (setup.getBase() != null) {

			TestSuite suite;
			try {
				suite = new ConfigurationTestSuite(configuration.getSelected(), setup.getSecret());
			} catch (final ParserException e) {
				JOptionPane.showMessageDialog(null, e.getMessage() + ":\n" + e.getLine()
				        + (e.getCause() == null ? "" : "\nCaused by:\n" + e.getCause()),
				        "Error loading configuration!", JOptionPane.ERROR_MESSAGE);
				e.printStackTrace();
				return;
			} catch (final FileNotFoundException e) {
				JOptionPane.showMessageDialog(null, "Configuration file not found!\n" + e,
				        "Error loading configuration!", JOptionPane.ERROR_MESSAGE);
				e.printStackTrace();
				return;
			} catch (final IOException e) {
				JOptionPane.showMessageDialog(null, "Reading configuration file failed!\n" + e,
				        "Error loading configuration!", JOptionPane.ERROR_MESSAGE);
				e.printStackTrace();
				return;
			}

			PetriNet petriNet;
			try {
				petriNet = DOMParser.parse(new FileInputStream(setup.getBase()), "base");
			} catch (final Exception e) {
				JOptionPane.showMessageDialog(null, "Error loading base model!", "Error Loading",
				        JOptionPane.ERROR_MESSAGE);
				return;
			}

			if (!setup.getModels().isDirectory()) {
				JOptionPane.showMessageDialog(null, "Model directory is not a directory!", "Invalid Model Directory",
				        JOptionPane.ERROR_MESSAGE);
				return;
			}

			final File[] files = setup.getModels().listFiles(new FilenameFilter() {
				@Override
				public boolean accept(final File arg0, final String arg1) {
					return arg1.endsWith("cpn");
				}
			});

			final List<PetriNet> models = new ArrayList<PetriNet>();
			progress = 0;
			final StringBuilder failed = new StringBuilder();
			for (final File file : files) {
				try {
					models.add(DOMParser.parse(new FileInputStream(file), file.getName().replace("[.]cpn$", "")));
				} catch (final Exception _) {
					failed.append(file.getAbsolutePath());
					failed.append('\n');
				}
			}
			if (failed.length() != 0) {
				if (JOptionPane.showConfirmDialog(null, "The following files failed loading:\n" + failed,
				        "Error Loading", JOptionPane.OK_CANCEL_OPTION) != JOptionPane.OK_OPTION) { return; }
			}

			final Tester tester = new Tester(suite, setup.getStudentIds(), petriNet, new File(setup.getModels(),
			        "outputs"));
			final ResultDialog resultDialog = new ResultDialog(tester, files.length);

			final HashSet<StudentID> unused = new HashSet<StudentID>(setup.getStudentIds());
			final Map<StudentID, Report> old = new HashMap<StudentID, Report>();
			final Map<StudentID, File> oldfiles = new HashMap<StudentID, File>();
			final AtomicInteger running = new AtomicInteger(0);
			final List<ResultData> result = Collections.synchronizedList(new LinkedList<ResultData>());
			new Thread("GUI") {
				@Override
				public void run() {
					while (!result.isEmpty() || running.get() >= 0) {
						if (!result.isEmpty()) {
							final ResultData resultData = result.remove(0);
							final List<Report> test = resultData.getResult();
							final File f = resultData.getFile();
							for (final Report r : test) {
								if (unused.remove(r.getStudentId())) {
									resultDialog.addReport(f, r);
									old.put(r.getStudentId(), r);
									oldfiles.put(r.getStudentId(), f);
								} else {
									if (r.getStudentId().getId().startsWith("generated_")) {
										r.addError("Model does not seem to belong to anybody; generated id has been used!");
										resultDialog.addReport(f, r);
									} else {
										final Report or = old.remove(r.getStudentId());
										markCheater(f, r);
										if (or != null) {
											markCheater(oldfiles.get(or.getStudentId()), or);
										}
										resultDialog.addReport(f, r);
									}
								}
							}
						} else {
							try {
								sleep(100);
							} catch (final InterruptedException e) {
								// Ignore interrupt
							}
						}
					}
				}
			}.start();
			final int maxThreads = Integer.parseInt(noThreads.getText());
			for (final File f : files) {
				if (resultDialog.isCancelled()) {
					break;
				}
				while (running.get() >= maxThreads) {
					if (resultDialog.isCancelled()) {
						break;
					}
					try {
						Thread.sleep(100);
					} catch (final InterruptedException e) {
					}
				}
				running.incrementAndGet();
				new Thread("Worker") {
					@Override
					public void run() {
						final Date d = new Date();
						resultDialog.update(null, "Loading " + f);
						try {
							final PetriNet net = DOMParser.parse(new FileInputStream(f),
							        f.getName().replace("[.]cpn$", ""));
							try {

								final List<Report> test = tester.test(net, setup.getModels());
								result.add(new ResultData(f, test));
							} catch (final Exception e2) {
								e2.printStackTrace();
								resultDialog.addError(f, "Error testing model! " + e2.getMessage());
							}
						} catch (final Exception e) {
							e.printStackTrace();
							resultDialog.addError(f, "Error loading model! " + e.getMessage());
						}
						incrementProgress(resultDialog);
						final long end = new Date().getTime() - d.getTime();
						resultDialog.update(null, "Checking took " + end / 1000.0 + " seconds.");
						running.decrementAndGet();
					}
				}.start();
			}
			while (running.get() > 0) {
				try {
					Thread.sleep(100);
				} catch (final InterruptedException e) {
				}
			}
			running.decrementAndGet();
			for (final StudentID sid : unused) {
				resultDialog.addError(sid);
			}
			resultDialog.update(null, "Done.");
			resultDialog.setModal(true);

// int lazies = 0;
// final Map<StudentID, Integer> cheaters = new HashMap<StudentID, Integer>();
// for (final StudentID sid : setup.getStudentIds()) {
// final int matches = matcher.match(sid);
// if (matches == 0) {
// lazies++;
// } else if (matches > 1) {
// cheaters.put(sid, matches);
// }
// progressMonitor.setProgress(++progress);
// }
// if (lazies > 0 || cheaters.size() > 0) {
// final StringBuilder message = new StringBuilder();
// final StringBuilder title = new StringBuilder();
// if (lazies > 0) {
// title.append("Lazy");
// message.append(lazies);
// message.append(" student");
// if (lazies > 1) {
// message.append('s');
// }
// message.append(" did not hand anything in.");
// }
// if (cheaters.size() > 0) {
// if (lazies > 0) {
// title.append(" and ");
// }
// title.append("Cheating");
// if (lazies > 0) {
// message.append('\n');
// }
// message.append(cheaters.size());
// message.append(" student");
// if (cheaters.size() > 1) {
// message.append('s');
// }
// message.append(" participated in cheating. They are:\n");
// message.append(cheaters.keySet());
// }
// JOptionPane.showMessageDialog(null, message.toString(), title.toString() + " Students Found",
// cheaters.size() > 0 ? JOptionPane.WARNING_MESSAGE : JOptionPane.INFORMATION_MESSAGE);
// }

		}
// System.exit(0);
	}

	public static void incrementProgress(final ResultDialog resultDialog) {
		resultDialog.setProgress(++progress);
	}

	static void markCheater(final File f, final Report r) {
		r.setStudentId(new StudentID("cheating_" + r.getStudentId().getId() + "_impersonating_"
		        + f.getName().replaceAll("[.]cpn$", "")));
		r.addError("User has submitted another model as well!  Likely cheating is taking place.");
	}
}
