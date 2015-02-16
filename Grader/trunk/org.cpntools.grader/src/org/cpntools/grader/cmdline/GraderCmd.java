package org.cpntools.grader.cmdline;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Observable;
import java.util.Observer;
import java.util.TreeSet;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.prefs.Preferences;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.grader.cmdline.ResultDialogCmd;
import org.cpntools.grader.gui.Grader;
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
public class GraderCmd {

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

	private static final String CONFIG = "config";
	private static final String MODEL_DIR = "model_directory";
	private static final String MODEL_FILE = "base_model_file";
	private static int progress;

	private static final String STUDENT_IDS = "student_ids";

	public static void incrementProgress(final ResultDialogCmd resultDialog) {
		resultDialog.setProgress(++GraderCmd.progress);
	}
	
	/**
	 * print help message for using commandline parameters
	 */
	public static void printUsage() {
		System.out.println("GraderCmd requires 6 command line parameters (in the given order): \n"
						+"     <baseFile>       - the .cpn base file\n"
						+"     <studentIdFile>  - a text file with all student IDs (one per line)\n"
						+"     <secret>         - the secret with which all IDs in the student files were hashed\n"
						+"     <numThreads>     - number of grader threads to use (suggested: 1)\n"
						+"     <configFile>     - the .cfg file used for grading\n"
						+"     <modelDirectory> - directory with all student submissions\n");
	}

