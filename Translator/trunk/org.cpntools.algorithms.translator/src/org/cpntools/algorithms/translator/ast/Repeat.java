package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class Repeat extends Statement {

	private final List<Statement> s;
	private final Expression w;

	public Repeat(final List<Statement> s, final Expression w) {
		Collections.reverse(s);
		this.s = s;
		this.w = w;
	}

	public Repeat(final Statement t, final List<Statement> translate, final Expression translate2) {
		this(translate, translate2);
		init(t);
	}

	public List<Statement> getStatements() {
		return s;
	}

	public Expression getCondition() {
		return w;
	}

	@Override
	public String toString() {
		return "repeat\n" + Helper.indent(Helper.toString(s)) + "until " + w + "\n";
	}
}
