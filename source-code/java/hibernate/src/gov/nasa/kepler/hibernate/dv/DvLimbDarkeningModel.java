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

package gov.nasa.kepler.hibernate.dv;

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "DV_LIMB_DARKENING_MODELS")
@XmlType
public class DvLimbDarkeningModel extends DvAbstractTargetTableData {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_LIMB_DARKEN_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute(required = true)
    private int keplerId;

    @XmlAttribute(required = true)
    private String modelName;

    @XmlAttribute
    private float coefficient1;

    @XmlAttribute
    private float coefficient2;

    @XmlAttribute
    private float coefficient3;

    @XmlAttribute
    private float coefficient4;

    @XmlAttribute(required = true)
    private FluxType fluxType;

    @ManyToOne(fetch = FetchType.LAZY)
    @XmlAttribute(name = "pipelineTaskId", required = true)
    @XmlJavaTypeAdapter(PipelineTaskXmlAdapter.class)
    private PipelineTask pipelineTask;

    /**
     * Creates a {@link DvLimbDarkeningModel}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    public DvLimbDarkeningModel() {
    }

    /**
     * Creates a new {@link DvLimbDarkeningModel} from the given parameters.
     */
    public DvLimbDarkeningModel(Builder builder) {
        super(builder);
        keplerId = builder.keplerId;
        modelName = builder.modelName;
        coefficient1 = builder.coefficient1;
        coefficient2 = builder.coefficient2;
        coefficient3 = builder.coefficient3;
        coefficient4 = builder.coefficient4;
        fluxType = builder.fluxType;
        pipelineTask = builder.pipelineTask;
    }

    public long getId() {
        return id;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public String getModelName() {
        return modelName;
    }

    public float getCoefficient1() {
        return coefficient1;
    }

    public float getCoefficient2() {
        return coefficient2;
    }

    public float getCoefficient3() {
        return coefficient3;
    }

    public float getCoefficient4() {
        return coefficient4;
    }

    public FluxType getFluxType() {
        return fluxType;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Float.floatToIntBits(coefficient1);
        result = prime * result + Float.floatToIntBits(coefficient2);
        result = prime * result + Float.floatToIntBits(coefficient3);
        result = prime * result + Float.floatToIntBits(coefficient4);
        result = prime * result + (fluxType == null ? 0 : fluxType.hashCode());
        result = prime * result + keplerId;
        result = prime * result
            + (modelName == null ? 0 : modelName.hashCode());
        result = prime * result
            + (pipelineTask == null ? 0 : pipelineTask.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (!(obj instanceof DvLimbDarkeningModel)) {
            return false;
        }
        DvLimbDarkeningModel other = (DvLimbDarkeningModel) obj;
        if (Float.floatToIntBits(coefficient1) != Float.floatToIntBits(other.coefficient1)) {
            return false;
        }
        if (Float.floatToIntBits(coefficient2) != Float.floatToIntBits(other.coefficient2)) {
            return false;
        }
        if (Float.floatToIntBits(coefficient3) != Float.floatToIntBits(other.coefficient3)) {
            return false;
        }
        if (Float.floatToIntBits(coefficient4) != Float.floatToIntBits(other.coefficient4)) {
            return false;
        }
        if (fluxType == null) {
            if (other.fluxType != null) {
                return false;
            }
        } else if (!fluxType.equals(other.fluxType)) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (modelName == null) {
            if (other.modelName != null) {
                return false;
            }
        } else if (!modelName.equals(other.modelName)) {
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
        return ReflectionToStringBuilder.toString(this);
    }

    /**
     * Used to construct a {@link DvLimbDarkeningModel} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvLimbDarkeningModel} object is created using
     * the build method. For example:
     * 
     * <pre>
     * DvLimbDarkeningModel limbDarkeningModel = new DvLimbDarkeningModel(
     *     targetTableId, keplerId, pipelineTask).ccdModule(2)
     *     .ccdOutput(1)
     *     .modelName(&quot;kepler_nonlinear_limb_darkening_model&quot;)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    @XmlTransient
    public static class Builder extends DvAbstractTargetTableData.Builder {
    
        private int keplerId;
        private String modelName;
        private float coefficient1;
        private float coefficient2;
        private float coefficient3;
        private float coefficient4;
        private FluxType fluxType;
        private PipelineTask pipelineTask;
    
        public Builder(int targetTableId, FluxType fluxType, int keplerId,
            PipelineTask pipelineTask) {
            super(targetTableId);
    
            if (pipelineTask == null) {
                throw new NullPointerException("pipelineTask can't be null");
            }
            if (fluxType == null) {
                throw new NullPointerException("fluxType can't be null");
            }
            this.fluxType = fluxType;
            this.keplerId = keplerId;
            this.pipelineTask = pipelineTask;
        }
    
        @Override
        public Builder ccdModule(int ccdModule) {
            super.ccdModule(ccdModule);
            return this;
        }
    
        @Override
        public Builder ccdOutput(int ccdOutput) {
            super.ccdOutput(ccdOutput);
            return this;
        }
    
        @Override
        public Builder quarter(int quarter) {
            super.quarter(quarter);
            return this;
        }
    
        @Override
        public Builder startCadence(int startCadence) {
            super.startCadence(startCadence);
            return this;
        }
    
        @Override
        public Builder endCadence(int endCadence) {
            super.endCadence(endCadence);
            return this;
        }
    
        public Builder modelName(String modelName) {
            this.modelName = modelName;
            return this;
        }
    
        public Builder coefficient1(float coefficient1) {
            this.coefficient1 = coefficient1;
            return this;
        }
    
        public Builder coefficient2(float coefficient2) {
            this.coefficient2 = coefficient2;
            return this;
        }
    
        public Builder coefficient3(float coefficient3) {
            this.coefficient3 = coefficient3;
            return this;
        }
    
        public Builder coefficient4(float coefficient4) {
            this.coefficient4 = coefficient4;
            return this;
        }
    
        public DvLimbDarkeningModel build() {
            return new DvLimbDarkeningModel(this);
        }
    }
}
