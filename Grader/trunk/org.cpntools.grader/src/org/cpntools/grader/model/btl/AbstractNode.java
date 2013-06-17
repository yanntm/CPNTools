package org.cpntools.grader.model.btl;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * @author michael
 * @param <T>
 */
public abstract class AbstractNode<T> implements Node<T>, Iterable<Node<T>> {
	private final T branch;
	private final Map<Node<T>, Node<T>> children = new HashMap<Node<T>, Node<T>>();
	protected boolean expanded = false;

	protected boolean valid = true;

	/**
	 * @param branch
	 */
	public AbstractNode(final T branch) {
		this.branch = branch;

	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#addNode(org.cpntools.grader.model.btl.Node)
	 */
	@Override
	public Node<T> addNode(final Node<T> node) {
		if (children.containsKey(node)) { return children.get(node); }
		children.put(node, node);
		return node;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@SuppressWarnings("rawtypes")
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof AbstractNode)) { return false; }
		final AbstractNode other = (AbstractNode) obj;
		if (branch == null) {
			if (other.branch != null) { return false; }
		} else if (!branch.equals(other.branch)) { return false; }
		return true;
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#getBranch()
	 */
	@Override
	public T getBranch() {
		return branch;
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#getCoverage()
	 */
	@Override
	public double getCoverage() {
		double result = 0;
		int count = 0;
		for (final Node<T> child : this) {
			result += child.getCoverage();
			count++;
		}
		if (count == 0) {
			if (expanded) {
				return 1;
			} else {
				return 0;
			}
		}
		return result / count;
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#getTraceSatisfactionProbability()
	 */
	@Override
	public double getTraceSatisfactionProbability() {
		if (!valid) { return 0; }
		double result = 0;
		int count = 0;
		for (final Node<T> child : this) {
			result += child.getTraceSatisfactionProbability();
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

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (branch == null ? 0 : branch.hashCode());
		return result;
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#invalidate()
	 */
	@Override
	public void invalidate() {
		expanded = true;
		valid = false;
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#isExpanded()
	 */
	@Override
	public boolean isExpanded() {
		return expanded;
	}

	/**
	 * @see java.lang.Iterable#iterator()
	 */
	@Override
	public Iterator<Node<T>> iterator() {
		return children.keySet().iterator();
	}

	@Override
	public String toString() {
		final StringBuilder sb = new StringBuilder();
		if (branch == null) {
			sb.append("<root>");
		} else {
			sb.append(branch);
		}
		sb.append(" (");
		if (expanded) {
			sb.append(valid);
			sb.append("; ");
		}
		try {
			sb.append(getSatisfactionProbability());
		} catch (final Unsatisfied e) {
			sb.append("unsat");
		}
		sb.append("; ");
		sb.append(getTraceSatisfactionProbability());
		sb.append("; ");
		sb.append(getCoverage());
		sb.append(")");
		for (final Iterator<Node<T>> it = iterator(); it.hasNext();) {
			final Node<T> child = it.next();
			sb.append("\n+--");
			if (it.hasNext()) {
				sb.append(child.toString().replaceAll("\n", "\n|  "));
			} else {
				sb.append(child.toString().replaceAll("\n", "\n   "));
			}
		}
		return sb.toString();
	}

	/**
	 * @see org.cpntools.grader.model.btl.Node#validate()
	 */
	@Override
	public void validate() {
		expanded = true;
		valid = true;
	}
}
