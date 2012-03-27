package org.cpntools.grader.model.btl.model;

import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public abstract class BExpression extends Expression {
	public abstract boolean evaluate(final PetriNet model, HighLevelSimulator simulator, NameHelper names);

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final NameHelper names) {
		return candidates;
	}

	@Override
	public BExpression progress(final Instance<org.cpntools.accesscpn.model.Transition> transition,
	        final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		if (evaluate(model, simulator, names)) { return null; }
		return this;
	}

}
