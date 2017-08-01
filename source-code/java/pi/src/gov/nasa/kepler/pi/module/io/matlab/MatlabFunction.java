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
public abstract class MatlabFunction {

    private static final String TAB = "    ";

    protected String canonicalClassName;
    protected String simpleClassName;

    protected String functionName;
    protected String functionType;
    protected boolean topLevel = false;

    protected StringWriter contents = new StringWriter();
    protected PrintWriter contentsWriter = new PrintWriter(contents);

    private int tabLevel;
    protected String tabs;

    public MatlabFunction(String canonicalClassName, String simpleClassName, String functionType, boolean topLevel) {
        this.canonicalClassName = canonicalClassName;
        this.simpleClassName = simpleClassName;
        this.functionName = functionType + "_" + simpleClassName;
        this.functionType = functionType;
        this.topLevel = topLevel;
    }

    public String getFunctionName() {
        return functionName;
    }

    /**
     * Return the final full contents of the function
     * 
     * @return
     */
    public abstract String genFunctionContents();

    /**
     * Add a field to the read/write function
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param preservePrecision
     */
    public abstract void addField(String name, String classSimpleName, boolean primitive, boolean preservePrecision);
    
    /**
     * Add an array field to the read/write function
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     * @param preservePrecision
     */
    public abstract void addListField(String name, String classSimpleName, boolean primitive, int dimensions, boolean preservePrecision);

    /**
     * Generate the code to read/write the length info for repeating elements
     * 
     * @param tabs
     * @param name
     * @param lenVarName
     */
    protected abstract void genLengthCode(String name, String lenVarName);

    /**
     * Hook for adding code before for loops after the length variable is
     * initialized. For example, allows the read code to initialize an empty
     * array when length == 0
     * 
     * @param tabs
     */
    protected abstract void genPreLoopCode(String arrayVarName, String lenVarName);

    /**
     * Hook for adding code after a for loop
     * 
     * @param tabs
     * @param lenVarName
     */
    protected abstract void genPostLoopCode();

    /**
     * Generate the code to read/write Strings
     * 
     * @param tabs
     * @param name
     */
    protected abstract void genStringCode(String name);

    /**
     * Generate the code to read/write single primitives
     * 
     * @param tabs
     * @param name
     * @param lenVarName
     * @param matlabType
     */
    protected abstract void genReadWritePrimitiveCode(String name, String lenVarName, String matlabType,
        boolean preservePrecision);

    /**
     * Generate the code to read/write Persistables
     * 
     * @param tabs
     * @param classSimpleName
     * @param name
     */
    protected abstract void genPersistableCode(String classSimpleName, String name);

    /**
     * 
     * @param arraySize
     * @param arrayIndexName
     */
    protected abstract void genStructArrayPreallocationCode(int arrayDimensions, String lenVarName,
        String arrayIndexName, String arrayVarName);

    /**
     * Treat these types as strings in the generated code.  The .bin file will have
     * the toString() value for objects of these types.
     * 
     * @param classSimpleName
     * @return
     */
    protected boolean useStringRepresentation(String classSimpleName){
        return(classSimpleName.equals("String") 
        || classSimpleName.equals("Date") 
        || classSimpleName.equals("Enum"));
    }
    
