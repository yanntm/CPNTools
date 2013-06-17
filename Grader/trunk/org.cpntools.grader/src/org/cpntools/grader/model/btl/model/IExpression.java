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
public abstract class IExpression extends Expression {
	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		throw new UnsupportedOperationException("You should never call canTerminate on IExpressions");
	}

	public abstract int evaluate(final PetriNet model, HighLevelSimulator simulator, NameHelper names,
	        Environment environment);

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return candidates;
	}

	@Override
	public IExpression progress(final Instance<org.cpntools.accesscpn.model.Transition> transition,
	        final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		throw new UnsupportedOperationException("You should never call progress on IExpressions");
	}

}
