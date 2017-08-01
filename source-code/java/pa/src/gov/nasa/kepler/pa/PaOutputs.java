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

package gov.nasa.kepler.pa;

import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.pa.PaCosmicRayMetrics;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Photometric Analysis (PA) pipeline module interface outputs.
 * 
 * @author Forrest Girouard
 * 
 */
public class PaOutputs implements Persistable {

    /**
     * CCD module.
     */
    private int ccdModule;

    /**
     * CCD output.
     */
    private int ccdOutput;

    /**
     * Type of cadence ('LONG' or 'SHORT').
     */
    private String cadenceType = "";

    /**
     * Start cadence (inclusive).
     */
    private int startCadence;

    /**
     * End cadence (inclusive).
     */
    private int endCadence;

    /**
     * Processing state for this task.
     */
    private String processingState = "";

    /**
     * Indices with identified Argabrightening.
     */
    private int[] argabrighteningIndices = ArrayUtils.EMPTY_INT_ARRAY;

    /**
     * Indices with identified reaction-wheel zero crossing events.
     */
    private int[] reactionWheelZeroCrossingIndices = ArrayUtils.EMPTY_INT_ARRAY;

    /**
     * Target flux time series.
     */
    private List<PaFluxTarget> targetStarResultsStruct = new ArrayList<PaFluxTarget>();

    /**
     * Identified background cosmic ray events.
     */
    private List<PaPixelCosmicRay> backgroundCosmicRayEvents = new ArrayList<PaPixelCosmicRay>();

    /**
     * Identified target star cosmic ray events.
     */
    private List<PaPixelCosmicRay> targetStarCosmicRayEvents = new ArrayList<PaPixelCosmicRay>();

    /**
     * The values in this time series are true if any thruster definitely fired
     * during the cadence; otherwise false.
     */
    private boolean[] definiteThrusterActivityIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    /**
     * The values in this time series are true if any thruster may have fired
     * during the cadence; otherwise false.
     */
    private boolean[] possibleThrusterActivityIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    
    /**
     * Background cosmic ray metrics.
     */
    private PaCosmicRayMetrics backgroundCosmicRayMetrics = new PaCosmicRayMetrics();

    /**
     * Target start cosmic ray metrics.
     */
    private PaCosmicRayMetrics targetStarCosmicRayMetrics = new PaCosmicRayMetrics();

    /**
     * Encircled energy metric time series.
     */
    private CompoundFloatTimeSeries encircledEnergyMetrics = new CompoundFloatTimeSeries();

    /**
     * Brightness metric time series.
     */
    private CompoundFloatTimeSeries brightnessMetrics = new CompoundFloatTimeSeries();

    /**
     * Name of local file containing background coefficients.
     */
    private String backgroundBlobFileName = "";

    /**
     * Name of local file containing motion polynomials.
     */
    private String motionBlobFileName = "";

    /**
     * Name of local file containing output primitives and transformations.
     */
    private String uncertaintyBlobFileName = "";

    /**
     * Alerts for the operator.
     */
    private List<ModuleAlert> alerts = new ArrayList<ModuleAlert>();

    @Override
    public String toString() {
        return "PaOutputs [ccdModule=" + ccdModule + ", ccdOutput=" + ccdOutput
            + ", cadenceType=" + cadenceType + ", startCadence=" + startCadence
            + ", endCadence=" + endCadence + ", processingState="
            + processingState + ", argabrighteningIndices="
            + Arrays.toString(argabrighteningIndices)
            + ", reactionWheelZeroCrossingIndices="
            + Arrays.toString(reactionWheelZeroCrossingIndices)
            + ", targetStarResultsStruct=" + targetStarResultsStruct
            + ", backgroundCosmicRayEvents=" + backgroundCosmicRayEvents
            + ", targetStarCosmicRayEvents=" + targetStarCosmicRayEvents
            + ", backgroundCosmicRayMetrics=" + backgroundCosmicRayMetrics
            + ", targetStarCosmicRayMetrics=" + targetStarCosmicRayMetrics
            + ", encircledEnergyMetrics=" + encircledEnergyMetrics
            + ", brightnessMetrics=" + brightnessMetrics
            + ", backgroundBlobFileName=" + backgroundBlobFileName
            + ", motionBlobFileName=" + motionBlobFileName
            + ", uncertaintyBlobFileName=" + uncertaintyBlobFileName
            + ", alerts=" + alerts + "]";
    }

    public List<ModuleAlert> getAlerts() {
        return alerts;
    }

    public void setAlerts(final List<ModuleAlert> alerts) {
        this.alerts = alerts;
    }

