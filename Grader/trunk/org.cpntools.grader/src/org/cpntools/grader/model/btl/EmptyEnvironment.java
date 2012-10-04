package org.cpntools.grader.model.btl;

/**
 * @author michael
 */
public class EmptyEnvironment implements Environment {
	public static final Environment INSTANCE = new EmptyEnvironment();

	/**
	 * @see org.cpntools.grader.model.btl.Environment#get(java.lang.String)
	 */
	@Override
	public String get(final String key) {
		return null;
	}

}
