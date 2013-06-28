package org.cpntools.grader.signer;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

import javax.naming.OperationNotSupportedException;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;

import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.exporter.DOMGenerator;
import org.cpntools.accesscpn.model.impl.PetriNetImpl;
import org.cpntools.grader.model.StudentID;

public class Generator {
	public static PetriNet generate(final File dir, final PetriNetImpl model, final String secret, final StudentID id)
	        throws OperationNotSupportedException, TransformerException, ParserConfigurationException, IOException {
		final PetriNet signedModel = Signer.sign(model, secret, id);
		final OutputStream outputStream = new FileOutputStream(new File(dir, model.getName().getText() 
		        + id.getId() + ".cpn"));
		DOMGenerator.export(signedModel, outputStream);
		outputStream.close();
		return signedModel;
	}
}
