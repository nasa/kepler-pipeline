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


import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.beans.PropertyEditor;
import java.lang.reflect.Array;
import java.lang.reflect.Field;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.l2fprod.common.beans.ExtendedPropertyDescriptor;
import com.l2fprod.common.propertysheet.PropertySheetPanel;

/**
 * Helper methods for working with L2fprod's {@link PropertySheetPanel}
 *  
 * @author tklaus
 *
 */
public class PropertySheetHelper {
    private static final Log log = LogFactory.getLog(PropertySheetHelper.class);

    private PropertySheetHelper() {
    }

    /**
     * Initialize null fields since the property editors may not work correctly
     * otherwise.  This can't be done in the property editors themselves since
     * they only get an Object and don't know the type (foo.getClass() doesn't
     * work if foo is null!)
     * 
     * @param parametersBean
     * @throws Exception 
     */
    public static void deNullify(Object parametersBean) throws Exception{
        Class<?> beanClass = parametersBean.getClass();
        Field[] fields = beanClass.getDeclaredFields();
        for (int i = 0; i < fields.length; i++) {
            Field field = fields[i];

            // allow us to access the value of private fields
            field.setAccessible(true);

            Object fieldValue = field.get(parametersBean);
            Class<?> fieldClass = field.getType();
            Object initialValue = null;
            
            if(fieldValue == null){
                log.debug("Initializing null field: " + field.getName());

                if(fieldClass.isArray()){
                    initialValue = Array.newInstance(fieldClass.getComponentType(), 0);
                }else{
                    initialValue = fieldClass.newInstance();
                }
                field.set(parametersBean, initialValue);
            }
        }
    }
    
    /**
     * Helper method that populates a {@link PropertySheetPanel} with the contents of
     * a bean instance.  Automatically adds an {@link ArrayPropertyEditor} and an
     * {@link ArrayTableCellRenderer} for array fields that do not already have a custom
     * {@link PropertyEditor}.
     * 
     * @param parametersBean
     * @param propertySheetPanel
     * @throws IntrospectionException
     */
    public static void populatePropertySheet(Object parametersBean, PropertySheetPanel propertySheetPanel) throws Exception{

        // initialize null fields so the property editors won't get tripped up.
        PropertySheetHelper.deNullify(parametersBean);
        
        Class<?> beanClass = parametersBean.getClass();
        BeanInfo beanInfo;

        beanInfo = Introspector.getBeanInfo(beanClass, Object.class);
        PropertyDescriptor[] propertyDescriptors = beanInfo.getPropertyDescriptors();
        
        /* Add an ArrayPropertyEditor for fields that are arrays and don't
         * already have a custom PropertyEditor assigned.
         * 
         * if class is array
         *   if propertyDescriptor is NOT ExtendedPropertyDescriptor
         *     convert to ExtendedPropertyDescriptor
         *   if getPropertyEditorClass not set
         *     set to ArrayPropertyEditor
         *   if getPropertyTableRendererClass not set
         *     set to ArrayTableCellRenderer
         * add property to propertySheetPanel
         */
        
        PropertyDescriptor[] newPropertyDescriptors = new PropertyDescriptor[propertyDescriptors.length];
        int index = 0;
        
        for (PropertyDescriptor propertyDescriptor : propertyDescriptors) {

            Class<?> clazz = propertyDescriptor.getPropertyType();
            log.debug("property class = " + clazz);
            
            if(clazz.isArray()){
                ExtendedPropertyDescriptor extendedPropertyDescriptor;
                
                if(propertyDescriptor instanceof ExtendedPropertyDescriptor){
                    extendedPropertyDescriptor = (ExtendedPropertyDescriptor) propertyDescriptor;
                }else{
                    extendedPropertyDescriptor = ExtendedPropertyDescriptor.newPropertyDescriptor(propertyDescriptor.getName(), beanClass);
                }
                
                if(extendedPropertyDescriptor.getPropertyEditorClass() == null){
                    extendedPropertyDescriptor.setPropertyEditorClass(ArrayPropertyEditor.class);
                }
                
                if(extendedPropertyDescriptor.getPropertyTableRendererClass() == null){
                    extendedPropertyDescriptor.setPropertyTableRendererClass(ArrayTableCellRenderer.class);
                }
                
                newPropertyDescriptors[index++] = extendedPropertyDescriptor;
            }else{
                newPropertyDescriptors[index++] = propertyDescriptor;
            }
        }

        propertySheetPanel.setProperties(newPropertyDescriptors);
        propertySheetPanel.readFromObject(parametersBean);
    }
}
