package org.cpntools.grader.tester;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.TreeMap;

import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;

/**
 * @author michael
 */
public class Report implements Comparable<Report> {
	protected final List<String> errors = new ArrayList<String>();
	private final List<String> errors_u = Collections.unmodifiableList(errors);
	private double total = 0.0;
	protected final Map<Grader, Message> reports = new TreeMap<Grader, Message>();
	protected StudentID sid;

	/**
	 * @param sid
	 */
	public Report(final StudentID sid) {
		this.sid = sid;

	}

	public void addError(final String error) {
		errors.add(error);
	}

	@Override
	public int compareTo(final Report o) {
		return Double.compare(getResult(), o.getResult());
	}

	public List<String> getErrors() {
		return errors_u;
	}

	public Set<Entry<Grader, Message>> getReports() {
		return Collections.unmodifiableSet(reports.entrySet());
	}

	public double getResult() {
		return total;
	}

	public StudentID getStudentId() {
		return sid;
	}

	public void setStudentId(final StudentID sid) {
		this.sid = sid;
	}

	@Override
	public String toString() {
		return sid.toString();
	}

	void addReport(final Grader grader, final Message result) {
		reports.put(grader, result);
		total += result.getPoints();
	}
}
