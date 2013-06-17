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
public class Repeat implements Guide {
	private final Simple s;

	public Repeat(final Simple s) {
		this.s = s;

	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return true;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Repeat)) { return false; }
		final Repeat other = (Repeat) obj;
		if (s == null) {
			if (other.s != null) { return false; }
		} else if (!s.equals(other.s)) { return false; }
		return true;
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return candidates;
	}

	@Override
	public Set<String> getAtomic() {
		return s.getAtomic();
	}

	public Simple getS() {
		return s;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (s == null ? 0 : s.hashCode());
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		s.prestep(model, simulator, names, environment);
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names, final Environment environment) throws Unconsumed {
		final Guide news = s.progress(ti, model, simulator, names, environment);
		if (s == news) { return this; }
		if (news == null) { return this; }
		if (news == Failure.INSTANCE) { throw new Unconsumed(); }
		return new And(news, new Guard(news, this));
	}

	@Override
	public String toString() {
		return "* (" + s + ")";
	}

}
