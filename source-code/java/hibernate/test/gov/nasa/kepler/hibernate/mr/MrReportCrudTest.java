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

package gov.nasa.kepler.hibernate.mr;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.hibernate.NonUniqueResultException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link MrReportCrud} class.
 * 
 * @author Bill Wohler
 */
public class MrReportCrudTest {

    private static final long MILLIS_PER_DAY = 24 * 60 * 60 * 1000;
    private static final int SPECIAL_IDENTIFIER = 42;

    private DatabaseService databaseService;
    private MrReportCrud mrReportCrud = new MrReportCrud();
    private PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
    private PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();
    private PipelineDefinitionCrud pipelineDefinitionCrud = new PipelineDefinitionCrud();
    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud();
    private PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

    private List<String> names;
    private List<MrReport> reports;
    private Map<String, PipelineModuleDefinition> pipelineModuleDefinitionMap = new HashMap<String, PipelineModuleDefinition>();
    private Map<String, PipelineDefinition> pipelineDefinitionMap = new HashMap<String, PipelineDefinition>();

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testMrReportToString() {
        String s = createReports("foo").get(0)
            .toString();
        assertTrue(s.contains("id=1,pipelineInstance=1,pipelineInstanceNode=1,pipelineTask=1,identifier=<null>,moduleName=foo,uow=0-1440 [0/2],created="));
        assertTrue(s.contains(",filename=foo.pdf,mimeType=application/pdf,fsId=foo]"));
    }

