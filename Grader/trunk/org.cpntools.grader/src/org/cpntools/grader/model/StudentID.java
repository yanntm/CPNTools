package org.cpntools.grader.model;

/**
 * @author michael
 */
public class StudentID {
	private final String id;

	/**
	 * @param id
	 */
	public StudentID(final String id) {
		this.id = id;
	}

	/**
	 * @return
	 */
	public String getId() {
		return id;
	}

	@Override
	public String toString() {
		return id;
	}
}
