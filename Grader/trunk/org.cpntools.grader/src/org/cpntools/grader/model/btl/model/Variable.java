package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class Variable extends IExpression {
	private final String name;

	/**
	 * @param name
	 */
	public Variable(final String name) {
		this.name = name;

	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Variable)) { return false; }
		final Variable other = (Variable) obj;
		if (name == null) {
			if (other.name != null) { return false; }
		} else if (!name.equals(other.name)) { return false; }
		return true;
	}

	@Override
	public int evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return Integer.parseInt(environment.get(name));
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.emptySet();
	}

	public String getName() {
		return name;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 131;
		int result = 1;
		result = prime * result + (name == null ? 0 : name.hashCode());
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {

	}

	@Override
	public String toString() {
		return "<" + name + ">";
	}

}
