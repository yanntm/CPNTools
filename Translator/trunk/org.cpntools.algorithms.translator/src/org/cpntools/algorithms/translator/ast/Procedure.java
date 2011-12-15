package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class Procedure extends TopLevel {

	private final String name;
	private final List<Declaration> p;
	private final List<Statement> s;

	public Procedure(final String name, final List<Declaration> p, final List<Statement> s) {
		this.name = name;
		Collections.reverse(p);
		this.p = p;
		Collections.reverse(s);
		this.s = s;
	}

	public Procedure(final Procedure t, final String name, final List<Declaration> parameters,
	        final List<Statement> translate) {
		this(name, parameters, translate);
		init(t);
	}

	public String getName() {
		return name;
	}

	public List<Declaration> getParameters() {
		return p;
	}

	public List<Statement> getStatements() {
		return s;
	}

	@Override
	public String toString() {
		return "proc " + name + "(" + Helper.toStringParameters(p) + ") is\n" + Helper.indent(Helper.toString(s))
		        + "endproc\n";
	}
}