	/**
	 * @param args
	 */
	public static void main(final String[] args) {
		
		if (args.length != 6) {
			printUsage();
			return;
		}

		final String baseFile = args[0];
		final String idFileName = args[1];
		final String secret = args[2];
		final String noThreads = args[3];
		final File configFile = new File(args[4]); 
		final File modelDirectory = new File(args[5]); 

		if (baseFile != null) {

			TestSuite suite;
			try {
				suite = new ConfigurationTestSuite(configFile, secret);
			} catch (final ParserException e) {
				System.err.println("Error loading configuration\n"+e.getMessage() + ":\n" + e.getLine() + (e.getCause() == null ? "" : "\nCaused by:\n" + e.getCause()));
				e.printStackTrace();
				return;
			} catch (final FileNotFoundException e) {
				System.err.println("Configuration file not found!\n" + e);
				e.printStackTrace();
				return;
			} catch (final IOException e) {
				System.err.println("Reading configuration file failed!\n" + e);
				e.printStackTrace();
				return;
			}

			PetriNet petriNet;
			try {
				petriNet = DOMParser.parse(new FileInputStream(baseFile), "base");
			} catch (final Exception e) {
				System.err.println("Error loading base model!\n"+e);
				return;
			}

			if (!modelDirectory.isDirectory()) {
				System.err.println("Model directory is not a directory!");
				return;
			}

			final File[] files = modelDirectory.listFiles(new FilenameFilter() {
				@Override
				public boolean accept(final File arg0, final String arg1) {
					return arg1.endsWith("cpn");
				}
			});

			final List<PetriNet> models = new ArrayList<PetriNet>();
			GraderCmd.progress = 0;
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
				System.out.println("The following files failed loading:\n" + failed);
			}

			List<StudentID> studentIDs;
			try {
				studentIDs = getStudentIDs(idFileName);
			} catch (FileNotFoundException e) {
				System.err.println("Could not find student id file!\n"+e);
				return;
			} catch (IOException e) {
				System.err.println("Error reading student id file!\n"+e);
				return;
			}
			
			final Tester tester = new Tester(suite, studentIDs, petriNet, new File(modelDirectory, "outputs"));
			final ResultDialogCmd resultDialog = new ResultDialogCmd(tester, files.length, new File(modelDirectory, "reports"));

			final TreeSet<StudentID> unused = new TreeSet<StudentID>(studentIDs);
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
										GraderCmd.markCheater(f, r);
										if (or != null) {
											GraderCmd.markCheater(oldfiles.get(or.getStudentId()), or);
										}
										resultDialog.addReport(f, r);
									}
								}
							}
						} else {
							try {
								Thread.sleep(100);
							} catch (final InterruptedException e) {
								// Ignore interrupt
							}
						}
					}
				}
			}.start();
			final int maxThreads = Integer.parseInt(noThreads);
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
						
						File fDoneEarlier = new File(f.getAbsolutePath()+".done");
						System.out.println(fDoneEarlier+" exists? "+fDoneEarlier.exists());
						
						String studentID = f.getName().substring(2, 9);
						File reportsDir = new File(modelDirectory, "reports");
						File fReportEarlier = new File(reportsDir, "S"+studentID+"_report.pdf");
						System.out.println(fReportEarlier+" exists? "+fReportEarlier.exists());
						
						if (!fDoneEarlier.exists() || !fReportEarlier.exists()) {
							resultDialog.update(null, "Loading " + f);
							try {
								final PetriNet net = DOMParser.parse(new FileInputStream(f),
								        f.getName().replace("[.]cpn$", ""));
								try {
	
									final List<Report> test = tester.test(net, modelDirectory);
									result.add(new ResultData(f, test));
								} catch (final Throwable e2) {
									e2.printStackTrace();
									resultDialog.addError(f, "Error testing model! " + e2.getMessage());
								}
							} catch (final Throwable e) {
								e.printStackTrace();
								resultDialog.addError(f, "Error loading model! " + e.getMessage());
	//							
	//							Report errorReport = new Report(new StudentID(f.getName()));
	//							errorReport.addError(e.getMessage());
	//							List<Report> errorList = new ArrayList<Report>();
	//							errorList.add(errorReport);
	//							result.add(new ResultData(f, errorList));
							}
							final long end = new Date().getTime() - d.getTime();
							resultDialog.update(null, "Checking took " + end / 1000.0 + " seconds.");
							writeDoneFile(f.getAbsolutePath()+".done");
							GraderCmd.incrementProgress(resultDialog);
							
							HashSet<File> recursed = new HashSet<File>();
							
							// clear the simout directory for this model, recursively
							File simOutDir = new File(modelDirectory.getAbsolutePath(), "simout");
							simOutDir = new File(simOutDir, studentID.toString()); 
							System.out.println("cleaning "+simOutDir);
							if (simOutDir.exists()) {
								LinkedList<File> deleteTree = new LinkedList<File>();
								deleteTree.addFirst(simOutDir);
								while (!deleteTree.isEmpty()) {
									File toDelete = deleteTree.getFirst();
									if (!toDelete.isDirectory() || toDelete.listFiles().length == 0) {
										toDelete.delete();
										deleteTree.removeFirst();
									} else if (!recursed.contains(toDelete)) {
										recursed.add(toDelete);
										for (File toDeleteChild : toDelete.listFiles()) {
											deleteTree.addFirst(toDeleteChild);
										}									
									} else {
										deleteTree.removeFirst();
									}
								}
							}
						} else {
							resultDialog.update(null, "Skipping "+f);
							GraderCmd.incrementProgress(resultDialog);
						}
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
		System.exit(0);
	}
	
	static void writeDoneFile(String file) {
		FileWriter fstream;
		try {
			fstream = new FileWriter(file);
			BufferedWriter out = new BufferedWriter(fstream);
			out.write("done");
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	static LinkedList<StudentID> getStudentIDs(String idFileName) throws IOException {
		  FileInputStream fstream = new FileInputStream(idFileName);
		  DataInputStream in = new DataInputStream(fstream);
		  BufferedReader br = new BufferedReader(new InputStreamReader(in));
		  String strLine;
		  
		  LinkedList<StudentID> ids = new LinkedList<StudentID>();
		  while ((strLine = br.readLine()) != null)   {
			  ids.add(new StudentID(strLine));
		  }
		  in.close();
		  return ids;
	}

	static void markCheater(final File f, final Report r) {
		r.setStudentId(new StudentID("cheating_" + r.getStudentId().getId() + "_impersonating_"
		        + f.getName().replaceAll("[.]cpn$", "")));
		r.addError("User has submitted another model as well!  Likely cheating is taking place.");
	}

}
