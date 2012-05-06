package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
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
import org.cpntools.accesscpn.engine.highlevel.instance.Binding;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.accesscpn.model.importer.NetCheckException;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.btl.BTLGrader;
import org.cpntools.grader.model.btl.model.Guide;
import org.cpntools.grader.model.btl.model.Unconsumed;
import org.cpntools.grader.model.btl.parser.CupParser;
import org.cpntools.grader.tester.EnablingControl;
import org.cpntools.grader.tester.EnablingControlAdapterFactory;
import org.xml.sax.SAXException;

public class BTLTester extends JDialog {
	public static class Snapshot {

		private final String time;
		private final Binding be;
		private final Guide guide;

		public Snapshot(final String time, final Binding be, final Guide guide) {
			this.time = time;
			this.be = be;
			this.guide = guide;
		}

		public Guide getGuide() {
			return guide;
		}

		public Binding getBinding() {
			return be;
		}

		/**
		 * @return
		 */
		public String getTime() {
			return time;
		}

		@Override
		public String toString() {
			if (be == null) { return "<initial state>"; }
			return be.toString();
		}

	}

	private final PetriNet petriNet;
	private final JTextArea marking;
	private HighLevelSimulator simulator;
	Guide current = null;
	private final JTextArea currentFormula;
	private final JTextArea parsedFormula;
	final JTextArea initFormula;
	private final ModelInstance modelInstances;
	private final List<Instance<Transition>> allTransitionInstances;
	private final NameHelper nameHelper;
	private final EnablingControl ec;
	private final DefaultListModel disallowed;
	final DefaultListModel enabled;
	private final DefaultTableModel trace;

