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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.sun.javadoc.ClassDoc;
import com.sun.javadoc.FieldDoc;
import com.sun.javadoc.LanguageVersion;
import com.sun.javadoc.RootDoc;
import com.sun.javadoc.Type;

/**
 * Generates a graphviz graph specification for a UML class diagram for 
 * the fields of a Java class and its relations.
 * 
 * 
 * To generate the documentation for CalModuleParameters run the following
 * command from java/common.
 * 
 * <pre>
 * javadoc -private -classpath ../../dist/lib/soc-classpath.jar -docletpath build/classes/src:../jars/dev/antlr/antlr-2.7.7.jar:../../dist/lib/soc-classpath.jar -doclet gov.nasa.kepler.common.doc.FieldDocumentationGeneratorDoclet ../cal/src/gov/nasa/kepler/cal/io/CalModuleParameters.java
 * </pre>
 * 
 * TODO:  Attempt to corner graph 
 * edges.  Line between class name and field parameters.  Inheritance
 * 
 * @author Sean McCauliff
 *
 */
public class UmlGraphvizClassDiagramDoclet {

    
    public static LanguageVersion languageVersion() {
        return LanguageVersion.JAVA_1_5;
    }
    
    /**
     * This is the entry point for the doclet.  Don't ask me why Sun choose to
     * use static methods.
     * 
     * @param rootDoc
     * @return true
     * @throws Exception
     */
    public static boolean start(RootDoc rootDoc) throws Exception {
        File outputFile = new File("umlcd.dot");
        BufferedWriter bwriter = new BufferedWriter(new FileWriter(outputFile));
        System.out.println("UmlGraphvizClassDiagramDoclet called");
        bwriter.write("digraph UmlCD {\n");
        ClassDoc[] classDocs = rootDoc.specifiedClasses();
        List<GraphvizNode> nodes = new ArrayList<GraphvizNode>(classDocs.length);
        for (ClassDoc classDoc : classDocs) {
            nodes.add(buildNode(classDoc));
        }
        for (GraphvizNode node : nodes) {
            bwriter.write(node.nodeDef);
        }
        for (GraphvizNode node : nodes) {
            for (String arcTarget : node.arcDefs) {
                bwriter.write(node.nodeName + " -> " + arcTarget + ";\n");
            }
        }
        bwriter.write("}\n");
        bwriter.close();
        System.out.println("Exiting UmlGraphvizClassDiagramDoclet.");
        return true;  //required by the Doclet spec?
    }
    
    private static GraphvizNode buildNode(ClassDoc classDoc) 
        throws SecurityException, NoSuchMethodException, 
        IllegalArgumentException, InstantiationException, 
        IllegalAccessException, InvocationTargetException, 
        ClassNotFoundException, NoSuchFieldException {
        
        Set<String> arcDefs = new HashSet<String>();
        List<String> fields = new ArrayList<String>();
        for (FieldDoc fieldDoc : classDoc.fields()) {
            Object defaultValue = null;
            if (!classDoc.isAbstract() && classDoc.name().endsWith("Parameters")) {
                Class<?> clazz = Class.forName(classDoc.qualifiedTypeName());
                Constructor<?> defaultConstructor = clazz.getDeclaredConstructor();
                if (defaultConstructor != null) {
                    defaultConstructor.setAccessible(true);
                    Object defaultInstance = defaultConstructor.newInstance();
                    Field field = clazz.getDeclaredField(fieldDoc.name());
                    field.setAccessible(true);
                    defaultValue = field.get(defaultInstance);
                }
            }
            
            
            if (fieldDoc.isStatic()) {
                continue;
            }
      
            String typeString = typeToString(fieldDoc.type(), arcDefs);
            String fieldLabel = formatField(fieldDoc, typeString, defaultValue);
            fields.add(fieldLabel); 
            if (!fieldDoc.type().qualifiedTypeName().startsWith("gov.nasa.kepler")) {
                continue;
            }
            arcDefs.add(cleanNodeName(fieldDoc.type().qualifiedTypeName()));
        }
        return new GraphvizNode(classDoc.qualifiedTypeName(), arcDefs, fields);
    }
    
    private static String formatField(FieldDoc fieldDoc, String typeString,
        Object defaultValue) {

        StringBuilder bldr = new StringBuilder();
        bldr.append("+ ").append(fieldDoc.name()).append(" : ").append(typeString);
        if (defaultValue != null) {
            bldr.append(" = ").append(defaultValue);
        }
        return bldr.toString();
    }

    private static String typeToString(Type t, Set<String> arcDefs) {
        StringBuilder bldr = new StringBuilder();
        typeToString_rec(t, bldr, arcDefs);
        return bldr.toString();
    }
    
    private static void typeToString_rec(Type t, StringBuilder bldr, Set<String> arcDefs) {
        bldr.append(t.typeName());
        if (t.asParameterizedType() != null) {
            bldr.append("&lt;");
            for (Type typeArg : t.asParameterizedType().typeArguments()) {
                arcDefs.add(cleanNodeName(typeArg.qualifiedTypeName()));
                typeToString_rec(typeArg, bldr, arcDefs);
                bldr.append(',');
            }
            bldr.setLength(bldr.length() - 1);
            bldr.append("&gt;");
        } else if (t.asWildcardType() != null) {
            throw new IllegalStateException("Wild card type not supported.");
        }
        
    }
    private static String cleanNodeName(String typeName) {
        return typeName.replace('.', '_');
    }
    
    private static final class GraphvizNode {
        public final String nodeName;
        public final String nodeDef;
        public final Set<String> arcDefs;
        
        public GraphvizNode(String typeName, Set<String> arcDefs, List<String> fields) {
            this.nodeName =  cleanNodeName(typeName);
            
            StringBuilder label = new StringBuilder();
            label.append("<<table border=\"0\" cellborder=\"0\" ><tr><td align=\"center\" >")
                    .append(typeName).append("</td></tr>");
            for (String field : fields) {
                label.append("<tr><td align=\"left\" >").append(field).append("</td></tr>");
            }
            label.append("</table>> ");
            this.nodeDef = nodeName + "[label=" + label + " shape=\"box\"];\n";
            this.arcDefs = arcDefs;
        }
    }
}
