package org.cpntools.grader.signer;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Random;
import java.util.Set;

import org.cpntools.accesscpn.engine.highlevel.instance.InstanceFactory;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelData;
import org.cpntools.accesscpn.engine.highlevel.instance.adapter.ModelDataAdapterFactory;
import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.HLDeclaration;
import org.cpntools.accesscpn.model.HasId;
import org.cpntools.accesscpn.model.Instance;
import org.cpntools.accesscpn.model.Node;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.ParameterAssignment;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.impl.PetriNetImpl;
import org.cpntools.accesscpn.model.monitors.Monitor;
import org.cpntools.grader.model.StudentID;
import org.eclipse.emf.ecore.util.EcoreUtil;

/**
 * @author michael
 */
public class Signer {
	/**
	 * @param model
	 * @param secret
	 * @param studentId
	 * @return
	 */
	@SuppressWarnings("unchecked")
	static public PetriNet sign(final PetriNetImpl model, final String secret, final StudentID studentId) {
		final PetriNet result = EcoreUtil.copy(model);
		final ModelData modelData = (ModelData) ModelDataAdapterFactory.getInstance().adapt(result, ModelData.class);
		for (final Monitor m : result.getMonitors()) {
			final Collection<Object> nodes = new ArrayList<Object>(m.getNodes());
			m.getNodes().clear();
			for (final Object o : nodes) {
				final org.cpntools.accesscpn.engine.highlevel.instance.Instance<Node> i = (org.cpntools.accesscpn.engine.highlevel.instance.Instance<Node>) o;
				m.getNodes().add(remap(i, modelData));
			}
		}
		final Random random = getRandom(secret, studentId);
		final Set<String> usedIds = new HashSet<String>();
		final Map<String, String> idMap = new HashMap<String, String>();
		for (final HLDeclaration d : result.declaration()) {
			replaceId(random, usedIds, idMap, d);
		}
		for (final Page p : result.getPage()) {
			replaceId(random, usedIds, idMap, p);
			for (final org.cpntools.accesscpn.model.Object o : p.getObject()) {
				replaceId(random, usedIds, idMap, o);
			}
			for (final Arc a : p.getArc()) {
				replaceId(random, usedIds, idMap, a);
			}
		}
		for (final Page p : result.getPage()) {
			for (final Instance i : p.instance()) {
				i.setSubPageID(idMap.get(i.getSubPageID()));
				for (final ParameterAssignment pa : i.getParameterAssignment()) {
					pa.setParameter(idMap.get(pa.getParameter()));
					pa.setValue(idMap.get(pa.getValue()));
				}
			}
		}
		return result;
	}

	@SuppressWarnings("unchecked")
	private static <T extends Node> org.cpntools.accesscpn.engine.highlevel.instance.Instance<T> remap(
	        final org.cpntools.accesscpn.engine.highlevel.instance.Instance<T> i, final ModelData modelData) {
		if (i == null) { return null; }
		final org.cpntools.accesscpn.engine.highlevel.instance.Instance<Node> result = InstanceFactory.INSTANCE
		        .createInstance(modelData.getNode(i.getNode().getId()), i.getInstanceNumber());
		result.setTransitionPath(remap(i.getTransitionPath(), modelData));
		return (org.cpntools.accesscpn.engine.highlevel.instance.Instance<T>) result;
	}

	private static Random getRandom(final String secret, final StudentID studentId) {
		try {
			final SecureRandom securerandom = SecureRandom.getInstance("SHA1PRNG");
			securerandom.setSeed((secret + "//" + studentId.getId()).getBytes());
			return securerandom;
		} catch (final NoSuchAlgorithmException _) {
			return new Random((secret + "//" + studentId.getId()).hashCode());
		}
	}

	/**
	 * @param model
	 * @param secret
	 * @param studentId
	 * @return how many nodes matched the signature; typically this is not all
	 */
	public static int checkSignature(final PetriNet model, final String secret, final StudentID studentId) {
		final Random random = getRandom(secret, studentId);
		final Set<String> usedIds = new HashSet<String>();
		final Set<String> ids = new HashSet<String>();
		for (final HLDeclaration d : model.declaration()) {
			ids.add(d.getId());
		}
		for (final Page p : model.getPage()) {
			ids.add(p.getId());
			for (final org.cpntools.accesscpn.model.Object o : p.getObject()) {
				ids.add(o.getId());
			}
			for (final Arc a : p.getArc()) {
				ids.add(a.getId());
			}
		}
		int count = 0;
		for (int i = 0; i < ids.size(); i++) {
			final String id = getId(random, usedIds);
			if (ids.contains(id)) {
				count++;
			}
		}
		return count;
	}

	private static void replaceId(final Random random, final Set<String> usedIds, final Map<String, String> idMap,
	        final HasId o) {
		final String id = getId(random, usedIds);
		idMap.put(o.getId(), id);
		o.setId(id);
	}

	static protected String getId(final Random random, final Set<String> used) {
		final int number = random.nextInt() & 0xfffffff;
		final String id = "id" + number;
		if (!used.add(id)) { return getId(random, used); }
		return id;
	}
}
