package org.cpntools.grader.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;

/**
 * @author michael
 */
public class NullGrader extends AbstractGrader {
	public static final NullGrader INSTANCE = new NullGrader();

	protected NullGrader() {
		super(0.0);
	}

	/**
	 * @see org.cpntools.grader.model.Grader#configure(double, java.lang.String)
	 */
	@Override
	public Grader configure(final double maxPoints, final String configuration) {
		return NullGrader.INSTANCE;
	}

	/**
	 * @see org.cpntools.grader.model.Grader#grade(org.cpntools.grader.model.StudentID,
	 *      org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator)
	 */
	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		return Message.NULL;
	}
}
