package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.WindowConstants;

import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.signer.gui.FileChooser;

/**
 * @author michael
 */
public class SetupDialog extends JDialog {

	/**
     * 
     */
	private static final long serialVersionUID = -7081862886519471794L;

	protected File base = null;

	/**
	 * @return the base
	 */
	public File getBase() {
		return base;
	}

	/**
	 * @return the models
	 */
	public File getModels() {
		return models;
	}

	/**
	 * @return the secret
	 */
	public String getSecret() {
		return secret;
	}

	/**
	 * @return the ids_u
	 */
	public List<StudentID> getStudentIds() {
		return ids_u;
	}

	protected File models = null;
	protected String secret = null;
	protected final List<StudentID> ids = new ArrayList<StudentID>();
	private final List<StudentID> ids_u = Collections.unmodifiableList(ids);

	private final JPanel files;

	public SetupDialog() {
		setModal(true);
		setTitle("Setup Grading");
		setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		setLayout(new BorderLayout());
		final JPanel buttons = new JPanel(new FlowLayout(FlowLayout.CENTER));
		final JButton cancelButton = new JButton("Cancel");
		buttons.add(cancelButton);
		cancelButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(final ActionEvent e) {
				SetupDialog.this.setVisible(false);
				System.exit(0);
			}
		});
		final JButton okButton = new JButton("Ok");
		buttons.add(okButton);
		getRootPane().setDefaultButton(okButton);
		add(buttons, BorderLayout.SOUTH);

		files = new JPanel(new BorderLayout());
		final FileChooser baseModel = new FileChooser("Base model", true);
		getFiles().add(baseModel, BorderLayout.NORTH);
		final FileChooser outputDir = new FileChooser("Model directory", true, false) {
			@Override
			protected void updated() {
				if (baseModel.getSelected().getName().equals("")) {
					final File base = new File(getSelected(), "base");
					if (base.exists() && base.isDirectory()) {
						for (final File f : base.listFiles(new FilenameFilter() {
							@Override
							public boolean accept(final File arg0, final String arg1) {
								return arg1.endsWith(".cpn");
							}

						})) {
							baseModel.setSelected(f);
						}
					}
				}
				SetupDialog.this.update(getSelected());
			}
		};
		getFiles().add(outputDir, BorderLayout.CENTER);

		final JPanel secret = new JPanel(new BorderLayout());
		final JLabel secretLabel = new JLabel("Secret");
		secret.add(secretLabel, BorderLayout.WEST);
		final JTextField secretField = new JTextField();
		secret.add(secretField);
		secretLabel.setLabelFor(secretField);

		final JPanel top = new JPanel(new BorderLayout());
		top.add(getFiles(), BorderLayout.SOUTH);
		top.add(secret, BorderLayout.NORTH);
		add(top, BorderLayout.NORTH);

		final JPanel ids = new JPanel(new BorderLayout());
		ids.add(new JLabel("Student ids"), BorderLayout.NORTH);
		final JTextArea idField = new JTextArea();
		ids.add(idField);
		add(ids);
		okButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent e) {
				SetupDialog.this.secret = secretField.getText().trim();
				base = baseModel.getSelected();
				models = outputDir.getSelected();
				SetupDialog.this.ids.clear();
				for (final String s : idField.getText().trim().split("[\n\r]")) {
					final String idText = s.trim();
					if (!"".equals(idText)) {
						SetupDialog.this.ids.add(new StudentID(idText));
					}
				}
				setVisible(false);
			}
		});
		setMinimumSize(new Dimension(400, 300));
		pack();
	}

	protected void update(final File selected) {

	}

	public JPanel getFiles() {
		return files;
	}
}
