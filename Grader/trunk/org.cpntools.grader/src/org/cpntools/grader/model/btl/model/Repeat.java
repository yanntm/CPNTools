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
public class Repeat implements Guide {
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

	private final Simple s;

	public Repeat(final Simple s) {
		this.s = s;

	}

	public Simple getS() {
		return s;
	}

	@Override
	public String toString() {
		return "* (" + s + ")";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		return candidates;
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names) throws Unconsumed {
		final Guide news = s.progress(ti, model, simulator, names);
		if (s == news) { return this; }
		if (news == null) { return this; }
		if (news == Failure.INSTANCE) { throw new Unconsumed(); }
		return new And(news, new Guard(news, this));
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		return true;
	}

	@Override
	public Set<String> getAtomic() {
		return s.getAtomic();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		s.prestep(model, simulator, names);
	}

}
