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

package gov.nasa.kepler.common.persistable;

import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class models the data dictionary contained in the header of
 * every .sdf file.
 * 
 * <pre>
 * Data Dictionary format
 * 
 * Reserved type values for primitives
 * 
 * 1 : boolean
 * 2 : byte
 * 3 : short
 * 4 : int
 * 5 : long
 * 6 : float
 * 7 : double
 * 8 : string
 * 9 : char
 * 
 * # of classes : int
 * for each class
 *     type : int
 *     # fields in class : int
 *     for each field
 *     field name : string
 *     type : int 
 *     array dimensionality : int (0 means not an array/list)
 * 
 * Sample Classes
 * 
 * class Foo{
 *       ff1 : int
 *       ff2 : boolean
 *       ff3 : Bar
 *       ff4 : float
 *       ff5 : List<Zap>
 * }
 * 
 * class Bar{
 *       bf1 : string
 *       bf2 : double
 * }
 * 
 * class Zap{
 *       zf1 : List<Bar>
 * }
 * 
 * Sample Data Dictionary
 * 
 * 3       (# classes)
 * 
 * 10      (Foo type)
 * 5       (# fields in Foo)
 * 'ff1',4,0       (Foo.ff1)
 * 'ff2',1,0       (Foo.ff2)
 * 'ff3',16,0      (Foo.ff3)
 * 'ff4',6,0       (Foo.ff4)
 * 'ff5',19,0      (Foo.ff5)
 * 
 * 11      (Bar tag)
 * 2       (# fields in Bar)
 * 'bf1',8,0   (Bar.bf1)
 * 'bf1',7,0   (Bar.bf2)
 * 
 * 12      (Zap tag)
 * 1       (# fields in Zap)
 * 'zf1',16,1  (Zap.zf1)
 * 
 * Sample Object Tree
 * 
 * s.ff1 = 42;
 * s.ff2 = true;
 * s.ff3 = 
 *       .bf1 = 'bar1';
 *       .bf2 = 42.42;
 * s.ff4 = 84.1;
 * s.ff5[0]
 *     .zf1[0]
 *         .bf1 = 'z0b0';
 *         .bf2 = 0.0;
 *     .zf1[1]
 *         .bf1 = 'z0b1';
 *         .bf2 = 0.1;
 * s.ff5[1]
 *     .zf1[0]
 *         .bf1 = 'z1b0';
 *         .bf2 = 1.0;
 *     .zf1[1]
 *         .bf1 = 'z1b1';
 *         .bf2 = 1.1;
 *     .zf1[2]
 *         .bf1 = 'z1b2';
 *         .bf2 = 1.2;
 *         
 * Sample Data Stream
 * 
 * Format is a header, followed by [L][V], where
 *        [L] is the number of sub-elements for this element (absent if not list/array)
 *        [V] is the contents of this element (may be nested LVs)
 * 
 * [Magic Number]
 * [Data Dictionary]
 * [Tag of top-level element]
 * [Number of top-level elements]
 * [42]
 * [true]
 * [['bar1']
 * [42.42]]
 * [84.1]
 * [2][
 *     [2][
 *         ['z0b0']
 *         [0.0]
 *         ['z0b1']
 *         [0.1]]
 *     [3][
 *         ['z1b0']
 *         [1.0]
 *         ['z1b1']
 *         [1.1]
 *         ['z1b2']
 *         [1.2]]
 *     ]
 * ]
 * </pre>
 * 
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class SdfDataDictionary {
    static final Log log = LogFactory.getLog(SdfDataDictionary.class);

    public static final int BOOLEAN_TAG = 1;
    public static final int BYTE_TAG = 2;
    public static final int SHORT_TAG = 3;
    public static final int INT_TAG = 4;
    public static final int LONG_TAG = 5;
    public static final int FLOAT_TAG = 6;
    public static final int DOUBLE_TAG = 7;
    public static final int STRING_TAG = 8;
    public static final int CHAR_TAG = 9;
    public static final int DATE_TAG = 10;
    public static final int ENUM_TAG = 11;
    
    public static final int LAST_PRIMITIVE_TAG = ENUM_TAG;

    /* These values are converted to empty on the MATLAB side */
    public static final byte EMPTY_BOOLEAN_VALUE = 2;
    public static final int EMPTY_INT_VALUE = Integer.MAX_VALUE;
    public static final long EMPTY_LONG_VALUE = Long.MAX_VALUE;
    public static final float EMPTY_FLOAT_VALUE = Float.MAX_VALUE;
    public static final double EMPTY_DOUBLE_VALUE = Double.MAX_VALUE;
    
    private List<SdfDataDictionaryClass> classes = new LinkedList<SdfDataDictionaryClass>();

    private HashMap<Class<?>, Integer> classTypeMap;

    public SdfDataDictionary() {
    }

    public void addClass(SdfDataDictionaryClass c) {
        classes.add(c);
    }

    public List<SdfDataDictionaryClass> getClasses() {
        return classes;
    }

    public void setClasses(List<SdfDataDictionaryClass> classes) {
        this.classes = classes;
    }

    /**
     * @param classSimpleName
     * @return
     * @throws Exception
     */
    public int typeForClass(String className) throws Exception {
        if(className.equals("boolean") || className.equals("Boolean")){
            return BOOLEAN_TAG;
        }else if(className.equals("byte") || className.equals("Byte")){
            return BYTE_TAG;
        }else if(className.equals("short") || className.equals("Short")){
            return SHORT_TAG;
        }else if(className.equals("int") || className.equals("Integer")){
            return INT_TAG;
        }else if(className.equals("long") || className.equals("Long")){
            return LONG_TAG;
        }else if(className.equals("float") || className.equals("Float")){
            return FLOAT_TAG;
        }else if(className.equals("double") || className.equals("Double")){
            return DOUBLE_TAG;
        }else if(className.equals("String")){
            return STRING_TAG;
        }else if(className.equals("Date")){
            return DATE_TAG;
        }else if(className.equals("Enum")){
            return ENUM_TAG;
        }else if(className.equals("char") || className.equals("Character")){
            return CHAR_TAG;
        }else{
            throw new Exception("unknown className: " + className);
        }
    }

    public void write(SdfPersistableOutputStream output) throws IOException {
        classTypeMap = new HashMap<Class<?>, Integer>();
        int classType = LAST_PRIMITIVE_TAG + 1;

        // first assign a type to each class
        for (SdfDataDictionaryClass c : classes) {
            classTypeMap.put(c.getClazz(), classType);
            c.setType(classType);
            log.debug("Class=" + c.getClazz().getSimpleName() + ", type=" + classType);
            classType++;
        }

        log.debug("numClasses=" + classes.size());
        output.writeInt(null, classes.size());
        
        for (SdfDataDictionaryClass c : classes) {
            // classtype
            log.debug("class(name=" + c.getClazz().getSimpleName() + ",type=" + c.getType() + ")");
            output.writeInt(null, c.getType());

            // classname
            output.writeString(null, c.getClazz().getName());
            
            // fields
            List<SdfDataDictionaryField> fields = c.getFields();
            // num fields
            log.debug("  numFields=" + fields.size());
            output.writeInt(null, fields.size());
            
            for (SdfDataDictionaryField field : fields) {
                Class<?> fieldClass = field.getClazz();
                
                // field name
                String fieldName = field.getName();
                output.writeString(null, fieldName);

                // field type
                if (fieldClass != null) {
                    log.debug("  fieldClass=" + fieldClass.getSimpleName());
                    field.setType(typeForClass(fieldClass));
                }
                log.debug(" field(name=" + fieldName + ",type=" + field.getType() + "," + field.getArrayDimensions() + ")");
                output.writeInt(null, field.getType());

                // field dims
                output.writeInt(null, field.getArrayDimensions());
            }
        }
    }

    public int typeForClass(Class<?> clazz) {
        return classTypeMap.get(clazz);
    }

    public boolean containsClass(Class<?> clazz) {
        return classTypeMap.containsKey(clazz);
    }
}
