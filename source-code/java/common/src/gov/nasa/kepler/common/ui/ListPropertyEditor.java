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

package gov.nasa.kepler.common.ui;

import gov.nasa.spiffy.common.collect.ArrayUtils;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.lang.reflect.Array;
import java.util.Arrays;
import java.util.Comparator;

import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.commons.lang.StringUtils;



import com.l2fprod.common.beans.editor.AbstractPropertyEditor;

/**
 * Edit arrays with a JList.  This will not work with arrays of primitive types.
 * 
 * @author Sean McCauliff
 *
 */
public class ListPropertyEditor extends AbstractPropertyEditor {

    private Object[] currentValues;
    /** This array is sorted. */
    private Object[] availableValues;
    private Comparator<Object> comp;
    private Class<?> arrayComponentType;
    private final InTableButtonsPanel tableUi;
    private final String title;
    private ListEditorDialog dialog;
    
    public ListPropertyEditor(String title) {
        this.title = title;
        
        ActionListener editActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                showEditorUi();
            }
        };
        
        ActionListener cancelActionListener = new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                eraseValue();
            }
        };
        
        tableUi = new InTableButtonsPanel(false, editActionListener, cancelActionListener);
        tableUi.setEditable(false);
        editor = tableUi;
        
    }
    
    
    private int[] selectedIndicesFromOldValues() {
        final int[] selectedIndices = new int[currentValues.length];
        for (int i=0; i < currentValues.length; i++) {
            selectedIndices[i] = 
                Arrays.binarySearch(availableValues, currentValues[i], comp);
        }
        return selectedIndices;
    }
    
    
    private void showEditorUi() {
        dialog = ListEditorDialog.newDialog(editor);
        dialog.setAvailableValues(availableValues);
        if (currentValues != null) {
            dialog.setSelectedIndices(selectedIndicesFromOldValues());
        }
        dialog.addListSelectionListener(new ListSelectionListener() {
            @Override
            public void valueChanged(ListSelectionEvent lev) {
                listChanged(lev);
            }
        });
        dialog.setTitle(title);
        dialog.setLocationRelativeTo(tableUi);
        dialog.pack();
        Object[] oldValues = currentValues;
        //Important! modal.
        dialog.setVisible(true);
        tableUi.setText(valuesToString());
        //Important! Only do this once per edit.  Because the editor component
        //gets removed after the first property change is triggered.
        firePropertyChange(oldValues, currentValues);
    }
    
    private void eraseValue() {
        setValue(Array.newInstance(arrayComponentType, 0));
    }

    private void listChanged(ListSelectionEvent event) {

        if (event.getValueIsAdjusting()) {
            return;
        }
        
        final Object[] fromListValues = dialog.getSelectedValues();
        currentValues = (Object[]) ArrayUtils.copyArray(fromListValues, arrayComponentType);
        tableUi.setText(valuesToString());
    }
    
    /**
     * @return Here Object is actually an array of the arrayComponentType.
     */
    @Override
    public Object getValue() {
        return currentValues;
    }
    
    /**
     * @param objValue is actually an array of objects.
     */
    @Override
    public void setValue(Object objValue) {
        final Object[] values = (Object[]) objValue;
        if (values == null) {
            currentValues = null;
            return;
        }
        currentValues = values;
        
        //jList.setSelectedIndices(selectedIndices);
        arrayComponentType = objValue.getClass().getComponentType();
        tableUi.setText(valuesToString());
    }
    
    public void setAvailableValues(Object[] values, Comparator<Object> comp) {
        this.availableValues = Arrays.copyOf(values, values.length);
        Arrays.sort(availableValues, comp);
        this.comp = comp;
    }
    
    public void setArrayComponentType(Class<?> arrayComponentType) {
        this.arrayComponentType = arrayComponentType;
    }
    
    private String valuesToString() {
        if (currentValues == null) {
            return "";
        }
        
        return StringUtils.join(currentValues, ", ");
    }
}
