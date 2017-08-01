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

import gov.nasa.kepler.pi.module.SubTaskServer.Request;
import gov.nasa.kepler.pi.module.SubTaskServer.RequestType;
import gov.nasa.kepler.pi.module.SubTaskServer.Response;
import gov.nasa.kepler.pi.module.SubTaskServer.ResponseType;

import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Client class used to communicate with a {@link SubTaskServer}
 * instance in another JVM.
 *  
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class SubTaskClient {
    private static final Log log = LogFactory.getLog(SubTaskClient.class);

    private String host;
    
    public SubTaskClient(String host) {
        this.host = host;
    }

    public Response getNextSubTask(){
        return getNextSubTask(true);
    }
    
    /**
     * Client method to report that a sub-task has completed
     * 
     * @param subTaskIndex
     */
    public Response reportSubTaskComplete(int groupIndex, int subTaskIndex){
        Response response = request(RequestType.REPORT_DONE, groupIndex, subTaskIndex);
        return response;
    }

    /**
     * Internal method to retrieve a new sub-task to process
     * 
     * wait=false only used for unit tests
     * 
     * @return
     */
    Response getNextSubTask(boolean wait){
        Response response = request(RequestType.GET_NEXT);
        
        if(wait){
            while(response.status == ResponseType.TRY_AGAIN){
                try {
                    Thread.sleep(50000);
                } catch (InterruptedException e) {}
                
                response = request(RequestType.GET_NEXT);
            }
        }
                
        log.debug("getNextSubTask: Got a response: " + response);

        return response;
    }

    private Response request(RequestType command){
        return request(command, -1, -1);
    }
    
    private Response request(RequestType command, int groupIndex, int subTaskIndex){
        Socket socket = null;
        Request request = null;
        Response response = null;
        boolean success = false;
        
        while(!success){
            try {
                log.debug("Connecting to sub-task server at: " + host);
                socket = new Socket(host, SubTaskServer.SERVER_PORT);
                
                log.debug("Connected to sub-task server at: " + host + ", sending request");

                request = new Request(command, groupIndex, subTaskIndex);
                
                ObjectOutputStream out = new ObjectOutputStream(socket.getOutputStream());
                ObjectInputStream in = new ObjectInputStream(socket.getInputStream());

                out.writeObject(request);
                out.flush();

                log.debug("Sent request, waiting for response");

                response = (Response) in.readObject();
                
                log.debug("Got response: " + response);

                out.close();
                in.close();
                socket.close();
                
                log.debug("Got a response: " + response);
                
                success = true;
            } catch (Exception e) {
                String socketString = (socket == null ? "null" : socket.toString());
                String requestString = (request == null ? "null" : request.toString());
                String responseString = (response == null ? "null" : response.toString());
                
                long sleepTime = (long)(Math.random() * 100000.0);
                
                log.error("failed to connect to sub-task server." + 
                    "\n  server: " + host + 
                    "\n  port: " + SubTaskServer.SERVER_PORT + 
                    "\n  socket: " + socketString + 
                    "\n  request: " + requestString + 
                    "\n  response: " + responseString + 
                    "\n  sleepTime: " + sleepTime + 
                    "\n  caught exception: " + e);
                try {
                    Thread.sleep(sleepTime);
                } catch (InterruptedException e1) {
                }
                log.error("Retrying...");
            }
        }
        return response;
    }
}
