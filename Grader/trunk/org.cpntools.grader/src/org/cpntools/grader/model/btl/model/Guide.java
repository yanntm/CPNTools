package org.cpntools.grader.model.btl.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public interface Guide extends Condition {
	@Override
	Guide progress(Instance<org.cpntools.accesscpn.model.Transition> ti, PetriNet model, HighLevelSimulator simulator,
	        NameHelper names, Environment environment) throws Unconsumed;

}
