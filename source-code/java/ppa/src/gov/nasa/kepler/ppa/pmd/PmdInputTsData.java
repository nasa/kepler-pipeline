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

package gov.nasa.kepler.ppa.pmd;

import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.BLACK_LEVEL;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.BLACK_LEVEL_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.DARK_CURRENT;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.DARK_CURRENT_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.SMEAR_LEVEL;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.SMEAR_LEVEL_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType.TWOD_BLACK;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType.TWOD_BLACK_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType.UNDERSHOOT;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType.UNDERSHOOT_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType.BRIGHTNESS;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType.BRIGHTNESS_UNCERTAINTIES;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType.ENCIRCLED_ENERGY;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType.ENCIRCLED_ENERGY_UNCERTAINTIES;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.CompoundTimeSeries;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.pa.PaCosmicRayMetrics;
import gov.nasa.kepler.ppa.PpaTargetTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Input time series data from CAL and PA needed by PPA:PMD.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 */
public class PmdInputTsData implements Persistable {
    /**
     * The black cosmic ray summary time series (from CAL) for this
     * module/output.
     */
    private PmdCalCosmicRayMetrics blackCosmicRayMetrics = new PmdCalCosmicRayMetrics();

    /**
     * The masked smear cosmic ray summary time series (from CAL) for this
     * module/output.
     */
    private PmdCalCosmicRayMetrics maskedSmearCosmicRayMetrics = new PmdCalCosmicRayMetrics();

    /**
     * The virtual smear cosmic ray summary time series (from CAL) for this
     * module/output.
     */
    private PmdCalCosmicRayMetrics virtualSmearCosmicRayMetrics = new PmdCalCosmicRayMetrics();

    /**
     * The 2D black time series (from CAL) for each target.
     */
    private PpaTargetTimeSeries[] twoDBlack = new PpaTargetTimeSeries[0];

    /**
     * The LDE undershoot time series (from CAL) for each target.
     */
    private PpaTargetTimeSeries[] ldeUndershoot = new PpaTargetTimeSeries[0];

    /**
     * Collateral (black level) time series data from CAL.
     */
    private CompoundFloatTimeSeries blackLevel = new CompoundFloatTimeSeries();

    /**
     * Collateral (dark current) time series data from CAL.
     */
    private CompoundFloatTimeSeries darkCurrent = new CompoundFloatTimeSeries();

    /**
     * Collateral (smear level) time series data from CAL.
     */
    private CompoundFloatTimeSeries smearLevel = new CompoundFloatTimeSeries();

    /**
     * Theoretical compression efficiency data from CAL.
     */
    private SimpleFloatTimeSeries theoreticalCompressionEfficiency = new SimpleFloatTimeSeries();

    /**
     * Achieved compression efficiency data from CAL.
     */
    private SimpleFloatTimeSeries achievedCompressionEfficiency = new SimpleFloatTimeSeries();

    /**
     * The background cosmic ray summary time series (from PA) for this
     * module/output.
     */
    private PaCosmicRayMetrics backgroundCosmicRayMetrics = new PaCosmicRayMetrics();

    /**
     * The target cosmic ray summary time series (from PA) for this
     * module/output.
     */
    private PaCosmicRayMetrics targetStarCosmicRayMetrics = new PaCosmicRayMetrics();

    /**
     * The encircled energy time series (from PA) for this module/output.
     */
    private CompoundFloatTimeSeries encircledEnergy = new CompoundFloatTimeSeries();

    /**
     * The brightness time series (from PA) for this module/output.
     */
    private CompoundFloatTimeSeries brightness = new CompoundFloatTimeSeries();

