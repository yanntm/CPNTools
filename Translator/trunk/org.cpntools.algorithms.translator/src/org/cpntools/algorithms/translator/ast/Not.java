package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class Not extends Expression {

	private final Expression e;

	public Not(final Expression e) {
		this.e = e;
	}

	public Not(final TopLevel e2, final Expression translate) {
		this(translate);
		init(e2);
	}

	public Expression getExpression() {
		return e;
	}

	@Override
	public String toString() {
		return "(not " + e + ")";
	}
}
