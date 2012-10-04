package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class Always implements Guide {
	private final Simple s;
	private final BExpression b;
	private final boolean conjunction;

	public Always(final BExpression b, final Simple s, final boolean conjunction) {
		this.b = b;
		this.s = s;
		this.conjunction = conjunction;

	}

	public Simple getS() {
		return s;
	}

	@Override
	public String toString() {
		if (b == null) {
			if (s == null) { return "true"; }
			return "@ (" + s + ")";
		} else {
			if (s == null) { return "@ (" + b + ")"; }
			if (conjunction) { return "@ (" + b + " & " + s + ")"; }
			return "@ (" + b + " | " + s + ")";
		}
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		boolean B = conjunction;
		if (b != null) {
			B = b.evaluate(model, simulator, names, environment);
		}
		if (conjunction) {
			if (B) { return s == null ? candidates : s.force(candidates, model, simulator, names, environment); }
			return Collections.emptySet();
		} else {
			if (B) { return candidates; }
			if (s == null) {
				return Collections.emptySet();
			} else {
				return s.force(candidates, model, simulator, names, environment);
			}
		}
	}

	@Override
	public Guide progress(final Instance<Transition> ti, final PetriNet model, final HighLevelSimulator simulator,
	        final NameHelper names, final Environment environment) throws Unconsumed {
		Simple newb = b;
		if (b != null) {
			newb = b.progress(ti, model, simulator, names, environment);
		}
		if (newb == null && !conjunction) { return this; }
		Simple news = s;
		if (s != null) {
			news = s.progress(ti, model, simulator, names, environment);
		}
		if (news == null) { return this; }
		if (news == Failure.INSTANCE) { return Failure.INSTANCE; }
		// I don't think this acutlaly should happen...
		return new And(news, this);
	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return true;
	}

	@Override
	public Set<String> getAtomic() {
		return s.getAtomic();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		s.prestep(model, simulator, names, environment);
	}

	public BExpression getB() {
		return b;
	}

}