    public int[] getArgabrighteningIndices() {
        return argabrighteningIndices;
    }

    public void setArgabrighteningIndices(int[] argabrighteningIndices) {
        this.argabrighteningIndices = argabrighteningIndices;
    }

    public String getBackgroundBlobFileName() {
        return backgroundBlobFileName;
    }

    public void setBackgroundBlobFileName(final String backgroundBlobFileName) {
        this.backgroundBlobFileName = backgroundBlobFileName;
    }

    public List<PaPixelCosmicRay> getBackgroundCosmicRayEvents() {
        return backgroundCosmicRayEvents;
    }

    public void setBackgroundCosmicRayEvents(
        final List<PaPixelCosmicRay> backgroundCosmicRayEvents) {
        this.backgroundCosmicRayEvents = backgroundCosmicRayEvents;
    }

    public PaCosmicRayMetrics getBackgroundCosmicRayMetrics() {
        return backgroundCosmicRayMetrics;
    }

    public void setBackgroundCosmicRayMetrics(
        final PaCosmicRayMetrics backgroundCosmicRayMetrics) {
        this.backgroundCosmicRayMetrics = backgroundCosmicRayMetrics;
    }

    public String getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(final String cadenceType) {
        this.cadenceType = cadenceType;
    }

    public CompoundFloatTimeSeries getBrightnessMetrics() {
        return brightnessMetrics;
    }

    public void setBrightnessMetrics(
        final CompoundFloatTimeSeries brightnessMetrics) {
        this.brightnessMetrics = brightnessMetrics;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(final int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(final int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public CompoundFloatTimeSeries getEncircledEnergyMetrics() {
        return encircledEnergyMetrics;
    }

    public void setEncircledEnergyMetrics(
        final CompoundFloatTimeSeries encircledEnergyMetrics) {
        this.encircledEnergyMetrics = encircledEnergyMetrics;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(final int endCadence) {
        this.endCadence = endCadence;
    }

    public List<PaFluxTarget> getFluxTargets() {
        return targetStarResultsStruct;
    }

    public void setFluxTargets(final List<PaFluxTarget> fluxTargets) {
        targetStarResultsStruct = fluxTargets;
    }

    public String getMotionBlobFileName() {
        return motionBlobFileName;
    }

    public void setMotionBlobFileName(final String motionBlobFileName) {
        this.motionBlobFileName = motionBlobFileName;
    }

    public String getProcessingState() {
        return processingState;
    }

    public void setProcessingState(String processingState) {
        this.processingState = processingState;
    }

    public int[] getReactionWheelZeroCrossingIndices() {
        return reactionWheelZeroCrossingIndices;
    }

    public void setReactionWheelZeroCrossingIndices(
        int[] reactionWheelZeroCrossingIndices) {
        this.reactionWheelZeroCrossingIndices = reactionWheelZeroCrossingIndices;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(final int startCadence) {
        this.startCadence = startCadence;
    }

    public List<PaPixelCosmicRay> getTargetStarCosmicRayEvents() {
        return targetStarCosmicRayEvents;
    }

    public void setTargetStarCosmicRayEvents(
        final List<PaPixelCosmicRay> targetStarCosmicRayEvents) {
        this.targetStarCosmicRayEvents = targetStarCosmicRayEvents;
    }

    public PaCosmicRayMetrics getTargetCosmicRayMetrics() {
        return targetStarCosmicRayMetrics;
    }

    public void setTargetCosmicRayMetrics(
        final PaCosmicRayMetrics targetCosmicRayMetrics) {
        targetStarCosmicRayMetrics = targetCosmicRayMetrics;
    }

    public boolean[] getDefiniteThrusterActivityIndicators() {
        return definiteThrusterActivityIndicators;
    }

    public void setDefiniteThrusterActivityIndicators(
        boolean[] definiteThrusterActivityIndicators) {
        this.definiteThrusterActivityIndicators = definiteThrusterActivityIndicators;
    }

    public boolean[] getPossibleThrusterActivityIndicators() {
        return possibleThrusterActivityIndicators;
    }

    public void setPossibleThrusterActivityIndicators(
        boolean[] possibleThrusterActivityIndicators) {
        this.possibleThrusterActivityIndicators = possibleThrusterActivityIndicators;
    }

    public String getUncertaintyBlobFileName() {
        return uncertaintyBlobFileName;
    }

    public void setUncertaintyBlobFileName(final String uncertaintyBlobFileName) {
        this.uncertaintyBlobFileName = uncertaintyBlobFileName;
    }
}
