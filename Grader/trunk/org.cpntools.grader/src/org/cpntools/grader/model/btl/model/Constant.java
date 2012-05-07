package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class Constant extends IExpression {
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

	private final int value;

	/**
	 * @param value
	 */
	public Constant(final int value) {
		this.value = value;

	}

	public int getValue() {
		return value;
	}

	@Override
	public String toString() {
		return "" + value;
	}

	@Override
	public int evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		return value;
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.emptySet();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {

	}

}