    /**
     * Generates code to read/write an array or List field
     * 
     * @param name
     * @param classSimpleName
     * @param primitive
     * @param dimensions
     * @param preservePrecision
     */
    protected void genArrayCode(String name, String classSimpleName, boolean primitive, int dimensions,
        boolean preservePrecision, boolean isWrite) {
        
        boolean isRead = !isWrite;
        StringBuffer varSuffix = new StringBuffer();
        String prevVarSuffix = "";
        boolean isString = useStringRepresentation(classSimpleName);
        int innerMostDimension;

        tabLevel = 0;
        tabs = tabs(tabLevel);

        if (primitive && !isString) {
            innerMostDimension = dimensions - 1;
        } else {
            innerMostDimension = dimensions;
        }

        for (int currentDimension = 1; currentDimension <= dimensions; currentDimension++) {
            prevVarSuffix = varSuffix.toString();
            String vVarName = "v" + currentDimension + "_" + name;
            String lenVarName = vVarName + "_length";
            char loopVarName = (char) ('i' + (currentDimension - 1));
            if (currentDimension == 1) {
                genDebug(contentsWriter, "disp('write " + classSimpleName + " " + name + "');");
            }

            String arrayVarName = "s." + name + varSuffix;

            /* make sure arrays are really just vectors and not matrices (at most one dimension
             * has size > 1) */
            if (isWrite && !isString) {
                contentsWriter.println(tabs + "if(length(find(size(" + arrayVarName + ") > 1)) > 1)");
                contentsWriter.println(tabs + "\terror('Error serializing .bin file: field " + arrayVarName
                    + " is not a vector (see array2D_to_struct.m)');");
                contentsWriter.println(tabs + "end;");
            }

            genLengthCode(arrayVarName, lenVarName);

            if (isString && currentDimension > 1) {
                genPreLoopCode(arrayVarName, lenVarName);
                if(isRead){
                    contentsWriter.println(tabs + "tmp = cell(1, " + lenVarName + ");");                    
                }
            } else {
                genPreLoopCode(arrayVarName, lenVarName);
            }
            genDebugDumpValue(contentsWriter, lenVarName, tabs);

            /*
             * Do the for loops for arrays of primitives, skip the inner-most
             * dimension (we'll read/write the whole array with one
             * fread()/fwrite())
             */
            if (currentDimension <= innerMostDimension) {
                contentsWriter.println();
                contentsWriter.println(tabs + "for " + loopVarName + " = 1:" + lenVarName);
                incrementTabs();
            }

            // strings
            if (isString) {
                varSuffix.append("{" + loopVarName + "}");
            }

            // objects
            if (!primitive) {
                if (currentDimension < innerMostDimension) {
                    varSuffix.append("(" + loopVarName + ").array");
                } else {
                    varSuffix.append("(" + loopVarName + ")");
                }
            }

            if (currentDimension == dimensions) {
                /*
                 * inner-most dimension: this is where the fread()/fwrite() code
                 * is.
                 * 
                 * Write: 1D example: fwrite(fid, s.floatArray1, 'float32'); 2D
                 * example: fwrite(fid, s.floatArray2(j).array, 'float32'); 3D
                 * example: fwrite(fid, s.floatArray3(i).array(j).array,
                 * 'float32');
                 * 
                 * Read: 1D example: s.floatArray1 = fread(fid,
                 * v1_floatArray1_length, 'float32'); 2D example:
                 * s.floatArray2(j).array = fread(fid, v2_floatArray2_length,
                 * 'float32'); 3D example: s.floatArray3(i).array(j).array =
                 * fread(fid, v3_floatArray3_length, 'float32');
                 */
                if (isString) {
                    if (currentDimension > 1 && isRead) {
                        genStringCode("tmp{" + loopVarName + "}");
                    } else {
                        genStringCode("s." + name + varSuffix);
                    }
                } else if (primitive) {
                    genReadWritePrimitiveCode("s." + name + varSuffix, lenVarName, matlabType(classSimpleName),
                        preservePrecision);
                } else {
                    genPersistableCode(classSimpleName, "s." + name + varSuffix);
                    genStructArrayPreallocationCode(dimensions, lenVarName, "" + loopVarName, "s." + name);
                }
            }

            /*
             * Primitives
             * 
             * We don't need a varSuffix for the inner-most dimension or for
             * single-dimensional arrays, so we only add this for the *next*
             * time through the loop
             */
            if (primitive && !isString) {
                varSuffix.append("(" + loopVarName + ").array");
            }
        }

        // contentsWriter.println("innerMostDimension = " + innerMostDimension);
        for (int i = 1; i <= dimensions; i++) {
            // contentsWriter.println("i = " + i);
            if (i <= innerMostDimension) {
                decrementTabs();
                contentsWriter.println(tabs + "end;");
            }
            if (isString) {
                if (i < innerMostDimension && isRead) {
                    contentsWriter.println(tabs + "s." + name + prevVarSuffix + " = tmp;");
                }
                genPostLoopCode();
            } else {
                genPostLoopCode();
            }

        }
    }

    /**
     * Utility function that returns a String containing spaces representing the
     * specified number of tabs
     * 
     * @param indentLevel
     * @return
     */
    protected String tabs(int indentLevel) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < indentLevel; i++) {
            sb.append(TAB);
        }
        return sb.toString();
    }

    protected void incrementTabs() {
        tabLevel++;
        tabs = tabs(tabLevel);
    }

    protected void decrementTabs() {
        tabLevel--;
        tabs = tabs(tabLevel);
    }

    /**
     * 
     * @param w
     */
    protected void printHeader(PrintWriter w, String functionDeclaration) {
        w.println(functionDeclaration);
        w.println("%" + functionDeclaration);
        w.println("%");
        w.println("% This code was auto-generated by gov.nasa.kepler.pi.module.io.matlab.MatlabProxyGenerator");
        w.println("% based on the Java class: " + canonicalClassName);
        w.println("%");
        w.println("% WARNING: DO NOT EDIT THIS FILE");
        w.println("% Manual edits to this file will be overwritten.");
    }

    /**
     * Returns the equivelent Matlab type name for the specified java type name
     * 
     * @param javaType
     * @return
     */
    protected String matlabType(String javaType) {
        String matlabType;

        if (javaType.equals("boolean")) {
            matlabType = "logical";
        } else if (javaType.equals("byte")) {
            matlabType = "uint8";
        } else if (javaType.equals("short")) {
            matlabType = "int16";
        } else if (javaType.equals("int")) {
            matlabType = "int32";
        } else if (javaType.equals("long")) {
            matlabType = "int64";
        } else if (javaType.equals("float")) {
            matlabType = "float32";
        } else if (javaType.equals("double")) {
            matlabType = "double";
        } else if (javaType.equals("char")) {
            matlabType = "uint8";
        } else {
            matlabType = javaType;
        }
        return matlabType;
    }

    /**
     * Wraps the specified code in #ifdef DEBUG
     * 
     * @param writer
     * @param code
     */
    protected void genDebug(PrintWriter writer, String code) {
        // writer.println(code);
    }

    /**
     * Generates code to print the value of a variable in DEBUG mode
     * 
     * @param writer
     * @param varName
     * @param tabs
     */
    protected void genDebugDumpValue(PrintWriter writer, String varName, String tabs) {
        // genDebug(writer, tabs + "disp('" + varName + " = ' '" + varName +
        // "');");
    }

    /**
     * @param w
     */
    protected void printFileOpenCode(PrintWriter w, String mode) {
        w.println();
        w.println("if(isnumeric(file))");
        w.println("    % assume a file descriptor was passed in");
        w.println("   fid = file;");
        w.println("   closeFile = false;");
        w.println("else");
        w.println("    % assume a filename was passed in");
        w.println("    fid = fopen(file, '" + mode + "');");
        w.println("    if(fid == -1)");
        w.println("      error(['" + functionName + ": Unable to open file: ' file ]);");
        w.println("    end;");
        w.println("    closeFile = true;");
        w.println(" end;");
    }

}
