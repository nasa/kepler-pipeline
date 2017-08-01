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

package gov.nasa.kepler.ppa.pag;

import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CCD_MOD_OUT_ALL;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.ACHIEVED_COMPRESSION_EFFICIENCY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.THEORETICAL_COMPRESSION_EFFICIENCY;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.ppa.pmd.PmdMetricReport;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Complete metric report for the entire focal plane.
 * 
 * @author Bill Wohler
 */
public class PagReport implements Persistable {

    /**
     * Theoretical compression efficiency report.
     */
    private PmdMetricReport theoreticalCompressionEfficiency = new PmdMetricReport();

    /**
     * Achieved compression efficiency report.
     */
    private PmdMetricReport achievedCompressionEfficiency = new PmdMetricReport();

    public List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> createReports(
        PipelineTask pipelineTask, TargetTable targetTable, int startCadence,
        int endCadence) {

        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();

        reports.add(getTheoreticalCompressionEfficiency().createReport(
            THEORETICAL_COMPRESSION_EFFICIENCY, pipelineTask, targetTable,
            CCD_MOD_OUT_ALL, CCD_MOD_OUT_ALL, startCadence, endCadence));
        reports.add(getAchievedCompressionEfficiency().createReport(
            ACHIEVED_COMPRESSION_EFFICIENCY, pipelineTask, targetTable,
            CCD_MOD_OUT_ALL, CCD_MOD_OUT_ALL, startCadence, endCadence));

        return reports;
    }

    public Map<List<String>, List<ModuleAlert>> alerts() {

        Map<List<String>, List<ModuleAlert>> alerts = new HashMap<List<String>, List<ModuleAlert>>();

        alerts.put(THEORETICAL_COMPRESSION_EFFICIENCY.toList(),
            getTheoreticalCompressionEfficiency().getAlerts());
        alerts.put(ACHIEVED_COMPRESSION_EFFICIENCY.toList(),
            getAchievedCompressionEfficiency().getAlerts());

        return alerts;
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
}
