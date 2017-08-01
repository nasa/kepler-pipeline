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

package gov.nasa.kepler.fs.api.gen;

import gov.nasa.kepler.io.DataInputStream;

import static gov.nasa.kepler.fs.api.gen.Utils.className;
import static gov.nasa.kepler.fs.api.gen.Utils.packageName;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;


abstract class AbstractGenerator {

    protected final String fullServerClassName;

    protected abstract void generateServerMethodBody(MethodData mdata, StringBuilder bldr);

    abstract String generateServer();

    protected abstract void addImplementationClassesToImports(ImportGenerator igen);

    /**
     * Generate the source code for a client method.
     * @param mdata
     * @param bldr
     */
    protected abstract void generateClientMethodBody(MethodData mdata, 
                                                                                          StringBuilder bldr);
    
    /**
     * Executed after other methods have been generated.  This is a hook
     * for implementation classes to add their own stuff into the class body.
     * @param bldr
     */
    protected abstract void clientSpecificGeneration(StringBuilder bldr);
    
    protected  String generateClient() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("/** This is automatically generated source code.\n");
        bldr.append("  * Generated at : ").append(new Date()).append("\n");
        bldr.append("  */\n\n");
        
        //package name
        bldr.append("package ").append(clientPackageName()).append(";\n");
        
        //Import statements
        ImportGenerator igen = ifaceClass.importGenerator();
        addImplementationClassesToImports(igen);
        bldr.append(igen.imports(Package.getPackage(clientPackageName()))).append("\n\n");
        
        //Class declaration
        bldr.append("public abstract class ").append(clientClassName());
        bldr.append(" implements ").append(
            ifaceClass.interfaceClass().getSimpleName());
        bldr.append(" {\n\n");
        
        //Constants
        generateCodeConstants(bldr);
        
        //Declare implcit parameters.
        ImplicitParameterData[] implicitParameters = 
                                                ifaceClass.implicitParameters();
        for (ImplicitParameterData iparam : implicitParameters) {
            bldr.append("    protected abstract ").
                               append(iparam.methodSignature()).append(";\n\n");
          
        }
            
        //Method definition.
        for (MethodData mdata : ifaceClass.methods()) {
            if (mdata.ignoreClientGeneration()) {
                continue;
            }
            generateClientMethodBody(mdata, bldr);
        }

        clientSpecificGeneration(bldr);
        
