package org.cpntools.grader.model.btl;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/**
 * @author michael
 */
public class CoverageMaximizer<T> implements Strategy<T> {
	private static final Random r = new Random();

	@SuppressWarnings("javadoc")
	@Override
	public T getOne(final DecisionTree<T> decisionTree, final Node<T> current, final List<T> candidates) {
		final List<T> possible = new ArrayList<T>();
		double coverage = 1.0;
		for (final Node<T> child : current) {
			if (child.getCoverage() < coverage) {
				coverage = child.getCoverage();
				possible.clear();
			}
			if (child.getCoverage() == coverage) {
				possible.add(child.getBranch());
			}
		}
		if (possible.size() > 0) { return possible.get(r.nextInt(possible.size())); }
		return candidates.get(r.nextInt(candidates.size()));
	}

	@Override
	public String toString() {
		return "Coverage Maximizer";
	}

}
