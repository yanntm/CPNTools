package org.cpntools.accesscpn.cosimulation.impl;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Observable;
import java.util.Observer;

import org.cpntools.accesscpn.cosimulation.CPNSimulation;
import org.cpntools.accesscpn.cosimulation.CPNToolsPlugin;
import org.cpntools.accesscpn.cosimulation.ChannelDescription;
import org.cpntools.accesscpn.cosimulation.DataStore;
import org.cpntools.accesscpn.cosimulation.ExecutionContext;
import org.cpntools.accesscpn.cosimulation.InputChannel;
import org.cpntools.accesscpn.cosimulation.ObservableInputChannel;
import org.cpntools.accesscpn.cosimulation.OutputChannel;
import org.cpntools.accesscpn.cosimulation.SubpagePlugin;
import org.cpntools.accesscpn.cosimulation.TransitionPlugin;
import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Binding;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.InstanceFactory;
import org.cpntools.accesscpn.engine.highlevel.instance.Marking;
import org.cpntools.accesscpn.engine.highlevel.instance.ValueAssignment;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.engine.highlevel.instance.cpnvalues.CPNValue;
import org.cpntools.accesscpn.model.Node;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.cpntypes.CPNType;

public class CPNToolsSimulation extends Thread implements CPNSimulation, Observer {

	private final CPNToolsCosimulation cosimulation;
	private boolean done;
	private final HighLevelSimulator simulator;
	private boolean dirty = true;
	private final List<Instance<PlaceNode>> outgoingplaces;
	private final Map<ObservableInputChannel, Instance<PlaceNode>> incomingplaces;

	public CPNToolsSimulation(final CPNToolsCosimulation cosimulation) {
		this.cosimulation = cosimulation;
		simulator = cosimulation.getSimulator();
		done = false;

		outgoingplaces = new ArrayList<Instance<PlaceNode>>();
		for (final Entry<Instance<PlaceNode>, OutputChannel> entry : cosimulation.outputs()) {
			outgoingplaces.add(entry.getKey());
		}
		incomingplaces = new HashMap<ObservableInputChannel, Instance<PlaceNode>>();
		for (final Entry<Instance<PlaceNode>, InputChannel> entry : cosimulation.inputs()) {
			ObservableInputChannel oin;
			if (entry.getValue() instanceof ObservableInputChannel) {
				oin = (ObservableInputChannel) entry.getValue();
			} else {
				oin = new ObservableInputChannel(entry.getValue());
			}
			incomingplaces.put(oin, entry.getKey());
			oin.addObserver(this);
		}
	}

	@Override
	public synchronized void done() {
		done = true;
		notifyAll();
	}

