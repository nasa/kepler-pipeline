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

import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.ui.swing.ToolTableModel;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A table model for the delta quaternion export.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class DeltaQuaternionTableModel extends ToolTableModel {

    public static enum Column {
        INSTANCE_ID(Long.class),
        START(Date.class),
        X(Double.class),
        Y(Double.class),
        Z(Double.class),
        W(Double.class),
        ERROR(Double.class);

        private static ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(DeltaQuaternionTableModel.class);
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
    private List<AttitudeAdjustment> entries = new ArrayList<AttitudeAdjustment>();
    private List<Date> dates = new ArrayList<Date>();

    /**
     * Returns the delta quaternions that this model is handling.
     * 
     * @return the delta quaternions
     */
    public List<AttitudeAdjustment> getDeltaQuaternions() {
        return entries;
    }

    /**
     * Sets the delta quaternions (and their dates) that this model is handling.
     * <p>
     * The conversion from {@code refPixelFileTime} to {@link Date} involves a
     * database lookup so it must be done in advance. If the
     * {@code refPixelFileTime} is ever converted to a type that doesn't require
     * a database lookup, then the {@code dates} parameter can be eliminated.
     * 
     * @param deltaQuaternions the delta quaternions that this model is handling
     * @param dates the {@link Date} objects that correspond to each of the
     * {@code refPixelFileTime} fields
     * @throws NullPointerException if {@code deltaQuaternions} or {@code dates}
     * are {@code null}
     */
    public void setDeltaQuaternions(List<AttitudeAdjustment> deltaQuaternions,
        List<Date> dates) {
        if (deltaQuaternions == null) {
            throw new NullPointerException("deltaQuaternions can't be null");
        }
        if (dates == null) {
            throw new NullPointerException("dates can't be null");
        }
        entries = deltaQuaternions;
        this.dates = dates;
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
        return entries.size();
    }

    @Override
    public Object getValueAt(int row) {
        return entries.get(row);
    }

    @Override
    public Object getValueAt(int row, int column) {
        AttitudeAdjustment entry = entries.get(row);
        switch (columns[column]) {
            case INSTANCE_ID:
                return entry.getPipelineTask()
                    .getPipelineInstance()
                    .getId();
            case START:
                return dates.get(row);
            case X:
                return entry.getX();
            case Y:
                return entry.getY();
            case Z:
                return entry.getZ();
            case W:
                return entry.getW();
            case ERROR:
                return entry.getX() * entry.getX() + entry.getY()
                    * entry.getY() + entry.getZ() * entry.getZ() + entry.getW()
                    * entry.getW() - 1.0;
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }
}
