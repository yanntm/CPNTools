package org.cpntools.grader.model.btl;

import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("javadoc")
public class ChainedMapEnvironment extends FunctionalChainedMapEnvironment {
	/**
	 * 
	 */
	public ChainedMapEnvironment() {
		this(null);
	}

	/**
	 * @param parent
	 * @param elements
	 */
	public ChainedMapEnvironment(final Environment parent, final Map<String, String> elements) {
		super(parent, new HashMap<String, String>());
		if (elements != null) {
			values.putAll(elements);
		}
	}

	/**
	 * @param elements
	 */
	public ChainedMapEnvironment(final Map<String, String> elements) {
		this(null, elements);
	}

	/**
	 * @param key
	 * @param value
	 */
	public void put(final String key, final String value) {
		values.put(key, value);
	}
}
