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

package gov.nasa.kepler.mc;

import static gov.nasa.kepler.hibernate.tad.TargetTable.TargetType.LONG_CADENCE;
import static gov.nasa.kepler.hibernate.tad.TargetTable.TargetType.SHORT_CADENCE;
import gov.nasa.kepler.hibernate.CrudFactory;
import gov.nasa.kepler.hibernate.tad.*;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.awt.Component;
import java.beans.IntrospectionException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JLabel;
import javax.swing.JTable;
import javax.swing.table.TableCellRenderer;

import com.google.common.collect.Lists;
import com.l2fprod.common.beans.BaseBeanInfo;
import com.l2fprod.common.beans.ExtendedPropertyDescriptor;
import com.l2fprod.common.beans.editor.ComboBoxPropertyEditor;
import com.l2fprod.common.beans.editor.IntegerPropertyEditor;

public class TargetTableParametersBeanInfo extends BaseBeanInfo {

    public TargetTableParametersBeanInfo() throws IntrospectionException {
        super(TargetTableParameters.class);

        ExtendedPropertyDescriptor propertyDescriptor = new ExtendedPropertyDescriptor(
            "TargetTableDbId", TargetTableParameters.class);
        propertyDescriptor.setDisplayName("Target Table"); // TODO: this should
                                                            // be in a resource
                                                            // file
        propertyDescriptor.setPropertyEditorClass(Editor.class);
        
        propertyDescriptor.setPropertyTableRendererClass(TargetTableIdRender.class);
        addPropertyDescriptor(propertyDescriptor);
        
        ExtendedPropertyDescriptor chunkSizePropertyDescriptor = 
            new ExtendedPropertyDescriptor("ChunkSize", TargetTableParameters.class);
        chunkSizePropertyDescriptor.setPropertyEditorClass(IntegerPropertyEditor.class);
        chunkSizePropertyDescriptor.setDisplayName("Unit of work chunk size");
        addPropertyDescriptor(chunkSizePropertyDescriptor);
    }

    public static final class Editor extends ComboBoxPropertyEditor {
        public Editor() {
            TargetCrudInterface targetCrud = (TargetCrudInterface)
                CrudFactory.getCrud(new TargetCrud());
            List<TargetTable> shortList =
                targetCrud.retrieveUplinkedTargetTables(SHORT_CADENCE);
            List<TargetTable> longList =    
                targetCrud.retrieveUplinkedTargetTables(LONG_CADENCE);
            List<TargetTable> bkgList = 
                targetCrud.retrieveUplinkedTargetTables(TargetType.BACKGROUND);
            
            List<TargetTable> combinedList = 
                Lists.newArrayListWithCapacity(shortList.size() + longList.size() + bkgList.size());
            combinedList.addAll(longList);
            combinedList.addAll(shortList);
            combinedList.addAll(bkgList);
            
            Value[] values = new Value[combinedList.size()];
            for (int i=0; i < values.length; i++) {
                TargetTable ttable = combinedList.get(i);
                String visualValue = humanString(ttable);
                values[i] = new Value(ttable.getId(), visualValue);
            }
            this.setAvailableValues(values);
        }
        
    }
    
    @SuppressWarnings("serial")
    public static final class TargetTableIdRender 
        extends JLabel implements TableCellRenderer {

        @Override
        public Component getTableCellRendererComponent(JTable table,
            Object value, boolean isSelected, boolean hasFocus, int row,
            int column) {

            TargetCrudInterface targetCrud = (TargetCrudInterface)
            CrudFactory.getCrud(new TargetCrud());
            TargetTable ttable = 
                targetCrud.retrieveTargetTable((Long)value);
            
            setText(humanString(ttable));
            
            return this;
        }
        
        //The Java Almanac 1.4 recommends overriding the following for
        //performance.
        @Override
        public void validate() {}
        @Override
        public void revalidate() {}
        @Override
        protected void firePropertyChange(String propertyName, Object oldValue, Object newValue) {}
        @Override
        public void firePropertyChange(String propertyName, boolean oldValue, boolean newValue) {}
    }
    
    private static String humanString(TargetTable ttable) {
        if (ttable == null) {
            return "Not Selected";
        }
        StringBuilder bldr = new StringBuilder();
        bldr.append(ttable.getType()).append('-')
            .append(ttable.getExternalId()).append(" (")
            .append(ttable.getId()).append(")");
        return bldr.toString();
   
    }

}
