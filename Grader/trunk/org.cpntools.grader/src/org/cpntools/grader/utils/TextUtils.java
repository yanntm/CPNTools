package org.cpntools.grader.utils;

/**
 * @author michael
 */
public class TextUtils {
	public static String stringToHTMLString(final String string) {
		final StringBuilder sb = new StringBuilder();
		boolean lastWasBlankChar = false;
		final int len = string.length();
		char c;

		for (int i = 0; i < len; i++) {
			c = string.charAt(i);
			if (c == ' ') {
				if (lastWasBlankChar) {
					lastWasBlankChar = false;
// sb.append("&nbsp;");
					sb.append(' ');
				} else {
					lastWasBlankChar = true;
					sb.append(' ');
				}
			} else {
				lastWasBlankChar = false;
				if (c == '"') {
					sb.append("&quot;");
				} else if (c == '&') {
					sb.append("&amp;");
				} else if (c == '<') {
					sb.append("&lt;");
				} else if (c == '>') {
					sb.append("&gt;");
				} else if (c == '\n') {
					sb.append("<br/>");
				} else {
					final int ci = 0xffff & c;
					if (ci < 160) {
						sb.append(c);
					} else {
						sb.append("&#");
						sb.append(new Integer(ci).toString());
						sb.append(';');
					}
				}
			}
		}
		return sb.toString();
	}
}
