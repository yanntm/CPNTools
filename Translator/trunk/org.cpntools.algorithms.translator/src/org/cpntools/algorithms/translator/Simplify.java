package org.cpntools.algorithms.translator;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.HLAnnotation;
import org.cpntools.accesscpn.model.HLArcType;
import org.cpntools.accesscpn.model.Instance;
import org.cpntools.accesscpn.model.ModelFactory;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.ParameterAssignment;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Place;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.accesscpn.model.RefPlace;
import org.cpntools.accesscpn.model.Transition;

/**
 * @author michael
 */
public class Simplify {
	static int id = 0;

	public static PetriNet simplify(final PetriNet petriNet) {
		for (final Page p : petriNet.getPage()) {
			simplify(p);
		}
		return petriNet;
	}

	private static void simplify(final Page p) {
		final Set<String> sockets = new HashSet<String>();
		for (final Instance i : p.instance()) {
			for (final ParameterAssignment pa : i.getParameterAssignment()) {
				sockets.add(pa.getParameter());
			}
		}

		removeNoopTransitions(p, sockets);

		removeUnconnectedPlaces(p, sockets);
	}

	private static void removeNoopTransitions(final Page p, final Set<String> sockets) {
		boolean changed = false;
		do {
			changed = false;
			for (final org.cpntools.accesscpn.model.Object object : new ArrayList<org.cpntools.accesscpn.model.Object>(
			        p.getObject())) {
				if (object instanceof Transition) {
					final Transition transition = (Transition) object;
					if (transition.getCondition() == null || transition.getCondition().getText().equals("")) {
						changed = removeForwardTransitions(changed, sockets, transition);
						changed = mergeReleaseMutex(p, changed, sockets, transition);
					}
				}
			}
		} while (changed);
	}

	private static boolean mergeReleaseMutex(final Page p, boolean changed, final Set<String> sockets,
	        final Transition transition) {
		if (transition.getSourceArc().size() == 2 && transition.getTargetArc().size() == 1) {
			Arc sourceArc1 = transition.getSourceArc().get(0);
			Arc sourceArc2 = transition.getSourceArc().get(1);
			final Arc targetArc = transition.getTargetArc().get(0);
			PlaceNode targetPlace1 = sourceArc1.getPlaceNode();
			PlaceNode targetPlace2 = sourceArc2.getPlaceNode();
			final PlaceNode sourcePlace = targetArc.getPlaceNode();

			if (targetPlace2.getSort().getText().equals("MUTEX")) {
				final Arc tmpArc = sourceArc2;
				final PlaceNode tmpPlace = targetPlace2;
				sourceArc2 = sourceArc1;
				targetPlace2 = targetPlace1;
				sourceArc1 = tmpArc;
				targetPlace1 = tmpPlace;
			}

			if (targetPlace1.getSort().getText().equals("MUTEX")) {
				if (sourcePlace.getSourceArc().size() == 1 && "".equals(targetPlace2.getInitialMarking().getText())
				        && !sockets.contains(sourcePlace.getId()) && !(sourcePlace instanceof RefPlace)) {
					if (sourceArc2.getHlinscription().getText().equals(targetArc.getHlinscription().getText())) {
						changed = true;
						sourceArc1.setSource(null);
						sourceArc1.setTarget(null);
						sourceArc1.setPage(null);
						sourceArc2.setSource(null);
						sourceArc2.setTarget(null);
						sourceArc2.setPage(null);
						targetArc.setSource(null);
						targetArc.setTarget(null);
						targetArc.setPage(null);
						transition.setPage(null);
						for (final Arc arc : new ArrayList<Arc>(sourcePlace.getSourceArc())) {
							arc.setSource(targetPlace2);
						}
						for (final Arc arc : new ArrayList<Arc>(sourcePlace.getTargetArc())) {
							arc.setTarget(targetPlace2);
						}
						for (final Arc arc : targetPlace2.getTargetArc()) {
							final Arc newArc = ModelFactory.INSTANCE.createArc();
							newArc.setKind(HLArcType.NORMAL);
							newArc.setId("sid" + id++);
							newArc.setPage(p);
							final HLAnnotation annotation = ModelFactory.INSTANCE.createHLAnnotation();
							annotation.setText(sourceArc1.getHlinscription().getText());
							newArc.setHlinscription(annotation);
							newArc.setSource(arc.getSource());
							newArc.setTarget(targetPlace1);
						}
					}
				}
			}
		}
		return changed;
	}

	private static boolean removeForwardTransitions(boolean changed, final Set<String> sockets,
	        final Transition transition) {
		if (transition.getSourceArc().size() == 1 && transition.getTargetArc().size() == 1) {
			final Arc sourceArc = transition.getSourceArc().get(0);
			final Arc targetArc = transition.getTargetArc().get(0);
			final PlaceNode targetPlace = sourceArc.getPlaceNode();
			final PlaceNode sourcePlace = targetArc.getPlaceNode();
// System.out.println(sourcePlace.getName().getText() + " -> "
// + transition.getName().getText() + " -> " + targetPlace.getName().getText());
			if (sourcePlace.getSourceArc().size() == 1 && !sockets.contains(sourcePlace.getId())
			        && !sockets.contains(targetPlace.getId()) && !(targetPlace instanceof RefPlace)
			        && "".equals(targetPlace.getInitialMarking().getText())) {
				if (sourceArc.getHlinscription().getText().equals(targetArc.getHlinscription().getText())) {
					changed = true;
					sourceArc.setSource(null);
					sourceArc.setTarget(null);
					sourceArc.setPage(null);
					targetArc.setSource(null);
					targetArc.setTarget(null);
					targetArc.setPage(null);
					transition.setPage(null);
					for (final Arc arc : new ArrayList<Arc>(targetPlace.getSourceArc())) {
						arc.setSource(sourcePlace);
					}
					for (final Arc arc : new ArrayList<Arc>(targetPlace.getTargetArc())) {
						arc.setTarget(sourcePlace);
					}
				}
			}
		}
		return changed;
	}

	private static void removeUnconnectedPlaces(final Page p, final Set<String> sockets) {
		for (final org.cpntools.accesscpn.model.Object object : new ArrayList<org.cpntools.accesscpn.model.Object>(
		        p.getObject())) {
			if (object instanceof Place) {
				final Place place = (Place) object;
				if (place.getSourceArc().isEmpty() && place.getTargetArc().isEmpty()
				        && !sockets.contains(place.getId())) {
					place.setPage(null);
				}
			}
		}
	}

}
