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
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Centroid test module parameters.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class CentroidTestParameters implements Persistable, Parameters {

    private boolean centroidModelFineMeshEnabled;
    private int centroidModelFineMeshFactor;
    private float chiSquaredTolerance;
    private String cloudPlotDecMarker = "";
    private String cloudPlotRaMarker = "";
    private int defaultMaxTransitDurationCadences;
    private float foldedTransitDurationsShown;
    private int iterationLimit;
    private float iterativeWhitenerTolerance;
    private float madsToClipForCloudPlot;
    private float maximumSourceRaDecOffsetArcsec;
    private int maximumTransitDurationCadences;
    private int minimumPointsPerPlanet;
    private int padTransitCadences;
    private float plotOutlierThesholdInSigma;
    private float transitDurationFactorForMedianFilter;
    private float transitDurationsMasked;
    private int timeoutPerTargetSeconds;

    public boolean isCentroidModelFineMeshEnabled() {
        return centroidModelFineMeshEnabled;
    }

    public void setCentroidModelFineMeshEnabled(
        boolean centroidModelFineMeshEnabled) {
        this.centroidModelFineMeshEnabled = centroidModelFineMeshEnabled;
    }

    public int getCentroidModelFineMeshFactor() {
        return centroidModelFineMeshFactor;
    }

    public void setCentroidModelFineMeshFactor(int centroidModelFineMeshFactor) {
        this.centroidModelFineMeshFactor = centroidModelFineMeshFactor;
    }

    public float getChiSquaredTolerance() {
        return chiSquaredTolerance;
    }

    public void setChiSquaredTolerance(float chiSquaredTolerance) {
        this.chiSquaredTolerance = chiSquaredTolerance;
    }

    public String getCloudPlotDecMarker() {
        return cloudPlotDecMarker;
    }

    public void setCloudPlotDecMarker(String cloudPlotDecMarker) {
        this.cloudPlotDecMarker = cloudPlotDecMarker;
    }

    public String getCloudPlotRaMarker() {
        return cloudPlotRaMarker;
    }

    public void setCloudPlotRaMarker(String cloudPlotRaMarker) {
        this.cloudPlotRaMarker = cloudPlotRaMarker;
    }

    public int getDefaultMaxTransitDurationCadences() {
        return defaultMaxTransitDurationCadences;
    }

    public void setDefaultMaxTransitDurationCadences(
        int defaultMaxTransitDurationCadences) {
        this.defaultMaxTransitDurationCadences = defaultMaxTransitDurationCadences;
    }

    public float getFoldedTransitDurationsShown() {
        return foldedTransitDurationsShown;
    }

    public void setFoldedTransitDurationsShown(float foldedTransitDurationsShown) {
        this.foldedTransitDurationsShown = foldedTransitDurationsShown;
    }

    public int getIterationLimit() {
        return iterationLimit;
    }

    public void setIterationLimit(int iterationLimit) {
        this.iterationLimit = iterationLimit;
    }

    public float getIterativeWhitenerTolerance() {
        return iterativeWhitenerTolerance;
    }

    public void setIterativeWhitenerTolerance(float iterativeWhitenerTolerance) {
        this.iterativeWhitenerTolerance = iterativeWhitenerTolerance;
    }

    public float getMadsToClipForCloudPlot() {
        return madsToClipForCloudPlot;
    }

    public void setMadsToClipForCloudPlot(float madsToClipForCloudPlot) {
        this.madsToClipForCloudPlot = madsToClipForCloudPlot;
    }

    public float getMaximumSourceRaDecOffsetArcsec() {
        return maximumSourceRaDecOffsetArcsec;
    }

    public void setMaximumSourceRaDecOffsetArcsec(
        float maximumSourceRaDecOffsetArcsec) {
        this.maximumSourceRaDecOffsetArcsec = maximumSourceRaDecOffsetArcsec;
    }

    public int getMaximumTransitDurationCadences() {
        return maximumTransitDurationCadences;
    }

    public void setMaximumTransitDurationCadences(
        int maximumTransitDurationCadences) {
        this.maximumTransitDurationCadences = maximumTransitDurationCadences;
    }

    public int getMinimumPointsPerPlanet() {
        return minimumPointsPerPlanet;
    }

    public void setMinimumPointsPerPlanet(int minimumPointsPerPlanet) {
        this.minimumPointsPerPlanet = minimumPointsPerPlanet;
    }

    public int getPadTransitCadences() {
        return padTransitCadences;
    }

    public void setPadTransitCadences(int padTransitCadences) {
        this.padTransitCadences = padTransitCadences;
    }

    public float getPlotOutlierThesholdInSigma() {
        return plotOutlierThesholdInSigma;
    }

    public void setPlotOutlierThesholdInSigma(float plotOutlierThesholdInSigma) {
        this.plotOutlierThesholdInSigma = plotOutlierThesholdInSigma;
    }

    public float getTransitDurationFactorForMedianFilter() {
        return transitDurationFactorForMedianFilter;
    }

    public void setTransitDurationFactorForMedianFilter(
        float transitDurationFactorForMedianFilter) {
        this.transitDurationFactorForMedianFilter = transitDurationFactorForMedianFilter;
    }

    public float getTransitDurationsMasked() {
        return transitDurationsMasked;
    }

    public void setTransitDurationsMasked(float transitDurationsMasked) {
        this.transitDurationsMasked = transitDurationsMasked;
    }
    
    public int getTimeoutPerTargetSeconds() {
        return timeoutPerTargetSeconds;
    }
    
    public void setTimeoutPerTargetSeconds(int timeoutPerTargetSeconds) {
        this.timeoutPerTargetSeconds = timeoutPerTargetSeconds;
    }
}
