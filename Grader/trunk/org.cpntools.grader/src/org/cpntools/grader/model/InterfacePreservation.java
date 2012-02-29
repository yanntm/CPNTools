package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.PageSorter;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.model.Annotation;
import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.HLArcType;
import org.cpntools.accesscpn.model.Node;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Place;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.accesscpn.model.RefPlace;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.TransitionNode;

/**
 * @author michael
 */
public class InterfacePreservation extends AbstractGrader {
	public static final Grader INSTANCE = new InterfacePreservation(0, 0, true, false,
	        Collections.<String> emptyList(), Collections.<String> emptyList());

	Pattern p = Pattern
	        .compile(
	                "^interface-preservation(, *partial=(-?[0-9.]+))?(, *addpages(=(true|false))?)?(, *initmark(=(true|false))?)?(, *subset=([a-z0-9. _']+(; *[a-z0-9. _']+)*))?(, *ignore=([a-z0-9. _']+(; *[a-z0-9. _']+)*))?$",
	                Pattern.CASE_INSENSITIVE);

	private final double partial;

	private final boolean addpages;

	private final List<String> subset;

	private final List<String> exclude;

	private final boolean initmark;

	/**
	 * @param maxPoints
	 *            points awarded for correct answer
	 * @param partial
	 *            partial credit (if some page is to be an exact match but something is added, if addpages is false but
	 *            pages are added)
	 * @param addpages
	 *            is it allowed to add new pages (true = yes, defult = true)
	 * @param initmark
	 *            should the initial marking be considered (true = yes, default = false)
	 * @param subset
	 *            list of page names for which matching is not exact but only subset. Page names are given as list of
	 *            substitution transitions. Only alphanumeric characters are considered and names are case-insensitive
	 *            (i.e., "Page Name" is the same as "PageName" and "pagename"). If the page name is unique (after this
	 *            transformation), the full path does not have to be given. If page names are not unique, pages closer
	 *            to the top of the hierarchy are given priority. Instances can only be handled using absolute naming.
	 *            The absolute naming can start at any level. If two substitution transitions on the same page have the
	 *            same names, there is no way to distinguish the subpages if they have the same names.
	 * @param exclude
	 *            list of page names to ignore from the base model when comparing. Same format as for subset.
	 */
	public InterfacePreservation(final double maxPoints, final double partial, final boolean addpages,
	        final boolean initmark, final List<String> subset, final List<String> exclude) {
		super(maxPoints);
		this.partial = partial;
		this.addpages = addpages;
		this.initmark = initmark;
		this.subset = cleanup(subset);
		this.exclude = cleanup(exclude);
	}

	private List<String> cleanup(final List<String> strings) {
		final List<String> result = new ArrayList<String>(strings.size());
		for (final String string : strings) {
			final String token = cleanup(string);
			if (!token.isEmpty()) {
				result.add(token);
			}
		}
		return result;
	}

