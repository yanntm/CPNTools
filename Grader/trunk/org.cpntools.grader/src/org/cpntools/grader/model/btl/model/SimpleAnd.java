package org.cpntools.grader.model.btl.model;

import java.util.HashSet;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class SimpleAnd extends Simple {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (s1 == null ? 0 : s1.hashCode());
		result = prime * result + (s2 == null ? 0 : s2.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof SimpleAnd)) { return false; }
		final SimpleAnd other = (SimpleAnd) obj;
		if (s1 == null) {
			if (other.s1 != null) { return false; }
		} else if (!s1.equals(other.s1)) { return false; }
		if (s2 == null) {
			if (other.s2 != null) { return false; }
		} else if (!s2.equals(other.s2)) { return false; }
		return true;
	}

	private final Simple s1;
	private final Simple s2;

	/**
	 * @param s1
	 * @param s2
	 */
	public SimpleAnd(final Simple s1, final Simple s2) {
		this.s1 = s1;
		this.s2 = s2;

	}

	public Simple getS1() {
		return s1;
	}

	public Simple getS2() {
		return s2;
	}

	@Override
	public String toString() {
		return "(" + s1 + ") & (" + s2 + ")";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		final HashSet<Instance<org.cpntools.accesscpn.model.Transition>> set = new HashSet<Instance<org.cpntools.accesscpn.model.Transition>>();
		set.addAll(s1.force(candidates, model, names));
		set.retainAll(s2.force(candidates, model, names));
		return set;
	}

}
