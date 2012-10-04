package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public interface Condition {
	public void prestep(final PetriNet model, HighLevelSimulator simulator, final NameHelper names,
	        Environment environment);

	Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, PetriNet model,
	        HighLevelSimulator simulator, NameHelper names, Environment environment);

	Condition progress(Instance<org.cpntools.accesscpn.model.Transition> ti, PetriNet model,
	        HighLevelSimulator simulator, NameHelper names, Environment environment) throws Unconsumed;

	boolean canTerminate(PetriNet model, HighLevelSimulator simulator, NameHelper names, Environment environment);

	/**
	 * @return
	 */
	Set<String> getAtomic();
}
