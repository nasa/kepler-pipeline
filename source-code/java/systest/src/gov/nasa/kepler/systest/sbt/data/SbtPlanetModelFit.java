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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.primitives.Floats.toArray;
import gov.nasa.kepler.hibernate.dv.DvModelParameter;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * This class contains a planet model fit.
 * 
 * @author Miles Cote
 * 
 */
public class SbtPlanetModelFit implements SbtDataContainer {

    private boolean fullConvergence;
    private String limbDarkeningModelName = "";
    private float modelChiSquare = Float.NaN;
    private float modelDegreesOfFreedom = Float.NaN;
    private float modelFitSnr;
    private float[] modelParameterCovariance = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private List<SbtModelParameter> modelParameters = newArrayList();
    private int planetNumber;
    private boolean seededWithPriorFit;
    private String transitModelName = "";

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString(
            "limbDarkeningModelName",
            new SbtString(limbDarkeningModelName).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("modelChiSquare",
            new SbtNumber(modelChiSquare).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "modelDegreesOfFreedom",
            new SbtNumber(modelDegreesOfFreedom).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("planetNumber",
            new SbtNumber(planetNumber).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("transitModelName",
            new SbtString(transitModelName).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPlanetModelFit() {
    }

    public SbtPlanetModelFit(DvPlanetModelFit dvPlanetModelFit) {
        this.fullConvergence = dvPlanetModelFit.isFullConvergence();
        // For trapezoidal fit, the limb-darkening model name is NULL in the database
        final String limbDarkeningModelName =
            dvPlanetModelFit.getLimbDarkeningModelName();
        this.limbDarkeningModelName = (limbDarkeningModelName == null) ? "N/A" : 
            limbDarkeningModelName;
        this.modelChiSquare = dvPlanetModelFit.getModelChiSquare();
        this.modelDegreesOfFreedom = dvPlanetModelFit.getModelDegreesOfFreedom();
        this.modelFitSnr = dvPlanetModelFit.getModelFitSnr();
        this.planetNumber = dvPlanetModelFit.getPlanetNumber();
        this.seededWithPriorFit = dvPlanetModelFit.isSeededWithPriorFit();
        this.transitModelName = dvPlanetModelFit.getTransitModelName();

        List<Float> covarianceList = newArrayList();
        for (Float covariance : dvPlanetModelFit.getModelParameterCovariance()) {
            covarianceList.add(covariance);
        }
        this.modelParameterCovariance = toArray(covarianceList);

        List<SbtModelParameter> sbtModelParameters = newArrayList();
        for (DvModelParameter dvModelParameter : dvPlanetModelFit.getModelParameters()) {
            sbtModelParameters.add(new SbtModelParameter(dvModelParameter));
        }
        this.modelParameters = sbtModelParameters;
    }

    public SbtPlanetModelFit(boolean fullConvergence,
        String limbDarkeningModelName, float modelChiSquare,
        float modelDegreesOfFreedom, float modelFitSnr,
        float[] modelParameterCovariance,
        List<SbtModelParameter> modelParameters, int planetNumber,
        boolean seededWithPriorFit, String transitModelName) {
        this.fullConvergence = fullConvergence;
        // For trapezoidal fit, the limb-darkening model name is NULL in the database
        this.limbDarkeningModelName =
            (limbDarkeningModelName == null) ? "N/A" : limbDarkeningModelName; 
        this.modelChiSquare = modelChiSquare;
        this.modelDegreesOfFreedom = modelDegreesOfFreedom;
        this.modelFitSnr = modelFitSnr;
        this.modelParameterCovariance = modelParameterCovariance;
        this.modelParameters = modelParameters;
        this.planetNumber = planetNumber;
        this.transitModelName = transitModelName;
    }

    public String getLimbDarkeningModelName() {
        return limbDarkeningModelName;
    }

    public void setLimbDarkeningModelName(String limbDarkeningModelName) {
        // For trapezoidal fit, the limb-darkening model name is NULL in the database
        this.limbDarkeningModelName =
            (limbDarkeningModelName == null) ? "N/A" : limbDarkeningModelName;
    }

    public float getModelChiSquare() {
        return modelChiSquare;
    }

    public void setModelChiSquare(float modelChiSquare) {
        this.modelChiSquare = modelChiSquare;
    }

    public float getModelDegreesOfFreedom() {
        return modelDegreesOfFreedom;
    }

    public void setModelDegreesOfFreedom(float modelDegreesOfFreedom) {
        this.modelDegreesOfFreedom = modelDegreesOfFreedom;
    }

    public float[] getModelParameterCovariance() {
        return modelParameterCovariance;
    }

    public void setModelParameterCovariance(float[] modelParameterCovariance) {
        this.modelParameterCovariance = modelParameterCovariance;
    }

    public List<SbtModelParameter> getModelParameters() {
        return modelParameters;
    }

    public void setModelParameters(List<SbtModelParameter> modelParameters) {
        this.modelParameters = modelParameters;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public void setPlanetNumber(int planetNumber) {
        this.planetNumber = planetNumber;
    }

    public boolean isSeededWithPriorFit() {
        return seededWithPriorFit;
    }

    public void setSeededWithPriorFit(boolean seededWithPriorFit) {
        this.seededWithPriorFit = seededWithPriorFit;
    }

    public String getTransitModelName() {
        return transitModelName;
    }

    public void setTransitModelName(String transitModelName) {
        this.transitModelName = transitModelName;
    }

    public boolean isFullConvergence() {
        return fullConvergence;
    }

    public void setFullConvergence(boolean fullConvergence) {
        this.fullConvergence = fullConvergence;
    }

    public float getModelFitSnr() {
        return modelFitSnr;
    }

    public void setModelFitSnr(float modelFitSnr) {
        this.modelFitSnr = modelFitSnr;
    }

}
