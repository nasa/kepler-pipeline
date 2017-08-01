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

import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG10;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG11;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG12;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG13;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG14;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG15;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG9;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport;
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
 * CDPP report.
 * 
 * @author Bill Wohler
 */
public class PmdCdppReport implements Persistable {

    private PmdCdppMagReport mag9 = new PmdCdppMagReport();
    private PmdCdppMagReport mag10 = new PmdCdppMagReport();
    private PmdCdppMagReport mag11 = new PmdCdppMagReport();
    private PmdCdppMagReport mag12 = new PmdCdppMagReport();
    private PmdCdppMagReport mag13 = new PmdCdppMagReport();
    private PmdCdppMagReport mag14 = new PmdCdppMagReport();
    private PmdCdppMagReport mag15 = new PmdCdppMagReport();

    /**
     * Creates a {@link PmdCdppReport}.
     */
    public PmdCdppReport() {
    }

    /**
     * Creates a {@link PmdCdppReport}.
     * 
     * @param reportMap a map from {@link PmdMetricReportKey} to
     * {@link gov.nasa.kepler.hibernate.ppa.PmdMetricReport}
     * @param ccdModule the CCD module
     * @param ccdOutput the CCD output
     * @param type the report type
     */
    public PmdCdppReport(Map<PmdMetricReportKey, PmdMetricReport> reportMap,
        int ccdModule, int ccdOutput, ReportType type) {
        setMag9(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG9));
        setMag10(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG10));
        setMag11(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG11));
        setMag12(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG12));
        setMag13(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG13));
        setMag14(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG14));
        setMag15(new PmdCdppMagReport(reportMap, ccdModule, ccdOutput, type,
            MAG15));
    }

    public List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> createReports(
        ReportType type, PipelineTask pipelineTask, TargetTable targetTable,
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports = new ArrayList<gov.nasa.kepler.hibernate.ppa.PmdMetricReport>();

        reports.addAll(getMag9().createReports(type, MAG9, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(getMag10().createReports(type, MAG10, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(getMag11().createReports(type, MAG11, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(getMag12().createReports(type, MAG12, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(getMag13().createReports(type, MAG13, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(getMag14().createReports(type, MAG14, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));
        reports.addAll(getMag15().createReports(type, MAG15, pipelineTask,
            targetTable, ccdModule, ccdOutput, startCadence, endCadence));

        return reports;
    }

    public Map<List<String>, List<ModuleAlert>> alerts(ReportType type) {
        Map<List<String>, List<ModuleAlert>> alerts = new HashMap<List<String>, List<ModuleAlert>>();

        alerts.putAll(getMag9().alerts(type, MAG9));
        alerts.putAll(getMag10().alerts(type, MAG10));
        alerts.putAll(getMag11().alerts(type, MAG11));
        alerts.putAll(getMag12().alerts(type, MAG12));
        alerts.putAll(getMag13().alerts(type, MAG13));
        alerts.putAll(getMag14().alerts(type, MAG14));
        alerts.putAll(getMag15().alerts(type, MAG15));

        return alerts;
    }

    public PmdCdppMagReport getMag9() {
        return mag9;
    }

    public void setMag9(PmdCdppMagReport mag9) {
        this.mag9 = mag9;
    }

    public PmdCdppMagReport getMag10() {
        return mag10;
    }

    public void setMag10(PmdCdppMagReport mag10) {
        this.mag10 = mag10;
    }

    public PmdCdppMagReport getMag11() {
        return mag11;
    }

    public void setMag11(PmdCdppMagReport mag11) {
        this.mag11 = mag11;
    }

    public PmdCdppMagReport getMag12() {
        return mag12;
    }

    public void setMag12(PmdCdppMagReport mag12) {
        this.mag12 = mag12;
    }

    public PmdCdppMagReport getMag13() {
        return mag13;
    }

    public void setMag13(PmdCdppMagReport mag13) {
        this.mag13 = mag13;
    }

    public PmdCdppMagReport getMag14() {
        return mag14;
    }

    public void setMag14(PmdCdppMagReport mag14) {
        this.mag14 = mag14;
    }

    public PmdCdppMagReport getMag15() {
        return mag15;
    }

    public void setMag15(PmdCdppMagReport mag15) {
        this.mag15 = mag15;
    }
}
