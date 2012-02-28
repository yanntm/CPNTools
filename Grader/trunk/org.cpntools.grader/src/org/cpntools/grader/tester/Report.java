package org.cpntools.grader.tester;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;

public class Report implements Comparable<Report> {
	protected final Map<Grader, Message> reports = new HashMap<Grader, Message>();
	protected final List<String> errors = new ArrayList<String>();
	private final List<String> errors_u = Collections.unmodifiableList(errors);
	protected final StudentID sid;
	private double total = 0.0;

	/**
	 * @param sid
	 */
	public Report(final StudentID sid) {
		this.sid = sid;

	}

	public StudentID getStudentId() {
		return sid;
	}

	void addReport(final Grader grader, final Message result) {
		reports.put(grader, result);
		total += result.getPoints();
	}

	public void addError(final String error) {
		errors.add(error);
	}

	public double getResult() {
		return total;
	}

	public Set<Entry<Grader, Message>> getReports() {
		return Collections.unmodifiableSet(reports.entrySet());
	}

	public List<String> getErrors() {
		return errors_u;
	}

	@Override
	public String toString() {
		return sid.toString();
	}

	@Override
	public int compareTo(final Report o) {
		return Double.compare(getResult(), o.getResult());
	}
}
