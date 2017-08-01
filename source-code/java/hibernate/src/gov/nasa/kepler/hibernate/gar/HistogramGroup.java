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

package gov.nasa.kepler.hibernate.gar;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

/**
 * A collection of {@link Histogram}s across a range of baseline intervals. This
 * record can represent histograms for a single module/output as well as the
 * entire CCD (see {@link #CCD_MOD_OUT_ALL}).
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "GAR_HISTOGRAM_GROUP")
public class HistogramGroup {

    /**
     * Used in the {@code ccdModule} and {@code ccdOutput} fields to indicate
     * that this histogram applies to the entire CCD.
     */
    public static final int CCD_MOD_OUT_ALL = -1;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "GAR_HISTOGRAM_GROUP_SEQ")
    private long id;

    /**
     * The {@link PipelineInstance} that produced these histograms. This can be
     * used by hac to find histograms that were written by hgn.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private PipelineInstance pipelineInstance;

    /**
     * The {@link PipelineTask} that produced these histograms. This is used for
     * data accountability.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    /**
     * The module used to build this histogram, or {@link #CCD_MOD_OUT_ALL} if
     * this histogram applies to the entire CCD.
     */
    private int ccdModule;

    /**
     * The output used to build this histogram, or {@link #CCD_MOD_OUT_ALL} if
     * this histogram applies to the entire CCD.
     */
    private int ccdOutput;

    /**
     * The best baseline interval.
     */
    private int bestBaselineInterval;

    /**
     * The best storage rate.
     */
    private float bestStorageRate;

    /**
     * A collection of {@link Histogram}s across a range of baseline intervals.
     * The semantics of a list isn't strictly needed, but adding IndexColumn
     * fixed the {@link #equals(Object)} method.
     */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    private List<Histogram> histograms = new ArrayList<Histogram>();

    /**
     * For use by mock objects and Hibernate only.
     */
    HistogramGroup() {
    }

    /**
     * Creates a {@link HistogramGroup} that applies across the entire focal
     * plane.
     * 
     * @param pipelineInstance the pipeline instance that produced these
     * histograms.
     * @param pipelineTask the pipeline task that produced these histograms.
     */
    public HistogramGroup(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this(pipelineInstance, pipelineTask, CCD_MOD_OUT_ALL, CCD_MOD_OUT_ALL);
    }

    /**
     * Creates a {@link HistogramGroup} that applies to the given module/output.
     * 
     * @param pipelineInstance the pipeline instance that produced these
     * histograms.
     * @param pipelineTask the pipeline task that produced these histograms.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     */
    public HistogramGroup(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask, int ccdModule, int ccdOutput) {
        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    public PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public int getBestBaselineInterval() {
        return bestBaselineInterval;
    }

    public void setBestBaselineInterval(int bestBaselineInterval) {
        this.bestBaselineInterval = bestBaselineInterval;
    }

    public float getBestStorageRate() {
        return bestStorageRate;
    }

    public void setBestStorageRate(float bestStorageRate) {
        this.bestStorageRate = bestStorageRate;
    }

    public List<Histogram> getHistograms() {
        return histograms;
    }

    public void setHistograms(List<Histogram> histograms) {
        this.histograms = histograms;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + bestBaselineInterval;
        result = prime * result + Float.floatToIntBits(bestStorageRate);
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result
            + ((histograms == null) ? 0 : histograms.hashCode());
        result = prime * result
            + ((pipelineInstance == null) ? 0 : pipelineInstance.hashCode());
        result = prime * result
            + ((pipelineTask == null) ? 0 : pipelineTask.hashCode());
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
        if (!(obj instanceof HistogramGroup)) {
            return false;
        }
        HistogramGroup other = (HistogramGroup) obj;
        if (bestBaselineInterval != other.bestBaselineInterval) {
            return false;
        }
        if (Float.floatToIntBits(bestStorageRate) != Float.floatToIntBits(other.bestStorageRate)) {
            return false;
        }
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (histograms == null) {
            if (other.histograms != null) {
                return false;
            }
        } else if (!histograms.equals(other.histograms)) {
            return false;
        }
        if (pipelineInstance == null) {
            if (other.pipelineInstance != null) {
                return false;
            }
        } else if (!pipelineInstance.equals(other.pipelineInstance)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("ccdModule", ccdModule)
            .append("ccdOutput", ccdOutput)
            .append("bestBaselineInterval", bestBaselineInterval)
            .append("bestStorageRate", bestStorageRate)
            .append("histograms size", histograms.size())
            .append("pipelineTaskId", pipelineTask.getId())
            .append("pipelineInstanceId", pipelineInstance.getId())
            .toString();
    }
}
