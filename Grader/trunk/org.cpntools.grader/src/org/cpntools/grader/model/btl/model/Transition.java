package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class Transition extends Simple {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (name == null ? 0 : name.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Transition)) { return false; }
		final Transition other = (Transition) obj;
		if (name == null) {
			if (other.name != null) { return false; }
		} else if (!name.equals(other.name)) { return false; }
		return true;
	}

	private final String name;

	public Transition(final String name) {
		this.name = NameHelper.cleanup(name);

	}

	public String getName() {
		return name;
	}

	@Override
	public String toString() {
		return name;
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		final Instance<org.cpntools.accesscpn.model.Transition> ti = names.getTransitionInstance(name);
		if (candidates.contains(ti)) { return Collections.singleton(ti); }
		return Collections.emptySet();
	}

	@Override
	public Simple progress(final Instance<org.cpntools.accesscpn.model.Transition> ti, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names) {
		if (ti.equals(names.getTransitionInstance(name))) { return null; }
		return Failure.INSTANCE;
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		return false;
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.singleton(name);
	}

}
