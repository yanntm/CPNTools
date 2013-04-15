package org.cpntools.algorithms.translator;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.swing.JFileChooser;

import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.Condition;
import org.cpntools.accesscpn.model.HLAnnotation;
import org.cpntools.accesscpn.model.HLArcType;
import org.cpntools.accesscpn.model.HLDeclaration;
import org.cpntools.accesscpn.model.HLMarking;
import org.cpntools.accesscpn.model.Instance;
import org.cpntools.accesscpn.model.ModelFactory;
import org.cpntools.accesscpn.model.Name;
import org.cpntools.accesscpn.model.Node;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.ParameterAssignment;
import org.cpntools.accesscpn.model.PetriNet;
import org.cpntools.accesscpn.model.Place;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.accesscpn.model.RefPlace;
import org.cpntools.accesscpn.model.Sort;
import org.cpntools.accesscpn.model.Transition;
import org.cpntools.accesscpn.model.cpntypes.CPNIndex;
import org.cpntools.accesscpn.model.cpntypes.CPNProduct;
import org.cpntools.accesscpn.model.cpntypes.CPNType;
import org.cpntools.accesscpn.model.cpntypes.CpntypesFactory;
import org.cpntools.accesscpn.model.declaration.DeclarationFactory;
import org.cpntools.accesscpn.model.declaration.TypeDeclaration;
import org.cpntools.accesscpn.model.declaration.VariableDeclaration;
import org.cpntools.accesscpn.model.exporter.DOMGenerator;
import org.cpntools.algorithms.translator.ast.Assignment;
import org.cpntools.algorithms.translator.ast.Declaration;
import org.cpntools.algorithms.translator.ast.Expression;
import org.cpntools.algorithms.translator.ast.ForAll;
import org.cpntools.algorithms.translator.ast.IfElse;
import org.cpntools.algorithms.translator.ast.Invocation;
import org.cpntools.algorithms.translator.ast.Launch;
import org.cpntools.algorithms.translator.ast.Lock;
import org.cpntools.algorithms.translator.ast.Not;
import org.cpntools.algorithms.translator.ast.Procedure;
import org.cpntools.algorithms.translator.ast.Program;
import org.cpntools.algorithms.translator.ast.Repeat;
import org.cpntools.algorithms.translator.ast.Return;
import org.cpntools.algorithms.translator.ast.Statement;
import org.cpntools.algorithms.translator.ast.TopLevel;
import org.cpntools.algorithms.translator.ast.Variable;
import org.cpntools.algorithms.translator.ast.Whatever;
import org.cpntools.algorithms.translator.ast.While;

/**
 * @author michael
 */
public class Translator {
	private static int id = 0;
	private static final boolean SIMPLE_SPLIT = false;
	private static final boolean LONG_NAMES = false;
	private static int t = 0;

	public static void main(final String[] args) throws Exception {
		if (args.length != 0) {
			for (final String fileName : args) {
				translate(new File(fileName));
			}
		} else {
			final JFileChooser chooser = new JFileChooser();
			if (chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
				translate(chooser.getSelectedFile());
			}
		}
	}

	private static void translate(final File file) throws Exception {
		Program p = CupParser.parse(file);
		System.out.print(p);
		System.out.println("==========================================");
		p = DesugarExtreme.instance.translate(p);
		System.out.print(p);
		System.out.println("==========================================");
		final JFileChooser chooser = new JFileChooser();
		if (chooser.showSaveDialog(null) == JFileChooser.APPROVE_OPTION) {
			System.out.print("Translating...");
			final PetriNet translated = translate(p);
			System.out.print("\nSimplifying...");
			final PetriNet simplified = Simplify.simplify(translated);
			System.out.print("\nExporting...");
			DOMGenerator.export(simplified, new FileOutputStream(chooser.getSelectedFile()));
// DOMGenerator.export(translate(p), new FileOutputStream(chooser.getSelectedFile()));
			System.out.println("\nDone.");
		}
	}

