package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class Future implements Guide {

	private final Guide constraint;

	/**
	 * @param condition
	 * @param constraint
	 */
	public Future(final Guide constraint) {
		this.constraint = constraint;

	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return constraint.canTerminate(model, simulator, names, environment);
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return candidates;
	}

	@Override
	public Set<String> getAtomic() {
		return constraint.getAtomic();
	}

	public Guide getConstraint() {
		return constraint;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		constraint.prestep(model, simulator, names, environment);
	}

	/**
	 * @throws Unconsumed
	 * @see org.cpntools.grader.model.btl.model.Guide#progress(org.cpntools.accesscpn.engine.highlevel.instance.Instance,
	 *      org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator,
	 *      org.cpntools.grader.model.NameHelper)
	 */
	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names, final Environment environment) throws Unconsumed {
		final Guide newc = constraint.progress(ti, model, simulator, names, environment);
		if (newc == Failure.INSTANCE) { return this; }
		if (newc == constraint) { return this; }
		return newc;
	}

	@Override
	public String toString() {
		return "--> (" + constraint + ")";
	}

}
