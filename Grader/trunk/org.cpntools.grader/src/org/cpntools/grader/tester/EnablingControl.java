package org.cpntools.grader.tester;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.InstanceFactory;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.PetriNetDataAdapter;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.SimulatorModelAdapterFactory;
import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.HLAnnotation;
import org.cpntools.accesscpn.model.HLArcType;
import org.cpntools.accesscpn.model.HLDeclaration;
import org.cpntools.accesscpn.model.HLMarking;
import org.cpntools.accesscpn.model.ModelFactory;
import org.cpntools.accesscpn.model.Name;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.Place;
import org.cpntools.accesscpn.model.Sort;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.cpntypes.CPNUnit;
import org.cpntools.accesscpn.model.cpntypes.CpntypesFactory;
import org.cpntools.accesscpn.model.declaration.DeclarationFactory;
import org.cpntools.accesscpn.model.declaration.TypeDeclaration;
import org.eclipse.emf.common.notify.Notifier;

/**
 * @author michael
 */
public class EnablingControl extends PetriNetDataAdapter {
	private static final String ENABLING_CONTROL = "ENABLING_CONTROL";
	Map<Transition, Place> enablingPlaces = new HashMap<Transition, Place>();
	Set<Instance<Transition>> disabled = new HashSet<Instance<Transition>>();

	@Override
	public void setTarget(final Notifier target) {
		super.setTarget(target);
		if (petriNet != null && target == petriNet) {
			addTypeDeclaration();

			int id = 0;
			for (final Page p : petriNet.getPage()) {
				for (final Transition t : list(p.transition())) {
					final Place place = createPlace(id++, p);
					enablingPlaces.put(t, place);
					createArc(id++, p, t, place);
				}
			}
		}
	}

	public Collection<Instance<Place>> getPlaces(final Instance<Page> pi) {
		final Set<Instance<Place>> result = new HashSet<Instance<Place>>();
		for (final Transition t : pi.getNode().transition()) {
			result.add(InstanceFactory.INSTANCE.createInstance(enablingPlaces.get(t), pi.getTransitionPath()));
		}
		return result;
	}

	public Collection<Place> getPlaces(final Page p) {
		final Set<Place> result = new HashSet<Place>();
		for (final Transition t : p.transition()) {
			result.add(enablingPlaces.get(t));
		}
		return result;

	}

	private Collection<Transition> list(final Iterable<Transition> transition) {
		final ArrayList<Transition> result = new ArrayList<Transition>();
		for (final Transition t : transition) {
			result.add(t);
		}
		return result;
	}

	public void enable(final Instance<Transition> ti) {
		if (disabled.contains(ti)) {
			setMarking(ti, "()");
			disabled.remove(ti);
		}
	}

	public void disable(final Instance<Transition> ti) {
		if (!disabled.contains(ti)) {
			setMarking(ti, "");
			disabled.add(ti);
		}
	}

	public void setMarking(final Instance<Transition> ti, final String marking) {
		final Instance<Place> pi = getPlaceInstance(ti);
		if (pi == null) { return; }
		final HighLevelSimulator simulator = getSimulator(ti);
		try {
			simulator.setMarking(pi, InstanceFactory.INSTANCE.createMarking(marking));
		} catch (final IOException e) {
			// Ignore
		}
	}

	public HighLevelSimulator getSimulator(final Instance<Transition> ti) {
		final HighLevelSimulator simulator = (HighLevelSimulator) SimulatorModelAdapterFactory.getInstance().adapt(
		        ti.getNode().getPage().getPetriNet(), HighLevelSimulator.class);
		return simulator;
	}

	public Instance<Place> getPlaceInstance(final Instance<Transition> ti) {
		final Place p = enablingPlaces.get(ti.getNode());
		if (p == null) { return null; }
		if (ti.getTransitionPath() != null) {
			return InstanceFactory.INSTANCE.createInstance(p, ti.getInstanceNumber(), ti.getTransitionPath());
		} else {
			return InstanceFactory.INSTANCE.createInstance(p, ti.getInstanceNumber());
		}
	}

	public void createArc(final int id, final Page p, final Transition t, final Place place) {
		final Arc arc = ModelFactory.INSTANCE.createArc();
		arc.setId("enabling" + id);
		arc.setSource(t);
		arc.setTarget(place);
		arc.setKind(HLArcType.TEST);
		final HLAnnotation expr = ModelFactory.INSTANCE.createHLAnnotation();
		expr.setText("()");
		arc.setHlinscription(expr);
		arc.setPage(p);
	}

	public Place createPlace(final int id, final Page p) {
		final Name name = ModelFactory.INSTANCE.createName();
		final Sort type = ModelFactory.INSTANCE.createSort();
		final HLMarking initmark = ModelFactory.INSTANCE.createHLMarking();
		name.setText("Enabling Control " + id);
		type.setText(ENABLING_CONTROL);
		initmark.setText("()");
		final Place place = ModelFactory.INSTANCE.createPlace();
		place.setId("enabling" + id);
		place.setName(name);
		place.setSort(type);
		place.setInitialMarking(initmark);
		place.setPage(p);
		return place;
	}

	public void addTypeDeclaration() {
		final TypeDeclaration color = DeclarationFactory.INSTANCE.createTypeDeclaration();
		final CPNUnit bool = CpntypesFactory.INSTANCE.createCPNUnit();
		color.setSort(bool);
		color.setTypeName(ENABLING_CONTROL);
		final HLDeclaration decl = ModelFactory.INSTANCE.createHLDeclaration();
		decl.setStructure(color);
		decl.setId("enabling0");
		petriNet.getLabel().add(decl);
	}
}
