package org.cpntools.grader.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;

/**
 * @author michael
 */
public class NameCategorizer extends AbstractGrader {
	public static final Grader INSTANCE = new NameCategorizer(0.0);

	/**
	 * @param maxPoints
	 */
	public NameCategorizer(final double maxPoints) {
		super(maxPoints);
	}

	/**
	 * @see org.cpntools.grader.model.Grader#configure(double, java.lang.String)
	 */
	@Override
	public Grader configure(final double maxPoints, final String configuration) {
		if ("matchfilename".equalsIgnoreCase(configuration)) { return new NameCategorizer(maxPoints); }
		return null;
	}

	/**
	 * @see org.cpntools.grader.model.AbstractGrader#grade(org.cpntools.grader.model.StudentID,
	 *      org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.model.PetriNet,
	 *      org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator)
	 */
	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		if (model.getName().getText().toLowerCase().indexOf(id.getId().trim().toLowerCase()) >= 0) { return new Message(
		        getMaxPoints(), id + " is a substring of " + model.getName().getText()); }
		return new Message(getMinPoints(), id + " is not a substring of " + model.getName().getText());
	}

}
