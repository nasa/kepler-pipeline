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

import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.RequantTableDescriptor;
import gov.nasa.kepler.ui.swing.ToolTableModel;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A table model for the requantization table export.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class RequantTableDescriptorModel extends ToolTableModel {

    public static enum Column {
        INSTANCE_ID(Long.class),
        TASK_ID(Long.class),
        START(Date.class),
        UPLINKED(Boolean.class),
        EXTERNAL_ID(Integer.class);

        private static ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(RequantTableDescriptorModel.class);
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
    }

    private Column[] columns = Column.values();
    private List<RequantTableDescriptor> requantTableDescriptors = new ArrayList<RequantTableDescriptor>();

    /**
     * Returns the requantization table descriptors that this model is handling.
     * 
     * @return the requantization table descriptors
     */
    public List<RequantTableDescriptor> getRequantTables() {
        return requantTableDescriptors;
    }

    /**
     * Sets the requantization table descriptors that this model is handling.
     * 
     * @param requantTableDescriptors the requantization table descriptors that
     * this model is handling
     * @throws NullPointerException if {@code requantTableDescriptors} is
     * {@code null}
     */
    public void setRequantTableDescriptors(
        List<RequantTableDescriptor> requantTableDescriptors) {
        if (requantTableDescriptors == null) {
            throw new NullPointerException(
                "requantTableDescriptors can't be null");
        }
        this.requantTableDescriptors = requantTableDescriptors;
        fireTableDataChanged();
    }

    /**
     * Replace the given requantization table descriptor with a new one.
     * 
     * @param oldRequantTableDescriptor the old requantization table descriptor
     * @param requantTableDescriptor the new requantization table descriptor
     * @throws NullPointerException if either {@code oldRequantTableDescriptor}
     * or {@code requantTableDescriptor} is {@code null}
     * @throws IllegalStateException if {@code oldRequantTableDescriptor} isn't
     * present in the model
     */
    public void replace(RequantTableDescriptor oldRequantTableDescriptor,
        RequantTableDescriptor requantTableDescriptor) {

        int row = requantTableDescriptors.indexOf(oldRequantTableDescriptor);
        if (row == -1) {
            throw new IllegalStateException(oldRequantTableDescriptor
                + ": no such descriptor");
        }

        requantTableDescriptors.set(row, requantTableDescriptor);
        fireTableRowsUpdated(row, row);
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
        return requantTableDescriptors.size();
    }

    @Override
    public Object getValueAt(int row) {
        return requantTableDescriptors.get(row);
    }

    @Override
    public Object getValueAt(int row, int column) {
        RequantTableDescriptor requantTableDescriptor = requantTableDescriptors.get(row);
        switch (columns[column]) {
            case INSTANCE_ID:
                return requantTableDescriptor.getPipelineInstanceId();
            case TASK_ID:
                return requantTableDescriptor.getPipelineTaskId();
            case START:
                return requantTableDescriptor.getPlannedStartTime();
            case UPLINKED:
                return requantTableDescriptor.getState() == State.UPLINKED;
            case EXTERNAL_ID:
                return requantTableDescriptor.getExternalId();
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }

    /**
     * Refresh the given requantization table descriptor. Call this if a
     * requantization table is updated and you want to update the view.
     * 
     * @param requantTableDescriptor the requantization table descriptor
     * @throws NullPointerException if {@code requantTable} is {@code null}
     */
    public void refresh(RequantTableDescriptor requantTableDescriptor) {
        int row = requantTableDescriptors.indexOf(requantTableDescriptor);
        fireTableRowsUpdated(row, row);
    }

}
