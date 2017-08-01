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

package gov.nasa.kepler.ui.gar;

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.ui.swing.ToolTableModel;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A table model for choosing target list sets for export.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListSetTableModel extends ToolTableModel {

    public static final Long NO_DATA = -1L;

    public static enum Column {
        TARGET_DATABASE_ID(Long.class),
        APERTURE_DATABASE_ID(Long.class),
        NAME(String.class),
        START(Date.class),
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

    private Column[] columns = Column.values();
    private List<TargetListSet> targetListSets = new ArrayList<TargetListSet>();

    /**
     * Returns the target list sets that this model is handling.
     * 
     * @return the target list sets
     */
    public List<TargetListSet> getTargetListSets() {
        return targetListSets;
    }

    /**
     * Sets the target list sets that this model is handling.
     * 
     * @param targetListSets the target list sets that this model is handling
     * @throws NullPointerException if {@code targetListSets} is {@code null}
     */
    public void setTargetListSets(List<TargetListSet> targetListSets) {
        if (targetListSets == null) {
            throw new NullPointerException("targetListSets can't be null");
        }
        this.targetListSets = targetListSets;
        fireTableDataChanged();
    }

    @Override
    public int getColumnCount() {
        return columns.length;
    }

    @Override
    public String getColumnName(int column) {
        return columns[column].getColumnName();
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
    public int getRowCount() {
        return targetListSets.size();
    }

    @Override
    public Object getValueAt(int row) {
        return targetListSets.get(row);
    }

    @Override
    public Object getValueAt(int row, int column) {
        TargetListSet targetListSet = targetListSets.get(row);
        switch (columns[column]) {
            case TARGET_DATABASE_ID:
                return targetListSet.getTargetTable() != null ? targetListSet.getTargetTable()
                    .getId()
                    : NO_DATA;
            case APERTURE_DATABASE_ID:
                return targetListSet.getTargetTable() != null
                    && targetListSet.getTargetTable()
                        .getMaskTable() != null ? targetListSet.getTargetTable()
                    .getMaskTable()
                    .getId()
                    : NO_DATA;
            case NAME:
                return targetListSet.getName();
            case START:
                return targetListSet.getStart();
            case UPLINKED:
                return targetListSet.getState() == State.UPLINKED;
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }
}
