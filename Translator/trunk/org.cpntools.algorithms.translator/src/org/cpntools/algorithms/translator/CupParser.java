package org.cpntools.algorithms.translator;

import java.io.File;
import java.io.FileReader;
import java.io.StringReader;

import org.cpntools.algorithms.translator.ast.Program;

public class CupParser {
	public static Program parse(final String program) throws Exception {
		final Scanner scanner = new Scanner(new StringReader(program));
		final ParserCup parser = new ParserCup(scanner);
		return (Program) parser.parse().value;
	}

	public static Program parse(final File file) throws Exception {
		final Scanner scanner = new Scanner(new FileReader(file));
		final ParserCup parser = new ParserCup(scanner);
		return (Program) parser.parse().value;
	}

}
