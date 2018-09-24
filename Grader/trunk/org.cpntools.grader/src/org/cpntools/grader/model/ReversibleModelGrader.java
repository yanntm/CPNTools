package org.cpntools.grader.model;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Marking;
import org.cpntools.accesscpn.engine.highlevel.instance.State;
import org.cpntools.accesscpn.model.PetriNet;

public class ReversibleModelGrader extends AbstractGrader {
	public static final Grader INSTANCE = new ReversibleModelGrader(0, 10, -1, -1);
	
	private final int replications, steps, time;
	Pattern p = Pattern
	        .compile(
	                "^reversible(, *replications=([1-9][0-9]*))?(, *steps=([1-9][0-9]*))?(, *time=([1-9][0-9]*))?$",
	                Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
	//Pattern params = Pattern.compile("([\\p{Alpha}][\\p{Alnum}'_]*)=\\[([1-9][0-9.]*(, *[1-9][0-9.]*)*)\\](, *(.*))?",
	//        Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
	
	public ReversibleModelGrader(final double maxPoints, int replications, int steps, int time) {
		super(maxPoints);
		this.replications = replications;
		this.steps = steps;
		this.time = time;
	}

	@SuppressWarnings("hiding")
	@Override
	public Grader configure(double maxPoints, String configuration) throws Exception {
		final Matcher m = p.matcher(configuration);
		if (m.matches()) {
			int replications = 10;
			if (m.group(2) != null) {
				replications = Integer.parseInt(m.group(2));
			}
			int steps = 0;
			if (m.group(4) != null) {
				steps = Integer.parseInt(m.group(4));
			}
			int time = 0;
			if (m.group(6) != null) {
				time = Integer.parseInt(m.group(6));
			}
			return new ReversibleModelGrader(maxPoints, replications, steps, time);
		}
		return null;
	}

	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		if (simulator == null) { return new Message(getMinPoints(), "Cannot test monitors without a correct model!"); }
		try {
			simulator.setStopOptions("IntInf.fromInt " + steps, "IntInf.fromInt 0", "ModelTime.fromInt " + time,
			        "ModelTime.fromInt 0");
			
			simulator.initialState();
			State m = simulator.getMarking();
			simulator.execute(steps);
			State m2 = simulator.getMarking();
			
			int m_tokens = 0;
			for (Marking place : m.getAllMarkings()) {
				m_tokens += place.getTokenCount();
			}
			int m2_tokens = 0;
			for (Marking place : m2.getAllMarkings()) {
				m2_tokens += place.getTokenCount();
			}
			
			if (m2_tokens <= m_tokens*2) {
				Detail d = new Detail("Reversible Model", "Had "+m_tokens+" in initial marking and "+m2_tokens+" in the final marking/after "+steps+" steps. This is ok.");  
				return new Message(getMaxPoints(), "Tokens are properly cleaned up in the model.", d);
			} else {
				Detail d = new Detail("Reversible Model", "Had "+m_tokens+" in initial marking and "+m2_tokens+" in the final marking/after "+steps+" steps. This is not ok.");  
				return new Message(getMinPoints(), "Tokens are accumulating in the model.", d);
				
			}
		} catch (final Exception e) {
			return new Message(getMinPoints(), "An error occurred during grading.", new Detail("Monitoring Error",
			        e.toString()));
		}
	}

}