	private static PetriNet translate(final Program p) {
		final PetriNet result = ModelFactory.INSTANCE.createPetriNet();
		final Map<String, Procedure> procedures = getProcedures(p);
		final Map<String, Integer> processes = getProcesses(p);

		final Map<String, String> globals = getGlobals(p);

		createVariable(result, "MUTEX", "mutex");
		createTypeDeclaration(result, "BOOL", CpntypesFactory.INSTANCE.createCPNBool());
		createTypeDeclaration(result, "INT", CpntypesFactory.INSTANCE.createCPNInt());
		for (final Entry<String, String> e : globals.entrySet()) {
			createVariable(result, e);
		}

		final Map<String, Page> pages = new HashMap<String, Page>();
		final Map<String, List<PlaceNode>> iterface = new HashMap<String, List<PlaceNode>>();
		if (processes.size() == 0) {
			// Not handled currently
		} else if (processes.size() == 1) {
			final Entry<String, Integer> process = processes.entrySet().iterator().next();
			createTop(result, procedures, pages, process, "PROCESS", globals, iterface);

		} else {
			int i = 1;
			for (final Entry<String, Integer> process : processes.entrySet()) {
				createTop(result, procedures, pages, process, "PROCESS" + i, globals, iterface);
				i++;
			}
		}

		return result;
	}

	private static void createVariable(final PetriNet result, final String type, final String name,
	        final String processType) {
		createVariable(result, type, name);
		if (!type.equalsIgnoreCase("bool") && !type.equalsIgnoreCase("int")) {
			final CPNProduct product = CpntypesFactory.INSTANCE.createCPNProduct();
			product.addSort(processType);
			product.addSort(type);
			createTypeDeclaration(result, processType + "x" + type, product);
		}
	}

	private static void createVariable(final PetriNet result, final Entry<String, String> e) {
		createVariable(result, getType(e), e.getKey().trim());
	}

	private static void createVariable(final PetriNet result, final String type, final String name) {
		if (!type.equalsIgnoreCase("bool") && !type.equalsIgnoreCase("int")) {
			createTypeDeclaration(result, type, CpntypesFactory.INSTANCE.createCPNUnit());
		}

		final HLDeclaration declaration = ModelFactory.INSTANCE.createHLDeclaration();
		declaration.setId("id" + id++);
		declaration.setParent(result);
		final VariableDeclaration variableDeclaration = DeclarationFactory.INSTANCE.createVariableDeclaration();
		variableDeclaration.setTypeName(type);
		variableDeclaration.addVariable(name);
		variableDeclaration.addVariable(name + "'");
		declaration.setStructure(variableDeclaration);
		declaration.setText(variableDeclaration.asString());
	}

	private static String getType(final Entry<String, String> e) {
		if ("".equals(e.getValue())) {
			return e.getKey().trim().toUpperCase();
		} else {
			return e.getValue().trim();
		}
	}

	private static Page createTop(final PetriNet result, final Map<String, Procedure> procedures,
	        final Map<String, Page> pages, final Entry<String, Integer> process, final String name,
	        final Map<String, String> globals, final Map<String, List<PlaceNode>> iterface) {
		final CPNIndex index = CpntypesFactory.INSTANCE.createCPNIndex();
		index.setLow("1");
		index.setHigh("" + process.getValue());
		index.setName(process.getKey());
		createTypeDeclaration(result, name, index);
		final CPNProduct b = CpntypesFactory.INSTANCE.createCPNProduct();
		b.addSort(name);
		b.addSort("BOOL");
		createTypeDeclaration(result, name + "xBOOL", b);
		final CPNProduct i = CpntypesFactory.INSTANCE.createCPNProduct();
		i.addSort(name);
		i.addSort("INT");
		createTypeDeclaration(result, name + "xINT", i);

		final HLDeclaration declaration = ModelFactory.INSTANCE.createHLDeclaration();
		declaration.setId("id" + id++);
		declaration.setParent(result);
		final VariableDeclaration variableDeclaration = DeclarationFactory.INSTANCE.createVariableDeclaration();
		variableDeclaration.setTypeName(name);
		variableDeclaration.addVariable(name.toLowerCase());
		declaration.setStructure(variableDeclaration);
		declaration.setText(variableDeclaration.asString());

		final Map<String, String> refined = new HashMap<String, String>();
		for (final Entry<String, String> g : globals.entrySet()) {
			if (!"".equals(g.getValue())) {
				refined.put(g.getKey(), g.getValue());
			}
		}

		return translate(result, procedures, pages, procedures.get(process.getKey()), name, name.toLowerCase(),
		        globals, refined, iterface, true);
	}

	private static Map<String, String> getGlobals(final Program p) {
		return getVariables(p.getTopLevels());
	}

