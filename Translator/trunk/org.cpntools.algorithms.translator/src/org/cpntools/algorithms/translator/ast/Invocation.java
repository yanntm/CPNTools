package org.cpntools.algorithms.translator.ast;

import java.util.Collections;
import java.util.List;

public class Invocation extends Expression {

	private final String name;
	private final List<Expression> v;

	public Invocation(final String name, final List<Expression> v) {
		this.name = name;
		Collections.reverse(v);
		this.v = v;
	}

	public Invocation(final TopLevel e, final String name2, final List<Expression> values) {
		this(name2, values);
		init(e);
	}

	public String getName() {
		return name;
	}

	public List<Expression> getValues() {
		return v;
	}

	@Override
	public String toString() {
		return name + "(" + Helper.toStringValues(v) + ")";
	}
}
