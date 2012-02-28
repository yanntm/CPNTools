package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.List;

/**
 * @author michael
 */
public class GraderFactory {
	protected List<Grader> graders = new ArrayList<Grader>();

	/**
	 * 
	 */
	public static final GraderFactory INSTANCE = new GraderFactory();

	/**
	 * @param g
	 */
	public void register(final Grader g) {
		graders.add(g);
	}

	/**
	 * @param points
	 * @param configuration
	 * @return
	 */
	public Grader getGrader(final double points, final String configuration) {
		for (final Grader g : graders) {
			final Grader result = g.configure(points, configuration);
			if (result != null) { return result; }
		}
		return NullGrader.INSTANCE;
	}
}
