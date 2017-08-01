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

package gov.nasa.kepler.services.process;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingListener;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 * 
 */
public class PipelineProcessAdminListener extends MessagingListener {
    private static final Log log = LogFactory.getLog(PipelineProcessAdminListener.class);

    @SuppressWarnings("unused")
    private ExecutorService executor = Executors.newSingleThreadExecutor();
    
    /**
     * @param listener
     * 
     */
    public PipelineProcessAdminListener(String processName, String processHost) {
        super(MessagingDestinations.PIPELINE_ADMIN_DESTINATION, createSelector(processName, processHost), false);
    }

    private static String createSelector(String processName, String processHost) {
        String processIdentifier = PipelineProcessAdminOperations.getProcessIdentifier(processName, processHost);
        return PipelineProcessAdminOperations.PROCESS_PROP_NAME + " = '" + processIdentifier + "' OR "
            + PipelineProcessAdminOperations.PROCESS_PROP_NAME + " = '*'";
    }

    /**
     * Handoff admin requests to the registered handlers.
     */
    @Override
    protected void processMessage(MessageContext messageContext) throws PipelineException {
        PipelineProcessAdminRequest request = (PipelineProcessAdminRequest) messageContext.getPipelineMessage();
        PipelineProcessAdminResponse response = null;

        log.info("got an admin request: " + request);

//        if(request.isAsynchronous()){
//            
//        }else{
//            response = request.processRequest();
//        }

        response = request.processRequest();

        log.info("sending admin response: " + response);

        MessagingServiceFactory.getNonTransactedInstance().respond(messageContext, response);
    }
}
