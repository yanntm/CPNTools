package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

public final class True extends Simple {
	public True() {

	}

	@Override
	public String toString() {
		return "true";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		return candidates;
	}

	@Override
	public boolean equals(final Object o) {
		return o instanceof True;
	}

	@Override
	public int hashCode() {
		return 7;
	}
}
