package org.cpntools.grader.model;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.Shape;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Path2D;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.swing.JComponent;

import org.cpntools.accesscpn.engine.highlevel.instance.Instance;
import org.cpntools.accesscpn.model.Annotation;
import org.cpntools.accesscpn.model.Arc;
import org.cpntools.accesscpn.model.HLAnnotation;
import org.cpntools.accesscpn.model.HLArcType;
import org.cpntools.accesscpn.model.HasId;
import org.cpntools.accesscpn.model.Label;
import org.cpntools.accesscpn.model.Node;
import org.cpntools.accesscpn.model.Page;
import org.cpntools.accesscpn.model.PlaceNode;
import org.cpntools.accesscpn.model.TransitionNode;
import org.cpntools.accesscpn.model.graphics.AnnotationGraphics;
import org.cpntools.accesscpn.model.graphics.ArcGraphics;
import org.cpntools.accesscpn.model.graphics.Coordinate;
import org.cpntools.accesscpn.model.graphics.NodeGraphics;

public class PageComponent extends JComponent {
	private static final Color GREEN = new Color(0, 0x80, 0);
	private static final Color MAROON = new Color(0x80, 0, 0);
	private static final Color NAVY = new Color(0, 0, 0x80);
	private static final Color OLIVE = new Color(0x80, 0x80, 0);
	private static final Color PURPLE = new Color(0x80, 0, 0x80);
	/**
     * 
     */
	private static final long serialVersionUID = 1L;
	private static final Color TEAL = new Color(0, 0x80, 0x80);

	public static Color getColor(final String color) {
		return PageComponent.getColor(color, Color.BLACK);
	}

	public static Color getColor(final String color, final Color alternative) {
		if ("black".equalsIgnoreCase(color)) { return Color.BLACK; }
		if ("white".equalsIgnoreCase(color)) { return Color.WHITE; }
		if ("silver".equalsIgnoreCase(color)) { return Color.LIGHT_GRAY; }
		if ("gray".equalsIgnoreCase(color)) { return Color.GRAY; }
		if ("maroon".equalsIgnoreCase(color)) { return PageComponent.MAROON; }
		if ("red".equalsIgnoreCase(color)) { return Color.RED; }
		if ("purple".equalsIgnoreCase(color)) { return PageComponent.PURPLE; }
		if ("fuchsia".equalsIgnoreCase(color)) { return Color.MAGENTA; }
		if ("fucia".equalsIgnoreCase(color)) { return Color.MAGENTA; }
		if ("green".equalsIgnoreCase(color)) { return PageComponent.GREEN; }
		if ("lime".equalsIgnoreCase(color)) { return Color.GREEN; }
		if ("olive".equalsIgnoreCase(color)) { return PageComponent.OLIVE; }
		if ("yellow".equalsIgnoreCase(color)) { return Color.YELLOW; }
		if ("navy".equalsIgnoreCase(color)) { return PageComponent.NAVY; }
		if ("blue".equalsIgnoreCase(color)) { return Color.BLUE; }
		if ("teal".equalsIgnoreCase(color)) { return PageComponent.TEAL; }
		if ("aqua".equalsIgnoreCase(color)) { return Color.CYAN; }
		return alternative != null ? alternative : Color.BLACK;
	}

	private final Path2D arrowhead = new Path2D.Double();

	private final Set<HasId> highlightNodes;

	private final Page page;

	private final Map<Node, Shape> shapes = new HashMap<Node, Shape>();

	protected Font font = new Font("Verdana", Font.PLAIN, 12);
	protected FontMetrics fm = new FontMetrics(font) {

		/**
             * 
             */
		private static final long serialVersionUID = 1L;
	};

	Rectangle2D.Double bounds = null;

	{
		arrowhead.moveTo(0.0, 0.0);
		arrowhead.lineTo(5.0, 10.0);
		arrowhead.lineTo(0.0, 8.0);
		arrowhead.lineTo(-5.0, 10.0);
		arrowhead.lineTo(0.0, 0.0);
	}

	public PageComponent(final Instance<Page> pi) {
		this(pi, Collections.EMPTY_SET);
	}

