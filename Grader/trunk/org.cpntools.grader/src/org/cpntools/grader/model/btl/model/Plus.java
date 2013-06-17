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
public class Plus extends IExpression {
	private final IExpression e1;

	private final IExpression e2;

	/**
	 * @param e1
	 * @param e2
	 */
	public Plus(final IExpression e1, final IExpression e2) {
		this.e1 = e1;
		this.e2 = e2;

	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof Plus)) { return false; }
		final Plus other = (Plus) obj;
		if (e1 == null) {
			if (other.e1 != null) { return false; }
		} else if (!e1.equals(other.e1)) { return false; }
		if (e2 == null) {
			if (other.e2 != null) { return false; }
		} else if (!e2.equals(other.e2)) { return false; }
		return true;
	}

	@Override
	public int evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return e1.evaluate(model, simulator, names, environment) + e2.evaluate(model, simulator, names, environment);
	}

	@Override
	public Set<String> getAtomic() {
		final Set<String> result = new HashSet<String>();
		result.addAll(e1.getAtomic());
		result.addAll(e2.getAtomic());
		return result;
	}

	public IExpression getE1() {
		return e1;
	}

	public IExpression getE2() {
		return e2;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (e1 == null ? 0 : e1.hashCode());
		result = prime * result + (e2 == null ? 0 : e2.hashCode());
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		e1.prestep(model, simulator, names, environment);
		e2.prestep(model, simulator, names, environment);
	}

	@Override
	public String toString() {
		return "(" + e1 + ") + (" + e2 + ")";
	}

}
