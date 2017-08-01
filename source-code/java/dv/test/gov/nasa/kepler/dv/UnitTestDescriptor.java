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

package gov.nasa.kepler.dv;

import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;

/**
 * Descriptor used to control the unit tests.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class UnitTestDescriptor {

    // CadenceRangeParameters
    private int startCadence = 1439;
    private int endCadence = 1488;

    // PlanetaryCandidatesChunkUowTask
    private int startKeplerId = 10000000;
    private int endKeplerId = startKeplerId + 100;
    private int skyGroupId = 13;

    private PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters = new PlanetaryCandidatesFilterParameters();

    // Target table data
    private int targetTableCount = 1;
    private int targetTableId = 103;
    private int targetsPerTable = 2;
    private int maxPixelsPerTarget = 4;

    // DvModuleParameters
    private String[] ancillaryEngineeringMnemonics = new String[] {};
    private String[] ancillaryPipelineMnemonics = new String[] {};
    private int bootstrapSkipCount = 0;
    private float histogramBinWidth = 0F;
    private String transitModelName = "transit";
    private String limbDarkeningModelName = "limb";
    private boolean binaryDiscriminationTestsEnabled = false;
    private boolean bootstrapEnabled = false;
    private boolean centroidTestsEnabled = false;
    private boolean multiplePlanetSearchEnabled = false;
    private boolean reportEnabled = false;
    private boolean storeRobustWeightsEnabled = true;
    private boolean simulatedTransitsEnabled = false;
    private boolean externalTcesEnabled = false;
    private boolean koiMatchingEnabled = false;

    // DifferenceImageParameters
    private float boundedBoxWidth = 48.0F;

    // DV runtime
    private int planetCount = 1;
    private int ccdModule = 4;
    private int ccdOutput = 3;
    private int ccdRow = 24;
    private int ccdColumn = 42;
    private int quarter = 6;
    private int numberOfTransits = 42;
    private int numberOfCadencesInTransit = 43;
    private int numberOfCadenceGapsInTransit = 44;
    private int numberOfCadencesOutOfTransit = 45;
    private int numberOfCadenceGapsOutOfTransit = 46;
    private boolean overlappedTransits = false;

    // Unit test control
    private boolean generateAlerts = false;
    private boolean serializeInputs = false;
    private boolean serializeOutputs = false;
    private boolean validateInputs = false;
    private boolean validateOutputs = false;
    private boolean prfCentroidsEnabled = true;

    public int getCadenceCount() {
        return endCadence - startCadence + 1;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getStartKeplerId() {
        return startKeplerId;
    }

    public void setStartKeplerId(int startKeplerId) {
        this.startKeplerId = startKeplerId;
    }

    public int getEndKeplerId() {
        return endKeplerId;
    }

    public void setEndKeplerId(int endKeplerId) {
        this.endKeplerId = endKeplerId;
    }

    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    public PlanetaryCandidatesFilterParameters getPlanetaryCandidatesFilterParameters() {
        return planetaryCandidatesFilterParameters;
    }

    public void setPlanetaryCandidatesFilterParameters(
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters) {
        this.planetaryCandidatesFilterParameters = planetaryCandidatesFilterParameters;
    }

    public int getTargetTableCount() {
        return targetTableCount;
    }

    public void setTargetTableCount(int targetTableCount) {
        this.targetTableCount = targetTableCount;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    public int getTargetsPerTable() {
        return targetsPerTable;
    }

    public void setTargetsPerTable(int targetsPerTable) {
        this.targetsPerTable = targetsPerTable;
    }

    public int getMaxPixelsPerTarget() {
        return maxPixelsPerTarget;
    }

    public void setMaxPixelsPerTarget(int maxPixelsPerTarget) {
        this.maxPixelsPerTarget = maxPixelsPerTarget;
    }

    public void setAncillaryEngineeringMnemonics(
        String[] ancillaryEngineeringMnemonics) {
        this.ancillaryEngineeringMnemonics = ancillaryEngineeringMnemonics;
    }

    public String[] getAncillaryEngineeringMnemonics() {
        return ancillaryEngineeringMnemonics;
    }

    public String[] getAncillaryPipelineMnemonics() {
        return ancillaryPipelineMnemonics;
    }

    public void setAncillaryPipelineMnemonics(
        String[] ancillaryPipelineMnemonics) {
        this.ancillaryPipelineMnemonics = ancillaryPipelineMnemonics;
    }

    public int getBootstrapSkipCount() {
        return bootstrapSkipCount;
    }

    public void setBootstrapSkipCount(int bootstrapSkipCount) {
        this.bootstrapSkipCount = bootstrapSkipCount;
    }

    public float getHistogramBinWidth() {
        return histogramBinWidth;
    }

    public void setHistogramBinWidth(float histogramBinWidth) {
        this.histogramBinWidth = histogramBinWidth;
    }

    public String getTransitModelName() {
        return transitModelName;
    }

    public void setTransitModelName(String transitModelName) {
        this.transitModelName = transitModelName;
    }

    public String getLimbDarkeningModelName() {
        return limbDarkeningModelName;
    }

    public void setLimbDarkeningModelName(String limbDarkeningModelName) {
        this.limbDarkeningModelName = limbDarkeningModelName;
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

    public boolean isCentroidTestsEnabled() {
        return centroidTestsEnabled;
    }

    public void setCentroidTestsEnabled(boolean centroidTestsEnabled) {
        this.centroidTestsEnabled = centroidTestsEnabled;
    }

    public boolean isMultiplePlanetSearchEnabled() {
        return multiplePlanetSearchEnabled;
    }

    public void setMultiplePlanetSearchEnabled(
        boolean multiplePlanetSearchEnabled) {
        this.multiplePlanetSearchEnabled = multiplePlanetSearchEnabled;
    }

    public boolean isReportEnabled() {
        return reportEnabled;
    }

    public void setReportEnabled(boolean reportEnabled) {
        this.reportEnabled = reportEnabled;
    }

    public boolean isStoreRobustWeightsEnabled() {
        return storeRobustWeightsEnabled;
    }

    public void setStoreRobustWeightsEnabled(boolean storeRobustWeightsEnabled) {
        this.storeRobustWeightsEnabled = storeRobustWeightsEnabled;
    }

    public boolean isSimulatedTransitsEnabled() {
        return simulatedTransitsEnabled;
    }

    public void setSimulatedTransitsEnabled(boolean simulatedTransitsEnabled) {
        this.simulatedTransitsEnabled = simulatedTransitsEnabled;
    }

    public boolean isExternalTcesEnabled() {
        return externalTcesEnabled;
    }

    public void setExternalTcesEnabled(boolean externalTcesEnabled) {
        this.externalTcesEnabled = externalTcesEnabled;
    }

    public float getBoundedBoxWidth() {
        return boundedBoxWidth;
    }

    public void setBoundedBoxWidth(float boundedBoxWidth) {
        this.boundedBoxWidth = boundedBoxWidth;
    }

    public int getPlanetCount() {
        return planetCount;
    }

    public void setPlanetCount(int planetCount) {
        this.planetCount = planetCount;
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

    public int getCcdRow() {
        return ccdRow;
    }

    public void setCcdRow(int ccdRow) {
        this.ccdRow = ccdRow;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public void setCcdColumn(int ccdColumn) {
        this.ccdColumn = ccdColumn;
    }

    public int getQuarter() {
        return quarter;
    }

    public void setQuarter(int quarter) {
        this.quarter = quarter;
    }

    public int getNumberOfTransits() {
        return numberOfTransits;
    }

    public void setNumberOfTransits(int numberOfTransits) {
        this.numberOfTransits = numberOfTransits;
    }

    public int getNumberOfCadencesInTransit() {
        return numberOfCadencesInTransit;
    }

    public void setNumberOfCadencesInTransit(int numberOfCadencesInTransit) {
        this.numberOfCadencesInTransit = numberOfCadencesInTransit;
    }

    public int getNumberOfCadenceGapsInTransit() {
        return numberOfCadenceGapsInTransit;
    }

    public void setNumberOfCadenceGapsInTransit(int numberOfCadenceGapsInTransit) {
        this.numberOfCadenceGapsInTransit = numberOfCadenceGapsInTransit;
    }

    public int getNumberOfCadencesOutOfTransit() {
        return numberOfCadencesOutOfTransit;
    }

    public void setNumberOfCadencesOutOfTransit(int numberOfCadencesOutOfTransit) {
        this.numberOfCadencesOutOfTransit = numberOfCadencesOutOfTransit;
    }

    public int getNumberOfCadenceGapsOutOfTransit() {
        return numberOfCadenceGapsOutOfTransit;
    }

    public void setNumberOfCadenceGapsOutOfTransit(
        int numberOfCadenceGapsOutOfTransit) {
        this.numberOfCadenceGapsOutOfTransit = numberOfCadenceGapsOutOfTransit;
    }

    public boolean isOverlappedTransits() {
        return overlappedTransits;
    }

    public void setOverlappedTransits(boolean overlappedTransits) {
        this.overlappedTransits = overlappedTransits;
    }

    public boolean isGenerateAlerts() {
        return generateAlerts;
    }

    public void setGenerateAlerts(boolean generateAlerts) {
        this.generateAlerts = generateAlerts;
    }

    public boolean isSerializeInputs() {
        return serializeInputs;
    }

    public void setSerializeInputs(boolean serializeInputs) {
        this.serializeInputs = serializeInputs;
    }

    public boolean isSerializeOutputs() {
        return serializeOutputs;
    }

    public void setSerializeOutputs(boolean serializeOutputs) {
        this.serializeOutputs = serializeOutputs;
    }

    public boolean isValidateInputs() {
        return validateInputs;
    }

    public void setValidateInputs(boolean validateInputs) {
        this.validateInputs = validateInputs;
    }

    public boolean isValidateOutputs() {
        return validateOutputs;
    }

    public void setValidateOutputs(boolean validateOutputs) {
        this.validateOutputs = validateOutputs;
    }

    public boolean isPrfCentroidsEnabled() {
        return prfCentroidsEnabled;
    }

    public void setPrfCentroidsEnabled(boolean prfCentroidsEnabled) {
        this.prfCentroidsEnabled = prfCentroidsEnabled;
    }

    public boolean isKoiMatchingEnabled() {
        return koiMatchingEnabled;
    }

    public void setKoiMatchingEnabled(boolean koiMatchingEnabled) {
        this.koiMatchingEnabled = koiMatchingEnabled;
    }

}