	public PageComponent(final Instance<Page> pi, final Collection<HasId> interfaceNodes) {
		this(pi.getNode(), interfaceNodes);
	}

	public PageComponent(final Page node) {
		this(node, Collections.EMPTY_SET);
	}

	public PageComponent(final Page node, final Collection<HasId> highlightNodes) {
		page = node;
		this.highlightNodes = new HashSet<HasId>(highlightNodes);
		updateBounds(getGraphics());
	}

	@Override
	public void paint(final Graphics g) {
		if (bounds == null) {
			updateBounds(g);
		}
		final Graphics2D g2d = (Graphics2D) g;
		g2d.translate(-bounds.x, -bounds.y);
		g2d.setFont(font);
		for (final org.cpntools.accesscpn.model.Object o : page.getObject()) {
			if (o instanceof Node) {
				paint((Graphics2D) g2d.create(), (Node) o);
			}
		}
		for (final Arc a : page.getArc()) {
			paint(g2d, a);
		}
	}

	private void drawArrowHead(final Graphics2D g, final Point2D s, final Point2D t) {
		g.translate(s.getX(), s.getY());
		g.setStroke(new BasicStroke());
		g.rotate(Math.atan2(s.getX() - t.getX(), t.getY() - s.getY()));
		g.fill(arrowhead);
	}

	private Color getColor(final String color, final Color alternative, final boolean contains) {
		final Color c = PageComponent.getColor(color, alternative);
		if (!highlightNodes.isEmpty() && !contains) { return new Color(c.getRed(), c.getGreen(), c.getBlue(), 0x50); }
		return c;
	}

	private double getHeight(final Annotation a) {
		double h = 0.0;
		for (final String line : a.getText().split("\n")) {
			h += font.getSize2D();
		}
		return h;
	}

	private Point2D getIntersect(final Point2D from, final Point2D to, final Shape shape) {
		final Rectangle rectangle = shape.getBounds();
		final double dx = to.getX() - from.getX();
		final double dy = to.getY() - from.getY();
		if (dy == 0) {
			if (dx > 0) {
				return new Point2D.Double(from.getX() + rectangle.getWidth() / 2.0, from.getY());
			} else {
				return new Point2D.Double(from.getX() - rectangle.getWidth() / 2.0, from.getY());
			}
		}
		if (dx == 0) {
			if (dy > 0) {
				return new Point2D.Double(from.getX(), from.getY() + rectangle.getHeight() / 2.0);
			} else {
				return new Point2D.Double(from.getX(), from.getY() - rectangle.getHeight() / 2.0);
			}
		}
		final double a = dx / dy;
		if (shape instanceof Rectangle2D) {
			final double b = rectangle.getWidth() / rectangle.getHeight();
			if (Math.abs(a) >= b) {
				final double x = dx > 0 ? rectangle.getWidth() / 2.0 : -rectangle.getWidth() / 2.0;
				return new Point2D.Double(from.getX() + x, from.getY() + x / a);
			} else {
				final double y = dy > 0 ? rectangle.getHeight() / 2.0 : -rectangle.getHeight() / 2.0;
				return new Point2D.Double(from.getX() + y * a, from.getY() + y);
			}
		} else if (shape instanceof Ellipse2D) {
			final double atan = Math.atan2(dy, dx);
			return new Point2D.Double(from.getX() + Math.cos(atan) * rectangle.getWidth() / 2.0, from.getY()
			        + Math.sin(atan) * rectangle.getHeight() / 2.0);
		}
		return from;
	}

	private double getWidth(final Annotation a, final Graphics g) {
		double w = 0.0;
		for (final String line : a.getText().split("\n")) {
			w = Math.max(w, fm.getStringBounds(line.trim(), g).getWidth());
		}
		return w;
	}

