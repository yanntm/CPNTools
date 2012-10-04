package org.cpntools.grader.model.btl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;

/**
 * @author michael
 */
public class NewTransitionStrategy<T> implements Strategy<T> {
	private static final Random r = new Random();
	LinkedList<T> previous = new LinkedList<T>();

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
		if (possible.isEmpty()) {
			possible.addAll(candidates);
		}

		HashSet<T> cs = new HashSet<T>(possible);
		cs.removeAll(previous);
		if (!cs.isEmpty()) {
			final List<T> csl = new ArrayList<T>(cs);
			Collections.shuffle(csl);
			for (final T c : csl) {
				previous.addFirst(c);
			}
		}
		cs = new HashSet<T>(possible);
		T t = null;
		for (final Iterator<T> it = previous.iterator(); it.hasNext();) {
			t = it.next();
			if (cs.contains(t)) {
				it.remove();
				break;
			}
		}
		previous.addLast(t);
		return t;
	}

	@Override
	public String toString() {
		return "New Transition";
	}

}
