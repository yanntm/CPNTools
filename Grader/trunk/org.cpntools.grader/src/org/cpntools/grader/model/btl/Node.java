package org.cpntools.grader.model.btl;

public interface Node<T> extends Iterable<Node<T>> {
	/**
	 * @return
	 * @throws Unsatisfied
	 */
	double getSatisfactionProbability() throws Unsatisfied;

	/**
	 * @return
	 */
	double getTraceSatisfactionProbability();

	/**
	 * @param node
	 * @return
	 */
	Node<T> addNode(Node<T> node);

	/**
	 * 
	 */
	void invalidate();

	/**
	 * 
	 */
	void validate();

	/**
	 * @return
	 */
	double getCoverage();

	/**
	 * @return
	 */
	boolean isExpanded();

	/**
	 * @return
	 */
	T getBranch();

}
