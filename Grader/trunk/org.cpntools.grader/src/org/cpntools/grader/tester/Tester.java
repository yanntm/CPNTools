package org.cpntools.grader.tester;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
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

	public List<Report> test(final PetriNet model) throws Exception {
		notify("Checking " + model.getName().getText());
		final HighLevelSimulator simulator = HighLevelSimulator.getHighLevelSimulator();
		final Checker checker = new Checker(model, new File(output, model.getName().getText()), simulator);
		try {
			// Explicitly ignore localcheck here!
			checker.checkInitializing();
			checker.checkDeclarations();
			checker.generateSerializers();
			checker.checkPages();
			checker.generateInstances();
			checker.initialiseSimulationScheduler();
			checker.checkMonitors();
		} catch (final ErrorInitializingSMLInterface _) {
		} catch (final Exception e) {
			notify("Error checking model " + e.getMessage());
			return Collections.emptyList();
		}
		notify("Categorizing");
		final List<Report> result = new ArrayList<Report>();
		for (final StudentID sid : ids) {
			final Message message = suite.getMatcher().grade(sid, model, simulator);
			if (message.getPoints() > 0) {
				notify("Model matches " + sid);
				final Report report = new Report(sid);
				report.addReport(suite.getMatcher(), new Message(0.0, message.getMessage()));
				result.add(report);
			}
		}
		if (result.size() > 1) {
			for (final Report report : result) {
				report.addError("This model matches multiple students");
			}
		}
		notify("Grading");
		for (final Report r : result) {
			for (final Grader grader : suite.getGraders()) {
				final Message message = grader.grade(r.getStudentId(), model, simulator);
				r.addReport(grader, message);
			}
		}
		return result;
	}
}
