package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class LogicalNot extends BExpression {
	private final BExpression b;

	/**
	 * @param b
	 */
	public LogicalNot(final BExpression b) {
		this.b = b;

	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof LogicalNot)) { return false; }
		final LogicalNot other = (LogicalNot) obj;
		if (b == null) {
			if (other.b != null) { return false; }
		} else if (!b.equals(other.b)) { return false; }
		return true;
	}

	@Override
	public boolean evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return !b.evaluate(model, simulator, names, environment);
	}

	@Override
	public Set<String> getAtomic() {
		return b.getAtomic();
	}

	public BExpression getB() {
		return b;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (b == null ? 0 : b.hashCode());
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {

	}

	@Override
	public String toString() {
		return "!(" + b + ")";
	}

}
