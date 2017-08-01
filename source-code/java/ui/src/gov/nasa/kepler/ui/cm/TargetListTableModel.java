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

import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.DatabaseTaskService;
import gov.nasa.kepler.ui.proxy.TargetSelectionCrudProxy;
import gov.nasa.kepler.ui.swing.ToolTableModel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.generics.TypeReference;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A target list model. One view is simple and lists all target lists equally.
 * In another view, you can specify that targets within the list are included or
 * excluded from a particular set, let the user change this property, and later
 * ask this model for the current included and excluded targets. This class
 * manages this by creating a single list of an internal object (that contains a
 * target list and an include/exclude boolean) for viewing.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListTableModel extends ToolTableModel {

    /**
     * What to display in the used by field if a list isn't contained within any
     * target list sets.
     */
    private static final String NOT_IN_TARGET_SET_LIST = "-";

    public static enum Column {
        INCLUDE(Boolean.class),
        EXCLUDE(Boolean.class),
        NAME(String.class),
        COUNT(Integer.class),
        USED_BY(String.class);

        private static ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(TargetListTableModel.class);
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

    private Column[] columns;
    private List<Entry> entries = new ArrayList<Entry>();
    private List<TargetListSet> targetListSets = Collections.emptyList();
    private boolean editable;

    /**
     * Creates a {@link TargetListTableModel} with all of the target lists in
     * the database.
     */
    public TargetListTableModel() {
        columns = new Column[] { Column.NAME, Column.COUNT, Column.USED_BY };
    }

    /**
     * Creates a {@link TargetListTableModel} with the given target lists and
     * excluded target lists. Unless the table is sorted, excluded target lists
     * will be initially placed last.
     * 
     * @param targetLists a list of {@link TargetList}s that will have the
     * Include checkbox checked
     * @param excludedTargetLists a list of {@link TargetList}s that will have
     * the Exclude checkbox checked
     * @param editable if {@code true}, the checkboxes can be changed which has
     * the effect of moving the affected {@link TargetList} from one list to the
     * other
     */
    public TargetListTableModel(List<TargetList> targetLists,
        List<TargetList> excludedTargetLists, boolean editable) {

        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }
        if (excludedTargetLists == null) {
            throw new NullPointerException("excludedTargetLists can't be null");
        }
        columns = new Column[] { Column.INCLUDE, Column.EXCLUDE, Column.NAME,
            Column.COUNT };

        this.editable = editable;
        setTargetLists(targetLists, excludedTargetLists);
    }

    /**
     * Returns the target lists that this model is handling.
     * 
     * @return the target lists
     */
    public List<TargetList> getTargetLists() {
        return getTargetLists(true);
    }

    /**
     * Sets the target lists that this model is handling.
     * 
     * @throws NullPointerException if {@code targetLists} is {@code null}
     */
    public void setTargetLists(List<TargetList> targetLists) {
        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }

        updateTableData(targetLists, null);
    }

    /**
     * Returns the excluded target lists that this model is handling.
     * 
     * @return the excluded target lists
     */
    public List<TargetList> getExcludedTargetLists() {
        return getTargetLists(false);
    }

    /**
     * Helper method for get[Excluded]TargetLists.
     * 
     * @param include if {@code true}, return the included target lists; if
     * {@code false}, return the excluded target lists
     * @return the appropriate list of target lists; guaranteed to be non-
     * {@code null}
     */
    private List<TargetList> getTargetLists(boolean include) {
        List<TargetList> targetLists = new ArrayList<TargetList>();
        for (Entry entry : entries) {
            if (entry.isInclude() == include) {
                targetLists.add(entry.getTargetList());
            }
        }

        return targetLists;
    }

    /**
     * Sets the excluded target lists that this model is handling.
     * 
     * @throws NullPointerException if {@code targetLists} is {@code null}
     */
    public void setExcludedTargetLists(List<TargetList> targetLists) {
        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }

        updateTableData(null, targetLists);
    }

    /**
     * Sets both the included and excluded target lists that this model is
     * handling.
     * 
     * @throws NullPointerException if either {@code targetLists} or
     * {@code excludedTargetLists} is {@code null}
     */
    private void setTargetLists(List<TargetList> targetLists,
        List<TargetList> excludedTargetLists) {

        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }
        if (excludedTargetLists == null) {
            throw new NullPointerException("excludedTargetLists can't be null");
        }
        updateTableData(targetLists, excludedTargetLists);
    }

    /**
     * Creates a new list of entries based upon the current set of included and
     * excluded target lists and calls {@link #fireTableDataChanged()}.
     * 
     * @param targetLists the target lists to include; if {@code null}, the
     * existing target lists are left alone
     * @param excludedTargetLists the target lists to exclude; if {@code null},
     * the existing excluded target lists are left alone
     */
    private void updateTableData(List<TargetList> targetLists,
        List<TargetList> excludedTargetLists) {

        if (targetLists != null) {
            clearTargetLists(true);
            addTargetLists(targetLists, true);
        }
        if (excludedTargetLists != null) {
            clearTargetLists(false);
            addTargetLists(excludedTargetLists, false);
        }

        fireTableDataChanged();
        updateCountColumn(entries);
        updateUsedByColumn();
    }

    /**
     * Clear the desired target lists.
     * 
     * @param include if {@code true}, clear the included target lists; if
     * {@code false}, clear the excluded target lists
     */
    private void clearTargetLists(boolean include) {
        for (Iterator<Entry> i = entries.iterator(); i.hasNext();) {
            Entry entry = i.next();
            if (entry.isInclude() == include) {
                i.remove();
            }
        }
    }

    /**
     * Append the target lists per the {@code include} flag.
     * 
     * @param targetLists the target lists
     * @param include if {@code true}, the target lists will be shown with an
     * include checkbox; if {@code false}, the target lists will be shown with
     * an exclude checkbox
     */
    private void addTargetLists(List<TargetList> targetLists, boolean include) {
        for (TargetList targetList : targetLists) {
            entries.add(new Entry(targetList, include));
        }
    }

    /**
     * Updates the Used By column. Call this if a {@link TargetListSet} has been
     * added, deleted, or modified.
     */
    public void updateUsedByColumn() {
        if (Arrays.asList(columns)
            .contains(Column.USED_BY)) {
            DataRequestEvent<List<TargetListSet>> request = new DataRequestEvent<List<TargetListSet>>();
            EventBus.publish(
                new TypeReference<DataRequestEvent<List<TargetListSet>>>() {
                }.getType(), request);
            List<TargetListSet> result = request.getData();
            // The target list set panel must still be reloading if result is
            // null...
            if (result != null) {
                updateUsedByColumn(result);
            }
        }
    }

    /**
     * Updates the Used By column. This is meant to be called by the background
     * task which obtains a list of target list sets.
     * 
     * @see #updateUsedByColumn()
     * @param targetListSets a list of {@link TargetListSet}s
     * @throws NullPointerException if {@code targetListSets} is {@code null}
     */
    private void updateUsedByColumn(List<TargetListSet> targetListSets) {
        if (targetListSets == null) {
            throw new NullPointerException("targetListSets can't be null");
        }

        this.targetListSets = targetListSets;
        int column = columnOf(Column.USED_BY);
        for (int row = 0, n = entries.size(); row < n; row++) {
            fireTableCellUpdated(row, column);
        }
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
        return entries.size();
    }

    @Override
    public boolean isCellEditable(int row, int column) {
        return editable
            && (columns[column] == Column.INCLUDE || columns[column] == Column.EXCLUDE);
    }

    @Override
    public Object getValueAt(int row) {
        return entries.get(row)
            .getTargetList();
    }

    @Override
    public Object getValueAt(int row, int column) {
        Entry entry = entries.get(row);
        switch (columns[column]) {
            case INCLUDE:
                return entry.isInclude();
            case EXCLUDE:
                return !entry.isInclude();
            case NAME:
                return entry.getTargetList()
                    .getName();
            case COUNT:
                return entry.getCount();
            case USED_BY:
                return usedBy(entry.getTargetList());
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }

    /**
     * Returns comma-separated string of the names of target list sets that
     * contain the given target list. If the target list is not used by any
     * target list sets, then {@link #NOT_IN_TARGET_SET_LIST} (a "-") is
     * returned.
     * 
     * @param targetList the target list to check
     * @return a comma-separated string of the names of target list sets, or
     * {@link #NOT_IN_TARGET_SET_LIST} (a "-")
     */
    private String usedBy(TargetList targetList) {
        StringBuilder s = new StringBuilder();
        for (TargetListSet targetListSet : targetListSets) {
            if (targetListSet.getTargetLists()
                .contains(targetList) || targetListSet.getExcludedTargetLists()
                .contains(targetList)) {
                if (s.length() > 0) {
                    s.append(", ");
                }
                s.append(targetListSet.getName());
            }
        }
        if (s.length() == 0) {
            s.append(NOT_IN_TARGET_SET_LIST);
        }

        return s.toString();
    }

    @Override
    public void setValueAt(Object value, int row, int column) {
        switch (columns[column]) {
            case INCLUDE:
                entries.get(row)
                    .setInclude((Boolean) value);
                fireTableCellUpdated(row, columnOf(Column.INCLUDE));
                fireTableCellUpdated(row, columnOf(Column.EXCLUDE));
                break;
            case EXCLUDE:
                entries.get(row)
                    .setInclude(!(Boolean) value);
                fireTableCellUpdated(row, columnOf(Column.INCLUDE));
                fireTableCellUpdated(row, columnOf(Column.EXCLUDE));
                break;
            case USED_BY:
                fireTableCellUpdated(row, columnOf(Column.USED_BY));
                break;
            default:
                log.error("Unknown column index: " + column);
        }
    }

    /**
     * Returns the column number for the given column type.
     * 
     * @param column the column type
     * @return the column number
     * @throws IllegalStateException if the given column type isn't in this
     * model
     */
    public int columnOf(Column column) {
        int i = 0;
        for (Column c : columns) {
            if (c == column) {
                return i;
            }
            i++;
        }
        throw new IllegalStateException("Unknown column " + column);
    }

    /**
     * Updates the given target list and adds it to the model if it's new.
     * 
     * @param targetList the target list
     * @throws NullPointerException if {@code targetList} is {@code null}
     */
    public void addOrUpdate(TargetList targetList) {
        // Find the target list in the list using == instead of equals() since
        // it might have been renamed.
        Entry match = null;
        for (Entry entry : entries) {
            if (entry.getTargetList() == targetList) {
                match = entry;
                break;
            }
        }

        if (match == null) {
            add(-1, targetList);
        } else {
            int row = entries.indexOf(match);
            fireTableRowsUpdated(row, row);
            updateCountColumn(match);
        }
    }

    /**
     * Adds the given target lists to the model.
     * 
     * @param newTargetLists the target lists to add
     */
    public void addAll(List<TargetList> newTargetLists) {
        for (TargetList targetList : newTargetLists) {
            if (!entries.contains(new Entry(targetList))) {
                add(-1, targetList);
            }
        }
    }

    /**
     * Inserts the given target list to the model <b>after</b> the specified
     * target list. Be aware that this behavior differs from
     * {@link List#add(int, Object)} which normally inserts the object
     * <b>before</b> the given row.
     * 
     * @param targetList the target list the new target list should follow
     * @param newTargetList the target list to add
     */
    public void add(TargetList targetList, TargetList newTargetList) {
        add(entries.indexOf(new Entry(targetList)) + 1, newTargetList);
    }

    /**
     * Adds the given target list to the model at the given row.
     * 
     * @param row the row to add target list, or -1 if the target list should be
     * appended to the end
     * @param targetList the target list to add
     */
    private void add(int row, TargetList targetList) {
        Entry entry = new Entry(targetList);
        int actualRow = row;
        if (actualRow < 0) {
            // Append target list.
            entries.add(entry);
            actualRow = getRowCount() - 1;
        } else {
            // Insert target list.
            entries.add(actualRow, entry);
        }

        // Update screen and counts.
        fireTableRowsInserted(actualRow, actualRow);
        updateCountColumn(entry);
    }

    /**
     * Updates the Count column for the given target entry.
     * 
     * @param entry an {@link Entry}
     * @see #updateCountColumn(List)
     */
    private void updateCountColumn(Entry entry) {
        List<Entry> entries = new ArrayList<Entry>(1);
        entries.add(entry);
        updateCountColumn(entries);
    }

    /**
     * Updates the Count column. This methods starts a background thread to look
     * up the target counts.
     * 
     * @param targetLists a list of {@link TargetList}s
     */
    private void updateCountColumn(List<Entry> targetLists) {
        Application.getInstance()
            .getContext()
            .getTaskService(DatabaseTaskService.NAME)
            .execute(new TargetCountLoadTask(targetLists));
    }

    /**
     * Deletes the given target lists.
     * 
     * @param targetLists the target lists
     * @throws NullPointerException if {@code targetLists} is {@code null}
     */
    public void delete(List<TargetList> targetLists) {
        for (TargetList targetList : targetLists) {
            delete(targetList);
        }
    }

    /**
     * Deletes the given target list.
     * 
     * @param targetList the target lists
     * @throws ArrayIndexOutOfBoundsException if {@code targetList} isn't in the
     * list of target lists
     */
    public void delete(TargetList targetList) {
        int row = entries.indexOf(new Entry(targetList));
        entries.remove(row);
        fireTableRowsDeleted(row, row);
    }

    /**
     * A task for loading target counts from the database in the background.
     * 
     * @author Bill Wohler
     */
    private class TargetCountLoadTask extends
        DatabaseTask<Map<TargetList, Integer>, Void> {

        private static final String NAME = "TargetCountLoadTask";
        private List<Entry> entries;

        public TargetCountLoadTask(List<Entry> entries) {
            this.entries = entries;
        }

        @Override
        protected Map<TargetList, Integer> doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            Map<TargetList, Integer> targetCountByTargetListName = new HashMap<TargetList, Integer>();
            for (Entry entry : entries) {
                targetCountByTargetListName.put(
                    entry.getTargetList(),
                    targetSelectionCrud.plannedTargetCount(entry.getTargetList()));
            }

            return targetCountByTargetListName;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            String primary = resourceMap.getString(NAME + ".failed");
            String secondary = resourceMap.getString(
                NAME + ".failed.secondary", e.getMessage());
            log.error(primary + ": " + secondary, e);
        }

        @Override
        protected void succeeded(
            Map<TargetList, Integer> targetCountByTargetListName) {

            int column = columnOf(Column.COUNT);
            for (Entry entry : entries) {
                entry.setCount(targetCountByTargetListName.get(entry.getTargetList()));
                fireTableCellUpdated(
                    TargetListTableModel.this.entries.indexOf(entry), column);
            }
        }
    }

    /**
     * An entry that corresponds to a row in the table's view.
     */
    private static class Entry {
        private TargetList targetList;
        private boolean include;
        private int count = -1;

        public Entry(TargetList targetList) {
            this(targetList, true);
        }

        public Entry(TargetList targetList, boolean include) {
            this.targetList = targetList;
            this.include = include;
        }

        private TargetList getTargetList() {
            return targetList;
        }

        private boolean isInclude() {
            return include;
        }

        public void setInclude(boolean include) {
            this.include = include;
        }

        private synchronized int getCount() {
            return count;
        }

        private synchronized void setCount(int count) {
            this.count = count;
        }

        @Override
        public int hashCode() {
            final int PRIME = 31;
            int result = 1;
            result = PRIME * result
                + (targetList == null ? 0 : targetList.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (getClass() != obj.getClass()) {
                return false;
            }
            final Entry other = (Entry) obj;
            if (targetList == null) {
                if (other.targetList != null) {
                    return false;
                }
            } else if (!targetList.equals(other.targetList)) {
                return false;
            }
            return true;
        }
    }
}
