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

package gov.nasa.kepler.pi.module.io.cpp;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashSet;

/**
 * This class represents a C++ .h file and generates its content
 * 
 * @author tklaus
 * 
 */
public class CppHeader extends CppFile {

    private StringWriter bodyContent = new StringWriter();

    private PrintWriter body = new PrintWriter(bodyContent);

    private HashSet<String> includes = new HashSet<String>();

    private String upperClassName = null;

    /**
     * 
     * @param className
     */
    public CppHeader(String className) {
        super(className);
        upperClassName = className.toUpperCase();
    }

    /**
     * Returns the content of the .h file after all fields have been added to it
     * 
     * @return
     */
    public String content() {
        StringWriter content = new StringWriter();
        PrintWriter w = new PrintWriter(content);

        printHeaderComment(w);

        w.println();

        w.println("#ifndef " + upperClassName + "_H_");
        w.println("#define " + upperClassName + "_H_");

        w.println();
        w.println("#include <Persistable.h>");
        w.println("#include <PersistableInputStream.h>");
        w.println("#include <PersistableOutputStream.h>");
        w.println();
        for (String include : includes) {
            w.println("#include " + include);
        }
        w.println();
        w.println("class " + className + " : public Persistable{");
        w.println();
        w.println("public:");
        w.println("\t" + className + "(){}");
        w.println("\tvirtual ~" + className + "(){}");
        w.println();
        w.print(bodyContent.toString());
        w.println();
        w.println("\tvirtual void load( PersistableInputStream& " + INSTREAM_VAR_NAME + " );");
        w.println("\tvirtual void save( PersistableOutputStream& " + OUTSTREAM_VAR_NAME + " );");
        w.println();
        w.println("};");
        w.println();
        w.println("#endif /* " + upperClassName + "_H_ */");

        return content.toString();
    }

    /**
     * Adds load and save code for the specified field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     */
    public void addField(String name, String classSimpleName, boolean primitive) {
        String cppType = cppType(classSimpleName);

        if (classSimpleName.equals("String")) {
            includes.add("<string>");
        }

        if (!primitive) {
            includes.add("\"" + classSimpleName + ".h\"");
        }

        body.println("\t" + cppType + " " + name + ";");
    }

    /**
     * Generates load and save code for a java.util.List or array field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     */
    public void addListField(String name, String classSimpleName, boolean primitive, int dimensions) {
        String cppType = cppType(classSimpleName);

        if (classSimpleName.equals("String")) {
            includes.add("<string>");
        }

        includes.add("<vector>");

        if (!primitive && !classSimpleName.equals("String")) {
            includes.add("\"" + classSimpleName + ".h\"");
        }

        body.print("\t");

        body.print(vectorCppTypeName(dimensions, cppType));
        body.println(" " + name + ";");
    }

    /**
     * Generate code for a Map<K,V> field. Currently only supports Map<String,String>
     * or Map<String,Persistable>
     * 
     * @param name
     * @param keyClassSimpleName
     * @param valueClassSimpleName
     * @param elementIsPersistable
     * @param dimensions
     */
    public void addMapField(String name, String keyClassSimpleName, String valueClassSimpleName, boolean elementIsPersistable,
        int dimensions) {

        includes.add("<map>");

        if (keyClassSimpleName.equals("String") || valueClassSimpleName.equals("String")) {
            includes.add("<string>");
        }

        if (elementIsPersistable) {
            includes.add("\"" + valueClassSimpleName + ".h\"");
        }

        String keyCppType = cppType(keyClassSimpleName);
        String valueCppType = cppType(valueClassSimpleName);

        String mapType = "std::map< " + keyCppType + ", " + valueCppType + " >";

        body.println("\t" + mapType + " " + name + ";");
    }

    /**
     * Generate code for a Set<K> field. Currently only supports Set<String>
     * 
     * @param name
     * @param keyClassSimpleName
     * @param dimensions
     */
    public void addSetField(String name, String keyClassSimpleName) {

        includes.add("<set>");

        if (keyClassSimpleName.equals("String")) {
            includes.add("<string>");
        }

        String keyCppType = cppType(keyClassSimpleName);

        String setType = "std::set< " + keyCppType + " >";

        body.println("\t" + setType + " " + name + ";");
    }
}
