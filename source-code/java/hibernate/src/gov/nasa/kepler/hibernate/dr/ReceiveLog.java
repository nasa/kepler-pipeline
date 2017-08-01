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

package gov.nasa.kepler.hibernate.dr;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * Master log for files ingested by data receipt
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@Entity
@Table(name = "DR_RECEIVE_LOG")
public class ReceiveLog implements Serializable {

    private static final long serialVersionUID = -3727438918588153354L;

    public enum State {
        PROCESSING, SUCCESS, FAILURE
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_RECEIVE_LOG_SEQ")
    // required by Hibernate
    private long id;

    private Date socIngestTime;
    private String messageType;
    private String messageFileName;
    private String firstTimestamp;
    private String lastTimestamp;

    private State state;

    private Date startProcessingTime;
    private Date endProcessingTime;
    
    private int totalFileCount;

    /**
     * 
     */
    ReceiveLog() {
    }

    /**
     * 
     * @param socIngestTime
     * @param messageType
     * @param messageFileName
     */
    public ReceiveLog(Date socIngestTime, String messageType,
        String messageFileName) {
        this.socIngestTime = socIngestTime;
        this.messageType = messageType;
        this.messageFileName = messageFileName;
    }

    /**
     * @return the firstTimestamp
     */
    public String getFirstTimestamp() {
        return firstTimestamp;
    }

    /**
     * @param firstTimestamp the firstTimestamp to set
     */
    public void setFirstTimestamp(String firstTimestamp) {
        this.firstTimestamp = firstTimestamp;
    }

    /**
     * @return the lastTimestamp
     */
    public String getLastTimestamp() {
        return lastTimestamp;
    }

    /**
     * @param lastTimestamp the lastTimestamp to set
     */
    public void setLastTimestamp(String lastTimestamp) {
        this.lastTimestamp = lastTimestamp;
    }

    /**
     * @return the messageFileName
     */
    public String getMessageFileName() {
        return messageFileName;
    }

    /**
     * @param messageFileName the messageFileName to set
     */
    public void setMessageFileName(String messageFileName) {
        this.messageFileName = messageFileName;
    }

    /**
     * @return the messageType
     */
    public String getMessageType() {
        return messageType;
    }

    /**
     * @param messageType the messageType to set
     */
    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    /**
     * @return the socIngestTime
     */
    public Date getSocIngestTime() {
        return socIngestTime;
    }

    /**
     * @param socIngestTime the socIngestTime to set
     */
    public void setSocIngestTime(Date socIngestTime) {
        this.socIngestTime = socIngestTime;
    }

    /**
     * @return the id
     */
    public long getId() {
        return id;
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public Date getEndProcessingTime() {
        return endProcessingTime;
    }

    public void setEndProcessingTime(Date endProcessingTime) {
        this.endProcessingTime = endProcessingTime;
    }

    public Date getStartProcessingTime() {
        return startProcessingTime;
    }

    public void setStartProcessingTime(Date startProcessingTime) {
        this.startProcessingTime = startProcessingTime;
    }

    public int getTotalFileCount() {
        return totalFileCount;
    }

    public void setTotalFileCount(int totalFileCount) {
        this.totalFileCount = totalFileCount;
    }

    @Override
    public String toString() {
        return "ReceiveLog [socIngestTime=" + socIngestTime + ", messageType="
            + messageType + ", messageFileName=" + messageFileName
            + ", firstTimestamp=" + firstTimestamp + ", lastTimestamp="
            + lastTimestamp + "]";
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result
            + ((firstTimestamp == null) ? 0 : firstTimestamp.hashCode());
        result = PRIME * result
            + ((lastTimestamp == null) ? 0 : lastTimestamp.hashCode());
        result = PRIME * result
            + ((messageFileName == null) ? 0 : messageFileName.hashCode());
        result = PRIME * result
            + ((messageType == null) ? 0 : messageType.hashCode());
        result = PRIME * result
            + ((socIngestTime == null) ? 0 : socIngestTime.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final ReceiveLog other = (ReceiveLog) obj;
        if (firstTimestamp == null) {
            if (other.firstTimestamp != null)
                return false;
        } else if (!firstTimestamp.equals(other.firstTimestamp))
            return false;
        if (lastTimestamp == null) {
            if (other.lastTimestamp != null)
                return false;
        } else if (!lastTimestamp.equals(other.lastTimestamp))
            return false;
        if (messageFileName == null) {
            if (other.messageFileName != null)
                return false;
        } else if (!messageFileName.equals(other.messageFileName))
            return false;
        if (messageType == null) {
            if (other.messageType != null)
                return false;
        } else if (!messageType.equals(other.messageType))
            return false;
        if (socIngestTime == null) {
            if (other.socIngestTime != null)
                return false;
        } else if (!socIngestTime.equals(other.socIngestTime))
            return false;
        return true;
    }

}
