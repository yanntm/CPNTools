package org.cpntools.grader.model.btl;

import java.util.List;
import java.util.Random;

/**
 * @author michael
 */
public class RandomStrategy<T> implements Strategy<T> {
	private static final Random r = new Random();

	@SuppressWarnings("javadoc")
	@Override
	public T getOne(final DecisionTree<T> decisionTree, final Node<T> current, final List<T> candidates) {
		return candidates.get(r.nextInt(candidates.size()));
	}

	@Override
	public String toString() {
		return "Random";
	}

}
