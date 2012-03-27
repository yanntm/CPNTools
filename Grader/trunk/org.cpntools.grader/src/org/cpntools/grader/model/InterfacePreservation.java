package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.HasId;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.PetriNet;

/**
 * @author michael
 */
public class InterfacePreservation extends AbstractGrader {
	public static final Grader INSTANCE = new InterfacePreservation(0, 0, true, false,
	        Collections.<String> emptyList(), Collections.<String> emptyList());

	Pattern p = Pattern
	        .compile(
	                "^interface-preservation(, *partial=(-?[0-9.]+))?(, *addpages(=(true|false))?)?(, *initmark(=(true|false))?)?(, *subset=([a-z0-9. _']+(; *[a-z0-9. _']+)*))?(, *ignore=([a-z0-9. _']+(; *[a-z0-9. _']+)*))?$",
	                Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

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
		this.subset = NameHelper.cleanup(subset);
		this.exclude = NameHelper.cleanup(exclude);
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
		final Map<String, Page> basePageNames = NameHelper.extractPageNames(base);
		final Map<String, String> baseShortcuts = NameHelper.extractShortcuts(base);
		final Map<String, Page> modelPageNames = NameHelper.extractPageNames(model);
		for (final String name : exclude) {
			final String shortcut = baseShortcuts.get(name);
			basePageNames.remove(shortcut);
			modelPageNames.remove(shortcut);
		}
		final Set<String> baseNames = new HashSet<String>(basePageNames.keySet());
		baseNames.removeAll(modelPageNames.keySet());
		if (!baseNames.isEmpty()) { return new Message(getMinPoints(), "Pages were deleted from the interface",
		        new Detail("Deleted pages", NameHelper.getNames(baseNames, base, basePageNames))); }

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
			final Map<String, HasId> compare = compare(basePageNames.get(name), modelPageNames.get(name));
			if (compare == null) {
				removeNames.add(name);
			} else if (compare.size() == 0) {
				exactNames.remove(name);
			}
		}
		if (!removeNames.isEmpty()) { return new Message(getMinPoints(), "Nodes were removed/altered on the pages: "
		        + NameHelper.getNames(removeNames, model, modelPageNames)); }
		for (final String name : new ArrayList<String>(subsetNames)) {
			final Map<String, HasId> compare = compare(basePageNames.get(name), modelPageNames.get(name));
			if (compare != null) {
				subsetNames.remove(name);
			}
		}
		Message m = null;
		if (!subsetNames.isEmpty()) {
			if (m == null) {
				m = new Message(getMinPoints(), "Nodes were removed/altered");
			}
			for (final Instance<Page> pi : NameHelper.getPages(subsetNames, model, modelPageNames)) {
				m.addDetail(new Detail("Nodes were removed/altered on " + pi, new PageComponent(pi)));
			}
		}
		if (!exactNames.isEmpty()) {
			if (m == null) {
				m = new Message(partial, "Nodes were added on interface pages (that should not happen)");
			}
			for (final Instance<Page> pi : NameHelper.getPages(exactNames, model, modelPageNames)) {
				m.addDetail(new Detail("Nodes were added on interface page " + pi, new PageComponent(pi)));
			}
		}
		if (!addpages && basePageNames.size() < modelPageNames.size()) {
			final Set<String> addedPages = new HashSet<String>(modelPageNames.keySet());
			addedPages.removeAll(basePageNames.keySet());
			if (m == null) {
				m = new Message(partial, "Pages were added (that should not happen)");
			}
			for (final Instance<Page> pi : NameHelper.getPages(addedPages, model, modelPageNames)) {
				m.addDetail(new Detail("Page " + pi + " added", new PageComponent(pi)));
			}
		}

		if (m == null) {
			m = new Message(getMaxPoints(), "The interface has not been modified incorrectly.");
			for (final String s : subset) {
				final String shortcut = baseShortcuts.get(s);
				final Page modelPage = modelPageNames.get(shortcut);
				final Map<String, HasId> compare = compare(basePageNames.get(shortcut), modelPage);
				if (compare != null && compare.size() > 0) {
					m.addDetail(new Detail("Page " + modelPage.getName().getText() + " legally modified",
					        new PageComponent(modelPage, compare.values())));
				}
			}
		}
		return m;
	}

	private Iterable<String> createImage(final Instance<Page> pi) {
		// TODO Auto-generated method stub
		return null;
	}

	private Map<String, HasId> compare(final Page page1, final Page page2) {
		final Map<String, HasId> nodes1 = NameHelper.getNodes(page1, initmark);
		final Map<String, HasId> nodes2 = NameHelper.getNodes(page2, initmark);
		final Set<String> keys = new HashSet<String>(nodes1.keySet());
		for (final String key : nodes2.keySet()) {
			nodes1.remove(key);
		}
		if (!nodes1.isEmpty()) { return null; }
		for (final String key : keys) {
			nodes2.remove(key);
		}
		return nodes2;
	}

}
