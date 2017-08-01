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

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.util.ArrayList;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

/**
 * The best model that fits the given planet.
 * <p>
 * Some column names shortened to meet Oracle's 30 character limit.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "DV_PLANET_MODEL_FIT")
@XmlType
public class DvPlanetModelFit {

    public enum PlanetModelFitType {
        ALL, ODD, EVEN, SINGLE, REDUCED_PARAMETER, TRAPEZOIDAL;

        private String name;

        private PlanetModelFitType() {
            name = StringUtils.constantToCamel(super.toString())
                .intern();
        }

        public String getName() {
            return name;
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_PLANET_MODEL_FIT_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute
    private int keplerId;

    @XmlAttribute
    private int planetNumber;

    @XmlAttribute
    private PlanetModelFitType type;

    @XmlAttribute
    private float modelChiSquare;

    @XmlAttribute
    private float modelDegreesOfFreedom;

    @XmlAttribute
    private float modelFitSnr;

    @XmlAttribute
    private String transitModelName;

    @XmlAttribute(required = true)
    private String limbDarkeningModelName;

    @XmlAttribute
    private boolean fullConvergence;

    @XmlAttribute
    private boolean seededWithPriorFit;

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_PMF_MODEL_PARAMETERS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvModelParameter> modelParameters = new ArrayList<DvModelParameter>();

    // This is a nxn covariance matrix on the modelParameters where n is the
    // same dimension as the modelParameters field. The MATLAB code is
    // responsible for turning the matrix into a vector. The matrix is symmetric
    // so it doesn't matter if you access the vector in row-major or
    // column-major fashion.
    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_PMF_MODEL_PARAMETER_COV")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<Float> modelParameterCovariance = new ArrayList<Float>();

    @ManyToOne(fetch = FetchType.LAZY)
    @XmlAttribute(name = "pipelineTaskId", required = true)
    @XmlJavaTypeAdapter(PipelineTaskXmlAdapter.class)
    private PipelineTask pipelineTask;

    /**
     * Creates a {@link DvPlanetModelFit}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    public DvPlanetModelFit() {
    }

    /**
     * Creates a new {@link DvPlanetModelFit} from the given object.
     */
    private DvPlanetModelFit(Builder builder) {
        id = builder.id;
        keplerId = builder.keplerId;
        planetNumber = builder.planetNumber;
        type = builder.type;
        modelChiSquare = builder.modelChiSquare;
        modelDegreesOfFreedom = builder.modelDegreesOfFreedom;
        modelFitSnr = builder.modelFitSnr;
        transitModelName = builder.transitModelName;
        limbDarkeningModelName = builder.limbDarkeningModelName;
        fullConvergence = builder.fullConvergence;
        seededWithPriorFit = builder.seededWithPriorFit;
        modelParameters = builder.modelParameters;
        modelParameterCovariance = builder.modelParameterCovariance;
        pipelineTask = builder.pipelineTask;
    }

    public long getId() {
        return id;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public PlanetModelFitType getType() {
        return type;
    }

    public float getModelChiSquare() {
        return modelChiSquare;
    }

    public float getModelDegreesOfFreedom() {
        return modelDegreesOfFreedom;
    }

    public float getModelFitSnr() {
        return modelFitSnr;
    }

    public String getTransitModelName() {
        return transitModelName;
    }

    public String getLimbDarkeningModelName() {
        return limbDarkeningModelName;
    }

    public boolean isFullConvergence() {
        return fullConvergence;
    }

    public boolean isSeededWithPriorFit() {
        return seededWithPriorFit;
    }

    public List<DvModelParameter> getModelParameters() {
        return modelParameters;
    }

    public List<Float> getModelParameterCovariance() {
        return modelParameterCovariance;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (fullConvergence ? 1231 : 1237);
        result = prime * result + keplerId;
        result = prime
            * result
            + (limbDarkeningModelName == null ? 0
                : limbDarkeningModelName.hashCode());
        result = prime * result + Float.floatToIntBits(modelChiSquare);
        result = prime * result + Float.floatToIntBits(modelDegreesOfFreedom);
        result = prime * result + Float.floatToIntBits(modelFitSnr);
        result = prime
            * result
            + (modelParameterCovariance == null ? 0
                : modelParameterCovariance.hashCode());
        result = prime * result
            + (modelParameters == null ? 0 : modelParameters.hashCode());
        result = prime * result
            + (pipelineTask == null ? 0 : pipelineTask.hashCode());
        result = prime * result + planetNumber;
        result = prime * result + (seededWithPriorFit ? 1231 : 1237);
        result = prime * result
            + (transitModelName == null ? 0 : transitModelName.hashCode());
        result = prime * result + (type == null ? 0 : type.hashCode());
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
        if (!(obj instanceof DvPlanetModelFit)) {
            return false;
        }
        DvPlanetModelFit other = (DvPlanetModelFit) obj;
        if (fullConvergence != other.fullConvergence) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (limbDarkeningModelName == null) {
            if (other.limbDarkeningModelName != null) {
                return false;
            }
        } else if (!limbDarkeningModelName.equals(other.limbDarkeningModelName)) {
            return false;
        }
        if (Float.floatToIntBits(modelChiSquare) != Float.floatToIntBits(other.modelChiSquare)) {
            return false;
        }
        if (Float.floatToIntBits(modelDegreesOfFreedom) != Float.floatToIntBits(other.modelDegreesOfFreedom)) {
            return false;
        }
        if (Float.floatToIntBits(modelFitSnr) != Float.floatToIntBits(other.modelFitSnr)) {
            return false;
        }
        if (modelParameterCovariance == null) {
            if (other.modelParameterCovariance != null) {
                return false;
            }
        } else if (!modelParameterCovariance.equals(other.modelParameterCovariance)) {
            return false;
        }
        if (modelParameters == null) {
            if (other.modelParameters != null) {
                return false;
            }
        } else if (!modelParameters.equals(other.modelParameters)) {
            return false;
        }
        if (pipelineTask == null) {
            if (other.pipelineTask != null) {
                return false;
            }
        } else if (!pipelineTask.equals(other.pipelineTask)) {
            return false;
        }
        if (planetNumber != other.planetNumber) {
            return false;
        }
        if (seededWithPriorFit != other.seededWithPriorFit) {
            return false;
        }
        if (transitModelName == null) {
            if (other.transitModelName != null) {
                return false;
            }
        } else if (!transitModelName.equals(other.transitModelName)) {
            return false;
        }
        if (type == null) {
            if (other.type != null) {
                return false;
            }
        } else if (!type.equals(other.type)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("id", id)
            .append("keplerId", keplerId)
            .append("planetNumber", planetNumber)
            .append("type", type)
            .append("modelChiSquare", modelChiSquare)
            .append("modelDegreesOfFreedom", modelDegreesOfFreedom)
            .append("modelFitSnr", modelFitSnr)
            .append("transitModelName", transitModelName)
            .append("limbDarkeningModelName", limbDarkeningModelName)
            .append("fullConvergence", fullConvergence)
            .append("seededWithPriorFit", seededWithPriorFit)
            .append("modelParameters", modelParameters)
            .append("modelParameterCovariance", modelParameterCovariance)
            .append("pipelineTaskId",
                pipelineTask != null ? pipelineTask.getId() : "null")
            .toString();
    }

    /**
     * Used to construct a {@link DvPlanetModelFit} object. To use this class, a
     * {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvPlanetModelFit} object is created using the
     * build method. For example:
     * 
     * <pre>
     * DvPlanetModelFit planetModelFit = new DvPlanetModelFit.Builder(pipelineTask).keplerId(
     *     12345678)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    @XmlTransient
    public static class Builder {
        private long id;
        private int keplerId;
        private int planetNumber;
        private PlanetModelFitType type;
        private float modelChiSquare;
        private float modelDegreesOfFreedom;
        private float modelFitSnr;
        private String transitModelName;
        private String limbDarkeningModelName;
        private boolean fullConvergence;
        private boolean seededWithPriorFit;
        private List<DvModelParameter> modelParameters;
        private List<Float> modelParameterCovariance;
        private PipelineTask pipelineTask;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param keplerId the Kepler ID
         * @param planetNumber the planet number
         * @param pipelineTask the pipeline task
         * @throws NullPointerException if {@code pipelineTask} is {@code null}
         */
        public Builder(int keplerId, int planetNumber, PipelineTask pipelineTask) {
            if (pipelineTask == null) {
                throw new NullPointerException("pipelineTask can't be null");
            }

            this.keplerId = keplerId;
            this.planetNumber = planetNumber;
            this.pipelineTask = pipelineTask;
        }

        /**
         * For use by tests only.
         */
        Builder id(long id) {
            this.id = id;
            return this;
        }

        public Builder type(PlanetModelFitType type) {
            this.type = type;
            return this;
        }

        public Builder modelChiSquare(float modelChiSquare) {
            this.modelChiSquare = modelChiSquare;
            return this;
        }

        public Builder modelDegreesOfFreedom(float modelDegreesOfFreedom) {
            this.modelDegreesOfFreedom = modelDegreesOfFreedom;
            return this;
        }

        public Builder modelFitSnr(float modelFitSnr) {
            this.modelFitSnr = modelFitSnr;
            return this;
        }

        public Builder transitModelName(String transitModelName) {
            this.transitModelName = transitModelName;
            return this;
        }

        public Builder limbDarkeningModelName(String limbDarkeningModelName) {
            this.limbDarkeningModelName = limbDarkeningModelName;
            return this;
        }

        public Builder fullConvergence(boolean fullConvergence) {
            this.fullConvergence = fullConvergence;
            return this;
        }

        public Builder seededWithPriorFit(boolean seededWithPriorFit) {
            this.seededWithPriorFit = seededWithPriorFit;
            return this;
        }

        public Builder modelParameters(List<DvModelParameter> modelParameters) {
            this.modelParameters = modelParameters;
            return this;
        }

        public Builder modelParameterCovariance(
            List<Float> modelParameterCovariance) {
            this.modelParameterCovariance = modelParameterCovariance;
            return this;
        }

        public DvPlanetModelFit build() {
            return new DvPlanetModelFit(this);
        }
    }
}
