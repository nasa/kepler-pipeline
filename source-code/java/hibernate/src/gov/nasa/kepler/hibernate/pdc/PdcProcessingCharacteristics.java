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

package gov.nasa.kepler.hibernate.pdc;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.CadenceData;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlTransient;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(name = "PDC_PROC_CHARACTERISTICS")
public class PdcProcessingCharacteristics implements CadenceData {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PDC_PROC_CHAR_SEQ")
    @Column(nullable = false)
    private long id;

    private long pipelineTaskId;

    @Column(nullable = false)
    private FluxType fluxType;

    @Column(nullable = false)
    private CadenceType cadenceType;

    private int startCadence;
    private int endCadence;

    private int keplerId;

    @Column(nullable = false)
    private String pdcMethod = "";

    private int numDiscontinuitiesDetected;

    private int numDiscontinuitiesRemoved;

    private boolean harmonicsFitted;

    private boolean harmonicsRestored;

    private float targetVariability;

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "PDC_PROC_CHAR_BANDS")
    @IndexColumn(name = "IDX")
    private List<PdcBand> bands = new ArrayList<PdcBand>();

    public PdcProcessingCharacteristics() {
    }

    private PdcProcessingCharacteristics(Builder builder) {

        pipelineTaskId = builder.pipelineTaskId;
        fluxType = builder.fluxType;
        cadenceType = builder.cadenceType;
        startCadence = builder.startCadence;
        endCadence = builder.endCadence;
        keplerId = builder.keplerId;
        pdcMethod = builder.pdcMethod;
        numDiscontinuitiesDetected = builder.numDiscontinuitiesDetected;
        numDiscontinuitiesRemoved = builder.numDiscontinuitiesRemoved;
        harmonicsFitted = builder.harmonicsFitted;
        harmonicsRestored = builder.harmonicsRestored;
        targetVariability = builder.targetVariability;
        bands = builder.bands;
    }

    @Override
    public long getCreationTime() {
        return pipelineTaskId;
    }

    @Override
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getPipelineTaskId() {
        return pipelineTaskId;
    }

    public void setPipelineTaskId(long pipelineTaskId) {
        this.pipelineTaskId = pipelineTaskId;
    }

    public FluxType getFluxType() {
        return fluxType;
    }

    public void setFluxType(FluxType fluxType) {
        this.fluxType = fluxType;
    }

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType;
    }

    @Override
    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    @Override
    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public String getPdcMethod() {
        return pdcMethod;
    }

    public void setPdcMethod(String pdcMethod) {
        this.pdcMethod = pdcMethod;
    }

    public int getNumDiscontinuitiesDetected() {
        return numDiscontinuitiesDetected;
    }

    public void setNumDiscontinuitiesDetected(int numDiscontinuitiesDetected) {
        this.numDiscontinuitiesDetected = numDiscontinuitiesDetected;
    }

    public int getNumDiscontinuitiesRemoved() {
        return numDiscontinuitiesRemoved;
    }

    public void setNumDiscontinuitiesRemoved(int numDiscontinuitiesRemoved) {
        this.numDiscontinuitiesRemoved = numDiscontinuitiesRemoved;
    }

    public boolean isHarmonicsFitted() {
        return harmonicsFitted;
    }

    public void setHarmonicsFitted(boolean harmonicsFitted) {
        this.harmonicsFitted = harmonicsFitted;
    }

    public boolean isHarmonicsRestored() {
        return harmonicsRestored;
    }

    public void setHarmonicsRestored(boolean harmonicsRestored) {
        this.harmonicsRestored = harmonicsRestored;
    }

    public float getTargetVariability() {
        return targetVariability;
    }

    public void setTargetVariability(float targetVariability) {
        this.targetVariability = targetVariability;
    }

    public List<PdcBand> getBands() {
        return bands;
    }

    public void setBands(List<PdcBand> bands) {
        this.bands = bands;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (bands == null ? 0 : bands.hashCode());
        result = prime * result
            + (cadenceType == null ? 0 : cadenceType.hashCode());
        result = prime * result + endCadence;
        result = prime * result + (fluxType == null ? 0 : fluxType.hashCode());
        result = prime * result + (harmonicsFitted ? 1231 : 1237);
        result = prime * result + (harmonicsRestored ? 1231 : 1237);
        result = prime * result + keplerId;
        result = prime * result + numDiscontinuitiesDetected;
        result = prime * result + numDiscontinuitiesRemoved;
        result = prime * result
            + (pdcMethod == null ? 0 : pdcMethod.hashCode());
        result = prime * result
            + (int) (pipelineTaskId ^ pipelineTaskId >>> 32);
        result = prime * result + startCadence;
        result = prime * result + Float.floatToIntBits(targetVariability);
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
        if (!(obj instanceof PdcProcessingCharacteristics)) {
            return false;
        }
        PdcProcessingCharacteristics other = (PdcProcessingCharacteristics) obj;
        if (bands == null) {
            if (other.bands != null) {
                return false;
            }
        } else if (!bands.equals(other.bands)) {
            return false;
        }
        if (cadenceType != other.cadenceType) {
            return false;
        }
        if (endCadence != other.endCadence) {
            return false;
        }
        if (fluxType != other.fluxType) {
            return false;
        }
        if (harmonicsFitted != other.harmonicsFitted) {
            return false;
        }
        if (harmonicsRestored != other.harmonicsRestored) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (numDiscontinuitiesDetected != other.numDiscontinuitiesDetected) {
            return false;
        }
        if (numDiscontinuitiesRemoved != other.numDiscontinuitiesRemoved) {
            return false;
        }
        if (pdcMethod != other.pdcMethod) {
            return false;
        }
        if (pipelineTaskId != other.pipelineTaskId) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        if (Float.floatToIntBits(targetVariability) != Float.floatToIntBits(other.targetVariability)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", id)
            .append("pipelineTaskId", pipelineTaskId)
            .append("fluxType", fluxType)
            .append("cadenceType", cadenceType)
            .append("startCadence", startCadence)
            .append("endCadence", endCadence)
            .append("keplerId", keplerId)
            .append("pdcMethod", pdcMethod)
            .append("numDiscontinuitiesDetected", numDiscontinuitiesDetected)
            .append("numDiscontinuitiesRemoved", numDiscontinuitiesRemoved)
            .append("harmonicsFitted", harmonicsFitted)
            .append("harmonicsRestored", harmonicsRestored)
            .append("targetVariability", targetVariability)
            .append("bands", bands)
            .toString();
    }

    @XmlTransient
    public static class Builder {
        private long pipelineTaskId;
        private FluxType fluxType;
        private CadenceType cadenceType;
        private int startCadence;
        private int endCadence;
        private int keplerId;
        private String pdcMethod;
        private int numDiscontinuitiesDetected;
        private int numDiscontinuitiesRemoved;
        private boolean harmonicsFitted;
        private boolean harmonicsRestored;
        private float targetVariability;
        private List<PdcBand> bands = new ArrayList<PdcBand>();

        public Builder(long pipelineTaskId, FluxType fluxType,
            CadenceType cadenceType, int keplerId) {
            this.pipelineTaskId = pipelineTaskId;
            this.fluxType = fluxType;
            this.cadenceType = cadenceType;
            this.keplerId = keplerId;
        }

        public Builder startCadence(int startCadence) {
            this.startCadence = startCadence;
            return this;
        }

        public Builder endCadence(int endCadence) {
            this.endCadence = endCadence;
            return this;
        }

        public Builder pdcMethod(String pdcMethod) {
            this.pdcMethod = pdcMethod;
            return this;
        }

        public Builder numDiscontinuitiesDetected(int numDiscontinuitiesDetected) {
            this.numDiscontinuitiesDetected = numDiscontinuitiesDetected;
            return this;
        }

        public Builder numDiscontinuitiesRemoved(int numDiscontinuitiesRemoved) {
            this.numDiscontinuitiesRemoved = numDiscontinuitiesRemoved;
            return this;
        }

        public Builder harmonicsFitted(boolean harmonicsFitted) {
            this.harmonicsFitted = harmonicsFitted;
            return this;
        }

        public Builder harmonicsRestored(boolean harmonicsRestored) {
            this.harmonicsRestored = harmonicsRestored;
            return this;
        }

        public Builder targetVariability(float targetVariability) {
            this.targetVariability = targetVariability;
            return this;
        }

        public Builder bands(List<PdcBand> bands) {
            this.bands = bands;
            return this;
        }

        public PdcProcessingCharacteristics build() {
            return new PdcProcessingCharacteristics(this);
        }
    }
}
