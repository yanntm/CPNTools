package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.List;

import org.cpntools.grader.model.btl.BTLGrader;

/**
 * @author michael
 */
public class GraderFactory {
	protected List<Grader> graders = new ArrayList<Grader>();

	/**
	 * 
	 */
	public static final GraderFactory INSTANCE = new GraderFactory();

	static {
		INSTANCE.register(NameCategorizer.INSTANCE);
		INSTANCE.register(SignatureGrader.INSTANCE);
		INSTANCE.register(DeclarationSubset.INSTANCE);
		INSTANCE.register(InterfacePreservation.INSTANCE);
		INSTANCE.register(BTLGrader.INSTANCE);
	}

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
