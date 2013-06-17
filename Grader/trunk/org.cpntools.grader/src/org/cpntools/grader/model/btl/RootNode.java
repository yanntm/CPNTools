package org.cpntools.grader.model.btl;

/**
 * @author michael
 * @param <T>
 */
public class RootNode<T> extends SimpleNode<T> {

	/**
	 * @param branch
	 */
	public RootNode() {
		super(null);
	}

	/**
	 * @see org.cpntools.grader.model.btl.AbstractNode#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object other) {
		return this == other;
	}

	/**
	 * @see org.cpntools.grader.model.btl.AbstractNode#hashCode()
	 */
	@Override
	public int hashCode() {
		return 7;
	}

}
