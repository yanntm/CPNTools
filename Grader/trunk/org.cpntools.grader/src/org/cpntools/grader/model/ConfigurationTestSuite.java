package org.cpntools.grader.model;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class ConfigurationTestSuite extends TestSuite {

	/**
	 * @param file
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws ParserException
	 */
	public ConfigurationTestSuite(final File file, final String secret) throws FileNotFoundException, IOException,
	        ParserException {
		super(Parser.parse(new FileInputStream(file), "matcher", GraderFactory.INSTANCE).get(0));
		graders.addAll(Parser.parse(new FileInputStream(file), "tests", GraderFactory.INSTANCE));
		setSecret(matcher, secret);
		for (final Grader grader : getGraders()) {
			setSecret(grader, secret);
		}
	}

	private void setSecret(final Grader matcher, final String secret) {
		if (matcher instanceof SignatureGrader) {
			final SignatureGrader signatureGrader = (SignatureGrader) matcher;
			signatureGrader.setSecret(secret);
		}
	}

}
