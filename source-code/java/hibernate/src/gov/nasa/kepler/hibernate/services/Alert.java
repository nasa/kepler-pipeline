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

package gov.nasa.kepler.hibernate.services;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.lf5.LogLevel;

/**
 * Contains alert data. Shared by {@link Alert} (used to store alert data in the
 * database) and {@link AlertMessage} (used to broadcast alert data on the
 * {@link MessagingService})
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@Embeddable
public class Alert implements Serializable {
    private static final Log log = LogFactory.getLog(Alert.class);

    private static final long serialVersionUID = -6630368734502687993L;

    private static final int MAX_MESSAGE_LENGTH = 4000;
    
    private Date timestamp;
    private String sourceComponent = null;
    private long sourceTaskId = -1;
    private String processName = null;
    private String processHost = null;
    private int processId = -1;
    private String severity = LogLevel.ERROR.getLabel();
    @Column(nullable=true, length=MAX_MESSAGE_LENGTH)
    private String message = null;

    public Alert() {
    }

    public Alert(Date timestamp, String sourceComponent, long sourceTaskId,
        String processName, String processHost, int processId, String message) {
        this.timestamp = timestamp;
        this.sourceComponent = sourceComponent;
        this.sourceTaskId = sourceTaskId;
        this.processName = processName;
        this.processHost = processHost;
        this.processId = processId;
        this.message = message;
        
        validateMessageLength();
    }

    public Alert(Date timestamp, String sourceComponent, long sourceTaskId,
        String processName, String processHost, int processId, String severity,
        String message) {
        this.timestamp = timestamp;
        this.sourceComponent = sourceComponent;
        this.sourceTaskId = sourceTaskId;
        this.processName = processName;
        this.processHost = processHost;
        this.processId = processId;
        this.severity = severity;
        this.message = message;
        
        validateMessageLength();
    }

    private void validateMessageLength() {
        if(message == null){
            message = "<Missing>";
            log.warn("Alert message is NULL");
        }else if(message.length() > MAX_MESSAGE_LENGTH){
            message = message.substring(0, MAX_MESSAGE_LENGTH - 4) + "...";
            log.warn("Alert message length (" + message.length() + ") is too long, max = " + MAX_MESSAGE_LENGTH + ", truncated");
        }
    }

    public int getProcessId() {
        return processId;
    }

    public void setProcessId(int processId) {
        this.processId = processId;
    }

    public String getProcessName() {
        return processName;
    }

    public void setProcessName(String processName) {
        this.processName = processName;
    }

    public String getSourceComponent() {
        return sourceComponent;
    }

    public void setSourceComponent(String sourceComponent) {
        this.sourceComponent = sourceComponent;
    }

    public long getSourceTaskId() {
        return sourceTaskId;
    }

    public void setSourceTaskId(long sourceTaskId) {
        this.sourceTaskId = sourceTaskId;
    }

    public Date getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }

    public String getProcessHost() {
        return processHost;
    }

    public void setProcessHost(String processHost) {
        this.processHost = processHost;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getSeverity() {
        return severity;
    }

    public void setSeverity(LogLevel severity) {
        this.severity = severity.getLabel();
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }
}
