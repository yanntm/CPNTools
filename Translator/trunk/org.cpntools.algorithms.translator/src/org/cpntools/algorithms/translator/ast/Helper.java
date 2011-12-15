package org.cpntools.algorithms.translator.ast;

import java.util.List;

/**
 * @author michael
 */
public class Helper {
	public static String toString(final List<? extends TopLevel> s) {
		final StringBuilder sb = new StringBuilder();
		for (final TopLevel ss : s) {
			sb.append(ss);
		}
		return sb.toString();
	}

	public static String toStringParameters(final List<Declaration> s) {
		final StringBuilder sb = new StringBuilder();
		boolean first = true;
		for (final Declaration ss : s) {
			if (first) {
				first = false;
			} else {
				sb.append(", ");
			}
			if (ss.getType() != null) {
				sb.append(ss.getType());
				sb.append(' ');
			}
			sb.append(ss.getId());
		}
		return sb.toString();
	}

	public static String indent(final String string) {
		return "\t" + string.replaceAll("\n", "\n\t").replaceAll("\t\t*$", "");
	}

	public static String toStringValues(final List<? extends Expression> v) {
		return toStringValues(v, ", ");
	}

	public static String toStringValues(final List<? extends Expression> v, final String seperator) {
		final StringBuilder sb = new StringBuilder();
		boolean first = true;
		for (final Expression vv : v) {
			if (first) {
				first = false;
			} else {
				sb.append(seperator);
			}
			sb.append(vv);
		}
		return sb.toString();
	}
}
