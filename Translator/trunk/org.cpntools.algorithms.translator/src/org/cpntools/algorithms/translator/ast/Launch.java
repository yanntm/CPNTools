package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class Launch extends TopLevel {

	private final List<Invocation> i;

	public Launch(final List<Invocation> i) {
		Collections.reverse(i);
		this.i = i;
	}

	public List<Invocation> getInvocations() {
		return i;
	}

	@Override
	public String toString() {
		return Helper.toStringValues(i, " || ") + "\n";
	}
}
