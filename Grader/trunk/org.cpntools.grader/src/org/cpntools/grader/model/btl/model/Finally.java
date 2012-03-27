package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class Finally implements Guide {
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
		if (!(obj instanceof Finally)) { return false; }
		final Finally other = (Finally) obj;
		if (condition == null) {
			if (other.condition != null) { return false; }
		} else if (!condition.equals(other.condition)) { return false; }
		if (constraint == null) {
			if (other.constraint != null) { return false; }
		} else if (!constraint.equals(other.constraint)) { return false; }
		return true;
	}

	private final Condition constraint;
	private final Guide condition;

	/**
	 * @param condition
	 * @param constraint
	 */
	public Finally(final Guide condition, final Condition constraint) {
		this.condition = condition;
		this.constraint = constraint;

	}

	public Guide getCondition() {
		return condition;
	}

	public Condition getConstraint() {
		return constraint;
	}

	@Override
	public String toString() {
		return "(" + condition + ") ===> [" + constraint + "]";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		return candidates;
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names) {
		if (condition == null) { return this; }
		final Guide newc = condition.progress(ti, model, simulator, names);
		if (newc == condition) { return this; }
		return new Finally(newc, constraint);
	}

}