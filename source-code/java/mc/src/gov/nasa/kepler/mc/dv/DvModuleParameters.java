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

package gov.nasa.kepler.mc.dv;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;

/**
 * Data Validation (DV) module parameters.
 * 
 * @author Forrest Girouard
 */
public class DvModuleParameters implements Persistable, Parameters {

    private boolean binaryDiscriminationTestsEnabled;
    private boolean bootstrapEnabled;
    private boolean cbvEnabled;
    private boolean centroidTestsEnabled;
    private int debugLevel;
    private boolean differenceImageGenerationEnabled;
    private boolean externalTcesEnabled;
    private boolean ghostDiagnosticTestsEnabled;
    private boolean koiMatchingEnabled;
    private float koiMatchingThreshold;
    private String limbDarkeningModelName = "";
    private int maxCandidatesPerTarget;
    private boolean multiplePlanetSearchEnabled;
    private boolean modelFitEnabled;
    private boolean pixelCorrelationTestsEnabled;
    private boolean reportEnabled;
    private boolean rollingBandDiagnosticsEnabled;
    private boolean simulatedTransitsEnabled;
    private String[] team = ArrayUtils.EMPTY_STRING_ARRAY;
    private String transitModelName = "";
    private boolean weakSecondaryTestEnabled;
    private boolean exceptionCatchingEnabled;

    @ProxyIgnore
    private boolean storeRobustWeightsEnabled = false;

    public DvModuleParameters() {
    }

    public boolean isBinaryDiscriminationTestsEnabled() {
        return binaryDiscriminationTestsEnabled;
    }

    public void setBinaryDiscriminationTestsEnabled(
        boolean binaryDiscriminationTestsEnabled) {
        this.binaryDiscriminationTestsEnabled = binaryDiscriminationTestsEnabled;
    }

    public boolean isBootstrapEnabled() {
        return bootstrapEnabled;
    }

    public void setBootstrapEnabled(boolean bootstrapEnabled) {
        this.bootstrapEnabled = bootstrapEnabled;
    }

    public boolean isCbvEnabled() {
        return cbvEnabled;
    }

    public void setCbvEnabled(boolean cbvEnabled) {
        this.cbvEnabled = cbvEnabled;
    }

    public boolean isCentroidTestsEnabled() {
        return centroidTestsEnabled;
    }

    public void setCentroidTestsEnabled(boolean centroidTestsEnabled) {
        this.centroidTestsEnabled = centroidTestsEnabled;
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    public boolean isDifferenceImageGenerationEnabled() {
        return differenceImageGenerationEnabled;
    }

    public void setDifferenceImageGenerationEnabled(
        boolean differenceImageGenerationEnabled) {
        this.differenceImageGenerationEnabled = differenceImageGenerationEnabled;
    }

    public boolean isExternalTcesEnabled() {
        return externalTcesEnabled;
    }

    public void setExternalTcesEnabled(boolean externalTcesEnabled) {
        this.externalTcesEnabled = externalTcesEnabled;
    }

    public boolean isGhostDiagnosticTestsEnabled() {
        return ghostDiagnosticTestsEnabled;
    }

    public void setGhostDiagnosticTestsEnabled(
        boolean ghostDiagnosticTestsEnabled) {
        this.ghostDiagnosticTestsEnabled = ghostDiagnosticTestsEnabled;
    }

    public boolean isKoiMatchingEnabled() {
        return koiMatchingEnabled;
    }

    public void setKoiMatchingEnabled(boolean koiMatchingEnabled) {
        this.koiMatchingEnabled = koiMatchingEnabled;
    }

    public float getKoiMatchingThreshold() {
        return koiMatchingThreshold;
    }

    public void setKoiMatchingThreshold(float koiMatchingThreshold) {
        this.koiMatchingThreshold = koiMatchingThreshold;
    }

    public String getLimbDarkeningModelName() {
        return limbDarkeningModelName;
    }

    public void setLimbDarkeningModelName(String limbDarkeningModelName) {
        this.limbDarkeningModelName = limbDarkeningModelName;
    }

    public int getMaxCandidatesPerTarget() {
        return maxCandidatesPerTarget;
    }

    public void setMaxCandidatesPerTarget(int maxCandidatesPerTarget) {
        this.maxCandidatesPerTarget = maxCandidatesPerTarget;
    }

    public boolean isMultiplePlanetSearchEnabled() {
        return multiplePlanetSearchEnabled;
    }

    public void setMultiplePlanetSearchEnabled(
        boolean multiplePlanetSearchEnabled) {
        this.multiplePlanetSearchEnabled = multiplePlanetSearchEnabled;
    }

    public boolean isModelFitEnabled() {
        return modelFitEnabled;
    }

    public void setModelFitEnabled(boolean modelFitEnabled) {
        this.modelFitEnabled = modelFitEnabled;
    }

    public boolean isPixelCorrelationTestsEnabled() {
        return pixelCorrelationTestsEnabled;
    }

    public void setPixelCorrelationTestsEnabled(
        boolean pixelCorrelationTestsEnabled) {
        this.pixelCorrelationTestsEnabled = pixelCorrelationTestsEnabled;
    }

    public boolean isReportEnabled() {
        return reportEnabled;
    }

    public void setReportEnabled(boolean reportEnabled) {
        this.reportEnabled = reportEnabled;
    }

    public boolean isRollingBandDiagnosticsEnabled() {
        return rollingBandDiagnosticsEnabled;
    }

    public void setRollingBandDiagnosticsEnabled(
        boolean rollingBandDiagnosticsEnabled) {
        this.rollingBandDiagnosticsEnabled = rollingBandDiagnosticsEnabled;
    }

    public boolean isSimulatedTransitsEnabled() {
        return simulatedTransitsEnabled;
    }

    public void setSimulatedTransitsEnabled(boolean simulatedTransitsEnabled) {
        this.simulatedTransitsEnabled = simulatedTransitsEnabled;
    }

    public boolean isStoreRobustWeightsEnabled() {
        return storeRobustWeightsEnabled;
    }

    public void setStoreRobustWeightsEnabled(boolean storeRobustWeightsEnabled) {
        this.storeRobustWeightsEnabled = storeRobustWeightsEnabled;
    }

    public String[] getTeam() {
        return team;
    }

    public void setTeam(String[] team) {
        this.team = team;
    }

    public String getTransitModelName() {
        return transitModelName;
    }

    public void setTransitModelName(String transitModelName) {
        this.transitModelName = transitModelName;
    }

    public boolean isWeakSecondaryTestEnabled() {
        return weakSecondaryTestEnabled;
    }

    public void setWeakSecondaryTestEnabled(boolean weakSecondaryTestEnabled) {
        this.weakSecondaryTestEnabled = weakSecondaryTestEnabled;
    }
    
    public boolean isExceptionCatchingEnabled() {
        return exceptionCatchingEnabled;
    }
    
    public void setExceptionCatchingEnabled(boolean exceptionCatchingEnabled) {
        this.exceptionCatchingEnabled = exceptionCatchingEnabled;
    }
}