	private static Map<String, String> getVariables(final Iterable<? extends TopLevel> list) {
		final Map<String, String> result = new HashMap<String, String>();
		for (final TopLevel t : list) {
			if (t instanceof Assignment) {
				final Assignment a = (Assignment) t;
				if (!result.containsKey(a.getId())) {
					result.put(a.getId(), "");
				}
			} else if (t instanceof Declaration) {
				final Declaration d = (Declaration) t;
				if (!result.containsKey(d.getId()) || "".equals(result.get(d.getId()))) {
					result.put(d.getId(), d.getType().trim().toUpperCase());
				}
			}
// else if (t instanceof ForAll) {
// assert false;
// result.putAll(getVariables(((ForAll) t).getStatements()));
// } else if (t instanceof IfElse) {
// final IfElse i = (IfElse) t;
// result.putAll(getVariables(i.getThenStatements()));
// result.putAll(getVariables(i.getElseStatements()));
// } else if (t instanceof Lock) {
// final Lock l = (Lock) t;
// result.putAll(getVariables(l.getStatements()));
// } else if (t instanceof Repeat) {
// final Repeat r = (Repeat) t;
// result.putAll(getVariables(r.getStatements()));
// } else if (t instanceof While) {
// final While w = (While) t;
// result.putAll(getVariables(w.getStatements()));
// }
		}
		return result;
	}

	private static Page translate(final PetriNet petriNet, final Map<String, Procedure> procedures,
	        final Map<String, Page> pages, final Procedure procedure, final String processType,
	        final String processVariable, final Map<String, String> globals, final Map<String, String> refined,
	        final Map<String, List<PlaceNode>> iterface, final boolean top) {
		pages.put(procedure.getName(), null);
		final Page result = ModelFactory.INSTANCE.createPage();
		result.setId("id" + id++);
		final Name name = ModelFactory.INSTANCE.createName();
		name.setText(procedure.getName().trim());
		result.setName(name);
		result.setPetriNet(petriNet);

		final Map<String, PlaceNode> g = new HashMap<String, PlaceNode>();
		final HashMap<String, String> names = new HashMap<String, String>();

		final Map<String, String> rr = new HashMap<String, String>(refined);

		final List<PlaceNode> iplaces = new ArrayList<PlaceNode>();
		for (final Entry<String, String> global : globals.entrySet()) {
			final String n = global.getKey().trim();
			names.put(n, n);
			PlaceNode place;
			if (top) {
				place = createPlace(result, n, getType(global), "1`()");
			} else {
				place = createPlace(result, n, getType(global), "", ModelFactory.INSTANCE.createRefPlace());
			}
			iplaces.add(place);
			g.put(n, place);
		}

		final HashMap<String, PlaceNode> l = new HashMap<String, PlaceNode>();

		iterface.put(procedure.getName(), iplaces);
		for (final Declaration d : procedure.getParameters()) {
			final String localName = d.getId().trim();
			g.remove(localName);
			rr.remove(localName);
			final String type = d.getType() == null || d.getType().equals("") ? procedure.getName().trim()
			        .toUpperCase()
			        + "_" + localName.toUpperCase() : d.getType();
			final String n = procedure.getName().trim() + "_" + localName;
			createVariable(petriNet, type, n, processType);
			if (d.getType() != null && !d.getType().equals("")) {
				rr.put(n, d.getType());
			}
			names.put(localName, n);
			final RefPlace place = createPlace(result, localName, processType + "x" + type, processType + "x" + type
			        + ".mult (" + processType + ".all(), [" + type + ".col 0])", ModelFactory.INSTANCE.createRefPlace());
			iplaces.add(place);
			l.put(n, place);
		}
		if (!top) {
			final RefPlace returnPlace = createPlace(result, "Return Value", procedure.getName().trim().toUpperCase()
			        + "_RETURN", "", ModelFactory.INSTANCE.createRefPlace());
			iplaces.add(returnPlace);
			l.put("<return>", returnPlace);
		}

		for (final Entry<String, String> variable : getVariables(getAllStatements(procedure.getStatements()))
		        .entrySet()) {
			if (!g.containsKey(variable.getKey()) || !"".equals(variable.getValue())) {
				final String localName = variable.getKey().trim();
				if (g.containsKey(localName)) {
					rr.remove(localName);
				}
				g.remove(localName);
				final String type = variable.getValue().equals("") ? procedure.getName().trim().toUpperCase() + "_"
				        + getType(variable) : getType(variable);
				final String n = procedure.getName().trim() + "_" + localName;
				createVariable(petriNet, type, n, processType);
				if (!variable.getValue().equals("")) {
					rr.put(n, variable.getValue().trim());
				}
				names.put(localName, n);
				l.put(n,
				        createPlace(result, localName, processType + "x" + type, processType + "x" + type + ".mult("
				                + processType + ".all(), [" + type + ".col 0])"));
			}
		}

		final PlaceNode s;
		final PlaceNode e;
		if (top) {
			s = createPlace(result, "entry", processType, processType + ".all()");
			e = createPlace(result, "exit", processType, "");
		} else {
			s = createPlace(result, "entry", processType, "", ModelFactory.INSTANCE.createRefPlace());
			e = createPlace(result, "exit", processType, "", ModelFactory.INSTANCE.createRefPlace());
		}

		iplaces.add(s);
		iplaces.add(e);
		addStatements(petriNet, result, procedures, pages, g, l, names, procedure.getStatements(), s, e, e,
		        processType, processVariable, globals, rr, iterface, 1);

		pages.put(procedure.getName(), result);
		return result;
	}

