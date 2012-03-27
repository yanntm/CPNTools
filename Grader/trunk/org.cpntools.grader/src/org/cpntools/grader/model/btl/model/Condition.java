package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public interface Condition {
	Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, PetriNet model, NameHelper names);

	Condition progress(Instance<org.cpntools.accesscpn.model.Transition> ti, PetriNet model,
	        HighLevelSimulator simulator, NameHelper names);

}
