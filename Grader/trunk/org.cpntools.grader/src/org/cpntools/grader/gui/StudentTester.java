package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.io.File;
import java.io.InputStream;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.importer.DOMParser;

/**
 * @author michael
 */
public class StudentTester extends JDialog implements Observer {
	private final JTextArea log;
	private final InputStream baseStream;
	private final InputStream configStream;
	private final File model;
	private PetriNet petriNet;
	private final JProgressBar progressBar;

	public StudentTester(final InputStream baseStream, final InputStream configStream, final File model) {
		this.baseStream = baseStream;
		this.configStream = configStream;
		this.model = model;
		setTitle("I Want it That Way Ð " + model.getName().replaceAll("[.][cC][pP][nN]$", ""));
		setLayout(new BorderLayout());

		log = new JTextArea();
		log.setEditable(false);
		final JScrollPane logScroller = new JScrollPane(log);
		add(logScroller);
		logScroller.setPreferredSize(new Dimension(500, 250));
		final JButton cancelButton = new JButton("Cancel");
		final JPanel buttons = new JPanel(new FlowLayout(FlowLayout.CENTER));
		add(buttons, BorderLayout.SOUTH);
		buttons.add(cancelButton);

		progressBar = new JProgressBar(0, 10);
		progressBar.setStringPainted(true);
		add(progressBar, BorderLayout.NORTH);
		pack();
		setVisible(true);

	}

	public void setup() {
		log("Loading base model");
		try {
			petriNet = DOMParser.parse(baseStream, "base model");
		} catch (final Exception e) {
			JOptionPane
			        .showMessageDialog(this, "Error loading base model!", "Error Loading", JOptionPane.ERROR_MESSAGE);
			return;
		}
		progressBar.setValue(1);

		log("Loading configuration file");

	}

	public static void main(final String... args) {
		final InputStream baseStream = getResource("../../../../base.cpn");
		if (baseStream == null) {
			JOptionPane
			        .showMessageDialog(
			                null,
			                "Could not find the base model.\n\nPlease contact your teacher and not\nthe author of this program for help..",
			                "Error", JOptionPane.ERROR_MESSAGE);
			System.exit(1);
		}
		final InputStream configStream = getResource("../../../../config.cfg");
		if (configStream == null) {
			JOptionPane
			        .showMessageDialog(
			                null,
			                "Could not find the configuration file.\n\nPlease contact your teacher and not\nthe author of this program for help..",
			                "Error", JOptionPane.ERROR_MESSAGE);
			System.exit(1);
		}
		final JFileChooser load = new JFileChooser();
		final int result = load.showOpenDialog(null);
		if (result == JFileChooser.APPROVE_OPTION) {
			final File model = load.getSelectedFile();
			if (!model.isFile()) {
				JOptionPane.showMessageDialog(null, "Selected file could no be found or is not a file.", "Error",
				        JOptionPane.ERROR_MESSAGE);
				System.exit(1);
			}
			new StudentTester(baseStream, configStream, load.getSelectedFile());
		} else {
			System.exit(0);
		}
	}

	private static InputStream getResource(final String resource) {
		InputStream result = StudentTester.class.getResourceAsStream(resource);
		if (result != null) { return result; }
		result = StudentTester.class.getResourceAsStream("../../../.." + resource);
		if (result != null) { return result; }
		result = StudentTester.class.getResourceAsStream("../../../../.." + resource);
		if (result != null) { return result; }
		return result;
	}

	@Override
	public void update(final Observable arg0, final Object arg1) {
		if (arg1 instanceof String) {
			log((String) arg1);
		}
	}

	public void log(final String message) {
		log.append(message + "\n");
		log.setCaretPosition(log.getText().length());
	}

}
