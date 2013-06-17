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
	private final JButton browse;

	public FileChooser(final String labelText, final boolean load) {
		this(labelText, load, true);
	}

	public FileChooser(final String labelText, final String defaultText, final boolean load) {
		this(labelText, defaultText, load, true);
	}

	public FileChooser(final String labelText, final boolean load, final boolean file) {
		this(labelText, "", load, true);
	}

	/**
	 * @param labelText
	 * @param file
	 * @param load
	 */
	public FileChooser(final String labelText, final String defaultText, final boolean load, final boolean file) {
		super(new BorderLayout());
		final JLabel label = new JLabel(labelText);
		add(label, BorderLayout.WEST);
		fileName = new JTextField(defaultText);
		label.setLabelFor(fileName);
		add(fileName, BorderLayout.CENTER);
		browse = new JButton("Browse...");
		add(browse, BorderLayout.EAST);
		browse.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				System.setProperty("apple.awt.fileDialogForDirectories", "" + !file);
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
				fileName.setText(new File(fileDialog.getDirectory(), fileDialog.getFile()).getAbsolutePath());
				System.setProperty("apple.awt.fileDialogForDirectories", "false");
				updated();
			}
		});
	}

	protected void updated() {

	}

	public void openDialog() {
		browse.doClick();
	}

	/**
	 * @return
	 */
	public File getSelected() {
		return new File(fileName.getText());
	}

	public void setSelected(final File file) {
		fileName.setText(file.getAbsolutePath());
	}
}
