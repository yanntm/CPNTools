package org.cpntools.grader.model.btl.model;

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
			return Integer.parseInt(simulator.getTime());
		} catch (final Exception e) {
			return Integer.MIN_VALUE;
		}
	}
}