	public BTLTester(final File selectedFile) throws FileNotFoundException, NetCheckException, SAXException,
	        IOException, ParserConfigurationException {
		petriNet = DOMParser.parse(new FileInputStream(selectedFile),
		        selectedFile.getName().replaceFirst("[.][cC][pP][nN]$", ""));
		setTitle("BTL Tester - " + petriNet.getName().getText());
		setLayout(new BorderLayout());
		final JPanel buttons = new JPanel();
		buttons.setLayout(new FlowLayout(FlowLayout.CENTER));
		add(buttons, BorderLayout.SOUTH);
		final JButton checkButton = new JButton("Check");
		checkButton.setEnabled(false);
		buttons.add(checkButton);
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

		final JSplitPane top = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
		top.setResizeWeight(0.5);
		add(top, BorderLayout.CENTER);
		final JSplitPane main = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
		top.setLeftComponent(main);
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
		final JSplitPane rightTransitions = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
		rightTransitions.setTopComponent(transitionMappingScroller);
		top.setRightComponent(rightTransitions);
		rightTransitions.setResizeWeight(0.5);

		trace = new DefaultTableModel(new Object[] { "Time", "Binding Element" }, 0);
		final JTable traceTable = new JTable(trace);
		traceTable.setEnabled(false);
		final JScrollPane traceScroller = new JScrollPane(traceTable);
		traceScroller.setBorder(BorderFactory.createTitledBorder("Execution Trace"));
		rightTransitions.setBottomComponent(traceScroller);

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

		transitionList.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(final MouseEvent evt) {
				final JList list = (JList) evt.getSource();
				if (evt.getClickCount() == 2) { // Double-click
					final int index = list.locationToIndex(evt.getPoint());
					final String transitionName = ((String) transitionListModel.get(index)).toLowerCase().replaceAll(
					        "[^a-z0-9.]*", "");
					final int position = initFormula.getCaretPosition();
					final String oldText = initFormula.getText();
					initFormula.setText(oldText.substring(0, position) + transitionName + oldText.substring(position));
					initFormula.setCaretPosition(position + transitionName.length());
					initFormula.requestFocus();
				}
			}
		});

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
		enabled = new DefaultListModel();
		final JList enabledList = new JList(enabled);
		enabledList.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseClicked(final MouseEvent evt) {
				final JList list = (JList) evt.getSource();
				if (evt.getClickCount() == 2) { // Double-click
					final int index = list.locationToIndex(evt.getPoint());
					final Binding clicked = (Binding) enabled.get(index);
					execute(clicked);
				}
			}
		});
		final JScrollPane enabledScroller = new JScrollPane(enabledList);
		enabledScroller.setBorder(BorderFactory.createTitledBorder("Enabled Bindings"));
		transitions.add(enabledScroller);
		disallowed = new DefaultListModel();
		final JList disallowedList = new JList(disallowed);
		disallowedList.setEnabled(false);
		final JScrollPane disallowedScroller = new JScrollPane(disallowedList);
		disallowedScroller.setBorder(BorderFactory.createTitledBorder("Disallowed Transitions"));
		transitions.add(disallowedScroller);
		modelData.setRightComponent(transitions);

		modelInstances = (ModelInstance) ModelInstanceAdapterFactory.getInstance().adapt(petriNet, ModelInstance.class);
		allTransitionInstances = modelInstances.getModelData().getAllTransitionInstances();
		nameHelper = new NameHelper(petriNet);

		ec = (EnablingControl) EnablingControlAdapterFactory.getInstance().adapt(petriNet, EnablingControl.class);
		initializeTransitionList(transitionListModel);
		clearTrace();
		pack();
		setVisible(true);
		try {
			simulator = org.cpntools.grader.tester.Tester.checkModel(petriNet, selectedFile.getParentFile(),
			        selectedFile.getParentFile(), new StudentID("dummy"));
			refreshMarking();
			refreshEnabling();
		} catch (final Exception e) {
			marking.setText("Checking failed with " + e);
		}
	}

	protected void execute(final Binding be) {
		try {
			simulator.execute(be);
			if (current != null) {
				current = current.progress(be.getTransitionInstance(), petriNet, simulator, nameHelper);
			}
			addToTrace(simulator.getTime(), be, current);
			refreshMarking();
			refreshEnabling();
			refreshCurrent();
		} catch (final IOException e) {
			marking.setText("Execution failed with: " + e);
		} catch (final Unconsumed e) {
			e.printStackTrace();
		}

	}

	private void addToTrace(final String time, final Binding be, final Guide guide) {
		trace.addRow(new Object[] { time, new Snapshot(time, be, guide) });
	}

	@SuppressWarnings("unchecked")
	private void refreshEnabling() {
		try {
			final Set<Instance<Transition>> allowed = new HashSet<Instance<Transition>>();
			List<Instance<? extends Transition>> enabled;
			if (current != null) {
				enabled = BTLGrader.getEnabledAndAllowed(petriNet, simulator, nameHelper, allTransitionInstances, ec,
				        current, allowed);
			} else {
				enabled = BTLGrader.getEnabled(simulator, allTransitionInstances, ec);
				allowed.addAll((Collection<? extends Instance<Transition>>) enabled);
			}
			final SortedMap<String, Instance<? extends Transition>> sortedNames = new TreeMap<String, Instance<? extends Transition>>();
			for (final Instance<? extends Transition> ti : enabled) {
				Instance<? extends Transition> old = sortedNames.put(ti.toString(), ti);
				while (old != null) {
					old = sortedNames.put(old.toString() + "#", old);
				}
			}
			this.enabled.clear();
			disallowed.clear();
			for (final Instance<? extends Transition> ti : sortedNames.values()) {
				if (allowed.contains(ti)) {
					for (final Binding b : simulator.getBindings(ti)) {
						this.enabled.addElement(b);
					}
				} else {
					disallowed.addElement(ti);
				}
			}
		} catch (final IOException e) {
			e.printStackTrace();
		}

	}

	public void initializeTransitionList(final DefaultListModel transitionListModel) {
		final SortedSet<String> transitionNames = new TreeSet<String>();
		for (final Instance<Transition> ti : allTransitionInstances) {
			transitionNames.add(ti.toString());
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
		refreshEnabling();
		refreshCurrent();
	}

	void initial() {
		clearTrace();
		reparse();
		try {
			simulator.initialState();
		} catch (final IOException e) {
			marking.setText("Could not go to the initial state. " + e);
		}
		refresh();
	}

	private void clearTrace() {
		while (trace.getRowCount() > 0) {
			trace.removeRow(trace.getRowCount() - 1);
		}
		addToTrace("0", null, null);
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
