package org.cpntools.grader.model.btl.model;

import java.util.HashSet;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class SimpleOr extends Simple {
	private final Simple s1;

	private final Simple s2;

	/**
	 * @param s1
	 * @param s2
	 */
	public SimpleOr(final Simple s1, final Simple s2) {
		this.s1 = s1;
		this.s2 = s2;

	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return s1.canTerminate(model, simulator, names, environment)
		        || s2.canTerminate(model, simulator, names, environment);
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof SimpleOr)) { return false; }
		final SimpleOr other = (SimpleOr) obj;
		if (s1 == null) {
			if (other.s1 != null) { return false; }
		} else if (!s1.equals(other.s1)) { return false; }
		if (s2 == null) {
			if (other.s2 != null) { return false; }
		} else if (!s2.equals(other.s2)) { return false; }
		return true;
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		final HashSet<Instance<org.cpntools.accesscpn.model.Transition>> set = new HashSet<Instance<org.cpntools.accesscpn.model.Transition>>();
		set.addAll(s1.force(candidates, model, simulator, names, environment));
		set.addAll(s2.force(candidates, model, simulator, names, environment));
		return set;
	}

	@Override
	public Set<String> getAtomic() {
		final Set<String> result = new HashSet<String>();
		result.addAll(s1.getAtomic());
		result.addAll(s2.getAtomic());
		return result;
	}

	public Simple getS1() {
		return s1;
	}

	public Simple getS2() {
		return s2;
	}

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

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		s1.prestep(model, simulator, names, environment);
		s2.prestep(model, simulator, names, environment);
	}

	@Override
	public Simple progress(final Instance<org.cpntools.accesscpn.model.Transition> transition, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		final Simple news1 = s1.progress(transition, model, simulator, names, environment);
		final Simple news2 = s2.progress(transition, model, simulator, names, environment);
		if (news1 == null) { return null; }
		if (news2 == null) { return null; }
		if (news1 == Failure.INSTANCE) { return news2; }
		if (news2 == Failure.INSTANCE) { return news1; }
		if (news1 == s1 && news2 == s2) { return this; }
		return new SimpleOr(news1, news2);
	}

	@Override
	public String toString() {
		return "(" + s1 + ") | (" + s2 + ")";
	}

}
