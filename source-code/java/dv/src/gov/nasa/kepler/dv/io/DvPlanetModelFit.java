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

package gov.nasa.kepler.dv.io;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Fit results for a particular planet.
 * 
 * @author Forrest Girouard
 */
public class DvPlanetModelFit implements Persistable {

    private boolean fullConvergence;
    private int keplerId;
    private String limbDarkeningModelName = "";
    private float modelChiSquare;
    private float modelDegreesOfFreedom;
    private float modelFitSnr;
    private float[] modelParameterCovariance = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private List<DvModelParameter> modelParameters = new ArrayList<DvModelParameter>();
    private int planetNumber;
    private float[] robustWeights = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean seededWithPriorFit;
    private String transitModelName = "";

    /**
     * Creates a {@link DvPlanetModelFit}. For use only by mock objects and
     * Hibernate.
     */
    public DvPlanetModelFit() {
    }

    /**
     * Creates a new immutable {@link DvPlanetModelFit} from the given
     * {@link Builder} object.
     */
    protected DvPlanetModelFit(Builder builder) {
        fullConvergence = builder.fullConvergence;
        keplerId = builder.keplerId;
        planetNumber = builder.planetNumber;
        limbDarkeningModelName = builder.limbDarkeningModelName;
        modelChiSquare = builder.modelChiSquare;
        modelDegreesOfFreedom = builder.modelDegreesOfFreedom;
        modelFitSnr = builder.modelFitSnr;
        modelParameterCovariance = builder.modelParameterCovariance;
        modelParameters = builder.modelParameters;
        robustWeights = builder.robustWeights;
        seededWithPriorFit = builder.seededWithPriorFit;
        transitModelName = builder.transitModelName;
    }

    /**
     * Used to construct an immutable {@link DvPlanetModelFit} object. To use
     * this class, a {@link Builder} object is created and then non-null fields
     * are set using the available builder methods. Finally, a
     * {@link DvPlanetModelFit} object is created using the {@code build}
     * method. For example:
     * 
     * <pre>
     * DvPlanetModelFit modelFit = new DvPlanetModelFit.Builder(keplerId, planetNumber).modelChiSquare(
     *     chiSquare)
     *     .robustWeights(robustWeights)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */

    public static class Builder {
        private boolean fullConvergence;
        private int keplerId;
        private String limbDarkeningModelName = "";
        private float modelChiSquare;
        private float modelDegreesOfFreedom;
        private float modelFitSnr;
        private float[] modelParameterCovariance = ArrayUtils.EMPTY_FLOAT_ARRAY;;
        private List<DvModelParameter> modelParameters = new ArrayList<DvModelParameter>();
        private int planetNumber;
        private float[] robustWeights = ArrayUtils.EMPTY_FLOAT_ARRAY;
        private boolean seededWithPriorFit;
        private String transitModelName = "";

        public Builder(int keplerId, int planetNumber) {
            this.keplerId = keplerId;
            this.planetNumber = planetNumber;
        }

        public Builder fullConvergence(boolean fullConvergence) {
            this.fullConvergence = fullConvergence;
            return this;
        }

        public Builder limbDarkeningModelName(String limbDarkeningModelName) {
            this.limbDarkeningModelName = limbDarkeningModelName;
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

        public Builder modelParameterCovariance(float[] modelParameterCovariance) {
            this.modelParameterCovariance = modelParameterCovariance;
            return this;
        }

        public Builder modelParameters(List<DvModelParameter> modelParameters) {
            this.modelParameters = modelParameters;
            return this;
        }

        public Builder robustWeights(float[] robustWeights) {
            this.robustWeights = robustWeights;
            return this;
        }

        public Builder seededWithPriorFit(boolean seededWithPriorFit) {
            this.seededWithPriorFit = seededWithPriorFit;
            return this;
        }

        public Builder transitModelName(String transitModelName) {
            this.transitModelName = transitModelName;
            return this;
        }

        public DvPlanetModelFit build() {
            return new DvPlanetModelFit(this);
        }
    }

    public boolean isFullConvergence() {
        return fullConvergence;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public String getLimbDarkeningModelName() {
        return limbDarkeningModelName;
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

    public float[] getModelParameterCovariance() {
        return modelParameterCovariance;
    }

    public List<DvModelParameter> getModelParameters() {
        return modelParameters;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public float[] getRobustWeights() {
        return robustWeights;
    }

    public boolean isSeededWithPriorFit() {
        return seededWithPriorFit;
    }

    public String getTransitModelName() {
        return transitModelName;
    }
}
