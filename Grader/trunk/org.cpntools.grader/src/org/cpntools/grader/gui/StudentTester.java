package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map.Entry;
import java.util.Observable;
import java.util.Observer;

import javax.swing.BorderFactory;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.grader.gui.PDFExport.ReportItem;
import org.cpntools.grader.model.ConfigurationTestSuite;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.TestSuite;
import org.cpntools.grader.model.btl.BTLGrader;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.tester.Tester;

/**
 * @author michael
 */
public class StudentTester extends JDialog implements Observer {
	public static class TestError {

		private final BTLGrader grader;

		public TestError(final BTLGrader grader) {
			this.grader = grader;
		}

		@Override
		public String toString() {
			return getGrader().getName();
		}

		public BTLGrader getGrader() {
			return grader;
		}

	}

	private static final int PROGRESS_MAX = 10;
	private final JTextArea log;
	private final InputStream baseStream;
	private final InputStream configStream;
	private final File model;
	private PetriNet petriNet;
	private final JProgressBar progressBar;
	private TestSuite suite;
	private int progress = 0;
	private Tester tester;
	private final JButton cancelButton;
	private final JButton exportButton;
	List<Report> testResult;
	private final JPanel errorPanel;
	private final DefaultListModel errors;

	public StudentTester(final InputStream baseStream, final InputStream configStream, final File model) {
		this.baseStream = baseStream;
		this.configStream = configStream;
		this.model = model;
		setTitle("Grade/CPN Student Tester Ñ " + model.getName().replaceAll("[.][cC][pP][nN]$", ""));
		setLayout(new BorderLayout());

		log = new JTextArea();
		log.setEditable(false);
		final JScrollPane logScroller = new JScrollPane(log);
		add(logScroller);
		logScroller.setPreferredSize(new Dimension(500, 250));
		cancelButton = new JButton("Cancel");
		cancelButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				System.exit(0);
			}
		});

		exportButton = new JButton("Export PDF");
		exportButton.setEnabled(false);
		exportButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				if (!testResult.isEmpty()) {
					File output = model;
					final JFileChooser jFileChooser = new JFileChooser();
					if (output == null) {
						if (JFileChooser.APPROVE_OPTION == jFileChooser.showOpenDialog(StudentTester.this)) {
							output = jFileChooser.getSelectedFile();
						}
					}
					while (output != null && !output.isDirectory()) {
						output = output.getParentFile();
					}
					if (output != null) {
						final Collection<PDFExport.ReportItem> items = new ArrayList<PDFExport.ReportItem>();
						for (final Report r : testResult) {
							items.add(new ReportItem(r, r.getStudentId(), model, Collections.emptyList(), null));
						}
						try {
							PDFExport.exportReports(output, items);
							JOptionPane.showMessageDialog(StudentTester.this, "Report successfully exported as `"
							        + new File(output, "S" + testResult.get(0).getStudentId() + ".pdf'"),
							        "Export Successful", JOptionPane.INFORMATION_MESSAGE);
						} catch (final Exception e) {
							JOptionPane.showMessageDialog(StudentTester.this, "Error exporting: " + e,
							        "Error Exporting", JOptionPane.ERROR_MESSAGE);
						}
					}
				}
			}
		});
		final JPanel buttons = new JPanel(new FlowLayout(FlowLayout.CENTER));
		add(buttons, BorderLayout.SOUTH);
		buttons.add(exportButton);
		buttons.add(cancelButton);

		progressBar = new JProgressBar(0, PROGRESS_MAX);
		progressBar.setStringPainted(true);
		add(progressBar, BorderLayout.NORTH);

		errorPanel = new JPanel(new BorderLayout());
		errors = new DefaultListModel();
		final JList errorList = new JList(errors);
		errorList.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(final MouseEvent evt) {
				final JList list = (JList) evt.getSource();
				if (evt.getClickCount() == 2) { // Double-click
					final int index = list.locationToIndex(evt.getPoint());
					final TestError testError = (TestError) errors.get(index);
					try {
						new BTLTester(petriNet, model.getParentFile(), testError.getGrader().getGuide());
					} catch (final Exception e) {
						e.printStackTrace();
					}
				}
			}
		});
		final JScrollPane errorScroller = new JScrollPane(errorList);
		errorScroller.setBorder(BorderFactory.createTitledBorder("Failing Tests"));
		errorPanel.add(errorScroller, BorderLayout.CENTER);
		errorPanel.setVisible(false);
		add(errorPanel, BorderLayout.EAST);
		pack();
		setVisible(true);

	}

	public void setup() {
		log("Loading base model");
		PetriNet baseModel;
		try {
			baseModel = DOMParser.parse(baseStream, "base model");
		} catch (final Exception e) {
			JOptionPane
			        .showMessageDialog(this, "Error loading base model!", "Error Loading", JOptionPane.ERROR_MESSAGE);
			return;
		}
		progressBar.setValue(++progress);

		log("Loading your model");
		try {
			petriNet = DOMParser.parse(new FileInputStream(model), model.getName().replaceAll("[.][cC][pP][nN]$", ""));
		} catch (final Exception e) {
			JOptionPane
			        .showMessageDialog(this, "Error loading your model!", "Error Loading", JOptionPane.ERROR_MESSAGE);
			return;
		}
		progressBar.setValue(++progress);

		log("Loading configuration file");
		try {
			suite = new ConfigurationTestSuite(configStream, "none");
		} catch (final Exception e) {
			JOptionPane.showMessageDialog(null, "Reading configuration file failed!\n" + e,
			        "Error loading configuration!", JOptionPane.ERROR_MESSAGE);
			return;
		}
		progressBar.setValue(++progress);

		tester = new Tester(suite, null, baseModel, new File(model.getParentFile(), "outputs"));
		tester.addObserver(this);
		progressBar.setValue(++progress);
	}

	public static void main(final String... args) {
		final InputStream baseStream = getResource("/base.cpn");
		if (baseStream == null) {
			JOptionPane
			        .showMessageDialog(
			                null,
			                "Could not find the base model.\n\nPlease contact your teacher and not\nthe author of this program for help..",
			                "Error", JOptionPane.ERROR_MESSAGE);
			System.exit(1);
		}
		final InputStream configStream = getResource("/config.cfg");
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
			final StudentTester studentTester = new StudentTester(baseStream, configStream, load.getSelectedFile());
			studentTester.setup();
			studentTester.runTest();
			studentTester.finish();
		} else {
			System.exit(0);
		}
	}

	private void finish() {
		log("Done!");

		boolean errors = false;
		for (final Report r : testResult) {
			for (final Entry<Grader, Message> entry : r.getReports()) {
				if (entry.getValue().getPoints() < entry.getKey().getMaxPoints()) {
					if (entry.getKey() instanceof BTLGrader) {
						this.errors.addElement(new TestError((BTLGrader) entry.getKey()));
						errors = true;
					}
				}
			}
		}
		errorPanel.setVisible(errors);

		progressBar.setValue(PROGRESS_MAX);
		progressBar.setVisible(false);
		cancelButton.setText("Quit");
		exportButton.setEnabled(true);
		pack();
	}

	private void runTest() {
		if (tester != null) {
			progressBar.setIndeterminate(true);
			try {
				testResult = tester.test(petriNet, model.getParentFile());
			} catch (final Exception e) {
				JOptionPane.showMessageDialog(null, "Grading failed with message: " + e, "Error",
				        JOptionPane.ERROR_MESSAGE);
			}

			for (final Report r : testResult) {
				log("Result: " + r.getResult());
				for (final Entry<Grader, Message> entry : r.getReports()) {
					log(entry.getValue().getPoints() + ": " + entry.getValue().getMessage());
				}
			}

			progressBar.setIndeterminate(false);
			progressBar.setValue(progress += 5);
		}
	}

	private static InputStream getResource(final String resource) {
		InputStream result = StudentTester.class.getResourceAsStream(resource);
		if (result != null) { return result; }
		result = StudentTester.class.getResourceAsStream("../../../.." + resource);
		if (result != null) { return result; }
		result = StudentTester.class.getResourceAsStream("../../../../.." + resource);
		if (result != null) { return result; }
		result = StudentTester.class.getResourceAsStream("../../../../../bin" + resource);
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
