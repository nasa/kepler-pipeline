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

package gov.nasa.kepler.mc.pa;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Parameters related to injecting simulating transits.
 * 
 * @author Forrest Girouard
 */
public class SimulatedTransitsModuleParameters implements Persistable,
    Parameters {

    private boolean enableRandomParamGen;
    private float epochZeroTimeMjd;
    private String generatingParamSetName = "";
    private float inputSesUpperLimit;
    private float inputSesLowerLimit;
    private float inputDurationUpperLimit;
    private float inputDurationLowerLimit;
    private float inputOrbitalPeriodLowerLimit;
    private float inputOrbitalPeriodUpperLimit;
    private float inputPlanetRadiusLowerLimit;
    private float inputPlanetRadiusUpperLimit;
    private float impactParameterUpperLimit;
    private float impactParameterLowerLimit;
    private boolean offsetEnabled;
    private float offsetLowerLimitArcSec;
    private float offsetTransitDepth;
    private float offsetUpperLimitArcSec;
    private String parameterInputFilename = "";
    private int[] randomSeedBySkygroup = new int[0];
    private boolean randomSeedFromClockEnabled;
    private int transitBufferCadences;
    private float transitSeparationFactor;
    private boolean useDefaultKicsParameters;

    public boolean isEnableRandomParamGen() {
        return enableRandomParamGen;
    }

    public void setEnableRandomParamGen(boolean enableRandomParamGen) {
        this.enableRandomParamGen = enableRandomParamGen;
    }

    public float getEpochZeroTimeMjd() {
        return epochZeroTimeMjd;
    }

    public void setEpochZeroTimeMjd(float epochZeroTimeMjd) {
        this.epochZeroTimeMjd = epochZeroTimeMjd;
    }

    public String getGeneratingParamSetName() {
        return generatingParamSetName;
    }

    public void setGeneratingParamSetName(String generatingParamSetName) {
        this.generatingParamSetName = generatingParamSetName;
    }

    public float getInputSesUpperLimit() {
        return inputSesUpperLimit;
    }

    public void setInputSesUpperLimit(float inputSesUpperLimit) {
        this.inputSesUpperLimit = inputSesUpperLimit;
    }

    public float getInputSesLowerLimit() {
        return inputSesLowerLimit;
    }

    public void setInputSesLowerLimit(float inputSesLowerLimit) {
        this.inputSesLowerLimit = inputSesLowerLimit;
    }

    public float getInputDurationUpperLimit() {
        return inputDurationUpperLimit;
    }

    public void setInputDurationUpperLimit(float inputDurationUpperLimit) {
        this.inputDurationUpperLimit = inputDurationUpperLimit;
    }

    public float getInputDurationLowerLimit() {
        return inputDurationLowerLimit;
    }

    public void setInputDurationLowerLimit(float inputDurationLowerLimit) {
        this.inputDurationLowerLimit = inputDurationLowerLimit;
    }

    public float getInputOrbitalPeriodLowerLimit() {
        return inputOrbitalPeriodLowerLimit;
    }

    public void setInputOrbitalPeriodLowerLimit(
        float inputOrbitalPeriodLowerLimit) {
        this.inputOrbitalPeriodLowerLimit = inputOrbitalPeriodLowerLimit;
    }

    public float getInputOrbitalPeriodUpperLimit() {
        return inputOrbitalPeriodUpperLimit;
    }

    public void setInputOrbitalPeriodUpperLimit(
        float inputOrbitalPeriodUpperLimit) {
        this.inputOrbitalPeriodUpperLimit = inputOrbitalPeriodUpperLimit;
    }

    public float getInputPlanetRadiusLowerLimit() {
        return inputPlanetRadiusLowerLimit;
    }

    public void setInputPlanetRadiusLowerLimit(float inputPlanetRadiusLowerLimit) {
        this.inputPlanetRadiusLowerLimit = inputPlanetRadiusLowerLimit;
    }

    public float getInputPlanetRadiusUpperLimit() {
        return inputPlanetRadiusUpperLimit;
    }

    public void setInputPlanetRadiusUpperLimit(float inputPlanetRadiusUpperLimit) {
        this.inputPlanetRadiusUpperLimit = inputPlanetRadiusUpperLimit;
    }

    public float getImpactParameterUpperLimit() {
        return impactParameterUpperLimit;
    }

    public void setImpactParameterUpperLimit(float impactParameterUpperLimit) {
        this.impactParameterUpperLimit = impactParameterUpperLimit;
    }

    public float getImpactParameterLowerLimit() {
        return impactParameterLowerLimit;
    }

    public void setImpactParameterLowerLimit(float impactParameterLowerLimit) {
        this.impactParameterLowerLimit = impactParameterLowerLimit;
    }

    public boolean isOffsetEnabled() {
        return offsetEnabled;
    }

    public void setOffsetEnabled(boolean offsetEnabled) {
        this.offsetEnabled = offsetEnabled;
    }

    public float getOffsetLowerLimitArcSec() {
        return offsetLowerLimitArcSec;
    }

    public void setOffsetLowerLimitArcSec(float offsetLowerLimitArcSec) {
        this.offsetLowerLimitArcSec = offsetLowerLimitArcSec;
    }

    public float getOffsetTransitDepth() {
        return offsetTransitDepth;
    }

    public void setOffsetTransitDepth(float offsetTransitDepth) {
        this.offsetTransitDepth = offsetTransitDepth;
    }

    public float getOffsetUpperLimitArcSec() {
        return offsetUpperLimitArcSec;
    }

    public void setOffsetUpperLimitArcSec(float offsetUpperLimitArcSec) {
        this.offsetUpperLimitArcSec = offsetUpperLimitArcSec;
    }

    public int[] getRandomSeedBySkygroup() {
        return randomSeedBySkygroup;
    }

    public void setRandomSeedBySkygroup(int[] randomSeedBySkygroup) {
        this.randomSeedBySkygroup = randomSeedBySkygroup;
    }

    public String getParameterInputFilename() {
        return parameterInputFilename;
    }

    public void setParameterInputFilename(String parameterInputFilename) {
        this.parameterInputFilename = parameterInputFilename;
    }

    public boolean isRandomSeedFromClockEnabled() {
        return randomSeedFromClockEnabled;
    }

    public void setRandomSeedFromClockEnabled(boolean randomSeedFromClockEnabled) {
        this.randomSeedFromClockEnabled = randomSeedFromClockEnabled;
    }

    public int getTransitBufferCadences() {
        return transitBufferCadences;
    }

    public void setTransitBufferCadences(int transitBufferCadences) {
        this.transitBufferCadences = transitBufferCadences;
    }

    public float getTransitSeparationFactor() {
        return transitSeparationFactor;
    }

    public void setTransitSeparationFactor(float transitSeparationFactor) {
        this.transitSeparationFactor = transitSeparationFactor;
    }

    public boolean isUseDefaultKicsParameters() {
        return useDefaultKicsParameters;
    }

    public void setUseDefaultKicsParameters(boolean useDefaultKicsParameters) {
        this.useDefaultKicsParameters = useDefaultKicsParameters;
    }
}
