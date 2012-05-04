package org.cpntools.grader.tester;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Observable;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.checker.Checker;
import org.cpntools.accesscpn.engine.highlevel.checker.ErrorInitializingSMLInterface;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.TestSuite;

/**
 * @author michael
 */
public class Tester extends Observable {
	private final TestSuite suite;
	private final List<StudentID> ids;
	private final PetriNet base;
	private final File output;

	public Tester(final TestSuite suite, final List<StudentID> ids, final PetriNet base, final File output) {
		this.suite = suite;
		this.ids = ids;
		this.base = base;
		this.output = output;
	}

	/**
	 * @param message
	 */
	public void notify(final String message) {
		setChanged();
		notifyObservers(message);
	}

	public List<Report> test(final PetriNet model, final File modelPath) throws Exception {
		notify("Categorizing");
		StudentID studentid = null;
		final List<Report> result = new ArrayList<Report>();
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
		if (result.size() > 1) {
			for (final Report report : result) {
				report.addError("This model matches multiple students");
			}
		}
		if (result.size() == 0) {
			final String id = model.getName().getText().trim();
			notify("Model doesn't match anybody - using generated id `generated_" + id + "'");
			final StudentID sid = new StudentID("generated_" + id);
			studentid = sid;
			final Report report = new Report(sid);
			report.addReport(suite.getMatcher(), suite.getMatcher().grade(sid, base, model, null));
			result.add(report);
		}

		notify("Adding enabling control to " + model.getName().getText());
		EnablingControlAdapterFactory.instance.adapt(model, EnablingControl.class);
		notify("Checking " + model.getName().getText());
		final HighLevelSimulator simulator = null;
		try {
			checkModel(model, output, modelPath, studentid);
		} catch (final Exception e) {
			notify("Error checking model " + e.getMessage());
		}

		notify("Grading");
		for (final Report r : result) {
			if (simulator == null) {
				r.addError("Could not syntax check model; simulation based tests will fail.");
			}
			for (final Grader grader : suite.getGraders()) {
				try {
					final Message message = grader.grade(r.getStudentId(), base, model, simulator);
					r.addReport(grader, message);
				} catch (final Exception e) {
					r.addError("Grader " + grader.getClass().getCanonicalName() + " failed with exception " + e);
				}
			}
		}
		return result;
	}

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
			simulator.setConfidenceIntervals(95);
			checker.checkMonitors();
			checker.generateInstances();
			checker.initialiseSimulationScheduler();
		} catch (final ErrorInitializingSMLInterface _) {
		}
		return simulator;
	}
}
