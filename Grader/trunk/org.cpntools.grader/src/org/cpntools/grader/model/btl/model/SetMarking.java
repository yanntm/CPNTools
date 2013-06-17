package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

/**
 * @author michael
 */
public class SetMarking implements Guide {

	private final String name;
	private final String value;

	public SetMarking(final String name, final String value) {
		this.value = value;
		this.name = NameHelper.cleanup(name);

	}

	@Override
	public boolean canTerminate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		return true;
	}

	/**
	 * @see java.lang.Object#equals(java.lang.Object)
	 */
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) { return true; }
		if (obj == null) { return false; }
		if (!(obj instanceof SetMarking)) { return false; }
		final SetMarking other = (SetMarking) obj;
		if (name == null) {
			if (other.name != null) { return false; }
		} else if (!name.equals(other.name)) { return false; }
		if (value == null) {
			if (other.value != null) { return false; }
		} else if (!value.equals(other.value)) { return false; }
		return true;
	}

	@Override
	public Set<Instance<org.cpntools.accesscpn.model.Transition>> force(
	        final Set<Instance<org.cpntools.accesscpn.model.Transition>> candidates, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment) {
		return candidates;
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.emptySet();
	}

	public String getName() {
		return name;
	}

	public String getValue() {
		return value;
	}

	/**
	 * @see java.lang.Object#hashCode()
	 */
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (name == null ? 0 : name.hashCode());
		result = prime * result + (value == null ? 0 : value.hashCode());
		return result;
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
		try {
			final Instance<PlaceNode> place = names.getPlaceInstance(name);
			if (place != null) {
				simulator.setMarking(place, value);
			} else {
				simulator.evaluate(name + " := (" + value + ");");
			}
		} catch (final Exception e) {
		}
	}

	@Override
	public Guide progress(final Instance<org.cpntools.accesscpn.model.Transition> ti, final PetriNet model,
	        final HighLevelSimulator simulator, final NameHelper names, final Environment environment)
	        throws Unconsumed {
		throw new Unconsumed();
	}

	@Override
	public String toString() {
		return name + " := \"" + value.replaceAll("\"", "\\\\\"") + "\"";
	}

}
