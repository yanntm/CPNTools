package org.cpntools.grader.model.btl;

/**
 * @author michael
 * @param <T>
 */
public class SimpleNode<T> extends AbstractNode<T> {

	/**
	 * @param branch
	 */
	public SimpleNode(final T branch) {
		super(branch);
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#getSatisfactionProbability()
	 */
	@Override
	public double getSatisfactionProbability() throws Unsatisfied {
		if (!valid) { throw new Unsatisfied(); }
		double result = 0;
		int count = 0;
		for (final Node<T> child : this) {
			result += child.getSatisfactionProbability();
			count++;
		}
		if (count == 0) {
			if (expanded) {
				return 1.0;
			} else {
				return 0.0;
			}
		}
		return result / count;
	}
}
