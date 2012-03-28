package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import javax.swing.JOptionPane;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.grader.model.ConfigurationTestSuite;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.TestSuite;
import org.cpntools.grader.signer.gui.FileChooser;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.tester.Tester;

/**
 * @author michael
 */
public class Grader {

	/**
	 * @param args
	 */
	public static void main(final String[] args) {
		final SetupDialog setup = new SetupDialog();
		final FileChooser configuration = new FileChooser("Configuration", true);
		setup.getFiles().add(configuration, BorderLayout.SOUTH);
		setup.setVisible(true);

		if (setup.getBase() != null) {

			TestSuite suite;
			try {
				suite = new ConfigurationTestSuite(configuration.getSelected(), setup.getSecret());
			} catch (final Exception e) {
				JOptionPane.showMessageDialog(null, "Error loading configuration!", "Error Loading",
				        JOptionPane.ERROR_MESSAGE);
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
			int progress = 0;
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
			for (final File f : files) {
				resultDialog.update(null, "Loading " + f);
				try {
					final PetriNet net = DOMParser.parse(new FileInputStream(f), f.getName().replace("[.]cpn$", ""));
					try {
						final List<Report> test = tester.test(net);
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
					} catch (final Exception e2) {
						e2.printStackTrace();
						resultDialog.addError(f, "Error testing model! " + e2.getMessage());
					}
				} catch (final Exception e) {
					e.printStackTrace();
					resultDialog.addError(f, "Error loading model! " + e.getMessage());
				}
				resultDialog.setProgress(++progress);
				if (resultDialog.isCancelled()) {
					break;
				}
			}
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

	private static void markCheater(final File f, final Report r) {
		r.setStudentId(new StudentID("cheating_" + r.getStudentId().getId() + "_impersonating_"
		        + f.getName().replaceAll("[.]cpn$", "")));
		r.addError("User has submitted another model as well!  Likely cheating is taking place.");
	}
}
