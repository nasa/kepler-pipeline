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

package gov.nasa.kepler.services.cmdrunner;

import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class CommandRunnerClient {
    private static final Log log = LogFactory.getLog(CommandRunnerClient.class);
    
    private boolean useServer = true;
    
    public CommandRunnerClient() {
    }

    public CommandResults run(List<String> args, long timeoutMillis) throws PipelineException {
        return run(args, null, timeoutMillis);
    }
    
    public CommandResults run(List<String> args, File workingDir, long timeoutMillis) throws PipelineException {       
        
        CommandResults results = null;
        
        if(useServer){
            Socket socket = null;
            
            // initiate connection
            try {
                log.info("Connecting to command server at: " + CommandRunnerServer.SERVER_HOST 
                    + ":" + CommandRunnerServer.SERVER_PORT);
                socket = new Socket(CommandRunnerServer.SERVER_HOST, CommandRunnerServer.SERVER_PORT);
            } catch (Exception e) {
                throw new PipelineException("failed to connect to command server, caught e = " + e, e );
            }
            
            try {
                CommandRequest request = new CommandRequest(args, workingDir, timeoutMillis);            

                log.info("Sending request: " + request.toString());
                
                OutputStream socketOutput = socket.getOutputStream();
                ObjectOutputStream oos = new ObjectOutputStream(socketOutput);

                oos.writeObject(request);
                oos.flush();
            } catch (Exception e) {
                throw new PipelineException("failed to send request to command server, caught e = " + e, e );
            }
            
            try {
                log.info("Waiting for response...");
                
                ObjectInputStream ois = new ObjectInputStream(socket.getInputStream());
                results = (CommandResults) ois.readObject();
                
                log.info("Got a response: " + results.toString());

                socket.close();
            } catch (Exception e) {
                throw new PipelineException("failed to receive response from command server, caught e = " + e, e );
            }
        }else{
            try {
                results = CommandRunnerThread.exec(args, timeoutMillis, workingDir);
            } catch (Exception e) {
                throw new PipelineException("failed to execute command, caught e = " + e, e );
            }
        }
        
        return results;
    }

    public static void main(String[] args) {
        List<String> argsList = Arrays.asList(args);
        
        CommandRunnerClient c = new CommandRunnerClient();
        
        c.run(argsList, 10000);
    }

    public boolean isUseServer() {
        return useServer;
    }

    public void setUseServer(boolean useServer) {
        this.useServer = useServer;
    }
}
