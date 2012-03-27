package org.cpntools.grader.model.btl.model;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public abstract class Simple implements Guide {
	@Override
	public Simple progress(final Instance<org.cpntools.accesscpn.model.Transition> transition, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names) {
		return null; // Simple are always reduced if legal (as we assume they are due to force)
	}

}
