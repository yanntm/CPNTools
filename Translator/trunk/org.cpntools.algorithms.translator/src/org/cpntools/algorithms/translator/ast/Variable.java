package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class Variable extends Expression {

	private final String name;

	public Variable(final String name) {
		this.name = name;
	}

	public Variable(final Statement t, final String name2) {
		this(name2);
		init(t);
	}

	public String getId() {
		return name;
	}

	@Override
	public String toString() {
		return name;
	}
}
