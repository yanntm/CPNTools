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
public class ConditionGuide implements Guide {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (c == null ? 0 : c.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof ConditionGuide)) { return false; }
		final ConditionGuide other = (ConditionGuide) obj;
		if (c == null) {
			if (other.c != null) { return false; }
		} else if (!c.equals(other.c)) { return false; }
		return true;
	}

	private final Condition c;

	public ConditionGuide(final Condition c) {
		this.c = c;

	}

	public Condition getC() {
		return c;
	}

	@Override
	public String toString() {
		return "[" + c + "]";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return candidates;
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names, final Environment environment) throws Unconsumed {
		final Condition newc = c.progress(ti, model, simulator, names, environment);
		if (newc == Failure.INSTANCE) { return Failure.INSTANCE; }
		if (newc == c) { return this; }
		if (newc == null) { return null; }
		return new ConditionGuide(newc);
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return c.canTerminate(model, simulator, names, environment);
	}

	@Override
	public Set<String> getAtomic() {
		return c.getAtomic();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		c.prestep(model, simulator, names, environment);
	}

}
