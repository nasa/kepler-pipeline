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

import gov.nasa.kepler.common.ui.ListPropertyEditor;
import gov.nasa.kepler.hibernate.CrudFactory;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrudInterface;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.util.Comparator;
import java.util.List;

import org.apache.commons.lang.StringUtils;

import com.l2fprod.common.beans.BaseBeanInfo;
import com.l2fprod.common.beans.ExtendedPropertyDescriptor;
import com.l2fprod.common.beans.editor.IntegerPropertyEditor;
import com.l2fprod.common.swing.renderer.DefaultCellRenderer;

/**
 * Provides a target list selection editor.
 * 
 * @author Sean McCauliff
 *
 */
public class TargetListParametersBeanInfo extends BaseBeanInfo implements BeanInfo {

    public TargetListParametersBeanInfo() throws IntrospectionException {
        super(TargetListParameters.class);

        ExtendedPropertyDescriptor targetListNamesDesc =
            new ExtendedPropertyDescriptor(
                "targetListNames", TargetListParameters.class);
        targetListNamesDesc.setDisplayName("Target Lists");
        targetListNamesDesc.setPropertyEditorClass(Editor.class);
        targetListNamesDesc.setPropertyTableRendererClass(Renderer.class);
        
        addPropertyDescriptor(targetListNamesDesc);
        
        ExtendedPropertyDescriptor nChunksDesc = 
            new ExtendedPropertyDescriptor("nChunks", TargetListParameters.class);
        nChunksDesc.setDisplayName("Number of UoW");
        nChunksDesc.setPropertyEditorClass(IntegerPropertyEditor.class);
        
        addPropertyDescriptor(nChunksDesc);
        
    }

    public static final class Editor extends ListPropertyEditor {
        
        public Editor() {
            super("Editing Target List Names");
            TargetSelectionCrudInterface targetSelectionCrud =
                (TargetSelectionCrudInterface) CrudFactory.getCrud(new TargetSelectionCrud());
            
            List<TargetList> targetLists = 
                targetSelectionCrud.retrieveTargetListsForUplinkedTargetTables();
            
            String[] validTargetListNames = new String[targetLists.size()];
            for (int i=0; i < targetLists.size(); i++) {
                validTargetListNames[i] = targetLists.get(i).getName();
            }
            
            setAvailableValues(validTargetListNames, new Comparator<Object>() {
                @Override
                public int compare(Object o1, Object o2) {
                    String s1 = (String) o1;
                    String s2 = (String) o2;
                    return s1.compareTo(s2);
                }
            });
            setArrayComponentType(String.class);
        }
    }
    
    @SuppressWarnings("serial") 
    public static final class Renderer extends DefaultCellRenderer {

        @Override
        public void setValue(Object value) {
            if (value == null) {
                setText("");
            } else {
                String[] strValues = (String[]) value;
                setText(StringUtils.join(strValues, ", "));
            }
           // System.out.println("renderer getText(): " + getText() + " value " + value);
        }
    }
}
