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

import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingListener;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class TestCopierEventListener extends MessagingListener {
    private static final Log log = LogFactory.getLog(TestCopierEventListener.class);

    private TestCopierEvent event;

    public TestCopierEventListener() {
        super(MessagingDestinations.TEST_COPIER_EVENTS_DESTINATION, false);
    }

    @Override
    protected void processMessage(MessageContext messageContext) {

        event = (TestCopierEvent) messageContext.getPipelineMessage();

        log.info("got a mesg: " + event);

        String sourcePath = event.getSourcePath();
        File sourceDir = new File(sourcePath);

        TestCopierEvent response = new TestCopierEvent(sourcePath);

        if (sourceDir.exists()) {
            File nmFile = null;
            for (File file : sourceDir.listFiles()) {
                String filename = file.getName();
                if (filename.contains("nm.xml")
                    || filename.contains("tara.xml")) {
                    nmFile = file;
                }
            }

            if (nmFile == null) {
                response.setErrorMessage("The sourceDir must contain an nm.xml file or a tara.xml file.\n  sourceDir: "
                    + sourceDir);
            }
        } else {
            response.setErrorMessage("The sourceDir must exist.\n  sourceDir: "
                + sourceDir);
        }

        MessagingService messagingService = MessagingServiceFactory.getNonTransactedInstance();
        messagingService.initializeReceiver(MessagingDestinations.TEST_COPIER_EVENTS_DESTINATION);
        messagingService.respond(messageContext, response);

        try {
            IncomingFileCopier copier = new IncomingFileCopier();
            copier.copyFilesToIncomingDir(sourcePath);
        } catch (Exception e) {
            throw new PipelineException(
                "Unable to copy files to incoming dir.", e);
        }
    }

    public TestCopierEvent getEvent() {
        return event;
    }

    public static void main(String[] args) throws InterruptedException {
        TestCopierEventListener listener = new TestCopierEventListener();
        listener.start();
        listener.waitForReadyToProcess();
    }

}
