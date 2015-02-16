package org.cpntools.grader.model;

import java.util.BitSet;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
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

	public static final Grader INSTANCE = new DeclarationSubset(0, false, 0, false);
	private final boolean globref;

	private final boolean subset;

	private final double subsetPoints;

	Pattern p = Pattern.compile("^declaration-preservation(, *subset(=(-?[0-9.]+))?)?(, *globref(=(true|false))?)?$",
	        Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

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
		final Set<String> addedDeclarations = new HashSet<String>(modelDecl.values());
		final Detail addedDetail = new Detail("Added declarations", addedDeclarations);
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
