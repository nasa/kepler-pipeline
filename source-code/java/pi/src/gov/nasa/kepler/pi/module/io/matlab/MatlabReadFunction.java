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
 * Generates the Matlab Read function for a Java class
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class MatlabReadFunction extends MatlabFunction {

    public MatlabReadFunction(String canonicalClassName, String simpleClassName, boolean topLevel) {
        super(canonicalClassName, simpleClassName, "read", topLevel);
    }

    /**
     * Returns the content of the X_read.m files after all fields have been
     * added
     * 
     * @return
     */
    @Override
    public String genFunctionContents() {
        StringWriter content = new StringWriter();
        PrintWriter w = new PrintWriter(content);
        String functionDeclaration;

        functionDeclaration = "function s = " + functionName + "(file)";
        printHeader(w, functionDeclaration);

        printFileOpenCode(w, "rb");

        w.print(contents.toString());
        w.println();

        w.println("if(closeFile)");
        w.println("    fclose(fid);");
        w.println("end;");
        w.println();

        return content.toString();
    }

    /**
     * Adds read code for the specified field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     */
    @Override
    public void addField(String name, String classSimpleName, boolean primitive, boolean preservePrecision) {

        contentsWriter.println();

        genDebug(contentsWriter, "disp(\"read " + classSimpleName + " " + name + "\");");

        contentsWriter.println("% " + classSimpleName + " " + name);

        if (useStringRepresentation(classSimpleName)) {
            genReadStringCode("", "s." + name);
        } else if (primitive) {
            String matlabType = matlabType(classSimpleName);
            contentsWriter.println(genReadCode("s." + name, "1", matlabType, false));
        } else {
            contentsWriter.println("s." + name + " = read_" + classSimpleName + "(fid);");
        }
    }

    /**
     * Generates read code for a java.util.List or array field
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

        genArrayCode(name, classSimpleName, primitive, dimensions, preservePrecision, false);
    }

    /**
     * Generate code to read a data element.
     * 
     * The preservePrecision flag specifies whether generated MATLAB code will preserve the native 
     * precision of the data in the .bin file or convert to double (the default), as shown here:1  
     * 
     * <pre>
     * If true, the generated code will look like this:
     *   s.ccdModule = fread(fid, 1, '*int32');
     * if false, the generated code will look like this:
     *   s.ccdModule = fread(fid, 1, 'int32');
     * </pre>
     * 
     * Only used for primitive fields.
     * @param name
     * @param lengthVar
     * @param matlabType
     * @param preservePrecision
     * @return
     */
    private String genReadCode(String name, String lengthVar, String matlabType, boolean preservePrecision) {
        String readCode;
        
        if (matlabType.equals("logical")) {
            readCode = name + " = logical(fread(fid, " + lengthVar + ", 'uint8'));";
        } else {
            String precisionString = "";
            
            if(preservePrecision){
                precisionString = "*";
            }

            readCode = name + " = fread(fid, " + lengthVar + ", '" + precisionString + matlabType + "');";
        }
        return readCode;
    }

    private void genReadStringCode(String tabs, String name) {
        /*
         * Example:
         * 
         * stringLength = fread(fid, 1, 'int32'); string = fread(fid,
         * stringLength, 'char'); resultsStruct.huffmanCodeStrings{i} =
         * char(string');
         */
        contentsWriter.println(tabs + genReadCode("stringLength", "1", "int32", false));
        contentsWriter.println(tabs + genReadCode("string", "stringLength", "char", false));
        contentsWriter.println(tabs + name + " = char(string');");
    }

    @Override
    protected void genLengthCode(String name, String lenVarName) {
        contentsWriter.println(tabs + genReadCode(lenVarName, "1", "int32", false));
        genDebugDumpValue(contentsWriter, lenVarName, tabs);
    }

    @Override
    protected void genPersistableCode(String classSimpleName, String name) {
        contentsWriter.println(tabs + name + " = read_" + classSimpleName + "(fid);");
    }

    @Override
    protected void genReadWritePrimitiveCode(String name, String lenVarName, String matlabType, boolean preservePrecision) {
        contentsWriter.println(tabs + genReadCode(name, lenVarName, matlabType, preservePrecision));
    }

    @Override
    protected void genStringCode(String name) {
        genReadStringCode(tabs, name);
    }

    @Override
    protected void genPreLoopCode(String arrayVarName, String lenVarName) {
        contentsWriter.println(tabs + "if(" + lenVarName + " == 0)");
        incrementTabs();
        contentsWriter.println(tabs + arrayVarName + " = [];");
        decrementTabs();
        contentsWriter.println(tabs + "else");
        incrementTabs();
    }

    @Override
    protected void genPostLoopCode() {
        decrementTabs();
        contentsWriter.println(tabs + "end;");

    }

    @Override
    protected void genStructArrayPreallocationCode(
        int arrayDimensions, String arraySizeVar, String arrayIndexName, String arrayVarName) {
        
        if (arrayDimensions != 1) {
            return; //cowardly skipping more complicated issues.
        }
        
        contentsWriter.println(tabs + "if (" + arrayIndexName  + " == 1)");
        incrementTabs();
        contentsWriter.println(tabs + arrayVarName + "(1:" + arraySizeVar + ") = " + arrayVarName + "(1);");
        decrementTabs();
        contentsWriter.println(tabs + "end;");
    }
}
