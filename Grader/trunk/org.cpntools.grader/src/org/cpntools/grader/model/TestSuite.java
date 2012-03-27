package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class TestSuite {
	protected final List<Grader> graders = new ArrayList<Grader>();
	private final List<Grader> graders_u = Collections.unmodifiableList(graders);

	protected final Grader matcher;

	public TestSuite(final Grader matcher) {
		this.matcher = matcher;
	}

	/**
	 * @return
	 */
	public Grader getMatcher() {
		return matcher;
	}

	/**
	 * @return
	 */
	public List<Grader> getGraders() {
		return graders_u;
	}

}
