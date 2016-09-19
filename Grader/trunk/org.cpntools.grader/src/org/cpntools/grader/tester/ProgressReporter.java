package org.cpntools.grader.tester;

/**
 * Encapsulate progress bar behavior to allow progress reporting for command line
 * as well as for windows.
 *  
 * @author dfahland
 */
public interface ProgressReporter {

	/**
	 * @return amount of work remaining on the progress bar
	 */
	public int getRemainingProgress();
	/**
	 * add amount of work done to progress bar
	 * @param amount
	 */
	public void addProgress(int amount);

}
