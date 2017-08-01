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

/**
 * This class represents a C++ .cpp file and generates its content
 * 
 * @author tklaus
 * 
 */
public class CppCode extends CppFile {

    private StringWriter loadContent = new StringWriter();
    private StringWriter saveContent = new StringWriter();
    private PrintWriter load = new PrintWriter(loadContent);
    private PrintWriter save = new PrintWriter(saveContent);

    /**
     * 
     * @param className
     */
    public CppCode(String className) {
        super(className);
    }

    /**
     * Returns the content of the .cpp file after all fields have been added to
     * it
     * 
     * @return
     */
    public String content() {
        StringWriter content = new StringWriter();
        PrintWriter w = new PrintWriter(content);

        printHeaderComment(w);

        w.println();

        w.println("#include \"" + className + ".h\"");
        w.println("#include <iostream>");
        w.println();

        w.println();

        w.println("void " + className + "::load( PersistableInputStream& " + INSTREAM_VAR_NAME + " ){");
        w.print(loadContent.toString());
        w.println("}");

        w.println();

        w.println("void " + className + "::save( PersistableOutputStream& " + OUTSTREAM_VAR_NAME + " ){");
        w.print(saveContent.toString());
        w.println("}");

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

        load.println();
        save.println();

        load.println("\t// " + classSimpleName + " " + name);
        save.println("\t// " + classSimpleName + " " + name);

        genDebug(load, "\tstd::cout << \"load " + classSimpleName + " " + name + "\" << std::endl;");
        genDebug(save, "\tstd::cout << \"save " + classSimpleName + " " + name + "\" << std::endl;");

        if (primitive) {
            String cppType = cppType(classSimpleName);
            load.println("\t" + genReadCode("this->" + name, cppType));
            save.println("\t" + genWriteCode("this->" + name, cppType));
        } else {
            load.println("\t" + name + ".load( " + INSTREAM_VAR_NAME + " );");
            save.println("\t" + name + ".save( " + OUTSTREAM_VAR_NAME + " );");
        }
    }

    /**
     * Generates load and save code for a java.util.List or array field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param listType
     * @param dimensions
     */
    public void addListField(String name, String classSimpleName, boolean primitive, int dimensions) {
        String cppType = cppType(classSimpleName);

        save.println();
        load.println();

        // load code
        genLoadVectorCode(name, classSimpleName, primitive, dimensions, cppType);

        // save code
        genSaveVectorCode(name, classSimpleName, primitive, dimensions, cppType);
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

        save.println();
        load.println();

        genLoadMapCode(name, keyClassSimpleName, valueClassSimpleName, elementIsPersistable);
        genSaveMapCode(name, keyClassSimpleName, valueClassSimpleName, elementIsPersistable);
    }

    /**
     * Generate code for a Set<K> field. Currently only supports Set<String>
     * 
     * @param name
     * @param keyClassSimpleName
     * @param dimensions
     */
    public void addSetField(String name, String keyClassSimpleName) {

        save.println();
        load.println();

        genLoadSetCode(name, keyClassSimpleName);
        genSaveSetCode(name, keyClassSimpleName);
    }

    /**
     * Generates code to load a std::vector<> field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     * @param cppType
     */
    private void genLoadVectorCode(String name, String classSimpleName, boolean primitive, int dimensions, String cppType) {
        int tabLevel = 1;
        String tabs = tabs(tabLevel);
        String prevVVarName = "";
        char prevLoopVarName = ' ';

        for (int i = 1; i <= dimensions; i++) {
            int level = dimensions + 1 - i;
            String vVarName = "v" + i + "_" + name;
            String vectorType = vectorCppTypeName(level, cppType);
            String lenVarName = vVarName + "_length";
            char loopVarName = (char) ('i' + (i - 1));

            if (i == 1) {
                load.println("\t// " + vectorType + " this->" + name);
                genDebug(load, "\tstd::cout << \"load " + vectorType + " " + name + "\" << std::endl;");
            }

            load.println(tabs + "int " + lenVarName + ";");

            load.println();
            load.println(tabs + INSTREAM_VAR_NAME + ".readInt( " + lenVarName + " );");

            genDebugDumpValue(load, lenVarName, tabs);

            if (i > 1) {
                // inside a for loop, inner vector variable initialized by
                // dereferencing iterator
                load.println(tabs + vectorType + "& " + vVarName + " = " + prevVVarName + ".at( " + prevLoopVarName + " );");
            } else {
                // outside for loop, inner vector variable initialized to member
                // variable
                load.println(tabs + vectorType + "& " + vVarName + " = this->" + name + ";");
            }

            if (i <= dimensions - 1) {
                // initialize & pre-allocate the vector at this level
                load.println(tabs + vVarName + " = " + vectorType + "( " + lenVarName + " );");
            } else {
                // initialize & pre-allocate the vector at this level
                load.println(tabs + vVarName + ".reserve( " + lenVarName + " );");
            }

            load.println();
            load.println(tabs + "for( int " + loopVarName + " = 0; " + loopVarName + " < " + lenVarName + "; " + loopVarName
                + "++ ){");

            tabLevel++;
            tabs = tabs(tabLevel);

            if (i == dimensions) {
                if (primitive || classSimpleName.equals("String")) {
                    load.println(tabs + cppType + " v" + i + ";");
                    load.println(tabs + genReadCode("v" + i, cppType(classSimpleName)));
                    load.println(tabs + vVarName + ".push_back( v" + i + " );");
                } else {
                    load.println(tabs + cppType + " v" + i + ";");
                    load.println(tabs + "v" + i + ".load( " + INSTREAM_VAR_NAME + " );");
                    load.println(tabs + vVarName + ".push_back( v" + i + " );");
                }
            }
            prevVVarName = vVarName;
            prevLoopVarName = loopVarName;
        }
        for (int i = 0; i < dimensions; i++) {
            tabLevel--;
            tabs = tabs(tabLevel);
            load.println(tabs + "}");
        }
    }

