package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
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
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.table.DefaultTableModel;
import javax.xml.parsers.ParserConfigurationException;

import org.cpntools.accesscpn.engine.highlevel.HighLevelSimulator;
import org.cpntools.accesscpn.engine.highlevel.instance.Binding;
import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstance;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelInstanceAdapterFactory;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.SimulatorModelAdapterFactory;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.importer.DOMParser;
import org.cpntools.accesscpn.model.importer.NetCheckException;
import org.cpntools.grader.model.NameHelper;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.model.btl.BTLGrader;
import org.cpntools.grader.model.btl.CoverageMaximizer;
import org.cpntools.grader.model.btl.DecisionTree;
import org.cpntools.grader.model.btl.EmptyEnvironment;
import org.cpntools.grader.model.btl.NewTransitionStrategy;
import org.cpntools.grader.model.btl.Node;
import org.cpntools.grader.model.btl.RandomStrategy;
import org.cpntools.grader.model.btl.Strategy;
import org.cpntools.grader.model.btl.model.Failure;
import org.cpntools.grader.model.btl.model.Guide;
import org.cpntools.grader.model.btl.model.True;
import org.cpntools.grader.model.btl.model.Unconsumed;
import org.cpntools.grader.model.btl.parser.CupParser;
import org.cpntools.grader.tester.EnablingControl;
import org.cpntools.grader.tester.EnablingControlAdapterFactory;
import org.xml.sax.SAXException;

/**
 * @author michael
 */
public class BTLTester extends JFrame {
	public static class Snapshot {

		private final Binding be;
		private final Guide guide;
		private final String time;

		public Snapshot(final String time, final Binding be, final Guide guide) {
			this.time = time;
			this.be = be;
			this.guide = guide;
		}

		public Binding getBinding() {
			return be;
		}