	/**
	 * @see org.cpntools.grader.model.Grader#configure(double, java.lang.String)
	 */
	@SuppressWarnings("hiding")
	@Override
	public Grader configure(final double maxPoints, final String configuration) {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			double partial = 0.0;
			if (m.group(2) != null && m.group(2).length() > 0) {
				partial = Double.parseDouble(m.group(2));
			}
			;
			final boolean addpages = !"false".equalsIgnoreCase(m.group(5)); // We need double negations to make the
// default true
			boolean initmark = false;
			if (m.group(6) != null && m.group(6).length() > 0 && !"false".equalsIgnoreCase(m.group(8))) {
				initmark = true;
			}
			final List<String> subset = tokenize(m.group(10));
			final List<String> exclude = tokenize(m.group(13));
			return new InterfacePreservation(maxPoints, partial, addpages, initmark, subset, exclude);
		}
		return null;
	}

	private List<String> tokenize(final String group) {
		final List<String> result = new ArrayList<String>();
		if (group != null) {
			for (final String child : group.split(";")) {
				if (child != null) {
					final String token = child.trim().toLowerCase();
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
		final Map<String, Page> basePageNames = extractPageNames(base);
		final Map<String, String> baseShortcuts = extractShortcuts(base);
		final Map<String, Page> modelPageNames = extractPageNames(model);
		for (final String name : exclude) {
			final String shortcut = baseShortcuts.get(name);
			basePageNames.remove(shortcut);
			modelPageNames.remove(shortcut);
		}
		final Set<String> baseNames = new HashSet<String>(basePageNames.keySet());
		baseNames.removeAll(modelPageNames.keySet());
		if (!baseNames.isEmpty()) { return new Message(getMinPoints(), "These pages were deleted from the interface: "
		        + getNames(baseNames, base, basePageNames)); }

		final Set<String> exactNames = new HashSet<String>(basePageNames.keySet());
		final Set<String> subsetNames = new HashSet<String>();
		for (final String s : subset) {
			final String shortcut = baseShortcuts.get(s);
			if (exactNames.remove(shortcut)) {
				subsetNames.add(shortcut);
			}
		}

		final Set<String> removeNames = new HashSet<String>();
		for (final String name : new ArrayList<String>(exactNames)) {
			final int compare = compare(basePageNames.get(name), modelPageNames.get(name));
			if (compare < 0) {
				removeNames.add(name);
			} else if (compare == 0) {
				exactNames.remove(name);
			}
		}
		if (!removeNames.isEmpty()) { return new Message(getMinPoints(), "Nodes were removed/altered on the pages: "
		        + getNames(removeNames, model, modelPageNames)); }
		for (final String name : new ArrayList<String>(subsetNames)) {
			final int compare = compare(basePageNames.get(name), modelPageNames.get(name));
			if (compare >= 0) {
				subsetNames.remove(name);
			}
		}
		if (!subsetNames.isEmpty()) { return new Message(getMinPoints(), "Nodes were removed/altered on the pages: "
		        + getNames(subsetNames, model, modelPageNames)); }
		if (!exactNames.isEmpty()) { return new Message(partial,
		        "Nodes were added on the pages (that should not happen): "
		                + getNames(exactNames, model, modelPageNames)); }
		if (!addpages && basePageNames.size() < modelPageNames.size()) {
			final Set<String> addedPages = new HashSet<String>(modelPageNames.keySet());
			addedPages.removeAll(basePageNames.keySet());
			return new Message(partial, "Pages were added (that should not happen): "
			        + getNames(addedPages, model, modelPageNames));
		}

		return new Message(getMaxPoints(), "The interface has not been modified.");
	}

	private int compare(final Page page1, final Page page2) {
		final Set<String> nodes1 = getNodes(page1);
		final Set<String> nodes2 = getNodes(page2);
		final int count = nodes1.size();
		nodes1.removeAll(nodes2);
		if (!nodes1.isEmpty()) { return -1; }
		if (nodes2.size() == count) { return 0; }
		return 1;
	}

	private Set<String> getNodes(final Page page) {
		final Set<String> result = new HashSet<String>();
		for (final Object o : page.getObject()) {
			final StringBuilder sb = new StringBuilder();
			if (o instanceof Node) {
				final Node n = (Node) o;
				if (n instanceof PlaceNode) {
					final PlaceNode pn = (PlaceNode) n;
					if (pn instanceof Place) {
						final Place p = (Place) pn;
						sb.append("Place\n");
						if (initmark) {
							sb.append("Marking: " + getText(p.getInitialMarking()));
						}
					} else if (pn instanceof RefPlace) {
						final RefPlace rp = (RefPlace) pn;
						if (rp.isFusionGroup()) {
							sb.append("Fusion Place\n");
							sb.append("Group: " + getText(rp.getRef().getName()));
						} else if (rp.isPort()) {
							sb.append("Port Place\n");
						} else {
							assert false;
						}
					} else {
						assert false;
					}
					sb.append("Type: " + getText(pn.getSort()));
				} else if (n instanceof TransitionNode) {
					final TransitionNode tn = (TransitionNode) n;
					if (tn instanceof Transition) {
						final Transition t = (Transition) tn;
						sb.append("Transition\n");
						assert t != null; // No special properties, so ignore
					} else {
						assert false;
					}
					sb.append("Guard: " + getText(tn.getCondition()));
					sb.append("Code: " + getText(tn.getCode()));
					sb.append("Time: " + getText(tn.getTime()));
					sb.append("Priority: " + getText(tn.getPriority()));
				} else if (n instanceof org.cpntools.accesscpn.model.Instance) {
				}
				sb.append("Name: " + getText(n.getName()));
			}
			result.add(sb.toString());
		}
		for (final Arc a : page.getArc()) {
			final StringBuilder sb = new StringBuilder();
			sb.append("Source: " + getText(a.getSource().getName()));
			sb.append("Target: " + getText(a.getTarget().getName()));
			sb.append("Expression: " + getText(a.getHlinscription()));
			if (a.getKind() == HLArcType.TEST) {
				sb.append("Double Arc\n");
			}
			result.add(sb.toString());
		}
		return result;
	}

	private String getText(final Annotation node) {
		if (node == null) { return ""; }
		final String label = node.getText();
		if (label == null) { return ""; }
		return label.replaceAll("[ \t\n\r]", "") + "\n";
	}

	private Collection<String> getNames(final Set<String> names, final PetriNet model, final Map<String, Page> pages) {
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final Set<String> pagesNames = new TreeSet<String>();
		final List<Instance<Page>> pageInstances = new ArrayList<Instance<Page>>();
		for (final String name : names) {
			pageInstances.addAll(modelInstance.getAllInstances(pages.get(name)));
		}
		for (final Instance<Page> pi : pageInstances) {
			final String pageName = pi.toString();
			if (names.contains(cleanup(pageName))) {
				pagesNames.add(pageName);
			}
		}
		return pagesNames;
	}

	Pattern dotRemover = Pattern.compile("^[^.]*[.](.*)$");

	private Map<String, String> extractShortcuts(final PetriNet model) {
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final Map<String, String> result = new HashMap<String, String>();
		for (final Page p : new PageSorter(model.getPage())) {
			for (final Instance<Page> pi : modelInstance.getAllInstances(p)) {
				final String name = cleanup(pi.toString());
				Matcher m = dotRemover.matcher("ignore." + name);
				m.matches();
				do {
					final String token = m.group(1);
					result.put(token, name);
					m = dotRemover.matcher(token);
				} while (m.matches());
			}

		}
		return result;
	}

	private Map<String, Page> extractPageNames(final PetriNet model) {
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final Map<String, Page> names = new HashMap<String, Page>();
		for (final Page p : model.getPage()) {
			for (final Instance<Page> pi : modelInstance.getAllInstances(p)) {
				final String name = cleanup(pi.toString());
				names.put(name, p);
			}
		}
		return names;
	}

	private String cleanup(final String s) {
		final String name = s.toLowerCase().replaceAll("[^a-z0-9.]*", "");
		return name;
	}

}