    /**
     * Generates code to save a std::vector<> field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     * @param cppType
     */
    private void genSaveVectorCode(String name, String classSimpleName, boolean primitive, int dimensions, String cppType) {
        int tabLevel = 1;
        String tabs = tabs(tabLevel);

        for (int i = 1; i <= dimensions; i++) {

            String itVarName = "i" + i + "_" + name;
            String vVarName = "v" + i + "_" + name;

            // another for(;;) loop...
            String vectorType = vectorCppTypeName(dimensions + 1 - i, cppType);

            if (i == 1) {
                save.println("\t// " + vectorType + " " + name);
                genDebug(save, "\tstd::cout << \"save " + vectorType + " " + name + "\" << std::endl;");
            }

            if (i > 1) {
                // inside a for loop, inner vector variable initialized by
                // dereferencing iterator
                save.println(tabs + vectorType + "& " + vVarName + " = (*i" + (i - 1) + "_" + name + ");");
            } else {
                // outside for loop, inner vector variable initialized to member
                // variable
                save.println(tabs + vectorType + "& " + vVarName + " = this->" + name + ";");
            }

            save.println(tabs + "int " + vVarName + "_length = " + vVarName + ".size();");

            save.println();
            save.println(tabs + OUTSTREAM_VAR_NAME + ".writeInt(" + vVarName + "_length);");

            genDebugDumpValue(save, vVarName + "_length", tabs);

            save.println();
            save.println(tabs + vectorType + "::iterator " + itVarName + ";");
            save.println(tabs + "for( " + itVarName + " = " + vVarName + ".begin(); " + itVarName + " != " + vVarName
                + ".end(); ++" + itVarName + " ){");

            tabLevel++;
            tabs = tabs(tabLevel);

            if (i == dimensions) {
                if (primitive || classSimpleName.equals("String")) {
                    save.println(tabs + cppType + " v" + i + " = (*" + itVarName + ");");
                    save.println(tabs + genWriteCode("v" + i, cppType));
                } else {
                    // save.println( tabs + type + " v" + i + " = (*" +
                    // itVarName + ");" );
                    // save.println( tabs + "v" + i + ".save( output );");
                    save.println(tabs + itVarName + " -> save( " + OUTSTREAM_VAR_NAME + " );");
                }
            }

            if (i < dimensions) {
            } else {
                if (i > 1) {
                    // not outside outer for(;;) loop
                    // bottom
                }
            }
        }

        for (int i = 0; i < dimensions; i++) {
            tabLevel--;
            tabs = tabs(tabLevel);
            save.println(tabs + "}");
        }
    }

