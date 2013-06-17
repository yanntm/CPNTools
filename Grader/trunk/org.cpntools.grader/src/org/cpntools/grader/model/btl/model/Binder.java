package org.cpntools.grader.model.btl.model;

import java.util.Map;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class Binder extends And {
	private final Map<String, String> vars;

	public Binder(final String name, final Map<String, String> vars, final Guide g) {
		super(new Transition(name), g);
		this.vars = vars;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (!super.equals(obj)) { return false; }
		if (!(obj instanceof Binder)) { return false; }
		final Binder other = (Binder) obj;
		if (vars == null) {
			if (other.vars != null) { return false; }
		} else if (!vars.equals(other.vars)) { return false; }
		return true;
	}

	@Override
	public Guide progress(final Instance<org.cpntools.accesscpn.model.Transition> ti, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment)
	        throws Unconsumed {
		final Guide g = super.progress(ti, model, simulator, names, environment);
		if (g != Failure.INSTANCE) {
			// TODO scrape variables
		}
		return g;
	}

	@Override
	public String toString() {
		return "new " + getG1().toString() + ' ' + vars + " (" + getG2().toString() + ')';
	}

}
