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

import java.lang.reflect.Array;
import java.util.LinkedList;
import java.util.List;

import javax.swing.table.AbstractTableModel;

import org.apache.commons.beanutils.BeanUtilsBean2;

/**
 * Table model for editing an Object[]
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class ArrayEditorTableModel extends AbstractTableModel {
    //private static final Log log = LogFactory.getLog(ArrayEditorTableModel.class);

    private LinkedList<Object> elements = new LinkedList<Object>();

    private Class<?> componentType;
    

    public ArrayEditorTableModel(Object array) {
        int length = Array.getLength(array);
        for (int i = 0; i < length; i++) {
            elements.add(Array.get(array, i));
        }

        componentType = array.getClass().getComponentType();
        if(componentType.isPrimitive()){
            componentType = primitiveToWrapper(componentType);
        }
    }

    public Object asArray(){
        Object newArray = Array.newInstance(wrapperToPrimitive(componentType), elements.size());
        
        for (int index = 0; index < elements.size(); index++) {
            Array.set(newArray, index, elements.get(index));
        }
        
        return newArray;
    }
    
    public List<String> asStringList(){
        BeanUtilsBean2 beanUtils = new BeanUtilsBean2();
        List<String> newList = new LinkedList<String>();
        
        for (int index = 0; index < elements.size(); index++) {
            String stringValue = (String) beanUtils.getConvertUtils().convert(elements.get(index), String.class);
            newList.add(stringValue);
        }
        
        return newList;
    }
    
    public void replaceWith(List<String> newValues){
        BeanUtilsBean2 beanUtils = new BeanUtilsBean2();
        elements = new LinkedList<Object>();
        
        for (String newValue : newValues) {
            Object convertedValue = beanUtils.getConvertUtils().convert(newValue, componentType);
            elements.add(convertedValue);
        }

        fireTableDataChanged();
    }
    
    public void insertElementAt(int index, String text){
        BeanUtilsBean2 beanUtils = new BeanUtilsBean2();
        Object newValue = beanUtils.getConvertUtils().convert(text, componentType);

        elements.add(index, newValue);

        fireTableDataChanged();
    }

    public void insertElementAtEnd(String text) {
        insertElementAt(elements.size(), text);
    }

    public void removeElementAt(int selectedIndex) {
        elements.remove(selectedIndex);
        fireTableDataChanged();
    }
    
    public int getColumnCount() {
        return 2;
    }

    public int getRowCount() {
        return elements.size();
    }

    public Object getValueAt(int rowIndex, int columnIndex) {
        switch(columnIndex){
            case 0:
                return rowIndex;
            case 1:
                Object object = elements.get(rowIndex);
                return object;
            default:
                throw new IllegalArgumentException("invalid columnIndex = " + columnIndex);
        }
    }

    @Override
    public void setValueAt(Object value, int rowIndex, int columnIndex) {
        if(columnIndex == 1){
            elements.set(rowIndex, value);
        }
    }

    @Override
    public String getColumnName(int columnIndex) {
        switch(columnIndex){
            case 0:
                return "idx";
            case 1:
                return "value";
            default:
                throw new IllegalArgumentException("invalid columnIndex = " + columnIndex);
        }
    }

    @Override
    public boolean isCellEditable(int rowIndex, int columnIndex) {
        return(columnIndex == 1);
    }

    @Override
    public Class<?> getColumnClass(int columnIndex) {
        
        switch(columnIndex){
            case 0:
                return Integer.class;
            case 1:
                return componentType;
            default:
                throw new IllegalArgumentException("invalid columnIndex = " + columnIndex);
        }
    }

    /**
     * There must be a better way to do this...
     * 
     * @param primitiveType
     * @return
     */
    private Class<?> primitiveToWrapper(Class<?> primitiveType){
        
        if(primitiveType == char.class){
            return Character.class;
        }else if(primitiveType == byte.class){
            return Byte.class;
        }else if(primitiveType == short.class){
            return Short.class;
        }else if(primitiveType == int.class){
            return Integer.class;
        }else if(primitiveType == long.class){
            return Long.class;
        }else if(primitiveType == float.class){
            return Float.class;
        }else if(primitiveType == double.class){
            return Double.class;
        }else if(primitiveType == boolean.class){
            return Boolean.class;
        }else{
            return null;
        }
    }
    
    private Class<?> wrapperToPrimitive(Class<?> wrapperClass){

        if(wrapperClass == Character.class){
            return char.class;
        }else if(wrapperClass == Byte.class){
            return byte.class;
        }else if(wrapperClass == Short.class){
            return short.class;
        }else if(wrapperClass == Integer.class){
            return int.class;
        }else if(wrapperClass == Long.class){
            return long.class;
        }else if(wrapperClass == Float.class){
            return float.class;
        }else if(wrapperClass == Double.class){
            return double.class;
        }else if(wrapperClass == Boolean.class){
            return boolean.class;
        }else{
            return wrapperClass;
        }
    }
}
