package org.cpntools.grader.model;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.HLDeclaration;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.declaration.GlobalReferenceDeclaration;

public class DeclarationSubset extends AbstractGrader {
	public static final Grader INSTANCE = new DeclarationSubset(0, false, 0, false);

	Pattern p = Pattern.compile("^declaration-preservation(, *subset(=(-?[0-9.]+))?)?(, *globref(=(true|false))?)?$",
	        Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
	private final boolean subset;

	private final double subsetPoints;

	private final boolean globref;

	public DeclarationSubset(final double maxPoints, final boolean subset, final double subsetPoints,
	        final boolean globref) {
		super(maxPoints);
		this.subset = subset;
		this.subsetPoints = subsetPoints;
		this.globref = globref;
	}

	@Override
	public Grader configure(final double maxPoints, final String configuration) {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			final boolean subset = !(m.group(3) != null && m.group(3).length() > 0)
			        && !(m.group(1) != null && m.group(1).length() > 0);
			double subsetPoints = 0.0;
			if (m.group(3) != null && m.group(3).length() > 0) {
				subsetPoints = Double.parseDouble(m.group(3));
			}
			boolean globref = false;
			if (m.group(4) != null && m.group(4).length() > 0) {
				globref = m.group(6) == null || Boolean.parseBoolean(m.group(6));
			}
			return new DeclarationSubset(maxPoints, subset, subsetPoints, globref);
		}
		return null;
	}

	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		final Map<String, String> baseDecl = getDeclarations(base);
		final Map<String, String> modelDecl = getDeclarations(model);
		final Map<String, String> baseDeclCopy = new HashMap<String, String>(baseDecl);
		remove(baseDecl, modelDecl);
		remove(modelDecl, baseDeclCopy);
		final Detail addedDetail = new Detail("Added declarations", modelDecl.values());
		if (!baseDecl.isEmpty()) { return new Message(getMinPoints(),
		        "Some declarations were removed from the original model.", new Detail("Removed declarations",
		                baseDecl.values()), addedDetail); }
		if (modelDecl.isEmpty()) { return new Message(getMaxPoints(), "Declarations were preserved."); }
		if (subset) { return new Message(getMaxPoints(),
		        "Declarations were preserved and new ones were added (that is ok).", addedDetail); }
		return new Message(subsetPoints, "Declarations were preserved, but new ones were added (penalty of "
		        + Math.abs(getMaxPoints() - (subsetPoints < 0 ? 0 : subsetPoints)) + ").", addedDetail);
	}

	private void remove(final Map<String, String> baseDecl, final Map<String, String> modelDecl) {
		for (final String key : modelDecl.keySet()) {
			baseDecl.remove(key);
		}
	}

	private Map<String, String> getDeclarations(final PetriNet model) {
		final Map<String, String> declarations = new HashMap<String, String>();
		for (final HLDeclaration d : model.declaration()) {
			if (globref && d.getStructure() instanceof GlobalReferenceDeclaration) {
				final GlobalReferenceDeclaration globref = (GlobalReferenceDeclaration) d.getStructure();
				declarations.put("globref " + globref.getName().trim(), d.asString().trim());
			} else {
				declarations.put(d.asString().trim().replaceAll("[ \t\n]+", " "), d.asString().trim());
			}
		}
		return declarations;
	}
}
