package org.cpntools.grader.model.btl;

import java.text.DecimalFormat;

/**
 * @author michael
 * @param <T>
 */
public class DecisionTree<T> {
	private final DecimalFormat f = new DecimalFormat("#.#");

	Node<T> root = new RootNode<T>();

	public Node<T> addChild(final Node<T> parent, final T child) {
		final Node<T> n = new SimpleNode<T>(child);
		if (parent == null) {
			return root.addNode(n);
		} else {
			return parent.addNode(n);
		}
	}

	public Node<T> addChild(final T child) {
		return addChild(null, child);
	}

	/**
	 * @return
	 */
	public double getCoverage() {
		return root.getCoverage();
	}

	public Node<T> getRoot() {
		return root;
	}

	/**
	 * @return
	 */
	public double getSatisfactionProbability() {
		try {
			return root.getSatisfactionProbability();
		} catch (final Unsatisfied e) {
			return 0;
		}
	}

	/**
	 * @return
	 */
	public double getTraceSatisfactionProbability() {
		return root.getTraceSatisfactionProbability();
	}

	public String round(final double d) {
		return f.format(d * 100);
	}

	@Override
	public String toString() {
		return "Trace coverage: " + round(root.getCoverage()) + " %\nSatisfaction probability: "
		        + round(getSatisfactionProbability()) + " %\nTrace satisfaction probability: "
		        + round(getTraceSatisfactionProbability()) + " %";// \n" + root;
	}
}
