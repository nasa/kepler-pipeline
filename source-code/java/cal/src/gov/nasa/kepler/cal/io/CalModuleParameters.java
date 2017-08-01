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

package gov.nasa.kepler.cal.io;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;
import gov.nasa.spiffy.common.pi.Parameters;


/**
 * Module parameters for cal.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * @author Bill Wohler
 */
@ProxyIgnoreStatics
public class CalModuleParameters implements Persistable, Parameters {
    
    public static final int K2_CAMPAIGN_MISSING = -1;
    
    private float stdRatioThreshold;
    
    private int coefficentModelId;
    
    private boolean useRobustVerticalCoeffs;
    
    private boolean useRobustFrameFgsCoeffs;
    
    private boolean useRobustParallelFgsCoeffs;

    /**
     * e.g. "q0:q1,q2:q16,q17"
     */
    private String blackAlgorithmQuarters = "";
    
    /**
     * Use one of several algorithms to compute black values.
     * e.g. "exponentialOneDBlack,dynablack,exponentialOneDBlack"
     */
    private String blackAlgorithm = "";
    
    /** When true this enables cosmic ray correction. [317.CAL.2] */
    private boolean crCorrectionEnabled;
    
    /** When true this enables linearity correction. [1002.CAL.1, 1003.CAL.1]*/
    private boolean linearityCorrectionEnabled;
    
    /**  When true this enables flat field correction. */
    private boolean flatFieldCorrectionEnabled;
    
    /** When true this enables LDE undershoot correction. [CAL2.CAL1]*/
    private boolean undershootEnabled;
    
    private boolean collateralMetricUncertEnabled;
    
    private float madSigmaThresholdForSmearLevels;
    
    private int undershootReverseFitPolyOrder;
    private int undershootReverseFitWindow;
    
    private int polyOrderMax;
    
    private float defaultDarkCurrentElectronsPerSec;
    
    private int minCadencesForCompression;
    
    private float nSigmaForFfiOutlierRejection;
    
    private boolean errorOnCoarsePointFfi; 

    /**
     * The maximum number of FsIds to read from
     * the file store at one time.
     */
    @ProxyIgnore
    private int maxReadFsIds;
    
    /**
     * The maximum number of pixels in the visible region to send to cal matlab.
     * Note that this can never be less than the number of pixels in a complete
     * module output row.
     */
    @ProxyIgnore
    private int maxCalibrateFsIds;

    /**
     * When true enables debug mode in cal-matlab.  The behavior of this is not 
     * well defined.
     */
    private boolean debugEnabled = false;

    private boolean dynoblackModelAutoSelectEnable = false;
    
    private double dynoblackChi2Threshold = 0;
    
    private boolean enableLcInformSmear;
    
    private boolean enableFfiInform;
    
    private boolean enableCoarsePointProcessing;
    
    private boolean enableMmntmDmpFlag;
    private boolean enableSefiAccFlag;
    private boolean enableSefiCadFlag;
    private boolean enableLdeOosFlag;
    private boolean enableLdeParErFlag;
    private boolean enableScrcErrFlag;
    
    private boolean enableSmearExcludeColumnMap;
    
    private boolean enableSceneDependentRowMap;
    
    private boolean enableBlackCoefficientOverrides;
    
    private boolean enableExcludeIndicators;
    
    private boolean enableExcludePreserve;
    
    /**
     * Not serializaing this because I'm going to pass this in via the cal inputs class.
     * When I can get this from the database then this parameter needs to be removed.
     */
    @ProxyIgnore
    private int k2Campaign;
    
    private boolean enableDbDataQualityGapping;
    
    /**
     * Creates a {@link CalModuleParameters}.
     */
    public CalModuleParameters() {
    }

    /**
     * This is not a Java bean property.  This is a way for the pipeline module
     * to know if it should fetch a dynablack blob.
     * @return true if dynablack is in use.
     */
    public boolean dynablackIsEnabled() {
        return blackAlgorithm != null && blackAlgorithm.equals("dynablack");
    }

    public float getStdRatioThreshold() {
        return stdRatioThreshold;
    }

    public void setStdRatioThreshold(float stdRatioThreshold) {
        this.stdRatioThreshold = stdRatioThreshold;
    }

    public int getCoefficentModelId() {
        return coefficentModelId;
    }

    public void setCoefficentModelId(int coefficentModelId) {
        this.coefficentModelId = coefficentModelId;
    }

