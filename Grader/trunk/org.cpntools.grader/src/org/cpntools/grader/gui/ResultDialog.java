package org.cpntools.grader.gui;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
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

import org.cpntools.grader.model.Detail;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.signer.gui.FileChooser;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.utils.TextUtils;
import org.xhtmlrenderer.pdf.ITextRenderer;

import com.lowagie.text.DocumentException;

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
		tableModel = new DefaultTableModel(new Object[] { FILE, STUDENT_ID, SCORE, ERRORS }, 0) {
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
				final File directory = fileChooser.getSelected();
				try {
					final StringBuilder error = new StringBuilder();
					final ITextRenderer errorRenderer = new ITextRenderer();
					final ImageUserAgent errorAgent = new ImageUserAgent(errorRenderer.getOutputDevice());
					errorRenderer.getSharedContext().setUserAgentCallback(errorAgent);
					error.append("<html><head><title>Errors</title></head><body>");
					for (final int row : table.getSelectedRows()) {
						Report r;
						try {
							r = (Report) tableModel.getValueAt(row, 2);
						} catch (final ClassCastException _) {
							r = null;
						}
						StringBuilder writer = error;
						ITextRenderer renderer = errorRenderer;
						ImageUserAgent agent = errorAgent;
						if (r != null) {
							renderer = new ITextRenderer();
							agent = new ImageUserAgent(renderer.getOutputDevice());
							renderer.getSharedContext().setUserAgentCallback(agent);
							writer = new StringBuilder();

							writer.append("<html><head><title>Rating for ");
							writer.append(r.getStudentId().toString());
							writer.append("</title></head><body><h1>Rating for ");
							writer.append(r.getStudentId().toString());
							writer.append("</h1>");

							writer.append("<h3>File: ");
							writer.append("" + tableModel.getValueAt(row, 0));
							writer.append("</h3>");

							final StringBuilder details = new StringBuilder();
							writer.append("<h2>Points: ");
							writer.append(String.format("%.2f", r.getResult()));
							writer.append("</h2><table style=\"border-top: 3px solid black; border-bottom: 3px solid black\">");
							writer.append("<thead><tr><th>Point range</th><th>Points</th><th>Reason</th><th>Grader</th></tr></thead><tbody style=\"border-top: 2px solid black\">");
							boolean odd = true;
							int image = 0;
							for (final Entry<Grader, Message> e : r.getReports()) {
								writer.append("<tr");
								if (!odd) {
									writer.append(" style=\"background-color: #cfcfcf\"");
								}
								odd = !odd;
								writer.append("><td align=\"center\">");
								writer.append("" + e.getKey().getMinPoints());
								writer.append(" - " + e.getKey().getMaxPoints());
								writer.append("</td><td align=\"right\"><span style=\"color: ");
								if (e.getValue().getPoints() == e.getKey().getMinPoints()) {
									writer.append("red");
								} else if (e.getValue().getPoints() == e.getKey().getMaxPoints()) {
									writer.append("green");
								} else {
									writer.append("yellow");
								}
								writer.append("\">" + e.getValue().getPoints());
								writer.append("</span></td><td>");
								writer.append(TextUtils.stringToHTMLString(e.getValue().getMessage()));
								writer.append("</td><td><pre>");
								writer.append(TextUtils.stringToHTMLString(e.getKey().getClass().getSimpleName()));
								writer.append("</pre></td></tr>");

								for (final Detail d : e.getValue().getDetails()) {
									details.append("<h3>");
									details.append(d.getHeader());
									details.append(" - ");
									details.append(e.getKey().getClass().getCanonicalName());
									details.append("</h3>");
									details.append("<ul>");
									for (final String s : d.getStrings()) {
										details.append("<li>");
										details.append(TextUtils.stringToHTMLString(s).replaceAll("\n", "<br />"));
										details.append("</li>");
									}
									details.append("</ul>");
									if (d.getImage() != null) {
										final String name = "S" + r.getStudentId() + "_image" + image++ + ".png";
										try {
											agent.register(name, d.getImage());
											// ImageIO.write(d.getImage(), "png", new File(directory, name));
											details.append("<p><img width=\"100%\" src=\"");
											details.append(name);
											details.append("\" /></p>");
										} catch (final Exception _) {
											// Ignore
										}
									}
								}
							}
							writer.append("</tbody></table>");
							writer.append(details.toString());
						}

						final List<?> errors = (List<?>) tableModel.getValueAt(row, 3);
						if (errors != null && !errors.isEmpty()) {
							writer.append("<h2>Errors");
							if (r == null) {
								writer.append(" for ");
								writer.append("" + tableModel.getValueAt(row, 1));
								writer.append(" / " + tableModel.getValueAt(row, 0));
							}
							writer.append("</h2><table>");
							writer.append("<thead><tbody>");
							boolean odd = true;
							for (final Object e : errors) {
								writer.append("<tr");
								if (!odd) {
									writer.append(" bgcolor=\"#cfcfcf\"");
								}
								odd = !odd;
								writer.append("><td>");
								writer.append(TextUtils.stringToHTMLString("" + e));
								writer.append("</td></tr>");
							}
							writer.append("</tbody></table>");
						}

						if (writer != error) {
							writer.append("</body>");
							writer.append("</html>");
							renderer.setDocumentFromString(writer.toString());
							renderer.layout();
							final FileOutputStream os = new FileOutputStream(new File(directory, "S" + r.getStudentId()
							        + "_report.pdf"));
							try {
								renderer.createPDF(os);
							} catch (final DocumentException e) {
							}
							os.close();
						}
					}
					error.append("</body>");
					error.append("</html>");
					errorRenderer.setDocumentFromString(error.toString());
					errorRenderer.layout();
					final FileOutputStream os = new FileOutputStream(new File(directory, "errors.pdf"));
					try {
						errorRenderer.createPDF(os);
					} catch (final DocumentException e) {
					}
					os.close();
				} catch (final IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		});

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
		tableModel.addRow(new Object[] { "<none>", s, 0.0, Collections.singletonList("No model found for S" + s) });
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
