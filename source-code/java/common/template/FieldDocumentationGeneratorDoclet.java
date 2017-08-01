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

package gov.nasa.kepler.common.doc;

import gov.nasa.kepler.common.persistable.ProxyIgnore;

import java.io.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.Comparator;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;

import com.sun.javadoc.*;

import org.antlr.stringtemplate.*;
import org.antlr.stringtemplate.language.*;
import org.apache.commons.lang.ArrayUtils;

/**
 * This is a doclet.  For whatever reason Sun choose not to use inheritance of
 * anykind in order to denote a class or class instance as a doclet.
 * 
 * See http://java.sun.com/javase/6/docs/technotes/guides/javadoc/doclet/overview.html
 * 
 * To generate the documentation for CalModuleParameters run the following
 * command from java/common.
 * 
 * <pre>
 * javadoc -private -classpath ../../dist/lib/soc-classpath.jar -docletpath build/classes/src:../jars/dev/antlr/antlr-2.7.7.jar:../../dist/lib/soc-classpath.jar -doclet gov.nasa.kepler.common.doc.FieldDocumentationGeneratorDoclet ../cal/src/gov/nasa/kepler/cal/io/CalModuleParameters.java
 * </pre>
 * @author Sean McCauliff
 *
 */
public class FieldDocumentationGeneratorDoclet {

    private static volatile StringTemplateGroup fieldTableTemplateGroup;
    
    
    /**
     * This is the doclet entry point.
     * 
     * @param rootDoc
     * @return
     */
    public static boolean start(RootDoc rootDoc) {
        System.out.println("FieldDocumentationGenerator called.");
        try {
            init();
   
            ClassDoc[] classDocs = rootDoc.specifiedClasses();
            for (ClassDoc classDoc : classDocs) {
                printClass(classDoc);
            }
            System.out.println("Exiting FieldDocumentationGenerator.");
        } catch (Exception ioe) {
            throw new IllegalStateException(ioe);
        }
        
        return true;  //This is required by the doclet spec.
    }
    
    private static void init() {
        if (fieldTableTemplateGroup != null) {
            return;
        }

        StringTemplateGroup group = new StringTemplateGroup("mygroup",
            "template", DefaultTemplateLexer.class);
        fieldTableTemplateGroup = group;
    }
     