    public boolean isUseRobustVerticalCoeffs() {
        return useRobustVerticalCoeffs;
    }

    public void setUseRobustVerticalCoeffs(boolean useRobustVerticalCoeffs) {
        this.useRobustVerticalCoeffs = useRobustVerticalCoeffs;
    }

    public boolean isUseRobustFrameFgsCoeffs() {
        return useRobustFrameFgsCoeffs;
    }

    public void setUseRobustFrameFgsCoeffs(boolean useRobustFrameFgsCoeffs) {
        this.useRobustFrameFgsCoeffs = useRobustFrameFgsCoeffs;
    }

    public boolean isUseRobustParallelFgsCoeffs() {
        return useRobustParallelFgsCoeffs;
    }

    public void setUseRobustParallelFgsCoeffs(boolean useRobustParallelFgsCoeffs) {
        this.useRobustParallelFgsCoeffs = useRobustParallelFgsCoeffs;
    }

    public String getBlackAlgorithmQuarters() {
        return blackAlgorithmQuarters;
    }

    public void setBlackAlgorithmQuarters(String blackAlgorithmQuarters) {
        this.blackAlgorithmQuarters = blackAlgorithmQuarters;
    }

    public String getBlackAlgorithm() {
        return blackAlgorithm;
    }

    public void setBlackAlgorithm(String blackAlgorithm) {
        this.blackAlgorithm = blackAlgorithm;
    }

    public boolean isCrCorrectionEnabled() {
        return crCorrectionEnabled;
    }

    public void setCrCorrectionEnabled(boolean crCorrectionEnabled) {
        this.crCorrectionEnabled = crCorrectionEnabled;
    }

    public boolean isLinearityCorrectionEnabled() {
        return linearityCorrectionEnabled;
    }

    public void setLinearityCorrectionEnabled(boolean linearityCorrectionEnabled) {
        this.linearityCorrectionEnabled = linearityCorrectionEnabled;
    }

    public boolean isFlatFieldCorrectionEnabled() {
        return flatFieldCorrectionEnabled;
    }

    public void setFlatFieldCorrectionEnabled(boolean flatFieldCorrectionEnabled) {
        this.flatFieldCorrectionEnabled = flatFieldCorrectionEnabled;
    }

    public boolean isUndershootEnabled() {
        return undershootEnabled;
    }

    public void setUndershootEnabled(boolean undershootEnabled) {
        this.undershootEnabled = undershootEnabled;
    }

    public boolean isCollateralMetricUncertEnabled() {
        return collateralMetricUncertEnabled;
    }

    public void setCollateralMetricUncertEnabled(
        boolean collateralMetricUncertEnabled) {
        this.collateralMetricUncertEnabled = collateralMetricUncertEnabled;
    }

    public float getMadSigmaThresholdForSmearLevels() {
        return madSigmaThresholdForSmearLevels;
    }

    public void setMadSigmaThresholdForSmearLevels(
        float madSigmaThresholdForSmearLevels) {
        this.madSigmaThresholdForSmearLevels = madSigmaThresholdForSmearLevels;
    }

    public int getUndershootReverseFitPolyOrder() {
        return undershootReverseFitPolyOrder;
    }

    public void setUndershootReverseFitPolyOrder(int undershootReverseFitPolyOrder) {
        this.undershootReverseFitPolyOrder = undershootReverseFitPolyOrder;
    }

    public int getUndershootReverseFitWindow() {
        return undershootReverseFitWindow;
    }

    public void setUndershootReverseFitWindow(int undershootReverseFitWindow) {
        this.undershootReverseFitWindow = undershootReverseFitWindow;
    }

    public int getPolyOrderMax() {
        return polyOrderMax;
    }

    public void setPolyOrderMax(int polyOrderMax) {
        this.polyOrderMax = polyOrderMax;
    }

    public float getDefaultDarkCurrentElectronsPerSec() {
        return defaultDarkCurrentElectronsPerSec;
    }

    public void setDefaultDarkCurrentElectronsPerSec(
        float defaultDarkCurrentElectronsPerSec) {
        this.defaultDarkCurrentElectronsPerSec = defaultDarkCurrentElectronsPerSec;
    }

    public int getMinCadencesForCompression() {
        return minCadencesForCompression;
    }

    public void setMinCadencesForCompression(int minCadencesForCompression) {
        this.minCadencesForCompression = minCadencesForCompression;
    }

    public float getnSigmaForFfiOutlierRejection() {
        return nSigmaForFfiOutlierRejection;
    }

