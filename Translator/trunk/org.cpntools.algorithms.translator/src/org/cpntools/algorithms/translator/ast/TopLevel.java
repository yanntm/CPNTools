package org.cpntools.algorithms.translator.ast;

/**
 * @author michael
 */
public class TopLevel {

	private int x;
	private int y;

	/**
	 * @param tleft
	 * @param tright
	 */
	public void setPosition(final int tleft, final int tright) {
		y = tleft;
		x = tright;
	}

	public int getX() {
		return x;
	}

	public int getY() {
		return y;
	}

	protected void init(final TopLevel t) {
		setPosition(t.y, t.x);
	}

}
