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

package gov.nasa.kepler.ui.swing;

import gov.nasa.kepler.common.Iso8601Formatter;

import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Point;
import java.awt.event.ActionEvent;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Formatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.swing.Action;
import javax.swing.Icon;
import javax.swing.JLabel;
import javax.swing.JPopupMenu;
import javax.swing.JTable;
import javax.swing.KeyStroke;
import javax.swing.ListSelectionModel;
import javax.swing.Scrollable;
import javax.swing.SwingConstants;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import javax.swing.table.DefaultTableCellRenderer;
import javax.swing.table.JTableHeader;
import javax.swing.table.TableCellRenderer;
import javax.swing.table.TableColumn;
import javax.swing.table.TableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.bushe.swing.event.EventBus;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A table that has been customized to work well in a {@link ToolPanel}. It
 * takes advantage of {@link ToolPanel} methods to populate its context menu,
 * for example. All KSOC tables should subclass this class to ensure a common
 * look and feel and good aesthetics.
 * <p>
 * This class publishes the list of objects that represent the selected rows on
 * the {@link EventBus}. This list will be empty if there isn't a selection. The
 * topic name used is {@link #getSelectionTopic()}.
 * <p>
 * By default, dates are displayed in ISO 8601 date format. Call
 * {@link #setTimeDisplayed(boolean)} to display dates in ISO 8601 combined
 * date/time format.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD_STORE")
public class ToolTable extends JTable {

    private final Log log = LogFactory.getLog(getClass());

    /** Preferred width of this table. */
    private static final int MAX_PREFFERRED_WIDTH = 500;

    /** Preferred height of this table. */
    private static final int MAX_PREFFERRED_HEIGHT = 300;

    /** Pad heading string with an em on either side. */
    private static final int HEADING_MARGIN = KeplerSwingUtilities.textWidth(
        new JLabel(), "MM");

    /**
     * This string is part of the topic that is published when an item is
     * selected or deselected and can be used as a pattern to subscribe to
     * selection events. The published data includes a non-null list of objects
     * that represent the selected rows; this list will be empty if there isn't
     * a selection.
     */
    public static final String SELECT = "selectedItem";

    /**
     * A Boolean renderer that displays images. See
     * {@link #setBooleanRenderer(int)}.
     */
    public static final int IMAGE_BOOLEAN_RENDERER = 0;

    private ResourceMap resourceMap = Application.getInstance()
        .getContext()
        .getResourceMap(getClass());
    private ListSelectionListener toolTableSelectionListener = new ToolTableSelectionListener();
    private DecimalRenderer decimalRenderer = new DecimalRenderer();
    private DateRenderer dateRenderer = new DateRenderer();
    private BooleanRenderer booleanRenderer;

    /**
     * Creates a {@link ToolTable} with the given {@link ToolPanel}.
     */
    public ToolTable(ToolPanel toolPanel) {
        this(null, toolPanel);
    }

    /**
     * Creates a {@link ToolTable} with the given {@link ToolTableModel} and
     * {@link ToolPanel}.
     */
    public ToolTable(ToolTableModel model, ToolPanel toolPanel) {
        if (model != null) {
            setModel(model);
        }
        if (getTableHeader() != null) {
            ((JLabel) getTableHeader().getDefaultRenderer()).setHorizontalAlignment(SwingConstants.CENTER);
        }
        setDefaultRenderer(Float.class, decimalRenderer);
        setDefaultRenderer(Double.class, decimalRenderer);
        setDefaultRenderer(Date.class, dateRenderer);
        setBackground(Color.WHITE);
        setGridColor(Color.LIGHT_GRAY);
        getSelectionModel().addListSelectionListener(toolTableSelectionListener);
        configureDefaultAction(toolPanel.getDefaultAction());
        createPopupMenu(toolPanel);
    }

    @Override
    public void setModel(TableModel model) {
        super.setModel(model);
        if (getTableHeader() != null) {
            setColumnWidths();
        }
    }

    /**
     * Sets appropriate column widths for the content. Ensures that all columns
     * of a particular type are all the same width for aesthetical reasons.
     */
    private void setColumnWidths() {
        TableModel model = getModel();
        TableCellRenderer headerRenderer = getTableHeader().getDefaultRenderer();
        Map<Class<?>, Integer> minWidthMap = new HashMap<Class<?>, Integer>();
        Map<Class<?>, Integer> maxWidthMap = new HashMap<Class<?>, Integer>();

        // Calculate columns widths.
        for (int i = 0, n = model.getColumnCount(); i < n; i++) {
            // Let String columns fill available space; otherwise, create an
            // object in order to determine the column's minimum width.
            Class<?> clazz = model.getColumnClass(i);
            Object cellObject = "";
            boolean alwaysFillsColumn = false;

            if (clazz == String.class) {
                continue;
            } else if (clazz == Integer.class) {
                cellObject = Integer.valueOf(Integer.MAX_VALUE);
            } else if (clazz == Long.class) {
                cellObject = Long.valueOf(Long.MAX_VALUE);
            } else if (clazz == Float.class || clazz == Double.class) {
                cellObject = Float.valueOf(Float.MAX_VALUE);
            } else if (clazz == Boolean.class) {
                cellObject = Boolean.TRUE;
            } else if (clazz == Date.class) {
                cellObject = new Date();
                alwaysFillsColumn = true;
            }

            // Otherwise, try to scrunch column around heading or content.
            TableColumn column = getColumnModel().getColumn(i);

            Component comp = headerRenderer.getTableCellRendererComponent(null,
                column.getHeaderValue(), false, false, 0, 0);
            int headerWidth = comp.getPreferredSize().width + HEADING_MARGIN;

            comp = getDefaultRenderer(clazz).getTableCellRendererComponent(
                this, cellObject, false, false, 0, i);
            int cellWidth = comp.getPreferredSize().width;
            if (alwaysFillsColumn) {
                // Allow for intercell spacing, plus add some breathing room.
                cellWidth += 2 * getIntercellSpacing().width + 12;
            }

            log.debug("Column " + i + ": name=" + model.getColumnName(i)
                + ", headerWidth=" + headerWidth + ", cellWidth=" + cellWidth);
            Integer width = minWidthMap.get(clazz);
            minWidthMap.put(clazz, Math.max(width != null ? width : 0,
                alwaysFillsColumn ? Math.max(headerWidth, cellWidth)
                    : headerWidth));
            width = maxWidthMap.get(clazz);
            maxWidthMap.put(
                clazz,
                Math.max(width != null ? width : 0,
                    Math.max(headerWidth, cellWidth)));
        }

        // Set column widths.
        for (int i = 0, n = model.getColumnCount(); i < n; i++) {
            Class<?> clazz = model.getColumnClass(i);
            TableColumn column = getColumnModel().getColumn(i);
            Integer width = minWidthMap.get(clazz);
            if (width != null) {
                column.setMinWidth(width);
            }
            width = maxWidthMap.get(clazz);
            if (width != null) {
                // Ensure that columns will always fill table. All columns will
                // be proportionally reduced to fit within the table.
                column.setMaxWidth(100 * width);
            }
        }
    }

    /**
     * Make ENTER run the default action.
     * 
     * @param defaultAction the default {@link Action}
     */
    private void configureDefaultAction(Action defaultAction) {
        getInputMap().put(KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, 0),
            "default");
        getActionMap().put("default", defaultAction);
    }

    /**
     * Creates a popup menu for the table.
     */
    private void createPopupMenu(final ToolPanel toolPanel) {
        final JPopupMenu menu = toolPanel.getPopupMenu();
        final Component parent = this;

        addMouseListener(new java.awt.event.MouseAdapter() {
            @Override
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (e.getClickCount() == 2) {
                    adjustSelection(e);
                    if (toolPanel.getDefaultAction() != null) {
                        toolPanel.getDefaultAction()
                            .actionPerformed(
                                new ActionEvent(parent,
                                    ActionEvent.ACTION_PERFORMED, null));
                    }
                }
                mouseReleased(e);
            }

            @Override
            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger()) {
                    adjustSelection(e);
                    if (menu != null) {
                        menu.show(parent, e.getX(), e.getY());
                    }
                }
            }
        });
    }

    /**
     * Returns a unique {@link EventBus} selection topic name for this table.
     * This topic is used by the table to broadcast selection changes.
     * 
     * @return a topic
     */
    public String getSelectionTopic() {
        return getModel().getClass()
            .getName() + "@" + hashCode() + "." + SELECT;
    }

    /**
     * Adjusts the selection. Useful for popup triggers; for some reason the
     * right mouse button doesn't modify the selection by default.
     * <p>
     * If the mouse is over a row that is already selected, then do not adjust
     * the selection since the leads to surprising behavior; otherwise, update
     * the selection normally.
     * 
     * @param e the mouse event
     */
    private void adjustSelection(MouseEvent e) {
        int row = rowAtPoint(e.getPoint());
        if (isRowSelected(row)) {
            return;
        }

        int column = columnAtPoint(e.getPoint());
        changeSelection(row, column, e.isControlDown(), e.isShiftDown());
    }

    @Override
    protected JTableHeader createDefaultTableHeader() {
        return new JTableHeader(columnModel) {
            @Override
            public String getToolTipText(MouseEvent e) {
                Point p = e.getPoint();
                int index = columnModel.getColumnIndexAtX(p.x);
                int realIndex = columnModel.getColumn(index)
                    .getModelIndex();
                return ((ToolTableModel) getModel()).getColumnTip(realIndex);
            }
        };
    }

    /**
     * Returns the preferred size of the viewport for this table limited to
     * {@value #MAX_PREFFERRED_WIDTH} x {@value #MAX_PREFFERRED_HEIGHT}.
     * 
     * @return a {@code Dimension} object containing the {@code preferredSize}
     * of the {@code JViewport} which displays this table
     * @see Scrollable#getPreferredScrollableViewportSize()
     */
    @Override
    public Dimension getPreferredScrollableViewportSize() {
        Dimension size = super.getPreferredScrollableViewportSize();
        return new Dimension(Math.min(size.width, MAX_PREFFERRED_WIDTH),
            Math.min(size.height, MAX_PREFFERRED_HEIGHT));
    }

    /**
     * Returns the current format in {@link Float} and {@link Double} cells.
     */
    public String getFormat() {
        return decimalRenderer.getFormat();
    }

    /**
     * Sets the format in {@link Float} and {@link Double} cells.
     */
    public void setFormat(String format) {
        decimalRenderer.setFormat(format);
        setColumnWidths();
    }

    /**
     * Returns whether the time is shown or not in {@link Date} cells.
     */
    public boolean isTimeDisplayed() {
        return dateRenderer.isTimeDisplayed();
    }

    /**
     * Sets whether the time is shown or not in {@link Date} cells.
     */
    public void setTimeDisplayed(boolean timeDisplayed) {
        dateRenderer.setTimeDisplayed(timeDisplayed);
        setColumnWidths();
    }

    /**
     * Change the renderer that displays {@link Boolean} values.
     * 
     * @param rendererType only {@link #IMAGE_BOOLEAN_RENDERER} is implemented
     * at this time
     */
    public void setBooleanRenderer(int rendererType) {
        switch (rendererType) {
            case IMAGE_BOOLEAN_RENDERER:
                if (booleanRenderer == null) {
                    booleanRenderer = new BooleanRenderer(resourceMap);
                }
                setDefaultRenderer(Boolean.class, booleanRenderer);
        }
    }

    /**
     * Returns whether the icon for false is shown or not. This method can only
     * be used if {@code setBooleanRenderer(IMAGE_BOOLEAN_RENDERER)} has been
     * called.
     * 
     * @throws IllegalStateException if this operation isn't supported by the
     * current renderer
     */
    public boolean isHideFalseIcon() {
        if (booleanRenderer == null) {
            throw new IllegalStateException(
                "Need to call setBooleanRenderer(IMAGE_BOOLEAN_RENDERER) first");
        }
        return booleanRenderer.isHideFalseIcon();
    }

    /**
     * Show false icon if {@code hideFalseIcon} is true. This method can only be
     * used if {@code setBooleanRenderer(IMAGE_BOOLEAN_RENDERER)} has been
     * called.
     * 
     * @throws IllegalStateException if this operation isn't supported by the
     * current renderer
     * 
     */
    public void setHideFalseIcon(boolean hideFalseIcon) {
        if (booleanRenderer == null) {
            throw new IllegalStateException(
                "Need to call setBooleanRenderer(IMAGE_BOOLEAN_RENDERER) first");
        }
        booleanRenderer.setHideFalseIcon(hideFalseIcon);
    }

    /**
     * Returns whether the icon for true is shown or not. This method can only
     * be used if {@code setBooleanRenderer(IMAGE_BOOLEAN_RENDERER)} has been
     * called.
     * 
     * @throws IllegalStateException if this operation isn't supported by the
     * current renderer
     * 
     */
    public boolean isHideTrueIcon() {
        if (booleanRenderer == null) {
            throw new IllegalStateException(
                "Need to call setBooleanRenderer(IMAGE_BOOLEAN_RENDERER) first");
        }
        return booleanRenderer.isHideTrueIcon();
    }

    /**
     * Show true icon if {@code hideTrueIcon} is true. This method can only be
     * used if {@code setBooleanRenderer(IMAGE_BOOLEAN_RENDERER)} has been
     * called.
     * 
     * @throws IllegalStateException if this operation isn't supported by the
     * current renderer
     * 
     */
    public void setHideTrueIcon(boolean hideTrueIcon) {
        if (booleanRenderer == null) {
            throw new IllegalStateException(
                "Need to call setBooleanRenderer(IMAGE_BOOLEAN_RENDERER) first");
        }
        booleanRenderer.setHideTrueIcon(hideTrueIcon);
    }

    /**
     * A listener that publishes selection events.
     * 
     * @author Bill Wohler
     */
    private class ToolTableSelectionListener implements ListSelectionListener {

        @Override
        public void valueChanged(ListSelectionEvent e) {
            if (e.getValueIsAdjusting()) {
                return;
            }

            // Publish a list of the names of the selected rows, or an empty
            // list if there aren't any selected items.
            ListSelectionModel lsm = (ListSelectionModel) e.getSource();
            List<Object> selection = null;
            if (lsm.isSelectionEmpty()) {
                selection = Collections.emptyList();
            } else {
                ToolTableModel model = (ToolTableModel) getModel();
                selection = new ArrayList<Object>();
                int[] rows = getSelectedRows();
                for (int row : rows) {
                    selection.add(model.getValueAt(row));
                }
            }
            EventBus.publish(getSelectionTopic(), selection);
        }
    }

    /**
     * A custom renderer for {@link Float} and {@link Double} objects. By
     * default, numbers are displayed with a "%g.4" format string. Call
     * {@link #setFormat(String)} to use a different format.
     * 
     * @see Formatter
     * @author Bill Wohler
     */
    private static class DecimalRenderer extends
        DefaultTableCellRenderer.UIResource {

        private String format = "%.4g";

        @Override
        public void setValue(Object value) {
            if (value == null || value.equals("")) {
                return;
            }
            setText(String.format(format, value));
        }

        /**
         * Returns the current format.
         */
        public String getFormat() {
            return format;
        }

        /**
         * Sets the format.
         */
        public void setFormat(String format) {
            this.format = format;
        }
    }

    /**
     * A custom renderer for {@link Date} objects. By default, dates are
     * displayed in ISO 8601 date format. Call
     * {@link #setTimeDisplayed(boolean)} to display dates in ISO 8601 combined
     * date/time format.
     * 
     * @author Bill Wohler
     */
    private static class DateRenderer extends
        DefaultTableCellRenderer.UIResource {

        private static final String NO_DATA = "-";

        private boolean timeDisplayed;
        private DateFormat iso8601DateFormat = Iso8601Formatter.dateFormatter();
        private DateFormat iso8601DateTimeFormat = Iso8601Formatter.dateTimeFormatter();

        public DateRenderer() {
            setHorizontalAlignment(SwingConstants.CENTER);
        }

        @Override
        public void setValue(Object value) {
            if (value == null || value.equals("")) {
                setText(NO_DATA);
                return;
            }
            Date date = (Date) value;
            if (timeDisplayed) {
                setText(iso8601DateTimeFormat.format(date));
            } else {
                setText(iso8601DateFormat.format(date));
            }
        }

        /**
         * Returns whether the time is shown or not.
         */
        public boolean isTimeDisplayed() {
            return timeDisplayed;
        }

        /**
         * Sets whether the time is shown or not.
         */
        public void setTimeDisplayed(boolean timeDisplayed) {
            this.timeDisplayed = timeDisplayed;
        }
    }

    /**
     * A custom renderer for Boolean objects. Displays a checkmark if the cell's
     * value is {@code true}; an X if the cell's value is {@code false}.
     * <p>
     * The actual icons used can be changed by changing the value of the
     * following resources in <i>ToolTable.properties</i>:
     * <dl>
     * <dt>{@code true.icon}
     * <dd>The image used to render a value of {@code true}.
     * <dt>{@code false.icon}
     * <dd>The image used to render a value of {@code false}.
     * </dl>
     * 
     * @author Bill Wohler
     */
    private static class BooleanRenderer extends
        DefaultTableCellRenderer.UIResource {

        private boolean hideTrueIcon;
        private boolean hideFalseIcon;

        private Icon trueImage;
        private Icon falseImage;

        public BooleanRenderer(ResourceMap resourceMap) {
            trueImage = resourceMap.getIcon("true.icon");
            falseImage = resourceMap.getIcon("false.icon");

            setHorizontalAlignment(SwingConstants.CENTER);
        }

        @Override
        public void setValue(Object value) {
            if (value != null && !((Boolean) value).booleanValue()
                && !hideFalseIcon) {
                setIcon(falseImage);
            } else if (value != null && ((Boolean) value).booleanValue()
                && !hideTrueIcon) {
                setIcon(trueImage);
            } else {
                setIcon(null);
            }
        }

        /**
         * Returns whether the icon for false is shown or not.
         */
        public boolean isHideFalseIcon() {
            return hideFalseIcon;
        }

        /**
         * Show false icon if {@code hideFalseIcon} is true.
         */
        public void setHideFalseIcon(boolean hideFalseIcon) {
            this.hideFalseIcon = hideFalseIcon;
        }

        /**
         * Returns whether the icon for true is shown or not.
         */
        public boolean isHideTrueIcon() {
            return hideTrueIcon;
        }

        /**
         * Show true icon if {@code hideTrueIcon} is true.
         */
        public void setHideTrueIcon(boolean hideTrueIcon) {
            this.hideTrueIcon = hideTrueIcon;
        }
    }
}
