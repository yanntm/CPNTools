package org.cpntools.grader.model.btl.model;

import java.util.Collections;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.btl.Environment;

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
	public int evaluate(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {
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
	public void prestep(final PetriNet model, final HighLevelSimulator simulator, final NameHelper names,
	        final Environment environment) {

	}

	@Override
	public String toString() {
		return "time";
	}
}
