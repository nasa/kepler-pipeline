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

import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution.ENERGY_KURTOSIS;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution.ENERGY_SKEWNESS;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution.ENERGY_VARIANCE;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution.HIT_RATE;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution.MEAN_ENERGY;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.ppa.pag.PmdMetricReportKey;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Energy distribution report for a given type of collateral data.
 * 
 * @author Bill Wohler
 */
public class PmdEnergyDistributionReport implements Persistable {

    private PmdMetricReport hitRate = new PmdMetricReport();
    private PmdMetricReport meanEnergy = new PmdMetricReport();
    private PmdMetricReport energyVariance = new PmdMetricReport();
    private PmdMetricReport energySkewness = new PmdMetricReport();
    private PmdMetricReport energyKurtosis = new PmdMetricReport();

    /**
     * Creates a {@link PmdEnergyDistributionReport}.
     */
    public PmdEnergyDistributionReport() {
    }

    /**
     * Creates a {@link PmdEnergyDistributionReport}.
     * 
     * @param reportMap a map from {@link PmdMetricReportKey} to
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param type the report type
     */
    public PmdEnergyDistributionReport(
        Map<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reportMap,
        int ccdModule, int ccdOutput, ReportType type) {

        setHitRate(new PmdMetricReport(reportMap, ccdModule, ccdOutput, type,
            HIT_RATE.toString()));
        setMeanEnergy(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            type, MEAN_ENERGY.toString()));
        setEnergyVariance(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            type, ENERGY_VARIANCE.toString()));
        setEnergySkewness(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            type, ENERGY_SKEWNESS.toString()));
        setEnergyKurtosis(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            type, ENERGY_KURTOSIS.toString()));
    }

    public List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> createReports(
        ReportType type, PipelineTask pipelineTask, TargetTable targetTable,
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();

        reports.add(getHitRate().createReport(type, HIT_RATE, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.add(getMeanEnergy().createReport(type, MEAN_ENERGY,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getEnergyVariance().createReport(type, ENERGY_VARIANCE,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getEnergySkewness().createReport(type, ENERGY_SKEWNESS,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getEnergyKurtosis().createReport(type, ENERGY_KURTOSIS,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));

        return reports;
    }

    public Map<List<String>, List<ModuleAlert>> alerts(ReportType type) {
        Map<List<String>, List<ModuleAlert>> alerts = new HashMap<List<String>, List<ModuleAlert>>();

        alerts.put(append(type.toList(), HIT_RATE), getHitRate().getAlerts());
        alerts.put(append(type.toList(), MEAN_ENERGY),
            getMeanEnergy().getAlerts());
        alerts.put(append(type.toList(), ENERGY_VARIANCE),
            getEnergyVariance().getAlerts());
        alerts.put(append(type.toList(), ENERGY_SKEWNESS),
            getEnergySkewness().getAlerts());
        alerts.put(append(type.toList(), ENERGY_KURTOSIS),
            getEnergyKurtosis().getAlerts());

        return alerts;
    }

    private List<String> append(List<String> list,
        EnergyDistribution energyDistribution) {
        list.add(energyDistribution.toString());
        return list;
    }

    public PmdMetricReport getHitRate() {
        return hitRate;
    }

    public void setHitRate(PmdMetricReport hitRate) {
        this.hitRate = hitRate;
    }

    public PmdMetricReport getMeanEnergy() {
        return meanEnergy;
    }

    public void setMeanEnergy(PmdMetricReport meanEnergy) {
        this.meanEnergy = meanEnergy;
    }

    public PmdMetricReport getEnergyVariance() {
        return energyVariance;
    }

    public void setEnergyVariance(PmdMetricReport energyVariance) {
        this.energyVariance = energyVariance;
    }

    public PmdMetricReport getEnergySkewness() {
        return energySkewness;
    }

    public void setEnergySkewness(PmdMetricReport energySkewness) {
        this.energySkewness = energySkewness;
    }

    public PmdMetricReport getEnergyKurtosis() {
        return energyKurtosis;
    }

    public void setEnergyKurtosis(PmdMetricReport energyKurtosis) {
        this.energyKurtosis = energyKurtosis;
    }
}