    /**
     * Generates code to load a std::map<> field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     * @param cppType
     */
    private void genLoadMapCode(String name, String keyClassSimpleName, String valueClassSimpleName, boolean valueIsPersistable) {

        int tabLevel = 1;
        String tabs = tabs(tabLevel);

        String keyCppType = cppType(keyClassSimpleName);
        String valueCppType = cppType(valueClassSimpleName);

        String mapType = "std::map< " + keyCppType + ", " + valueCppType + " >";

        load.println("\t// " + mapType + " this->" + name);
        genDebug(load, "\tstd::cout << \"load " + mapType + " " + name + "\" << std::endl;");

        String vVarName = "v" + "_" + name;
        String lenVarName = vVarName + "_length";

        // read the length of the map
        load.println(tabs + "int " + lenVarName + ";");

        load.println();
        load.println(tabs + INSTREAM_VAR_NAME + ".readInt(" + lenVarName + ");");

        genDebugDumpValue(load, lenVarName, tabs);

        load.println(tabs + mapType + "& " + vVarName + " = this->" + name + ";");

        // initialize & pre-allocate the map
        // load.println( tabs + vVarName + ".reserve( " + lenVarName + " );");

        load.println();
        load.println(tabs + "for( int i = 0; i < " + lenVarName + "; i++ ){");

        tabs = tabs(++tabLevel);

        // load key
        String keyVarName = vVarName + "_key";
        load.println(tabs + keyCppType + " " + keyVarName + ";");
        load.println(tabs + genReadCode(keyVarName, keyCppType));

        // load value
        String valueVarName = vVarName + "_value";
        load.println(tabs + valueCppType + " " + valueVarName + ";");

        if (valueIsPersistable) {
            load.println(tabs + valueVarName + ".load( " + INSTREAM_VAR_NAME + " );");
        } else {
            load.println(tabs + genReadCode(valueVarName, valueCppType));
        }

        // add the new pair to the map
        load.println(tabs + vVarName + ".insert( std::make_pair( " + keyVarName + ", " + valueVarName + " ));");

        tabs = tabs(--tabLevel);
        load.println(tabs + "}");
    }

    /**
     * Generates code to save a std::map<> field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     * @param cppType
     */
    private void genSaveMapCode(String name, String keyClassSimpleName, String valueClassSimpleName, boolean elementIsPersistable) {

        int tabLevel = 1;
        String tabs = tabs(tabLevel);

        String itVarName = "i" + "_" + name;
        String vVarName = "v" + "_" + name;

        String keyCppType = cppType(keyClassSimpleName);
        String valueCppType = cppType(valueClassSimpleName);

        String mapType = "std::map< " + keyCppType + ", " + valueCppType + " >";

        save.println("\t// " + mapType + " " + name);
        genDebug(save, "\tstd::cout << \"save " + mapType + " " + name + "\" << std::endl;");

        // initialize local variable that points to the member map
        save.println(tabs + mapType + "& " + vVarName + " = this->" + name + ";");

        // number of elements in the map
        save.println(tabs + "int " + vVarName + "_length = " + vVarName + ".size();");

        save.println();
        save.println(tabs + OUTSTREAM_VAR_NAME + ".writeInt( " + vVarName + "_length );");

        genDebugDumpValue(save, vVarName + "_length", tabs);

        // loop through the elements and save each one
        save.println();
        save.println(tabs + mapType + "::iterator " + itVarName + ";");
        save.println(tabs + "for( " + itVarName + " = " + vVarName + ".begin(); " + itVarName + " != " + vVarName + ".end(); ++"
            + itVarName + " ){");

        tabs = tabs(++tabLevel);

        // save the key
        String keyVarName = vVarName + "_key";
        save.println(tabs + keyCppType + " " + keyVarName + " = " + itVarName + "->first;");
        save.println(tabs + genWriteCode(keyVarName, keyCppType));

        // save the value
        String valueVarName = vVarName + "_value";
        save.println(tabs + valueCppType + " " + valueVarName + " = " + itVarName + "->second;");

        if (elementIsPersistable) {
            save.println(tabs + valueVarName + ".save( " + OUTSTREAM_VAR_NAME + " );");
        } else {
            save.println(tabs + genWriteCode(valueVarName, valueCppType));
        }

        tabs = tabs(--tabLevel);
        save.println(tabs + "}");
    }

    /**
     * Generates code to load a std::set<> field
     * 
     * @param name
     * @param keyClassSimpleName
     */
    private void genLoadSetCode(String name, String keyClassSimpleName) {

        int tabLevel = 1;
        String tabs = tabs(tabLevel);

        String keyCppType = cppType(keyClassSimpleName);

        String setType = "std::set< " + keyCppType + " >";

        load.println("\t// " + setType + " this->" + name);
        genDebug(load, "\tstd::cout << \"load " + setType + " " + name + "\" << std::endl;");

        String vVarName = "v" + "_" + name;
        String lenVarName = vVarName + "_length";

        // read the length of the set
        load.println(tabs + "int " + lenVarName + ";");

        load.println();
        load.println(tabs + INSTREAM_VAR_NAME + ".readInt(" + lenVarName + ");");

        genDebugDumpValue(load, lenVarName, tabs);

        load.println(tabs + setType + "& " + vVarName + " = this->" + name + ";");

        // initialize & pre-allocate the set
        // load.println( tabs + vVarName + ".reserve( " + lenVarName + " );");

        load.println();
        load.println(tabs + "for( int i = 0; i < " + lenVarName + "; i++ ){");

        tabs = tabs(++tabLevel);

        // load key
        String keyVarName = vVarName + "_key";
        load.println(tabs + keyCppType + " " + keyVarName + ";");
        load.println(tabs + genReadCode(keyVarName, keyCppType));

        // add the new element to the set
        load.println(tabs + vVarName + ".insert( " + keyVarName + " );");

        tabs = tabs(--tabLevel);
        load.println(tabs + "}");
    }

