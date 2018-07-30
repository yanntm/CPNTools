package org.cpntools.grader.gui;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map.Entry;

import org.cpntools.grader.model.Grader;
import org.cpntools.grader.model.Message;
import org.cpntools.grader.tester.Report;

/**
 * Helper class to write grading summaries to CSV files
 * 
 * @author dfahland
 */
public class CSVExport {
	
	/**
	 * Append line with report scores to default CSV file
	 * @param directory
	 * @param r
	 * @throws IOException 
	 */
	public static void appendCSVLine(final File directory, final Report r) throws IOException {
	    if (r == null) return;
	    
	    java.net.InetAddress localMachine = java.net.InetAddress.getLocalHost();
	    
		FileWriter fw = new FileWriter(new File(directory, "results"+localMachine.getHostName()+".csv"), true);
	    BufferedWriter bw = new BufferedWriter(fw);
	    PrintWriter out = new PrintWriter(bw);
	    
	    StringBuilder sb = new StringBuilder();
	    String studentID = (r.getStudentId() == null) ? "<null>" : r.getStudentId().toString();
	    sb.append(studentID);
	    sb.append(";"+r.getDeductions());
	    sb.append(";"+r.getPoints());
	    for (Entry<Grader, Message> e : r.getReports()) {
	    	sb.append(";"+e.getValue().getPoints());
	    }
	    out.append(sb.toString());
	    for (String e : r.getErrors()) {
	    	sb.append(";"+e);
	    }
	    out.append('\n');
	    out.close();
	}
}
