package org.cpntools.algorithms.translator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.cpntools.algorithms.translator.ast.Assignment;
import org.cpntools.algorithms.translator.ast.Declaration;
import org.cpntools.algorithms.translator.ast.Expression;
import org.cpntools.algorithms.translator.ast.ForAll;
import org.cpntools.algorithms.translator.ast.IfElse;
import org.cpntools.algorithms.translator.ast.Invocation;
import org.cpntools.algorithms.translator.ast.MethodInvocation;
import org.cpntools.algorithms.translator.ast.Not;
import org.cpntools.algorithms.translator.ast.Procedure;
import org.cpntools.algorithms.translator.ast.Repeat;
import org.cpntools.algorithms.translator.ast.Return;
import org.cpntools.algorithms.translator.ast.Statement;
import org.cpntools.algorithms.translator.ast.TopLevel;
import org.cpntools.algorithms.translator.ast.Variable;
import org.cpntools.algorithms.translator.ast.While;

/**
 * @author michael Replaces MethodInvocation with Invocations, Replace for all with while, Move all function calls to
 *         assignments, Remove double not, Make sure if only has positive formulas
 */
public class DesugarExtreme extends Mapper {
	public static final DesugarExtreme instance = new DesugarExtreme();
	int condition = 0;
	int all = 0;
	int returnValue = 0;
	int dummy = 0;
	int local = 0;

	private final Set<String> procedures = new HashSet<String>();

	@Override
	protected List<TopLevel> translate(final List<TopLevel> topLevels, final boolean ignore) {
		for (final TopLevel topLevel : topLevels) {
			if (topLevel instanceof Procedure) {
				final Procedure procedure = (Procedure) topLevel;
				procedures.add(procedure.getName());
			}
		}
		return super.translate(topLevels, ignore);
	}

	@Override
	protected Object translate(final Procedure t) {
		condition = 0;
		all = 0;
		returnValue = 0;
		dummy = 0;
		local = 0;
		return super.translate(t);
	}

