package org.cpntools.grader.cmdline;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Observable;
import java.util.Observer;

import org.cpntools.grader.gui.PDFExport;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.tester.Report;

/**
 * @author michael
 */
public class ResultDialogCmd implements Observer {
	private static final String ERRORS = "Errors";
	private static final String FILE = "File";
	private static final String SCORE = "Score";
	/**
     * 
     */
	private static final long serialVersionUID = 1533651130078221593L;
	private static final String STUDENT_ID = "StudentID";
	boolean cancelled = false;
	
	private File reportDirectory;
	private int count;

	public ResultDialogCmd(final Observable o, final int count, final File reportDirectoy) {
		this.reportDirectory = reportDirectoy;
		this.reportDirectory.mkdirs();
		this.count = count;
	}

	public synchronized void addError(final File f, final String error) {
		writeReport( f.getName(), null, new StudentID("<none>"), Collections.singletonList(error), 0.0);
		System.out.println("Error: "+f.getName()+": "+error);
	}

	public synchronized void addError(final StudentID s) {
		writeReport("<none>", null, s, Collections.singletonList("No model found for " + s), 0.0);
		System.out.println("No model found for " + s);
	}

	public synchronized void addReport(final File f, final Report r) {
		writeReport(f.getName(), r, r.getStudentId(), r.getErrors(), r.getResult());
		System.out.println("Graded: "+f.getName()+": "+r.getResult());
	}
		
	public synchronized void writeReport(final String fileName, final Report r, final StudentID studentID, final List<String> errors, final double result) {
	
		PDFExport.ReportItem report;
		try {
			// file, id, score, errors
			report = new PDFExport.ReportItem(r, studentID, fileName, errors, null);
		} catch (final ClassCastException _) {
			report = new PDFExport.ReportItem(null, studentID, fileName, errors, result);
		}
		
		List<PDFExport.ReportItem> reports = new LinkedList<PDFExport.ReportItem>();
		reports.add(report);
		
		try {
			PDFExport.exportReports(reportDirectory, reports);
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
		System.out.println("[====== progress: "+progress+"/"+count+" ======]");
	}

	@Override
	public synchronized void update(final Observable arg0, final Object arg1) {
		System.out.println("log: "+arg1);
	}
}
