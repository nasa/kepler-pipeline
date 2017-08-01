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

package gov.nasa.kepler.pi.module;

import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.CountDownLatch;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Serves sub-tasks to clients using {@link SubClassAllocator}.
 * 
 * Clients should use {@link SubTaskClient} to communicate with an 
 * instance of this class.
 * 
 * @author tklaus
 *
 */
public class SubTaskServer implements Runnable {
    private static final Log log = LogFactory.getLog(SubTaskServer.class);

    static final int SERVER_PORT = 4445;    
    static final int BACKLOG_SIZE = 4096;
    
    private String host;
    private ServerSocket serverSocket;
    private SubTaskAllocator subTaskAllocator = null;
    private CountDownLatch serverThreadReady = new CountDownLatch(1);
    private boolean shuttingDown = false;
    
    public SubTaskServer(String host) {
        this.host = host;
    }

    public SubTaskServer(String host, InputsHandler inputsHandler) throws Exception {
        this.host = host;
        this.subTaskAllocator = new SubTaskAllocator(inputsHandler);
        
        if(this.subTaskAllocator.isEmpty()){
            throw new PipelineException("InputsHandler contains no elements!");
        }
        
        log.info("Starting SubTaskServer for inputs: " + inputsHandler);
        
        Thread t = new Thread(this, "SubTaskServer-listener");
        t.setDaemon(true);
        t.start();

        serverThreadReady.await();

        log.info("SubTaskServer thread ready");
    }

    public void shutdownServer() throws Exception{
        shuttingDown = true;
        if(serverSocket != null){
            serverSocket.close();
        }
    }
    

    // request commands
    public enum RequestType{
        NOOP(-1),
        GET_NEXT(1),
        REPORT_DONE(2);
        
        private final int v;

        private RequestType(int value) {
            this.v = value;
        }
        public int value() {
            return v;
        }
    }
    
    // request commands
    public enum ResponseType{
        OK(0),
        TRY_AGAIN(-1),
        NO_MORE(-2);
        
        private final int v;

        private ResponseType(int value) {
            this.v = value;
        }
        public int value() {
            return v;
        }
        public static ResponseType fromValue(int v){
            switch(v){
                case 0: return OK;
                case -1: return TRY_AGAIN;
                case -2: return NO_MORE;
                default: throw new IllegalArgumentException("invalid value: " + v);
            }
        }
    }

    public static final class Request implements Serializable{
        private static final long serialVersionUID = -3336544526225919889L;
        
        public static final int NONE = -1;
        
        public RequestType type;
        public int groupIndex;
        public int subTaskIndex;

        public Request(RequestType type, int groupIndex, int subTaskIndex) {
            this.type = type;
            this.groupIndex = groupIndex;
            this.subTaskIndex = subTaskIndex;
        }

        @Override
        public String toString() {
            StringBuffer sb = new StringBuffer();
            sb.append("Request [type=");
            sb.append(type);
            sb.append(", groupIndex=");
            sb.append(groupIndex);
            sb.append(", subTaskIndex=");
            sb.append(subTaskIndex);
            sb.append("]");
            
            return  sb.toString();
        }
    }

    public static final class Response implements Serializable{
        private static final long serialVersionUID = 4517789890439531336L;

        public ResponseType status;
        public int groupIndex = -1;
        public int subTaskIndex = -1;
        
        public Response(ResponseType status) {
            this.status = status;
        }

        public Response(ResponseType status, int groupIndex, int subTaskIndex) {
            this.status = status;
            this.groupIndex = groupIndex;
            this.subTaskIndex = subTaskIndex;
        }

        public boolean successful(){
            return status == ResponseType.OK;
        }
        
        @Override
        public String toString() {
            StringBuffer sb = new StringBuffer();
            sb.append("Response [status=");
            sb.append(status);
            sb.append(", groupIndex=");
            sb.append(groupIndex);
            sb.append(", subTaskIndex=");
            sb.append(subTaskIndex);
            sb.append("]");
            
            return  sb.toString();
        }
    }

    @Override
    public void run(){
        listen();
    }

    private void listen(){

        log.info("Initializing SubTaskServer server thread");
        
        try {
            serverSocket = new ServerSocket(SERVER_PORT, BACKLOG_SIZE);        
        } catch (IOException e) {
            log.error("Cannot initialize, caught: " + e);
            return;
        }

        serverThreadReady.countDown();
        
        log.info("Listening for connections on: " + host + ":" + SERVER_PORT);
        
        while(true){
            try {
                Socket clientSocket = serverSocket.accept();
                
                log.debug("Accepted new connection: " + clientSocket.toString());

                ObjectOutputStream out = new ObjectOutputStream(clientSocket.getOutputStream());
                ObjectInputStream in = new ObjectInputStream(clientSocket.getInputStream());

                Request request = (Request) in.readObject();

                log.debug("listen[server,before]: request: " + request);
                
                Response response = null;

                RequestType type = request.type;
                
                if(type == RequestType.GET_NEXT){
                    SubTaskAllocation nextSubTask = subTaskAllocator.nextSubTask();
                    
                    log.debug("Allocated: " + nextSubTask);
                    
                    ResponseType status = nextSubTask.getStatus();
                    int groupIndex = nextSubTask.getGroupIndex();
                    int subTaskIndex = nextSubTask.getSubTaskIndex();
                    
                    response = new Response(status, groupIndex, subTaskIndex);
                }else if(type == RequestType.REPORT_DONE){
                    subTaskAllocator.markSubTaskComplete(request.groupIndex, request.subTaskIndex);
                    response = new Response(ResponseType.OK);
                }else if(type == RequestType.NOOP){
                    log.debug("Got a NO-OP");
                    response = new Response(ResponseType.OK);
                }else{
                    log.error("Unknown command: " + type);
                }

                log.debug("listen[server,after], response: " + response);

                out.writeObject(response);
                
                out.close();
                in.close();
                clientSocket.close();
            } catch (Exception e) {
                if(shuttingDown){
                    log.info("Got shutdown signal, exiting server thread");
                    return;
                }
                log.error("Caught e = "+ e, e);
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ignore) {
                }
            }
        }
    }
}
