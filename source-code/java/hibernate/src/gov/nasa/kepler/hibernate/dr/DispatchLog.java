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

import gov.nasa.kepler.hibernate.dr.ReceiveLog.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.IndexColumn;

/**
 * This class maps an invocation of a dispatcher to the notification message
 * that called it.
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "DR_DISPATCH_LOG")
public class DispatchLog {

    public static final String LONG_CADENCE_TARGET_PMRF = "_lcm.fits";
    public static final String SHORT_CADENCE_TARGET_PMRF = "_scm.fits";
    public static final String BACKGROUND_PMRF = "_bgm.fits";
    public static final String LONG_CADENCE_COLLATERAL_PMRF = "_lcc.fits";
    public static final String SHORT_CADENCE_COLLATERAL_PMRF = "_scc.fits";

    public static enum DispatcherType {
        LONG_CADENCE_PIXEL,
        SHORT_CADENCE_PIXEL,
        GAP_REPORT,
        CONFIG_MAP,
        REF_PIXEL,
        LONG_CADENCE_TARGET_PMRF,
        SHORT_CADENCE_TARGET_PMRF,
        BACKGROUND_PMRF,
        LONG_CADENCE_COLLATERAL_PMRF,
        SHORT_CADENCE_COLLATERAL_PMRF,
        HISTOGRAM,
        ANCILLARY,
        SPACECRAFT_EPHEMERIS,
        PLANETARY_EPHEMERIS,
        LEAP_SECONDS,
        SCLK,
        CRCT,
        FFI,
        HISTORY,
        TARGET_LIST,
        TARGET_LIST_SET,
        MASK_TABLE,
        CLOCK_STATE_MASK,
        DATA_ANOMALY,
        RCLC_PIXEL,
        UKIRT_IMAGE,
        THRUSTER_DATA;

        private String name;

        private DispatcherType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_DISPATCH_LOG_SEQ")
    @Column(nullable = false)
    private long id;

    @ManyToOne
    private ReceiveLog receiveLog;

    private DispatcherType dispatcherType;

    private State state;

    private Date startProcessingTime;
    private Date endProcessingTime;

    private int totalFileCount;

    @OneToMany(fetch = FetchType.LAZY)
    @JoinTable(name = "DR_DISPATCH_LOG_PI")
    @IndexColumn(name = "IDX")
    private List<PipelineInstance> pipelineInstances = new ArrayList<PipelineInstance>();

    public void start() {
        startProcessingTime = new Date();
        state = State.PROCESSING;
    }

    public void end() {
        endProcessingTime = new Date();
        state = State.SUCCESS;
    }

    DispatchLog() {
    }

    public DispatchLog(ReceiveLog receiveLog, DispatcherType dispatcherType) {
        this.receiveLog = receiveLog;
        this.dispatcherType = dispatcherType;
    }

    public DispatcherType getDispatcherType() {
        return dispatcherType;
    }

    public void setDispatcherType(DispatcherType dispatcherType) {
        this.dispatcherType = dispatcherType;
    }

    public ReceiveLog getReceiveLog() {
        return receiveLog;
    }

    public void setReceiveLog(ReceiveLog receiveLog) {
        this.receiveLog = receiveLog;
    }

    public List<PipelineInstance> getPipelineInstances() {
        return pipelineInstances;
    }

    public void setPipelineInstances(List<PipelineInstance> pipelineInstances) {
        this.pipelineInstances = pipelineInstances;
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

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public int getTotalFileCount() {
        return totalFileCount;
    }

    public void setTotalFileCount(int totalFileCount) {
        this.totalFileCount = totalFileCount;
    }

    @Override
    public String toString() {
        return "DispatchLog [receiveLog=" + receiveLog + ", dispatcherType="
            + dispatcherType + ", state=" + state + ", startProcessingTime="
            + startProcessingTime + ", endProcessingTime=" + endProcessingTime
            + ", totalFileCount=" + totalFileCount + ", pipelineInstances="
            + pipelineInstances + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (dispatcherType == null ? 0 : dispatcherType.hashCode());
        result = prime * result
            + (endProcessingTime == null ? 0 : endProcessingTime.hashCode());
        result = prime * result
            + (pipelineInstances == null ? 0 : pipelineInstances.hashCode());
        result = prime * result
            + (receiveLog == null ? 0 : receiveLog.hashCode());
        result = prime
            * result
            + (startProcessingTime == null ? 0 : startProcessingTime.hashCode());
        result = prime * result + (state == null ? 0 : state.hashCode());
        result = prime * result + totalFileCount;
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        DispatchLog other = (DispatchLog) obj;
        if (dispatcherType != other.dispatcherType) {
            return false;
        }
        if (endProcessingTime == null) {
            if (other.endProcessingTime != null) {
                return false;
            }
        } else if (!endProcessingTime.equals(other.endProcessingTime)) {
            return false;
        }
        if (pipelineInstances == null) {
            if (other.pipelineInstances != null) {
                return false;
            }
        } else if (!pipelineInstances.equals(other.pipelineInstances)) {
            return false;
        }
        if (receiveLog == null) {
            if (other.receiveLog != null) {
                return false;
            }
        } else if (!receiveLog.equals(other.receiveLog)) {
            return false;
        }
        if (startProcessingTime == null) {
            if (other.startProcessingTime != null) {
                return false;
            }
        } else if (!startProcessingTime.equals(other.startProcessingTime)) {
            return false;
        }
        if (state != other.state) {
            return false;
        }
        if (totalFileCount != other.totalFileCount) {
            return false;
        }
        return true;
    }

}
