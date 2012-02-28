package org.cpntools.grader.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;

/**
 * @author michael
 */
public abstract class AbstractGrader implements Grader {
	private final double maxPoints;

	/**
	 * @param maxPoints
	 */
	public AbstractGrader(final double maxPoints) {
		this.maxPoints = maxPoints;
	}

	/**
	 * @see org.cpntools.grader.model.Grader#grade(org.cpntools.grader.model.StudentID,
	 *      org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.model.PetriNet,
	 *      org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator)
	 */
	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		return Message.NULL;
	}

	public double getMaxPoints() {
		if (maxPoints > 0) { return maxPoints; }
		return 0.0;
	}

	public double getMinPoints() {
		if (maxPoints < 0) { return maxPoints; }
		return 0.0;
	}

}
