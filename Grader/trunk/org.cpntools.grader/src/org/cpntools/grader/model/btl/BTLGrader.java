package org.cpntools.grader.model.btl;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Binding;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.InstanceFactory;
import org.cpntools.accesscpn.engine.highlevel.instance.State;
import org.cpntools.accesscpn.engine.highlevel.instance.ValueAssignment;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.model.AbstractGrader;
import org.cpntools.grader.model.Detail;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.btl.model.Condition;
import org.cpntools.grader.model.btl.model.Failure;
import org.cpntools.grader.model.btl.model.Guide;
import org.cpntools.grader.model.btl.model.True;
import org.cpntools.grader.model.btl.parser.CupParser;
import org.cpntools.grader.tester.EnablingControl;
import org.cpntools.grader.tester.EnablingControlAdapterFactory;

public class BTLGrader extends AbstractGrader {
	public static final Grader INSTANCE = new BTLGrader(0, false, 0, 0, 0, "", "<null>", True.INSTANCE);

	@SuppressWarnings("unchecked")
	public static List<Instance<Transition>> getEnabled(final HighLevelSimulator simulator,
	        final List<Instance<Transition>> allTransitionInstances, final EnablingControl ec) throws IOException {
		for (final Instance<Transition> ti : allTransitionInstances) {
			ec.enable(ti);
		}
		simulator.initialiseSimulationScheduler();
		final List<Instance<? extends Transition>> enabled = simulator.isEnabled(allTransitionInstances);
		return (List) enabled;
	}

	@SuppressWarnings({ "unchecked", "rawtypes", "javadoc" })
	public static List<Instance<Transition>> getEnabledAndAllowed(final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names,
	        final List<Instance<Transition>> allTransitionInstances, final EnablingControl ec,
	        final Condition toSatisfy, final Set<Instance<Transition>> allowed) throws IOException {
		if (toSatisfy != null) {
			toSatisfy.prestep(model, simulator, names, EmptyEnvironment.INSTANCE);
		}
		List<Instance<Transition>> enabled = BTLGrader.getEnabled(simulator, allTransitionInstances, ec);
// System.out.println(enabled);
		while (enabled.isEmpty() && simulator.increaseTime() == null) {
// System.out.println("Increasing time");
			enabled = (List) simulator.isEnabled(allTransitionInstances);
// System.out.println(enabled);
		}
// System.out.println("Formula: " + toSatisfy);
		allowed.addAll(toSatisfy.force(new HashSet(enabled), model, simulator, names, EmptyEnvironment.INSTANCE));
		boolean changed = true;
		while (allowed.isEmpty() && changed) {
			changed = false;
			final Set<Instance<Transition>> oldEnabled = new HashSet<Instance<Transition>>();
			oldEnabled.addAll(enabled);
			for (final Instance<Transition> ti : allTransitionInstances) {
				if (enabled.contains(ti)) {
					ec.disable(ti);
				} else {
					ec.enable(ti);
				}
			}
			for (final Instance<? extends Transition> ti : enabled) { // It seems the hash function is not correct for
// instances
				ec.disable((Instance<Transition>) ti);
			}
			simulator.initialiseSimulationScheduler();
			enabled = (List) simulator.isEnabled(allTransitionInstances);
// System.out.println("Updating " + enabled);
			while (enabled.isEmpty() && simulator.increaseTime() == null) {
				changed = true;
				enabled = (List) simulator.isEnabled(allTransitionInstances);
// System.out.println("Updating & Increasing " + enabled);
			}
			allowed.clear();
			allowed.addAll(toSatisfy.force(new HashSet(enabled), model, simulator, names, EmptyEnvironment.INSTANCE));
// System.out.println("Old " + oldEnabled);

			oldEnabled.addAll(enabled);
			enabled.clear();
			enabled.addAll(oldEnabled);
// System.out.println("Old and enabled " + enabled);
		}
// System.out.println("Returning " + enabled);
		return enabled;
	}

	private final boolean anti;
	private final Guide guide;

	private final int maxSteps;

	private final String name;

	private final int repeats;

	private final int threshold;

	private final String unparsed;

