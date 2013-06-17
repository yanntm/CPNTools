package org.cpntools.grader.model;

import java.util.Collection;
import java.util.Map;
import java.util.TreeMap;

/**
 * @author michael
 */
public class Message {
	public static final Message NULL = new Message(0.0, "Null Message");
	private final String message;

	private final double points;

	protected final Map<String, Detail> details = new TreeMap<String, Detail>();

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

	public void addDetail(final Detail d) {
		if (d != null) {
			details.put(d.getHeader(), d);
		}
	}

	public Collection<Detail> getDetails() {
		return details.values();
	}

	public String getMessage() {
		return message;
	}

	public double getPoints() {
		return points;
	}
}
