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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.dr.dispatch.NmEventListener;
import gov.nasa.kepler.dr.dispatch.NotificationMessageEvent;
import gov.nasa.kepler.pi.worker.PipelineEventListener;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent.Type;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class IncomingFileCopierRequester {

    private static final int TIMEOUT = 60000;

    private static final Log log = LogFactory.getLog(IncomingFileCopierRequester.class);

    private NmEventListener nmEventListener;
    private PipelineEventListener pipelineEventListener;
    private MessagingService nonTransactedInstance;

    public IncomingFileCopierRequester() throws InterruptedException {
        nmEventListener = new NmEventListener();
        nmEventListener.start();
        nmEventListener.waitForReadyToProcess();

        pipelineEventListener = new PipelineEventListener();
        pipelineEventListener.start();
        pipelineEventListener.waitForReadyToProcess();

        nonTransactedInstance = MessagingServiceFactory.getNonTransactedInstance();
    }

    public void requestCopyAndWaitForNmCompletion(String srcDir) {
        log.info("Copying files from srcDir: " + srcDir);
        MessageContext responseContext = nonTransactedInstance.request(
            MessagingDestinations.TEST_COPIER_EVENTS_DESTINATION,
            new TestCopierEvent(srcDir), TIMEOUT);

        if (responseContext == null) {
            // Exceeded timeout.
            throw new PipelineException(
                "The responseContext is null, which means that the copy request timed out.  This can "
                    + "happen if the test-copier-listener process is not running.  Try running this from a linux "
                    + "shell and see if it shows any process running:\n  ps -ef |grep Listener");
        } else {
            TestCopierEvent response = (TestCopierEvent) responseContext.getPipelineMessage();
            if (response.getErrorMessage() != null) {
                throw new PipelineException(
                    "Unable to copy files.\n  errorMessage: "
                        + response.getErrorMessage());
            }

            waitForNmCompletion();
        }
    }

    private void waitForNmCompletion() {
        log.info("Waiting for nm completion...");

        NotificationMessageEvent event;
        try {
            nmEventListener.waitForNmComplete();
            event = nmEventListener.getEvent();
        } catch (Exception e) {
            throw new PipelineException("Unable to waitForNmComplete().  " + e);
        }

        gov.nasa.kepler.hibernate.dr.ReceiveLog.State state = event.getReceiveLog()
            .getState();
        log.info("nm state: " + state);
        if (state == gov.nasa.kepler.hibernate.dr.ReceiveLog.State.FAILURE) {
            throw new PipelineException("Received an nm failure.");
        }
    }

    public void waitForPipelineCompletion() {
        log.info("Waiting for pipeline completion...");

        Type eventType;
        try {
            pipelineEventListener.waitForPipelineComplete();
            eventType = pipelineEventListener.getEventType();
        } catch (Exception e) {
            throw new PipelineException("Unable to waitForPipelineComplete(). "
                + e);
        }

        log.info("pipelineInstance event: " + eventType);
        if (eventType == Type.FAILURE) {
            throw new PipelineException("Received a pipelineInstance failure.");
        }
    }

}
