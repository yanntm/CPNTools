package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.PageSorter;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.model.Annotation;
import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.HLArcType;
import org.cpntools.accesscpn.model.HasId;
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
public class NameHelper {
	private final Map<String, Instance<Node>> nodeNames;
	private final Map<String, String> nodeShortcuts;

	public NameHelper(final PetriNet petriNet) {
		nodeNames = extractNodeNames(petriNet);
		nodeShortcuts = extractNodeShortcuts(petriNet);
	}

	public static List<String> cleanup(final List<String> strings) {
		final List<String> result = new ArrayList<String>(strings.size());
		for (final String string : strings) {
			final String token = cleanup(string);
			if (!token.isEmpty()) {
				result.add(token);
			}
		}
		return result;
	}

	public static String cleanup(final String s) {
		final String name = s.toLowerCase().replaceAll("[^a-z0-9.]*", "");
		return name;
	}

	public static Map<String, HasId> getNodes(final Page page, final boolean initmark) {
		final Map<String, HasId> result = new HashMap<String, HasId>();
		for (final org.cpntools.accesscpn.model.Object o : page.getObject()) {
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
			result.put(sb.toString(), o);
		}
		for (final Arc a : page.getArc()) {
			final StringBuilder sb = new StringBuilder();
			sb.append("Source: " + getText(a.getSource().getName()));
			sb.append("Target: " + getText(a.getTarget().getName()));
			sb.append("Expression: " + getText(a.getHlinscription()));
			if (a.getKind() == HLArcType.TEST) {
				sb.append("Double Arc\n");
			}
			result.put(sb.toString(), a);
		}
		return result;
	}

	public static String getText(final Annotation node) {
		if (node == null) { return ""; }
		final String label = node.getText();
		if (label == null) { return ""; }
		return label.replaceAll("[ \t\n\r]", "") + "\n";
	}

	private static Pattern dotRemover = Pattern.compile("^[^.]*[.](.*)$");

	public static Map<String, String> extractShortcuts(final PetriNet model) {
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

	public static Map<String, Page> extractPageNames(final PetriNet model) {
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

	public static Map<String, Instance<Node>> extractNodeNames(final PetriNet model) {
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final Map<String, Instance<Node>> names = new HashMap<String, Instance<Node>>();
		for (final Page p : model.getPage()) {
			for (final Object o : p.getObject()) {
				if (o instanceof Node) {
					final Node n = (Node) o;
					for (final Instance<Node> ni : modelInstance.getAllInstances(n)) {
						final String name = cleanup(ni.toString());
						names.put(name, ni);
					}
				}
			}
		}
		return names;
	}

	public static Map<String, String> extractNodeShortcuts(final PetriNet model) {
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final Map<String, String> result = new HashMap<String, String>();
		for (final Page p : new PageSorter(model.getPage())) {
			for (final Object o : p.getObject()) {
				if (o instanceof Node) {
					final Node n = (Node) o;
					for (final Instance<Node> ni : modelInstance.getAllInstances(n)) {
						final String name = cleanup(ni.toString());
						Matcher m = dotRemover.matcher("ignore." + name);
						m.matches();
						do {
							final String token = m.group(1);
							result.put(token, name);
							m = dotRemover.matcher(token);
						} while (m.matches());
					}
				}
			}
		}
		return result;
	}

	public static Collection<String> getNames(final Set<String> names, final PetriNet model,
	        final Map<String, Page> pages) {
		final Set<String> pageNames = new TreeSet<String>();
		for (final Instance<Page> pi : getPages(names, model, pages)) {
			pageNames.add(pi.toString());
		}
		return pageNames;
	}

	public static Collection<Instance<Page>> getPages(final Set<String> names, final PetriNet model,
	        final Map<String, Page> pages) {
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final Set<Instance<Page>> pageSet = new HashSet<Instance<Page>>();
		final List<Instance<Page>> pageInstances = new ArrayList<Instance<Page>>();
		for (final String name : names) {
			pageInstances.addAll(modelInstance.getAllInstances(pages.get(name)));
		}
		for (final Instance<Page> pi : pageInstances) {
			final String pageName = pi.toString();
			if (names.contains(NameHelper.cleanup(pageName))) {
				pageSet.add(pi);
			}
		}
		return pageSet;
	}

	/**
	 * @param name
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public Instance<PlaceNode> getPlaceInstance(final String name) {
		final String realName = nodeShortcuts.get(name);
		final Instance<Node> ni = nodeNames.get(realName);
		final PlaceNode p = (PlaceNode) ni.getNode();
		assert p != null;
		return (Instance) ni;
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	public Instance<Transition> getTransitionInstance(final String name) {
		final String realName = nodeShortcuts.get(name);
		final Instance<Node> ni = nodeNames.get(realName);
		final Transition p = (Transition) ni.getNode();
		assert p != null;
		return (Instance) ni;

	}

}
