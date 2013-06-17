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
public class Binding extends Transition {
	private final Map<String, String> vars;

	public Binding(final String name, final Map<String, String> vars) {
		super(name);
		this.vars = vars;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (!super.equals(obj)) { return false; }
		if (!(obj instanceof Binding)) { return false; }
		return true;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int result = super.hashCode();
		return result;
	}

	@Override
	public Simple progress(final Instance<org.cpntools.accesscpn.model.Transition> ti, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		final Simple s = super.progress(ti, model, simulator, names, environment);
		if (s == null) {
			// TODO scrape variables
		}
		return s;
	}

	@Override
	public String toString() {
		return super.toString() + ' ' + vars;
	}

}