	private static int addStatements(final PetriNet petriNet, final Page page, final Map<String, Procedure> procedures,
	        final Map<String, Page> pages, final Map<String, PlaceNode> g, final HashMap<String, PlaceNode> l,
	        final HashMap<String, String> names, final List<Statement> statements, final PlaceNode s,
	        final PlaceNode e, final PlaceNode ret, final String processType, final String processVariable,
	        final Map<String, String> globals, final Map<String, String> refined,
	        final Map<String, List<PlaceNode>> iterface, int identifier) {
		int i = statements.size();
		PlaceNode start = s;
		for (final Statement statement : statements) {
			PlaceNode end = e;
			if (i > 1) {
				end = createPlace(page, "s" + identifier++, processType, "");
			}
			identifier = addStatement(petriNet, page, procedures, pages, g, l, names, statement, start, end, ret,
			        processType, processVariable, globals, refined, identifier, iterface);
			start = end;
			i--;
		}
		return identifier;
	}

	private static int addStatement(final PetriNet petriNet, final Page page, final Map<String, Procedure> procedures,
	        final Map<String, Page> pages, final Map<String, PlaceNode> g, final HashMap<String, PlaceNode> l,
	        final HashMap<String, String> names, final Statement statement, final PlaceNode start, final PlaceNode end,
	        final PlaceNode ret, final String processType, final String processVariable,
	        final Map<String, String> globals, final Map<String, String> refined, int identifier,
	        final Map<String, List<PlaceNode>> iterface) {
		if (statement instanceof Assignment) {
			final Assignment a = (Assignment) statement;
			if (a.getValue() instanceof Invocation && procedures.containsKey(((Invocation) a.getValue()).getName())) {
				final Invocation i = (Invocation) a.getValue();
				Page p = null;
				if (!pages.containsKey(i.getName())) {
					p = translate(petriNet, procedures, pages, procedures.get(i.getName()), processType,
					        processVariable, globals, refined, iterface, false);
				} else {
					p = pages.get(i.getName());
				}
				if (p == null && false) { throw new UnsupportedOperationException("Recursion not supported"); }

				if (p == null) {
					final Transition transition = createTransition(page, start,
					        "Subpage Failed\n" + statement.toString(), processVariable, null, a);
					addArc(page, transition, end, processVariable);
				} else {
					final Instance instance = ModelFactory.INSTANCE.createInstance();
					instance.setPage(page);
					instance.setSubPageID(p.getId());
					final Name name = ModelFactory.INSTANCE.createName();
					if (LONG_NAMES) {
						name.setText("l" + (statement.getY() + 1) + "_" + t++ + " Invoke\n" + statement);
					} else {
						name.setText("l" + (statement.getY() + 1) + "_" + t++);
					}
					instance.setName(name);
					instance.setId("id" + id++);
					final List<PlaceNode> list = iterface.get(i.getName());
					if (list.size() != i.getValues().size() + globals.size() + 3) { throw new UnsupportedOperationException(
					        "Parameters do not match values for " + i); }
					int j = 0;
					for (final Entry<String, String> e : globals.entrySet()) {
						final PlaceNode place = g.get(e.getKey());
						if (place != null) {
							final ParameterAssignment pa = ModelFactory.INSTANCE.createParameterAssignment();
							pa.setInstance(instance);
							pa.setParameter(place.getId());
							pa.setValue(list.get(j).getId());
							list.get(j).getSort().setText(place.getSort().getText());
							j++;
						}
					}
					for (j = 0; j < i.getValues().size(); j++) {
						final Expression e = i.getValues().get(j);
						if (!(e instanceof Variable)) { throw new UnsupportedOperationException("Parameter " + (j + 1)
						        + " is not a variable in invocation " + i); }
						final Variable v = (Variable) e;
						final String localName = names.get(v.getId());
						final PlaceNode place = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
						if (place != null) {
							final ParameterAssignment pa = ModelFactory.INSTANCE.createParameterAssignment();
							pa.setInstance(instance);
							pa.setParameter(place.getId());
							pa.setValue(list.get(j + globals.size()).getId());
							list.get(j + globals.size()).getSort().setText(place.getSort().getText());
						}
					}
					final String localName = names.get(a.getId());
					final PlaceNode place = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
					if (place != null) {
						final ParameterAssignment pa = ModelFactory.INSTANCE.createParameterAssignment();
						pa.setInstance(instance);
						pa.setParameter(place.getId());
						pa.setValue(list.get(list.size() - 3).getId());
						list.get(list.size() - 3).getSort().setText(place.getSort().getText());
					}
					ParameterAssignment pa = ModelFactory.INSTANCE.createParameterAssignment();
					pa.setInstance(instance);
					pa.setParameter(start.getId());
					pa.setValue(list.get(list.size() - 2).getId());
					pa = ModelFactory.INSTANCE.createParameterAssignment();
					pa.setInstance(instance);
					pa.setParameter(end.getId());
					pa.setValue(list.get(list.size() - 1).getId());
					for (final PlaceNode placeNode : list) {
						placeNode.getInitialMarking().setText("");
					}
				}
			} else {
				final String localName = names.get(a.getId());
				PlaceNode variable = null;
				if (refined.containsKey(localName)) {
					variable = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
				}
				final Transition transition = createTransition(page, start, statement.toString(), processVariable,
				        variable == null ? null : null/* new String[] { localName + "' = (" + a.getValue() + ")" } */, a);
				addArc(page, transition, end, processVariable);
				if (variable != null) {
					if (g.containsKey(localName)) {
						addArc(page, variable, transition, localName);
// addArc(page, transition, variable, localName + "'");
						addArc(page, transition, variable, a.getValue().toString());
					} else {
						addArc(page, variable, transition, "(" + processVariable + ", " + localName + ")");
// addArc(page, transition, variable, "(" + processVariable + ", " + a.getValue() + ")");
						addArc(page, transition, variable, "(" + processVariable + ", " + localName + "')");
					}
				}
				if (a.getValue() instanceof Invocation) {
					final Invocation i = (Invocation) a.getValue();
					for (final Expression e : i.getValues()) {
						if (!(e instanceof Variable)) { throw new UnsupportedOperationException("Parameter " + e
						        + " is not a variable in invocation " + i); }
						final Variable v = (Variable) e;
						final String ll = names.get(v.getId());
						if (refined.containsKey(ll) && !ll.equals(localName)) {
							final PlaceNode place = !g.containsKey(ll) ? l.get(ll) : g.get(ll);
							if (g.containsKey(ll)) {
								addArc(page, place, transition, ll, true);
							} else {
								addArc(page, place, transition, "(" + processVariable + ", " + ll + ")", true);
							}
						}
					}

				}
			}
		} else if (statement instanceof Declaration) {
			final Transition transition = createTransition(page, start, statement.toString(), processVariable, null,
			        statement);
			addArc(page, transition, end, processVariable);
		} else if (statement instanceof ForAll) {
			throw new UnsupportedOperationException("Please desugar for all away");
		} else if (statement instanceof IfElse) {
			final IfElse i = (IfElse) statement;
			PlaceNode ifstart = end;
			PlaceNode elsestart = end;
			if (!i.getThenStatements().isEmpty()) {
				ifstart = createPlace(page, "s" + identifier++, processType, "");
				identifier = addStatements(petriNet, page, procedures, pages, g, l, names, i.getThenStatements(),
				        ifstart, end, ret, processType, processVariable, globals, refined, iterface, identifier);
			}
			if (!i.getElseStatements().isEmpty()) {
				elsestart = createPlace(page, "s" + identifier++, processType, "");
				identifier = addStatements(petriNet, page, procedures, pages, g, l, names, i.getElseStatements(),
				        elsestart, end, ret, processType, processVariable, globals, refined, iterface, identifier);
			}

			final Expression e = i.getCondition();
			String localName = e.toString();
			PlaceNode variable = null;
			if (e instanceof Variable) {
				final Variable v = (Variable) e;
				localName = names.get(v.getId());
				if (refined.containsKey(localName)) {
					variable = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
				}
			}

			if (SIMPLE_SPLIT) {
				final Transition t = createTransition(page, start, "If\n" + i.getCondition(), processVariable, null, i);
				addArc(page, t, elsestart, "if " + localName + "\nthen empty\nelse 1`" + processVariable);
				addArc(page, t, ifstart, "if " + localName + "\nthen 1`" + processVariable + "\nelse empty");
				if (variable != null) {
					final String expression = "(" + processVariable + ", " + localName + ")";
					addArc(page, variable, t, expression, true);
				}
			} else {
				final Transition ifthen;
				final Transition ifelse;
				if (variable != null) {
					ifthen = createTransition(page, start, "If\n" + localName + "\nThen", processVariable, null, i);
					ifelse = createTransition(page, start, "If\n" + localName + "\nElse", processVariable, null, i);
					addArc(page, variable, ifthen, "(" + processVariable + ", true)", true);
					addArc(page, variable, ifelse, "(" + processVariable + ", false)", true);
				} else {
					ifthen = createTransition(page, start, "If\n" + localName + "\nThen", processVariable, null, i);
					ifelse = createTransition(page, start, "If\n" + localName + "\nElse", processVariable, null, i);
				}
				addArc(page, ifthen, ifstart, processVariable);
				addArc(page, ifelse, elsestart, processVariable);
			}
		} else if (statement instanceof Lock) {
			final Lock lock = (Lock) statement;
			final Place mutex = createPlace(page, "Mutex\n" + lock.getLockName(), "MUTEX", "1`()");
			final Place in = createPlace(page, "s" + identifier++, processType, "");
			final Place out = createPlace(page, "s" + identifier++, processType, "");
			final Transition enter = createTransition(page, start, "Enter " + lock.getLockName(), processVariable,
			        null, lock);
			final Transition leave = createTransition(page, out, "Leave " + lock.getLockName(), processVariable, null,
			        lock);
			addArc(page, mutex, enter, "()");
			addArc(page, enter, in, processVariable);
			addArc(page, leave, mutex, "()");
			addArc(page, leave, end, processVariable);
			addStatements(petriNet, page, procedures, pages, g, l, names, lock.getStatements(), in, out, out,
			        processType, processVariable, globals, refined, iterface, identifier);
		} else if (statement instanceof Repeat) {
			final Repeat r = (Repeat) statement;
			final Place loopend = createPlace(page, "s" + identifier++, processType, "");

			Expression e = r.getCondition();
			PlaceNode myend = end;
			PlaceNode myloopstart = start;
			if (e instanceof Not) {
				final Not n = (Not) e;
				e = n.getExpression();
				myend = start;
				myloopstart = end;
			}

			String localName = e.toString();
			PlaceNode variable = null;
			if (e instanceof Variable) {
				final Variable v = (Variable) e;
				localName = names.get(v.getId());
				if (refined.containsKey(localName)) {
					variable = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
				}
			}
			final Transition repeat;
			if (variable != null) {
				repeat = createTransition(page, loopend, "Repeat not\n" + e, processVariable, null, r);
				addArc(page, variable, repeat, "(" + processVariable + ", false)", true);
			} else {
				repeat = createTransition(page, loopend, "Repeat not\n" + e, processVariable, null, r);
			}
			addArc(page, repeat, myloopstart, processVariable);

			final Transition loop;
			if (variable != null) {
				loop = createTransition(page, loopend, "Repeat\n" + e, processVariable, null, r);
				addArc(page, variable, loop, "(" + processVariable + ", true)", true);
			} else {
				loop = createTransition(page, loopend, "Repeat\n" + e, processVariable, null, r);
			}
			addArc(page, loop, myend, processVariable);
			identifier = addStatements(petriNet, page, procedures, pages, g, l, names, r.getStatements(), start,
			        loopend, ret, processType, processVariable, globals, refined, iterface, identifier);
		} else if (statement instanceof Invocation) {
			throw new UnsupportedOperationException("Please desugar invocations into assignments");
		} else if (statement instanceof While) {
			final While w = (While) statement;
			final Place loopstart = createPlace(page, "s" + identifier++, processType, "");

			Expression e = w.getCondition();
			PlaceNode myend = end;
			PlaceNode myloopstart = loopstart;
			if (e instanceof Not) {
				final Not n = (Not) e;
				e = n.getExpression();
				myend = loopstart;
				myloopstart = end;
			}

			String localName = e.toString();
			PlaceNode variable = null;
			if (e instanceof Variable) {
				final Variable v = (Variable) e;
				localName = names.get(v.getId());
				if (refined.containsKey(localName)) {
					variable = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
				}
			}
			if (SIMPLE_SPLIT) {
				final Transition t = createTransition(page, start, "While\n" + w.getCondition(), processVariable, null,
				        w);
				addArc(page, t, myend, "if " + localName + "\nthen empty\nelse 1`" + processVariable);
				addArc(page, t, myloopstart, "if " + localName + "\nthen 1`" + processVariable + "\nelse empty");
				if (variable != null) {
					final String expression = "(" + processVariable + ", " + localName + ")";
					addArc(page, variable, t, expression, true);
				}
			} else {
				final Transition leave;
				if (variable != null) {
					leave = createTransition(page, start, "While not\n" + e, processVariable, null, w);
					addArc(page, variable, leave, "(" + processVariable + ", false)", true);
				} else {
					leave = createTransition(page, start, "While not\n" + e, processVariable, null, w);
				}
				addArc(page, leave, myend, processVariable);

				final Transition loop;
				if (variable != null) {
					loop = createTransition(page, start, "While\n" + e, processVariable, null, w);
					addArc(page, variable, loop, "(" + processVariable + ", true)", true);
				} else {
					loop = createTransition(page, start, "While\n" + e, processVariable, null, w);
				}
				addArc(page, loop, myloopstart, processVariable);
			}
			identifier = addStatements(petriNet, page, procedures, pages, g, l, names, w.getStatements(), loopstart,
			        start, ret, processType, processVariable, globals, refined, iterface, identifier);
		} else if (statement instanceof Return) {
			final Return r = (Return) statement;
			final PlaceNode returnPlace = l.get("<return>");
			Expression e = r.getExpression();
			boolean not = false;
			if (e instanceof Not) {
				final Not n = (Not) e;
				e = n.getExpression();
				not = true;
			}
			if (e instanceof Variable) {
				final Variable v = (Variable) e;
				final Transition t = createTransition(page, start, "Return\n" + e, processVariable, null, v);
				addArc(page, t, ret, processVariable);
				final String localName = names.get(v.getId());
				final PlaceNode variable = !g.containsKey(localName) ? l.get(localName) : g.get(localName);
				if (variable != null) {
					final String expression = "(" + processVariable + ", " + localName + ")";
					final String expression2 = "(" + processVariable + ", " + localName + "')";
					if (refined.containsKey(localName)) {
						addArc(page, variable, t, expression, true);
						addArc(page, returnPlace, t, expression2);
						if (not) {
							addArc(page, t, returnPlace, "(" + processVariable + ", not(" + localName + "))");
						} else {
							addArc(page, t, returnPlace, expression);
						}
					} else {
						addArc(page, returnPlace, t, expression2);
						addArc(page, t, returnPlace, expression);
					}
					final Sort sort = ModelFactory.INSTANCE.createSort();
					sort.setText(variable.getSort().getText());
					returnPlace.setSort(sort);
					final HLMarking marking = ModelFactory.INSTANCE.createHLMarking();
					marking.setText(variable.getInitialMarking().getText());
					returnPlace.setInitialMarking(marking);
				} else {
					addArc(page, returnPlace, t, "(" + processVariable + ", _)");
					addArc(page, t, returnPlace, "(" + processVariable + ", " + v.getId() + ")");
				}
			} else if (e instanceof Whatever) {
				final Whatever w = (Whatever) e;
				final Transition t = createTransition(page, start, "Return\n" + w, processVariable, null, w);
				addArc(page, t, ret, processVariable);
				addArc(page, t, returnPlace, "(" + processVariable + ", " + w.getContents() + ")");
			} else {
				throw new UnsupportedOperationException("Please desugar invocations into assignments");
			}

		} else {
			throw new UnsupportedOperationException("Unknown AST node, " + start.getClass());
		}
		return identifier;
	}

