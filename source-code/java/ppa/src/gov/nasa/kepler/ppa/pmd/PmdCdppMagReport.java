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

import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration.SIX_HOUR;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration.THREE_HOUR;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration.TWELVE_HOUR;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
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
 * CDPP report for a single magnitude.
 * 
 * @author Bill Wohler
 */
public class PmdCdppMagReport implements Persistable {

    private PmdMetricReport threeHour = new PmdMetricReport();
    private PmdMetricReport sixHour = new PmdMetricReport();
    private PmdMetricReport twelveHour = new PmdMetricReport();

    /**
     * Creates a {@link PmdCdppMagReport}.
     */
    public PmdCdppMagReport() {
    }

    /**
     * Creates a {@link PmdCdppMagReport}.
     * 
     * @param reportMap a map from {@link PmdMetricReportKey} to
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param type the report type
     * @param mag the magnitude
     */
    public PmdCdppMagReport(
        Map<PmdMetricReportKey, gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reportMap,
        int ccdModule, int ccdOutput, ReportType type, CdppMagnitude mag) {

        setThreeHour(new PmdMetricReport(reportMap, ccdModule, ccdOutput, type,
            mag.toString(), THREE_HOUR.toString()));
        setSixHour(new PmdMetricReport(reportMap, ccdModule, ccdOutput, type,
            mag.toString(), SIX_HOUR.toString()));
        setTwelveHour(new PmdMetricReport(reportMap, ccdModule, ccdOutput,
            type, mag.toString(), TWELVE_HOUR.toString()));
    }

    public List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> createReports(
        ReportType type, CdppMagnitude magnitude, PipelineTask pipelineTask,
        TargetTable targetTable, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {

        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();

        reports.add(getThreeHour().createReport(type, magnitude, THREE_HOUR,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getSixHour().createReport(type, magnitude, SIX_HOUR,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));
        reports.add(getTwelveHour().createReport(type, magnitude, TWELVE_HOUR,
            pipelineTask, targetTable, ccdModule, ccdOutput, startCadence,
            endCadence));

        return reports;
    }

    public Map<List<String>, List<ModuleAlert>> alerts(ReportType type,
        CdppMagnitude magnitude) {

        Map<List<String>, List<ModuleAlert>> alerts = new HashMap<List<String>, List<ModuleAlert>>();

        alerts.put(append(type.toList(), magnitude, THREE_HOUR),
            getThreeHour().getAlerts());
        alerts.put(append(type.toList(), magnitude, SIX_HOUR),
            getSixHour().getAlerts());
        alerts.put(append(type.toList(), magnitude, TWELVE_HOUR),
            getTwelveHour().getAlerts());

        return alerts;
    }

    private List<String> append(List<String> list, CdppMagnitude magnitude,
        CdppDuration duration) {
        list.add(magnitude.toString());
        list.add(duration.toString());
        return list;
    }

    public PmdMetricReport getThreeHour() {
        return threeHour;
    }

    public void setThreeHour(PmdMetricReport threeHour) {
        this.threeHour = threeHour;
    }

    public PmdMetricReport getSixHour() {
        return sixHour;
    }

    public void setSixHour(PmdMetricReport sixHour) {
        this.sixHour = sixHour;
    }

    public PmdMetricReport getTwelveHour() {
        return twelveHour;
    }

    public void setTwelveHour(PmdMetricReport twelveHour) {
        this.twelveHour = twelveHour;
    }
}
