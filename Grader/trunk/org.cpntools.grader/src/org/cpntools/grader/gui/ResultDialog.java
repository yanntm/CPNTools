package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Map.Entry;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTable;
import javax.swing.JTextArea;
import javax.swing.ListSelectionModel;
import javax.swing.SwingConstants;
import javax.swing.WindowConstants;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.DefaultTableModel;

import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.signer.gui.FileChooser;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.utils.TextUtils;

/**
 * @author michael
 */
public class ResultDialog extends JPanel implements Observer {
	private static final String ERRORS = "Errors";
	private static final String FILE = "File";
	private static final String SCORE = "Points | Deductions";
	/**
     * 
     */
	private static final long serialVersionUID = 1533651130078221593L;
	private static final String STUDENT_ID = "StudentID";
	protected static final Color COLOR_ERROR = new Color(255, 127, 127);
	protected static final Color COLOR_OK = new Color(127, 255, 127);
	protected static final Color COLOR_WARN = new Color(255, 255, 127);
	static final Color ERROR_DARKER = ResultDialog.COLOR_ERROR.darker();
	static final Color OK_DARKER = ResultDialog.COLOR_OK.darker();
	static final Color WARN_DARKER = ResultDialog.COLOR_WARN.darker();
	private final JTextArea log;
	private JProgressBar progressBar;
	private final DefaultTableModel tableModel;
	JPanel cancelArea;
	boolean cancelled = false;
	
	private File reportDirectory;

