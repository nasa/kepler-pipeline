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

import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.ACHIEVED_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BACKGROUND_COSMIC_RAY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BACKGROUND_LEVEL;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BLACK_COSMIC_RAY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BLACK_LEVEL;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BRIGHTNESS;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.CDPP_EXPECTED;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.CDPP_MEASURED;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.CDPP_RATIO;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.CENTROIDS_MEAN_COLUMN;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.CENTROIDS_MEAN_ROW;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.DARK_CURRENT;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.ENCIRCLED_ENERGY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.LDE_UNDERSHOOT;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.MASKED_SMEAR_COSMIC_RAY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.PLATE_SCALE;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.SMEAR_LEVEL;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.TARGET_STAR_COSMIC_RAY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.THEORETICAL_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.TWO_D_BLACK;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.VIRTUAL_SMEAR_COSMIC_RAY;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.ppa.pag.PmdMetricReportKey;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Complete metric report for a single module/output.
 * 
 * @author Bill Wohler
 */
@ProxyIgnoreStatics
public class PmdReport implements Persistable {

    private static final Log log = LogFactory.getLog(PmdReport.class);

    /**
     * Number of distinct types of reports we need, not including subtypes.
     */
    private static final int REPORT_TYPE_COUNT = ReportType.values().length;

    /**
     * The black cosmic ray summary report.
     */
    private PmdEnergyDistributionReport blackCosmicRayMetrics = new PmdEnergyDistributionReport();

    /**
     * The masked smear cosmic ray summary report.
     */
    private PmdEnergyDistributionReport maskedSmearCosmicRayMetrics = new PmdEnergyDistributionReport();

    /**
     * The virtual smear cosmic ray summary report.
     */
    private PmdEnergyDistributionReport virtualSmearCosmicRayMetrics = new PmdEnergyDistributionReport();

    /**
     * The 2D black report for each target.
     */
    private PmdMetricReport[] twoDBlack = new PmdMetricReport[0];

    /**
     * The LDE undershoot report for each target.
     */
    private PmdMetricReport[] ldeUndershoot = new PmdMetricReport[0];

    /**
     * Collateral (black level) report.
     */
    private PmdMetricReport blackLevel = new PmdMetricReport();

    /**
     * Collateral (dark current) report.
     */
    private PmdMetricReport darkCurrent = new PmdMetricReport();

    /**
     * Collateral (smear level) report.
     */
    private PmdMetricReport smearLevel = new PmdMetricReport();

    /**
     * Theoretical compression efficiency report.
     */
    private PmdMetricReport theoreticalCompressionEfficiency = new PmdMetricReport();

    /**
     * Achieved compression efficiency report.
     */
    private PmdMetricReport achievedCompressionEfficiency = new PmdMetricReport();

    /**
     * The background cosmic ray summary report.
     */
    private PmdEnergyDistributionReport backgroundCosmicRayMetrics = new PmdEnergyDistributionReport();

    /**
     * The target cosmic ray summary report.
     */
    private PmdEnergyDistributionReport targetStarCosmicRayMetrics = new PmdEnergyDistributionReport();

    /**
     * The encircled energy report.
     */
    private PmdMetricReport encircledEnergy = new PmdMetricReport();

    /**
     * The brightness report.
     */
    private PmdMetricReport brightness = new PmdMetricReport();

    /**
     * The background level report.
     */
    private PmdMetricReport backgroundLevel = new PmdMetricReport();

    /**
     * The centroid row report.
     */
    private PmdMetricReport centroidsMeanRow = new PmdMetricReport();

    /**
     * The centroid column report.
     */
    private PmdMetricReport centroidsMeanColumn = new PmdMetricReport();

    /**
     * The plate scale report.
     */
    private PmdMetricReport plateScale = new PmdMetricReport();

    /**
     * The expected CDPP report.
     */
    private PmdCdppReport cdppExpected = new PmdCdppReport();

    /**
     * The measured CDPP report.
     */
    private PmdCdppReport cdppMeasured = new PmdCdppReport();

    /**
     * The ratio between expected CDPP and measured CDPP report.
     */
    private PmdCdppReport cdppRatio = new PmdCdppReport();

