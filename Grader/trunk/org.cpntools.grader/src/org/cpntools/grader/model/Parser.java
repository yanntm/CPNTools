package org.cpntools.grader.model;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author michael
 */
public class Parser {

	protected static final Pattern comment = Pattern.compile("^[ \\t]*(//|#)");
	protected static final Pattern nextLine = Pattern.compile("^[ \\t]*\\+[ \\t]*(.*)$");
	protected static final Pattern points = Pattern.compile("^[ \\t]*(-?[0-9.]+)[ \\t]*:[ \\t]*(.*)$");

	public synchronized static List<Grader> parse(final InputStream i, final String section, final GraderFactory factory)
	        throws IOException, ParserException {
		i.mark(1000000);
		final BufferedReader reader = new BufferedReader(new InputStreamReader(i));
		final List<Grader> result = new ArrayList<Grader>();
		String line = reader.readLine();
		int lineNumber = 1;

		// Skip to correct section
		if (section != null) {
			final String header = "[" + section.trim().toLowerCase() + "]";
			while (line != null && !header.equals(line.trim().toLowerCase())) {
				line = reader.readLine();
				lineNumber++;
			}
			if (line != null) {
				line = reader.readLine();
				lineNumber++;
			} else {
				throw new ParserException(-1, "Did not find a `" + section + "' section in the input", null, null);
			}
		}

		while (line != null && !line.matches("^ *\\[.*\\] *$")) {
			final Matcher m = Parser.points.matcher(line);
			if (m.matches()) {
				double points = 0.0;
				if (m.group(1) != null && m.group(1).length() > 0) {
					points = Double.parseDouble(m.group(1));
				}
				String configuration = "";
				if (m.group(2) != null) {
					configuration = m.group(2).trim();
				}
				final String firstLine = line;
				final int firstLineNumber = lineNumber;

				// Include next line if this ends on \ or if next starts with +
				line = reader.readLine();
				lineNumber++;
				Matcher m2 = line == null ? null : Parser.nextLine.matcher(line);
				boolean backslash = configuration.endsWith("\\");
				boolean matches = m2 == null ? false : m2.matches() && m2.group(1) != null;
				while (line != null && (backslash || matches)) {
					if (backslash) {
						configuration = configuration.substring(0, configuration.length() - 1) + " " + line.trim();
					} else {
						configuration = configuration + '\n' + m2.group(1).trim();
					}

					line = reader.readLine();
					lineNumber = lineNumber++;
					m2 = line == null ? null : Parser.nextLine.matcher(line);
					backslash = configuration.endsWith("\\");
					matches = m2 == null ? false : m2.matches() && m2.group(1) != null;
				}

				Grader grader = null;
				Exception exception = null;
				try {
					grader = factory.getGrader(points, configuration);
				} catch (final Exception e) {
					exception = e;
				}
				if (grader != null && grader != NullGrader.INSTANCE) {
					result.add(grader);
				} else {
					throw new ParserException(firstLineNumber, "Found no matching grader for this line"
					        + (lineNumber - firstLineNumber > 2 ? " (and the " + (lineNumber - firstLineNumber - 1)
					                + " following line(s))" : ""), firstLine, exception);
				}
			} else {
				if (!Parser.comment.matcher(line).matches() && !line.trim().isEmpty()) { throw new ParserException(
				        lineNumber, "I do not understand this line", line, null); }
				line = reader.readLine();
				lineNumber = lineNumber++;

			}
		}

		return result;
	}

}
