package org.cpntools.grader.model;

import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.swing.JComponent;

public class Detail {
	private final String header;
	private final Image image;
	protected final List<String> strings = new ArrayList<String>();
	private final List<String> u_strings = Collections.unmodifiableList(strings);

	public Detail(final String header, final Iterable<String> details) {
		this.header = header;
		for (final String detail : details) {
			strings.add(detail);
		}
		image = null;
	}

	public Detail(final String header, final JComponent compoent) {
		this.header = header;
		if (compoent.getSize().width <= 0 || compoent.getSize().height <= 0) {
			final BufferedImage tmp = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
			final Graphics g = tmp.createGraphics();
			compoent.paint(g);
			g.dispose();
		}
		final BufferedImage bi = new BufferedImage(compoent.getSize().width, compoent.getSize().height,
		        BufferedImage.TYPE_INT_ARGB);
		final Graphics g = bi.createGraphics();
		compoent.paint(g);
		g.dispose();
		image = bi;
	}

	public Detail(final String header, final String... details) {
		this.header = header;
		for (final String detail : details) {
			strings.add(detail);
		}
		image = null;
	}

	public String getHeader() {
		return header;
	}

	public Image getImage() {
		return image;
	}

	public List<String> getStrings() {
		return u_strings;
	}
}
