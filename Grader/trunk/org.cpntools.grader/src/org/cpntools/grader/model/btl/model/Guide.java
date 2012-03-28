package org.cpntools.grader.model.btl.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public interface Guide extends Condition {
	Guide progress(Instance<org.cpntools.accesscpn.model.Transition> ti, PetriNet model, HighLevelSimulator simulator,
	        NameHelper names) throws Unconsumed;

}
