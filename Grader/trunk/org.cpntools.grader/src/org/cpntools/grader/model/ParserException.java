package org.cpntools.grader.model;

/**
 * @author michael
 */
public class ParserException extends Exception {

	private final int lineNumber;
	private final String line;

	/**
	 * @param lineNumber
	 * @param string
	 * @param line
	 */
	public ParserException(final int lineNumber, final String string, final String line, final Exception e) {
		super("Error on line " + lineNumber + ": " + string, e);
		this.lineNumber = lineNumber;
		this.line = line;
	}

	public String getLine() {
		return line;
	}

	public int getLineNumber() {
		return lineNumber;
	}

	/**
     * 
     */
	private static final long serialVersionUID = 7807763406411898579L;

}