    /**
     * Returns all {@link FsId}s required to fill the time series for this
     * object.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param targets all targets on the CCD module/output
     * @return a non-{@code null} list of {@link FsId}s
     * @throws NullPointerException if {@code targets} is {@code null}
     */
    public static List<FsId> getFsIds(int ccdModule, int ccdOutput,
        List<ObservedTarget> targets) {

        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.addAll(PmdCalCosmicRayMetrics.getFsIds(
            CollateralType.BLACK_LEVEL, ccdModule, ccdOutput));
        fsIds.addAll(PmdCalCosmicRayMetrics.getFsIds(
            CollateralType.MASKED_SMEAR, ccdModule, ccdOutput));
        fsIds.addAll(PmdCalCosmicRayMetrics.getFsIds(
            CollateralType.VIRTUAL_SMEAR, ccdModule, ccdOutput));

        // TwoDBlack and ldeUndershoot.
        fsIds.addAll(getTargetFsIds(ccdModule, ccdOutput, targets));

        fsIds.add(getBlackLevelFsId(ccdModule, ccdOutput));
        fsIds.add(getBlackLevelUncertaintiesFsId(ccdModule, ccdOutput));
        fsIds.add(getDarkCurrentFsId(ccdModule, ccdOutput));
        fsIds.add(getDarkCurrentUncertaintiesFsId(ccdModule, ccdOutput));
        fsIds.add(getSmearLevelFsId(ccdModule, ccdOutput));
        fsIds.add(getSmearLevelUncertaintiesFsId(ccdModule, ccdOutput));

        fsIds.add(getTheoreticalCompressionEfficiencyFsId(ccdModule, ccdOutput));
        fsIds.add(getAchievedCompressionEfficiencyFsId(ccdModule, ccdOutput));

        fsIds.addAll(PaCosmicRayMetrics.getFsIds(TargetType.BACKGROUND,
            ccdModule, ccdOutput));
        fsIds.addAll(PaCosmicRayMetrics.getFsIds(TargetType.LONG_CADENCE,
            ccdModule, ccdOutput));

        fsIds.add(getEncircledEnergyFsId(ccdModule, ccdOutput));
        fsIds.add(getEncircledEnergyUncertaintiesFsId(ccdModule, ccdOutput));
        fsIds.add(getBrightnessFsId(ccdModule, ccdOutput));
        fsIds.add(getBrightnessUncertaintiesFsId(ccdModule, ccdOutput));

        return fsIds;
    }

