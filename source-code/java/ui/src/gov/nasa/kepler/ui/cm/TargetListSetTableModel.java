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

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.ui.swing.ToolTableModel;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.List;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A target list set model.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListSetTableModel extends ToolTableModel {
    private static enum Column {
        NAME(String.class),
        START(String.class),
        END(String.class),
        LOCKED(Boolean.class),
        UPLINKED(Boolean.class);

        private static ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(TargetListSetTableModel.class);
        private Class<?> clazz;

        private Column(Class<?> clazz) {
            this.clazz = clazz;
        }

        private String getColumnName() {
            return resourceMap.getString(toString().toLowerCase() + ".text");
        }

        private String getColumnTip() {
            return resourceMap.getString(toString().toLowerCase()
                + ".shortDescription");
        }

        private Class<?> getColumnClass() {
            return clazz;
        }
    };

    /**
     * What to display in the date field if a set doesn't have any target lists.
     */
    private static final String NO_DATE_CONTENT = "-";

    private Column[] columns;
    private List<TargetListSet> targetListSets = new ArrayList<TargetListSet>();

    private DateFormat dateFormat = Iso8601Formatter.dateFormatter();

    /**
     * Creates a {@link TargetListSetTableModel}.
     */
    public TargetListSetTableModel() {
        columns = Column.values();
    }

    public List<TargetListSet> getTargetListSets() {
        return targetListSets;
    }

    public void setTargetListSets(List<TargetListSet> targetListSets) {
        this.targetListSets = targetListSets;
        fireTableDataChanged();
    }

    @Override
    public Class<?> getColumnClass(int column) {
        return columns[column].getColumnClass();
    }

    @Override
    public String getColumnTip(int column) {
        return columns[column].getColumnTip();
    }

    @Override
    public String getColumnName(int column) {
        return columns[column].getColumnName();
    }

    @Override
    public int getColumnCount() {
        return columns.length;
    }

    @Override
    public int getRowCount() {
        return targetListSets.size();
    }

    /**
     * Returns a copy of the target list set at the given row. Since it is a
     * copy, you can modify it without affecting the data in the table.
     * 
     * @param row a non-negative row number
     * @return the target list set at that row
     */
    @Override
    public Object getValueAt(int row) {
        return targetListSets.get(row);
    }

    @Override
    public Object getValueAt(int row, int column) {
        TargetListSet targetListSet = (TargetListSet) getValueAt(row);
        switch (columns[column]) {
            case NAME:
                return targetListSet.getName();
            case START:
                return targetListSet.getStart() == null ? NO_DATE_CONTENT
                    : dateFormat.format(targetListSet.getStart());
            case END:
                return targetListSet.getEnd() == null ? NO_DATE_CONTENT
                    : dateFormat.format(targetListSet.getEnd());
            case LOCKED:
                return Boolean.valueOf(targetListSet.getState()
                    .locked());
            case UPLINKED:
                return Boolean.valueOf(targetListSet.getState()
                    .uplinked());
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }

    /**
     * Updates the given target list set and adds it to the model if it's new.
     * 
     * @param targetListSet the target list set
     * @throws NullPointerException if {@code targetListSet} is {@code null}
     */
    public void addOrUpdate(TargetListSet targetListSet) {
        // Find the target list set in the list using == instead of equals()
        // since it might have been renamed.
        int row = -1;
        int i = 0;
        for (TargetListSet t : targetListSets) {
            if (t == targetListSet) {
                row = i;
                break;
            }
            i++;
        }

        if (row < 0) {
            add(-1, targetListSet);
        } else {
            fireTableRowsUpdated(row, row);
        }
    }

    /**
     * Adds the given target list sets to the model.
     * 
     * @param newTargetListSets the target list sets to add
     */
    public void addAll(List<TargetListSet> newTargetListSets) {
        for (TargetListSet targetListSet : newTargetListSets) {
            if (!targetListSets.contains(targetListSet)) {
                add(-1, targetListSet);
            }
        }
    }

    /**
     * Inserts the given target list set to the model <b>after</b> the specified
     * target list set. Be aware that this behavior differs from
     * {@link List#add(int, Object)} which normally inserts the object
     * <b>before</b> the given row.
     * 
     * @param targetListSet the target list set the new target list set should
     * follow
     * @param newTargetListSet the target list set to add
     * @throws IndexOutOfBoundsException if {@code targetListSet} isn't in the
     * list of target list sets
     */
    public void add(TargetListSet targetListSet, TargetListSet newTargetListSet) {
        int index = targetListSets.indexOf(targetListSet);
        if (index < 0) {
            throw new IndexOutOfBoundsException(String.format(
                "Index: %d, Size: %d", index, targetListSets.size()));
        }
        add(index + 1, newTargetListSet);
    }

    /**
     * Adds the given target list set to the model at the given row.
     * 
     * @param row the row to add target list set, or -1 if the target list set
     * should be appended to the end
     * @param targetListSet the target list to add
     */
    private void add(int row, TargetListSet targetListSet) {
        int actualRow = row;
        if (actualRow < 0) {
            // Append target list set.
            targetListSets.add(targetListSet);
            actualRow = getRowCount() - 1;
        } else {
            // Insert target list.
            targetListSets.add(actualRow, targetListSet);
        }

        // Update screen.
        fireTableRowsInserted(actualRow, actualRow);
    }

    /**
     * Deletes the given target list sets.
     * 
     * @param targetListSets the target list sets
     * @throws NullPointerException if {@code targetListSets} is {@code null}
     * @throws IndexOutOfBoundsException if any of the target list sets in
     * {@code targetListSets} isn't in the list of target list sets
     */
    public void delete(List<TargetListSet> targetListSets) {
        for (TargetListSet targetListSet : targetListSets) {
            delete(targetListSet);
        }
    }

    /**
     * Deletes the given target list set.
     * 
     * @param targetListSet the target list set
     * @throws IndexOutOfBoundsException if {@code targetListSet} isn't in the
     * list of target list sets
     */
    public void delete(TargetListSet targetListSet) {
        int row = targetListSets.indexOf(targetListSet);
        targetListSets.remove(row);
        fireTableRowsDeleted(row, row);
    }

    /**
     * Refresh the given target list sets. Call this if a target list set is
     * updated and you want to update the view.
     * 
     * @param targetListSets the target list sets
     * @throws NullPointerException if {@code targetListSets} is {@code null}
     */
    public void refresh(List<TargetListSet> targetListSets) {
        for (TargetListSet targetListSet : targetListSets) {
            int row = this.targetListSets.indexOf(targetListSet);
            fireTableRowsUpdated(row, row);
        }
    }
}
