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

package gov.nasa.kepler.services.alert;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Date;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Alert service implementation.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class AlertServiceImpl implements AlertService {
    private static final Log log = LogFactory.getLog(AlertServiceImpl.class);

    public static final String BROADCAST_ENABLED_PROP = "pi.alerts.jmsBroadcast.enabled";
    public static final boolean BROADCAST_ENABLED_DEFAULT = false;

    public boolean broadcastEnabled = false;
    
    public AlertServiceImpl() {
        Configuration configService = ConfigurationServiceFactory.getInstance();
        try {
            broadcastEnabled = configService.getBoolean(BROADCAST_ENABLED_PROP, 
                BROADCAST_ENABLED_DEFAULT);
        } catch (Exception ignore) {
        }
    }

    @Override
    public void generateAlert(String sourceComponent, String message) {
        generateAlert(sourceComponent, -1, message);
    }

    @Override
    public void generateAlert(String sourceComponent, Severity severity,
        String message) {
        generateAlert(sourceComponent, -1, severity, message);
    }

    /**
     * 
     * @see gov.nasa.kepler.services.alert.AlertService#generateAlert(java.lang.String,
     * long, java.lang.String)
     */
    @Override
    public void generateAlert(String sourceComponent, long sourceTaskId,
        String message) {
        generateAlert(sourceComponent, sourceTaskId, Severity.ERROR, message);
    }

    @Override
    public void generateAlert(String sourceComponent, long sourceTaskId,
        Severity severity, String message) {
        log.debug("ALERT:[" + sourceComponent + "]: " + message);

        Date timestamp = new Date();
        String processName = null;
        String processHost = null;
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
                log.warn("failed to get hostname", e);
            }
        }

        Alert alertData = new Alert(timestamp, sourceComponent, sourceTaskId,
            processName, processHost, processId, severity.toString(), message);

        // store alert in db
        try {
            AlertLogCrud alertCrud = new AlertLogCrud(
                DatabaseServiceFactory.getInstance());
            alertCrud.create(new AlertLog(alertData));
        } catch (PipelineException e) {
            log.error("Failed to store Alert in database", e);
        }

        if(broadcastEnabled || severity == Severity.INFRASTRUCTURE){
            // broadcast alert on MessagingService
            try {
                MessagingServiceFactory.getNonTransactedInstance().send(
                    MessagingDestinations.PIPELINE_ALERTS_DESTINATION,
                    new AlertMessage(alertData));
            } catch (PipelineException e) {
                log.error("Failed to broadcast Alert", e);
            }
        }
    }
}
