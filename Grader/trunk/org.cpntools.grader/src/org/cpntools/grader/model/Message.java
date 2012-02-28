package org.cpntools.grader.model;

/**
 * @author michael
 */
public class Message {
	public static final Message NULL = new Message(0.0, "Null Message");

	public Message(final double points, final String message) {
		this.points = points;
		this.message = message;
	}

	private final double points;
	private final String message;

	public String getMessage() {
		return message;
	}

	public double getPoints() {
		return points;
	}
}
