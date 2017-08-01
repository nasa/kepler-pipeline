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

package gov.nasa.kepler.hibernate.pdq;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests of the PDQ data model.
 * 
 * @author Forrest Giroaurd (fgirouard)
 * 
 */
public class PdqCrudTest {

    private static final int CCD_MODULE = 7;
    private static final int CCD_OUTPUT = 2;
    private static final double DEFAULT_OFFSET = 1.0;
    private static final double DEFAULT_MJD = ModifiedJulianDate.dateToMjd(new Date());

    private DatabaseService databaseService;
    private PdqCrud pdqCrud;

    private AttitudeAdjustment attitudeAdjustment12;
    private AttitudeAdjustment attitudeAdjustment13;
    private List<AttitudeAdjustment> attitudeAdjustments1;
    private List<AttitudeAdjustment> attitudeAdjustments2;
    private List<AttitudeAdjustment> attitudeAdjustments3;
    private AttitudeAdjustment latestAttitudeAdjustment;

    private ModuleOutputMetricReport moduleOutputMetricReport;
    private List<ModuleOutputMetricReport> moduleOutputMetricReports;

    private FocalPlaneMetricReport focalPlaneMetricReport;
    private List<FocalPlaneMetricReport> focalPlaneMetricReports;

    private PipelineTask pipelineTask;
    private TargetTable targetTable;

