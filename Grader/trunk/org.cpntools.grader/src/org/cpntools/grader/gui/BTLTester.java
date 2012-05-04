package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.SortedSet;
import java.util.TreeSet;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.table.DefaultTableModel;
import javax.xml.parsers.ParserConfigurationException;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.accesscpn.model.importer.NetCheckException;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.btl.model.Guide;
import org.cpntools.grader.model.btl.parser.CupParser;
import org.cpntools.grader.tester.EnablingControl;
import org.cpntools.grader.tester.EnablingControlAdapterFactory;
import org.xml.sax.SAXException;

public class BTLTester extends JDialog {
	private final PetriNet petriNet;
	private final JTextArea marking;
	private HighLevelSimulator simulator;
	Guide current = null;
	private final JTextArea currentFormula;
	private final JTextArea parsedFormula;
	private final JTextArea initFormula;

	public BTLTester(final File selectedFile) throws FileNotFoundException, NetCheckException, SAXException,
	        IOException, ParserConfigurationException {
		petriNet = DOMParser.parse(new FileInputStream(selectedFile),
		        selectedFile.getName().replaceFirst("[.][cC][pP][nN]$", ""));
		setTitle("BTL Tester - " + petriNet.getName().getText());
		setLayout(new BorderLayout());
		final JPanel buttons = new JPanel();
		buttons.setLayout(new FlowLayout(FlowLayout.CENTER));
		add(buttons, BorderLayout.SOUTH);
		buttons.add(new JButton("Check"));
		final JButton refreshButton = new JButton("Refresh");
		refreshButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				refresh();
			}
		});
		buttons.add(refreshButton);
		final JButton initialButton = new JButton("Initial State");
		initialButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				initial();
			}
		});
		buttons.add(initialButton);

		final JSplitPane main = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
		add(main, BorderLayout.CENTER);
		final JPanel formulae = new JPanel();
		formulae.setLayout(new BoxLayout(formulae, BoxLayout.Y_AXIS));
		final JPanel formulaPanel = new JPanel(new BorderLayout());
		formulaPanel.add(formulae, BorderLayout.CENTER);
		final DefaultListModel transitionListModel = new DefaultListModel();
		final JList transitionList = new JList(transitionListModel);
		final JScrollPane transitionScroller = new JScrollPane(transitionList);
		transitionScroller.setBorder(BorderFactory.createTitledBorder("Transitions"));
		formulaPanel.add(transitionScroller, BorderLayout.EAST);
		final JSplitPane modelData = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
		main.setBottomComponent(formulaPanel);
		main.setTopComponent(modelData);
		main.setResizeWeight(0.5);
		modelData.setResizeWeight(0.5);

		final JScrollPane transitionMappingScroller = new JScrollPane(new JTable(new DefaultTableModel(new Object[] {
		        "ID", "Transition" }, 0)));
		transitionMappingScroller.setBorder(BorderFactory.createTitledBorder("Transition Mapping"));
		add(transitionMappingScroller, BorderLayout.EAST);

		initFormula = new JTextArea(3, 80);
		final JScrollPane initScroller = new JScrollPane(initFormula);
		initScroller.setBorder(BorderFactory.createTitledBorder("Initial Formula"));
		initFormula.setLineWrap(true);
		formulae.add(initScroller);
		parsedFormula = new JTextArea(3, 80);
		final JScrollPane parsedScroller = new JScrollPane(parsedFormula);
		parsedScroller.setBorder(BorderFactory.createTitledBorder("Parsed Formula"));
		parsedFormula.setLineWrap(true);
		parsedFormula.setEditable(false);
		formulae.add(parsedScroller);
		currentFormula = new JTextArea(3, 80);
		final JScrollPane currentScroller = new JScrollPane(currentFormula);
		currentScroller.setBorder(BorderFactory.createTitledBorder("Current Formula"));
		currentFormula.setLineWrap(true);
		formulae.add(currentScroller);

		marking = new JTextArea(10, 30);
		marking.setEditable(false);
		marking.setLineWrap(true);
		marking.setWrapStyleWord(true);
		marking.setText("Waiting for syntax check…");
		final JScrollPane markingScroller = new JScrollPane(marking);
		markingScroller.setBorder(BorderFactory.createTitledBorder("Current Marking"));
		modelData.setLeftComponent(markingScroller);

		final JPanel transitions = new JPanel();
		transitions.setLayout(new BoxLayout(transitions, BoxLayout.Y_AXIS));
		final JScrollPane enabledScroller = new JScrollPane(new JList());
		enabledScroller.setBorder(BorderFactory.createTitledBorder("Enabled Bindings"));
		transitions.add(enabledScroller);
		final JScrollPane disallowedScroller = new JScrollPane(new JList());
		disallowedScroller.setBorder(BorderFactory.createTitledBorder("Disallowed Transitions"));
		transitions.add(disallowedScroller);
		modelData.setRightComponent(transitions);

		initializeEnablingControl();
		initializeTransitionList(transitionListModel);
		pack();
		setVisible(true);
		try {
			simulator = org.cpntools.grader.tester.Tester.checkModel(petriNet, selectedFile.getParentFile(),
			        selectedFile.getParentFile(), new StudentID("dummy"));
			refreshMarking();
		} catch (final Exception e) {
			marking.setText("Checking failed with " + e);
		}
	}

	public void initializeTransitionList(final DefaultListModel transitionListModel) {
		final SortedSet<String> transitionNames = new TreeSet<String>();
		final ModelInstance modelInstances = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(petriNet,
		        ModelInstance.class);
		for (final Page p : petriNet.getPage()) {
			for (final Transition t : p.transition()) {
				for (final Instance<Transition> ti : modelInstances.getAllInstances(t)) {
					transitionNames.add(ti.toString());
				}
			}
		}
		for (final String name : transitionNames) {
			transitionListModel.addElement(name);
		}
	}

	public void initializeEnablingControl() {
		EnablingControlAdapterFactory.getInstance().adapt(petriNet, EnablingControl.class);
	}

	void refresh() {
		reparseCurrent();
		refreshMarking();
		refreshCurrent();
	}

	void initial() {
		reparse();
		try {
			simulator.initialState();
		} catch (final IOException e) {
			marking.setText("Could not go to the initial state. " + e);
		}
		refresh();
	}

	private void reparseCurrent() {
		try {
			current = CupParser.parse(currentFormula.getText());
		} catch (final Exception e) {
			currentFormula.setText("Could not parse current formula: " + e);
		}
	}

	private void refreshCurrent() {
		if (current == null) {
			currentFormula.setText("");
		} else {
			currentFormula.setText(current.toString());
		}
	}

	private void reparse() {
		try {
			final Guide parsed = CupParser.parse(initFormula.getText());
			parsedFormula.setText(parsed.toString());
			currentFormula.setText(parsed.toString());
		} catch (final Exception e) {
			parsedFormula.setText("Could not parse formula: " + e);
		}
	}

	void refreshMarking() {
		try {
			marking.setText(simulator.getMarking().toString()
			        .replaceAll(".*[.]Enabling_Control_[0-9]+: 1`..[\\r\\n]*", ""));
		} catch (final Exception e) {
			marking.setText("Failed getting marking; try hitting refresh or loading another model…");
		}
	}

	public static void main(final String... args) throws FileNotFoundException, NetCheckException, SAXException,
	        IOException, ParserConfigurationException {
		final JFileChooser load = new JFileChooser();
		final int result = load.showOpenDialog(null);
		if (result == JFileChooser.APPROVE_OPTION) {
			new BTLTester(load.getSelectedFile());
		}
	}
}
