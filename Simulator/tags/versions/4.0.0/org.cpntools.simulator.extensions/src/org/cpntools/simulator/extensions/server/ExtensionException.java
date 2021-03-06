package org.cpntools.simulator.extensions.server;

import org.cpntools.simulator.extensions.Extension;

/**
 * @author michael
 */
public class ExtensionException extends Exception {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private final Extension extension;

	/**
	 * @param message
	 * @param extension
	 */
	public ExtensionException(final String message, final Extension extension) {
		this(message, extension, null);
	}

	/**
	 * @param message
	 * @param extension
	 * @param t
	 */
	public ExtensionException(final String message, final Extension extension, final Throwable t) {
		super("Error in extension `" + extension.getName() + "' (ID: " + extension.getIdentifier() + "): " + message, t);
		this.extension = extension;
	}

	/**
	 * @return
	 */
	public Extension getExtension() {
		return extension;
	}
}
