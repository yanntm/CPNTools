package org.cpntools.grader.signer.gui;

import java.awt.BorderLayout;
import java.awt.Dialog;
import java.awt.FileDialog;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

public class FileChooser extends JPanel {
	/**
     * 
     */
    private static final long serialVersionUID = 1021409666534371348L;
	final JTextField fileName;

	public FileChooser(final String labelText, final boolean load) {
		this(labelText, true, load);
	}

	/**
	 * @param labelText
	 * @param file
	 * @param load
	 */
	public FileChooser(final String labelText, final boolean file, final boolean load) {
		super(new BorderLayout());
		final JLabel label = new JLabel(labelText);
		add(label, BorderLayout.WEST);
		fileName = new JTextField();
		label.setLabelFor(fileName);
		add(fileName, BorderLayout.CENTER);
		final JButton browse = new JButton("Browse...");
		add(browse, BorderLayout.EAST);
		browse.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				final FileDialog fileDialog = new FileDialog((Dialog) null);
				if (load) {
					fileDialog.setMode(FileDialog.LOAD);
				} else {
					fileDialog.setMode(FileDialog.SAVE);
				}
				if (file) {
					fileDialog.setFile(fileName.getText());
				} else {
					fileDialog.setDirectory(fileName.getText());
				}
				fileDialog.setVisible(true);
// if (file) {
// if (fileDialog.getFile() != null) {
// fileName.setText(fileDialog.getFile());
// }
// } else {
// if (fileDialog.getDirectory() != null) {
// fileName.setText(fileDialog.getDirectory());
// }
// }
				if (file) {
					fileName.setText(new File(fileDialog.getDirectory(), fileDialog.getFile()).getAbsolutePath());
				} else {
					fileName.setText(fileDialog.getDirectory());
				}
			}
		});
	}

	/**
	 * @return
	 */
	public File getSelected() {
		return new File(fileName.getText());
	}
}
