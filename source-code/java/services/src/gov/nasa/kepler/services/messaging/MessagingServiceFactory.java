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

package gov.nasa.kepler.services.messaging;

import gov.nasa.spiffy.common.lang.BooleanThreadLocal;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 * 
 */
public class MessagingServiceFactory {

    private static final Log log = LogFactory.getLog(MessagingServiceFactory.class);
    
    private static MessagingService localService = null;
    private static MessagingService xaService = null;
    private static MessagingService nonTransactedService = null;
    
    private static final BooleanThreadLocal usingLocalService = 
        new BooleanThreadLocal(Boolean.TRUE);
    private static final BooleanThreadLocal usingXaService = 
        new BooleanThreadLocal(Boolean.TRUE);
    
    /**
     * When true getInstance() will return the XA version of this service
     * else it will return the local version of this service.
     */
    private static final BooleanThreadLocal isXa =
        new BooleanThreadLocal(Boolean.FALSE);

    private MessagingServiceFactory() {

    }

    public static synchronized void setUseXa(boolean useXaForThisThread) {
        isXa.set(useXaForThisThread);
    }
    
    /**
     * Same as getInstance(TransactionServiceFactory.isXa())
     * 
     * @return
     * @throws PipelineException
     */
    public static MessagingService getInstance() {
        if (log.isTraceEnabled()) {
            log.trace("Returning " + ((isXa.get()) ? "xa" : "local") + " MessagingService");
        }

        return getInstance(isXa.get());
    }

    /**
     * Used by unit tests to reset the state between tests
     *
     */
    public static synchronized void reset(){
        localService = null;
        xaService = null;
        nonTransactedService = null;
    }
    
    /**
     * 
     * @param xa When true get the XA version of this service, else get the
     * local version.
     * @return
     * @throws PipelineException
     */
    public static synchronized MessagingService getInstance(boolean xa) {

        if (xa) {
            if (!usingXaService.get()) {
                throw new PipelineException("The MessagingService was not " + "enlisted with XA transactions.");
            }

            if (xaService != null) {
                return xaService;
            }

            XaActiveMqMessagingServiceImpl svc = new XaActiveMqMessagingServiceImpl(true);
            svc.initialize();
            xaService = svc;
            return xaService;
        } else {
            if (localService != null) {
                return localService;
            }

            JMSMessagingServiceImpl svc = new ActiveMqMessagingServiceImpl(true);
            svc.initialize();
            localService = svc;
            return localService;
        }

    }

    /**
     * Retrieve a non-transacted MessagingService.
     * All sent/received messages are implicitly committed.
     * 
     * @return
     * @throws PipelineException
     */
    public static synchronized MessagingService getNonTransactedInstance() throws PipelineException{
        
        if (nonTransactedService != null) {
            return nonTransactedService;
        }

        JMSMessagingServiceImpl svc = new ActiveMqMessagingServiceImpl(false);
        svc.initialize();
        nonTransactedService = svc;
        return nonTransactedService;
    }
    
    /**
     * Used for testing purposes only. Sets the specified instance.
     * 
     * @param instance
     */
    public static synchronized void setInstance(MessagingService instance, boolean xa) {
        if (xa) {
            xaService = instance;
        } else {
            localService = instance;
        }
    }

    /**
     * Used for testing purposes only. Sets the specified instance.
     * 
     * @param instance
     */
    public static synchronized void setNonTransactedInstance(MessagingService instance) {
        nonTransactedService = instance;
    }

    /**
     * Marks the service as not being needed by the current transaction.
     * 
     * @param xa If true then mark the xa version as not being used, else mark
     * the local version.
     */
    public static void markNotUsingService(boolean xa) {
        if (xa) {
            usingXaService.set(Boolean.FALSE);
        } else {
            usingLocalService.set(Boolean.FALSE);
        }
    }

    public static void clearNotUsingService(boolean xa) {
        if (xa) {
            usingXaService.set(Boolean.TRUE);
        } else {
            usingLocalService.set(Boolean.TRUE);
        }
    }
}
