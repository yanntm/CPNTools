package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map.Entry;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.ListSelectionModel;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;

import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.tester.Report;

/**
 * @author michael
 */
public class ResultDialog extends JDialog implements Observer {
	private static final String ERRORS = "Errors";
	private static final String SCORE = "Score";
	private static final String STUDENT_ID = "StudentID";
	private static final String FILE = "File";
	/**
     * 
     */
	private static final long serialVersionUID = 1533651130078221593L;
	protected static final Color COLOR_ERROR = new Color(255, 127, 127);
	protected static final Color COLOR_WARN = new Color(255, 255, 127);
	protected static final Color COLOR_OK = new Color(127, 255, 127);
	private final DefaultTableModel tableModel;
	private final JTextArea log;

	public ResultDialog(final Observable o) {
		setTitle("Results");
		setLayout(new BorderLayout());
		log = new JTextArea();
		log.setEditable(false);
		tableModel = new DefaultTableModel(new Object[] { FILE, STUDENT_ID, SCORE, ERRORS }, 0);
		final JTable table = new JTable(tableModel);
		table.getColumn(ERRORS).setCellRenderer(new DefaultTableCellRenderer() {
			@Override
			public Component getTableCellRendererComponent(final JTable table, final Object errors,
			        final boolean isSelected, final boolean hasFocus, final int row, final int column) {
				if (errors instanceof List<?>) {
					final List<?> c = (List<?>) errors;
					final Component component = super.getTableCellRendererComponent(table, c.size(), isSelected,
					        hasFocus, row, column);
					if (c.isEmpty()) {
						component.setBackground(COLOR_OK);
					} else {
						component.setBackground(COLOR_ERROR);
					}
					component.setForeground(Color.BLACK);
					if (component instanceof JComponent) {
						final JComponent jcomponent = (JComponent) component;
						final StringBuilder sb = new StringBuilder();
						for (final Object o : c) {
							sb.append("\n");
							sb.append(o);
						}
						jcomponent.setToolTipText(sb.toString().trim());
					}
					return component;
				} else {
					final Component component = super.getTableCellRendererComponent(table, errors, isSelected,
					        hasFocus, row, column);
					component.setBackground(COLOR_WARN);
					component.setForeground(Color.BLACK);
					if (component instanceof JComponent) {
						final JComponent jcomponent = (JComponent) component;
						jcomponent.setToolTipText("Student has not submitted anything!");
					}
					return component;
				}
			}
		});
		table.getColumn(SCORE).setCellRenderer(new DefaultTableCellRenderer() {
			@Override
			public Component getTableCellRendererComponent(final JTable table, final Object o,
			        final boolean isSelected, final boolean hasFocus, final int row, final int column) {
				if (o instanceof Report) {
					final Report r = (Report) o;
					final Component component = super.getTableCellRendererComponent(table, r.getResult(), isSelected,
					        hasFocus, row, column);
					if (component instanceof JComponent) {
						final JComponent jcomponent = (JComponent) component;
						final StringBuilder sb = new StringBuilder();
						for (final Entry<Grader, Message> e : r.getReports()) {
							sb.append("\n");
							sb.append(e.getValue().getPoints());
							sb.append(": ");
							sb.append(e.getValue().getMessage());
						}
						jcomponent.setToolTipText(sb.toString().trim());
					}
					return component;
				} else {
					final Component component = super.getTableCellRendererComponent(table, o, isSelected, hasFocus,
					        row, column);
					if (component instanceof JComponent) {
						final JComponent jcomponent = (JComponent) component;
						jcomponent.setToolTipText("");
					}
					return component;
				}
			}
		});
		table.setAutoCreateRowSorter(true);
		table.setFillsViewportHeight(true);
		table.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		add(new JSplitPane(JSplitPane.VERTICAL_SPLIT, new JScrollPane(table), new JScrollPane(log)),
		        BorderLayout.CENTER);
		log.setMinimumSize(new Dimension(400, 150));
		table.setMinimumSize(new Dimension(400, 300));
		pack();
		o.addObserver(this);
		setVisible(true);
	}

	public void addReport(final File f, final Report r) {
		tableModel.addRow(new Object[] { f.getName(), r.getStudentId(), r, r.getErrors() });
	}

	public void addError(final StudentID s) {
		tableModel.addRow(new Object[] { "<none>", s, 0.0, 0 });
	}

	public void addError(final File f, final String error) {
		tableModel.addRow(new Object[] { f.getName(), "<none>", 0.0, Collections.singletonList(error) });
	}

	@Override
	public void update(final Observable arg0, final Object arg1) {
		if (arg1 instanceof String) {
			final String message = (String) arg1;
			log.append(message + "\n");
			log.setCaretPosition(log.getText().length());
		}

	}
}
