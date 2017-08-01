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
import gov.nasa.kepler.io.DataOutputStream;


import gov.nasa.kepler.fs.client.ClientSideException;
import gov.nasa.kepler.fs.transport.ServerSideException;
import gov.nasa.kepler.fs.transport.TransportClient;
import gov.nasa.kepler.fs.transport.TransportException;
import gov.nasa.kepler.fs.transport.TransportServer;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.net.InetAddress;
import java.net.ProtocolException;
import java.net.SocketException;
import java.net.SocketTimeoutException;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import javax.transaction.xa.XAException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;


/**
 * Given an interface generate the server/client side code that calls this
 * interface's methods over the file store transport protocol.
 * 
 * @author Sean McCauliff
 *
 */
class FstpGenerator extends AbstractGenerator {
    
    private final List<String> disconnectExceptions = 
        ImmutableList.of(java.net.SocketException.class.getName(),
            java.net.ProtocolException.class.getName(),
            java.net.SocketTimeoutException.class.getName());
    /**
     * 
     * @param serverClassName  This is the fully qualified class name.
     * @param clientClassName this is a fullyQualified class name.
     * @param ifaceClass This class must be an interface. All super interface
     * methods will also be inspected.
     */
    FstpGenerator( String serverClassName,
        String clientClassName, InterfaceData ifaceClass) {
        super(serverClassName, clientClassName, ifaceClass);
    }

    @Override
    protected void addImplementationClassesToImports(ImportGenerator igen) {
        igen.addClass(TransportClient.class);
        igen.addClass(TransportException.class);
        igen.addClass(ServerSideException.class);
        igen.addClass(BufferedOutputStream.class);
        igen.addClass(BufferedInputStream.class);
        igen.addClass(DataInputStream.class);
        igen.addClass(DataOutputStream.class);
        igen.addClass(ifaceClass.interfaceClass());
        igen.addClass(IOException.class);
        igen.addClass(BinaryPersistableOutputStream.class);
        igen.addClass(BinaryPersistableInputStream.class);
        igen.addClass(InetAddress.class);
        igen.addClass(EOFException.class);
    }

    @Override
    protected void clientSpecificGeneration(StringBuilder bldr) {
        bldr.append("    protected abstract TransportClient transportClient();\n\n");      
    }

