package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class Return extends Statement {

	private final Expression i;

	public Return(final Expression i) {
		this.i = i;
	}

	public Return(final Statement t, final Expression translate) {
		this(translate);
		init(t);
	}

	public Expression getExpression() {
		return i;
	}

	@Override
	public String toString() {
		return "return " + i + "\n";
	}
}