	private static String negate(final Expression condition) {
		if (condition instanceof Not) { return ((Not) condition).getExpression().toString(); }
		return new Not(condition).toString();
	}

	private static Iterable<Statement> getAllStatements(final List<Statement> statements) {
		final ArrayList<Statement> result = new ArrayList<Statement>();
		getAllStatements(statements, result);
		return result;
	}

	private static void getAllStatements(final List<Statement> statements, final List<Statement> arrayList) {
		for (final Statement statement : statements) {
			getAllStatements(statement, arrayList);
		}
	}

	private static void getAllStatements(final Statement statement, final List<Statement> arrayList) {
		arrayList.add(statement);
		if (statement instanceof ForAll) {
			getAllStatements(((ForAll) statement).getStatements(), arrayList);
		} else if (statement instanceof IfElse) {
			getAllStatements(((IfElse) statement).getThenStatements(), arrayList);
			getAllStatements(((IfElse) statement).getElseStatements(), arrayList);
		} else if (statement instanceof Lock) {
			getAllStatements(((Lock) statement).getStatements(), arrayList);
		} else if (statement instanceof Repeat) {
			getAllStatements(((Repeat) statement).getStatements(), arrayList);
		} else if (statement instanceof While) {
			getAllStatements(((While) statement).getStatements(), arrayList);
		}
	}

