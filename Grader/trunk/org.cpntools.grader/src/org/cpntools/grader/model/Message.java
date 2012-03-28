package org.cpntools.grader.model;

import java.util.Collection;
import java.util.Map;
import java.util.TreeMap;

/**
 * @author michael
 */
public class Message {
	public static final Message NULL = new Message(0.0, "Null Message");
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

	private final double points;
	private final String message;

	public String getMessage() {
		return message;
	}

	public void addDetail(final Detail d) {
		if (d != null) {
			details.put(d.getHeader(), d);
		}
	}

	public double getPoints() {
		return points;
	}

	public Collection<Detail> getDetails() {
		return details.values();
	}
}
