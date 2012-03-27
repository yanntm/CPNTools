package org.cpntools.grader.model;

import java.util.Collections;

public class SimpleTestSuite extends TestSuite {
	public SimpleTestSuite(final int threshold, final String secret) {
		super(new SignatureGrader(-1.0, threshold, secret));
		graders.add(new NameCategorizer(-0.1));
		graders.add(new DeclarationSubset(-0.5, true, 0.0, true));
		graders.add(new InterfacePreservation(-0.5, -0.2, true, false, Collections.singletonList("System"), Collections
		        .<String> emptyList()));
	}
}
