package org.cpntools.grader.model;

import java.util.HashSet;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.HLDeclaration;
import org.cpntools.accesscpn.model.PetriNet;

public class DeclarationSubset extends AbstractGrader {
	public static final Grader INSTANCE = new DeclarationSubset(0, false, 0);

	Pattern p = Pattern.compile("^declaration-preservation(, *subset(=(-?[0-9.]+))?)?$", Pattern.CASE_INSENSITIVE);
	private final boolean subset;

	private final double subsetPoints;

	public DeclarationSubset(final double maxPoints, final boolean subset, final double subsetPoints) {
		super(maxPoints);
		this.subset = subset;
		this.subsetPoints = subsetPoints;
	}

	@Override
	public Grader configure(final double maxPoints, final String configuration) {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			if (m.group(1) != null && m.group(1).length() > 0) { return new DeclarationSubset(maxPoints, false, 0.0); }
			if (m.group(3) != null && m.group(3).length() > 0) {
				return new DeclarationSubset(maxPoints, false, Double.parseDouble(m.group(3)));
			} else {
				return new DeclarationSubset(maxPoints, true, 0.0);
			}
		}
		return null;
	}

	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		final Set<String> baseDecl = getDeclarations(base);
		final Set<String> modelDecl = getDeclarations(model);
		final int count = baseDecl.size();
		baseDecl.removeAll(modelDecl);
		if (!baseDecl.isEmpty()) { return new Message(getMinPoints(),
		        "Some declarations were removed from the original model " + baseDecl); }
		if (count == modelDecl.size()) { return new Message(getMaxPoints(), "Declarations were preserved."); }
		if (subset) { return new Message(getMaxPoints(),
		        "Declarations were preserved and new ones were added (that is ok)."); }
		return new Message(subsetPoints, "Declarations were preserved, but new ones were added (penalty of "
		        + Math.abs(getMaxPoints() - (subsetPoints < 0 ? 0 : subsetPoints)) + ").");
	}

	private Set<String> getDeclarations(final PetriNet model) {
		final Set<String> declarations = new HashSet<String>();
		for (final HLDeclaration d : model.declaration()) {
			declarations.add(d.asString().trim());
		}
		return declarations;
	}
}
