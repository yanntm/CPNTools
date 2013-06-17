package org.cpntools.grader.model.btl.parser;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.StringReader;

import org.cpntools.grader.model.btl.model.Guide;

/**
 * @author michael
 */
public class CupParser {
	public static void main(final String[] args) throws Exception {
		System.out.print("Please enter a guide: ");
		final String formula = new BufferedReader(new InputStreamReader(System.in)).readLine();
		final Guide f = CupParser.parse(formula);
		System.out.println("Parsed as: " + f);
	}

	/**
	 * @param guide
	 * @return
	 * @throws Exception
	 */
	public static Guide parse(final String guide) throws Exception {
		final Scanner scanner = new Scanner(new StringReader(guide));
		final ParserCup parser = new ParserCup(scanner);
		return (Guide) parser.parse().value;
	}
}