    @Override
    protected void generateClientMethodBody(MethodData mdata, StringBuilder bldr) {
        String returnMethodName = 
            "return"+
                capitalizeFirstLetter(mdata.method().getName())+mdata.methodIndex();
        String encodeRequestMethodName =
            "encodeRequest"+capitalizeFirstLetter(mdata.method().getName())+mdata.methodIndex();
        
        String protocolMethodName = 
            "protocolMethodName"+
                capitalizeFirstLetter(mdata.method().getName())+mdata.methodIndex();
        String indent = "    ";
        bldr.append(indent).append(mdata.signature()).append(" {\n");
        indent += "    ";
        //Send parameters.

        bldr.append(indent).append("try {\n");
        indent += "    ";
        bldr.append(indent).append("transportClient().startMethod();\n");
        bldr.append(indent).append(
            "BufferedOutputStream bout = new BufferedOutputStream(transportClient().outputStream(), 1024*1024);\n");
        bldr.append(indent).append(
        DataOutputStream.class.getName()).append(" dout = new ")
        	.append(DataOutputStream.class.getName()).append("(bout);\n");
        bldr.append(indent).append("String pname = ").append(protocolMethodName).append("();\n");
        bldr.append(indent).append("dout.writeUTF(pname);\n");
        bldr.append("\n");

        bldr.append(indent).append("@SuppressWarnings(\"unused\")\n")
            .append(indent)
            .append(
            "BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);\n");

        if (mdata.implicitParameter() != null) {
            ImplicitParameterData iparam = mdata.implicitParameter();
            writeOutSingleParameter(bldr, indent,iparam.parameterClass(), iparam.accessorMethodName()+"()");
        }
    
        if (mdata.needClientEncoding()) {
            bldr.append(indent).append(encodeRequestMethodName).append("(dout, pout, ");
            for (ParameterData parameter : mdata.parameters()) {
                bldr.append(parameter.parameterName()).append(",");
            }
            bldr.setLength(bldr.length() - 1);
            bldr.append(");\n");
            
        } else {
            
            for (ParameterData parameter : mdata.parameters()) {
                Class<?> parameterClass = parameter.getParameterClass();
                if (parameterClass.isArray()) {
                    bldr.append(indent).append("dout.writeInt(").append(
                        parameter.parameterName()).append(".length);\n");
                    bldr.append(indent).append("for (int i=0; i < ").append(
                        parameter.parameterName()).append(".length; i++) {\n");
                    writeOutSingleParameter(bldr, indent + "    ", parameterClass
                        .getComponentType(), parameter.parameterName() + "[i]");
                    bldr.append(indent).append("}\n");
                } else if (parameterClass.isAssignableFrom(Collection.class)) {
                    throw new IllegalStateException("Collections not implemneted.");
                } else {
                    writeOutSingleParameter(bldr, indent, parameterClass, parameter
                        .parameterName());
                }
            }
        }
     
        bldr.append(indent).append("bout.flush();\n\n");
        //Get stuff.
        if (mdata.method().getReturnType() == Void.TYPE) {
            //Read a byte of data to make sure there are no pending exceptions.
            bldr.append(indent).append("int okByte = transportClient().inputStream().read();\n");
            bldr.append(indent).append("if (okByte != 0) {\n");
            bldr.append(indent+"   ").append("throw new IOException(\"Protocol violation.\");\n");
            bldr.append(indent).append("}\n");
        } else {
            bldr.append(indent).append("BufferedInputStream bufin =" +
                    " new BufferedInputStream(transportClient().inputStream());\n");
            bldr.append(indent).append(DataInputStream.class.getName())
                .append(" din = new ").append(DataInputStream.class.getName())
                .append("(bufin);\n");
            bldr.append(indent).
                append("BinaryPersistableInputStream pin = " +
                        "new BinaryPersistableInputStream(din);\n");
            bldr.append(indent).append("return ").append(returnMethodName).append("(din,pin);\n");
        }
 
        //Start exception catch block.
        
        indent = indent.substring(0, indent.length() - 4);

        bldr.append(indent).append("} catch (RuntimeException rte) {\n");
        bldr.append(indent+"    ").append("gov.nasa.kepler.fs.api.gen.Utils.throwExceptionFromServer(rte);\n");
        bldr.append(indent+"    ").append("throw new IllegalStateException(\"This statement should never be reached.\");\n");
        bldr.append(indent).append("} catch (ServerSideException sse) {\n");
        if (mdata.throwsException(XAException.class)) {
            bldr.append(indent).append("    if (sse.getCause() instanceof javax.transaction.xa.XAException) {\n");
            bldr.append(indent).append("        gov.nasa.kepler.fs.api.gen.Utils.rethrowXAException(sse);\n");
            bldr.append(indent).append("    }\n");
        }
        bldr.append(indent).append("    gov.nasa.kepler.fs.api.gen.Utils.throwExceptionFromServer(sse);\n");
        bldr.append(indent).append("    throw new IllegalStateException(\"This statement should never be reached.\");\n");
        
        if (!mdata.throwsException(IOException.class)) {
            bldr.append(indent).append("} catch (IOException ioe) {\n");
            indent += "    ";
            bldr.append(indent).
                append("throw new FileStoreException(\"Transport layer exception.\", ioe);\n");
            indent = indent.substring(0, indent.length() - 4);
        }
        if (!mdata.throwsException(Exception.class)) {
            bldr.append(indent).append("} catch (Exception e) {\n");
            bldr.append(indent+"    try {\n");
            bldr.append(indent+"        transportClient().close();\n");
            bldr.append(indent+"    } catch (IOException ignored) {}\n");
            bldr.append(indent+"    throw new RuntimeException(\"Transport layer exception.\", e);\n");
        }
        bldr.append(indent).append("}\n");

        //end method
        indent = indent.substring(0, indent.length() - 4);
        bldr.append(indent).append("}\n\n");
        
        //abstract methods needed by this method.
        bldr.append(indent).append("protected abstract String ").
            append(protocolMethodName).append("();\n\n");
        
        if (mdata.needClientEncoding()) {
            bldr.append(indent).append("protected abstract void ").
                    append(encodeRequestMethodName).
                    append("(")
                    .append(DataOutputStream.class.getName())
                    .append(" dout, BinaryPersistableOutputStream pout,");
            
            for (ParameterData parameter : mdata.parameters()) {
                bldr.append(parameter.signature()).
                    append(" ").append(parameter.parameterName()).append(',');
            }
            bldr.setLength(bldr.length() - 1);
            bldr.append(") throws Exception;\n");
        }
        
        generateAbstractReturnMethod(mdata, bldr, returnMethodName);
        
    }

    /**
     * This does nothing.
     */
    @Override
    protected void generateCodeConstants(StringBuilder bldr) {
        //This does nothing.
    }

    @Override
    String generateServer() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("/** This is automatically generated source code.\n");
        bldr.append("  * Generated at : ").append(new Date()).append("\n");
        bldr.append("  */\n\n");
        //package header
        bldr.append("package ").append(serverPackageName()).append(";\n");
        
        //imports
        ImportGenerator igen = ifaceClass.importGenerator();
        igen.addClass(Log.class);
        igen.addClass(LogFactory.class);
        igen.addClass(TransportServer.class);
        igen.addClass(ClientSideException.class);

