package org.cpntools.accesscpn.engine;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;

/**
 * @author mw
 */
public class DaemonStarter implements Runnable {
	private static DaemonStarter instance = null;

	/**
	 * @return a static instance
	 * @throws IOException
	 */
	public static DaemonStarter getInstance() throws IOException {
		if (DaemonStarter.instance == null) {
			DaemonStarter.instance = new DaemonStarter();
		}
		return DaemonStarter.instance;
	}

	/**
	 * 
	 */
	public File simulatorDir;

	Process daemon = null;

	private final String cpnmld;

	private final String run;

	private DaemonStarter() throws IOException {
		String arch;
		String platform;
		if (OSValidator.isMac()) {
			platform = "darwin";
		} else if (OSValidator.isWindows()) {
			platform = "cygwin";
		} else if (OSValidator.isUnix()) {
			platform = "linux";
		} else {
			platform = "linux";
		}

		arch = "x86"; // When we get some 64-bit version we can worry about detecting it
		final String archOS = '.' + arch + '-' + platform;

		simulatorDir = new File(getPluginResource("simulator"));

		if (!simulatorDir.exists()) {
			if (!simulatorDir.mkdirs()) { throw new IOException("Could not create dir for storing simulator"); }
		}
		if (simulatorDir.isFile()) { throw new IOException("Location for storing simulator exists but is a file"); }

		ensureExists(simulatorDir, "simulator/cpnmld" + archOS);
		ensureExists(simulatorDir, "simulator/run" + archOS);
		ensureExists(simulatorDir, "simulator/cpn.ML" + archOS);
		if (OSValidator.isWindows()) {
			ensureExists(simulatorDir, "simulator/cygwin1.dll");
			ensureExists(simulatorDir, "simulator/cyggcc_s-1.dll");
		}
		cpnmld = new File(simulatorDir, ("cpnmld" + archOS)).toString();
		run = new File(".", "run" + archOS).toString();

		try {
			ProcessBuilder pb = new ProcessBuilder("chmod", "u+x", cpnmld);
			pb.directory(simulatorDir);
			pb.start().waitFor();
			pb = new ProcessBuilder("chmod", "u+x", run);
			pb.directory(simulatorDir);
			pb.start().waitFor();
		} catch (final InterruptedException e) {
			e.printStackTrace();
			// Ignore error
		} catch (final IOException e) {
			// e.printStackTrace();
			// Ignore if chmod does not exist -- this typically happens on
			// Windows where chmod is not needed to run executables
		}

		Runtime.getRuntime().addShutdownHook(new Thread(this, "Daemon shutdown hook")); //$NON-NLS-1$
	}

	@SuppressWarnings( { "null", "deprecation" })
	private void ensureExists(final File dir, final String resource) throws IOException {
		final File file = new File(new File(dir, ".."), resource);
		if (file.exists() && file.isFile()) { return; }
		URL resURL = DaemonStarter.class.getResource("/" + resource);
		if (resURL == null) {
			resURL = DaemonStarter.class.getResource("../../../../../../");
			if (resURL != null) {
				final String extractFileName = extractFileName(resURL.toString());
				final File f = new File(extractFileName);
				File g = new File(f, resource);
				if (!(g.exists() && g.isFile())) {
					g = new File(new File(f, ".."), resource);
				}
				if (g.exists() && g.isFile()) {
					resURL = g.toURL();
				}
			}
		}
		final InputStream resourceAsStream = new BufferedInputStream(resURL.openStream());
		final OutputStream outputStream = new BufferedOutputStream(new FileOutputStream(file));
		final byte[] buffer = new byte[8192];
		int read;
		while ((read = resourceAsStream.read(buffer)) >= 0) {
			outputStream.write(buffer, 0, read);
		}
		resourceAsStream.close();
		outputStream.close();
	}

	/**
	 * @see java.lang.Runnable#run()
	 */
	public void run() {
		destroy();
	}

	/**
	 * @param port
	 *            port to start simulator on
	 * @throws IOException
	 *             if, for some reason, we could not start simulator
	 */
	public void startSimulatorDaemon(final int port) throws IOException {
		final ProcessBuilder pb = new ProcessBuilder(cpnmld, "" + port, run);
		pb.redirectErrorStream(true);
		pb.directory(simulatorDir);
		daemon = pb.start();
		new Thread() {
			@Override
			public void run() {
				final InputStream out = daemon.getInputStream();
				while (daemon != null) {
					try {
						out.skip(out.available());
						Thread.sleep(100);
					} catch (final Exception e) {
						// Mask error
					}
				}
			}
		}.start();
	}

	/**
	 * @param name
	 * @return
	 */
	static String getPluginResource(final String name) {
		final String tempdir = System.getProperty("java.io.tmpdir");
		return new File(new File(new File(tempdir), "accesscpn"), name).toString();
// String locationName;
// final String result = DaemonStarter.class.getResource("").getPath() + "../../../../../../../../";
// return result;
// } else {
// try {
// locationName = FileLocator.resolve(Activator.getDefault().getBundle().getResource("")).toString()
// + "../" + name;
// } catch (final IOException e) {
// locationName = "/tmp";
// }
//
// String pluginArea = extractFileName(locationName);
//
// if (pluginArea.charAt(0) != '/') {
// final String configurationArea = extractFileName(Platform.getConfigurationLocation().getURL()
// .toString());
// final IPath p = new Path(configurationArea).append("..").append(pluginArea);
// pluginArea = p.toString();
// }
// return pluginArea;
// }
	}

	private static String extractFileName(final String name) {
		String locationName = name;
		try {
			URL location;
			do {
				location = new URL(locationName);
				locationName = URLDecoder.decode(location.getFile(), "UTF-8");
			} while (!location.getProtocol().equals("file"));
		} catch (final MalformedURLException e) {
			// First was not an URL, ignore
		} catch (final UnsupportedEncodingException e) {
			// Should not happen
		}
		return locationName;
	}

	void destroy() {
		if (daemon != null) {
			try {
				Thread.sleep(250);
			} catch (final InterruptedException e) {
				// Ignore error
			}
			daemon.destroy();
			try {
				daemon.waitFor();
			} catch (final InterruptedException e) {
				// Ignore error
			}
		}
		daemon = null;
	}
}
