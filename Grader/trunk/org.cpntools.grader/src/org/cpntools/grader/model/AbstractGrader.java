package org.cpntools.grader.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;

/**
 * @author michael
 */
public abstract class AbstractGrader implements Grader {
	private final double maxPoints;

	public AbstractGrader(final double maxPoints) {
		this.maxPoints = maxPoints;
	}

	@Override
	public Message grade(final StudentID id, final PetriNet model, final HighLevelSimulator simulator) {
		return Message.NULL;
	}

	public double getMaxPoints() {
		return maxPoints;
	}

}
