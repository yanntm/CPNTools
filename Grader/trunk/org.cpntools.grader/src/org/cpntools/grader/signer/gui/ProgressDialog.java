package org.cpntools.grader.signer.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.SwingConstants;

public class ProgressDialog extends JDialog {
	/**
     * 
     */
    private static final long serialVersionUID = -708273440254619104L;
	final JLabel caption;
	private final JProgressBar progressBar;

	public ProgressDialog(final String title, final int max) {
		setTitle(title);
		setLayout(new BorderLayout());
		caption = new JLabel();
		add(caption, BorderLayout.NORTH);
		progressBar = new JProgressBar(SwingConstants.HORIZONTAL, 0, max);
		progressBar.setStringPainted(true);
		progressBar.setIndeterminate(true);
		add(progressBar);
		final JPanel buttons = new JPanel(new FlowLayout(FlowLayout.CENTER));
		final JButton cancelButton = new JButton("Cancel");
		buttons.add(cancelButton);
		add(buttons, BorderLayout.SOUTH);
		cancelButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				setVisible(false);
			}
		});
		setSize(new Dimension(400, 150));
		setVisible(true);
	}

	/**
	 * @param caption
	 */
	public void updateCaption(final String caption) {
		ProgressDialog.this.caption.setText(caption);
		invalidate();
		repaint();
	}

	/**
	 * @param value
	 */
	public void updateValue(final int value) {
		if (value >= progressBar.getMinimum() && value <= progressBar.getMaximum()) {
			if (progressBar.isIndeterminate()) {
				progressBar.setIndeterminate(false);
			}
			progressBar.setValue(value);
			invalidate();
			repaint();
		}
	}

	/**
	 * @return
	 */
	public boolean isCancelled() {
		return !isVisible();
	}
}
