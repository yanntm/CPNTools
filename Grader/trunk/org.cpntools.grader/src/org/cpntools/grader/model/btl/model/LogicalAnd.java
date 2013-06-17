package org.cpntools.grader.model.btl.model;

import java.util.HashSet;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class LogicalAnd extends BExpression {
	private final BExpression b1;

	private final BExpression b2;

	/**
	 * @param b1
	 * @param b2
	 */
	public LogicalAnd(final BExpression b1, final BExpression b2) {
		this.b1 = b1;
		this.b2 = b2;

	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof LogicalAnd)) { return false; }
		final LogicalAnd other = (LogicalAnd) obj;
		if (b1 == null) {
			if (other.b1 != null) { return false; }
		} else if (!b1.equals(other.b1)) { return false; }
		if (b2 == null) {
			if (other.b2 != null) { return false; }
		} else if (!b2.equals(other.b2)) { return false; }
		return true;
	}

	@Override
	public boolean evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return b1.evaluate(model, simulator, names, environment) && b2.evaluate(model, simulator, names, environment);
	}

	@Override
	public Set<String> getAtomic() {
		final Set<String> result = new HashSet<String>();
		result.addAll(b1.getAtomic());
		result.addAll(b2.getAtomic());
		return result;
	}

	public BExpression getB1() {
		return b1;
	}

	public BExpression getB2() {
		return b2;
	}

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

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		b1.prestep(model, simulator, names, environment);
		b2.prestep(model, simulator, names, environment);
	}

	@Override
	public String toString() {
		return "(" + b1 + ") & (" + b2 + ")";
	}

}
