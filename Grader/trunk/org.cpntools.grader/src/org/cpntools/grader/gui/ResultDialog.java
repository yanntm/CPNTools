package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map.Entry;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.ListSelectionModel;
import javax.swing.SwingConstants;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;

import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.utils.TextUtils;

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
	static final Color ERROR_DARKER = COLOR_ERROR.darker();
	protected static final Color COLOR_WARN = new Color(255, 255, 127);
	static final Color WARN_DARKER = COLOR_WARN.darker();
	protected static final Color COLOR_OK = new Color(127, 255, 127);
	static final Color OK_DARKER = COLOR_OK.darker();
	private final DefaultTableModel tableModel;
	private final JTextArea log;
	private JProgressBar progressBar;
	boolean cancelled = false;
	JPanel cancelArea;

	public ResultDialog(final Observable o, final int count) {
		setTitle("Results");
		setLayout(new BorderLayout());
		log = new JTextArea();
		log.setEditable(false);
		tableModel = new DefaultTableModel(new Object[] { FILE, STUDENT_ID, SCORE, ERRORS }, 0);
		final JTable table = new JTable(tableModel);
		table.getColumn(ERRORS).setCellRenderer(new DefaultTableCellRenderer() {
			/**
             * 
             */
			private static final long serialVersionUID = 1400957256710108015L;

			@Override
			public Component getTableCellRendererComponent(final JTable table, final Object errors,
			        final boolean isSelected, final boolean hasFocus, final int row, final int column) {
				if (errors instanceof List<?>) {
					final List<?> c = (List<?>) errors;
					final Component component = super.getTableCellRendererComponent(table, c.size(), isSelected,
					        hasFocus, row, column);
					if (c.isEmpty()) {
						component.setBackground(isSelected ? OK_DARKER : COLOR_OK);
					} else {
						component.setBackground(isSelected ? ERROR_DARKER : COLOR_ERROR);
					}
					component.setForeground(Color.BLACK);
					if (component instanceof JComponent) {
						if (component instanceof JLabel) {
							final JLabel label = (JLabel) component;
							label.setHorizontalAlignment(SwingConstants.RIGHT);
						}
						final JComponent jcomponent = (JComponent) component;
						final StringBuilder sb = new StringBuilder();
						sb.append("<html><table><tbody>");
						final boolean odd = true;
						for (final Object o : c) {
							sb.append("<tr");
							if (!odd) {
								sb.append(" bgcolor=\"#9f9f7f\"");
							}
							sb.append("><td>");
							sb.append(TextUtils.stringToHTMLString(o.toString()));
							sb.append("</td></tr>");
						}
						sb.append("</tbody></table></html>");
						if (!c.isEmpty()) {
							jcomponent.setToolTipText(sb.toString());
						} else {
							jcomponent.setToolTipText("");
						}
					}
					return component;
				} else {
					final Component component = super.getTableCellRendererComponent(table, errors, isSelected,
					        hasFocus, row, column);
					component.setBackground(isSelected ? WARN_DARKER : COLOR_WARN);
					component.setForeground(Color.BLACK);
					if (component instanceof JComponent) {
						final JComponent jcomponent = (JComponent) component;
						if (component instanceof JLabel) {
							final JLabel label = (JLabel) component;
							label.setHorizontalAlignment(SwingConstants.RIGHT);
						}
						jcomponent
						        .setToolTipText("<html><table><tbody><tr><td>Student has not submitted anything!</td></tr></tbody></table></html>");
					}
					return component;
				}
			}
		});
		table.getColumn(SCORE).setCellRenderer(new DefaultTableCellRenderer() {
			/**
             * 
             */
			private static final long serialVersionUID = -2292823405484419642L;

			@Override
			public Component getTableCellRendererComponent(final JTable table, final Object o,
			        final boolean isSelected, final boolean hasFocus, final int row, final int column) {
				if (o instanceof Report) {
					final Report r = (Report) o;
					final Component component = super.getTableCellRendererComponent(table, r.getResult(), isSelected,
					        hasFocus, row, column);
					if (r.getResult() < 0) {
						component.setBackground(isSelected ? ERROR_DARKER : COLOR_ERROR);
						component.setForeground(Color.BLACK);
					} else if (r.getResult() > 0) {
						component.setBackground(isSelected ? OK_DARKER : COLOR_OK);
						component.setForeground(Color.BLACK);
					} else if (!isSelected) {
						component.setBackground(Color.WHITE);
					}
					if (component instanceof JComponent) {
						if (component instanceof JLabel) {
							final JLabel label = (JLabel) component;
							label.setHorizontalAlignment(SwingConstants.RIGHT);
						}
						final JComponent jcomponent = (JComponent) component;
						final StringBuilder sb = new StringBuilder();
						sb.append("<html><table><thead><tr><th>Points</th><th>Reason</th></tr></thead><tbody>");
						boolean nonEmpty = false;
						boolean odd = true;
						for (final Entry<Grader, Message> e : r.getReports()) {
							sb.append("<tr");
							if (!odd) {
								sb.append(" bgcolor=\"#9f9f7f\"");
							}
							odd = !odd;
							sb.append("><td align=\"right\">");
							sb.append(e.getValue().getPoints());
							sb.append("</td><td>");
							sb.append(e.getValue().getMessage());
							sb.append("</td></tr>");
							nonEmpty = true;
						}
						sb.append("</tbody></table></html>");
						if (nonEmpty) {
							jcomponent.setToolTipText(sb.toString().trim());
						} else {
							jcomponent.setToolTipText("");
						}
					}
					return component;
				} else {
					final Component component = super.getTableCellRendererComponent(table, o, isSelected, hasFocus,
					        row, column);
					component.setBackground(isSelected ? WARN_DARKER : COLOR_WARN);
					component.setForeground(Color.BLACK);
					if (component instanceof JComponent) {
						if (component instanceof JLabel) {
							final JLabel label = (JLabel) component;
							label.setHorizontalAlignment(SwingConstants.RIGHT);
						}
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

		final JPanel logArea = new JPanel(new BorderLayout());
		logArea.add(new JScrollPane(log));
		progressBar = new JProgressBar(0, count);
		progressBar.setStringPainted(true);
		cancelArea = new JPanel(new BorderLayout());
		logArea.add(cancelArea, BorderLayout.SOUTH);
		cancelArea.add(progressBar);
		final JButton cancelButton = new JButton("Cancel");
		cancelButton.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				cancelArea.setVisible(false);
				cancelled = true;
			}
		});
		cancelArea.add(cancelButton, BorderLayout.EAST);
		logArea.setMinimumSize(new Dimension(600, 150));
		table.setMinimumSize(new Dimension(600, 300));
		add(new JSplitPane(JSplitPane.VERTICAL_SPLIT, new JScrollPane(table), logArea), BorderLayout.CENTER);
		pack();
		o.addObserver(this);
		setVisible(true);
	}

	public void setProgress(final int progress) {
		progressBar.setValue(progress);
		if (progressBar.getValue() == progressBar.getMaximum()) {
			cancelArea.setVisible(false);
		}
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

	public boolean isCancelled() {
		return cancelled;
	}
}
