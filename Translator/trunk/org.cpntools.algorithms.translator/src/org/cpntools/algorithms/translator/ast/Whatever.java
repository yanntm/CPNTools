package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class Whatever extends Expression {

	private final String w;

	public Whatever(final String w) {
		this.w = w;
	}

	public String getContents() {
		return w;
	}

	@Override
	public String toString() {
		return w;
	}

}