        addImplementationClassesToImports(igen);
        bldr.append(igen.imports(Package.getPackage(serverPackageName()))).append("\n\n");
        //class declaration
        bldr.append("public abstract class ").append(serverClassName());
        bldr.append(" { \n\n");
        
        //logger
        bldr.append("    private static final Log log = LogFactory.getLog(").
            append(serverClassName()).append(".class);\n\n");
        generateCodeConstants(bldr);
        
        bldr.append("    protected abstract boolean isShutdown();\n\n");
        
        bldr.append("    protected abstract boolean isClosed();\n\n");
        
        //Generate processMethod() method
        bldr.append("    public boolean processMethod(TransportServer transportServer, InetAddress clientAddress) throws Exception {\n\n");
        String indent = "        ";
        bldr.append(indent).append("try {\n");
        indent += "    ";
        bldr.append(indent).append(DataInputStream.class.getName()).append(" din = null;\n");
        bldr.append(indent).append("String methodName = parseMethodName(transportServer);\n");
        
        bldr.append(indent).append("if (methodName == null) {\n")
        .append(indent).append("    return false;\n");
        

        for (MethodData mdata : ifaceClass.methods()) {
            if (mdata.ignoreServerGeneration()) {
                continue;
            }
            bldr.append(indent).append("} else if (is").append(serverMethodSuffix(mdata)).append("(methodName)) {\n");
            bldr.append(indent+"    decode").append(serverMethodSuffix(mdata)).append("(transportServer);\n");
        }
        bldr.append(indent).append("} else {\n");
        indent += "    ";
        bldr.append(indent).append("methodName = methodName.length() > 32 ? methodName.substring(0,32) + \"TRUNCATED\" : methodName;\n");
        bldr.append(indent).append("String errMsg = \"Invalid method \\\"\" + methodName + \"\\\".\";\n");
        bldr.append(indent).append("log.error(errMsg);\n");
        bldr.append(indent).append("throw new IOException(errMsg);");
        indent = indent.substring(0,indent.length() - 4);
        bldr.append(indent).append("}\n\n");
        
        bldr.append(indent).append("if (isClosed()) {\n");
        bldr.append(indent + "    ").append("return false;\n");
        bldr.append(indent).append("}\n\n");
        
        indent = indent.substring(0, indent.length() - 4);
        bldr.append(indent).append("} catch (ClientSideException cse) {\n");
        bldr.append(indent + "    ").append("//ignored\n");
        //A this point in this catch chain from hell I really need to know
        //why protocol exception and sockettimeoutexception are not
        //subclasses of ProtocolException.  JDK 7, save me.
        for (String exceptionString : disconnectExceptions) {
            bldr.append(indent).append("} catch (").append(exceptionString).append(" x) {\n");
            bldr.append(indent+"    ")
                .append("log.error(\"Caught ").append(exceptionString).append(".  Closing connection to client.\");\n");
            bldr.append(indent + "    ").append("transportServer.close();\n");
        }
        bldr.append(indent).append("} catch (Exception e) {\n");
        bldr.append(indent+"    ").append("if(!isShutdown() && !(e instanceof java.nio.channels.ClosedByInterruptException) ) {\n");
        bldr.append(indent+"        ").append("log.error(\"Log error before sending to client.\", e);\n");
        bldr.append(indent+"    ").append("}\n");
        bldr.append(indent+"    ").append("transportServer.sendThrowable(e);\n");
       // bldr.append(indent+"    ").append("transportServer.close();\n");
        bldr.append(indent).append("} finally {\n");
        bldr.append(indent+"    ").append("transportServer.doneWithMethod();\n");
        bldr.append(indent+"    ").append("transportServer.outputStream().flush();\n");
        bldr.append(indent).append("}\n");
        bldr.append(indent).append("return true;\n");
        bldr.append("    } //end method\n");
        
        //Generate decode methods.
        for (MethodData mdata : ifaceClass.methods()) {
            if (mdata.needServerDecode() && mdata.ignoreServerGeneration()) {
                throw new IllegalStateException("Method may not be ignored for " +
                		"server generation and need decoding.");
            }
            
            if (mdata.ignoreServerGeneration()) {
                continue;
            }
            
            if (mdata.needServerDecode()) {
                ///Just add a user supplied decode method.
                bldr.append("    ").append("protected abstract void decode").
                    append(serverMethodSuffix(mdata)).
                    append("(TransportServer transportServer) throws Exception;\n");
            } else {
                //automatically generate the decode method.
                generateServerMethodBody(mdata, bldr);
            }
            //Abstract method to multiplex this methods.
            bldr.append("    protected abstract boolean is").
                append(serverMethodSuffix(mdata)).append("(String uriStr);\n\n\n");
        }
        
