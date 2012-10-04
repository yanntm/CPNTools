package org.cpntools.grader.model.btl;

import java.util.List;

/**
 * @author michael
 * @param <T>
 */
public interface Strategy<T> {
	/**
	 * @param decisionTree
	 * @param current
	 * @param candidates
	 * @return
	 */
	T getOne(DecisionTree<T> decisionTree, Node<T> current, List<T> candidates);
}
