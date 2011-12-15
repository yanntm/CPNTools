package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class Declaration extends Statement {

	private final String type;
	private final String name;

	public Declaration(final String type, final String name) {
		this.type = type;
		this.name = name;
	}

	public Declaration(final String name) {
		this(null, name);
	}

	public Declaration(final Statement t, final String string, final String name2) {
		this(string, name2);
		init(t);
	}

	public String getType() {
		return type;
	}

	public String getId() {
		return name;
	}

	@Override
	public String toString() {
		return type + " " + name + "\n";
	}
}
