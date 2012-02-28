package org.cpntools.grader.model;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.signer.Signer;

/**
 * @author michael
 */
public class SignGrader extends AbstractGrader {

	private final int threshold;
	private final String secret;

	protected SignGrader(final double maxPoints, final int threshold, final String secret) {
		super(maxPoints);
		this.threshold = threshold;
		this.secret = secret != null ? secret : "";
	}

	Pattern p = Pattern.compile("^threshold=([1-9][0-9]*)(,secret=[^,]*)?$", Pattern.CASE_INSENSITIVE);

	@Override
	public synchronized Grader configure(final double maxPoints, final String configuration) {
		final Matcher m = p.matcher(configuration);
		if (!m.matches()) { return null; }
		return new SignGrader(maxPoints, Integer.parseInt(m.group(1)), m.group(2));
	}

	/**
	 * @see org.cpntools.grader.model.AbstractGrader#grade(org.cpntools.grader.model.StudentID,
	 *      org.cpntools.accesscpn.model.PetriNet)
	 */
	@Override
	public Message grade(final StudentID id, final PetriNet model, final HighLevelSimulator simulator) {
		final int match = Signer.checkSignature(model, secret, id);
		if (match >= threshold) { return new Message(getMaxPoints(), "Matched with " + match + " >= " + threshold); }
		return new Message(0.0, "Did not match with " + match + " < " + threshold);
	}
}
