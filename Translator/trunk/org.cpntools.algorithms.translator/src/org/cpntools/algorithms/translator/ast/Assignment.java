package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class Assignment extends Statement {

	private final String name;
	private final Expression w;

	public Assignment(final String name, final Expression w) {
		this.name = name;
		this.w = w;
	}

	public Assignment(final Statement t, final String id, final Expression translate) {
		this(id, translate);
		init(t);
	}

	public String getId() {
		return name;
	}

	public Expression getValue() {
		return w;
	}

	@Override
	public String toString() {
		return name + " := " + w + '\n';
	}
}
