package org.cpntools.grader.model;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Binding;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.Marking;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.tester.EnablingControl;
import org.cpntools.grader.tester.EnablingControlAdapterFactory;

/**
 * @author dfahland
 *
 */
public class TerminationGrader extends AbstractGrader {
	
	public static final Grader INSTANCE = new TerminationGrader(0, 10, -1);

	Pattern p = Pattern.compile("^show-finalmarking(, *steps=([1-9][0-9]*))?(, *time=([1-9][0-9]*))?$",
	        Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
	private int steps;
	private int time;
	
	/**
	 * @param maxPoints
	 * @param steps
	 * @param time
	 */
	public TerminationGrader(double maxPoints, int steps, int time) {
		super(maxPoints);
		this.steps = steps;
		this.time = time;
	}

	/* (non-Javadoc)
	 * @see org.cpntools.grader.model.Grader#configure(double, java.lang.String)
	 */
	@Override
	public Grader configure(double maxPoints, String configuration)	throws Exception {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			int steps = 0;
			if (m.group(2) != null) {
				steps = Integer.parseInt(m.group(2));
			}
			int time = 0;
			if (m.group(4) != null) {
				time = Integer.parseInt(m.group(4));
			}
			return new TerminationGrader(maxPoints, steps, time);
		}
		return null;
	}

	/* (non-Javadoc)
	 * @see org.cpntools.grader.model.AbstractGrader#grade(org.cpntools.grader.model.StudentID, org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.model.PetriNet, org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator)
	 */
	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model, final HighLevelSimulator simulator) {
		if (simulator == null) { return new Message(getMinPoints(), "Cannot test termination without a correct model!"); }
		try {
			final EnablingControl ec = (EnablingControl) EnablingControlAdapterFactory.getInstance().adapt(model, EnablingControl.class);
			simulator.setStopOptions("IntInf.fromInt " + steps, "IntInf.fromInt 0", "ModelTime.fromInt " + time, "ModelTime.fromInt 0");
			return new Message(getMaxPoints(), "Simulation executed correctly; check final marking manually.", simulate(simulator, ec, model));
		} catch (final Exception e) {
			return new Message(getMinPoints(), "An error occurred during grading.", new Detail("Monitoring Error",
			        e.toString()));
		}
	}
	
	/**
	 * @param simulator
	 * @param ec 
	 * @param petriNet 
	 * @return
	 * @throws Exception 
	 */
	public Detail[] simulate(final HighLevelSimulator simulator, EnablingControl ec, PetriNet petriNet) throws Exception {
		simulator.initialState();
		
		Random r = new Random();

		List<Instance<Transition>> allTransitionInstances = new ArrayList<Instance<Transition>>();
		allTransitionInstances.addAll(simulator.getAllTransitionInstances());

		Map<Instance<Transition>, Integer> parikh = new HashMap<Instance<Transition>, Integer>();  

		List<String> marking = new ArrayList<String>();
		
		int i = 0;
		for (; i < steps; i++) {
			try {
				//final Set<Instance<Transition>> allowed = new HashSet<Instance<Transition>>();
				List<Instance<Transition>> enabled = TerminationGrader.getEnabledAndAllowed(petriNet, simulator, ec, allTransitionInstances);
				if (enabled.isEmpty()) {
					break;
				} else {
					Instance<Transition> ti = enabled.get(r.nextInt(enabled.size()));
					final Binding binding = simulator.executeAndGet(ti);
					if (binding != null) {
						// the pre-computed binding could be executed 
						if (!parikh.containsKey(ti)) parikh.put(ti, 1);
						else parikh.put(ti, parikh.get(ti)+1);
					} else {
						// the pre-computed binding could not be executed, probably because of non-deterministic
						// calculations in the guard, find binding and execute transition inside the simulator 
						if (simulator.execute(ti)) {
							if (!parikh.containsKey(ti)) parikh.put(ti, 1);
							else parikh.put(ti, parikh.get(ti)+1);
						} else {
							// failed: to execute stop
							marking.add("Stopped early at "+ti+" (could not fire)");
							break; // end of simulation
						}
					}
				}
			} catch (final Exception e) {
				return new Detail[] { new Detail("Checking failed with: " + e, e.getMessage()) };
			}
		}
		



		marking.add("Terminated after "+i+" steps");
		for (Entry<Instance<Transition>, Integer> e : parikh.entrySet() ) {
			marking.add(e.getKey()+ " fired "+e.getValue() +" times");
		}
		marking.add("Reached final marking");
		for (Instance<PlaceNode> p : simulator.getAllPlaceInstances()) {
			String label = p.getNode().getName().getText();
			if (label.startsWith("Enabling Control")) continue;
			Marking m = simulator.getMarking().getMarking(p);
			if (m.getTokenCount() > 0) {
				marking.add("|"+p.toString()+"|="+m.getTokenCount()+", ");
			}
		}
		Detail finalMarkingDetail = new Detail("Final marking", marking);
		return new Detail[] { finalMarkingDetail }; 

	}

	/**
	 * @param simulator
	 * @param ec 
	 * @param allTransitionInstances
	 * @return
	 * @throws IOException
	 */
	@SuppressWarnings("unchecked")
	public static List<Instance<Transition>> getEnabled(final HighLevelSimulator simulator,
			final EnablingControl ec,
	        final List<Instance<Transition>> allTransitionInstances) throws IOException {
		
		for (final Instance<Transition> ti : allTransitionInstances) {
			ec.enable(ti);
		}
		simulator.initialiseSimulationScheduler();
		final List<Instance<? extends Transition>> enabled = simulator.isEnabled(allTransitionInstances);
		return (List) enabled;
	}

	/**
	 * @param model
	 * @param simulator
	 * @param ec 
	 * @param allTransitionInstances
	 * @return
	 * @throws IOException
	 */
	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static List<Instance<Transition>> getEnabledAndAllowed(final PetriNet model,
	        final HighLevelSimulator simulator,
	        final EnablingControl ec,
	        final List<Instance<Transition>> allTransitionInstances) throws IOException {

		List<Instance<Transition>> enabled = TerminationGrader.getEnabled(simulator, ec, allTransitionInstances);
 //System.out.println(enabled);
		while (enabled.isEmpty() && simulator.increaseTime() == null) {
 //System.out.println("Increasing time");
			enabled = (List) simulator.isEnabled(allTransitionInstances);
 //System.out.println(enabled);
		}
 //System.out.println("Returning " + enabled);
		return enabled;
	}
	
}
