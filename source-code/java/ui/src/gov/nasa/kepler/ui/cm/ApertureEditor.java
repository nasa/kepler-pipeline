/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.ui.cm;

import static java.lang.Math.abs;
import static java.lang.Math.ceil;
import static java.lang.Math.max;
import static java.lang.Math.min;
import gov.nasa.kepler.hibernate.tad.Offset;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Insets;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JPanel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * An editor for editing apertures.
 * <p>
 * In order to obtain the current value of the origin, monitor the property
 * "origin".
 * <p>
 * In order to pick up the current mouse location, monitor the property
 * {@link #MOUSE_OFFSET_PROPERTY}.
 * <p>
 * N.B. Unlike most coordinate systems that have x,y coordinates with 0,0 in the
 * upper left-hand corner, the world coordinate system here reverses the
 * coordinates by using row, column. In addition, the origin is in the lower
 * left-hand corner. To avoid confusion, or magnify it, the Point objects
 * mouseOffset and origin (in world coordinates) have the column and row in
 * their x and y fields respectively.
 * 
 * @author Bill Wohler
 * @author Todd Klaus
 */
@SuppressWarnings("serial")
public class ApertureEditor extends JPanel {
    /**
     * The property fired when the origin is moved. The value of the property is
     * a {@link Point}.
     * 
     * @see #getOrigin()
     */
    public static final String ORIGIN_PROPERTY = "origin";

    /**
     * The property fired when the offsets have been updated. The value of the
     * property is a {@code Collection<Offset>}
     * 
     * @see #getOffsets()
     */
    public static final String OFFSETS_PROPERTY = "offsets";

    /**
     * The property fired when the mouse is moved. The value of the property is
     * a {@link Point}.
     * 
     * @see #getMouseOffset()
     */
    public static final String MOUSE_OFFSET_PROPERTY = "mouseOffset";

    private static final Log log = LogFactory.getLog(ApertureEditor.class);

    private static final int DEFAULT_ROWS = 15;
    private static final int DEFAULT_COLUMNS = 15;
    private static final int MINIMUM_PIXEL_SIZE = 5;
    private static final int PREFERRED_PIXEL_SIZE = 20;
    private static final int MAXIMUM_PIXEL_SIZE = 40;
    private static final Color BACKGROUND_COLOR = new Color(229, 229, 229);
    private static final Color FOREGROUND_COLOR = Color.BLUE;
    private static final Color LINE_COLOR = Color.GRAY;
    private static final int LINE_WIDTH = 1;

    private boolean[][] pixelValues;
    private int currentPixelSize;
    private Dimension currentOffset;

    // Location where rubber-banding started in screen coordinates.
    private int rubberBandAnchorX = 0;
    private int rubberBandAnchorY = 0;

    // Location of mouse pointer during rubber-banding in screen coordinates.
    private int rubberBandX = 0;
    private int rubberBandY = 0;

    // Bound properties in world coordinates.
    private Point origin;
    private List<Offset> offsets;
    private Point mouseOffset;

    private boolean moveOrigin;
    private boolean calledFromUpdateOffsets;

    /**
     * Creates a ApertureEditor with of {@value #DEFAULT_ROWS} rows and
     * {@value #DEFAULT_COLUMNS} columns with no mask and the origin in the
     * middle.
     */
    public ApertureEditor() {
        this(new ArrayList<Offset>());
    }

    /**
     * Creates a ApertureEditor with a mask defined with the given offsets with
     * a minimum size of {@value #DEFAULT_ROWS} rows and
     * {@value #DEFAULT_COLUMNS} columns.
     * 
     * @param offsets the offsets relative to the origin
     * @throws NullPointerException if {@code offsets} is {@code null}
     */
    public ApertureEditor(List<Offset> offsets) {
        setOffsets(offsets);
        initComponents();
    }

    private void initComponents() {
        try {
            setBackground(BACKGROUND_COLOR);
            addMouseMotionListener(new MouseMotionAdapter() {
                @Override
                public void mouseDragged(MouseEvent evt) {
                    if (ApertureEditor.this.isEnabled()) {
                        updateMarquee(evt);
                    }
                }

                @Override
                public void mouseMoved(MouseEvent evt) {
                    if (ApertureEditor.this.isEnabled()) {
                        updateMouseLocation(evt);
                    }
                }
            });
            addMouseListener(new MouseAdapter() {
                @Override
                public void mouseReleased(MouseEvent evt) {
                    if (ApertureEditor.this.isEnabled()) {
                        marqueeToMask(evt);
                    }
                }

                @Override
                public void mousePressed(MouseEvent evt) {
                    if (ApertureEditor.this.isEnabled()) {
                        startMarquee(evt);
                    }
                }
            });
            repaint();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public Dimension getMaximumSize() {
        // log.debug(panelSize(MAXIMUM_PIXEL_SIZE));

        return panelSize(MAXIMUM_PIXEL_SIZE);
    }

    @Override
    public Dimension getMinimumSize() {
        // log.debug(panelSize(MINIMUM_PIXEL_SIZE));

        return panelSize(MINIMUM_PIXEL_SIZE);
    }

    @Override
    public Dimension getPreferredSize() {
        // log.debug(panelSize(PREFERRED_PIXEL_SIZE));

        return panelSize(PREFERRED_PIXEL_SIZE);
    }

    /**
     * Enforces a square panel.
     * 
     * @see Component#setBounds(int, int, int, int)
     */
    @Override
    public void setBounds(int x, int y, int width, int height) {
        Dimension maxSize = panelSize(width, height);
        super.setBounds(x, y, maxSize.width, maxSize.height);
    }

    @Override
    public void setBounds(Rectangle r) {
        this.setBounds(r.x, r.y, r.width, r.height);
    }

    /**
     * Gets the offsets corresponding to the set pixels in this
     * {@link ApertureEditor}.
     * 
     * @return a non-{@code null} list of offsets relative to the origin
     */
    public List<Offset> getOffsets() {
        log.debug("offsets=" + offsets);
        return offsets;
    }

    /**
     * Updates the pixels in this {@link ApertureEditor} using the given
     * offsets.
     * 
     * @param offsets the offsets relative to the origin
     * @throws NullPointerException if {@code offsets} is {@code null}
     */
    public void setOffsets(List<Offset> offsets) {
        log.debug("offsets=" + offsets);
        if (offsets == null) {
            throw new NullPointerException("offsets can't be null");
        }

        List<Offset> oldValue = this.offsets;
        this.offsets = offsets;

        if (offsets.size() == 0) {
            pixelValues = new boolean[DEFAULT_ROWS][DEFAULT_COLUMNS];
            origin = new Point(DEFAULT_COLUMNS / 2, DEFAULT_ROWS / 2);
        } else if (calledFromUpdateOffsets) {
            calledFromUpdateOffsets = false;
        } else {
            // Find min and max row and column offsets.
            int minRow = Integer.MAX_VALUE;
            int maxRow = Integer.MIN_VALUE;
            int minColumn = Integer.MAX_VALUE;
            int maxColumn = Integer.MIN_VALUE;
            for (Offset offset : offsets) {
                minRow = min(minRow, offset.getRow());
                maxRow = max(maxRow, offset.getRow());
                minColumn = min(minColumn, offset.getColumn());
                maxColumn = max(maxColumn, offset.getColumn());
            }

            // Use these limits to determine the size of the aperture.
            int rowLength = maxRow - minRow + 1;
            int columnLength = maxColumn - minColumn + 1;
            rowLength = max(rowLength, DEFAULT_ROWS);
            columnLength = max(columnLength, DEFAULT_COLUMNS);
            pixelValues = new boolean[rowLength][columnLength];

            // Try to get the origin as close as possible to the middle.
            int x = columnLength / 2;
            int y = rowLength / 2;
            if (maxRow > y) {
                y -= maxRow - y;
            } else if (minRow < -y) {
                y += -minRow - y;
            }
            if (maxColumn > x) {
                x -= maxColumn - x;
            } else if (minColumn < -x) {
                x += -minColumn - x;
            }
            origin = new Point(x, y);

            // Turn on the bits.
            for (Offset offset : offsets) {
                pixelValues[offset.getRow() + origin.y][offset.getColumn()
                    + origin.x] = true;
            }
        }

        repaint();
        firePropertyChange(OFFSETS_PROPERTY, oldValue, offsets);
    }

    /**
     * Updates the list of offsets from the current pixel values.
     */
    private void updateOffsets() {
        List<Offset> offsets = new ArrayList<Offset>();
        for (int i = 0; i < pixelValues.length; i++) {
            for (int j = 0; j < pixelValues[0].length; j++) {
                if (pixelValues[i][j]) {
                    Offset offset = new Offset(i - origin.y, j - origin.x);
                    offsets.add(offset);
                }
            }
        }
        calledFromUpdateOffsets = true;
        setOffsets(offsets);
    }

    /**
     * Gets whether mouse clicks move the origin or not.
     * 
     * @return {@code true} if a mouse click will move the origin
     */
    public boolean getMoveOrigin() {
        return moveOrigin;
    }

    /**
     * Sets whether mouse clicks move the origin or not.
     * 
     * @param moveOrigin {@code true} if a mouse click should move the origin
     */
    public void setMoveOrigin(boolean moveOrigin) {
        this.moveOrigin = moveOrigin;
    }

    public Point getMouseOffset() {
        return mouseOffset;
    }

    public void setMouseOffset(Point mouseOffset) {
        Point oldValue = this.mouseOffset;
        this.mouseOffset = mouseOffset;
        firePropertyChange(MOUSE_OFFSET_PROPERTY, oldValue, mouseOffset);
    }

    public Point getOrigin() {
        return origin;
    }

    public void setOrigin(Point origin) {
        Point oldValue = this.origin;
        this.origin = origin;
        firePropertyChange(ORIGIN_PROPERTY, oldValue, origin);
    }

    /**
     * Clears the display.
     */
    public void clear() {
        setOffsets(new ArrayList<Offset>());
    }

    /**
     * Returns a panelSize based upon the given pixelSize.
     * 
     * @param pixelSize the pixel size
     * @return a dimension of the panel that corresponds to the given pixel size
     */
    private Dimension panelSize(int pixelSize) {
        Insets insets = getInsets();
        return new Dimension(pixelValues[0].length * (pixelSize + LINE_WIDTH)
            + LINE_WIDTH + insets.left + insets.right, pixelValues.length
            * (pixelSize + LINE_WIDTH) + LINE_WIDTH + insets.top
            + insets.bottom);
    }

    /**
     * Returns a panelSize based upon the given width and height.
     * 
     * @return the largest panel that fits within the given bounds
     */
    private Dimension panelSize(int width, int height) {
        Insets insets = getInsets();
        int xPixelSize = (width - insets.left - insets.right - LINE_WIDTH)
            / pixelValues[0].length - LINE_WIDTH;
        int yPixelSize = (height - insets.top - insets.bottom - LINE_WIDTH)
            / pixelValues.length - LINE_WIDTH;

        return panelSize(min(xPixelSize, yPixelSize));
    }

    /**
     * Returns a pixelSize based upon the current panelSize.
     * 
     * @return a pixel size that allows the grid to be drawn in the given panel
     */
    private int pixelSize() {
        int pixelWidth = (getWidth() - LINE_WIDTH) / pixelValues[0].length
            - LINE_WIDTH;
        int pixelHeight = (getHeight() - LINE_WIDTH) / pixelValues.length
            - LINE_WIDTH;
        int pixelSize = min(pixelWidth, pixelHeight);

        log.debug(pixelSize);

        return pixelSize;
    }

    /**
     * Returns an offset for the origin of this drawing. This is calculated by
     * subtracting the drawing size and insets from the panel size.
     * 
     * @param pixelSize the size of an individual pixel
     * @return the actual inset
     */
    private Dimension offset(int pixelSize) {
        Insets insets = getInsets();
        Dimension drawingSize = panelSize(pixelSize);
        Dimension screenSize = getSize();
        int lineOffset = (int) ceil(LINE_WIDTH / 2);

        log.debug("insets=" + insets + ", drawing=" + drawingSize + ", screen="
            + screenSize + ", lineoffset=" + lineOffset);

        return new Dimension((screenSize.width - drawingSize.width) / 2
            + insets.left + lineOffset,
            (screenSize.height - drawingSize.height) / 2 + insets.top
                + lineOffset);
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        drawPixelGrid((Graphics2D) g);
        g.dispose();
    }

    /**
     * Draw the aperture.
     * 
     * @param g the graphics object
     */
    private void drawPixelGrid(Graphics2D g) {
        log.debug("start");

        int rows = pixelValues.length;
        int cols = pixelValues[0].length; // assume all rows same length
        currentPixelSize = pixelSize();
        currentOffset = offset(currentPixelSize);

        // Draw grid.
        g.setStroke(new BasicStroke(LINE_WIDTH));
        g.setColor(LINE_COLOR);
        int startX = currentOffset.width;
        int startY = currentOffset.height;
        int endX = startX + cols * (currentPixelSize + LINE_WIDTH);
        int endY = currentOffset.height;

        for (int i = 0; i <= rows; i++) {
            g.drawLine(startX, startY, endX, endY);
            startY += currentPixelSize + LINE_WIDTH;
            endY += currentPixelSize + LINE_WIDTH;
        }

        startX = currentOffset.width;
        startY = currentOffset.height;
        endX = currentOffset.width;
        endY = startY + rows * (currentPixelSize + LINE_WIDTH);
        for (int i = 0; i <= cols; i++) {
            g.drawLine(startX, startY, endX, endY);
            startX += currentPixelSize + LINE_WIDTH;
            endX += currentPixelSize + LINE_WIDTH;
        }

        // Fill in pixels.
        for (int row = 0; row < rows; row++) {
            for (int col = 0; col < cols; col++) {
                fillPixel(g, row, col, pixelValues[row][col]);
            }
        }

        // Mark origin.
        int leftX = getXForColumn(origin.x);
        int topY = getYForRow(origin.y);

        int rightX = leftX + currentPixelSize;
        int bottomY = topY + currentPixelSize;

        g.setColor(LINE_COLOR);
        g.drawLine(leftX, topY, rightX, bottomY);
        g.drawLine(leftX, bottomY, rightX + 1, topY);

        log.debug("end");
    }

    /**
     * Fill the given pixel.
     * 
     * @param row the pixel's row
     * @param column the pixel's column
     * @param foreground if {@code true} then the foreground color is used;
     * otherwise, the background color is used
     */
    private void fillPixel(Graphics2D g, int row, int column, boolean foreground) {
        int x = getXForColumn(column) + 1;
        int y = getYForRow(row) + 1;

        if (foreground) {
            g.setColor(FOREGROUND_COLOR);
        } else {
            g.setColor(BACKGROUND_COLOR);
        }
        g.fillRect(x, y, currentPixelSize, currentPixelSize);

    }

    /**
     * Start drawing the marquee upon a mouse pressed event.
     * 
     * @param e the mouse event
     */
    private void startMarquee(MouseEvent e) {
        log.debug("event=" + e);

        rubberBandAnchorX = e.getX();
        rubberBandAnchorY = e.getY();
        rubberBandX = e.getX();
        rubberBandY = e.getY();

        drawMarquee((Graphics2D) getGraphics());
    }

    /**
     * Update the marquee upon a mouse dragged event.
     * 
     * @param e the mouse event
     */
    private void updateMarquee(MouseEvent e) {
        log.debug("event=" + e);

        // Erase old.
        drawMarquee((Graphics2D) getGraphics());

        // Draw new.
        rubberBandX = e.getX();
        rubberBandY = e.getY();

        drawMarquee((Graphics2D) getGraphics());
    }

    private void marqueeToMask(MouseEvent e) {
        log.debug("event=" + e);

        // Erase marquee.
        drawMarquee((Graphics2D) getGraphics());

        if (moveOrigin) {
            // Moving origin.
            updateOriginLocation(e);
        } else {
            // Updating the mask.
            int startColumn = getColumnForX(min(rubberBandAnchorX, rubberBandX));
            int endColumn = getColumnForX(max(rubberBandAnchorX, rubberBandX));
            int startRow = getRowForY(max(rubberBandAnchorY, rubberBandY));
            int endRow = getRowForY(min(rubberBandAnchorY, rubberBandY));

            log.debug("selected = [" + startRow + ", " + startColumn + "] - ["
                + endRow + ", " + endColumn + "]");

            if (startColumn < 0 || startColumn >= pixelValues[0].length
                || endColumn < 0 || endColumn >= pixelValues[0].length
                || startRow < 0 || startRow >= pixelValues.length || endRow < 0
                || endRow >= pixelValues.length) {
                log.debug("selection out of range, ignoring");
                return;
            }

            for (int row = startRow; row <= endRow; row++) {
                for (int column = startColumn; column <= endColumn; column++) {
                    pixelValues[row][column] = !pixelValues[row][column];
                }
            }
        }
        updateOffsets();
    }

    /**
     * Returns the pixel row indicated by the given value.
     * 
     * @param y the pixel value in screen coordinates
     * @return the pixel value in world coordinates
     */
    private int getRowForY(int y) {
        return pixelValues.length - y / (currentPixelSize + LINE_WIDTH) - 1;
    }

    /**
     * Returns the pixel column indicated by the given value.
     * 
     * @param x the pixel value in screen coordinates
     * @return the pixel value in world coordinates
     */
    private int getColumnForX(int x) {
        return x / (currentPixelSize + LINE_WIDTH);
    }

    /**
     * Returns the pixel y coordinate indicated by the given value.
     * 
     * @param row the pixel value in world coordinates
     * @return the pixel value in screen coordinates
     */
    private int getYForRow(int row) {
        return currentOffset.height + LINE_WIDTH / 2
            + (pixelValues.length - row - 1) * (currentPixelSize + LINE_WIDTH);
    }

    /**
     * Returns the pixel x coordinate indicated by the given value.
     * 
     * @param column the pixel value in world coordinates
     * @return the pixel value in screen coordinates
     */
    private int getXForColumn(int column) {
        return currentOffset.width + LINE_WIDTH / 2 + column
            * (currentPixelSize + LINE_WIDTH);
    }

    /**
     * Draws a marquee as specified by the mouse motion.
     * 
     * @param g
     */
    private void drawMarquee(Graphics2D g) {
        g.setPaint(Color.WHITE);
        g.setXORMode(Color.BLACK);
        g.setStroke(new BasicStroke(1));
        int x = min(rubberBandAnchorX, rubberBandX);
        int y = min(rubberBandAnchorY, rubberBandY);
        int width = abs(rubberBandX - rubberBandAnchorX);
        int height = abs(rubberBandY - rubberBandAnchorY);

        log.debug("drawMarquee[" + x + "," + y + "," + width + "," + height
            + "]");

        g.drawRect(x, y, width, height);
    }

    /**
     * If the mouse moves, fire property events for mouseRowOffset and
     * mouseColumnOffset if they have changed.
     * 
     * @param e the mouse event
     */
    private void updateMouseLocation(MouseEvent e) {
        setMouseOffset(new Point(getColumnForX(e.getX()) - origin.x,
            getRowForY(e.getY()) - origin.y));
    }

    /**
     * If the origin moves, fire property events for originX and originY if they
     * have changed.
     * 
     * @param e the mouse event
     */
    private void updateOriginLocation(MouseEvent e) {
        setOrigin(new Point(getColumnForX(e.getX()), getRowForY(e.getY())));
        repaint();
    }
}
