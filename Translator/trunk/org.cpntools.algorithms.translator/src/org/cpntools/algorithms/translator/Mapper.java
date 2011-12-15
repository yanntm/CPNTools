package org.cpntools.algorithms.translator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.cpntools.algorithms.translator.ast.Assignment;
import org.cpntools.algorithms.translator.ast.Declaration;
import org.cpntools.algorithms.translator.ast.Expression;
import org.cpntools.algorithms.translator.ast.ForAll;
import org.cpntools.algorithms.translator.ast.IfElse;
import org.cpntools.algorithms.translator.ast.Invocation;
import org.cpntools.algorithms.translator.ast.Lock;
import org.cpntools.algorithms.translator.ast.MethodInvocation;
import org.cpntools.algorithms.translator.ast.Not;
import org.cpntools.algorithms.translator.ast.Procedure;
import org.cpntools.algorithms.translator.ast.Program;
import org.cpntools.algorithms.translator.ast.Repeat;
import org.cpntools.algorithms.translator.ast.Return;
import org.cpntools.algorithms.translator.ast.Statement;
import org.cpntools.algorithms.translator.ast.TopLevel;
import org.cpntools.algorithms.translator.ast.While;

public class Mapper {
	public Program translate(final Program p) {
		return new Program(translate(p.getTopLevels(), true));
	}

	protected List<TopLevel> translate(final List<TopLevel> topLevels, final boolean ignore) {
		final List<TopLevel> result = new ArrayList<TopLevel>();
		for (final TopLevel t : topLevels) {
			map(result, t);
		}

		Collections.reverse(result);
		return result;
	}

	protected Object translate(final TopLevel t) {
		if (t instanceof Statement) { return translate((Statement) t); }
		if (t instanceof Procedure) { return translate((Procedure) t); }
		return t;
	}

	protected Object translate(final Procedure t) {
		final List<Declaration> parameters = new ArrayList<Declaration>(t.getParameters());
		Collections.reverse(parameters);
		return new Procedure(t, t.getName(), parameters, translate(t.getStatements()));
	}

	protected List<Statement> translate(final List<Statement> statements) {
		final List<Statement> result = new ArrayList<Statement>();
		for (final Statement s : statements) {
			map(result, s);
		}
		Collections.reverse(result);
		return result;
	}

	@SuppressWarnings("unchecked")
	protected <T extends TopLevel> void map(final List<T> result, final TopLevel s) {
		final Object translated = translate(s);
		if (translated != null) {
			if (translated instanceof TopLevel) {
				result.add((T) translated);
			} else if (translated instanceof Statement[]) {
				for (final T tt : (T[]) translated) {
					map(result, tt);
				}
			}
		}
	}

	protected Object translate(final Statement t) {
		if (t instanceof Repeat) {
			final Repeat r = (Repeat) t;
			return new Repeat(t, translate(r.getStatements()), translate(r.getCondition()));
		}
		if (t instanceof While) {
			final While w = (While) t;
			return new While(t, translate(w.getCondition()), translate(w.getStatements()));
		}
		if (t instanceof ForAll) {
			final ForAll f = (ForAll) t;
			return new ForAll(t, translate(f.getCondition()), f.getId(), translate(f.getStatements()));
		}
		if (t instanceof IfElse) {
			final IfElse i = (IfElse) t;
			return new IfElse(t, translate(i.getCondition()), translate(i.getThenStatements()),
			        translate(i.getElseStatements()));
		}
		if (t instanceof Lock) {
			final Lock l = (Lock) t;
			return new Lock(t, l.getLockName(), translate(l.getStatements()));
		}
		if (t instanceof Assignment) {
			final Assignment a = (Assignment) t;
			return new Assignment(t, a.getId(), translate(a.getValue()));
		}
		if (t instanceof Return) { return new Return(t, translate(((Return) t).getExpression())); }
		if (t instanceof Expression) { return translate((Expression) t); }
		return t;
	}

	protected Expression translate(final Expression e) {
		if (e instanceof Not) {
			final Not n = (Not) e;
			return new Not(e, translate(n.getExpression()));
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
		if (e instanceof MethodInvocation) {
			final MethodInvocation mi = (MethodInvocation) e;
			return new MethodInvocation(e, translate(mi.getObject()), (Invocation) translate(mi.getMethod()));
		}
		return e;
	}
}
