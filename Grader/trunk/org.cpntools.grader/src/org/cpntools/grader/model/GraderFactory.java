package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.List;

import org.cpntools.grader.model.btl.BTLGrader;

/**
 * @author michael
 */
public class GraderFactory {
	/**
	 * 
	 */
	public static final GraderFactory INSTANCE = new GraderFactory();

	static {
		GraderFactory.INSTANCE.register(NameCategorizer.INSTANCE);
		GraderFactory.INSTANCE.register(SignatureGrader.INSTANCE);
		GraderFactory.INSTANCE.register(DeclarationSubset.INSTANCE);
		GraderFactory.INSTANCE.register(InterfacePreservation.INSTANCE);
		GraderFactory.INSTANCE.register(BTLGrader.INSTANCE);
		GraderFactory.INSTANCE.register(MonitoringGrader.INSTANCE);
		GraderFactory.INSTANCE.register(TerminationGrader.INSTANCE);
	}

	protected List<Grader> graders = new ArrayList<Grader>();

	/**
	 * @param points
	 * @param configuration
	 * @return
	 * @throws Exception
	 */
	public Grader getGrader(final double points, final String configuration) throws Exception {
		for (final Grader g : graders) {
			final Grader result = g.configure(points, configuration);
			if (result != null) { return result; }
		}
		return NullGrader.INSTANCE;
	}

	/**
	 * @param g
	 */
	public void register(final Grader g) {
		graders.add(g);
	}
}
