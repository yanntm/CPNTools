package org.cpntools.grader.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;

public interface Grader extends Comparable<Grader> {
	public Grader configure(double maxPoints, String configuration);

	public Message grade(StudentID id, PetriNet base, PetriNet model, HighLevelSimulator simulator);

	public double getMaxPoints();

	public double getMinPoints();
}