	private void paint(final Graphics2D g2d, final Annotation a, final double x, final double y) {
		if (a == null || a.getText() == null || "".equals(a.getText())) { return; }
		g2d.translate(x, -y);
		final double w = getWidth(a, g2d);
		final double h = getHeight(a);
		g2d.translate(-w / 2.0, -h / 2.0 + g2d.getFont().getSize2D());
		for (final String line : a.getText().split("\n")) {
			g2d.drawString(line, 0, 0);
			g2d.translate(0, g2d.getFont().getSize2D());
		}
	}

	private void paint(final Graphics2D g2d, final Arc a) {
		final Shape tshape = shapes.get(a.getPlaceNode());
		final Shape sshape = shapes.get(a.getOtherEnd(a.getPlaceNode()));
		if (tshape == null || sshape == null) { return; }
		final Rectangle tbounds = tshape.getBounds();
		final Rectangle sbounds = sshape.getBounds();
		final Point2D t = new Point2D.Double(tbounds.getCenterX(), tbounds.getCenterY());
		final Point2D s = new Point2D.Double(sbounds.getCenterX(), sbounds.getCenterY());
		final List<Point2D> points = new ArrayList<Point2D>();
		points.add(s);
		final ArcGraphics arcGraphics = a.getArcGraphics();
		if (arcGraphics != null) {
			g2d.setStroke(new BasicStroke((float) arcGraphics.getLine().getWidth()));
			g2d.setColor(getColor(arcGraphics.getLine().getColor(), Color.BLACK, highlightNodes.contains(a)));
			for (final Coordinate p : arcGraphics.getPosition()) {
				points.add(new Point2D.Double(p.getX(), -p.getY()));
			}
		}

		points.add(t);
		points.set(0, getIntersect(points.get(0), points.get(1), sshape));
		points.set(points.size() - 1,
		        getIntersect(points.get(points.size() - 1), points.get(points.size() - 2), tshape));
		boolean first = true;
		final Path2D path = new Path2D.Double();
		for (final Point2D p : points) {
			if (first) {
				path.moveTo(p.getX(), p.getY());
				first = false;
			} else {
				path.lineTo(p.getX(), p.getY());
			}
		}
		g2d.draw(path);
		if (a.getKind() == HLArcType.TEST || a.getTarget() == a.getOtherEnd(a.getPlaceNode())) {
			drawArrowHead((Graphics2D) g2d.create(), points.get(0), points.get(1));
		}
		if (a.getKind() == HLArcType.TEST || a.getTarget() == a.getPlaceNode()) {
			drawArrowHead((Graphics2D) g2d.create(), points.get(points.size() - 1), points.get(points.size() - 2));
		}

		final HLAnnotation annotation = a.getHlinscription();
		final AnnotationGraphics annotationGraphics = annotation.getAnnotationGraphics();
		if (annotationGraphics != null) {
			paint((Graphics2D) g2d.create(), annotation, annotationGraphics.getOffset().getX(), annotationGraphics
			        .getOffset().getY());
		}
	}

	private void paint(final Graphics2D g2d, final Node o) {
		final NodeGraphics nodeGraphics = o.getNodeGraphics();
		if (nodeGraphics != null) {
			g2d.setColor(getColor(nodeGraphics.getFill().getColor(), Color.WHITE, highlightNodes.contains(o)));
			Shape shape = null;
			if (o instanceof PlaceNode) {
				shape = new Ellipse2D.Double(-nodeGraphics.getDimension().getX() / 2.0
				        + nodeGraphics.getPosition().getX(), -nodeGraphics.getDimension().getY() / 2.0
				        - nodeGraphics.getPosition().getY(), nodeGraphics.getDimension().getX(), nodeGraphics
				        .getDimension().getY());
			} else if (o instanceof TransitionNode || o instanceof org.cpntools.accesscpn.model.Instance) {
				shape = new Rectangle2D.Double(-nodeGraphics.getDimension().getX() / 2.0
				        + nodeGraphics.getPosition().getX(), -nodeGraphics.getDimension().getY() / 2.0
				        - nodeGraphics.getPosition().getY(), nodeGraphics.getDimension().getX(), nodeGraphics
				        .getDimension().getY());
			}
			if (shape != null) {
				g2d.fill(shape);
				shapes.put(o, shape);
			}
			g2d.setColor(getColor(nodeGraphics.getLine().getColor(), Color.BLACK, highlightNodes.contains(o)));
			g2d.setStroke(new BasicStroke((float) nodeGraphics.getLine().getWidth()));
			if (shape != null) {
				g2d.draw(shape);
			}

			g2d.translate(nodeGraphics.getPosition().getX(), -nodeGraphics.getPosition().getY());
			paint((Graphics2D) g2d.create(), o.getName(), 0.0, 0.0);
			for (final Label l : o.getLabel()) {
				if (l instanceof Annotation) {
					final Annotation a = (Annotation) l;
					final AnnotationGraphics annotationGraphics = a.getAnnotationGraphics();
					if (annotationGraphics != null) {
						paint((Graphics2D) g2d.create(), a, annotationGraphics.getOffset().getX(), annotationGraphics
						        .getOffset().getY());
					}
				}
			}
		}
	}