	@Override
	public Collection<ChannelDescription<DataStore>> getData() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Collection<ChannelDescription<InputChannel>> getInputs() {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Collection<ChannelDescription<OutputChannel>> getOutputs() {
		// TODO Auto-generated method stub
		return null;
	}

	public boolean isDirty() {
		if (!dirty) {
			for (final SubpagePlugin plugin : cosimulation.subpagePlugins()) {
				if (!plugin.isDone()) return true;
			}
			return false;
		}
		return true;
	}

	public boolean isDone() {
		return done && !isDirty();
	}

	@Override
	public synchronized void setup() throws Exception {
		final ExecutionContext context = new ExecutionContext();
		for (final CPNToolsPlugin plugin : cosimulation.plugins()) {
			plugin.start(context);
		}
		for (final SubpagePlugin plugin : cosimulation.subpagePlugins()) {
			plugin.run();
		}
	}

	@Override
	public synchronized boolean step() throws Exception {
		do {
			if (dirty) {
				dirty = false;
				final boolean result = step(cosimulation.getAllTransitionInstances());
				if (result) return true;
			}
			try {
				wait();
			} catch (final InterruptedException _) {
				// Don't terminate on interrupt
			}
		} while (isDirty());
		return false;
	}

	@Override
	public boolean step(final Binding b) throws Exception {
		return step(b, false);
	}

	@Override
	public boolean step(final Instance<Transition> t) throws Exception {
		return step(Collections.singletonList(t));
	}

	@Override
	public synchronized void teardown() {
		for (final CPNToolsPlugin plugin : cosimulation.plugins()) {
			plugin.end();
		}
	}

	@Override
	public void update(final Observable arg0, final Object arg1) {
		if (arg0 instanceof ObservableInputChannel) {
			final ObservableInputChannel oin = (ObservableInputChannel) arg0;
			final Instance<PlaceNode> pi = incomingplaces.get(oin);
			if (pi != null) {
				final Collection<CPNValue> offers = oin.getOffers();
				if (!offers.isEmpty()) {
					final StringBuilder sb = new StringBuilder();
					String marking;
					synchronized (this) {
						try {
							marking = simulator.getMarking(pi);
							sb.append("(" + marking + ")");
							addTokens(pi, sb, offers);
							simulator.setMarking(pi, sb.toString());
							dirty = true;
							notifyAll();
						} catch (final Exception e) {
							// Mask
						}
					}
				}
			}
		}
	}

	protected Map<String, CPNValue> computeValueMap(final Binding binding) {
		final Map<String, CPNValue> result = new HashMap<String, CPNValue>();
		for (final ValueAssignment assignment : binding.getAllAssignments()) {
			final String name = assignment.getName();
			final CPNType variableType = cosimulation.getModelData().getVariableType(name);
			final List<CPNValue> value = simulator.evaluate(variableType, cosimulation
					.getModelData().getVariableTypeName(name), assignment.getValue());
			assert value.size() == 1;
			result.put(name, value.get(0));
		}
		return result;
	}

	protected synchronized boolean step(final Binding binding, final boolean executed)
			throws Exception {
		if (done) return false;
		if (!executed) {
			if (!cosimulation.getSimulator().execute(binding)) return false;
		}
		final TransitionPlugin transition = cosimulation.getTransitionPlugin(binding
				.getTransitionInstance());
		if (transition == null) return true;
		Number time;
		final String stringTime = simulator.getTime();
		try {
			time = new BigInteger(stringTime);
		} catch (final NumberFormatException _) {
			time = new Double(stringTime);
		}
		final Map<String, CPNValue> valueMap = computeValueMap(binding);
		if (transition.isEnabled(binding, time, valueMap)) {
			final Map<String, CPNValue> executeMap = transition.execute(binding, time, valueMap);
			if (executeMap != null && !executeMap.isEmpty()) {
				final Binding newBinding = computeBinding(binding, executeMap);
				simulator.rebind(binding, newBinding);
				transmitOutputs();
				dirty = true;
				notifyAll();
				return true;
			}
		} else {
			simulator.rollBack(binding);
		}
		return false;
	}

	protected synchronized boolean step(final Collection<Instance<Transition>> transitionInstances)
			throws Exception {
		if (done) return false;
		final List<Instance<Transition>> tis = new ArrayList<Instance<Transition>>(
				transitionInstances);
		Collections.shuffle(tis);
		for (final Instance<Transition> ti : tis) {
			if (simulator.isEnabled(ti)) {
				final List<Binding> bindings = simulator.getBindings(ti);
				Collections.shuffle(bindings);
				for (final Binding b : bindings) {
					if (step(b)) return true;
				}
			}
		}
		return false;
	}

	private void addTokens(final Instance<PlaceNode> placeInstance, final StringBuilder sb,
			final Collection<CPNValue> tokens) {
		final boolean timed = cosimulation.getModelData().isTimed(placeInstance);
		for (final CPNValue offer : tokens) {
			if (timed) {
				sb.append(" +++ ");
			} else {
				sb.append(" ++ ");
			}
			sb.append("1`");
			sb.append("(");
			sb.append(offer);
			sb.append(")");
		}
	}

	private Binding computeBinding(final Binding binding, final Map<String, CPNValue> executeMap) {
		final List<ValueAssignment> values = new ArrayList<ValueAssignment>();
		for (final ValueAssignment va : binding.getAllAssignments()) {
			final CPNValue o = executeMap.get(va.getName());
			if (o == null) {
				values.add(InstanceFactory.INSTANCE.createValueAssignment(va.getName(),
						va.getValue()));
			} else {
				values.add(InstanceFactory.INSTANCE.createValueAssignment(va.getName(),
						o.toString()));
			}
		}
		return InstanceFactory.INSTANCE.createBinding(binding.getTransitionInstance(), values);
	}

	// FIXME This updates all places, yet we know that only slaves of a transition have actually
	// changed
	private synchronized void transmitOutputs() throws Exception {
		final List<Instance<PlaceNode>> places = new ArrayList<Instance<PlaceNode>>();
		for (final Entry<Instance<PlaceNode>, OutputChannel> entry : cosimulation.outputs()) {
			final Node n = entry.getKey().getNode();
			places.add(entry.getKey());
			final ModelInstance modeInstance = (ModelInstance) ModelInstanceAdapterFactory
					.getInstance().adapt(n.getPage().getPetriNet(), ModelInstance.class);
			final Instance<Page> parentInstance = modeInstance
					.getParentInstance((Instance<?>) entry);
			final Map<Instance<Page>, Integer> instanceNumbers = modeInstance.getInstanceNumbers();
			instanceNumbers.get(parentInstance);
		}
		final org.cpntools.accesscpn.engine.highlevel.instance.State state = simulator
				.getMarking(outgoingplaces);
		for (final Entry<Instance<PlaceNode>, OutputChannel> entry : cosimulation.outputs()) {
			final Marking marking = state.getMarking(entry.getKey());
			if (marking.getTokenCount() > 0) {
				dirty = true;
				simulator.setMarking(entry.getKey(), "empty");
				entry.getValue().offer(simulator.getStructuredMarking(marking));
			}
		}
	}
}
