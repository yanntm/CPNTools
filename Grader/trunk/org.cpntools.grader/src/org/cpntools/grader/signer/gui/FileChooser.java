package org.cpntools.grader.signer.gui;

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.filechooser.FileNameExtensionFilter;

public class FileChooser extends JPanel {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1021409666534371348L;
	private final JButton browse;
	final JTextField fileName;

	public FileChooser(final String labelText, final boolean load) {
		this(labelText, load, true);
	}

	public FileChooser(final String labelText, final boolean load, final boolean file) {
		this(labelText, "", load, file);
	}

	public FileChooser(final String labelText, final String defaultText, final boolean load) {
		this(labelText, defaultText, load, true);
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

				JFileChooser fileChooser = new JFileChooser(new File(fileName.getText()));
				if (!file) {
					fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
				} else {
					fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
					fileChooser.setFileFilter(new FileNameExtensionFilter("CPN Files", "cpn"));
				}
				if (load) {
					fileChooser.setDialogTitle("Load file ...");
				} else {
					fileChooser.setDialogTitle("Save files to ...");
				}
				int returnVal = fileChooser.showOpenDialog(FileChooser.this.getTopLevelAncestor());
				if (returnVal == JFileChooser.APPROVE_OPTION) {
					fileName.setText(fileChooser.getSelectedFile().getAbsoluteFile().toString());
					updated();
				}

				// System.setProperty("apple.awt.fileDialogForDirectories", "" + !file);
				// final FileDialog fileDialog = new FileDialog((Dialog) null);
				// if (load) {
				// fileDialog.setMode(FileDialog.LOAD);
				// } else {
				// fileDialog.setMode(FileDialog.SAVE);
				// }
				// if (file) {
				// fileDialog.setFile(fileName.getText());
				// } else {
				// fileDialog.setDirectory(fileName.getText());
				// }
				// fileDialog.setVisible(true);
				//// if (file) {
				//// if (fileDialog.getFile() != null) {
				//// fileName.setText(fileDialog.getFile());
				//// }
				//// } else {
				//// if (fileDialog.getDirectory() != null) {
				//// fileName.setText(fileDialog.getDirectory());
				//// }
				//// }
				// fileName.setText(new File(fileDialog.getDirectory(),
				// fileDialog.getFile()).getAbsolutePath());
				// System.setProperty("apple.awt.fileDialogForDirectories", "false");
			}
		});
	}

	/**
	 * @return
	 */
	public File getSelected() {
		return new File(fileName.getText());
	}

	public void openDialog() {
		browse.doClick();
	}

	public void setSelected(final File file) {
		fileName.setText(file.getAbsolutePath());
	}

	protected void updated() {

	}
}
