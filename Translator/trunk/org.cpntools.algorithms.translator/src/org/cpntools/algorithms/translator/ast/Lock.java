package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class Lock extends Statement {

	private final String l;
	private final List<Statement> s;

	public Lock(final String l, final List<Statement> s) {
		this.l = l;
		Collections.reverse(s);
		this.s = s;
	}

	public Lock(final Statement t, final String lockName, final List<Statement> translate) {
		this(lockName, translate);
		init(t);
	}

	public String getLockName() {
		return l;
	}

	public List<Statement> getStatements() {
		return s;
	}

	@Override
	public String toString() {
		return "lock " + l + "\n" + Helper.indent(Helper.toString(s)) + "unlock\n";
	}
}
