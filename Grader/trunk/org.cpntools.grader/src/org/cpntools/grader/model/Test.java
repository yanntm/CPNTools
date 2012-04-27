package org.cpntools.grader.model;

public class Test {

	/**
	 * @param args
	 */
	public static void main(final String[] args) {
		for (final String s : "<table><tr><th><tr><td><table><tr>"
		        .split("(?=(?!^)(<table|<tr>))(?<!(<table|<tr>))|(?!(<table|<tr>))(?<=(<table|<tr>))")) {
			System.out.println(s);
		}

	}

}
