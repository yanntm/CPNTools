package org.cpntools.grader.model;

public class SimpleTestSuite extends TestSuite {
	public SimpleTestSuite(final int threshold, final String secret) {
		super(new SignGrader(1.0, threshold, secret));
	}
}