		public Guide getGuide() {
			return guide;
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

	private static final Color MAYBE = new Color(247, 255, 119);
	private static final Color NO = new Color(255, 151, 148);
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final Color YES = new Color(144, 255, 176);

	public static void main(final String... args) throws FileNotFoundException, NetCheckException, SAXException,
	        IOException, ParserConfigurationException {
		System.setProperty("apple.laf.useScreenMenuBar", "true");
		System.setProperty("com.apple.mrj.application.apple.menu.about.name", "BTL Tester");
		final JFileChooser load = new JFileChooser();
		final int result = load.showOpenDialog(null);
		if (result == JFileChooser.APPROVE_OPTION) {
			new BTLTester(load.getSelectedFile());
		} else {
			System.exit(0);
		}
	}

	private final List<Instance<Transition>> allTransitionInstances;
	private final JTextArea currentFormula;
	private final JTextArea decision;
	private final DefaultListModel disallowed;
	private final EnablingControl ec;
	private Guide init;
	private final DefaultTableModel mapping;
	private final JTextArea marking;
	private final ModelInstance modelInstances;
	private final NameHelper nameHelper;
	private final JTextArea parsedFormula;
	private final PetriNet petriNet;
	private int runs = 0;
	private final JLabel runsLabel;
	private HighLevelSimulator simulator;
	private final JComboBox strategy;
	private final DefaultTableModel trace;
	Guide current = null;
	DecisionTree<Instance<Transition>> decisionTree = new DecisionTree<Instance<Transition>>();
	final DefaultListModel enabled;

	final JTextArea initFormula;

	public BTLTester(final File selectedFile) throws FileNotFoundException, NetCheckException, SAXException,
	        IOException, ParserConfigurationException {
		this(DOMParser.parse(new FileInputStream(selectedFile),
		        selectedFile.getName().replaceFirst("[.][cC][pP][nN]$", "")), selectedFile.getParentFile(), false, null);
	}

	public BTLTester(final PetriNet net, final File parentFile, final boolean light, JFrame parent) throws FileNotFoundException,
	        NetCheckException, SAXException, IOException, ParserConfigurationException {
		petriNet = net;
		addWindowListener(new BasicWindowMonitor(parent));
		setTitle("BTL Tester - " + petriNet.getName().getText());
		setLayout(new BorderLayout());
		final JPanel buttons = new JPanel();
		buttons.setLayout(new FlowLayout(FlowLayout.CENTER));
		add(buttons, BorderLayout.SOUTH);
		runsLabel = new JLabel("Runs: 0");
		buttons.add(runsLabel);
		strategy = new JComboBox(new Object[] { new RandomStrategy<Instance<Transition>>(),
		        new CoverageMaximizer<Instance<Transition>>(), new NewTransitionStrategy<Instance<Transition>>() });
		buttons.add(strategy);
		final JButton resetButton = new JButton("Reset");
		resetButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				decisionTree = new DecisionTree<Instance<Transition>>();
				runs = 0;
				refreshDecision();
			}
		});
		buttons.add(resetButton);
		final JTextField runsField = new JTextField("1");
		runsField.setMinimumSize(new Dimension(40, 10));
		buttons.add(runsField);
		final JButton checkButton = new JButton("Check");
		checkButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				for (int i = Integer.parseInt(runsField.getText()); i > 0; i--) {
					check();
				}
			}
		});
		checkButton.setEnabled(false);
		buttons.add(checkButton);
		final JButton refreshButton = new JButton("Refresh");
		refreshButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				refresh();
			}
		});
		refreshButton.setEnabled(false);
		if (!light) {
			buttons.add(refreshButton);
		}
		final JButton initialButton = new JButton("Initial State");
		initialButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				initial();
			}
		});
		initialButton.setEnabled(false);
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
		if (!light) {
			formulaPanel.add(transitionScroller, BorderLayout.EAST);
		}
		final JSplitPane modelData = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
		main.setBottomComponent(formulaPanel);
		main.setTopComponent(modelData);
		main.setResizeWeight(0.5);
		modelData.setResizeWeight(0.5);

		mapping = new DefaultTableModel(new Object[] { "ID", "Transition" }, 0);
		final JScrollPane transitionMappingScroller = new JScrollPane(new JTable(mapping));
		transitionMappingScroller.setBorder(BorderFactory.createTitledBorder("Transition Mapping"));
		final JSplitPane rightTransitions = new JSplitPane(JSplitPane.VERTICAL_SPLIT);
		rightTransitions.setTopComponent(transitionMappingScroller);
		if (!light) {
			top.setRightComponent(rightTransitions);
		}
		rightTransitions.setResizeWeight(0.5);

		trace = new DefaultTableModel(new Object[] { "Time", "Binding Element" }, 0);
		final JTable traceTable = new JTable(trace);
		traceTable.setEnabled(false);
		traceTable.setRowSelectionAllowed(true);
		final JScrollPane traceScroller = new JScrollPane(traceTable);
		traceScroller.setBorder(BorderFactory.createTitledBorder("Execution Trace"));
		if (!light) {
			rightTransitions.setBottomComponent(traceScroller);
		} else {
			top.setRightComponent(traceScroller);
		}

		initFormula = new JTextArea(3, 80);
		final JScrollPane initScroller = new JScrollPane(initFormula);
		initScroller.setBorder(BorderFactory.createTitledBorder("Initial Formula"));
		initFormula.setLineWrap(true);
		if (!light) {
			formulae.add(initScroller);
		}
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
		decision = new JTextArea(3, 80);
		final JScrollPane decisionScroller = new JScrollPane(decision);
		decisionScroller.setBorder(BorderFactory.createTitledBorder("Descision Tree"));
		decision.setLineWrap(true);
		formulae.add(decisionScroller);

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
		marking.setText("Waiting for syntax check...");
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
			if (light) {
				simulator = (HighLevelSimulator) SimulatorModelAdapterFactory.getInstance().adapt(petriNet,
				        HighLevelSimulator.class);
			} else {
				simulator = org.cpntools.grader.tester.Tester.checkModel(petriNet, parentFile, parentFile,
				        new StudentID("dummy"));
			}
			checkButton.setEnabled(true);
			initialButton.setEnabled(true);
			refreshButton.setEnabled(true);
			initial();
			parsedFormula.setText("");
		} catch (final Exception e) {
			marking.setText("Checking failed with " + e);
		}
	}

	public BTLTester(final PetriNet net, final File parentFile, final Guide g, JFrame parent) throws FileNotFoundException,
	        NetCheckException, SAXException, IOException, ParserConfigurationException {
		this(net, parentFile, true, parent);
		setFormula(g);
		initial();
	}

	public void initializeEnablingControl() {
		EnablingControlAdapterFactory.getInstance().adapt(petriNet, EnablingControl.class);
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

	public void setFormula(final Guide g) {
		initFormula.setText("");
		init = g;
		current = g;
	}

	private void addToTrace(final String time, final Binding be, final Guide guide) {
		trace.addRow(new Object[] { time, new Snapshot(time, be, guide) });
	}

	private void clearTrace() {
		while (trace.getRowCount() > 0) {
			trace.removeRow(trace.getRowCount() - 1);
		}
	}

	private void refreshCurrent() {
		if (current == null) {
			currentFormula.setText("");
		} else {
			currentFormula.setText(current.toString());
		}
	}

	@SuppressWarnings("unchecked")
	private void refreshEnabling() {
		try {
			final Set<Instance<Transition>> allowed = new HashSet<Instance<Transition>>();
			List<Instance<Transition>> enabled;
			if (current != null && current != True.INSTANCE) {
				enabled = BTLGrader.getEnabledAndAllowed(petriNet, simulator, nameHelper, allTransitionInstances, ec,
				        current, allowed);
			} else {
				enabled = BTLGrader.getEnabled(simulator, allTransitionInstances, ec);
				allowed.addAll(enabled);
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

	private void refreshMapping(final Guide parsed) {
		if (parsed != null) {
			while (mapping.getRowCount() > 0) {
				mapping.removeRow(mapping.getRowCount() - 1);
			}
			for (final String ap : new TreeSet<String>(parsed.getAtomic())) {
				mapping.addRow(new Object[] { ap, nameHelper.getTransitionInstance(ap) });
			}
		}
	}

	private void reparse() {
		try {
			currentFormula.setBackground(Color.WHITE);
			if (init == null) {
				final Guide parsed = CupParser.parse(initFormula.getText());
				parsedFormula.setText(parsed.toString());
				currentFormula.setText(parsed.toString());
				current = parsed;
			} else {
				parsedFormula.setText(init.toString());
				currentFormula.setText(init.toString());
				current = init;
			}
			refreshMapping(current);
		} catch (final Exception e) {
			parsedFormula.setText("Could not parse formula: " + e);
		}
	}

	private void reparseCurrent() {
		try {
			current = CupParser.parse(currentFormula.getText());
		} catch (final Exception e) {
			currentFormula.setText("Could not parse current formula: " + e);
		}
	}

	private void setColor(final JComponent component, double p) {
		if (p < 0.5) {
			component.setBackground(new Color((int) ((1 - 2 * p) * BTLTester.NO.getRed() + 2 * p
			        * BTLTester.MAYBE.getRed()), (int) ((1 - 2 * p) * BTLTester.NO.getGreen() + 2 * p
			        * BTLTester.MAYBE.getGreen()), (int) ((1 - 2 * p) * BTLTester.NO.getBlue() + 2 * p
			        * BTLTester.MAYBE.getBlue())));
		} else {
			p = p - 0.5;
			component.setBackground(new Color((int) ((1 - 2 * p) * BTLTester.MAYBE.getRed() + 2 * p
			        * BTLTester.YES.getRed()), (int) ((1 - 2 * p) * BTLTester.MAYBE.getGreen() + 2 * p
			        * BTLTester.YES.getGreen()), (int) ((1 - 2 * p) * BTLTester.MAYBE.getBlue() + 2 * p
			        * BTLTester.YES.getBlue())));

		}

	}

	protected void check() {
		
		initial();
		runs++;

		@SuppressWarnings({ "unchecked", "hiding" })
		final Strategy<Instance<Transition>> strategy = (Strategy<Instance<Transition>>) this.strategy
		        .getSelectedItem();
		Node<Instance<Transition>> node = decisionTree.getRoot();

		currentFormula.setBackground(BTLTester.MAYBE);
		for (int i = 0; i < 25000 && current != null; i++) {
			try {
				final Set<Instance<Transition>> allowed = new HashSet<Instance<Transition>>();
				BTLGrader.getEnabledAndAllowed(petriNet, simulator, nameHelper, allTransitionInstances, ec, current,
				        allowed);
				if (allowed.isEmpty()) {
					if (current.canTerminate(petriNet, simulator, nameHelper, EmptyEnvironment.INSTANCE)) {
						boolean stillHolds = true;
						try {
							current = current.progress(null, petriNet, simulator, nameHelper, EmptyEnvironment.INSTANCE);
							if (current == Failure.INSTANCE) {
								stillHolds = false;
							}
						} catch (Exception e) {
							// do nothing
						}
						if (stillHolds) {
							node.validate();
							refreshFormula(true);
						} else {
							node.invalidate();
							refreshFormula(false);
						}
						refreshDecision();
					} else {
						node.invalidate();
						refreshFormula(false);
						refreshDecision();
					}
					break;
				} else {
					for (final Instance<Transition> ti : allowed) {
						decisionTree.addChild(node, ti);
					}
					final Binding binding = simulator.executeAndGet(strategy.getOne(decisionTree, node,
					        new ArrayList<Instance<Transition>>(allowed)));
					node = decisionTree.addChild(node, binding.getTransitionInstance());
					current = current.progress(binding.getTransitionInstance(), petriNet, simulator, nameHelper,
					        EmptyEnvironment.INSTANCE);
					addToTrace(simulator.getTime(), binding, current);
					if (current == Failure.INSTANCE) {
						node.invalidate();
						refreshFormula(false);
						refreshDecision();
					} else if (current == null) {
						node.validate();
						refreshFormula(true);
						refreshDecision();
					}
				}
			} catch (final Exception e) {
				currentFormula.setText("Checking failed with: " + e);
			}
		}
		refreshMarking();
		refreshEnabling();
		refreshCurrent();
	}

	protected void execute(final Binding be) {
		try {
			simulator.execute(be);
			if (current != null) {
				current = current.progress(be.getTransitionInstance(), petriNet, simulator, nameHelper,
				        EmptyEnvironment.INSTANCE);
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

	protected void refreshFormula(boolean satisfied) {
		setColor(currentFormula, ((satisfied) ? 1.0 : 0.0));
	}
	
	protected void refreshDecision() {
		setColor(decision, decisionTree.getCoverage());
		decision.setText(decisionTree.toString());
		decision.setCaretPosition(0);
		runsLabel.setText("Runs: " + runs);
	}

	void initial() {
		
		clearTrace();
		reparse();
		try {
			simulator.initialState();
			if (current != null) current.prestep(petriNet, simulator, nameHelper, EmptyEnvironment.INSTANCE);
			simulator.evaluate("CPN'Sim.init_all()");
			addToTrace(simulator.getTime(), null, current);
		} catch (final IOException e) {
			marking.setText("Could not go to the initial state. " + e);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		refresh();
	}

	void refresh() {
		reparseCurrent();
		refreshEnabling();
		refreshMarking();
		refreshCurrent();
	}

	void refreshMarking() {
		try {
			marking.setText(simulator.getMarking().toString()
			        .replaceAll(".*[.]Enabling_Control_[0-9]+: 1`..[\\r\\n]*", ""));
		} catch (final Exception e) {
			marking.setText("Failed getting marking; try hitting refresh or loading another model...");
		}
	}
}
