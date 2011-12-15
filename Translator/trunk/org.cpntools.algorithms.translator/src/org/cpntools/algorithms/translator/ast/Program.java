package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class Program {

	private final List<TopLevel> t;

	public Program(final List<TopLevel> t) {
		Collections.reverse(t);
		this.t = t;
	}

	public List<TopLevel> getTopLevels() {
		return t;
	}

	@Override
	public String toString() {
		return Helper.toString(t);
	}
}