    @Test(expected = NullPointerException.class)
    public void testMrReportNullPipelineTask() {
        new MrReport(null, null, null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testMrReportNullFilename() {
        new MrReport(new PipelineTask(), null, null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testMrReportNullMimeType() {
        new MrReport(new PipelineTask(), "", null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testMrReportNullFsid() {
        new MrReport(new PipelineTask(), "", "", null);
    }

    @Test
    public void testMrReportCrudDatabaseService() {
        // Code coverage only.
        new MrReportCrud(null);
    }

    @Test
    public void testFilenameWithDate() {
        assertTrue(matches("foo-pi00001-[0-9]{8}T[0-9]{6},[0-9]{3}Z",
            createReport("p1", "foo").filenameWithDate()));
        assertTrue(matches("foo-pi00002-[0-9]{8}T[0-9]{6},[0-9]{3}Z.pdf",
            createReport("p2", "foo.pdf").filenameWithDate()));
        assertTrue(matches("foo-4-2-pi00003-[0-9]{8}T[0-9]{6},[0-9]{3}Z.pdf",
            createReport("p3", "foo-4-2.pdf").filenameWithDate()));
        assertTrue(matches("foo.bar-pi00004-[0-9]{8}T[0-9]{6},[0-9]{3}Z.pdf",
            createReport("p4", "foo.bar.pdf").filenameWithDate()));
        assertTrue(matches("foo-20081010T121212.pdf",
            createReport("p5", "foo-20081010T121212.pdf").filenameWithDate()));
        assertTrue(matches("foo-20081010T121212Z.pdf",
            createReport("p6", "foo-20081010T121212Z.pdf").filenameWithDate()));
    }

    private boolean matches(String expectedRegex, String filename) {
        Pattern p = Pattern.compile(expectedRegex);
        Matcher m = p.matcher(filename);

        return m.matches();
    }

    @Test
    public void testDelete() {
        populateObjects();

        databaseService.beginTransaction();
        String moduleName = names.remove(0);
        for (MrReport report : reports) {
            if (report.getModuleName()
                .getName()
                .equals(moduleName)) {
                mrReportCrud.delete(report);
            }
        }
        databaseService.commitTransaction();
        Collections.sort(names);
        assertEquals(names, mrReportCrud.retrieveModuleNames());
    }

    @Test
    public void testRetrieveModuleNames() {
        populateObjects();

        Collections.sort(names);
        assertEquals(names, mrReportCrud.retrieveModuleNames());
    }

    @Test
    public void testRetrieveReportsByDate() {
        populateObjects();

        String moduleName = "foo";
        Date startDate = new Date(new Date().getTime() - MILLIS_PER_DAY);
        Date endDate = new Date(new Date().getTime() + MILLIS_PER_DAY);
        List<MrReport> actualReports = mrReportCrud.retrieveReports(moduleName,
            startDate, endDate);
        assertEquals(2, actualReports.size());
        MrReport report = reports.get(0);
        validateReport(report, actualReports.get(0));
    }

    @Test
    public void testRetrieveReportsByModuleNameAndPipelineInstance() {
        populateObjects();

        String moduleName = "foo";
        long pipelineInstanceId = 1L;
        List<MrReport> actualReports = mrReportCrud.retrieveReports(moduleName,
            pipelineInstanceId);
        assertEquals(2, actualReports.size());
        MrReport report = reports.get(0);
        validateReport(report, actualReports.get(0));
        assertTrue(actualReports.get(0)
            .compareTo(actualReports.get(1)) < 0);
    }

    @Test
    public void testRetrieveReportsByPipelineInstanceAndNode() {
        populateObjects();

        String moduleName = "foo";
        long pipelineInstanceId = 1L;
        long pipelineInstanceNodeId = 1L;
        List<MrReport> actualReports = mrReportCrud.retrieveReports(moduleName,
            pipelineInstanceId, pipelineInstanceNodeId);
        assertEquals(2, actualReports.size());
        MrReport report = reports.get(0);
        validateReport(report, actualReports.get(0));
        assertTrue(actualReports.get(0)
            .compareTo(actualReports.get(1)) < 0);
    }

    @Test
    public void testRetrieveReportByPipelineTask() {
        populateObjects();

        MrReport report = reports.get(0);
        long pipelineTaskId = report.getPipelineTask()
            .getId();
        validateReport(report, mrReportCrud.retrieveReport(pipelineTaskId));

        report = reports.get(1);
        pipelineTaskId = report.getPipelineTask()
            .getId();
        validateReport(report, mrReportCrud.retrieveReport(pipelineTaskId));

        pipelineTaskId = 4242;
        assertEquals(null, mrReportCrud.retrieveReport(pipelineTaskId));
    }

    @Test(expected = NonUniqueResultException.class)
    public void testRetrieveReportByPipelineTaskWithMultipleReportsWoId() {
        populateObjects();

        MrReport report = reports.get(10);
        long pipelineTaskId = report.getPipelineTask()
            .getId();
        mrReportCrud.retrieveReport(pipelineTaskId);
    }

    @Test(expected = NonUniqueResultException.class)
    public void testRetrieveReportByPipelineTaskWithMultipleReportsWId() {
        populateObjects();

        MrReport report = reports.get(12);
        long pipelineTaskId = report.getPipelineTask()
            .getId();
        mrReportCrud.retrieveReport(pipelineTaskId);
    }

    @Test
    public void testRetrieveReportByPipelineTaskAndIdentifier() {
        populateObjects();

        MrReport report = reports.get(0);
        long pipelineTaskId = report.getPipelineTask()
            .getId();
        String identifier = report.getIdentifier();
        validateReport(report,
            mrReportCrud.retrieveReport(pipelineTaskId, identifier));

        report = reports.get(6);
        pipelineTaskId = report.getPipelineTask()
            .getId();
        identifier = report.getIdentifier();
        validateReport(report,
            mrReportCrud.retrieveReport(pipelineTaskId, identifier));

        report = reports.get(7);
        pipelineTaskId = report.getPipelineTask()
            .getId();
        identifier = report.getIdentifier();
        validateReport(report,
            mrReportCrud.retrieveReport(pipelineTaskId, identifier));

        identifier = "foo";
        assertEquals(null,
            mrReportCrud.retrieveReport(pipelineTaskId, identifier));
    }

    private void validateReport(MrReport expectedReport, MrReport actualReport) {
        assertEquals(expectedReport, actualReport);
        assertEquals(expectedReport.getModuleName()
            .getName(), actualReport.getModuleName()
            .getName());
        assertEquals(expectedReport.getIdentifier(),
            actualReport.getIdentifier());
        assertEquals(expectedReport.getFsId(), actualReport.getFsId());
        assertEquals(expectedReport.getMimeType(), actualReport.getMimeType());
        assertEquals(expectedReport.getPipelineInstanceNode()
            .getId(), actualReport.getPipelineInstanceNode()
            .getId());
        assertEquals(expectedReport.hashCode(), actualReport.hashCode());
    }

    private void populateObjects() {
        databaseService.beginTransaction();

        // Start with names out of order to test that names come back sorted.
        names = new ArrayList<String>();
        names.add("foo"); // reports index 0, 1
        names.add("bar"); // reports index 2, 3
        names.add("baz"); // reports index 4, 5
        names.add("multi-reports"); // reports index 6, 7, 8, 9
        // reports index 10, 11 (identifier=null), 12, 13 (identifier=42)
        names.add("duplicate-reports");

        reports = new ArrayList<MrReport>();
        for (String name : names) {
            if (name.startsWith("multi")) {
                reports.addAll(createReports(name, 2, "foo.pdf",
                    "application/pdf"));
            } else if (name.startsWith("duplicate")) {
                reports.addAll(createReports(name, SPECIAL_IDENTIFIER,
                    "foo.pdf", "application/pdf"));
            } else {
                reports.addAll(createReports(name));
            }
        }

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    private List<MrReport> createReports(String name) {
        return createReports(name, "foo.pdf", "application/pdf");
    }

    private MrReport createReport(String pipelineName, String filename) {
        return createReports(pipelineName, filename, "application/pdf").get(0);
    }

    public List<MrReport> createReports(String pipelineName, String filename,
        String mimeType) {
        return createReports(pipelineName, 1, filename, mimeType);
    }

    public List<MrReport> createReports(String pipelineName,
        int reportsPerTask, String filename, String mimeType) {

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode();
        pipelineInstanceNodeCrud.create(pipelineInstanceNode);

        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstanceCrud.create(pipelineInstance);

        PipelineModuleDefinition pipelineModuleDefinition = pipelineModuleDefinitionMap.get(pipelineName);
        if (pipelineModuleDefinition == null) {
            pipelineModuleDefinition = new PipelineModuleDefinition(
                pipelineName);
            pipelineModuleDefinitionMap.put(pipelineName,
                pipelineModuleDefinition);
            pipelineModuleDefinitionCrud.create(pipelineModuleDefinition);
        }

        PipelineDefinition pipelineDefinition = pipelineDefinitionMap.get(pipelineName);
        if (pipelineDefinition == null) {
            pipelineDefinition = new PipelineDefinition(
                pipelineModuleDefinition.getName()
                    .getName());
            PipelineDefinitionNode pipelineDefinitionNode = new PipelineDefinitionNode();
            pipelineDefinitionNode.setPipelineModuleDefinition(pipelineModuleDefinition);
            pipelineDefinition.getRootNodes()
                .add(pipelineDefinitionNode);
            pipelineInstance.setPipelineDefinition(pipelineDefinition);
            pipelineDefinitionMap.put(pipelineName, pipelineDefinition);
            pipelineDefinitionCrud.create(pipelineDefinition);
        }

        List<MrReport> reports = new ArrayList<MrReport>();
        // Create two reports with different tasks to reproduce bug 962.
        for (int i = 0; i < 2; i++) {
            PipelineTask pipelineTask = new PipelineTask(pipelineInstance,
                pipelineDefinition.getRootNodes()
                    .get(0), pipelineInstanceNode);
            pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(
                new TestUnitOfWork(String.format("0-1440 [%d/2]", i))));
            pipelineTaskCrud.create(pipelineTask);

            if (reportsPerTask == 42) {
                // Special case: create duplicate reports with null identifiers
                // and identifiers whose value is 42.
                for (int j = 0; j < 4; j++) {
                    MrReport report = new MrReport(pipelineTask, j < 2 ? null
                        : Integer.toString(42), filename, mimeType, "foo");
                    mrReportCrud.create(report);
                    reports.add(report);
                }
            } else {
                for (int j = 0; j < reportsPerTask; j++) {
                    MrReport report = reportsPerTask > 1 ? new MrReport(
                        pipelineTask, Integer.toString(j), filename, mimeType,
                        "foo") : new MrReport(pipelineTask, filename, mimeType,
                        "foo");
                    mrReportCrud.create(report);
                    reports.add(report);
                }
            }
        }

        return reports;
    }

    public static class TestUnitOfWork extends UnitOfWorkTask {
        private String briefState;

        public TestUnitOfWork() {
        }

        public TestUnitOfWork(String briefState) {
            this.briefState = briefState;
        }

        public String getBriefState() {
            return briefState;
        }

        public void setBriefState(String briefState) {
            this.briefState = briefState;
        }

        @Override
        public String briefState() {
            return briefState;
        }

        public TestUnitOfWork makeCopy() {
            return new TestUnitOfWork(briefState);
        }

    }
}
