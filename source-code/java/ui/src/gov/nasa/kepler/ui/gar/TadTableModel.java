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
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TypedTable;
import gov.nasa.kepler.ui.swing.ToolTableModel;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;

/**
 * A table that displays {@link ExportTable}s.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TadTableModel extends ToolTableModel {

    public static enum Column {
        TLS_NAME(String.class),
        TYPE(String.class),
        START(Date.class),
        EXTERNAL_ID(Integer.class);

        private static ResourceMap resourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(TadTableModel.class);
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
    private List<Pair<ExportTable, TargetListSet>> tableTlsPairs = new ArrayList<Pair<ExportTable, TargetListSet>>();

    public List<Pair<ExportTable, TargetListSet>> getTableTlsPairs() {
        return tableTlsPairs;
    }

    public void setTables(List<Pair<ExportTable, TargetListSet>> tables) {
        this.tableTlsPairs = tables;
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
        return tableTlsPairs.size();
    }

    @Override
    public Object getValueAt(int row) {
        return tableTlsPairs.get(row);
    }

    @Override
    public Object getValueAt(int row, int column) {
        Pair<ExportTable, TargetListSet> tableTlsPair = tableTlsPairs.get(row);
        ExportTable table = tableTlsPair.left;
        switch (columns[column]) {
            case TLS_NAME:
                String name = "";
                TargetListSet targetListSet = tableTlsPair.right;
                if (targetListSet != null) {
                    name = targetListSet.getName();
                }
                return name;
            case TYPE:
                StringBuilder s = new StringBuilder();
                s.append(((TypedTable) table).getType()
                    .toString());
                if (table instanceof MaskTable) {
                    s.append(" aperture");
                }
                s.append(" table");
                return s.toString();
            case START:
                return table.getPlannedStartTime();
            case EXTERNAL_ID:
                return table.getExternalId();
            default:
                log.error("Unknown column index: " + column);
                return null;
        }
    }
}