    /**
     * Sets all of the time series in this object.
     * <p>
     * Use {@link #getFsIds(int, int, List)} to retrieve the fs IDs for your
     * call to {@code readTimeSeriesAsFloat} and then build a map from fs ID to
     * {@code FloatTimeSeries} for each time series.
     * 
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param targets all targets on the CCD module/output
     * @param floatTimeSeriesByFsId a map of {@link FsId} to
     * {@link FloatTimeSeries}
     * @throws NullPointerException if {@code targets} or
     * {@code floatTimeSeriesByFsId} are {@code null}
     */
    public void setTimeSeries(int ccdModule, int ccdOutput,
        List<ObservedTarget> targets,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        setBlackCosmicRayMetrics(createCalCosmicRayMetrics(
            CollateralType.BLACK_LEVEL, ccdModule, ccdOutput,
            floatTimeSeriesByFsId));
        setMaskedSmearCosmicRayMetrics(createCalCosmicRayMetrics(
            CollateralType.MASKED_SMEAR, ccdModule, ccdOutput,
            floatTimeSeriesByFsId));
        setVirtualSmearCosmicRayMetrics(createCalCosmicRayMetrics(
            CollateralType.VIRTUAL_SMEAR, ccdModule, ccdOutput,
            floatTimeSeriesByFsId));

        // TwoDBlack and ldeUndershoot.
        setTargetTimeSeries(ccdModule, ccdOutput, targets,
            floatTimeSeriesByFsId);

        setBlackLevel(CompoundTimeSeries.getFloatInstance(
            getBlackLevelFsId(ccdModule, ccdOutput),
            getBlackLevelUncertaintiesFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setDarkCurrent(CompoundTimeSeries.getFloatInstance(
            getDarkCurrentFsId(ccdModule, ccdOutput),
            getDarkCurrentUncertaintiesFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setSmearLevel(CompoundTimeSeries.getFloatInstance(
            getSmearLevelFsId(ccdModule, ccdOutput),
            getSmearLevelUncertaintiesFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));

        setTheoreticalCompressionEfficiency(SimpleTimeSeries.getFloatInstance(
            getTheoreticalCompressionEfficiencyFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setAchievedCompressionEfficiency(SimpleTimeSeries.getFloatInstance(
            getAchievedCompressionEfficiencyFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));

        setBackgroundCosmicRayMetrics(createPaCosmicRayMetrics(
            TargetType.BACKGROUND, ccdModule, ccdOutput, floatTimeSeriesByFsId));
        setTargetStarCosmicRayMetrics(createPaCosmicRayMetrics(
            TargetType.LONG_CADENCE, ccdModule, ccdOutput,
            floatTimeSeriesByFsId));

        setEncircledEnergy(CompoundTimeSeries.getFloatInstance(
            getEncircledEnergyFsId(ccdModule, ccdOutput),
            getEncircledEnergyUncertaintiesFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setBrightness(CompoundTimeSeries.getFloatInstance(
            getBrightnessFsId(ccdModule, ccdOutput),
            getBrightnessUncertaintiesFsId(ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
    }

    private static List<FsId> getTargetFsIds(int ccdModule, int ccdOutput,
        List<ObservedTarget> targets) {

        List<FsId> fsIds = new ArrayList<FsId>();

        for (ObservedTarget target : targets) {
            if (target.getLabels()
                .contains(TargetLabel.PPA_2DBLACK.toString())) {
                fsIds.add(getTwoDBlackFsId(ccdModule, ccdOutput, target));
                fsIds.add(getTwoDBlackUncertaintiesFsId(ccdModule, ccdOutput,
                    target));
            }
            if (target.getLabels()
                .contains(TargetLabel.PPA_LDE_UNDERSHOOT.toString())) {
                fsIds.add(getUndershootFsId(ccdModule, ccdOutput, target));
                fsIds.add(getUndershootUncertaintiesFsId(ccdModule, ccdOutput,
                    target));
            }
        }

        return fsIds;
    }

    private static FsId getTwoDBlackFsId(int ccdModule, int ccdOutput,
        ObservedTarget target) {
        return CalFsIdFactory.getTargetMetricsTimeSeriesFsId(CadenceType.LONG,
            TWOD_BLACK, ccdModule, ccdOutput, target.getKeplerId());
    }

    private static FsId getTwoDBlackUncertaintiesFsId(int ccdModule,
        int ccdOutput, ObservedTarget target) {
        return CalFsIdFactory.getTargetMetricsTimeSeriesFsId(CadenceType.LONG,
            TWOD_BLACK_UNCERTAINTIES, ccdModule, ccdOutput,
            target.getKeplerId());
    }

    private static FsId getUndershootFsId(int ccdModule, int ccdOutput,
        ObservedTarget target) {
        return CalFsIdFactory.getTargetMetricsTimeSeriesFsId(CadenceType.LONG,
            UNDERSHOOT, ccdModule, ccdOutput, target.getKeplerId());
    }

    private static FsId getUndershootUncertaintiesFsId(int ccdModule,
        int ccdOutput, ObservedTarget target) {
        return CalFsIdFactory.getTargetMetricsTimeSeriesFsId(CadenceType.LONG,
            UNDERSHOOT_UNCERTAINTIES, ccdModule, ccdOutput,
            target.getKeplerId());
    }

    private static FsId getBlackLevelFsId(int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            BLACK_LEVEL, ccdModule, ccdOutput);
    }

    private static FsId getBlackLevelUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            BLACK_LEVEL_UNCERTAINTIES, ccdModule, ccdOutput);
    }

    private static FsId getDarkCurrentFsId(int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            DARK_CURRENT, ccdModule, ccdOutput);
    }

    private static FsId getDarkCurrentUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            DARK_CURRENT_UNCERTAINTIES, ccdModule, ccdOutput);
    }

    private static FsId getSmearLevelFsId(int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            SMEAR_LEVEL, ccdModule, ccdOutput);
    }

    private static FsId getSmearLevelUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            SMEAR_LEVEL_UNCERTAINTIES, ccdModule, ccdOutput);
    }

    private static FsId getTheoreticalCompressionEfficiencyFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            THEORETICAL_COMPRESSION_EFFICIENCY, ccdModule, ccdOutput);
    }

