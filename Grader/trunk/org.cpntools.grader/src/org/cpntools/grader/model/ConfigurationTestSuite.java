package org.cpntools.grader.model;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

public class ConfigurationTestSuite extends TestSuite {
	public ConfigurationTestSuite(final File file, final String secret) throws FileNotFoundException, IOException,
	        ParserException {
		this(new FileInputStream(file), secret);
	}

	/**
	 * @param file
	 * @throws FileNotFoundException
	 * @throws IOException
	 * @throws ParserException
	 */
	public ConfigurationTestSuite(InputStream file, final String secret) throws FileNotFoundException, IOException,
	        ParserException {
		super(Parser.parse(file = new BufferedInputStream(file), "matcher", GraderFactory.INSTANCE).get(0));
		file.reset();
		graders.addAll(Parser.parse(file, "tests", GraderFactory.INSTANCE));
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
