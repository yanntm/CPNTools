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
public class Constant extends IExpression {
	private final int value;

	/**
	 * @param value
	 */
	public Constant(final int value) {
		this.value = value;

	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Constant)) { return false; }
		final Constant other = (Constant) obj;
		if (value != other.value) { return false; }
		return true;
	}

	@Override
	public int evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return value;
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.emptySet();
	}

	public int getValue() {
		return value;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + value;
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {

	}

	@Override
	public String toString() {
		return "" + value;
	}

}
