package org.cpntools.grader.model.btl.model;

import java.util.HashSet;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class LogicalOr extends BExpression {
	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (b1 == null ? 0 : b1.hashCode());
		result = prime * result + (b2 == null ? 0 : b2.hashCode());
		return result;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof LogicalOr)) { return false; }
		final LogicalOr other = (LogicalOr) obj;
		if (b1 == null) {
			if (other.b1 != null) { return false; }
		} else if (!b1.equals(other.b1)) { return false; }
		if (b2 == null) {
			if (other.b2 != null) { return false; }
		} else if (!b2.equals(other.b2)) { return false; }
		return true;
	}

	private final BExpression b1;
	private final BExpression b2;

	/**
	 * @param b1
	 * @param b2
	 */
	public LogicalOr(final BExpression b1, final BExpression b2) {
		this.b1 = b1;
		this.b2 = b2;

	}

	public BExpression getB2() {
		return b2;
	}

	public BExpression getB1() {
		return b1;
	}

	@Override
	public String toString() {
		return "(" + b1 + ") | (" + b2 + ")";
	}

	@Override
	public boolean evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		return b1.evaluate(model, simulator, names) || b2.evaluate(model, simulator, names);
	}

	@Override
	public Set<String> getAtomic() {
		final Set<String> result = new HashSet<String>();
		result.addAll(b1.getAtomic());
		result.addAll(b2.getAtomic());
		return result;
	}

}