    private static FsId getAchievedCompressionEfficiencyFsId(int ccdModule,
        int ccdOutput) {
        return CalFsIdFactory.getMetricsTimeSeriesFsId(CadenceType.LONG,
            ACHIEVED_COMPRESSION_EFFICIENCY, ccdModule, ccdOutput);
    }

    private static FsId getEncircledEnergyFsId(int ccdModule, int ccdOutput) {
        return PaFsIdFactory.getMetricTimeSeriesFsId(ENCIRCLED_ENERGY,
            ccdModule, ccdOutput);
    }

    private static FsId getEncircledEnergyUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return PaFsIdFactory.getMetricTimeSeriesFsId(
            ENCIRCLED_ENERGY_UNCERTAINTIES, ccdModule, ccdOutput);
    }

    private static FsId getBrightnessFsId(int ccdModule, int ccdOutput) {
        return PaFsIdFactory.getMetricTimeSeriesFsId(BRIGHTNESS, ccdModule,
            ccdOutput);
    }

    private static FsId getBrightnessUncertaintiesFsId(int ccdModule,
        int ccdOutput) {
        return PaFsIdFactory.getMetricTimeSeriesFsId(BRIGHTNESS_UNCERTAINTIES,
            ccdModule, ccdOutput);
    }

    private PmdCalCosmicRayMetrics createCalCosmicRayMetrics(
        CollateralType collateralType, int ccdModule, int ccdOutput,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        PmdCalCosmicRayMetrics pmdCalCosmicRayMetrics = new PmdCalCosmicRayMetrics();
        pmdCalCosmicRayMetrics.setTimeSeries(collateralType, ccdModule,
            ccdOutput, floatTimeSeriesByFsId);

        return pmdCalCosmicRayMetrics;
    }

    private PaCosmicRayMetrics createPaCosmicRayMetrics(TargetType targetType,
        int ccdModule, int ccdOutput,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        PaCosmicRayMetrics cosmicRayMetrics = new PaCosmicRayMetrics();
        cosmicRayMetrics.setTimeSeries(targetType, ccdModule, ccdOutput,
            floatTimeSeriesByFsId);

        return cosmicRayMetrics;
    }

    private void setTargetTimeSeries(int ccdModule, int ccdOutput,
        List<ObservedTarget> targets,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        List<PpaTargetTimeSeries> twoDBlack = new ArrayList<PpaTargetTimeSeries>();
        List<PpaTargetTimeSeries> ldeUndershoot = new ArrayList<PpaTargetTimeSeries>();

        for (ObservedTarget target : targets) {
            if (target.getLabels()
                .contains(TargetLabel.PPA_2DBLACK.toString())) {
                twoDBlack.add(PpaTargetTimeSeries.createTargetTimeSeries(
                    target.getKeplerId(),
                    getTwoDBlackFsId(ccdModule, ccdOutput, target),
                    getTwoDBlackUncertaintiesFsId(ccdModule, ccdOutput, target),
                    floatTimeSeriesByFsId));
            }
            if (target.getLabels()
                .contains(TargetLabel.PPA_LDE_UNDERSHOOT.toString())) {
                ldeUndershoot.add(PpaTargetTimeSeries.createTargetTimeSeries(
                    target.getKeplerId(),
                    getUndershootFsId(ccdModule, ccdOutput, target),
                    getUndershootUncertaintiesFsId(ccdModule, ccdOutput, target),
                    floatTimeSeriesByFsId));
            }
        }

        setTwoDBlack(twoDBlack.toArray(new PpaTargetTimeSeries[0]));
        setLdeUndershoot(ldeUndershoot.toArray(new PpaTargetTimeSeries[0]));
    }

    public PmdCalCosmicRayMetrics getBlackCosmicRayMetrics() {
        return blackCosmicRayMetrics;
    }

    public void setBlackCosmicRayMetrics(
        PmdCalCosmicRayMetrics blackCosmicRayMetrics) {
        this.blackCosmicRayMetrics = blackCosmicRayMetrics;
    }

    public PmdCalCosmicRayMetrics getMaskedSmearCosmicRayMetrics() {
        return maskedSmearCosmicRayMetrics;
    }

    public void setMaskedSmearCosmicRayMetrics(
        PmdCalCosmicRayMetrics maskedSmearCosmicRayMetrics) {
        this.maskedSmearCosmicRayMetrics = maskedSmearCosmicRayMetrics;
    }

    public PmdCalCosmicRayMetrics getVirtualSmearCosmicRayMetrics() {
        return virtualSmearCosmicRayMetrics;
    }

    public void setVirtualSmearCosmicRayMetrics(
        PmdCalCosmicRayMetrics virtualSmearCosmicRayMetrics) {
        this.virtualSmearCosmicRayMetrics = virtualSmearCosmicRayMetrics;
    }

    public PpaTargetTimeSeries[] getTwoDBlack() {
        return twoDBlack;
    }

    public void setTwoDBlack(PpaTargetTimeSeries[] twoDBlack) {
        this.twoDBlack = twoDBlack;
    }

    public PpaTargetTimeSeries[] getLdeUndershoot() {
        return ldeUndershoot;
    }

    public void setLdeUndershoot(PpaTargetTimeSeries[] ldeUndershoot) {
        this.ldeUndershoot = ldeUndershoot;
    }

    public CompoundFloatTimeSeries getBlackLevel() {
        return blackLevel;
    }

    public void setBlackLevel(CompoundFloatTimeSeries blackLevel) {
        this.blackLevel = blackLevel;
    }

    public CompoundFloatTimeSeries getDarkCurrent() {
        return darkCurrent;
    }

    public void setDarkCurrent(CompoundFloatTimeSeries darkCurrent) {
        this.darkCurrent = darkCurrent;
    }

    public CompoundFloatTimeSeries getSmearLevel() {
        return smearLevel;
    }

    public void setSmearLevel(CompoundFloatTimeSeries smearLevel) {
        this.smearLevel = smearLevel;
    }

    public SimpleFloatTimeSeries getTheoreticalCompressionEfficiency() {
        return theoreticalCompressionEfficiency;
    }

    public void setTheoreticalCompressionEfficiency(
        SimpleFloatTimeSeries theoreticalCompressionEfficiency) {
        this.theoreticalCompressionEfficiency = theoreticalCompressionEfficiency;
    }

    public SimpleFloatTimeSeries getAchievedCompressionEfficiency() {
        return achievedCompressionEfficiency;
    }

    public void setAchievedCompressionEfficiency(
        SimpleFloatTimeSeries achievedCompressionEfficiency) {
        this.achievedCompressionEfficiency = achievedCompressionEfficiency;
    }

    public PaCosmicRayMetrics getBackgroundCosmicRayMetrics() {
        return backgroundCosmicRayMetrics;
    }

    public void setBackgroundCosmicRayMetrics(
        PaCosmicRayMetrics backgroundCosmicRayMetrics) {
        this.backgroundCosmicRayMetrics = backgroundCosmicRayMetrics;
    }

    public PaCosmicRayMetrics getTargetStarCosmicRayMetrics() {
        return targetStarCosmicRayMetrics;
    }

    public void setTargetStarCosmicRayMetrics(
        PaCosmicRayMetrics targetStarCosmicRayMetrics) {
        this.targetStarCosmicRayMetrics = targetStarCosmicRayMetrics;
    }

    public CompoundFloatTimeSeries getEncircledEnergy() {
        return encircledEnergy;
    }

    public void setEncircledEnergy(CompoundFloatTimeSeries encircledEnergy) {
        this.encircledEnergy = encircledEnergy;
    }

    public CompoundFloatTimeSeries getBrightness() {
        return brightness;
    }

    public void setBrightness(CompoundFloatTimeSeries brightness) {
        this.brightness = brightness;
    }
}
