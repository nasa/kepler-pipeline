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
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.util.List;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecuteResultHandler;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteWatchdog;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.exec.ShutdownHookProcessDestroyer;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


public class CommandRunnerThread implements Runnable {
    static final Log log = LogFactory.getLog(CommandRunnerThread.class);

    private Socket clientSocket;
    
    public CommandRunnerThread(Socket clientSocket) {
        this.clientSocket = clientSocket;
    }

    @Override
    public void run() {
        CommandRequest request;
        String requestDescr = "?";
        
        try {
            ObjectInputStream ois = new ObjectInputStream(clientSocket.getInputStream());
            request = (CommandRequest) ois.readObject();
            requestDescr = request.toString();
            log.info("Got a request: " + requestDescr);
            
            long requestAge = System.currentTimeMillis() - request.getRequestTime();
            if(requestAge >= CommandRunnerServer.REQUEST_EXPIRY_MILLIS){
                // expired request
                throw new PipelineException("Request is expired(" 
                    + CommandRunnerServer.REQUEST_EXPIRY_MILLIS+"), age=" 
                    + requestAge + ", desc=" + requestDescr);
            }
            
            List<String> commandAndArgs = request.getArgs();
            if(commandAndArgs.size() <= 0){
                throw new PipelineException("No command specified, desc=" + requestDescr);
            }

            long timeout = request.getTimeoutMillis();
            File workingDir = request.getWorkingDir();
            
            log.info("Starting external process, desc=" + requestDescr);
            
            CommandResults results = exec(commandAndArgs, timeout, workingDir);
            
            log.info("Writing results to client, desc=" + requestDescr);
            
            ObjectOutputStream oos = new ObjectOutputStream(clientSocket.getOutputStream());
            oos.writeObject(results);
            oos.flush();

            log.info("Done! -- desc=" + requestDescr);
        } catch (Exception e) {
            log.error("Failed to process request (" + requestDescr + "), caught e:", e);
        } finally {
            try {
                clientSocket.close();
            } catch (IOException e) {
                log.error("Failed to close client socket, caught e:", e);
            }
        }
    }
    
    static CommandResults exec(List<String> commandAndArgs, long timeout, File workingDir) throws Exception{
        DefaultExecutor executor = new DefaultExecutor();
        if(timeout > 0){
            ExecuteWatchdog watchdog = new ExecuteWatchdog(timeout);
            executor.setWatchdog(watchdog);
        }

        StringLogOutputStream stdOut = new StringLogOutputStream();
        StringLogOutputStream stdErr = new StringLogOutputStream();
        PumpStreamHandler outputHandler = new PumpStreamHandler(stdOut, stdErr);
        executor.setStreamHandler(outputHandler);
        DefaultExecuteResultHandler resultHandler = new DefaultExecuteResultHandler();

        CommandLine commandLine = new CommandLine(commandAndArgs.get(0));
        for (int i = 1; i < commandAndArgs.size(); i++) {
            commandLine.addArgument(commandAndArgs.get(i));
        }

        if (workingDir != null) {
            executor.setWorkingDirectory(workingDir);
        }

        // kill this process if it is still running when the server shuts down
        ShutdownHookProcessDestroyer shutdownHook = new ShutdownHookProcessDestroyer();
        executor.setProcessDestroyer(shutdownHook);
        executor.execute(commandLine, resultHandler);

        resultHandler.waitFor();
        
        CommandResults results = new CommandResults(stdOut.contents(), stdErr.contents(), resultHandler.getExitValue());
        
        return results;
    }

}
