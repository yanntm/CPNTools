package org.cpntools.grader.model.btl;

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
import org.cpntools.grader.model.btl.model.Guide;
import org.cpntools.grader.model.btl.model.True;
import org.cpntools.grader.model.btl.parser.CupParser;

public class BTLGrader extends AbstractGrader {
	public static final Grader INSTANCE = new BTLGrader(0, 0, 0, 0, "", "<null>", new True());

	private final Guide guide;
	private final int repeats;
	private final int maxSteps;
	private final int threshold;

	private final String unparsed;

	private final String name;

	public BTLGrader(final double maxPoints, final int repeats, final int maxSteps, final int threshold,
	        final String friendlyName, final String unparsed, final Guide guide) {
		super(maxPoints);
		this.repeats = repeats;
		this.maxSteps = maxSteps;
		this.threshold = threshold;
		name = friendlyName;
		this.unparsed = unparsed;
		this.guide = guide;
	}

	Pattern p = Pattern
	        .compile(
	                "^btl(, *repeats? *= *([1-9][0-9]*))?(, *max-?steps? *= *([1-9][0-9]*))?(, *threshold *= *([1-9][0-9]*))?(, *name *= *\"([^\"]*)\")?, *test *=(.*)$",
	                Pattern.CASE_INSENSITIVE | Pattern.DOTALL);

	@SuppressWarnings("hiding")
	@Override
	public Grader configure(final double maxPoints, final String configuration) {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			int repeats = 1;
			int maxSteps = 10000;
			if (m.group(2) != null && !"".equals(m.group(2))) {
				repeats = Integer.parseInt(m.group(2));
			}
			if (m.group(4) != null && !"".equals(m.group(4))) {
				maxSteps = Integer.parseInt(m.group(4));
			}
			int threshold = repeats;
			if (m.group(6) != null && !"".equals(m.group(6))) {
				threshold = Integer.parseInt(m.group(6));
			}
			final String unparsed = m.group(9) == null ? "<null>" : m.group(9).trim();
			String name = unparsed;
			if (m.group(8) != null && !"".equals(m.group(8))) {
				name = m.group(8).trim();
			}
			try {
				final Guide guide = CupParser.parse(unparsed);
				if (guide != null) { return new BTLGrader(maxPoints, repeats, maxSteps, threshold, name,
				        unparsed.trim(), guide); }
			} catch (final Exception e) {
				System.err.println("Could not parse guide: " + unparsed);
				e.printStackTrace();
			}
		}
		return null;
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
		for (int i = 0; i < repeats; i++) {
			final Detail d = grade(model, simulator, names, allTransitionInstances);
			if (d != null) {
				error++;
				details.add(d);
			}
		}
		if (error == 0) { return new Message(getMaxPoints(), getName() + " was executed successfully " + repeats
		        + " time" + (repeats == 1 ? "" : "s")); }
		Message m;
		if (repeats - error >= threshold) {
			m = new Message(getMaxPoints(), getName() + " failed " + error + " time" + (error == 1 ? "" : "s")
			        + ", but this is under the threshold");
		} else if (repeats > error) {
			m = new Message(getMinPoints(), getName() + " failed " + error + " time" + (error == 1 ? "" : "s"));
		} else {
			m = new Message(getMinPoints(), getName() + " failed every time.");
		}
		for (final Detail d : details) {
			m.addDetail(d);
		}
		return m;
	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	private Detail grade(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final List<Instance<Transition>> allTransitionInstances) {
		try {
			simulator.initialState();
			Condition toSatisfy = guide;
			final List<Binding> bindings = new ArrayList<Binding>();
			for (int i = 0; maxSteps < 0 || i < maxSteps; i++) {
				final List<Instance<? extends Transition>> enabled = simulator.isEnabled(allTransitionInstances);
				if (enabled.isEmpty()) { return null; // FIXME We should check if any obligations are left
				}
				final Set<Instance<Transition>> allowed = guide.force(new HashSet(enabled), model, names);
				if (allowed.isEmpty()) { return new Detail("No Allowed Transtions for " + getName(),
				        "Enabled Transitions:\n" + toString(enabled), "Executed Trace:\n" + toString(bindings),
				        "Initial Formula:\n" + unparsed, "Parsed Formula:\n" + guide,
				        "Formula at error:\n" + toSatisfy, "Marking at error:\n" + simulator.getMarking(false)); }
				final Binding binding = simulator.executeAndGet(new ArrayList<Instance<Transition>>(allowed));
				toSatisfy = toSatisfy.progress(binding.getTransitionInstance(), model, simulator, names);
				if (toSatisfy == null) { return null; // Nothing left to satisfy
				}
			}
			return new Detail("Simulation Not Terminating", "The simulation was running for " + maxSteps
			        + " steps and was expected to terminate before", "Executed Trace:\n" + toString(bindings),
			        "Initial Formula:\n" + unparsed, "Parsed Formula:\n" + guide, "Formula at error:\n" + toSatisfy,
			        "Marking at error:\n" + simulator.getMarking(false));
		} catch (final Exception e) {
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

	public String getName() {
		return name;
	}

}
