package org.cpntools.grader.cmdline;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.Observable;
import java.util.Observer;
import java.util.Map.Entry;

import org.cpntools.grader.gui.CSVExport;
import org.cpntools.grader.gui.PDFExport;
import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.model.StudentID;
import org.cpntools.grader.tester.Report;

/**
 * @author michael
 */
public class ResultDialogCmd implements Observer {

	/**
     * 
     */
	private static final long serialVersionUID = 1533651130078221593L;
	private static final String STUDENT_ID = "StudentID";
	boolean cancelled = false;
	
	private File reportDirectory;
	private int count;

	public ResultDialogCmd(final Observable o, final int count, final File reportDirectoy) {
		o.addObserver(this);
		this.reportDirectory = reportDirectoy;
		this.reportDirectory.mkdirs();
		this.count = count;
	}

	public synchronized void addError(final File f, final String error) {
		writeReport(f, null, new StudentID("<none>"), Collections.singletonList(error), 0.0, 0.0);
		System.out.println("Error: "+f.getName()+": "+error);
	}

	public synchronized void addError(final StudentID s) {
		writeReport(null, null, s, Collections.singletonList("No model found for " + s), 0.0, 0.0);
		System.out.println("No model found for " + s);
	}

	public synchronized void addReport(final File f, final Report r) {
		writeReport(f, r, r.getStudentId(), r.getErrors(), r.getPoints(), r.getDeductions());
		System.out.println("Graded: "+f.getName()+": "+(r.getPoints()+r.getDeductions())+" = "+r.getPoints()+"+"+r.getDeductions());
	}
		
	public synchronized void writeReport(final File modelFile, final Report r, final StudentID studentID, final List<String> errors, final double points, final double deductions) {
	
		PDFExport.ReportItem report;
		try {
			// file, id, score, errors
			report = new PDFExport.ReportItem(r, studentID, modelFile, errors, null);
		} catch (final ClassCastException _) {
			report = new PDFExport.ReportItem(null, studentID, modelFile, errors, points+" / "+deductions);
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
		System.out.println("[====== progress: "+progress+"/"+count+" ======]");
	}

	@Override
	public synchronized void update(final Observable arg0, final Object arg1) {
		System.out.println("log: "+arg1);
	}
}
