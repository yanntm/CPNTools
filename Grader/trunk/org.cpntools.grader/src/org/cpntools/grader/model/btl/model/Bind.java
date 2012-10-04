package org.cpntools.grader.model.btl.model;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;
import org.cpntools.grader.model.btl.FunctionalChainedMapEnvironment;

/**
 * @author michael
 */
public class Bind implements Guide {
	private final Guide g;
	private final Map<String, String> vars;

	public Bind(final Map<String, String> vars, final Guide g) {
		this.g = g;
		this.vars = vars;
	}

	public Guide getG() {
		return g;
	}

	public Map<String, String> getVars() {
		return vars;
	}

	@Override
	public String toString() {
		return "bind " + vars + " (" + g + ")";
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		final HashSet<Instance<org.cpntools.accesscpn.model.Transition>> set = new HashSet<Instance<org.cpntools.accesscpn.model.Transition>>();
		set.addAll(g.force(candidates, model, simulator, names, new FunctionalChainedMapEnvironment(environment, vars)));
		return set;
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names, final Environment environment) throws Unconsumed {
		final Guide newg = g.progress(ti, model, simulator, names, new FunctionalChainedMapEnvironment(environment,
		        vars));
		if (newg == null) { return null; }
		if (newg == Failure.INSTANCE) { return Failure.INSTANCE; }
		if (newg == g) { return this; }
		return new Bind(vars, newg);

	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return g.canTerminate(model, simulator, names, new FunctionalChainedMapEnvironment(environment, vars));
	}

	@Override
	public Set<String> getAtomic() {
		return g.getAtomic();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		g.prestep(model, simulator, names, new FunctionalChainedMapEnvironment(environment, vars));
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 137;
		int result = 1;
		result = prime * result + (g == null ? 0 : g.hashCode());
		result = prime * result + (vars == null ? 0 : vars.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Bind)) { return false; }
		final Bind other = (Bind) obj;
		if (g == null) {
			if (other.g != null) { return false; }
		} else if (!g.equals(other.g)) { return false; }
		if (vars == null) {
			if (other.vars != null) { return false; }
		} else if (!vars.equals(other.vars)) { return false; }
		return true;
	}

}
