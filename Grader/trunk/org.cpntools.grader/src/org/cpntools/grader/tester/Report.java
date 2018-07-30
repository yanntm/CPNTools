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
	private double deductions = 0.0;
	protected final List<Entry<Grader, Message>> reports = new ArrayList<Entry<Grader, Message>>();
	protected StudentID sid;
	
	public static class ReportEntry implements Entry<Grader, Message> {
		
		private Grader grader;
		private Message message;
		
		public ReportEntry(Grader grader, Message message) {
			this.grader = grader;
			this.message = message;
		}

		@Override
		public Grader getKey() {
			return grader;
		}

		@Override
		public Message getValue() {
			return message;
		}

		@Override
		public Message setValue(Message value) {
			this.message = message;
			return getValue();
		}
	}

	/**
	 * @param sid
	 */
	public Report(final StudentID sid) {
		this.sid = sid;

	}

	/**
	 * @param error
	 */
	public void addError(final String error) {
		errors.add(error);
	}

	@Override
	public int compareTo(final Report o) {
		return Double.compare(getPoints()+getDeductions(), (o.getPoints()+o.getDeductions()));
	}

	public List<String> getErrors() {
		return errors_u;
	}

	public List<Entry<Grader, Message>> getReports() {
		return Collections.unmodifiableList(reports);
	}

	public double getPoints() {
		return total;
	}
	
	public double getDeductions() {
		return deductions;
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
		reports.add(new ReportEntry(grader, result));
		if (result.getPoints() > 0)
			total += result.getPoints();
		else
			deductions += result.getPoints();
	}
}
