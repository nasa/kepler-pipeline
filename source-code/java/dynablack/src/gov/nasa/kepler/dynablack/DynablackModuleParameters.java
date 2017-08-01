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

package gov.nasa.kepler.dynablack;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;

/**
 * Parameters for the {@link DynablackPipelineModule}.
 * 
 * @author Miles Cote
 */
public class DynablackModuleParameters implements Persistable, Parameters {

    private String[] ancillaryEngineeringMnemonics = ArrayUtils.EMPTY_STRING_ARRAY;
    private String[] rawFfiFileTimestamps = ArrayUtils.EMPTY_STRING_ARRAY;
    private double pixelBrightnessThreshold;
    private int minimumColumnForExcludingTrailingBlackRow;
    private boolean reverseClockedEnabled;
    private boolean removeFixedOffset;
    private boolean removeStatic2DBlack;
    private float blackResidualsThresholdDnPerRead;

    private String dynablackBlobFilename = StringUtils.EMPTY;
    private int cadenceGapThreshold;
    private boolean includeStepsInModel;
    private int maxA1CoeffCount;
    private int maxA2CoeffCount;
    private int maxB1CoeffCount;
    private int numModelTypes;
    private int numB1PredictorCoeffs;

    private int[] parallelPixelSelect = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] a2ParallelPixelSelect = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] framePixelSelect = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] a2FramePixelSelect = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] leadingColumnSelect = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] a2LeadingColumnSelect = ArrayUtils.EMPTY_INT_ARRAY;
    private int thermalRowOffset;
    private int defaultRowTimeConstant;
    private int minUndershootRow;
    private int maxUndershootRow;
    private int undershootSpan0;
    private int undershootSpan;
    private int scDPixThreshold;
    private int blurPix;
    private int nearTbMinpix;

    private int[] leadingArp = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] trailingArp = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] trailingArpUs = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] trailingCollat = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] neartrailingArp = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] trailingFfi = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] rclcTarg = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] trailingMaskedSmear = ArrayUtils.EMPTY_INT_ARRAY;
    private int[] leadingMaskedSmear = ArrayUtils.EMPTY_INT_ARRAY;

    private int a1NumPredictorRows;
    private int a1NumNonlinearPredictorRows;
    private int a1NumFfiPredictorRows;
    private boolean a2SkipDiff;
    private int a2ColumnPredictorCount;
    private int a2LeadColumnPredictorCount;
    private int a2SmearPredictorCount;
    private int[] a2SolRange = ArrayUtils.EMPTY_INT_ARRAY;
    private int a2SolStart;

    private float blackResidualsStdDevThresholdDnPerRead;
    private int numBlackPixelsAboveThreshold;

    public DynablackModuleParameters() {
    }

    public String[] getAncillaryEngineeringMnemonics() {
        return ancillaryEngineeringMnemonics;
    }

    public void setAncillaryEngineeringMnemonics(
        String[] ancillaryEngineeringMnemonics) {
        this.ancillaryEngineeringMnemonics = ancillaryEngineeringMnemonics;
    }

    public String[] getRawFfiFileTimestamps() {
        return rawFfiFileTimestamps;
    }

    public void setRawFfiFileTimestamps(String[] rawFfiFileTimestamps) {
        this.rawFfiFileTimestamps = rawFfiFileTimestamps;
    }

    public double getPixelBrightnessThreshold() {
        return pixelBrightnessThreshold;
    }

    public void setPixelBrightnessThreshold(double pixelBrightnessThreshold) {
        this.pixelBrightnessThreshold = pixelBrightnessThreshold;
    }

    public int getMinimumColumnForExcludingTrailingBlackRow() {
        return minimumColumnForExcludingTrailingBlackRow;
    }

    public void setMinimumColumnForExcludingTrailingBlackRow(
        int minimumColumnForExcludingTrailingBlackRow) {
        this.minimumColumnForExcludingTrailingBlackRow = minimumColumnForExcludingTrailingBlackRow;
    }

    public boolean isReverseClockedEnabled() {
        return reverseClockedEnabled;
    }

    public void setReverseClockedEnabled(boolean reverseClockedEnabled) {
        this.reverseClockedEnabled = reverseClockedEnabled;
    }

    public boolean isRemoveFixedOffset() {
        return removeFixedOffset;
    }

    public void setRemoveFixedOffset(boolean removeFixedOffset) {
        this.removeFixedOffset = removeFixedOffset;
    }

    public boolean isRemoveStatic2DBlack() {
        return removeStatic2DBlack;
    }

    public void setRemoveStatic2DBlack(boolean removeStatic2DBlack) {
        this.removeStatic2DBlack = removeStatic2DBlack;
    }

    public float getBlackResidualsThresholdDnPerRead() {
        return blackResidualsThresholdDnPerRead;
    }

    public void setBlackResidualsThresholdDnPerRead(
        float blackResidualsThresholdDnPerRead) {
        this.blackResidualsThresholdDnPerRead = blackResidualsThresholdDnPerRead;
    }

    public String getDynablackBlobFilename() {
        return dynablackBlobFilename;
    }

    public void setDynablackBlobFilename(String dynablackBlobFilename) {
        this.dynablackBlobFilename = dynablackBlobFilename;
    }

    public int getCadenceGapThreshold() {
        return cadenceGapThreshold;
    }

    public void setCadenceGapThreshold(int cadenceGapThreshold) {
        this.cadenceGapThreshold = cadenceGapThreshold;
    }

    public boolean isIncludeStepsInModel() {
        return includeStepsInModel;
    }

    public void setIncludeStepsInModel(boolean includeStepsInModel) {
        this.includeStepsInModel = includeStepsInModel;
    }

    public int getMaxA1CoeffCount() {
        return maxA1CoeffCount;
    }

    public void setMaxA1CoeffCount(int maxA1CoeffCount) {
        this.maxA1CoeffCount = maxA1CoeffCount;
    }

    public int getMaxA2CoeffCount() {
        return maxA2CoeffCount;
    }

    public void setMaxA2CoeffCount(int maxA2CoeffCount) {
        this.maxA2CoeffCount = maxA2CoeffCount;
    }

    public int getMaxB1CoeffCount() {
        return maxB1CoeffCount;
    }

    public void setMaxB1CoeffCount(int maxB1CoeffCount) {
        this.maxB1CoeffCount = maxB1CoeffCount;
    }

    public int getNumModelTypes() {
        return numModelTypes;
    }

    public void setNumModelTypes(int numModelTypes) {
        this.numModelTypes = numModelTypes;
    }

    public int getNumB1PredictorCoeffs() {
        return numB1PredictorCoeffs;
    }

    public void setNumB1PredictorCoeffs(int numB1PredictorCoeffs) {
        this.numB1PredictorCoeffs = numB1PredictorCoeffs;
    }

    public int[] getParallelPixelSelect() {
        return parallelPixelSelect;
    }

    public void setParallelPixelSelect(int[] parallelPixelSelect) {
        this.parallelPixelSelect = parallelPixelSelect;
    }

    public int[] getA2ParallelPixelSelect() {
        return a2ParallelPixelSelect;
    }

    public void setA2ParallelPixelSelect(int[] a2ParallelPixelSelect) {
        this.a2ParallelPixelSelect = a2ParallelPixelSelect;
    }

    public int[] getFramePixelSelect() {
        return framePixelSelect;
    }

    public void setFramePixelSelect(int[] framePixelSelect) {
        this.framePixelSelect = framePixelSelect;
    }

    public int[] getA2FramePixelSelect() {
        return a2FramePixelSelect;
    }

    public void setA2FramePixelSelect(int[] a2FramePixelSelect) {
        this.a2FramePixelSelect = a2FramePixelSelect;
    }

    public int[] getLeadingColumnSelect() {
        return leadingColumnSelect;
    }

    public void setLeadingColumnSelect(int[] leadingColumnSelect) {
        this.leadingColumnSelect = leadingColumnSelect;
    }

    public int[] getA2LeadingColumnSelect() {
        return a2LeadingColumnSelect;
    }

    public void setA2LeadingColumnSelect(int[] a2LeadingColumnSelect) {
        this.a2LeadingColumnSelect = a2LeadingColumnSelect;
    }

    public int getThermalRowOffset() {
        return thermalRowOffset;
    }

    public void setThermalRowOffset(int thermalRowOffset) {
        this.thermalRowOffset = thermalRowOffset;
    }

    public int getDefaultRowTimeConstant() {
        return defaultRowTimeConstant;
    }

    public void setDefaultRowTimeConstant(int defaultRowTimeConstant) {
        this.defaultRowTimeConstant = defaultRowTimeConstant;
    }

    public int getMinUndershootRow() {
        return minUndershootRow;
    }

    public void setMinUndershootRow(int minUndershootRow) {
        this.minUndershootRow = minUndershootRow;
    }

    public int getMaxUndershootRow() {
        return maxUndershootRow;
    }

    public void setMaxUndershootRow(int maxUndershootRow) {
        this.maxUndershootRow = maxUndershootRow;
    }

    public int getUndershootSpan0() {
        return undershootSpan0;
    }

    public void setUndershootSpan0(int undershootSpan0) {
        this.undershootSpan0 = undershootSpan0;
    }

    public int getUndershootSpan() {
        return undershootSpan;
    }

    public void setUndershootSpan(int undershootSpan) {
        this.undershootSpan = undershootSpan;
    }

    public int getScDPixThreshold() {
        return scDPixThreshold;
    }

    public void setScDPixThreshold(int scDPixThreshold) {
        this.scDPixThreshold = scDPixThreshold;
    }

    public int getBlurPix() {
        return blurPix;
    }

    public void setBlurPix(int blurPix) {
        this.blurPix = blurPix;
    }

    public int getNearTbMinpix() {
        return nearTbMinpix;
    }

    public void setNearTbMinpix(int nearTbMinpix) {
        this.nearTbMinpix = nearTbMinpix;
    }

    public int[] getLeadingArp() {
        return leadingArp;
    }

    public void setLeadingArp(int[] leadingArp) {
        this.leadingArp = leadingArp;
    }

    public int[] getTrailingArp() {
        return trailingArp;
    }

    public void setTrailingArp(int[] trailingArp) {
        this.trailingArp = trailingArp;
    }

    public int[] getTrailingArpUs() {
        return trailingArpUs;
    }

    public void setTrailingArpUs(int[] trailingArpUs) {
        this.trailingArpUs = trailingArpUs;
    }

    public int[] getTrailingCollat() {
        return trailingCollat;
    }

    public void setTrailingCollat(int[] trailingCollat) {
        this.trailingCollat = trailingCollat;
    }

    public int[] getNeartrailingArp() {
        return neartrailingArp;
    }

    public void setNeartrailingArp(int[] neartrailingArp) {
        this.neartrailingArp = neartrailingArp;
    }

    public int[] getTrailingFfi() {
        return trailingFfi;
    }

    public void setTrailingFfi(int[] trailingFfi) {
        this.trailingFfi = trailingFfi;
    }

    public int[] getRclcTarg() {
        return rclcTarg;
    }

    public void setRclcTarg(int[] rclcTarg) {
        this.rclcTarg = rclcTarg;
    }

    public int[] getTrailingMaskedSmear() {
        return trailingMaskedSmear;
    }

    public void setTrailingMaskedSmear(int[] trailingMaskedSmear) {
        this.trailingMaskedSmear = trailingMaskedSmear;
    }

    public int[] getLeadingMaskedSmear() {
        return leadingMaskedSmear;
    }

    public void setLeadingMaskedSmear(int[] leadingMaskedSmear) {
        this.leadingMaskedSmear = leadingMaskedSmear;
    }

    public int getA1NumPredictorRows() {
        return a1NumPredictorRows;
    }

    public void setA1NumPredictorRows(int a1NumPredictorRows) {
        this.a1NumPredictorRows = a1NumPredictorRows;
    }

    public int getA1NumNonlinearPredictorRows() {
        return a1NumNonlinearPredictorRows;
    }

    public void setA1NumNonlinearPredictorRows(int a1NumNonlinearPredictorRows) {
        this.a1NumNonlinearPredictorRows = a1NumNonlinearPredictorRows;
    }

    public int getA1NumFfiPredictorRows() {
        return a1NumFfiPredictorRows;
    }

    public void setA1NumFfiPredictorRows(int a1NumFfiPredictorRows) {
        this.a1NumFfiPredictorRows = a1NumFfiPredictorRows;
    }

    public boolean isA2SkipDiff() {
        return a2SkipDiff;
    }

    public void setA2SkipDiff(boolean a2SkipDiff) {
        this.a2SkipDiff = a2SkipDiff;
    }

    public int getA2ColumnPredictorCount() {
        return a2ColumnPredictorCount;
    }

    public void setA2ColumnPredictorCount(int a2ColumnPredictorCount) {
        this.a2ColumnPredictorCount = a2ColumnPredictorCount;
    }

    public int getA2LeadColumnPredictorCount() {
        return a2LeadColumnPredictorCount;
    }

    public void setA2LeadColumnPredictorCount(int a2LeadColumnPredictorCount) {
        this.a2LeadColumnPredictorCount = a2LeadColumnPredictorCount;
    }

    public int getA2SmearPredictorCount() {
        return a2SmearPredictorCount;
    }

    public void setA2SmearPredictorCount(int a2SmearPredictorCount) {
        this.a2SmearPredictorCount = a2SmearPredictorCount;
    }

    public int[] getA2SolRange() {
        return a2SolRange;
    }

    public void setA2SolRange(int[] a2SolRange) {
        this.a2SolRange = a2SolRange;
    }

    public int getA2SolStart() {
        return a2SolStart;
    }

    public void setA2SolStart(int a2SolStart) {
        this.a2SolStart = a2SolStart;
    }

    public float getBlackResidualsStdDevThresholdDnPerRead() {
        return blackResidualsStdDevThresholdDnPerRead;
    }

    public void setBlackResidualsStdDevThresholdDnPerRead(
        float blackResidualsStdDevThresholdDnPerRead) {
        this.blackResidualsStdDevThresholdDnPerRead = blackResidualsStdDevThresholdDnPerRead;
    }

    public int getNumBlackPixelsAboveThreshold() {
        return numBlackPixelsAboveThreshold;
    }

    public void setNumBlackPixelsAboveThreshold(int numBlackPixelsAboveThreshold) {
        this.numBlackPixelsAboveThreshold = numBlackPixelsAboveThreshold;
    }

}
