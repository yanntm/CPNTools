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
public class Guard implements Guide {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (condition == null ? 0 : condition.hashCode());
		result = prime * result + (constraint == null ? 0 : constraint.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Guard)) { return false; }
		final Guard other = (Guard) obj;
		if (condition == null) {
			if (other.condition != null) { return false; }
		} else if (!condition.equals(other.condition)) { return false; }
		if (constraint == null) {
			if (other.constraint != null) { return false; }
		} else if (!constraint.equals(other.constraint)) { return false; }
		return true;
	}

	private final Guide condition;
	private final Guide constraint;

	/**
	 * @param condition
	 * @param constraint
	 */
	public Guard(final Guide condition, final Guide constraint) {
		this.condition = condition;
		this.constraint = constraint;

	}

	public Guide getCondition() {
		return condition;
	}

	public Guide getConstraint() {
		return constraint;
	}

	@Override
	public String toString() {
		return "(" + condition + ") => (" + constraint + ")";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		return candidates;
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
			if (newc == null) { return constraint; }
			if (newc == Failure.INSTANCE) { return null; }
			if (newc == condition) { return this; }
			return new Guard(newc, constraint);
		} catch (final Exception e) {
			return constraint.progress(ti, model, simulator, names);
		}
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		if (condition.canTerminate(model, simulator, names)) { return constraint.canTerminate(model, simulator, names); }
		return true;
	}

	@Override
	public Set<String> getAtomic() {
		final Set<String> result = new HashSet<String>();
		result.addAll(condition.getAtomic());
		result.addAll(constraint.getAtomic());
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		condition.prestep(model, simulator, names);
	}

}