    @Before
    public void setUp() throws Exception {

        databaseService = DatabaseServiceFactory.getInstance();
        pdqCrud = new PdqCrud(databaseService);

        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void createAttitudeAdjustment() {

        populateAttitudeAdjustments();
        try {
            databaseService.beginTransaction();

            RefPixelLog refPixelLog = new RefPixelLog();
            refPixelLog.setMjd(ModifiedJulianDate.dateToMjd(new Date()));
            new LogCrud().createRefPixelLog(refPixelLog);
            attitudeAdjustment12.setRefPixelLog(refPixelLog);
            pdqCrud.createAttitudeAdjustment(attitudeAdjustment12);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createAttitudeAdjustments1() {

        populateAttitudeAdjustments();
        try {
            databaseService.beginTransaction();
            createAttitudeAdjustments(DEFAULT_MJD + DEFAULT_OFFSET,
                attitudeAdjustments1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = NullPointerException.class)
    public void createNullAttitudeAdjustment() {

        try {
            databaseService.beginTransaction();
            pdqCrud.createAttitudeAdjustment((AttitudeAdjustment) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void retrieveIllegalAttitudeAdjustments() {

        pdqCrud.retrieveAttitudeAdjustments(DEFAULT_MJD, DEFAULT_MJD
            - DEFAULT_OFFSET);
    }

    @Test
    public void retrieveAttitudeAdjustments() {

        // empty database
        List<AttitudeAdjustment> attitudeAdjustments = pdqCrud.retrieveAttitudeAdjustments(
            DEFAULT_MJD, DEFAULT_MJD + DEFAULT_OFFSET);
        assertNotNull(attitudeAdjustments);
        assertTrue(attitudeAdjustments.isEmpty());

        // add attitudeAdjustments1 to database
        createAttitudeAdjustments1();
        databaseService.closeCurrentSession();

        // get attitudeAdjustments1 from database
        attitudeAdjustments = pdqCrud.retrieveAttitudeAdjustments(DEFAULT_MJD,
            DEFAULT_MJD + DEFAULT_OFFSET + 1);
        assertNotNull(attitudeAdjustments);
        assertFalse(attitudeAdjustments.isEmpty());
        assertEquals(attitudeAdjustments1, attitudeAdjustments);

        attitudeAdjustments = pdqCrud.retrieveAttitudeAdjustments(DEFAULT_MJD
            - DEFAULT_OFFSET, DEFAULT_MJD);
        assertNotNull(attitudeAdjustments);
        assertTrue(attitudeAdjustments.isEmpty());
    }

    @Test
    public void createAttitudeAdjustmentsAll() {

        populateAttitudeAdjustments();
        try {
            databaseService.beginTransaction();
            double mjd = DEFAULT_MJD + DEFAULT_OFFSET;
            createAttitudeAdjustments(mjd, attitudeAdjustments1);
            mjd += attitudeAdjustments1.size();
            createAttitudeAdjustments(mjd, attitudeAdjustments2);
            mjd += attitudeAdjustments2.size();
            createAttitudeAdjustments(mjd, attitudeAdjustments3);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void retrieveAttitudeAdjustments2() {

        // empty database
        List<AttitudeAdjustment> attitudeAdjustments = pdqCrud.retrieveAttitudeAdjustments(
            DEFAULT_MJD - DEFAULT_OFFSET, DEFAULT_MJD);
        assertNotNull(attitudeAdjustments);
        assertTrue(attitudeAdjustments.isEmpty());

        AttitudeAdjustment attitudeAdjustment = pdqCrud.retrieveLatestAttitudeAdjustment();
        assertNull(attitudeAdjustment);

        // add all attitude adjustments to database
        createAttitudeAdjustmentsAll();
        databaseService.closeCurrentSession();

        // get all attitude adjustments
        attitudeAdjustments = pdqCrud.retrieveAttitudeAdjustments(DEFAULT_MJD,
            DEFAULT_MJD + DEFAULT_OFFSET + 5);
        assertNotNull(attitudeAdjustments);
        assertFalse(attitudeAdjustments.isEmpty());
        assertEquals(6, attitudeAdjustments.size());

        attitudeAdjustments = pdqCrud.retrieveAttitudeAdjustments(DEFAULT_MJD
            + DEFAULT_OFFSET + 2, DEFAULT_MJD + DEFAULT_OFFSET + 3);
        assertNotNull(attitudeAdjustments);
        assertFalse(attitudeAdjustments.isEmpty());
        assertEquals(2, attitudeAdjustments.size());

        attitudeAdjustment = pdqCrud.retrieveLatestAttitudeAdjustment();
        assertNotNull(attitudeAdjustment);
        assertEquals(latestAttitudeAdjustment, attitudeAdjustment);

        attitudeAdjustments = pdqCrud.retrieveLatestAttitudeAdjustments(2);
        assertNotNull(attitudeAdjustment);
        assertEquals(2, attitudeAdjustments.size());
        assertEquals(latestAttitudeAdjustment, attitudeAdjustments.get(0));
    }

    private void populateAttitudeAdjustments() {

        AttitudeAdjustment aa = null;

        attitudeAdjustments1 = new ArrayList<AttitudeAdjustment>();
        attitudeAdjustment12 = PdqSeed.createAttitudeAdjustment(1.2);
        attitudeAdjustments1.add(attitudeAdjustment12);
        attitudeAdjustment13 = PdqSeed.createAttitudeAdjustment(1.3);
        attitudeAdjustments1.add(attitudeAdjustment13);

        attitudeAdjustments2 = new ArrayList<AttitudeAdjustment>();
        aa = PdqSeed.createAttitudeAdjustment(2.0);
        attitudeAdjustments2.add(aa);
        aa = PdqSeed.createAttitudeAdjustment(2.1);
        attitudeAdjustments2.add(aa);

        attitudeAdjustments3 = new ArrayList<AttitudeAdjustment>();
        aa = PdqSeed.createAttitudeAdjustment(3.0);
        attitudeAdjustments3.add(aa);
        aa = PdqSeed.createAttitudeAdjustment(3.1);
        attitudeAdjustments3.add(aa);

        latestAttitudeAdjustment = aa;
    }

    @Test
    public void createModuleOutputMetricReport() {

        populateModuleOutputMetricReports();
        try {
            databaseService.beginTransaction();
            pdqCrud.createModuleOutputMetricReport(moduleOutputMetricReport);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createModuleOutputMetricReports() {

        populateModuleOutputMetricReports();
        try {
            databaseService.beginTransaction();
            pdqCrud.createModuleOutputMetricReports(moduleOutputMetricReports);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = NullPointerException.class)
    public void createNullModuleOutputMetricReport() {

        try {
            databaseService.beginTransaction();
            pdqCrud.createModuleOutputMetricReport((ModuleOutputMetricReport) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void retrieveIllegalModuleOutputMetricReports() {

        TargetTable targetTable = new TargetTable(TargetType.BACKGROUND);
        pdqCrud.retrieveModuleOutputMetricReports(targetTable);
    }

    @Test
    public void retrieveModuleOutputMetricReports() {

        populateModuleOutputMetricReports();

        // empty database
        List<ModuleOutputMetricReport> moduleOutputMetricReports2 = pdqCrud.retrieveModuleOutputMetricReports(targetTable);
        assertNotNull(moduleOutputMetricReports2);
        assertTrue(moduleOutputMetricReports2.isEmpty());

        // add metricReports1 to database
        createModuleOutputMetricReports();
        databaseService.closeCurrentSession();

        // get metric report from database
        moduleOutputMetricReports2 = pdqCrud.retrieveModuleOutputMetricReports(targetTable);
        assertNotNull(moduleOutputMetricReports2);
        assertFalse(moduleOutputMetricReports2.isEmpty());
        assertEquals(moduleOutputMetricReports, moduleOutputMetricReports2);

        // get multiple metric reports from database
        ModuleOutputMetricReport mr = PdqSeed.createModuleOutputMetricReport(
            pipelineTask, targetTable,
            ModuleOutputMetricReport.MetricType.SMEAR_LEVEL, CCD_MODULE,
            CCD_OUTPUT, 45.6F, 3.0F);
        pdqCrud.createModuleOutputMetricReport(mr);
        List<ModuleOutputMetricReport> moduleOutputMetricReportsAll = pdqCrud.retrieveModuleOutputMetricReports(targetTable);
        assertNotNull(moduleOutputMetricReportsAll);
        assertFalse(moduleOutputMetricReportsAll.isEmpty());
        assertEquals(2, moduleOutputMetricReportsAll.size());

        // get specific metric report from database
        ModuleOutputMetricReport mr1 = pdqCrud.retrieveModuleOutputMetricReport(
            targetTable, ModuleOutputMetricReport.MetricType.SMEAR_LEVEL,
            CCD_MODULE, CCD_OUTPUT);
        assertNotNull(mr1);
        assertEquals(mr, mr1);
    }

    @Test
    public void deleteModuleOutputMetricReports() {

        populateModuleOutputMetricReports();

        // add metricReports1 to database
        createModuleOutputMetricReports();
        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<ModuleOutputMetricReport> reports = pdqCrud.retrieveModuleOutputMetricReports(targetTable);
            assertNotNull(reports);
            assertTrue(reports.size() > 0);
            pdqCrud.deleteModuleOutputMetricReports(targetTable);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<ModuleOutputMetricReport> reports = pdqCrud.retrieveModuleOutputMetricReports(targetTable);
        assertNotNull(reports);
        assertTrue(reports.isEmpty());
    }

    private void populateModuleOutputMetricReports() {

        createTargetTable();
        createPipelineTask();
        moduleOutputMetricReports = new ArrayList<ModuleOutputMetricReport>();
        moduleOutputMetricReport = new ModuleOutputMetricReport.Builder(
            pipelineTask, targetTable, CCD_MODULE, CCD_OUTPUT).type(
            ModuleOutputMetricReport.MetricType.BACKGROUND_LEVEL)
            .value(42.0F)
            .uncertainty(0.0004F)
            .adaptiveBoundsReport(PdqSeed.createBoundsReport(10.0F, 50.0F))
            .fixedBoundsReport(PdqSeed.createBoundsReport(100.0F, 500.0F))
            .build();
        moduleOutputMetricReports.add(moduleOutputMetricReport);
    }

    @Test
    public void createFocalPlaneMetricReport() {

        populateFocalPlaneMetricReports();
        try {
            databaseService.beginTransaction();
            pdqCrud.createFocalPlaneMetricReport(focalPlaneMetricReport);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createFocalPlaneMetricReports() {

        populateFocalPlaneMetricReports();
        try {
            databaseService.beginTransaction();
            pdqCrud.createFocalPlaneMetricReports(focalPlaneMetricReports);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = NullPointerException.class)
    public void createNullFocalPlaneMetricReport() {

        try {
            databaseService.beginTransaction();
            pdqCrud.createFocalPlaneMetricReport((FocalPlaneMetricReport) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void retrieveIllegalFocalPlaneMetricReports() {

        TargetTable targetTable = new TargetTable(TargetType.BACKGROUND);
        pdqCrud.retrieveFocalPlaneMetricReports(targetTable);
    }

    @Test
    public void retrieveFocalPlaneMetricReports() {

        populateFocalPlaneMetricReports();

        // empty database
        List<FocalPlaneMetricReport> focalPlaneMetricReports2 = pdqCrud.retrieveFocalPlaneMetricReports(targetTable);
        assertNotNull(focalPlaneMetricReports2);
        assertTrue(focalPlaneMetricReports2.isEmpty());

        // add metricReports1 to database
        createFocalPlaneMetricReports();
        databaseService.closeCurrentSession();

        // get metric report from database
        focalPlaneMetricReports2 = pdqCrud.retrieveFocalPlaneMetricReports(targetTable);
        assertNotNull(focalPlaneMetricReports2);
        assertFalse(focalPlaneMetricReports2.isEmpty());
        assertEquals(focalPlaneMetricReports, focalPlaneMetricReports2);

        // get multiple metric reports from database
        FocalPlaneMetricReport mr = new FocalPlaneMetricReport.Builder(
            pipelineTask, targetTable).type(
            FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_ROLL)
            .value(45.6F)
            .uncertainty(3.0F)
            .build();
        pdqCrud.createFocalPlaneMetricReport(mr);
        List<FocalPlaneMetricReport> focalPlaneMetricReportsAll = pdqCrud.retrieveFocalPlaneMetricReports(targetTable);
        assertNotNull(focalPlaneMetricReportsAll);
        assertFalse(focalPlaneMetricReportsAll.isEmpty());
        assertEquals(2, focalPlaneMetricReportsAll.size());

        // get specific metric report from database
        FocalPlaneMetricReport mr1 = pdqCrud.retrieveFocalPlaneMetricReport(
            targetTable, FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_ROLL);
        assertNotNull(mr1);
        assertEquals(mr, mr1);
    }

    @Test
    public void deleteFocalPlaneMetricReports() {

        populateFocalPlaneMetricReports();

        // add metricReports1 to database
        createFocalPlaneMetricReports();
        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<FocalPlaneMetricReport> reports = pdqCrud.retrieveFocalPlaneMetricReports(targetTable);
            assertNotNull(reports);
            assertTrue(reports.size() > 0);
            pdqCrud.deleteFocalPlaneMetricReports(targetTable);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<FocalPlaneMetricReport> reports = pdqCrud.retrieveFocalPlaneMetricReports(targetTable);
        assertNotNull(reports);
        assertTrue(reports.isEmpty());
    }

    private void populateFocalPlaneMetricReports() {

        createTargetTable();
        createPipelineTask();
        focalPlaneMetricReports = new ArrayList<FocalPlaneMetricReport>();
        focalPlaneMetricReport = new FocalPlaneMetricReport.Builder(
            pipelineTask, targetTable).type(
            FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_RA)
            .value(42.0F)
            .uncertainty(4.0F)
            .time(55473.0)
            .adaptiveBoundsReport(PdqSeed.createBoundsReport(10.0F, 50.0F))
            .fixedBoundsReport(PdqSeed.createBoundsReport(100.0F, 500.0F))
            .build();
        focalPlaneMetricReports.add(focalPlaneMetricReport);
    }

    private void createTargetTable() {

        targetTable = new TargetTable(TargetType.REFERENCE_PIXEL);
        targetTable.setExternalId(1);
        try {
            databaseService.beginTransaction();
            new TargetCrud(databaseService).createTargetTable(targetTable);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private void createPipelineTask() {

        pipelineTask = new PipelineTask();
        try {
            databaseService.beginTransaction();
            new PipelineTaskCrud(databaseService).create(pipelineTask);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private void createAttitudeAdjustments(double initialMjd,
        List<AttitudeAdjustment> attitudeAdjustments) {

        LogCrud logCrud = new LogCrud();
        double mjd = initialMjd;
        for (AttitudeAdjustment attitudeAdjustment : attitudeAdjustments) {
            RefPixelLog refPixelLog = new RefPixelLog();
            refPixelLog.setMjd(mjd++);
            logCrud.createRefPixelLog(refPixelLog);
            attitudeAdjustment.setRefPixelLog(refPixelLog);
        }
        pdqCrud.createAttitudeAdjustments(attitudeAdjustments);
    }

}
