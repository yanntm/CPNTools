package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class MethodInvocation extends Expression {

	private final Expression object;
	private final Invocation method;

	public MethodInvocation(final Expression object, final Invocation method) {
		this.object = object;
		this.method = method;
	}

	public MethodInvocation(final TopLevel e, final Expression translate, final Invocation translate2) {
		this(translate, translate2);
		init(e);
	}

	public Expression getObject() {
		return object;
	}

	public Invocation getMethod() {
		return method;
	}

	@Override
	public String toString() {
		return "(" + object + "." + method + ")";
	}
}
