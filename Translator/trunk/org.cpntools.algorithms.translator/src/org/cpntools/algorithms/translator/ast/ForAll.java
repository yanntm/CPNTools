package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class ForAll extends Statement {

	private final Expression w;
	private final List<Statement> s;
	private final String i;

	public ForAll(final Expression w, final String i, final List<Statement> s) {
		this.w = w;
		this.i = i;
		Collections.reverse(s);
		this.s = s;
	}

	public ForAll(final Statement t, final Expression translate, final String id, final List<Statement> translate2) {
		this(translate, id, translate2);
		init(t);
	}

	public Expression getCondition() {
		return w;
	}

	public List<Statement> getStatements() {
		return s;
	}

	public String getId() {
		return i;
	}

	@Override
	public String toString() {
		return "for all " + i + " in " + w + " do\n" + Helper.indent(Helper.toString(s)) + "endfor\n";
	}
}