	public ResultDialog(final Observable o, final int count, final File reportDirectoy) {

		this.reportDirectory = reportDirectoy;
		this.reportDirectory.mkdirs();
		
		setLayout(new BorderLayout());
		
		log = new JTextArea();
		log.setEditable(false);
		tableModel = new DefaultTableModel(new Object[] { ResultDialog.FILE, ResultDialog.STUDENT_ID,
		        ResultDialog.SCORE, ResultDialog.ERRORS }, 0) {
			/**
             * 
             */
			private static final long serialVersionUID = 1L;

			@Override
			public boolean isCellEditable(final int rot, final int col) {
				return false;
			}
		};
		final JTable table = new JTable(tableModel);
		table.getColumn(ResultDialog.ERRORS).setCellRenderer(new DefaultTableCellRenderer() {
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
						component.setBackground(isSelected ? ResultDialog.OK_DARKER : ResultDialog.COLOR_OK);
					} else {
						component.setBackground(isSelected ? ResultDialog.ERROR_DARKER : ResultDialog.COLOR_ERROR);
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
								sb.append(" color=\"#9f9f7f\"");
							}
							sb.append("><td>");
							sb.append(TextUtils.stringToHTMLString("" + o));
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
					component.setBackground(isSelected ? ResultDialog.WARN_DARKER : ResultDialog.COLOR_WARN);
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
		table.getColumn(ResultDialog.SCORE).setCellRenderer(new DefaultTableCellRenderer() {
			/**
             * 
             */
			private static final long serialVersionUID = -2292823405484419642L;

			@Override
			public Component getTableCellRendererComponent(final JTable table, final Object o,
			        final boolean isSelected, final boolean hasFocus, final int row, final int column) {
				if (o instanceof Report) {
					final Report r = (Report) o;
					final Component component = super.getTableCellRendererComponent(table, r.getPoints()+" / "+r.getDeductions(), isSelected,
					        hasFocus, row, column);
					if (r.getDeductions() < 0) {
						component.setBackground(isSelected ? ResultDialog.ERROR_DARKER : ResultDialog.COLOR_ERROR);
						component.setForeground(Color.BLACK);
					} else if (r.getPoints() > 0) {
						component.setBackground(isSelected ? ResultDialog.OK_DARKER : ResultDialog.COLOR_OK);
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
							sb.append(TextUtils.stringToHTMLString(e.getValue().getMessage()));
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
					component.setBackground(isSelected ? ResultDialog.WARN_DARKER : ResultDialog.COLOR_WARN);
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
		table.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);

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
		final JPanel mainArea = new JPanel();
		mainArea.setLayout(new BorderLayout());
		mainArea.add(new JSplitPane(JSplitPane.VERTICAL_SPLIT, new JScrollPane(table), logArea), BorderLayout.CENTER);
		add(mainArea, BorderLayout.CENTER);

		final JPanel buttons = new JPanel(new FlowLayout(FlowLayout.CENTER));
		mainArea.add(buttons, BorderLayout.SOUTH);
		final JButton export = new JButton("Export...");
		buttons.add(export);
		export.addActionListener(new ActionListener() {
			@Override
			public void actionPerformed(final ActionEvent arg0) {
				final FileChooser fileChooser = new FileChooser("Output directory", true, false);
				fileChooser.openDialog();
				File directory = fileChooser.getSelected();
				if (directory.isFile()) {
					directory = directory.getParentFile();
				}
				final Collection<PDFExport.ReportItem> reports = new ArrayList<PDFExport.ReportItem>();
				for (final int row : table.getSelectedRows()) {
					try {
						reports.add(new PDFExport.ReportItem((Report) tableModel.getValueAt(row, 2), tableModel
						        .getValueAt(row, 1), tableModel.getValueAt(row, 0), (List<?>) tableModel.getValueAt(
						        row, 3), null));
					} catch (final ClassCastException _) {
						reports.add(new PDFExport.ReportItem(null, tableModel.getValueAt(row, 1), tableModel
						        .getValueAt(row, 0), (List<?>) tableModel.getValueAt(row, 3), tableModel.getValueAt(
						        row, 2)));
					}
				}

				try {
					PDFExport.exportReports(directory, reports);
				} catch (final IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});

		//pack();
		o.addObserver(this);
		setVisible(true);
	}

	public synchronized void addError(final File f, final String error) {
		tableModel.addRow(new Object[] { f.getName(), "<none>", 0.0, Collections.singletonList(error) });
		writeReport( f.getName(), null, new StudentID("<none>"), Collections.singletonList(error), 0.0, 0.0);
	}

	public synchronized void addError(final StudentID s) {
		tableModel.addRow(new Object[] { "<none>", s, 0.0, Collections.singletonList("No model found for S" + s) });
		writeReport("<none>", null, s, Collections.singletonList("No model found for " + s), 0.0, 0.0);
	}

	public synchronized void addReport(final File f, final Report r) {
		tableModel.addRow(new Object[] { f.getName(), r.getStudentId(), r, r.getErrors() });
		writeReport(f.getName(), r, r.getStudentId(), r.getErrors(), r.getPoints(), r.getDeductions());
	}

	public synchronized void writeReport(final String fileName, final Report r, final StudentID studentID, final List<String> errors, final double points, final double deductions) {
		
		PDFExport.ReportItem report;
		try {
			// file, id, score, errors
			report = new PDFExport.ReportItem(r, studentID, fileName, errors, null);
		} catch (final ClassCastException _) {
			report = new PDFExport.ReportItem(null, studentID, fileName, errors, points+" | "+deductions);
		}
		
		List<PDFExport.ReportItem> reports = new LinkedList<PDFExport.ReportItem>();
		reports.add(report);
		
		try {
			PDFExport.exportReports(reportDirectory, reports);
			CSVExport.appendCSVLine(reportDirectory, r);
		} catch (FileNotFoundException e) {
			System.err.println("Could not find report directory!\n"+e);
			e.printStackTrace();
		} catch (IOException e) {
			System.err.println("Could not write report!\n"+e);
			e.printStackTrace();
		}
	}
	
	public boolean isCancelled() {
		return cancelled;
	}

	public synchronized void setProgress(final int progress) {
		progressBar.setValue(progress);
		if (progressBar.getValue() == progressBar.getMaximum()) {
			cancelArea.setVisible(false);
		}
	}

	@Override
	public synchronized void update(final Observable arg0, final Object arg1) {
		if (arg1 instanceof String) {
			final String message = (String) arg1;
			log.append(message + "\n");
			log.setCaretPosition(log.getText().length());
		}

	}
}
