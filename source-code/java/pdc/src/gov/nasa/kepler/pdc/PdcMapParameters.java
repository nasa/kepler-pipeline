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

package gov.nasa.kepler.pdc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;

/**
 * 
 * @author Forrest Girouard
 */
public class PdcMapParameters implements Parameters, Persistable {

    private int[] coarseDetrendPolyOrder = ArrayUtils.EMPTY_INT_ARRAY;
    private boolean[] debugRun = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] denoiseBasisVectorsEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] ditherFlux = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] ditherMagnitude = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] entropyCleaningCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] entropyCleaningEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] entropyMadFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int[] entropyMaxIterations = ArrayUtils.EMPTY_INT_ARRAY;
    private String[] fitNormalizationMethod = ArrayUtils.EMPTY_STRING_ARRAY;
    private boolean[] forceRobustFit = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] fractionOfStarsToUseForPriorPdf = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] fractionOfStarsToUseForSvd = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] goodnessMetricIterationsCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] goodnessMetricIterationsEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] goodnessMetricIterationsPriorWeightStepSize = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int[] goodnessMetricMaxIterations = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] maxNumMaximizerIteration = ArrayUtils.EMPTY_INT_ARRAY;
    private float[] maxTolerance = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] minFractionOfTargetsForSvd = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int[] numPointsForMaximizerFirstGuess = ArrayUtils.EMPTY_INT_ARRAY;
    private float[] priorCentroidMotionScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorDecScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorEffTempScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorGoodnessPowerFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorGoodnessScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorKeplerMagnitudeScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorLogRadiusScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorPdfGoodnessGain = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorPdfGoodnessWeight = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorPdfVariabilityWeight = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorRaScalingFactor = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorWeightGoodnessCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] priorWeightVariabilityCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] quickMapEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] quickMapVariabilityCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int[] randomStreamSeed = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] spikeBasisVectorWindow = ArrayUtils.EMPTY_INT_ARRAY;
    private boolean[] spikeIsolationEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private int[] svdMaxOrder = ArrayUtils.EMPTY_INT_ARRAY;
    private String[] svdNormalizationMethod = ArrayUtils.EMPTY_STRING_ARRAY;
    private int[] svdOrder = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] svdOrderForReducedRobustFit = ArrayUtils.EMPTY_INT_ARRAY;
    private float[] svdSnrCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] useBasisVectorsAndPriorsFromBlob = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] useBasisVectorsAndPriorsFromPixels = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] useBasisVectorsFromBlob = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] useCentroidPriors = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] useOnlyQuietStarsForPriorPdf = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] useOnlyQuietStarsForSvd = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] variabilityCutoff = ArrayUtils.EMPTY_FLOAT_ARRAY;

    public int[] getCoarseDetrendPolyOrder() {
        return coarseDetrendPolyOrder;
    }

    public void setCoarseDetrendPolyOrder(int[] coarseDetrendPolyOrder) {
        this.coarseDetrendPolyOrder = coarseDetrendPolyOrder;
    }

    public boolean[] getDebugRun() {
        return debugRun;
    }

    public void setDebugRun(boolean[] debugRun) {
        this.debugRun = debugRun;
    }

    public boolean[] getDenoiseBasisVectorsEnabled() {
        return denoiseBasisVectorsEnabled;
    }

    public void setDenoiseBasisVectorsEnabled(boolean[] denoiseBasisVectorsEnabled) {
        this.denoiseBasisVectorsEnabled = denoiseBasisVectorsEnabled;
    }

    public boolean[] getDitherFlux() {
        return ditherFlux;
    }

    public void setDitherFlux(boolean[] ditherFlux) {
        this.ditherFlux = ditherFlux;
    }

    public float[] getDitherMagnitude() {
        return ditherMagnitude;
    }

    public void setDitherMagnitude(float[] ditherMagnitude) {
        this.ditherMagnitude = ditherMagnitude;
    }

    public float[] getEntropyCleaningCutoff() {
        return entropyCleaningCutoff;
    }

    public void setEntropyCleaningCutoff(float[] entropyCleaningCutoff) {
        this.entropyCleaningCutoff = entropyCleaningCutoff;
    }

    public boolean[] getEntropyCleaningEnabled() {
        return entropyCleaningEnabled;
    }

    public void setEntropyCleaningEnabled(boolean[] entropyCleaningEnabled) {
        this.entropyCleaningEnabled = entropyCleaningEnabled;
    }

    public float[] getEntropyMadFactor() {
        return entropyMadFactor;
    }

    public void setEntropyMadFactor(float[] entropyMadFactor) {
        this.entropyMadFactor = entropyMadFactor;
    }

    public int[] getEntropyMaxIterations() {
        return entropyMaxIterations;
    }

    public void setEntropyMaxIterations(int[] entropyMaxIterations) {
        this.entropyMaxIterations = entropyMaxIterations;
    }

    public String[] getFitNormalizationMethod() {
        return fitNormalizationMethod;
    }

    public void setFitNormalizationMethod(String[] fitNormalizationMethod) {
        this.fitNormalizationMethod = fitNormalizationMethod;
    }

    public boolean[] getForceRobustFit() {
        return forceRobustFit;
    }

    public void setForceRobustFit(boolean[] forceRobustFit) {
        this.forceRobustFit = forceRobustFit;
    }

    public float[] getFractionOfStarsToUseForPriorPdf() {
        return fractionOfStarsToUseForPriorPdf;
    }

    public void setFractionOfStarsToUseForPriorPdf(
        float[] fractionOfStarsToUseForPriorPdf) {
        this.fractionOfStarsToUseForPriorPdf = fractionOfStarsToUseForPriorPdf;
    }

    public float[] getFractionOfStarsToUseForSvd() {
        return fractionOfStarsToUseForSvd;
    }

    public void setFractionOfStarsToUseForSvd(float[] fractionOfStarsToUseForSvd) {
        this.fractionOfStarsToUseForSvd = fractionOfStarsToUseForSvd;
    }

    public float[] getGoodnessMetricIterationsCutoff() {
        return goodnessMetricIterationsCutoff;
    }

    public void setGoodnessMetricIterationsCutoff(
        float[] goodnessMetricIterationsCutoff) {
        this.goodnessMetricIterationsCutoff = goodnessMetricIterationsCutoff;
    }

    public boolean[] getGoodnessMetricIterationsEnabled() {
        return goodnessMetricIterationsEnabled;
    }

    public void setGoodnessMetricIterationsEnabled(
        boolean[] goodnessMetricIterationsEnabled) {
        this.goodnessMetricIterationsEnabled = goodnessMetricIterationsEnabled;
    }

    public float[] getGoodnessMetricIterationsPriorWeightStepSize() {
        return goodnessMetricIterationsPriorWeightStepSize;
    }

    public void setGoodnessMetricIterationsPriorWeightStepSize(
        float[] goodnessMetricIterationsPriorWeightStepSize) {
        this.goodnessMetricIterationsPriorWeightStepSize = goodnessMetricIterationsPriorWeightStepSize;
    }

    public int[] getGoodnessMetricMaxIterations() {
        return goodnessMetricMaxIterations;
    }

    public void setGoodnessMetricMaxIterations(int[] goodnessMetricMaxIterations) {
        this.goodnessMetricMaxIterations = goodnessMetricMaxIterations;
    }

    public int[] getMaxNumMaximizerIteration() {
        return maxNumMaximizerIteration;
    }

    public void setMaxNumMaximizerIteration(int[] maxNumMaximizerIteration) {
        this.maxNumMaximizerIteration = maxNumMaximizerIteration;
    }

    public float[] getMaxTolerance() {
        return maxTolerance;
    }

    public void setMaxTolerance(float[] maxTolerance) {
        this.maxTolerance = maxTolerance;
    }

    public float[] getMinFractionOfTargetsForSvd() {
        return minFractionOfTargetsForSvd;
    }

    public void setMinFractionOfTargetsForSvd(float[] minFractionOfTargetsForSvd) {
        this.minFractionOfTargetsForSvd = minFractionOfTargetsForSvd;
    }

    public int[] getNumPointsForMaximizerFirstGuess() {
        return numPointsForMaximizerFirstGuess;
    }

    public void setNumPointsForMaximizerFirstGuess(
        int[] numPointsForMaximizerFirstGuess) {
        this.numPointsForMaximizerFirstGuess = numPointsForMaximizerFirstGuess;
    }

    public float[] getPriorCentroidMotionScalingFactor() {
        return priorCentroidMotionScalingFactor;
    }

    public void setPriorCentroidMotionScalingFactor(
        float[] priorCentroidMotionScalingFactor) {
        this.priorCentroidMotionScalingFactor = priorCentroidMotionScalingFactor;
    }

    public float[] getPriorDecScalingFactor() {
        return priorDecScalingFactor;
    }

    public void setPriorDecScalingFactor(float[] priorDecScalingFactor) {
        this.priorDecScalingFactor = priorDecScalingFactor;
    }

    public float[] getPriorEffTempScalingFactor() {
        return priorEffTempScalingFactor;
    }

    public void setPriorEffTempScalingFactor(float[] priorEffTempScalingFactor) {
        this.priorEffTempScalingFactor = priorEffTempScalingFactor;
    }

    public float[] getPriorGoodnessPowerFactor() {
        return priorGoodnessPowerFactor;
    }

    public void setPriorGoodnessPowerFactor(float[] priorGoodnessPowerFactor) {
        this.priorGoodnessPowerFactor = priorGoodnessPowerFactor;
    }

    public float[] getPriorGoodnessScalingFactor() {
        return priorGoodnessScalingFactor;
    }

    public void setPriorGoodnessScalingFactor(float[] priorGoodnessScalingFactor) {
        this.priorGoodnessScalingFactor = priorGoodnessScalingFactor;
    }

    public float[] getPriorKeplerMagnitudeScalingFactor() {
        return priorKeplerMagnitudeScalingFactor;
    }

    public void setPriorKeplerMagnitudeScalingFactor(
        float[] priorKeplerMagnitudeScalingFactor) {
        this.priorKeplerMagnitudeScalingFactor = priorKeplerMagnitudeScalingFactor;
    }

    public float[] getPriorLogRadiusScalingFactor() {
        return priorLogRadiusScalingFactor;
    }

    public void setPriorLogRadiusScalingFactor(
        float[] priorLogRadiusScalingFactor) {
        this.priorLogRadiusScalingFactor = priorLogRadiusScalingFactor;
    }

    public float[] getPriorPdfGoodnessGain() {
        return priorPdfGoodnessGain;
    }

    public void setPriorPdfGoodnessGain(float[] priorPdfGoodnessGain) {
        this.priorPdfGoodnessGain = priorPdfGoodnessGain;
    }

    public float[] getPriorPdfGoodnessWeight() {
        return priorPdfGoodnessWeight;
    }

    public void setPriorPdfGoodnessWeight(float[] priorPdfGoodnessWeight) {
        this.priorPdfGoodnessWeight = priorPdfGoodnessWeight;
    }

    public float[] getPriorPdfVariabilityWeight() {
        return priorPdfVariabilityWeight;
    }

    public void setPriorPdfVariabilityWeight(float[] priorPdfVariabilityWeight) {
        this.priorPdfVariabilityWeight = priorPdfVariabilityWeight;
    }

    public float[] getPriorRaScalingFactor() {
        return priorRaScalingFactor;
    }

    public void setPriorRaScalingFactor(float[] priorRaScalingFactor) {
        this.priorRaScalingFactor = priorRaScalingFactor;
    }

    public float[] getPriorWeightGoodnessCutoff() {
        return priorWeightGoodnessCutoff;
    }

    public void setPriorWeightGoodnessCutoff(float[] priorWeightGoodnessCutoff) {
        this.priorWeightGoodnessCutoff = priorWeightGoodnessCutoff;
    }

    public float[] getPriorWeightVariabilityCutoff() {
        return priorWeightVariabilityCutoff;
    }

    public void setPriorWeightVariabilityCutoff(
        float[] priorWeightVariabilityCutoff) {
        this.priorWeightVariabilityCutoff = priorWeightVariabilityCutoff;
    }

    public boolean[] getQuickMapEnabled() {
        return quickMapEnabled;
    }

    public void setQuickMapEnabled(boolean[] quickMapEnabled) {
        this.quickMapEnabled = quickMapEnabled;
    }

    public float[] getQuickMapVariabilityCutoff() {
        return quickMapVariabilityCutoff;
    }

    public void setQuickMapVariabilityCutoff(float[] quickMapVariabilityCutoff) {
        this.quickMapVariabilityCutoff = quickMapVariabilityCutoff;
    }

    public int[] getRandomStreamSeed() {
        return randomStreamSeed;
    }

    public void setRandomStreamSeed(int[] randomStreamSeed) {
        this.randomStreamSeed = randomStreamSeed;
    }

    public int[] getSpikeBasisVectorWindow() {
        return spikeBasisVectorWindow;
    }

    public void setSpikeBasisVectorWindow(int[] spikeBasisVectorWindow) {
        this.spikeBasisVectorWindow = spikeBasisVectorWindow;
    }

    public boolean[] getSpikeIsolationEnabled() {
        return spikeIsolationEnabled;
    }

    public void setSpikeIsolationEnabled(boolean[] spikeIsolationEnabled) {
        this.spikeIsolationEnabled = spikeIsolationEnabled;
    }

    public String[] getSvdNormalizationMethod() {
        return svdNormalizationMethod;
    }

    public void setSvdNormalizationMethod(String[] svdNormalizationMethod) {
        this.svdNormalizationMethod = svdNormalizationMethod;
    }

    public int[] getSvdMaxOrder() {
        return svdMaxOrder;
    }

    public void setSvdMaxOrder(int[] svdMaxOrder) {
        this.svdMaxOrder = svdMaxOrder;
    }

    public int[] getSvdOrder() {
        return svdOrder;
    }

    public void setSvdOrder(int[] svdOrder) {
        this.svdOrder = svdOrder;
    }

    public int[] getSvdOrderForReducedRobustFit() {
        return svdOrderForReducedRobustFit;
    }

    public void setSvdOrderForReducedRobustFit(int[] svdOrderForReducedRobustFit) {
        this.svdOrderForReducedRobustFit = svdOrderForReducedRobustFit;
    }

    public float[] getSvdSnrCutoff() {
        return svdSnrCutoff;
    }

    public void setSvdSnrCutoff(float[] svdSnrCutoff) {
        this.svdSnrCutoff = svdSnrCutoff;
    }

    public boolean[] getUseBasisVectorsAndPriorsFromBlob() {
        return useBasisVectorsAndPriorsFromBlob;
    }

    public void setUseBasisVectorsAndPriorsFromBlob(
        boolean[] useBasisVectorsAndPriorsFromBlob) {
        this.useBasisVectorsAndPriorsFromBlob = useBasisVectorsAndPriorsFromBlob;
    }

    public boolean[] getUseBasisVectorsAndPriorsFromPixels() {
        return useBasisVectorsAndPriorsFromPixels;
    }

    public void setUseBasisVectorsAndPriorsFromPixels(
        boolean[] useBasisVectorsAndPriorsFromPixels) {
        this.useBasisVectorsAndPriorsFromPixels = useBasisVectorsAndPriorsFromPixels;
    }

    public boolean[] getUseBasisVectorsFromBlob() {
        return useBasisVectorsFromBlob;
    }

    public void setUseBasisVectorsFromBlob(boolean[] useBasisVectorsFromBlob) {
        this.useBasisVectorsFromBlob = useBasisVectorsFromBlob;
    }

    public boolean[] getUseCentroidPriors() {
        return useCentroidPriors;
    }

    public void setUseCentroidPriors(boolean[] useCentroidPriors) {
        this.useCentroidPriors = useCentroidPriors;
    }

    public boolean[] getUseOnlyQuietStarsForPriorPdf() {
        return useOnlyQuietStarsForPriorPdf;
    }

    public void setUseOnlyQuietStarsForPriorPdf(
        boolean[] useOnlyQuietStarsForPriorPdf) {
        this.useOnlyQuietStarsForPriorPdf = useOnlyQuietStarsForPriorPdf;
    }

    public boolean[] getUseOnlyQuietStarsForSvd() {
        return useOnlyQuietStarsForSvd;
    }

    public void setUseOnlyQuietStarsForSvd(boolean[] useOnlyQuietStarsForSvd) {
        this.useOnlyQuietStarsForSvd = useOnlyQuietStarsForSvd;
    }

    public float[] getVariabilityCutoff() {
        return variabilityCutoff;
    }

    public void setVariabilityCutoff(float[] variabilityCutoff) {
        this.variabilityCutoff = variabilityCutoff;
    }
}
