package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

public final class Failure extends Simple {
	public static final Failure INSTANCE = new Failure();

	private Failure() {
		// Singleton
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return false;
	}

	@Override
	public boolean equals(final Object o) {
		return o instanceof Failure;
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return Collections.emptySet();
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.emptySet();
	}

	@Override
	public int hashCode() {
		return 7;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {

	}

	@Override
	public Simple progress(final Instance<org.cpntools.accesscpn.model.Transition> transition, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return Failure.INSTANCE;
	}

	@Override
	public String toString() {
		return "failure";
	}

}
