package org.cpntools.grader.tester;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Observable;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.checker.Checker;
import org.cpntools.accesscpn.engine.highlevel.checker.ErrorInitializingSMLInterface;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.gui.BTLTester;
import org.cpntools.grader.model.DeclarationSubset;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.InterfacePreservation;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.MonitoringGrader;
import org.cpntools.grader.model.NameCategorizer;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.TerminationGrader;
import org.cpntools.grader.model.TestSuite;
import org.cpntools.grader.model.btl.BTLGrader;

/**
 * @author michael
 */
public class Tester extends Observable {
	public static HighLevelSimulator checkModel(final PetriNet model, final File output, final File modelPath,
	        final StudentID studentid) throws Exception {
		final HighLevelSimulator simulator = HighLevelSimulator.getHighLevelSimulator();
// simulator.getSimulator().addObserver(new PacketPrinter(simulator));
		final Checker checker = new Checker(model, new File(output, model.getName().getText()), simulator);
		try {
			// Explicitly ignore localcheck here!
			checker.checkInitializing(
			        modelPath.getAbsolutePath(),
			        new File(new File(modelPath, "simout"), studentid.toString()).getAbsolutePath().replaceFirst(
			                "[.][cC][pP][nN]$", ""));
			checker.checkDeclarations();
			checker.generateSerializers();
			checker.checkPages();
			checker.generatePlaceInstances();
			checker.checkMonitors();
			simulator.setConfidenceIntervals(95);
			checker.generateNonPlaceInstances();
			checker.initialiseSimulationScheduler();
		} catch (final ErrorInitializingSMLInterface _) {
		}
		return simulator;
	}

	private final PetriNet base;
	private final List<StudentID> ids;
	private final File output;
	private StudentID studentid = null;

	private final TestSuite suite;
	
	private long timeOut = -1;

	public Tester(final TestSuite suite, final List<StudentID> ids, final PetriNet base, final File output) {
		this.suite = suite;
		this.ids = ids;
		this.base = base;
		this.output = output;
	}
	
	public void setTimeOut(long timeOut) {
		this.timeOut = timeOut;
	}

	/**
	 * @param message
	 */
	public void notify(final String message) {
		setChanged();
		notifyObservers(message);
	}

	/**
	 * 
	 * @param model the model to test
	 * @param modelDirectory the directory containing all other models (to check for fraud)
	 * @param progress report progress of grading
	 * @return
	 * @throws Exception
	 */
	public List<Report> test(final PetriNet model, final File modelDirectory, ProgressReporter progress) throws Exception {
		
		int totalWork = suite.getGraders().size() + 4;
		int stepSize = progress.getRemainingProgress() / totalWork;
		
		final List<Report> result = new ArrayList<Report>();
		if (ids != null) {
			notify("Categorizing and checking for fraud");
			for (final StudentID sid : ids) {
				final Message message = suite.getMatcher().grade(sid, base, model, null);
				if (message.getPoints() > suite.getMatcher().getMinPoints()) {
					studentid = sid;
					notify("Model matches " + sid);
					final Report report = new Report(sid);
					report.addReport(suite.getMatcher(), message);
					result.add(report);
				}
			}
			progress.addProgress(stepSize);
			if (result.size() > 1) {
				for (final Report report : result) {
					report.addError("This model matches multiple students");
				}
			}
			if (result.size() == 0) {
				String id = model.getName().getText().trim();
				if (id.endsWith(".cpn")) id = id.substring(0, id.length()-4);
				notify("Model doesn't match anybody - using generated id `generated_" + id + "'");
				final StudentID sid = new StudentID("generated_" + id);
				studentid = sid;
				final Report report = new Report(sid);
				report.addReport(suite.getMatcher(), suite.getMatcher().grade(sid, base, model, null));
				result.add(report);
			}
			progress.addProgress(stepSize);
		} else {
			String modelName = model.getName().getText();
			if (modelName.endsWith(".cpn")) modelName = modelName.substring(0, modelName.length()-4);
			studentid = new StudentID(modelName);
			result.add(new Report(studentid));
			progress.addProgress(2*stepSize);
		}

		notify("Adding enabling control to " + model.getName().getText());
		EnablingControlAdapterFactory.instance.adapt(model, EnablingControl.class);
		progress.addProgress(stepSize);
		
		notify("Syntax checking " + model.getName().getText());
		HighLevelSimulator simulator = null;
		try {
			simulator = Tester.checkModel(model, output, modelDirectory, studentid);
		} catch (final Exception e) {
			notify("Error checking model " + e.getMessage());
			e.printStackTrace();
		}
		progress.addProgress(stepSize);

		notify("Grading");
		for (final Report r : result) {
			if (simulator == null) {
				r.addError("Could not syntax check model; simulation based tests will fail.");
			}
			int count=0;
			for (final Grader grader : suite.getGraders()) {
				count++;
				try {
					if (grader instanceof InterfacePreservation) {
						notify(count+"/"+suite.getGraders().size()+": checking interface preservation");
					}
					if (grader instanceof DeclarationSubset) {
						notify(count+"/"+suite.getGraders().size()+": checking declaration preservation");
					}
					if (grader instanceof NameCategorizer) {
						notify(count+"/"+suite.getGraders().size()+": checking file name for proper student id");
					}
					if (grader instanceof MonitoringGrader) {
						notify(count+"/"+suite.getGraders().size()+": creating performance report");
					}
					if (grader instanceof BTLGrader) {
						notify(count+"/"+suite.getGraders().size()+": "+((BTLGrader)grader).getName());
					}
					if (grader instanceof TerminationGrader) {
						notify(count+"/"+suite.getGraders().size()+": simulating to final marking");
					}
					
					Message message;
					if (timeOut > 0 && System.currentTimeMillis() > timeOut) {
						message = new Message(0.0, "Skipped (time out)");
					} else {
						message = grader.grade(r.getStudentId(), base, model, simulator);
					}
					r.addReport(grader, message);
				} catch (final Exception e) {
					r.addError("Grader " + grader.getClass().getCanonicalName() + " failed with exception " + e);
					e.printStackTrace();
				}
				progress.addProgress(stepSize);
			}
		}
		return result;
	}
	
	/**
	 * @return studentID used by the tester
	 */
	public StudentID getStudentid() {
		return studentid;
	}
}