	private static Place createPlace(final Page page, final String name, final String type, final String initmark) {
		return createPlace(page, name, type, initmark, ModelFactory.INSTANCE.createPlace());
	}

	private static <T extends PlaceNode> T createPlace(final Page page, final String name, final String type,
	        final String initmark, final T result) {
		result.setId("id" + id++);
		result.setPage(page);

		final Name n = ModelFactory.INSTANCE.createName();
		n.setText(name);
		result.setName(n);

		final Sort s = ModelFactory.INSTANCE.createSort();
		s.setText(type);
		result.setSort(s);

		final HLMarking m = ModelFactory.INSTANCE.createHLMarking();
		m.setText(initmark);
		result.setInitialMarking(m);
		return result;
	}

	private static Transition createTransition(final Page page, final PlaceNode origin, final String name,
	        final String processVariable, final String[] guard, final TopLevel s) {
		final Transition result = ModelFactory.INSTANCE.createTransition();
		result.setId("id" + id++);
		result.setPage(page);

		final Name n = ModelFactory.INSTANCE.createName();
		if (LONG_NAMES) {
			n.setText("l" + (s.getY() + 1) + "_" + t++ + name);
		} else {
			n.setText("l" + (s.getY() + 1) + "_" + t++);
		}
		result.setName(n);

		if (guard != null && guard.length > 0) {
			final Condition g = ModelFactory.INSTANCE.createCondition();
			g.setText(Arrays.toString(guard));
			result.setCondition(g);
		}

		addArc(page, origin, result, processVariable);

		return result;
	}

