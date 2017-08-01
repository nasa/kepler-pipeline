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

package gov.nasa.kepler.pi.module.io.matlab;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class MatlabWriteFunction extends MatlabFunction {

    public MatlabWriteFunction(String canonicalClassName, String simpleClassName, boolean topLevel) {
        super(canonicalClassName, simpleClassName, "write", topLevel);
    }

    /**
     * Returns the content of the write_*.m files after all fields have been
     * added
     * 
     * @return
     */
    @Override
    public String genFunctionContents() {
        StringWriter content = new StringWriter();
        PrintWriter w = new PrintWriter(content);
        String functionDeclaration;

        functionDeclaration = "function " + functionName + "(file, s)";
        printHeader(w, functionDeclaration);

        printFileOpenCode(w, "wb");

        w.print(contents.toString());
        w.println();

        w.println("if(closeFile)");
        w.println("    fclose(fid);");
        w.println("end;");
        w.println();

        return content.toString();
    }

    /**
     * Adds load and save code for the specified field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     */
    @Override
    public void addField(String name, String classSimpleName, boolean primitive, boolean preservePrecision) {

        contentsWriter.println();

        genDebug(contentsWriter, "disp(\"write " + classSimpleName + " " + name + "\");");

        contentsWriter.println("% " + classSimpleName + " " + name);

        if (!useStringRepresentation(classSimpleName)) {
            /*
             * Make sure scalar and non-array struct fields are not empty ([]). If
             * they are, the MATLAB fwrite function will silently write nothing to
             * the .bin file, resulting in an error when the file is deserialized
             */
            contentsWriter.println("if(isempty(s." + name + "))");
            contentsWriter.println("\terror('Error serializing .bin file, scalars and non-array structs must not be empty, field = "
                + name + "');");
            contentsWriter.println("end;");
        }

        if (useStringRepresentation(classSimpleName)) {
            genWriteStringCode("", "s." + name);
        } else if (primitive) {
            String matlabType = matlabType(classSimpleName);
            contentsWriter.println(genWriteCode("s." + name, matlabType));
        } else {
            // Make sure non-array structs are really not arrays or matrices
            // (should be [1x1 struct])
            contentsWriter.println("if(~(numel(s." + name + ") == 1))");
            contentsWriter.println("\terror('Error serializing .bin file, too many elements in non-array struct; field = "
                + name + ".  Expected [1x1 struct]');");
            contentsWriter.println("end;");

            contentsWriter.println("write_" + classSimpleName + "(fid, " + "s." + name + ");");
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
    @Override
    public void addListField(String name, String classSimpleName, boolean primitive, int dimensions, boolean preservePrecision) {
        contentsWriter.println();
        contentsWriter.print("% " + classSimpleName + " " + name);
        for (int i = 0; i < dimensions; i++) {
            contentsWriter.print("[]");
        }
        contentsWriter.println();

        genArrayCode(name, classSimpleName, primitive, dimensions, preservePrecision, true);
    }

    private void genWriteStringCode(String tabs, String name) {
        /*
         * Example:
         * 
         * fwrite(fid, length(dataStruct.string), 'int32'); fwrite(fid,
         * dataStruct.string, 'char');
         */
        contentsWriter.println(tabs + genWriteCode("length(" + name + ")", "int32"));
        contentsWriter.println(tabs + genWriteCode(name, "char"));
    }

    private String genWriteCode(String name, String matlabType) {
        String binType;

        if (matlabType.equals("logical")) {
            binType = "uint8";
        } else {
            binType = matlabType;
        }
        return "fwrite(fid, " + name + ", '" + binType + "');";
    }

    @Override
    protected void genLengthCode(String name, String lenVarName) {
        contentsWriter.println(tabs + lenVarName + " = length(" + name + ");");
        contentsWriter.println(tabs + genWriteCode(lenVarName, "int32"));
        genDebugDumpValue(contentsWriter, lenVarName, tabs);
    }

    @Override
    protected void genPersistableCode(String classSimpleName, String name) {
        contentsWriter.println(tabs + "write_" + classSimpleName + "(fid, " + name + ");");
    }

    @Override
    protected void genReadWritePrimitiveCode(String name, String lenVarName, String matlabType, boolean preservePrecision) {
        contentsWriter.println(tabs + genWriteCode(name, matlabType));
    }

    @Override
    protected void genStringCode(String name) {
        genWriteStringCode(tabs, name);
    }

    @Override
    protected void genPostLoopCode() {
    }

    @Override
    protected void genPreLoopCode(String arrayVarName, String lenVarName) {
    }

    /**
     * No need to preallocate on write.
     */
    @Override
    protected void genStructArrayPreallocationCode(int arrayDimensions,
        String lenVarName, String arrayIndexName, String arrayVarName) {
    }



}
