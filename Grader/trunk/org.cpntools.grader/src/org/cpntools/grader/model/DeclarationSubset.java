package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.BitSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.HLDeclaration;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.declaration.GlobalReferenceDeclaration;
import org.cpntools.accesscpn.model.declaration.VariableDeclaration;

public class DeclarationSubset extends AbstractGrader {
	/**
	 * @author michael
	 * @param <E>
	 */
	private static final class PowerSet<E> implements Iterator<Set<E>>, Iterable<Set<E>> {
		private Object[] arr = null;
		private BitSet bset = null;

		/**
		 * @param set
		 */
		public PowerSet(final Set<E> set) {
			arr = set.toArray();
			bset = new BitSet(arr.length + 1);
		}

		/**
		 * @see java.util.Iterator#hasNext()
		 */
		@Override
		public boolean hasNext() {
			return !bset.get(arr.length);
		}

		/**
		 * @see java.lang.Iterable#iterator()
		 */
		@Override
		public Iterator<Set<E>> iterator() {
			return this;
		}

		/**
		 * @see java.util.Iterator#next()
		 */
		@SuppressWarnings("unchecked")
		@Override
		public Set<E> next() {
			final Set<E> returnSet = new TreeSet<E>();
			for (int i = 0; i < arr.length; i++) {
				if (bset.get(i)) {
					returnSet.add((E) arr[i]);
				}
			}
			for (int i = 0; i < bset.size(); i++) {
				if (!bset.get(i)) {
					bset.set(i);
					break;
				} else {
					bset.clear(i);
				}
			}

			return returnSet;
		}

		/**
		 * @see java.util.Iterator#remove()
		 */
		@Override
		public void remove() {
			throw new UnsupportedOperationException("Not Supported!");
		}
	}

	public static final Grader INSTANCE = new DeclarationSubset(0, false, 0, false, new ArrayList<String>());
	private final boolean globref;

	private final boolean subset;

	private final double subsetPoints;
	
	private final List<String> exclude;

	// subset = points to deduce for subset of declarations changed
	// globref = true/false whehter globref declarations may (not) be changed
	// ignore = list of declarations that will be ignored in the check
	Pattern p = Pattern.compile("^declaration-preservation(, *subset(=(-?[0-9.]+))?)?(, *globref(=(true|false))?)?(, *ignore=([a-z0-9. _']+(; *[a-z0-9. _']+)*))?$",
	        Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

	public DeclarationSubset(final double maxPoints, final boolean subset, final double subsetPoints,
	        final boolean globref, final List<String> exclude) {
		super(maxPoints);
		this.subset = subset;
		this.subsetPoints = subsetPoints;
		this.globref = globref;
		this.exclude = exclude;
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
			List<String> exclude = null;
			if (m.group(7) != null && m.group(7).length() > 0) {
				exclude = tokenize(m.group(8));
			} else {
				exclude = new ArrayList<String>();
			}
			return new DeclarationSubset(maxPoints, subset, subsetPoints, globref, exclude);
		}
		return null;
	}
	
	private List<String> tokenize(final String group) {
		final List<String> result = new ArrayList<String>();
		if (group != null) {
			for (final String child : group.split(";")) {
				if (child != null) {
					final String token = child.trim();
					if (!token.isEmpty()) {
						result.add(token);
					}
				}
			}
		}
		return result;
	}

	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		final Map<String, String> baseDecl = getDeclarations(base);
		final Map<String, String> modelDecl = getDeclarations(model);
		final Map<String, String> baseDeclCopy = new HashMap<String, String>(baseDecl);
		remove(baseDecl, modelDecl);
		remove(modelDecl, baseDeclCopy);
		final Set<String> addedDeclarations = new HashSet<String>(modelDecl.values());
		final Detail addedDetail = new Detail("Added declarations", addedDeclarations);
		
		// remove all declarations from the remaining ones in the base model that are allowed to be changed
		List<String> baseExcluded = new ArrayList<String>();
		for (String baseD : baseDecl.keySet()) {
			for (String excl : exclude) {
				if (baseD.indexOf(excl) >= 0) {
					baseExcluded.add(baseD);
					break;
				}
			}
		}
		for (String excl : baseExcluded) {
			baseDecl.remove(excl);
		} // baseDecl now contains the declarations removed from the model that were not allowed to be changed
		
		if (!baseDecl.isEmpty()) { return new Message(getMinPoints(),
		        "Some declarations were removed from the original model.", new Detail("Removed declarations",
		                baseDecl.values()), addedDetail); }
		
		if (modelDecl.isEmpty()) { return new Message(getMaxPoints(), "Declarations were preserved."); }
		if (subset) { return new Message(getMaxPoints(),
		        "Declarations were preserved and new ones were added (that is ok).", addedDetail); }
		return new Message(subsetPoints, "Declarations were preserved, but new ones were added (penalty of "
		        + Math.abs(getMaxPoints() - (subsetPoints < 0 ? 0 : subsetPoints)) + ").", addedDetail);
	}

	private void addSubsets(final Map<String, String> declarations, final String typeName, final SortedSet<String> names) {

	}

	private Map<String, String> getDeclarations(final PetriNet model) {
		final Map<String, String> declarations = new TreeMap<String, String>();
		for (final HLDeclaration d : model.declaration()) {
			if (globref && d.getStructure() instanceof GlobalReferenceDeclaration) {
				final GlobalReferenceDeclaration globref = (GlobalReferenceDeclaration) d.getStructure();
				declarations.put("globref " + globref.getName().trim(), d.asString().trim());
			} else if (d.getStructure() instanceof VariableDeclaration) {
				final VariableDeclaration var = (VariableDeclaration) d.getStructure();
				for (final Set<String> subset : new PowerSet<String>(new TreeSet<String>(var.getVariables()))) {
					declarations.put("var " + subset + ": " + var.getTypeName(), d.asString().trim());
				}
			} else {
				declarations.put(d.asString().trim().replaceAll("[ \t\n]+", " "), d.asString().trim());
			}
		}
		return declarations;
	}

	private void remove(final Map<String, String> baseDecl, final Map<String, String> modelDecl) {
		for (final String key : modelDecl.keySet()) {
			baseDecl.remove(key);
		}
	}
}