        generateParseMethodName(bldr);
        
        // end class
        bldr.append("}\n");
        return bldr.toString();
    }
    
    private void generateParseMethodName(StringBuilder bldr) {
        String indent = "        ";
        bldr.append("    private String parseMethodName(TransportServer transportServer) throws IOException {\n")
        .append(indent).append("try {");
        indent += "    ";
        bldr.append(indent)
        .append("gov.nasa.kepler.io.DataInputStream  din = new gov.nasa.kepler.io.DataInputStream(transportServer.inputStream());\n")
        .append(indent).append("return din.readUTF();\n");
        indent = indent.substring(4);
        bldr.append(indent)
        .append("} catch (java.nio.channels.ClosedByInterruptException clientClosed) {\n")
        .append(indent).append("    return null;")
        .append(indent).append("} catch (java.io.UTFDataFormatException utfx) {\n")
        .append(indent).append("    log.error(\"Client did not parse previous exception.\", utfx);\n")
        .append(indent).append("    return null;\n")
        .append(indent).append("}\n")
        .append("    }\n");
    }

    @Override
    protected void generateServerMethodBody(MethodData mdata, StringBuilder bldr) {
        if (mdata.ignoreServerGeneration()) {
            return;
        }
        
        bldr.append("    protected void decode").append(serverMethodSuffix(mdata)).
        append("(TransportServer transportServer)\n").
        append("     throws Exception {\n");
    
        String indent = "        ";
        bldr.append(indent).
            append("BufferedInputStream bufin = " +
                    "new BufferedInputStream(transportServer.inputStream());\n");
        bldr.append(indent).
            append(DataInputStream.class.getName()).append(" din = new ")
            .append(DataInputStream.class.getName()).append("(bufin);\n");
        bldr.append(indent).append("@SuppressWarnings(\"unused\")\n");
        bldr.append(indent).
            append("BinaryPersistableInputStream pin = new BinaryPersistableInputStream(din);\n");
    
        if (mdata.implicitParameter() != null) {
            ImplicitParameterData iparam = mdata.implicitParameter();
            bldr.append(indent).append("final ").append(iparam.parameterClass().getSimpleName())
                .append(" implicit;\n");
                readInSingleParameter(bldr, indent, iparam.parameterClass(), "implicit");
        }
    
        for (ParameterData pdata : mdata.parameters()) {
            bldr.append(indent).append("final ").append(pdata.getParameterClass().getSimpleName()).
                append(" ").append(pdata.finalVariableName()).append(";\n");
            readInSingleParameter(bldr, indent, pdata.getParameterClass(), pdata.finalVariableName());
        }

        bldr.append("\n");
  
        bldr.append(indent).append("BufferedOutputStream bufout =" +
                " new BufferedOutputStream(transportServer.outputStream());\n");
        bldr.append(indent)
            .append(DataOutputStream.class.getName()).append(" dout = new ")
            .append(DataOutputStream.class.getName()).append("(bufout);\n");
        bldr.append(indent)
            .append("BinaryPersistableOutputStream pout = " +
                    "new BinaryPersistableOutputStream(dout);\n");
        bldr.append(indent).append("execute").append(serverMethodSuffix(mdata)).
            append("(dout, pout,");
    
        for (ParameterData pdata : mdata.parameters()) {
            bldr.append(pdata.finalVariableName()).append(",");
        }
        if (mdata.implicitParameter() !=  null) {
            bldr.append("implicit,");
        }
        bldr.setCharAt(bldr.length() - 1, ')');
        bldr.append(";\n\n");
        
        //Send back some data so the client knows that everything is ok.
        if (mdata.method().getReturnType() == Void.TYPE) {
            bldr.append(indent).append("bufout.write(0);\n\n");
        }
        
        bldr.append(indent).append("bufout.flush();\n");
        indent = indent.substring(0, indent.length() - 4);
        bldr.append("    } //end method\n\n\n");
    
        //Abstract method to do the work of the server side.
        bldr.append("    protected abstract void execute").
            append(serverMethodSuffix(mdata)).append("(");
        bldr.append(DataOutputStream.class.getName()).append(" dout, BinaryPersistableOutputStream pout,");
        for (ParameterData pdata : mdata.parameters()) {
            bldr.append(pdata.getParameterClass().getSimpleName()).append(" ").
                append(pdata.parameterName()).append(",");
        }
        if (mdata.implicitParameter() != null) {
            ImplicitParameterData implicit = mdata.implicitParameter();
            bldr.append(implicit.parameterClass().getSimpleName())
                .append(" implicit,");
        }
        bldr.setLength(bldr.length() - 1);
        bldr.append(") throws Exception;\n\n\n");

    }

    
}