	Pattern p = Pattern
	        .compile(
	                "^btl(, *anti)?(, *repeats? *= *([1-9][0-9]*))?(, *max-?steps? *= *([1-9][0-9]*))?(, *threshold *= *([1-9][0-9]*))?(, *name *= *\"([^\"]*)\")?, *test *=(.*)$",
	                Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

	public BTLGrader(final double maxPoints, final boolean anti, final int repeats, final int maxSteps,
	        final int threshold, final String friendlyName, final String unparsed, final Guide guide) {
		super(maxPoints);
		this.anti = anti;
		this.repeats = repeats;
		this.maxSteps = maxSteps;
		this.threshold = threshold;
		name = friendlyName;
		this.unparsed = unparsed;
		this.guide = guide;
	}

	@SuppressWarnings("hiding")
	@Override
	public Grader configure(final double maxPoints, final String configuration) throws Exception {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			boolean anti = false;
			int repeats = 1;
			int maxSteps = 10000;
			if (m.group(1) != null) {
				anti = true;
			}
			if (m.group(3) != null && !"".equals(m.group(3))) {
				repeats = Integer.parseInt(m.group(3));
			}
			if (m.group(5) != null && !"".equals(m.group(5))) {
				maxSteps = Integer.parseInt(m.group(5));
			}
			int threshold = repeats;//(anti) ? 0 : repeats; // if an anti-test, then it has to fail every time
			if (m.group(7) != null && !"".equals(m.group(7))) {
				threshold = Integer.parseInt(m.group(7));
			}
			final String unparsed = m.group(10) == null ? "<null>" : m.group(10).trim();
			String name = unparsed;
			if (m.group(9) != null && !"".equals(m.group(9))) {
				name = m.group(9).trim();
			}
			final Guide guide = CupParser.parse(unparsed);
			if (guide != null) { return new BTLGrader(maxPoints, anti, repeats, maxSteps, threshold, name,
			        unparsed.trim(), guide); }
		}
		return null;
	}

	public Guide getGuide() {
		return guide;
	}

	public String getName() {
		return name;
	}

	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		final List<Detail> details = new ArrayList<Detail>();
		final NameHelper names = new NameHelper(model);
		final ModelInstance modelInstance = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(model,
		        ModelInstance.class);
		final List<Instance<Transition>> allTransitionInstances = modelInstance.getModelData()
		        .getAllTransitionInstances();
		int error = 0;
		final Set<State> markings = new HashSet<State>();
		final EnablingControl ec = (EnablingControl) EnablingControlAdapterFactory.getInstance().adapt(model,
		        EnablingControl.class);
		final DecisionTree<Instance<Transition>> decisionTree = new DecisionTree<Instance<Transition>>();
		final Strategy<Instance<Transition>> strategy = new RandomStrategy<Instance<Transition>>();
		for (int i = 0; i < repeats; i++) {
			final Detail d = grade(model, simulator, names, allTransitionInstances, ec, decisionTree, strategy);
			if (d != null) {
				error++;
				details.add(d);
			} else {
				try {
					for (final Instance<Transition> ti : allTransitionInstances) {
						ec.disable(ti);
					}
					markings.add(simulator.getMarking());
				} catch (final Exception e) {
				}
			}
		}
		Message m;
		if (anti) {
			if (error == 0) {
				m = new Message(getMinPoints(), getName() + " was executed successfully " + repeats + " time"
				        + (repeats == 1 ? "" : "s") + " (it was expected to fail!)");
			} else if (repeats - error >= threshold) {
				m = new Message(getMinPoints(), getName() + " failed " + error + " time" + (error == 1 ? "" : "s")
				        + " (it was expected to fail "+threshold+" times)");
			} else if (repeats > error) {
				m = new Message(getMaxPoints(), getName() + " failed " + error + " time"
				        + (error == 1 ? "" : "s")+" (it was allowed to fail "+threshold+" times)");
			} else {
				m = new Message(getMaxPoints(), getName() + " failed every time. This is expected behavior.");
			}
		} else {
			if (error == 0) {
				m = new Message(getMaxPoints(), getName() + " was executed successfully " + repeats + " time"
				        + (repeats == 1 ? "" : "s"));
			} else if (repeats - error >= threshold) {
				m = new Message(getMaxPoints(), getName() + " failed " + error + " time" + (error == 1 ? "" : "s")
				        + ", but this is below the threshold of "+threshold+" allowed failures");
			} else if (repeats > error) {
				m = new Message(getMinPoints(), getName() + " failed " + error + " time" + (error == 1 ? "" : "s"));
			} else {
				m = new Message(getMinPoints(), getName() + " failed every time.");
			}
		}
		
