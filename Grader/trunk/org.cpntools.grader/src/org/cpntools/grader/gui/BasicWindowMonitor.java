package org.cpntools.grader.gui;

import java.awt.event.*;
import java.awt.Window;

public class BasicWindowMonitor extends WindowAdapter {
	
	private Window parent;
	
	/**
	 * Monitor closing of window. If there is still a known parent window, then don't close this one.
	 * @param parent
	 */
	public BasicWindowMonitor(Window parent) {
		this.parent = parent;
	}

	/**
	 * Close window and close application unless there is parent window still running. 
	 */
	@Override
	public void windowClosing(WindowEvent e) {
		Window w = e.getWindow();
		w.setVisible(false);
		w.dispose();
		
		if (parent == null || !parent.isShowing()) {
			System.exit(0);
		}
	}
}