	@Override
	protected Object translate(final Statement t) {
		if (false && t instanceof Repeat) {
			final Repeat r = (Repeat) t;
			final Statement[] result = new Statement[r.getStatements().size() + 1];
			int i = 0;
			for (final Statement tt : r.getStatements()) {
				result[i++] = tt;
			}
			final ArrayList<Statement> list = new ArrayList<Statement>(r.getStatements());
			Collections.reverse(list);
			Expression condition = translate(r.getCondition());
			if (condition instanceof Not) {
				condition = ((Not) condition).getExpression();
			} else {
				condition = new Not(t, condition);
			}
			result[i++] = new While(t, condition, translate(r.getStatements()));
			return result;
		}
		if (t instanceof Assignment) {
			final Assignment a = (Assignment) t;
			final Expression e = translate(a.getValue());
			if (e instanceof Not) {
				final Not n = (Not) e;
				final String local = getLocal();
				return new Statement[] { new Assignment(t, local, n.getExpression()),
				        new Assignment(t, a.getId(), new Not(t, new Variable(t, local))) };
			}
			if (e instanceof Invocation) {
				final Invocation i = (Invocation) e;
				final List<Expression> parameters = new ArrayList<Expression>(i.getValues());
				for (int j = 0; j < parameters.size(); j++) {
					final Expression parameter = parameters.get(j);
					if (!(parameter instanceof Variable)) {
						final String name = getLocal();
						parameters.set(j, new Variable(t, name));
						Collections.reverse(parameters);
						return new Statement[] { new Assignment(t, name, parameter),
						        new Assignment(t, a.getId(), new Invocation(t, i.getName(), parameters)) };
					}
				}
			}
			return new Assignment(t, a.getId(), translate(a.getValue()));
		}
		if (t instanceof Repeat) {
			final Repeat r = (Repeat) t;
			Expression e = translate(r.getCondition());
			final String name = getCondition();
			Expression variable = new Variable(t, name);
			if (e instanceof Not) {
				final Not n = (Not) e;
				e = n.getExpression();
				variable = new Not(t, variable);
			}
			if (!(e instanceof Variable)) {
				final List<Statement> list = new ArrayList<Statement>();
				list.addAll(r.getStatements());
				list.add(new Assignment(t, name, e));
				return new Statement[] { new Declaration(t, "BOOL", name), new Repeat(t, translate(list), variable) };
			}
			return new Repeat(t, translate(r.getStatements()), translate(r.getCondition()));
		}
		if (t instanceof IfElse) {
			final IfElse i = (IfElse) t;
			final Expression e = translate(i.getCondition());
			if (e instanceof Not) {
				final Not n = (Not) e;
				return new Statement[] { new IfElse(t, n.getExpression(), i.getElseStatements(), i.getThenStatements()) };
			}
// if (!(e instanceof Variable)) {
// final String name = getCondition();
// return new Statement[] {
// new Declaration(t, "BOOL", name),
// new Assignment(t, name, e),
// new IfElse(t, new Variable(t, name), translate(i.getThenStatements()),
// translate(i.getElseStatements())) };
// }
			if (containsInvoke(e)) {
				final String name = getCondition();
				return new Statement[] {
				        new Declaration(t, "BOOL", name),
				        new Assignment(t, name, e),
				        new IfElse(t, new Variable(t, name), translate(i.getThenStatements()),
				                translate(i.getElseStatements())) };
			}
			return new IfElse(t, e, translate(i.getThenStatements()), i.getElseStatements());
		}
		if (t instanceof Return) {
			final Return r = (Return) t;
			Expression e = translate(r.getExpression());
			final String name = getReturn();
			Expression variable = new Variable(t, name);
			if (e instanceof Not) {
				final Not n = (Not) e;
				e = n.getExpression();
				variable = new Not(t, variable);
			}
			if (!(e instanceof Variable)) { return new Statement[] { new Assignment(t, name, e),
			        new Return(t, variable) }; }
			return new Return(t, translate(r.getExpression()));
		}
		if (t instanceof While) {
			final While w = (While) t;
			Expression e = translate(w.getCondition());
			final String name = getCondition();
			Expression variable = new Variable(t, name);
			if (e instanceof Not) {
				final Not n = (Not) e;
				e = n.getExpression();
				variable = new Not(t, variable);
			}
// if (!(e instanceof Variable)) {
// final List<Statement> list = new ArrayList<Statement>();
// list.addAll(w.getStatements());
// list.add(new Assignment(t, name, e));
// return new Statement[] { new Declaration(t, "BOOL", name), new Assignment(t, name, e),
// new While(t, variable, translate(list)) };
// }
			if (containsInvoke(e)) {
				final List<Statement> list = new ArrayList<Statement>();
				list.addAll(w.getStatements());
				list.add(new Assignment(t, name, e));
				return new Statement[] { new Declaration(t, "BOOL", name), new Assignment(t, name, e),
				        new While(t, variable, translate(list)) };
			}
			return new While(t, e, translate(w.getStatements()));
		}
		if (t instanceof ForAll) {
			final ForAll f = (ForAll) t;
			final List<Statement> list = new ArrayList<Statement>();
			final String name = getAll(f);
			list.add(new Assignment(t, f.getId(), translate(new MethodInvocation(t, new Variable(t, name),
			        new Invocation(t, "getFirst", new ArrayList<Expression>())))));
			list.addAll(f.getStatements());
			return new Statement[] {
			        new Assignment(t, name, translate(f.getCondition())),
			        new While(t, new MethodInvocation(t, new Variable(t, name), new Invocation(t, "hasMore",
			                new ArrayList<Expression>())), translate(list)) };
		}
		if (t instanceof Expression) {
			final Expression e = (Expression) t;
			return new Assignment(t, getDummy(), e);
		}
		return super.translate(t);
	}

	private boolean containsInvoke(final Expression e) {
		if (e instanceof Invocation) {
			final Invocation i = (Invocation) e;
			if (procedures.contains(i.getName())) { return true; }
			for (final Expression ex : i.getValues()) {
				if (containsInvoke(ex)) { return true; }
			}
			return false;
		}
		if (e instanceof MethodInvocation) {
			assert false;
		}
		return false;
	}

	private String getDummy() {
		return "dummy" + dummy++;
	}

	@Override
	protected Expression translate(final Expression e) {
		if (e instanceof MethodInvocation) {
			final MethodInvocation mi = (MethodInvocation) e;
			final List<Expression> values = new ArrayList<Expression>();
			values.add(translate(mi.getObject()));
			values.addAll(mi.getMethod().getValues());
			Collections.reverse(values);
			return translate(new Invocation(e, mi.getMethod().getName(), values));
		}
		if (e instanceof Invocation) {
			final Invocation i = (Invocation) e;
			final List<Expression> values = new ArrayList<Expression>();
			for (final Expression ee : i.getValues()) {
				values.add(translate(ee));
			}
			Collections.reverse(values);
			return new Invocation(e, i.getName(), values);
		}
		if (e instanceof Not) {
			final Not n = (Not) e;
			if (n.getExpression() instanceof Not) {
				final Not nn = (Not) n.getExpression();
				return translate(nn.getExpression());
			}
		}
		return super.translate(e);
	}

	private String getAll(final ForAll f) {
		if (all++ == 0) { return "all_" + f.getId(); }
		return "all_" + f.getId() + all;
	}

	private String getReturn() {
		if (returnValue++ == 0) { return "returnValue"; }
		return "returnValue" + returnValue;
	}

	private String getLocal() {
		if (local++ == 0) { return "local"; }
		return "local" + local;
	}

	private String getCondition() {
		if (condition++ == 0) { return "condition"; }
		return "condition" + condition;
	}
}
