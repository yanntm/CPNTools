package org.cpntools.grader.model;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * @author michael
 */
public class Message {
	public static final Message NULL = new Message(0.0, "Null Message");
	protected final List<Detail> details = new ArrayList<Detail>();
	private final List<Detail> u_details = Collections.unmodifiableList(details);

	public Message(final double points, final String message, final Detail... details) {
		this.points = points;
		this.message = message;
		for (final Detail d : details) {
			addDetail(d);
		}
	}

	public Message(final double points, final String message, final Iterable<Detail> details) {
		this.points = points;
		this.message = message;
		for (final Detail d : details) {
			addDetail(d);
		}
	}

	private final double points;
	private final String message;

	public String getMessage() {
		return message;
	}

	public void addDetail(final Detail d) {
		if (d != null) {
			details.add(d);
		}
	}

	public double getPoints() {
		return points;
	}

	public List<Detail> getDetails() {
		return u_details;
	}
}