        // end class
        bldr.append("}\n");
        return bldr.toString();
    }

   

    protected abstract void generateCodeConstants(StringBuilder bldr);

    protected final String fullClientClassName;
    protected final InterfaceData ifaceClass;

    public AbstractGenerator(String fullServerClassName,
                                             String fullClientClassName, 
                                             InterfaceData ifaceData) {
        super();
        this.fullClientClassName = fullClientClassName;
        this.fullServerClassName = fullServerClassName;
        this.ifaceClass = ifaceData;
    }

    protected String clientPackageName() {
        return packageName(fullClientClassName);
    }

    protected String serverPackageName() {
        return packageName(fullServerClassName);
    }

    protected String clientClassName() {
        return className(fullClientClassName);
    }

    protected String serverClassName() {
        return className(fullServerClassName);
    }

    protected String serverMethodSuffix(MethodData mdata) {
        StringBuilder bldr = new StringBuilder();
        bldr.append(capitalizeFirstLetter(mdata.method().getName())).append(mdata.methodIndex());
        return bldr.toString();
    }

    protected String capitalizeFirstLetter(String s) {
        if (s.length() == 0) {
            return s;
        }
        StringBuilder bldr = new StringBuilder(s);
        bldr.setCharAt(0, Character.toUpperCase(bldr.charAt(0)));
        return bldr.toString();
    }
    
    protected void writeOutSingleParameter(StringBuilder bldr, String indent,
        Class<?> type, String parameterName) {
        bldr.append(indent);
        if (type.isPrimitive()) {
            if (type == Integer.TYPE) {
                bldr.append("dout.writeInt(");
            } else if (type == Byte.TYPE) {
                bldr.append("dout.write(");
            } else if (type == Short.TYPE) {
                bldr.append("dout.writeShort(");
            } else if (type == Long.TYPE) {
                bldr.append("dout.writeLong(");
            } else if (type == Boolean.TYPE) {
                bldr.append("dout.writeBoolean(");
            } else if (type == Double.TYPE) {
                bldr.append("dout.writeDouble(");
            } else {
                throw new IllegalStateException("Unimplemented primitve\""
                    + type.getSimpleName() + "\".");
            }
            
        } else if (type == String.class) {
            bldr.append("dout.writeUTF(");
        } else if (Persistable.class.isAssignableFrom(type)) {
            bldr.append("pout.save(");
        } else if (List.class.isAssignableFrom(type)) {
            bldr.append("pout.save(");
        } else {
            throw new IllegalStateException(
                "Parameter of type \""
                    + type.getSimpleName()
                    + "\" does not implement Persistable nor is it a primitive type.");
        }
        bldr.append(parameterName).append(");\n");
    }

    /**
     * Generates the code to unmarshell a single parameter either via assignment
     * via the various read() method in DataInputStream or via the load method
     * in BinaryPersistableInputStream.
     *  
     * @param bldr
     * @param indent
     * @param type  Persistable, primitive, an array of Persistable, 
     *     or Collection of Persistable.
     * @param parameterName
     */
    protected void readInSingleParameter(StringBuilder bldr, String indent,
        Class<?> type, String parameterName) {
        if (type.isArray()) {
            bldr.append(indent).append("int ").append(parameterName).append("Size = din.readInt();\n");
            bldr.append(indent).append(parameterName).append(" = new ").append(type.getSimpleName());
            bldr.setLength(bldr.length() -1);
            bldr.append(parameterName).append("Size];\n");
            bldr.append(indent).append("for (int i=0; i < ").append(parameterName).append("Size; i++) {\n");
            readInSingleParameter(bldr, indent + "    ", type.getComponentType(), parameterName+"[i]");
            bldr.append(indent).append("}\n");
        } else if (type.isPrimitive()) {
            if (type == Boolean.TYPE) {
                bldr.append(indent).append(parameterName).append(
                    " = din.readBoolean();\n");
            } else if (type == Integer.TYPE) {
                bldr.append(indent).append(parameterName).append(" = din.readInt();\n");
            } else if (type == Double.TYPE) {
                bldr.append(indent).append(parameterName).append(" = din.readDouble();\n");
            } else {
                throw new IllegalArgumentException("Primitive type \"" + type
                    + "\" not implemented yet.");
            }
        } else if (Persistable.class.isAssignableFrom(type)) {
            //All persistables must have a default constructor for this reason.
            bldr.append(indent).append(parameterName).append(" = new ").
                append(type.getSimpleName()).append("();\n");
            bldr.append(indent).append("pin.load(").append(parameterName)
                .append(");\n");
        } else if (String.class == type) {
            bldr.append(indent).append(parameterName).append(
            " = din.readUTF();\n");
        } else if (Collection.class.isAssignableFrom(type)) {
            if (List.class.isAssignableFrom(List.class)) {
                bldr.append(indent).append(parameterName).append(" = new ArrayList();\n");
            } else if (Map.class.isAssignableFrom(type)) {
                bldr.append(indent).append(parameterName).append(" = new HashMap();\n");
            } else {
                throw new IllegalStateException("Unsupported Collection type \"" 
                    + type.getSimpleName() + "\".");
            }
            bldr.append(indent).append("pin.load(").append(parameterName)
                .append(");\n");
        } else {
            throw new IllegalStateException(
                "Parameter of type \""
                    + type.getSimpleName()
                    + "\" does not implement Persistable nor is it a primitive type.");
        }
    }

    /**
     * @param mdata
     * @param bldr
     * @param returnMethodName
     */
    protected void generateAbstractReturnMethod(MethodData mdata, StringBuilder bldr, String returnMethodName) {
        //abstract method that decodes the return type.
        if (mdata.method().getReturnType() != Void.TYPE) {
            String returnTypeName = mdata.method().getGenericReturnType().toString();
            if (returnTypeName.indexOf("<") == -1) {
                returnTypeName = mdata.method().getReturnType().getSimpleName();
            }
            bldr.append("    protected abstract ").
                append(returnTypeName).append(' ').
                append(returnMethodName).
                append("(").append(DataInputStream.class.getName()).append(" din, BinaryPersistableInputStream pin) throws Exception;\n\n");
            
        }
    }

}