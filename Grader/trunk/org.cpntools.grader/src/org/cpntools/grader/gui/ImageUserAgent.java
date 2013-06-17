package org.cpntools.grader.gui;

import java.awt.Image;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.xhtmlrenderer.pdf.ITextFSImage;
import org.xhtmlrenderer.pdf.ITextOutputDevice;
import org.xhtmlrenderer.pdf.ITextUserAgent;
import org.xhtmlrenderer.resource.ImageResource;

import com.lowagie.text.BadElementException;

public class ImageUserAgent extends ITextUserAgent {

	Map<String, Image> images = new HashMap<String, Image>();

	public ImageUserAgent(final ITextOutputDevice outputDevice) {
		super(outputDevice);
	}

	@Override
	public ImageResource getImageResource(final java.lang.String uri) {
		final Image img = images.get(uri);
		if (img != null) {
			try {
				return new ImageResource(new ITextFSImage(com.lowagie.text.Image.getInstance(img, null)));
			} catch (final BadElementException e) {
			} catch (final IOException e) {
			}
		}
		return super.getImageResource(uri);
	}

	public void register(final String name, final Image img) {
		images.put(name, img);
	}

}
