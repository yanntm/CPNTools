package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;

/**
 * @author michael
 */
public class Time extends IExpression {
	public static Time INSTANCE = new Time();

	/**
	 * @param name
	 */
	protected Time() {
	}

	@Override
	public String toString() {
		return "time";
	}

	@Override
	public int evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {
		try {
			final String time = simulator.getTime();
			try {
				return Integer.parseInt(time);
			} catch (final Exception e1) {
				try {
					return (int) Math.round(Double.parseDouble(time));
				} catch (final Exception e2) {
				}
			}
		} catch (final Exception e) {

		}
		return Integer.MIN_VALUE;
	}

	@Override
	public Set<String> getAtomic() {
		return Collections.emptySet();
	}

	@Override
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names) {

	}
}