		if (!anti) {
			if (!markings.isEmpty()) {
				final String[] markingDescriptors = new String[markings.size()];
				int i = 0;
				for (final State s : markings) {
					markingDescriptors[i++] = s.toString();
				}
				//m.addDetail(new Detail("Final Markings for " + getName(), markingDescriptors));
			}
			for (final Detail d : details) {
				m.addDetail(d);
			}
		}
		//m.addDetail(new Detail("Coverage", decisionTree.toString()));
		return m;
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	private Detail grade(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final List<Instance<Transition>> allTransitionInstances, final EnablingControl ec,
	        final DecisionTree<Instance<Transition>> decisionTree, final Strategy<Instance<Transition>> strategy) {
		try {
			simulator.initialiseSimulationScheduler();
			simulator.initialState();
			Condition toSatisfy = getGuide();
			final List<Binding> trace_bindings = new ArrayList<Binding>();
			final List<String> trace_timeStamps = new ArrayList<String>(); // keep in sync with bindings
			
			Node<Instance<Transition>> node = decisionTree.getRoot();
			for (int i = 0; maxSteps < 0 || i < maxSteps; i++) {
				final Set<Instance<Transition>> allowed = new HashSet<Instance<Transition>>();
				final List<Instance<Transition>> enabled = BTLGrader.getEnabledAndAllowed(model, simulator, names,
				        allTransitionInstances, ec, toSatisfy, allowed);
// System.out.println(enabled);
				if (allowed.isEmpty()) {
					if (toSatisfy.canTerminate(model, simulator, names, EmptyEnvironment.INSTANCE)) {
						node.validate();
						return null;
					}
					node.invalidate();
					return new Detail("No Allowed Transtions for " + getName(), "Enabled Transitions:\n"
					        + toString(enabled), "Executed Trace:\n" + toString(trace_timeStamps, trace_bindings), "Initial Formula:\n"
					        + unparsed, "Parsed Formula:\n" + getGuide(), "Formula at error:\n" + toSatisfy,
					        "Marking at error:\n" + simulator.getMarking(false));
				}
				for (final Instance<Transition> ti : allowed) {
					decisionTree.addChild(node, ti);
				}
				
				Instance<Transition> ti = strategy.getOne(decisionTree, node, new ArrayList(allowed));
				Binding binding = simulator.executeAndGet(ti);
				if (binding == null) {
					// trying to bind a transition where the binding is defined by a random function
					// in this case, the simulator cannot manually set the binding defined externally
					// but has to compute one autonomously for this transition, in this case no binding
					// will be known
					simulator.execute(ti);
					final List<ValueAssignment> valueAssignments = new ArrayList<ValueAssignment>();
					binding = InstanceFactory.INSTANCE.createBinding(ti, valueAssignments);
				}
				String time = simulator.getTime();
				
				node = decisionTree.addChild(node, binding.getTransitionInstance());
				
				trace_bindings.add(binding); // extend trace
				trace_timeStamps.add(time);
				
				toSatisfy = toSatisfy.progress(binding.getTransitionInstance(), model, simulator, names,
				        EmptyEnvironment.INSTANCE);
				if (toSatisfy == Failure.INSTANCE) {
					node.invalidate();
					return new Detail("Assertion Failed", "Enabled Transitions:\n" + toString(enabled),
					        "Executed Trace:\n" + toString(trace_timeStamps, trace_bindings), "Initial Formula:\n" + unparsed,
					        "Parsed Formula:\n" + getGuide(), "Formula at error:\n" + toSatisfy, "Marking at error:\n"
					                + simulator.getMarking(false));
				}
				if (toSatisfy == null) {
					node.validate();
					return null; // Nothing left to satisfy
				}
			}
			return new Detail("Simulation Not Terminating", "The simulation was running for " + maxSteps
			        + " steps and was expected to terminate before", "Initial Formula:\n" + unparsed,
			        "Parsed Formula:\n" + getGuide(), "Formula at error:\n" + toSatisfy, "Marking at error:\n"
			                + simulator.getMarking(false));
		} catch (final Exception e) {
			e.printStackTrace();
			return new Detail("Running " + getName() + " failed", e.toString());
		}
	}

	private String toString(final Collection<?> stuff) {
		final StringBuilder sb = new StringBuilder();
		boolean first = true;
		for (final Object o : stuff) {
			if (first) {
				first = false;
			} else {
				sb.append('\n');
			}
			sb.append(o);
		}
		return sb.toString();
	}
	
	private String toString(final List<String> times, final List<Binding> bindings) {
		final StringBuilder sb = new StringBuilder();
		for (int i=0; i<times.size(); i++) {
			if (i > 0) sb.append('\n');
			sb.append(times.get(i)+" "+bindings.get(i));
		}
 		return sb.toString();
	}

}