    public void setnSigmaForFfiOutlierRejection(float nSigmaForFfiOutlierRejection) {
        this.nSigmaForFfiOutlierRejection = nSigmaForFfiOutlierRejection;
    }

    public boolean isErrorOnCoarsePointFfi() {
        return errorOnCoarsePointFfi;
    }

    public void setErrorOnCoarsePointFfi(boolean errorOnCoarsePointFfi) {
        this.errorOnCoarsePointFfi = errorOnCoarsePointFfi;
    }

    public int getMaxReadFsIds() {
        return maxReadFsIds;
    }

    public void setMaxReadFsIds(int maxReadFsIds) {
        this.maxReadFsIds = maxReadFsIds;
    }

    public int getMaxCalibrateFsIds() {
        return maxCalibrateFsIds;
    }

    public void setMaxCalibrateFsIds(int maxCalibrateFsIds) {
        this.maxCalibrateFsIds = maxCalibrateFsIds;
    }

    public boolean isDebugEnabled() {
        return debugEnabled;
    }

    public void setDebugEnabled(boolean debugEnabled) {
        this.debugEnabled = debugEnabled;
    }

    public boolean isDynoblackModelAutoSelectEnable() {
        return dynoblackModelAutoSelectEnable;
    }

    public void setDynoblackModelAutoSelectEnable(
        boolean dynoblackModelAutoSelectEnable) {
        this.dynoblackModelAutoSelectEnable = dynoblackModelAutoSelectEnable;
    }

    public double getDynoblackChi2Threshold() {
        return dynoblackChi2Threshold;
    }

    public void setDynoblackChi2Threshold(double dynoblackChi2Threshold) {
        this.dynoblackChi2Threshold = dynoblackChi2Threshold;
    }

    public boolean isEnableLcInformSmear() {
        return enableLcInformSmear;
    }

    public void setEnableLcInformSmear(boolean enableLcInformSmear) {
        this.enableLcInformSmear = enableLcInformSmear;
    }

    public boolean isEnableFfiInform() {
        return enableFfiInform;
    }

    public void setEnableFfiInform(boolean enableFfiInform) {
        this.enableFfiInform = enableFfiInform;
    }

    public boolean isEnableCoarsePointProcessing() {
        return enableCoarsePointProcessing;
    }

    public void setEnableCoarsePointProcessing(boolean enableCoarsePointProcessing) {
        this.enableCoarsePointProcessing = enableCoarsePointProcessing;
    }

    public boolean isEnableMmntmDmpFlag() {
        return enableMmntmDmpFlag;
    }

    public void setEnableMmntmDmpFlag(boolean enableMmntmDmpFlag) {
        this.enableMmntmDmpFlag = enableMmntmDmpFlag;
    }

    public boolean isEnableSefiAccFlag() {
        return enableSefiAccFlag;
    }

    public void setEnableSefiAccFlag(boolean enableSefiAccFlag) {
        this.enableSefiAccFlag = enableSefiAccFlag;
    }

    public boolean isEnableSefiCadFlag() {
        return enableSefiCadFlag;
    }

    public void setEnableSefiCadFlag(boolean enableSefiCadFlag) {
        this.enableSefiCadFlag = enableSefiCadFlag;
    }

    public boolean isEnableLdeOosFlag() {
        return enableLdeOosFlag;
    }

    public void setEnableLdeOosFlag(boolean enableLdeOosFlag) {
        this.enableLdeOosFlag = enableLdeOosFlag;
    }

    public boolean isEnableLdeParErFlag() {
        return enableLdeParErFlag;
    }

    public void setEnableLdeParErFlag(boolean enableLdeParErFlag) {
        this.enableLdeParErFlag = enableLdeParErFlag;
    }

    public boolean isEnableScrcErrFlag() {
        return enableScrcErrFlag;
    }

    public void setEnableScrcErrFlag(boolean enableScrcErrFlag) {
        this.enableScrcErrFlag = enableScrcErrFlag;
    }

    public boolean isEnableSmearExcludeColumnMap() {
        return enableSmearExcludeColumnMap;
    }

    public void setEnableSmearExcludeColumnMap(boolean enableSmearExcludeColumnMap) {
        this.enableSmearExcludeColumnMap = enableSmearExcludeColumnMap;
    }

    public boolean isEnableSceneDependentRowMap() {
        return enableSceneDependentRowMap;
    }