	private static Arc addArc(final Page page, final Node start, final Node end, final String expression) {
		return addArc(page, start, end, expression, false);
	}

	private static Arc addArc(final Page page, final Node start, final Node end, final String expression,
	        final boolean b) {
		final Arc result = ModelFactory.INSTANCE.createArc();
		result.setId("id" + id++);
		result.setPage(page);
		if (b) {
			result.setKind(HLArcType.TEST);
		} else {
			result.setKind(HLArcType.NORMAL);
		}
		result.setSource(start);
		result.setTarget(end);

		final HLAnnotation i = ModelFactory.INSTANCE.createHLAnnotation();
		i.setText(expression);
		result.setHlinscription(i);

		return result;
	}

	private static Map<String, Integer> getProcesses(final Program p) {
		final Map<String, Integer> result = new HashMap<String, Integer>();
		for (final TopLevel t : p.getTopLevels()) {
			if (t instanceof Launch) {
				final Launch l = (Launch) t;
				for (final Invocation i : l.getInvocations()) {
					if (i.getValues().isEmpty()) {
						final Integer count = result.get(i.getName());
						if (count == null) {
							result.put(i.getName(), 1);
						} else {
							result.put(i.getName(), count + 1);
						}
					}
				}
			}
		}

		return result;
	}

	private static Map<String, Procedure> getProcedures(final Program p) {
		final Map<String, Procedure> result = new HashMap<String, Procedure>();
		for (final TopLevel t : p.getTopLevels()) {
			if (t instanceof Procedure) {
				final Procedure pr = (Procedure) t;
				result.put(pr.getName(), pr);
			}
		}
		return result;
	}

	private static void createTypeDeclaration(final PetriNet result, final String name, final CPNType type) {
		final HLDeclaration declaration = ModelFactory.INSTANCE.createHLDeclaration();
		declaration.setId("id" + id++);
		declaration.setParent(result);
		final TypeDeclaration typeDeclaration = DeclarationFactory.INSTANCE.createTypeDeclaration();
		typeDeclaration.setTypeName(name);
		typeDeclaration.setSort(type);
		declaration.setStructure(typeDeclaration);
		declaration.setText(typeDeclaration.asString());
	}
}
