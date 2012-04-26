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
import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;

/**
 * @author michael
 */
public class MonitoringGrader extends AbstractGrader {
	public static final Grader INSTANCE = new MonitoringGrader(0, 10, -1, -1,
	        Collections.<String, List<String>> emptyMap());

	Pattern p = Pattern
	        .compile(
	                "^monitoring(, *replications=([1-9][0-9]*))?(, *steps=([1-9][0-9]*))?(, *time=([1-9][0-9]*))?(, *parameters=\\[((([\\p{Alpha}][\\p{Alnum}'_]*)=\\[([1-9][0-9.]*(, *[1-9][0-9.]*)*)\\])((, *([\\p{Alpha}][\\p{Alnum}'_]*)=\\[([1-9][0-9.]*(, *[1-9][0-9.]*)*)\\])*))\\])?$",
	                Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
	Pattern params = Pattern.compile("([\\p{Alpha}][\\p{Alnum}'_]*)=\\[([1-9][0-9.]*(, *[1-9][0-9.]*)*)\\](, *(.*))?",
	        Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
	private final int replications, steps, time;
	private final Map<String, List<String>> parameters;

	public MonitoringGrader(final double maxPoints, final int replications, final int steps, final int time,
	        final Map<String, List<String>> parameters) {
		super(maxPoints);
		this.replications = replications;
		this.steps = steps;
		this.time = time;
		this.parameters = parameters;
	}

	/**
	 * @see org.cpntools.grader.model.Grader#configure(double, java.lang.String)
	 */
	@SuppressWarnings("hiding")
	@Override
	public Grader configure(final double maxPoints, final String configuration) {
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
			final Map<String, List<String>> parameters = new HashMap<String, List<String>>();
			if (m.group(8) != null) {
				String params = m.group(8);
				do {
					final Matcher m2 = p.matcher(m.group(8));
					if (m2.matches() && m2.group(1) != null && m2.group(2) != null) {
						final String name = m2.group(1);
						final List<String> values = new ArrayList<String>();
						for (final String value : m2.group(2).split(",")) {
							values.add(value.trim());
						}
						if (!values.isEmpty()) {
							parameters.put(name, values);
						}
						params = m2.group(5);
					} else {
						params = null;
					}
				} while (params != null);
			}
			return new MonitoringGrader(maxPoints, replications, steps, time, parameters);
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
			return new Message(getMaxPoints(), "Monitoring executed correctly; check results manually.", simulate(
			        simulator, new HashMap<String, String>(), parameters));
		} catch (final Exception e) {
			return new Message(getMinPoints(), "An error occurred during grading.", new Detail("Monitoring Error",
			        e.toString()));
		}
	}

	private Detail[] simulate(final HighLevelSimulator simulator, final Map<String, String> values,
	        final Map<String, List<String>> parameters) throws FileNotFoundException, IOException, Exception {
		if (parameters.isEmpty()) {
			return simulate(simulator, values);
		} else {
			final ArrayList<Detail> result = new ArrayList<Detail>();
			final Map<String, List<String>> copy = new HashMap<String, List<String>>(parameters);
			final String name = parameters.keySet().iterator().next();
			final List<String> vs = copy.remove(name);
			for (final String value : vs) {
				final Map<String, String> v = new HashMap<String, String>(values);
				v.put(name, value);
				result.addAll(Arrays.asList(simulate(simulator, v, copy)));
			}
			return result.toArray(new Detail[result.size()]);
		}
	}

	public Detail[] simulate(final HighLevelSimulator simulator, final Map<String, String> values) throws IOException,
	        Exception, FileNotFoundException {
		simulator.initialState();
		for (final Entry<String, String> entry : values.entrySet()) {
			simulator.evaluate(entry.getKey() + " := (" + entry.getValue() + ")");
		}
		simulator.evaluate("Replications.nreplications " + replications);
		File repsDir = null;
		int number = 0;
		do {
			repsDir = new File(simulator.getOutputDir(), "reps_" + ++number);
		} while (repsDir.exists() && repsDir.isDirectory());
		repsDir = new File(simulator.getOutputDir(), "reps_" + --number);
		return new Detail[] {
		        new Detail("Monitoring Results", extractAndCleanTable(new Scanner(new File(repsDir,
		                "PerfReportIID.html")).useDelimiter("\\Z").next(), values)),
		        new Detail("Replication Report", cleanText(new Scanner(new File(repsDir, "replication_report.txt"))
		                .useDelimiter("\\Z").next(), values)) };
	}

	private String cleanText(final String next, final Map<String, String> values) {
		final StringBuilder sb = new StringBuilder();
		sb.append("Parameters\n");
		for (final Entry<String, String> e : values.entrySet()) {
			sb.append(" - ");
			sb.append(e.getKey());
			sb.append(" = ");
			sb.append(e.getValue());
			sb.append('\n');
		}
		sb.append('\n');
		sb.append(next);
		return sb.toString();
	}

	private String extractAndCleanTable(final String next, final Map<String, String> values) {
		String text = next.replaceFirst("([\\r\\n]|.*?)*?<table[^>]*>", "");
		text = text.replaceFirst("</table>([\\n\\r]|.*?)*$", "");
		text = text.replaceAll("<tr>[\\n\\r\\t ]*<tr>", "<tr>");
		text = "<table style=\"border-top: 3px solid black; border-bottom: 3px solid black\">" + text + "</table>";

		final StringBuilder sb = new StringBuilder("<html>");
		sb.append("<h4>Parameters</h4><dl>");
		for (final Entry<String, String> e : values.entrySet()) {
			sb.append("<dt>");
			sb.append(e.getKey());
			sb.append("</dt><dd>");
			sb.append(e.getValue());
			sb.append("</dd>");
		}
		sb.append("</dl>");
		sb.append(text);
		sb.append("</html>");
		return sb.toString();
	}
}