    /**
     * Generates code to save a std::set<> field
     * 
     * @param name
     * @param keyClassSimpleName
     */
    private void genSaveSetCode(String name, String keyClassSimpleName) {

        int tabLevel = 1;
        String tabs = tabs(tabLevel);

        String itVarName = "i" + "_" + name;
        String vVarName = "v" + "_" + name;

        String keyCppType = cppType(keyClassSimpleName);

        String setType = "std::set< " + keyCppType + " >";

        save.println("\t// " + setType + " " + name);
        genDebug(save, "\tstd::cout << \"save " + setType + " " + name + "\" << std::endl;");

        // initialize local variable that points to the member set
        save.println(tabs + setType + "& " + vVarName + " = this->" + name + ";");

        // number of elements in the set
        save.println(tabs + "int " + vVarName + "_length = " + vVarName + ".size();");

        save.println();
        save.println(tabs + OUTSTREAM_VAR_NAME + ".writeInt( " + vVarName + "_length );");

        genDebugDumpValue(save, vVarName + "_length", tabs);

        // loop through the elements and save each one
        save.println();
        save.println(tabs + setType + "::iterator " + itVarName + ";");
        save.println(tabs + "for( " + itVarName + " = " + vVarName + ".begin(); " + itVarName + " != " + vVarName + ".end(); ++"
            + itVarName + " ){");

        tabs = tabs(++tabLevel);

        // save the key
        String keyVarName = vVarName + "_key";
        save.println(tabs + keyCppType + " " + keyVarName + " = *" + itVarName + ";");
        save.println(tabs + genWriteCode(keyVarName, keyCppType));

        tabs = tabs(--tabLevel);
        save.println(tabs + "}");
    }
    /**
     * generate read C++ code for a specified C++ variable and C++ type
     * 
     * @param name
     * @param type
     * @return
     */
    private String genReadCode(String name, String type) {

        if (type.equals("char")) {
            return INSTREAM_VAR_NAME + ".readChar( " + name + " );";
        } else if (type.equals("short")) {
            return INSTREAM_VAR_NAME + ".readShort( " + name + " );";
        } else if (type.equals("int")) {
            return INSTREAM_VAR_NAME + ".readInt( " + name + " );";
        } else if (type.equals("float")) {
            return INSTREAM_VAR_NAME + ".readFloat( " + name + " );";
        } else if (type.equals("double")) {
            return INSTREAM_VAR_NAME + ".readDouble( " + name + " );";
        } else if (type.equals("std::string")) {
            return INSTREAM_VAR_NAME + ".readString( " + name + " );";
        } else if (type.equals("bool")) {
            return INSTREAM_VAR_NAME + ".readBoolean( " + name + " );";
        } else {
            throw new IllegalArgumentException("unknown primitive type=" + type);
        }
    }

    /**
     * generate write C++ code for a specified C++ variable and C++ type
     * 
     * @param name
     * @param type
     * @return
     */
    private String genWriteCode(String name, String type) {

        if (type.equals("char")) {
            return OUTSTREAM_VAR_NAME + ".writeChar( " + name + " );";
        } else if (type.equals("short")) {
            return OUTSTREAM_VAR_NAME + ".writeShort( " + name + " );";
        } else if (type.equals("int")) {
            return OUTSTREAM_VAR_NAME + ".writeInt( " + name + " );";
        } else if (type.equals("float")) {
            return OUTSTREAM_VAR_NAME + ".writeFloat( " + name + " );";
        } else if (type.equals("double")) {
            return OUTSTREAM_VAR_NAME + ".writeDouble( " + name + " );";
        } else if (type.equals("std::string")) {
            return OUTSTREAM_VAR_NAME + ".writeString( " + name + " );";
        } else if (type.equals("bool")) {
            return OUTSTREAM_VAR_NAME + ".writeBoolean( " + name + " );";
        } else {
            throw new IllegalArgumentException("unknown primitive type=" + type);
        }
    }

    /**
     * Wraps the specified code in #ifdef DEBUG
     * 
     * @param writer
     * @param code
     */
    private void genDebug(PrintWriter writer, String code) {
        writer.println("#ifdef DEBUG");
        writer.println(code);
        writer.println("#endif /* #ifdef DEBUG */");
    }

    /**
     * Generates code to print the value of a variable in DEBUG mode
     * 
     * @param writer
     * @param varName
     * @param tabs
     */
    private void genDebugDumpValue(PrintWriter writer, String varName, String tabs) {
        genDebug(writer, tabs + "std::cout << \"" + varName + " = \" << " + varName + " << std::endl;");
    }
}
