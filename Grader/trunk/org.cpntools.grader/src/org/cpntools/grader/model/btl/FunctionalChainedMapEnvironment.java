package org.cpntools.grader.model.btl;

import java.util.Collections;
import java.util.Map;

public class FunctionalChainedMapEnvironment implements Environment {
	private final Environment parent;

	protected final Map<String, String> values;

	/**
	 * 
	 */
	public FunctionalChainedMapEnvironment() {
		this(null);
	}

	/**
	 * @param parent
	 * @param elements
	 */
	public FunctionalChainedMapEnvironment(final Environment parent, final Map<String, String> elements) {
		this.parent = parent;
		if (elements != null) {
			values = elements;
		} else {
			values = Collections.emptyMap();
		}
	}

	/**
	 * @param elements
	 */
	public FunctionalChainedMapEnvironment(final Map<String, String> elements) {
		this(null, elements);
	}

	/**
	 * @see org.cpntools.grader.model.btl.Environment#get(java.lang.String)
	 */
	@Override
	public String get(final String key) {
		final String result = values.get(key);
		if (result != null) { return result; }
		if (parent != null) { return parent.get(key); }
		return null;
	}

}
