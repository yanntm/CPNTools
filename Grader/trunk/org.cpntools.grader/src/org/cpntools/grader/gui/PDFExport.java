package org.cpntools.grader.gui;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.Map.Entry;

import org.cpntools.grader.model.Detail;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.tester.Report;
import org.cpntools.grader.utils.TextUtils;
import org.xhtmlrenderer.pdf.ITextRenderer;

import com.lowagie.text.DocumentException;

/**
 * @author michael
 */
public class PDFExport {

	public static class ReportItem {

		private final Object errorMsg;
		private final List<?> errors;
		private final Object file;
		private final Report report;
		private final Object student;

		public ReportItem(final Report report, final Object student, final Object file, final List<?> errors,
		        final Object errorMsg) {
			this.report = report;
			this.student = student;
			this.file = file;
			this.errors = errors;
			this.errorMsg = errorMsg;
		}

		public Object getErrorMsg() {
			return errorMsg;
		}

		public List<?> getErrors() {
			return errors;
		}

		public Object getFile() {
			return file;
		}

		public Report getReport() {
			return report;
		}

		public Object getStudent() {
			return student;
		}

	}

	public static void exportReports(final File directory, final Collection<ReportItem> reports)
	        throws FileNotFoundException, IOException {
		final ITextRenderer errorRenderer = new ITextRenderer();
		final ImageUserAgent errorAgent = new ImageUserAgent(errorRenderer.getOutputDevice());
		errorRenderer.getSharedContext().setUserAgentCallback(errorAgent);
		for (final ReportItem ri : reports) {

			String reportNamePrefix;
			if (ri.getFile() != null && ri.getFile() instanceof File) {
				reportNamePrefix = ((File)ri.getFile()).getName();
			} else {
				reportNamePrefix = "ID" + ri.getStudent().toString();
			}
			
			final StringBuilder error = new StringBuilder();
			error.append("<html><head><title>Errors</title><style type=\"text/css\">tr.topBorder td, tr.topBorder th { border-top: 1px solid black; }</style></head><body>");
			
			final Report r = ri.getReport();
			StringBuilder writer = error;
			ITextRenderer renderer = errorRenderer;
			ImageUserAgent agent = errorAgent;
			final StringBuilder details = new StringBuilder();
			if (r != null) {
				renderer = new ITextRenderer();
				agent = new ImageUserAgent(renderer.getOutputDevice());
				renderer.getSharedContext().setUserAgentCallback(agent);
				writer = new StringBuilder();

				writer.append("<html><head><title>Rating for ");
				writer.append(r.getStudentId().toString());
				writer.append("</title><style type=\"text/css\">table { border-collapse: collapse; }\nth, td { padding-left: 3px; padding-right: 3px; }\ntr.topBorder td, tr.topBorder th { border-top: 1px solid black; }</style></head><body><h1>Rating for ");
				writer.append(r.getStudentId().toString());
				writer.append("</h1>");

				writer.append("<h3>File: ");
				writer.append("" + ri.getFile());
				writer.append("</h3>");

				writer.append("<h2>");
				writer.append("Points: "+String.format("%.2f = %.2f + %.2f", (r.getPoints()+r.getDeductions()), r.getPoints(), r.getDeductions()) );
				writer.append("</h2><table style=\"border-top: 3px solid black; border-bottom: 3px solid black\">");
				writer.append("<thead><tr><th>Point range</th><th>Points</th><th>Reason</th><th>Grader</th></tr></thead><tbody style=\"border-top: 2px solid black\">");
				boolean odd = false;
				int image = 0;
				boolean first = true;
				for (final Entry<Grader, Message> e : r.getReports()) {
					writer.append("<tr");
					if (first) {
						writer.append(" class=\"topBorder\"");
						first = false;
					}
					if (!odd) {
						writer.append(" style=\"background-color: #cfcfcf\"");
					}
					odd = !odd;
					writer.append("><td align=\"center\">");
					writer.append(String.format("%.2f", e.getKey().getMinPoints()));
					writer.append(String.format(" - %.2f", e.getKey().getMaxPoints()));
					writer.append("</td><td align=\"right\"><span style=\"color: ");
					if (e.getValue().getPoints() == e.getKey().getMinPoints()) {
						writer.append("red");
					} else if (e.getValue().getPoints() == e.getKey().getMaxPoints()) {
						writer.append("green");
					} else {
						writer.append("yellow");
					}
					writer.append("\">" + String.format("%.2f", e.getValue().getPoints()));
					writer.append("</span></td><td>");
					writer.append(TextUtils.stringToHTMLString(e.getValue().getMessage()));
					writer.append("</td><td><pre>");
					writer.append(TextUtils.stringToHTMLString(e.getKey().getClass().getSimpleName()));
					writer.append("</pre></td></tr>");

					for (final Detail d : e.getValue().getDetails()) {
						details.append("<h3>");
						details.append(d.getHeader());
						details.append(" - ");
						details.append(e.getKey().getClass().getSimpleName());
						details.append("</h3>");
						details.append("<ul>");
						for (final String s : d.getStrings()) {
							details.append("<li style=\"font-size:8pt\">");
							if (s.toLowerCase().indexOf("<html>") >= 0) {
								details.append(s.replaceFirst("^.*<[hH][tT][mM][lL][^>]*>", "")
								        .replaceFirst("</[hH][tT][mM][lM]>.*$", "")
								        .replaceFirst("^.*<[bB][oO][dD][yY][^>]*>", "")
								        .replaceFirst("</[bB][oO][dD][yY]>.*$", ""));
							} else {
								details.append(TextUtils.stringToHTMLString(s).replaceAll("\n", "<br />"));
							}
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
			}

			final List<?> errors = ri.getErrors();
			if (errors != null && !errors.isEmpty()) {
				writer.append("<h2>Errors");
				if (r == null) {
					writer.append(" for ");
					writer.append("" + TextUtils.stringToHTMLString(ri.getStudent().toString()));
					if (ri.getFile() != null) writer.append(" / " + TextUtils.stringToHTMLString(ri.getFile().toString()));
				}
				writer.append("</h2><table>");
				writer.append("<tbody>");
				boolean odd = true;
				for (final Object e : errors) {
					writer.append("<tr");
					if (!odd) {
						writer.append(" style=\"background-color: #cfcfcf\"");
					}
					odd = !odd;
					writer.append("><td>");
					writer.append(TextUtils.stringToHTMLString("" + e));
					writer.append("</td></tr>");
				}
				writer.append("</tbody></table>");
			}

			writer.append(details.toString());
			if (writer != error) {
				writer.append("</body>");
				writer.append("</html>");
				try {
					renderer.setDocumentFromString(writer.toString());
				} catch (final Exception _) {
					System.err.println(writer.toString());
				}
				renderer.layout();

				final FileOutputStream os = new FileOutputStream(new File(directory, reportNamePrefix+"_report.pdf"));
				try {
					renderer.createPDF(os);
				} catch (final DocumentException e) {
				}
				os.close();
			} else {
				error.append("</body>");
				error.append("</html>");
				errorRenderer.setDocumentFromString(error.toString());
				errorRenderer.layout();
				final FileOutputStream os = new FileOutputStream(new File(directory, reportNamePrefix+"_errors.pdf"));
				try {
					errorRenderer.createPDF(os);
				} catch (final DocumentException e) {
				}
				os.close();
			}
		}
	}

}