    private static void printClass(ClassDoc classDoc) throws Exception {
        if (classDoc.isAbstract()) {
            return;
        }
        
        File outputFile = new File(classDoc.name() + ".html");
        BufferedWriter bwriter = 
            new BufferedWriter(new FileWriter(outputFile));
        
        StringTemplate headerTemplate = 
            fieldTableTemplateGroup.getInstanceOf("FieldTableHeader");
        headerTemplate.setAttribute("className", classDoc.name());
        bwriter.write(headerTemplate.toString());
        bwriter.write("\n");
        
        //Technically you can have multiple private fields with the same name
        //in different super classes, but for SDD documentation purposes
        //this does not make sense.
        SortedMap<String, FieldDoc> fieldDocsByName = new TreeMap<String, FieldDoc>();
        assembleFieldDocs(classDoc, fieldDocsByName);
        
        Class<?> containingClass = 
            classForName(classDoc.qualifiedTypeName());
        Constructor<?> defaultConstructor = containingClass.getDeclaredConstructor();
        defaultConstructor.setAccessible(true);
        Object containingClassInstance = defaultConstructor.newInstance();
        
        for (FieldDoc fieldDoc : fieldDocsByName.values()) {
            printField(fieldDoc, containingClassInstance, bwriter);
        }
        
        StringTemplate footerTemplate = 
            fieldTableTemplateGroup.getInstanceOf("FieldTableFooter");
        bwriter.write(footerTemplate.toString());
        bwriter.close();
    }
    
    
    private static Class<?> classForName(String className) throws ClassNotFoundException {
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException initialException) {
            StringBuilder innerClassName = 
                new StringBuilder(className);
            innerClassName.setCharAt(innerClassName.lastIndexOf("."), '$');
            try {
                return Class.forName(innerClassName.toString());
            } catch (ClassNotFoundException x) {
                x.printStackTrace();
                throw x;
            }
        }
    }
    private static void assembleFieldDocs(ClassDoc classDoc, SortedMap<String, FieldDoc> fieldDocMap) {
        if (classDoc.superclass() == null) {
            //We have reached java.lang.Object
            return;
        }
        
        FieldDoc[] fieldDocs = classDoc.fields();
        for (FieldDoc fd : fieldDocs) {
            if (fd.isStatic()) {
                continue;
            }
            
            if (fieldDocMap.containsKey(fd.name())) {
                throw new IllegalStateException("Duplicate field \"" + 
                    fd.name() + "\".");
            }
            fieldDocMap.put(fd.name(), fd);
        }
        assembleFieldDocs(classDoc.superclass(), fieldDocMap);
    }
    
    private static void printField(FieldDoc fieldDoc, 
        Object containingClassInstance, BufferedWriter bwriter) 
        throws IOException, ClassNotFoundException, InstantiationException, 
        IllegalAccessException, SecurityException, NoSuchFieldException {
        
      
        Object fieldDefaultValue = null;
        Class<?> containingClass = classForName(fieldDoc.containingClass().qualifiedTypeName());
      
        Field field = containingClass.getDeclaredField(fieldDoc.name());
        field.setAccessible(true);
        boolean hasDefaultValue = false;
        //Generate default values only for parameter classes.
        if (containingClassInstance.getClass().getSimpleName().endsWith("Parameters")) {
            hasDefaultValue = true;
            //TODO: This does not deal with multidimensional arrays.
            fieldDefaultValue = field.get(containingClassInstance);
            if (fieldDefaultValue != null && fieldDefaultValue.getClass().isArray()) {
                fieldDefaultValue = ArrayUtils.toString(fieldDefaultValue);
            }
            if (fieldDefaultValue != null && fieldDefaultValue.getClass() == String.class) {
                fieldDefaultValue = "\"" + fieldDefaultValue + '"';
            }
            if (fieldDefaultValue == null || !isPrimitiveField(field.getType())) {
                fieldDefaultValue = "None";
            }
        }
        
        StringTemplate fieldTemplate = 
            fieldTableTemplateGroup.getInstanceOf("FieldRow");
        fieldTemplate.setAttribute("typeName", fieldDoc.type().typeName());
        fieldTemplate.setAttribute("fieldName", fieldDoc.name());
        fieldTemplate.setAttribute("defaultValue", fieldDefaultValue);
        fieldTemplate.setAttribute("hasDefaultValue", hasDefaultValue);
        String fieldComment = fieldDoc.commentText();
        if (fieldComment == null || fieldComment.length() == 0) {
            fieldComment = "TODO";
        }
        if (field.isAnnotationPresent(ProxyIgnore.class)) {
            fieldComment +=  "  This field is not passed to matlab.";
        }
            
        fieldTemplate.setAttribute("fieldComment", fieldComment);
        
        bwriter.write(fieldTemplate.toString());
        bwriter.write("\n");
    }
    
    /**
     * checks if the reflected Field object is a primitive or a primitive wrapper
     * object or a String value or an array of those types.
     * @param fieldClass  Class of reflected field type not a fieldDoc.
     * @return true it it meets the criteria above else false.
     */
    
    private static boolean isPrimitiveField(Class<?> fieldClass) {
        if (fieldClass.isArray()) {
            return isPrimitive(fieldClass.getComponentType());
        }
        return isPrimitive(fieldClass);
    }
    
    private static boolean isPrimitive(Class<?> fieldClass) {
        return fieldClass == Byte.TYPE || fieldClass == Byte.class ||
            fieldClass == Short.TYPE || fieldClass == Short.class |
            fieldClass == Integer.TYPE || fieldClass == Integer.class ||
            fieldClass == Long.TYPE || fieldClass == Long.class ||
            fieldClass == Character.TYPE || fieldClass == Character.class ||
            fieldClass == Boolean.TYPE || fieldClass == Boolean.class ||
            fieldClass == Float.TYPE || fieldClass == Float.class ||
            fieldClass == Double.TYPE || fieldClass == Double.class ||
            fieldClass == String.class;
    }
}
