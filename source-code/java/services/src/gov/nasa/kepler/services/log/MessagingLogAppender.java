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

package gov.nasa.kepler.services.log;

import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Date;

import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.spi.LoggingEvent;

/**
 * @author tklaus
 * 
 */
public class MessagingLogAppender extends AppenderSkeleton {

    public MessagingLogAppender() {
    }

    @Override
    protected void append(LoggingEvent event) {

        String processName = "<unknown>";
        String processHost = "<unknown>";
        int processId = -1;

        // get ProcessInfo, if available
        ProcessInfo processInfo = AbstractPipelineProcess.getProcessInfo();

        if (processInfo != null) {
            processName = processInfo.getName();
            processHost = processInfo.getHost();
            processId = processInfo.getPid();
        } else {
            try {
                processHost = InetAddress.getLocalHost().getHostName();
            } catch (UnknownHostException e) {
            }
        }

        LogMessage message = new LogMessage(processName, processHost, processId, event.getLoggerName(),
            event.getLevel().toString(), new Date(event.timeStamp), event.getMessage().toString());

        try {
            MessagingServiceFactory.getNonTransactedInstance().send(MessagingDestinations.PIPELINE_LOG_DESTINATION, message);
        } catch (PipelineException e) {
            System.err.println("failed to send log message via the MessagingService, e = " + e);
        }
    }

    @Override
    public boolean requiresLayout() {
        return false;
    }

    @Override
    public void close() {
        try {
            if (MessagingServiceFactory.getInstance().isInitialized()) {
                MessagingServiceFactory.getInstance().closeProducerForThread(
                    MessagingDestinations.PIPELINE_LOG_DESTINATION);
            }
        } catch (PipelineException e) {
            System.err.println("failed to close log MessageProducer in the MessagingService, e = " + e);
        }
    }
}
