package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class While extends Statement {

	private final Expression w;
	private final List<Statement> s;

	public While(final Expression w, final List<Statement> s) {
		this.w = w;
		Collections.reverse(s);
		this.s = s;
	}

	public While(final Statement t, final Expression translate, final List<Statement> translate2) {
		this(translate, translate2);
		init(t);
	}

	public Expression getCondition() {
		return w;
	}

	public List<Statement> getStatements() {
		return s;
	}

	@Override
	public String toString() {
		return "while " + w + " do\n" + Helper.indent(Helper.toString(s)) + "endwhile\n";
	}
}
