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
public class And implements Guide {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (g1 == null ? 0 : g1.hashCode());
		result = prime * result + (g2 == null ? 0 : g2.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof And)) { return false; }
		final And other = (And) obj;
		if (g1 == null) {
			if (other.g1 != null) { return false; }
		} else if (!g1.equals(other.g1)) { return false; }
		if (g2 == null) {
			if (other.g2 != null) { return false; }
		} else if (!g2.equals(other.g2)) { return false; }
		return true;
	}

	private final Guide g1;
	private final Guide g2;

	public And(final Guide g1, final Guide g2) {
		this.g1 = g1;
		this.g2 = g2;

	}

	public Guide getG1() {
		return g1;
	}

	public Guide getG2() {
		return g2;
	}

	@Override
	public String toString() {
		return "(" + g1 + ") & (" + g2 + ")";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		final HashSet<Instance<org.cpntools.accesscpn.model.Transition>> set = new HashSet<Instance<org.cpntools.accesscpn.model.Transition>>();
		set.addAll(g1.force(candidates, model, names));
		set.retainAll(g2.force(candidates, model, names));
		return set;
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names) {
		final Guide newg1 = g1.progress(ti, model, simulator, names);
		final Guide newg2 = g2.progress(ti, model, simulator, names);
		if (newg1 == null) { return newg2; }
		if (newg2 == null) { return newg1; }
		if (newg1 == g1 && newg2 == g2) { return this; }
		return new And(newg1, newg2);
	}

}
