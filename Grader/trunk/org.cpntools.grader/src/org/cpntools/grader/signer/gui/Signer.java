package org.cpntools.grader.signer.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.OperationNotSupportedException;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.ProgressMonitor;
import javax.swing.WindowConstants;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.impl.PetriNetImpl;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.signer.Generator;

/**
 * @author michael
 */
public class Signer extends JDialog {
	/**
     * 
     */
	private static final long serialVersionUID = -4634356481967680322L;

	protected Signer() {
		setTitle("Sign Base Models");
		setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		setLayout(new BorderLayout());
		final JPanel buttons = new JPanel(new FlowLayout(FlowLayout.CENTER));
		final JButton cancelButton = new JButton("Cancel");
		buttons.add(cancelButton);
		cancelButton.addActionListener(new ActionListener() {

			@Override
			public void actionPerformed(final ActionEvent e) {
				Signer.this.setVisible(false);
				System.exit(0);
			}
		});
		final JButton okButton = new JButton("Ok");
		buttons.add(okButton);
		getRootPane().setDefaultButton(okButton);
		add(buttons, BorderLayout.SOUTH);

		final JPanel files = new JPanel(new BorderLayout());
		final FileChooser baseModel = new FileChooser("Base model", true);
		files.add(baseModel, BorderLayout.NORTH);
		final FileChooser outputDir = new FileChooser("Output directory", true, false);
		files.add(outputDir, BorderLayout.SOUTH);

		final JPanel secret = new JPanel(new BorderLayout());
		final JLabel secretLabel = new JLabel("Secret");
		secret.add(secretLabel, BorderLayout.WEST);
		final JTextField secretField = new JTextField();
		secret.add(secretField);
		secretLabel.setLabelFor(secretField);

		final JPanel top = new JPanel(new BorderLayout());
		top.add(files, BorderLayout.SOUTH);
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
				setVisible(false);
				generate(secretField.getText().trim(), baseModel.getSelected(), outputDir.getSelected(), idField
				        .getText().trim());

			}
		});
		setMinimumSize(new Dimension(400, 300));
		pack();
	}

	protected void generate(final String secret, final File base, final File output, final String ids) {
		final List<StudentID> idList = new ArrayList<StudentID>();
		for (final String s : ids.split("[\n\r]")) {
			final String id = s.trim();
			if (!"".equals(id)) {
				idList.add(new StudentID(id));
			}
		}

		final ProgressMonitor progressMonitor = new ProgressMonitor(null, "Generating Signed Models",
		        "Loading base model...", 0, idList.size() + 1);
		PetriNet model;
		try {
			model = DOMParser.parse(new FileInputStream(base), base.getName().replaceAll("[.]cpn$", ""));
		} catch (final Exception e) {
			JOptionPane.showMessageDialog(null, "Loading model failed: " + e.getMessage(), "Error Loading Base Model",
			        JOptionPane.ERROR_MESSAGE);
			return;
		}
		progressMonitor.setProgress(1);

		int min = Integer.MAX_VALUE;
		int max = Integer.MIN_VALUE;
		int total = 0;
		int progress = 1;
		for (final StudentID sid : idList) {
			progress++;
			try {
				progressMonitor.setNote("Generating signed model " + total + " / " + idList.size() + "...");
				final int threshold = generate(secret, sid, (PetriNetImpl) model, output);
				min = Math.min(threshold, min);
				max = Math.max(threshold, max);
				total++;
			} catch (final Exception e) {
				e.printStackTrace();
				if (JOptionPane.showConfirmDialog(null,
				        "Generation failed for Student ID `" + sid + "':\n" + e.getMessage()
				                + "\n\nContinue generation?", "Error Generating Signed Model",
				        JOptionPane.YES_NO_OPTION) != JOptionPane.YES_OPTION) { return; }
			}
			progressMonitor.setProgress(progress);
			if (progressMonitor.isCanceled()) {
				JOptionPane.showMessageDialog(null, "Generation cancelled!");
				break;
			}
		}

		progressMonitor.close();
		JOptionPane.showMessageDialog(null, "Generation of " + total + " model" + (total == 1 ? "" : "s")
		        + " completed.\nThreshold for signatures: " + min + " - " + max, "Generation Complete",
		        JOptionPane.INFORMATION_MESSAGE);
		System.exit(0);
	}

	private int generate(final String secret, final StudentID studentID, final PetriNetImpl model, final File output)
	        throws OperationNotSupportedException, TransformerException, ParserConfigurationException, IOException {
		return org.cpntools.grader.signer.Signer.checkSignature(Generator.generate(output, model, secret, studentID),
		        secret, studentID);
	}

	/**
	 * @param args
	 */
	public static void main(final String[] args) {
		System.setProperty("apple.laf.useScreenMenuBar", "true");
		System.setProperty("com.apple.mrj.application.apple.menu.about.name", "Signer");
		new Signer().setVisible(true);

	}

}