    /**
     * Creates a {@link PmdReport}.
     */
    public PmdReport() {
    }

    /**
     * Creates a {@link PmdReport}.
     * 
     * @param reportMap a map from {@link PmdMetricReportKey} to
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     */
    public PmdReport(
        Map<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reportMap,
        int ccdModule, int ccdOutput) {

        setBlackCosmicRayMetrics(new PmdEnergyDistributionReport(reportMap,
            ccdModule, ccdOutput, BLACK_COSMIC_RAY));
        setMaskedSmearCosmicRayMetrics(new PmdEnergyDistributionReport(
            reportMap, ccdModule, ccdOutput, MASKED_SMEAR_COSMIC_RAY));
        setVirtualSmearCosmicRayMetrics(new PmdEnergyDistributionReport(
            reportMap, ccdModule, ccdOutput, VIRTUAL_SMEAR_COSMIC_RAY));

        setTwoDBlack(createReports(reportMap, ccdModule, ccdOutput, TWO_D_BLACK));
        setLdeUndershoot(createReports(reportMap, ccdModule, ccdOutput,
            LDE_UNDERSHOOT));

        setBlackLevel(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            BLACK_LEVEL));
        setDarkCurrent(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            DARK_CURRENT));
        setSmearLevel(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            SMEAR_LEVEL));

        setTheoreticalCompressionEfficiency(new PmdMetricReport(reportMap,
            ccdModule, ccdOutput, THEORETICAL_COMPRESSION_EFFICIENCY));
        setAchievedCompressionEfficiency(new PmdMetricReport(reportMap,
            ccdModule, ccdOutput, ACHIEVED_COMPRESSION_EFFICIENCY));

        setBackgroundCosmicRayMetrics(new PmdEnergyDistributionReport(
            reportMap, ccdModule, ccdOutput, BACKGROUND_COSMIC_RAY));
        setTargetStarCosmicRayMetrics(new PmdEnergyDistributionReport(
            reportMap, ccdModule, ccdOutput, TARGET_STAR_COSMIC_RAY));

        setEncircledEnergy(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            ENCIRCLED_ENERGY));
        setBrightness(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            BRIGHTNESS));
        setBackgroundLevel(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            BACKGROUND_LEVEL));
        setCentroidsMeanRow(new PmdMetricReport(reportMap, ccdModule,
            ccdOutput, CENTROIDS_MEAN_ROW));
        setCentroidsMeanColumn(new PmdMetricReport(reportMap, ccdModule,
            ccdOutput, CENTROIDS_MEAN_COLUMN));
        setPlateScale(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            PLATE_SCALE));

        setCdppExpected(new PmdCdppReport(reportMap, ccdModule, ccdOutput,
            CDPP_EXPECTED));
        setCdppMeasured(new PmdCdppReport(reportMap, ccdModule, ccdOutput,
            CDPP_MEASURED));
        setCdppRatio(new PmdCdppReport(reportMap, ccdModule, ccdOutput,
            CDPP_RATIO));
    }

    /**
     * Checks whether the given report map contains all the needed reports for
     * the given module and output.
     * 
     * @param reportMap a map from {@link PmdMetricReportKey} to
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @return {@code true} if all reports are present; otherwise, {@code false}
     */
    public static boolean containsReport(
        Map<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reportMap,
        int ccdModule, int ccdOutput) {

        if (reportMap == null) {
            return false;
        }

        // This is only a heuristic: it isn't checking for all subtypes.
        Set<ReportType> reportTypeSet = new HashSet<ReportType>();
        for (gov.nasa.kepler.hibernate.ppa.PmdMetricReport report : reportMap.values()) {
            if (report.getCcdModule() != ccdModule
                || report.getCcdOutput() != ccdOutput) {
                continue;
            }
            reportTypeSet.add(report.getType());
        }
        if (reportTypeSet.size() != REPORT_TYPE_COUNT) {
            log.warn(String.format(
                "Found %d types of reports for module/output %d/%d; expected %d",
                reportTypeSet.size(), ccdModule, ccdOutput, REPORT_TYPE_COUNT));

            // Since these are used in arrays, we can still create a valid
            // structure without them.
            reportTypeSet.add(TWO_D_BLACK);
            reportTypeSet.add(LDE_UNDERSHOOT);
        }

        if (reportTypeSet.size() != REPORT_TYPE_COUNT) {
            return false;
        }

        return true;
    }

    private PmdMetricReport[] createReports(
        Map<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reportMap,
        int ccdModule, int ccdOutput, ReportType type) {

        List<PmdMetricReport> reports = new ArrayList<PmdMetricReport>();
        int index = 0;
        PmdMetricReportKey key = new PmdMetricReportKey(ccdModule, ccdOutput,
            index, type);
        while (reportMap.containsKey(key)) {
            reports.add(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
                type));
            key = new PmdMetricReportKey(ccdModule, ccdOutput, ++index, type);
        }

        return reports.toArray(new PmdMetricReport[0]);
    }

    public List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> createReports(
        PipelineTask pipelineTask, TargetTable targetTable, int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();

        reports.addAll(getBlackCosmicRayMetrics().createReports(
            BLACK_COSMIC_RAY, pipelineTask, targetTable, ccdModule, ccdOutput,
            startCadence, endCadence));
        reports.addAll(getMaskedSmearCosmicRayMetrics().createReports(
            MASKED_SMEAR_COSMIC_RAY, pipelineTask, targetTable, ccdModule,
            ccdOutput, startCadence, endCadence));
        reports.addAll(getVirtualSmearCosmicRayMetrics().createReports(
            VIRTUAL_SMEAR_COSMIC_RAY, pipelineTask, targetTable, ccdModule,
            ccdOutput, startCadence, endCadence));

        reports.addAll(createReports(getTwoDBlack(), TWO_D_BLACK, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(createReports(getLdeUndershoot(), LDE_UNDERSHOOT,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));

        reports.add(getBlackLevel().createReport(BLACK_LEVEL, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.add(getDarkCurrent().createReport(DARK_CURRENT, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.add(getSmearLevel().createReport(SMEAR_LEVEL, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));

        reports.add(getTheoreticalCompressionEfficiency().createReport(
            THEORETICAL_COMPRESSION_EFFICIENCY, pipelineTask, targetTable,
            ccdModule, ccdOutput, startCadence, endCadence));
        reports.add(getAchievedCompressionEfficiency().createReport(
            ACHIEVED_COMPRESSION_EFFICIENCY, pipelineTask, targetTable,
            ccdModule, ccdOutput, startCadence, endCadence));

        reports.addAll(getBackgroundCosmicRayMetrics().createReports(
            BACKGROUND_COSMIC_RAY, pipelineTask, targetTable, ccdModule,
            ccdOutput, startCadence, endCadence));
        reports.addAll(getTargetStarCosmicRayMetrics().createReports(
            TARGET_STAR_COSMIC_RAY, pipelineTask, targetTable, ccdModule,
            ccdOutput, startCadence, endCadence));

        reports.add(getEncircledEnergy().createReport(ENCIRCLED_ENERGY,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getBrightness().createReport(BRIGHTNESS, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.add(getBackgroundLevel().createReport(BACKGROUND_LEVEL,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getCentroidsMeanRow().createReport(CENTROIDS_MEAN_ROW,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getCentroidsMeanColumn().createReport(
            CENTROIDS_MEAN_COLUMN, pipelineTask, targetTable, ccdModule,
            ccdOutput, startCadence, endCadence));
        reports.add(getPlateScale().createReport(PLATE_SCALE, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));

        reports.addAll(getCdppExpected().createReports(CDPP_EXPECTED,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.addAll(getCdppMeasured().createReports(CDPP_MEASURED,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.addAll(getCdppRatio().createReports(CDPP_RATIO, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));

        return reports;
    }

    private List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> createReports(
        PmdMetricReport[] metricReports, ReportType type,
        PipelineTask pipelineTask, TargetTable targetTable, int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();

        if (metricReports != null) {
            for (PmdMetricReport report : metricReports) {
                reports.add(report.createReport(type, pipelineTask,
                    targetTable, ccdModule, ccdOutput, startCadence, endCadence));
            }
        }

        return reports;
    }

    public Map<List<String>, List<ModuleAlert>> alerts() {
        Map<List<String>, List<ModuleAlert>> alerts = new HashMap<List<String>, List<ModuleAlert>>();

        alerts.putAll(getBlackCosmicRayMetrics().alerts(BLACK_COSMIC_RAY));
        alerts.putAll(getMaskedSmearCosmicRayMetrics().alerts(
            MASKED_SMEAR_COSMIC_RAY));
        alerts.putAll(getVirtualSmearCosmicRayMetrics().alerts(
            VIRTUAL_SMEAR_COSMIC_RAY));

        alerts.put(TWO_D_BLACK.toList(), alerts(getTwoDBlack()));
        alerts.put(LDE_UNDERSHOOT.toList(), alerts(getLdeUndershoot()));

        alerts.put(BLACK_LEVEL.toList(), getBlackLevel().getAlerts());
        alerts.put(DARK_CURRENT.toList(), getDarkCurrent().getAlerts());
        alerts.put(SMEAR_LEVEL.toList(), getSmearLevel().getAlerts());

        alerts.put(THEORETICAL_COMPRESSION_EFFICIENCY.toList(),
            getTheoreticalCompressionEfficiency().getAlerts());
        alerts.put(ACHIEVED_COMPRESSION_EFFICIENCY.toList(),
            getAchievedCompressionEfficiency().getAlerts());

        alerts.putAll(getBackgroundCosmicRayMetrics().alerts(
            BACKGROUND_COSMIC_RAY));
        alerts.putAll(getTargetStarCosmicRayMetrics().alerts(
            TARGET_STAR_COSMIC_RAY));

        alerts.put(ENCIRCLED_ENERGY.toList(), getEncircledEnergy().getAlerts());
        alerts.put(BRIGHTNESS.toList(), getBrightness().getAlerts());
        alerts.put(BACKGROUND_LEVEL.toList(), getBackgroundLevel().getAlerts());
        alerts.put(CENTROIDS_MEAN_ROW.toList(),
            getCentroidsMeanRow().getAlerts());
        alerts.put(CENTROIDS_MEAN_COLUMN.toList(),
            getCentroidsMeanColumn().getAlerts());
        alerts.put(PLATE_SCALE.toList(), getPlateScale().getAlerts());

        alerts.putAll(getCdppExpected().alerts(CDPP_EXPECTED));
        alerts.putAll(getCdppMeasured().alerts(CDPP_MEASURED));
        alerts.putAll(getCdppRatio().alerts(CDPP_RATIO));

        return alerts;
    }

    private List<ModuleAlert> alerts(PmdMetricReport[] metricReports) {
        List<ModuleAlert> alerts = new ArrayList<ModuleAlert>();

        if (metricReports != null) {
            for (PmdMetricReport report : metricReports) {
                alerts.addAll(report.getAlerts());
            }
        }

        return alerts;
    }

    public PmdEnergyDistributionReport getBlackCosmicRayMetrics() {
        return blackCosmicRayMetrics;
    }

    public void setBlackCosmicRayMetrics(
        PmdEnergyDistributionReport blackCosmicRayMetrics) {
        this.blackCosmicRayMetrics = blackCosmicRayMetrics;
    }

    public PmdEnergyDistributionReport getMaskedSmearCosmicRayMetrics() {
        return maskedSmearCosmicRayMetrics;
    }

    public void setMaskedSmearCosmicRayMetrics(
        PmdEnergyDistributionReport maskedSmearCosmicRayMetrics) {
        this.maskedSmearCosmicRayMetrics = maskedSmearCosmicRayMetrics;
    }

    public PmdEnergyDistributionReport getVirtualSmearCosmicRayMetrics() {
        return virtualSmearCosmicRayMetrics;
    }

    public void setVirtualSmearCosmicRayMetrics(
        PmdEnergyDistributionReport virtualSmearCosmicRayMetrics) {
        this.virtualSmearCosmicRayMetrics = virtualSmearCosmicRayMetrics;
    }

    public PmdMetricReport[] getTwoDBlack() {
        return twoDBlack;
    }

    public void setTwoDBlack(PmdMetricReport[] twoDBlack) {
        this.twoDBlack = twoDBlack;
    }

    public PmdMetricReport[] getLdeUndershoot() {
        return ldeUndershoot;
    }

    public void setLdeUndershoot(PmdMetricReport[] ldeUndershoot) {
        this.ldeUndershoot = ldeUndershoot;
    }

    public PmdMetricReport getBlackLevel() {
        return blackLevel;
    }

    public void setBlackLevel(PmdMetricReport blackLevel) {
        this.blackLevel = blackLevel;
    }

    public PmdMetricReport getDarkCurrent() {
        return darkCurrent;
    }

    public void setDarkCurrent(PmdMetricReport darkCurrent) {
        this.darkCurrent = darkCurrent;
    }

    public PmdMetricReport getSmearLevel() {
        return smearLevel;
    }

    public void setSmearLevel(PmdMetricReport smearLevel) {
        this.smearLevel = smearLevel;
    }

    public PmdMetricReport getTheoreticalCompressionEfficiency() {
        return theoreticalCompressionEfficiency;
    }

    public void setTheoreticalCompressionEfficiency(
        PmdMetricReport theoreticalCompressionEfficiency) {
        this.theoreticalCompressionEfficiency = theoreticalCompressionEfficiency;
    }

    public PmdMetricReport getAchievedCompressionEfficiency() {
        return achievedCompressionEfficiency;
    }

    public void setAchievedCompressionEfficiency(
        PmdMetricReport achievedCompressionEfficiency) {
        this.achievedCompressionEfficiency = achievedCompressionEfficiency;
    }

    public PmdEnergyDistributionReport getBackgroundCosmicRayMetrics() {
        return backgroundCosmicRayMetrics;
    }

    public void setBackgroundCosmicRayMetrics(
        PmdEnergyDistributionReport backgroundCosmicRayMetrics) {
        this.backgroundCosmicRayMetrics = backgroundCosmicRayMetrics;
    }

    public PmdEnergyDistributionReport getTargetStarCosmicRayMetrics() {
        return targetStarCosmicRayMetrics;
    }

    public void setTargetStarCosmicRayMetrics(
        PmdEnergyDistributionReport targetStarCosmicRayMetrics) {
        this.targetStarCosmicRayMetrics = targetStarCosmicRayMetrics;
    }

    public PmdMetricReport getEncircledEnergy() {
        return encircledEnergy;
    }

    public void setEncircledEnergy(PmdMetricReport encircledEnergy) {
        this.encircledEnergy = encircledEnergy;
    }

    public PmdMetricReport getBrightness() {
        return brightness;
    }

    public void setBrightness(PmdMetricReport brightness) {
        this.brightness = brightness;
    }

    public PmdMetricReport getBackgroundLevel() {
        return backgroundLevel;
    }

    public void setBackgroundLevel(PmdMetricReport backgroundLevel) {
        this.backgroundLevel = backgroundLevel;
    }

    public PmdMetricReport getCentroidsMeanRow() {
        return centroidsMeanRow;
    }

    public void setCentroidsMeanRow(PmdMetricReport centroidsMeanRow) {
        this.centroidsMeanRow = centroidsMeanRow;
    }

    public PmdMetricReport getCentroidsMeanColumn() {
        return centroidsMeanColumn;
    }

    public void setCentroidsMeanColumn(PmdMetricReport centroidsMeanColumn) {
        this.centroidsMeanColumn = centroidsMeanColumn;
    }

    public PmdMetricReport getPlateScale() {
        return plateScale;
    }

    public void setPlateScale(PmdMetricReport plateScale) {
        this.plateScale = plateScale;
    }

    public PmdCdppReport getCdppExpected() {
        return cdppExpected;
    }

    public void setCdppExpected(PmdCdppReport cdppExpected) {
        this.cdppExpected = cdppExpected;
    }

    public PmdCdppReport getCdppMeasured() {
        return cdppMeasured;
    }

    public void setCdppMeasured(PmdCdppReport cdppMeasured) {
        this.cdppMeasured = cdppMeasured;
    }

    public PmdCdppReport getCdppRatio() {
        return cdppRatio;
    }

    public void setCdppRatio(PmdCdppReport cdppReport) {
        cdppRatio = cdppReport;
    }
}
