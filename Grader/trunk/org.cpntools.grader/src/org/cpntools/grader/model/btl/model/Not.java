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
public class Not extends Simple {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (child == null ? 0 : child.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Not)) { return false; }
		final Not other = (Not) obj;
		if (child == null) {
			if (other.child != null) { return false; }
		} else if (!child.equals(other.child)) { return false; }
		return true;
	}

	private final Simple child;

	public Not(final Simple child) {
		this.child = child;

	}

	public Simple getChild() {
		return child;
	}

	@Override
	public String toString() {
		return "!(" + child + ")";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		final HashSet<Instance<org.cpntools.accesscpn.model.Transition>> set = new HashSet<Instance<org.cpntools.accesscpn.model.Transition>>();
		set.addAll(candidates);
		set.removeAll(child.force(candidates, model, simulator, names, environment));
		return set;
	}

	@Override
	public Simple progress(final Instance<org.cpntools.accesscpn.model.Transition> transition, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		final Simple newchild = child.progress(transition, model, simulator, names, environment);
		if (newchild == null) { return Failure.INSTANCE; }
		return null;
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return !child.canTerminate(model, simulator, names, environment);
	}

	@Override
	public Set<String> getAtomic() {
		return child.getAtomic();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {

	}

}
