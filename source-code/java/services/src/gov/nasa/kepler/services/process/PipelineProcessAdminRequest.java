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

import gov.nasa.kepler.services.messaging.PipelineMessage;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.tanukisoftware.wrapper.WrapperManager;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class PipelineProcessAdminRequest extends PipelineMessage {
    private static final Log log = LogFactory.getLog(PipelineProcessAdminRequest.class);

    private static final long serialVersionUID = 6218669106433704303L;

    public enum BasicRequestType {
        PAUSE, RESUME, RESTART, SHUTDOWN
    }

    protected BasicRequestType requestType;
    protected boolean abortCurrentJobs = false;

    /** If true, run in a background thread and return a response immediately */
    protected boolean asynchronous = false;
    
    public PipelineProcessAdminRequest() {
    }

    public PipelineProcessAdminRequest(BasicRequestType requestType) {
        this.requestType = requestType;
    }

    public PipelineProcessAdminRequest(BasicRequestType requestType, boolean abortCurrentJobs) {
        this.requestType = requestType;
        this.abortCurrentJobs = abortCurrentJobs;
    }

    public PipelineProcessAdminResponse processRequest() {
        switch (requestType) {

            /*
             * Stop accepting new jobs (worker tasks, client connections,
             * notification messages, etc.)
             * 
             * If abortCurrentJobs is true, kill running jobs, otherwise let
             * them finish but don't accept any new jobs.
             */
            case PAUSE:
                log.info("default implementation of pause(): doing nothing");
                break;

            /* Ask the {@link WrapperManager} to restart the JVM */
            case RESTART:
                log.info("default implementation of restart(): calling WrapperManager.restart(), hang on!");
                WrapperManager.restartAndReturn();
                break;
                
            /* Resume accepting new jobs */
            case RESUME:
                log.info("default implementation of resume(): doing nothing");
                break;

            /* Shutdown the JVM. Use stopAndReturn() so that shutdown hooks have
             * a chance to run. */
            case SHUTDOWN:
                log.info("default implementation of restart(): calling WrapperManager.stopAndReturn(), hang on!");
                WrapperManager.stopAndReturn(0);
                break;

            default:
                throw new IllegalArgumentException("unexpected request type = " + requestType);
        }
        
        return new PipelineProcessAdminResponse(true);
    }

    public boolean isAbortCurrentJobs() {
        return abortCurrentJobs;
    }

    public BasicRequestType getRequestType() {
        return requestType;
    }

    @Override
    public String toString() {
        return "AdminReq:" + requestType;
    }

    public boolean isAsynchronous() {
        return asynchronous;
    }

    public void setAsynchronous(boolean asynchronous) {
        this.asynchronous = asynchronous;
    }
}
