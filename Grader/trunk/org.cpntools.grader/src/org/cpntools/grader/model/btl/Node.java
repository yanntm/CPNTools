package org.cpntools.grader.model.btl;

public interface Node<T> extends Iterable<Node<T>> {
	/**
	 * @param node
	 * @return
	 */
	Node<T> addNode(Node<T> node);

	/**
	 * @return
	 */
	T getBranch();

	/**
	 * @return
	 */
	double getCoverage();

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
	 * 
	 */
	void invalidate();

	/**
	 * @return
	 */
	boolean isExpanded();

	/**
	 * 
	 */
	void validate();

}
