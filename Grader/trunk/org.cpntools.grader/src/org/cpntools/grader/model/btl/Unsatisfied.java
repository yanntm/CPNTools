package org.cpntools.grader.model.btl;

/**
 * @author michael
 */
public class Unsatisfied extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	public Unsatisfied() {
		super("The formula is not satisfied");
	}
}
