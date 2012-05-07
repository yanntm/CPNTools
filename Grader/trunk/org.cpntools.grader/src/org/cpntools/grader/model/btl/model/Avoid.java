package org.cpntools.grader.model.btl.model;

import java.util.HashSet;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class Avoid implements Guide {
	private final Guide condition;

	/**
	 * @param condition
	 * @param constraint
	 */
	public Avoid(final Guide condition) {
		this.condition = condition;

	}

	public Guide getCondition() {
		return condition;
	}

	@Override
	public String toString() {
		return "(" + condition + ") => failure";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		final Set<Instance<org.cpntools.accesscpn.model.Transition>> result = new HashSet<Instance<Transition>>(
		        candidates);
		result.removeAll(condition.force(candidates, model, names));
		return result;
	}

	/**
	 * @throws Unconsumed
	 * @see org.cpntools.grader.model.btl.model.Guide#progress(org.cpntools.accesscpn.engine.highlevel.instance.Instance,
	 *      org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator,
	 *      org.cpntools.grader.model.NameHelper)
	 */
	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names) throws Unconsumed {
		try {
			final Guide newc = condition.progress(ti, model, simulator, names);
			if (newc == null) { return Failure.INSTANCE; }
			if (newc == Failure.INSTANCE) { return null; }
			if (newc == condition) { return this; }
			return new Avoid(newc);
		} catch (final Exception e) {
			return Failure.INSTANCE;
		}
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		return true;
	}

	@Override
	public Set<String> getAtomic() {
		return condition.getAtomic();
	}

}
