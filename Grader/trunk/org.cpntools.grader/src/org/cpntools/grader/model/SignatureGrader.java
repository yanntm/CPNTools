package org.cpntools.grader.model;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.grader.signer.Signer;

/**
 * @author michael
 */
public class SignatureGrader extends AbstractGrader {
	public static Grader INSTANCE = new SignatureGrader(0, Integer.MAX_VALUE, "##");

	private final int threshold;
	private final String secret;

	protected SignatureGrader(final double maxPoints, final int threshold, final String secret) {
		super(maxPoints);
		this.threshold = threshold;
		this.secret = secret != null ? secret : "";
	}

	Pattern p = Pattern.compile("^threshold=([1-9][0-9]*)(, *secret=([^,]))?$", Pattern.CASE_INSENSITIVE);

	/**
	 * @see org.cpntools.grader.model.Grader#configure(double, java.lang.String)
	 */
	@Override
	public synchronized Grader configure(final double maxPoints, final String configuration) {
		final Matcher m = p.matcher(configuration);
		if (!m.matches()) { return null; }
		return new SignatureGrader(maxPoints, Integer.parseInt(m.group(1)), m.group(3));
	}

	/**
	 * @see org.cpntools.grader.model.AbstractGrader#grade(org.cpntools.grader.model.StudentID,
	 *      org.cpntools.accesscpn.model.PetriNet)
	 */
	@Override
	public Message grade(final StudentID id, final PetriNet base, final PetriNet model,
	        final HighLevelSimulator simulator) {
		final int match = Signer.checkSignature(model, secret, id);
		if (match >= threshold) { return new Message(getMaxPoints(), "Matched with " + match + " >= " + threshold); }
		return new Message(getMinPoints(), "Did not match with " + match + " < " + threshold);
	}
}