    public void setEnableSceneDependentRowMap(boolean enableSceneDependentRowMap) {
        this.enableSceneDependentRowMap = enableSceneDependentRowMap;
    }

    public boolean isEnableBlackCoefficientOverrides() {
        return enableBlackCoefficientOverrides;
    }

    public void setEnableBlackCoefficientOverrides(
        boolean enableBlackCoefficientOverrides) {
        this.enableBlackCoefficientOverrides = enableBlackCoefficientOverrides;
    }

    public boolean isEnableExcludeIndicators() {
        return enableExcludeIndicators;
    }

    public void setEnableExcludeIndicators(boolean enableExcludeIndicators) {
        this.enableExcludeIndicators = enableExcludeIndicators;
    }

    public boolean isEnableExcludePreserve() {
        return enableExcludePreserve;
    }

    public void setEnableExcludePreserve(boolean enableExcludePreserve) {
        this.enableExcludePreserve = enableExcludePreserve;
    }
    
    public int getK2Campaign() {
        return k2Campaign;
    }

    public void setK2Campaign(int k2Campaign) {
        this.k2Campaign = k2Campaign;
    }

    
    public boolean isEnableDbDataQualityGapping() {
        return enableDbDataQualityGapping;
    }

    public void setEnableDbDataQualityGapping(boolean enableDbDataQualityGapping) {
        this.enableDbDataQualityGapping = enableDbDataQualityGapping;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((blackAlgorithm == null) ? 0 : blackAlgorithm.hashCode());
        result = prime
            * result
            + ((blackAlgorithmQuarters == null) ? 0
                : blackAlgorithmQuarters.hashCode());
        result = prime * result + coefficentModelId;
        result = prime * result + (collateralMetricUncertEnabled ? 1231 : 1237);
        result = prime * result + (crCorrectionEnabled ? 1231 : 1237);
        result = prime * result + (debugEnabled ? 1231 : 1237);
        result = prime * result
            + Float.floatToIntBits(defaultDarkCurrentElectronsPerSec);
        long temp;
        temp = Double.doubleToLongBits(dynoblackChi2Threshold);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result
            + (dynoblackModelAutoSelectEnable ? 1231 : 1237);
        result = prime * result
            + (enableBlackCoefficientOverrides ? 1231 : 1237);
        result = prime * result + (enableCoarsePointProcessing ? 1231 : 1237);
        result = prime * result + (enableDbDataQualityGapping ? 1231 : 1237);
        result = prime * result + (enableExcludeIndicators ? 1231 : 1237);
        result = prime * result + (enableExcludePreserve ? 1231 : 1237);
        result = prime * result + (enableFfiInform ? 1231 : 1237);
        result = prime * result + (enableLcInformSmear ? 1231 : 1237);
        result = prime * result + (enableLdeOosFlag ? 1231 : 1237);
        result = prime * result + (enableLdeParErFlag ? 1231 : 1237);
        result = prime * result + (enableMmntmDmpFlag ? 1231 : 1237);
        result = prime * result + (enableSceneDependentRowMap ? 1231 : 1237);
        result = prime * result + (enableScrcErrFlag ? 1231 : 1237);
        result = prime * result + (enableSefiAccFlag ? 1231 : 1237);
        result = prime * result + (enableSefiCadFlag ? 1231 : 1237);
        result = prime * result + (enableSmearExcludeColumnMap ? 1231 : 1237);
        result = prime * result + (errorOnCoarsePointFfi ? 1231 : 1237);
        result = prime * result + (flatFieldCorrectionEnabled ? 1231 : 1237);
        result = prime * result + k2Campaign;
        result = prime * result + (linearityCorrectionEnabled ? 1231 : 1237);
        result = prime * result
            + Float.floatToIntBits(madSigmaThresholdForSmearLevels);
        result = prime * result + maxCalibrateFsIds;
        result = prime * result + maxReadFsIds;
        result = prime * result + minCadencesForCompression;
        result = prime * result
            + Float.floatToIntBits(nSigmaForFfiOutlierRejection);
        result = prime * result + polyOrderMax;
        result = prime * result + Float.floatToIntBits(stdRatioThreshold);
        result = prime * result + (undershootEnabled ? 1231 : 1237);
        result = prime * result + undershootReverseFitPolyOrder;
        result = prime * result + undershootReverseFitWindow;
        result = prime * result + (useRobustFrameFgsCoeffs ? 1231 : 1237);
        result = prime * result + (useRobustParallelFgsCoeffs ? 1231 : 1237);
        result = prime * result + (useRobustVerticalCoeffs ? 1231 : 1237);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        CalModuleParameters other = (CalModuleParameters) obj;
        if (blackAlgorithm == null) {
            if (other.blackAlgorithm != null)
                return false;
        } else if (!blackAlgorithm.equals(other.blackAlgorithm))
            return false;
        if (blackAlgorithmQuarters == null) {
            if (other.blackAlgorithmQuarters != null)
                return false;
        } else if (!blackAlgorithmQuarters.equals(other.blackAlgorithmQuarters))
            return false;
        if (coefficentModelId != other.coefficentModelId)
            return false;
        if (collateralMetricUncertEnabled != other.collateralMetricUncertEnabled)
            return false;
        if (crCorrectionEnabled != other.crCorrectionEnabled)
            return false;
        if (debugEnabled != other.debugEnabled)
            return false;
        if (Float.floatToIntBits(defaultDarkCurrentElectronsPerSec) != Float.floatToIntBits(other.defaultDarkCurrentElectronsPerSec))
            return false;
        if (Double.doubleToLongBits(dynoblackChi2Threshold) != Double.doubleToLongBits(other.dynoblackChi2Threshold))
            return false;
        if (dynoblackModelAutoSelectEnable != other.dynoblackModelAutoSelectEnable)
            return false;
        if (enableBlackCoefficientOverrides != other.enableBlackCoefficientOverrides)
            return false;
        if (enableCoarsePointProcessing != other.enableCoarsePointProcessing)
            return false;
        if (enableDbDataQualityGapping != other.enableDbDataQualityGapping)
            return false;
        if (enableExcludeIndicators != other.enableExcludeIndicators)
            return false;
        if (enableExcludePreserve != other.enableExcludePreserve)
            return false;
        if (enableFfiInform != other.enableFfiInform)
            return false;
        if (enableLcInformSmear != other.enableLcInformSmear)
            return false;
        if (enableLdeOosFlag != other.enableLdeOosFlag)
            return false;
        if (enableLdeParErFlag != other.enableLdeParErFlag)
            return false;
        if (enableMmntmDmpFlag != other.enableMmntmDmpFlag)
            return false;
        if (enableSceneDependentRowMap != other.enableSceneDependentRowMap)
            return false;
        if (enableScrcErrFlag != other.enableScrcErrFlag)
            return false;
        if (enableSefiAccFlag != other.enableSefiAccFlag)
            return false;
        if (enableSefiCadFlag != other.enableSefiCadFlag)
            return false;
        if (enableSmearExcludeColumnMap != other.enableSmearExcludeColumnMap)
            return false;
        if (errorOnCoarsePointFfi != other.errorOnCoarsePointFfi)
            return false;
        if (flatFieldCorrectionEnabled != other.flatFieldCorrectionEnabled)
            return false;
        if (k2Campaign != other.k2Campaign)
            return false;
        if (linearityCorrectionEnabled != other.linearityCorrectionEnabled)
            return false;
        if (Float.floatToIntBits(madSigmaThresholdForSmearLevels) != Float.floatToIntBits(other.madSigmaThresholdForSmearLevels))
            return false;
        if (maxCalibrateFsIds != other.maxCalibrateFsIds)
            return false;
        if (maxReadFsIds != other.maxReadFsIds)
            return false;
        if (minCadencesForCompression != other.minCadencesForCompression)
            return false;
        if (Float.floatToIntBits(nSigmaForFfiOutlierRejection) != Float.floatToIntBits(other.nSigmaForFfiOutlierRejection))
            return false;
        if (polyOrderMax != other.polyOrderMax)
            return false;
        if (Float.floatToIntBits(stdRatioThreshold) != Float.floatToIntBits(other.stdRatioThreshold))
            return false;
        if (undershootEnabled != other.undershootEnabled)
            return false;
        if (undershootReverseFitPolyOrder != other.undershootReverseFitPolyOrder)
            return false;
        if (undershootReverseFitWindow != other.undershootReverseFitWindow)
            return false;
        if (useRobustFrameFgsCoeffs != other.useRobustFrameFgsCoeffs)
            return false;
        if (useRobustParallelFgsCoeffs != other.useRobustParallelFgsCoeffs)
            return false;
        if (useRobustVerticalCoeffs != other.useRobustVerticalCoeffs)
            return false;
        return true;
    }
}