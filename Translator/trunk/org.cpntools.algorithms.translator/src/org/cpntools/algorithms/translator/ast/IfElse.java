package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class IfElse extends Statement {

	private final Expression w;
	private final List<Statement> s1;
	private final List<Statement> s2;

	public IfElse(final Expression w, final List<Statement> s1, final List<Statement> s2) {
		this.w = w;
		Collections.reverse(s2);
		this.s2 = s2;
		Collections.reverse(s1);
		this.s1 = s1;
	}

	public IfElse(final Statement t, final Expression translate, final List<Statement> translate2,
	        final List<Statement> translate3) {
		this(translate, translate2, translate3);
		init(t);
	}

	public Expression getCondition() {
		return w;
	}

	public List<Statement> getThenStatements() {
		return s1;
	}

	public List<Statement> getElseStatements() {
		return s2;
	}

	@Override
	public String toString() {
		if (s2.isEmpty()) { return "if " + w + " then\n" + Helper.indent(Helper.toString(s1)) + "endif\n"; }
		return "if " + w + " then\n" + Helper.indent(Helper.toString(s1)) + "else\n"
		        + Helper.indent(Helper.toString(s2)) + "endif\n";
	}
}
