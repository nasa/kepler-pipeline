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

package gov.nasa.kepler.hibernate.ppa;

import static gov.nasa.kepler.hibernate.ppa.PadMetricReport.ReportType.DELTA_DEC;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration.SIX_HOUR;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude.MAG12;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution.ENERGY_KURTOSIS;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BACKGROUND_LEVEL;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.BLACK_COSMIC_RAY;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.CDPP_MEASURED;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests of the PPA data model.
 * 
 * @author Forrest Giroaurd (fgirouard)
 */
public class PpaCrudTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PpaCrudTest.class);

    private static final int START_CADENCE = 1440;
    private static final int UOW_CADENCE_SIZE = 1439;
    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;
    private static final gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType PMD_REPORT_TYPE = BACKGROUND_LEVEL;
    private static final gov.nasa.kepler.hibernate.ppa.PadMetricReport.ReportType PAD_REPORT_TYPE = DELTA_DEC;

    private DatabaseService databaseService;
    private PpaCrud ppaCrud;
    private TargetCrud targetCrud;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;

    private TargetTable targetTable1;
    private TargetTable targetTable2;
    private TargetTable targetTable3;

    private PmdMetricReport pmdMetricReport12;
    private PmdMetricReport pmdMetricReport21;
    private PmdMetricReport pmdMetricReport22;
    private List<PmdMetricReport> pmdMetricReportsList;

    private PadMetricReport padMetricReport12;
    private PadMetricReport padMetricReport13;
    private List<PadMetricReport> padMetricReportsList;

    @Before
    public void setUp() {
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        ppaCrud = new PpaCrud(databaseService);
        targetCrud = new TargetCrud(databaseService);

        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() {
        if (databaseService != null) {
            TestUtils.tearDownDatabase(databaseService);
        }
    }

    private PipelineInstance createPipelineInstance() {
        PipelineInstance pipelineInstance = new PipelineInstance();

        PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud(
            databaseService);

        try {
            databaseService.beginTransaction();
            instanceCrud.create(pipelineInstance);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        // pipelineInstance = instanceCrud.retrieve(pipelineInstance.getId());

        return pipelineInstance;
    }

    private PipelineTask createPipelineTask(PipelineInstance pipelineInstance) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setPipelineInstance(pipelineInstance);

        PipelineTaskCrud taskCrud = new PipelineTaskCrud(databaseService);

        try {
            databaseService.beginTransaction();
            taskCrud.create(pipelineTask);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        // pipelineTask = taskCrud.retrieve(pipelineTask.getId());

        return pipelineTask;
    }

    private void createTargetTables(TargetType type) {
        try {
            databaseService.beginTransaction();

            targetTable1 = new TargetTable(type);
            targetTable1.setExternalId(1);
            targetCrud.createTargetTable(targetTable1);

            targetTable2 = new TargetTable(type);
            targetTable2.setExternalId(2);
            targetCrud.createTargetTable(targetTable2);

            targetTable3 = new TargetTable(type);
            targetCrud.createTargetTable(targetTable3);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private void populateMetricReports() {
        pipelineInstance = createPipelineInstance();
        pipelineTask = createPipelineTask(pipelineInstance);
        pipelineTask.setPipelineInstance(pipelineInstance);
        createTargetTables(TargetType.LONG_CADENCE);

        pmdMetricReportsList = new ArrayList<PmdMetricReport>();
        pmdMetricReport12 = createPmdMetricReport(PMD_REPORT_TYPE,
            START_CADENCE);
        pmdMetricReportsList.add(pmdMetricReport12);
        pmdMetricReport21 = createPmdMetricReport(BLACK_COSMIC_RAY,
            ENERGY_KURTOSIS, START_CADENCE);
        pmdMetricReportsList.add(pmdMetricReport21);
        pmdMetricReport22 = createPmdMetricReport(CDPP_MEASURED, MAG12,
            SIX_HOUR, START_CADENCE);
        pmdMetricReportsList.add(pmdMetricReport22);

        padMetricReportsList = new ArrayList<PadMetricReport>();
        padMetricReport12 = createPadMetricReport(START_CADENCE);
        padMetricReportsList.add(padMetricReport12);
        padMetricReport13 = createPadMetricReport(START_CADENCE
            + UOW_CADENCE_SIZE + 1);
        padMetricReportsList.add(padMetricReport13);
    }

    private PmdMetricReport createPmdMetricReport(ReportType type,
        int startCadence) {
        PmdMetricReport metricReport = new PmdMetricReport.Builder(
            pipelineTask, targetTable1, CCD_MODULE, CCD_OUTPUT, startCadence,
            startCadence + UOW_CADENCE_SIZE - 1).type(type)
            .build();

        return metricReport;
    }

    private PmdMetricReport createPmdMetricReport(ReportType type,
        EnergyDistribution energyDistribution, int startCadence) {
        PmdMetricReport metricReport = new PmdMetricReport.Builder(
            pipelineTask, targetTable1, CCD_MODULE, CCD_OUTPUT, startCadence,
            startCadence + UOW_CADENCE_SIZE - 1).type(type)
            .subtype(energyDistribution)
            .build();

        return metricReport;
    }

    private PmdMetricReport createPmdMetricReport(ReportType type,
        CdppMagnitude magnitude, CdppDuration duration, int startCadence) {
        PmdMetricReport metricReport = new PmdMetricReport.Builder(
            pipelineTask, targetTable1, CCD_MODULE, CCD_OUTPUT, startCadence,
            startCadence + UOW_CADENCE_SIZE - 1).type(type)
            .subtype(magnitude)
            .subtype(duration)
            .build();

        return metricReport;
    }

    private PadMetricReport createPadMetricReport(int startCadence) {
        PadMetricReport metricReport = new PadMetricReport.Builder(
            pipelineTask, targetTable1, startCadence, startCadence
                + UOW_CADENCE_SIZE - 1).type(PAD_REPORT_TYPE)
            .build();

        return metricReport;
    }

    @Test(expected = HibernateException.class)
    public void createMetricReportWithEmptyDatabase() throws Throwable {
        try {
            databaseService.beginTransaction();
            databaseService.getDdlInitializer()
                .cleanDB();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        createMetricReport();
    }

    @Test
    public void createMetricReport() {
        populateMetricReports();

        try {
            databaseService.beginTransaction();
            ppaCrud.createMetricReport(pmdMetricReport12);
            ppaCrud.createMetricReport(padMetricReport12);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    @Test
    public void createMetricReports() {
        populateMetricReports();

        try {
            databaseService.beginTransaction();
            ppaCrud.createMetricReports(pmdMetricReportsList);
            ppaCrud.createMetricReports(padMetricReportsList);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    @Test(expected = NullPointerException.class)
    public void storeNullPmdMetricReport() {

        try {
            databaseService.beginTransaction();
            ppaCrud.createMetricReport((PmdMetricReport) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = NullPointerException.class)
    public void storeNullPadMetricReport() {

        try {
            databaseService.beginTransaction();
            ppaCrud.createMetricReport((PadMetricReport) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void storeEmptyPmdMetricReports() {

        try {
            databaseService.beginTransaction();
            ppaCrud.createMetricReports(new ArrayList<PmdMetricReport>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void storeEmptyPadMetricReports() {

        try {
            databaseService.beginTransaction();
            ppaCrud.createMetricReports(new ArrayList<PadMetricReport>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void retrieveMetricReports() {

        // Empty database.
        List<? extends MetricReport> metricReports = ppaCrud.retrievePmdMetricReports(pipelineInstance);
        assertTrue(metricReports.isEmpty());

        // Add metricReportsList to database.
        createMetricReports();

        // Get metric reports from database.
        metricReports = ppaCrud.retrievePmdMetricReports(pipelineInstance);
        assertFalse(metricReports.isEmpty());
        assertEquals(pmdMetricReportsList, metricReports);
        assertEquals(3, metricReports.size());

        PmdMetricReport pmdMetricReport = (PmdMetricReport) metricReports.get(0);
        assertEquals(pmdMetricReport12, pmdMetricReport);
        assertNotNull(pmdMetricReport.getPipelineTask());
        assertEquals(pipelineTask.getId(), pmdMetricReport.getPipelineTask()
            .getId());
        assertEquals(PMD_REPORT_TYPE, pmdMetricReport.getType());
        pmdMetricReport = (PmdMetricReport) metricReports.get(1);
        assertEquals(pmdMetricReport21, pmdMetricReport);
        assertEquals(BLACK_COSMIC_RAY, pmdMetricReport.getType());
        assertEquals(1, pmdMetricReport.getSubTypes()
            .size());
        assertTrue("energy kurtosis in subtypes", pmdMetricReport.getSubTypes()
            .contains(ENERGY_KURTOSIS.toString()));
        pmdMetricReport = (PmdMetricReport) metricReports.get(2);
        assertEquals(pmdMetricReport22, pmdMetricReport);
        assertEquals(CDPP_MEASURED, pmdMetricReport.getType());
        assertEquals(2, pmdMetricReport.getSubTypes()
            .size());
        assertTrue("magnitude in subtypes", pmdMetricReport.getSubTypes()
            .contains(MAG12.toString()));
        assertTrue("duration in subtypes", pmdMetricReport.getSubTypes()
            .contains(SIX_HOUR.toString()));
    }

    @Test
    public void retrieveEmptyMetricReports() {

        // Add metricReportsList to database.
        createMetricReports();

        // Get PMD records for pipeline instance with no records.
        List<? extends MetricReport> metricReports = ppaCrud.retrievePmdMetricReports(createPipelineInstance());
        assertTrue(metricReports.isEmpty());
    }
}