	private void updateBounds(final Graphics g) {
		if (g == null) { return; }
		bounds = new Rectangle2D.Double();
		bounds.y = bounds.x = Double.MAX_VALUE;
		bounds.width = bounds.height = Double.MIN_VALUE;
		for (final org.cpntools.accesscpn.model.Object o : page.getObject()) {
			if (o instanceof Node) {
				updateBounds(bounds, (Node) o, g);
			}
		}
		for (final Arc a : page.getArc()) {
			updateBounds(bounds, a, g);
		}
		setSize(new Dimension((int) bounds.width, (int) bounds.height));
	}

	private void updateBounds(final java.awt.geom.Rectangle2D.Double bounds2, final Arc a, final Graphics g) {
		updateBounds(bounds2, 0, 0, a.getHlinscription(), g);
		final ArcGraphics arcGraphics = a.getArcGraphics();
		if (arcGraphics != null) {
			for (final Coordinate p : arcGraphics.getPosition()) {
				updateBounds(bounds2, p.getX(), -p.getY());
			}
		}
	}

	private void updateBounds(final java.awt.geom.Rectangle2D.Double bounds, final double x, final double y) {
		bounds.x = Math.min(bounds.x, x);
		bounds.y = Math.min(bounds.y, -y);
		bounds.width = Math.max(bounds.x + bounds.width, x) - bounds.x;
		bounds.height = Math.max(bounds.y + bounds.height, -y) - bounds.y;
	}

	private void updateBounds(final java.awt.geom.Rectangle2D.Double bounds, final double x, final double y,
	        final Annotation a, final Graphics g) {
		if (a == null) { return; }
		final AnnotationGraphics annotationGraphics = a.getAnnotationGraphics();
		if (annotationGraphics != null && a.getText() != null && !"".equals(a.getText())) {
			final double w = getWidth(a, g);
			final double h = getHeight(a);
			updateBounds(bounds, x + annotationGraphics.getOffset().getX() - w / 2.0, y
			        + annotationGraphics.getOffset().getY() - h / 2.0);
			updateBounds(bounds, x + annotationGraphics.getOffset().getX() + w / 2.0, y
			        + annotationGraphics.getOffset().getY() + h / 2.0);
		}
	}

	private void updateBounds(final java.awt.geom.Rectangle2D.Double bounds, final Node n, final Graphics g) {
		final NodeGraphics nodeGraphics = n.getNodeGraphics();
		if (nodeGraphics != null) {
			updateBounds(bounds, nodeGraphics.getPosition().getX() - nodeGraphics.getDimension().getX() / 2.0,
			        nodeGraphics.getPosition().getY() - nodeGraphics.getDimension().getY() / 2.0);
			updateBounds(bounds, nodeGraphics.getPosition().getX() + nodeGraphics.getDimension().getX() / 2.0,
			        nodeGraphics.getPosition().getY() + nodeGraphics.getDimension().getY() / 2.0);
			for (final Label l : n.getLabel()) {
				if (l instanceof Annotation) {
					updateBounds(bounds, nodeGraphics.getPosition().getX(), nodeGraphics.getPosition().getY(),
					        (Annotation) l, g);
				}
			}
		}
	}

}
