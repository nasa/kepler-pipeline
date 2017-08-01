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

package gov.nasa.kepler.mc.mr;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.mr.MrReport;
import gov.nasa.kepler.hibernate.mr.MrReportCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.fs.MrFsIdFactory;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Tests the {@link GenericReportOperations} class.
 * 
 * @author Bill Wohler
 */
@RunWith(JMock.class)
public class GenericReportOperationsTest {

    private static final String MODULE_NAME = "foo";
    private static final String IDENTIFIER = "foobar";
    private static final String KNOWN_FILENAME = "foo.pdf";
    private static final String MIME_TYPE = "application/pdf";

    private Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private MrReportCrud mrReportCrud;
    private FileStoreClient fsClient;

    private GenericReportOperations genericReportOperations;

    private PipelineTask pipelineTask;
    private FsId fsId;
    private FsId fsIdWithIdentifier;

    @Test(expected = NullPointerException.class)
    public void testNullMimeType() {
        GenericReportOperations genericReportOperations = new GenericReportOperations();
        genericReportOperations.mimeType(null);
    }

    @Test
    public void testMimeType() {
        GenericReportOperations genericReportOperations = new GenericReportOperations();
        assertEquals("application/pdf",
            genericReportOperations.mimeType(new File("foo.pdf")));
        assertEquals("text/html", genericReportOperations.mimeType(new File(
            "foo.html")));
        assertEquals("text/plain", genericReportOperations.mimeType(new File(
            "foo.txt")));
        assertEquals("application/octet-stream",
            genericReportOperations.mimeType(new File("foo")));
    }

    @Test
    public void testCreateReportWithKnownFile() {
        populateObjects();
        createBlob();
        createMrReportForCreation();

        fsClient.beginLocalFsTransaction();
        MrReport report = genericReportOperations.createReport(pipelineTask,
            new File(KNOWN_FILENAME));
        fsClient.commitLocalFsTransaction();

        assertEquals(MODULE_NAME, report.getModuleName()
            .getName());
        assertEquals(fsId.toString(), report.getFsId());
        assertEquals(KNOWN_FILENAME, report.getFilename());
        assertEquals(MIME_TYPE, report.getMimeType());
    }

    @Test
    public void testCreateReportWithIdentifier() {
        populateObjects();
        createBlobWithIdentifier();
        createMrReportForCreation(IDENTIFIER);

        fsClient.beginLocalFsTransaction();
        MrReport report = genericReportOperations.createReport(pipelineTask,
            IDENTIFIER, new File(KNOWN_FILENAME));
        fsClient.commitLocalFsTransaction();

        assertEquals(MODULE_NAME, report.getModuleName()
            .getName());
        assertEquals(IDENTIFIER, report.getIdentifier());
        assertEquals(fsIdWithIdentifier.toString(), report.getFsId());
        assertEquals(KNOWN_FILENAME, report.getFilename());
        assertEquals(MIME_TYPE, report.getMimeType());
    }

    @Test
    public void testCreateReportWithKnownType() {
        populateObjects();
        createBlob();
        createMrReportForCreation();

        fsClient.beginLocalFsTransaction();
        MrReport report = genericReportOperations.createReport(pipelineTask,
            new File(KNOWN_FILENAME), MIME_TYPE);
        fsClient.commitLocalFsTransaction();

        assertEquals(MODULE_NAME, report.getModuleName()
            .getName());
        assertEquals(fsId.toString(), report.getFsId());
        assertEquals(KNOWN_FILENAME, report.getFilename());
        assertEquals(MIME_TYPE, report.getMimeType());
    }

    @Test
    public void testRetrieveReportBogusPipelineTaskId() {
        populateObjects();

        long bogusPipelineTaskId = 0;
        createBogusMrReport(bogusPipelineTaskId);

        assertNull(genericReportOperations.retrieveReport(bogusPipelineTaskId));
    }

    @Test
    public void testRetrieveReportBogusIdentifier() {
        populateObjects();

        String bogusIdentifier = "bogus";
        createBogusMrReport(bogusIdentifier);

        assertNull(genericReportOperations.retrieveReport(pipelineTask.getId(),
            bogusIdentifier));
    }

    @Test(expected = NullPointerException.class)
    public void testInputStreamNullBogusReport() {
        populateObjects();

        genericReportOperations.retrieveStreamedBlobResult(null);
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveBlobResultNullReport() {
        genericReportOperations.retrieveBlobResult(null, new File("foo"));
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveBlobResultNullFile() {
        genericReportOperations.retrieveBlobResult(createMrReport(), null);
    }

    @Test
    public void testRetrieveBlobResult() {
        populateObjects();

        MrReport report = new MrReport(pipelineTask, KNOWN_FILENAME, MIME_TYPE,
            fsId.toString());
        File file = new File("foo");
        createBlobFile(report, file);
        genericReportOperations.retrieveBlobResult(report, file);
    }

    @Test
    public void testRetrieveReport() {
        populateObjects();

        MrReport expectedReport = createMrReport();
        MrReport report = genericReportOperations.retrieveReport(pipelineTask.getId());
        assertEquals(expectedReport, report);

        expectedReport = createMrReport("foo");
        report = genericReportOperations.retrieveReport(pipelineTask.getId(),
            "foo");
        assertEquals(expectedReport, report);

        InputStream expectedInputStream = createInputStream(report);
        InputStream inputStream = genericReportOperations.retrieveStreamedBlobResult(
            report)
            .stream();
        assertEquals(expectedInputStream, inputStream);
    }

    @Test
    public void testRetrieveReportsBogusModuleName() {
        populateObjects();

        String bogusModuleName = "bar";
        createBogusMrReports(bogusModuleName,
            pipelineTask.getPipelineInstance()
                .getId());

        assertEquals(0, genericReportOperations.retrieveReports(
            bogusModuleName, pipelineTask.getPipelineInstance()
                .getId())
            .size());
    }

    @Test
    public void testRetrieveReportsBogusPipelineInstance() {
        populateObjects();

        long bogusPipelineInstanceId = 42L;
        createBogusMrReports(MODULE_NAME, bogusPipelineInstanceId);

        assertEquals(0, genericReportOperations.retrieveReports(MODULE_NAME,
            bogusPipelineInstanceId)
            .size());
    }

    @Test
    public void testRetrieveReports() {
        populateObjects();

        List<MrReport> expectedReports = createMrReports();
        List<MrReport> reports = genericReportOperations.retrieveReports(
            MODULE_NAME, pipelineTask.getPipelineInstance()
                .getId());
        assertEquals(expectedReports, reports);
    }

    private void populateObjects() {
        genericReportOperations = new GenericReportOperations();
        mrReportCrud = mockery.mock(MrReportCrud.class);
        fsClient = mockery.mock(FileStoreClient.class);
        pipelineTask = createPipelineTask();
        fsId = MrFsIdFactory.getReportId(pipelineTask);
        fsIdWithIdentifier = MrFsIdFactory.getReportId(pipelineTask, IDENTIFIER);

        genericReportOperations.setMrReportCrud(mrReportCrud);
        genericReportOperations.setFsClient(fsClient);

        FileStoreClientFactory.setInstance(fsClient);
    }

    private PipelineTask createPipelineTask() {
        PipelineInstance pipelineInstance = new PipelineInstance();

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode();

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            MODULE_NAME);

        PipelineDefinitionNode pipelineDefinitionNode = new PipelineDefinitionNode();
        pipelineDefinitionNode.setPipelineModuleDefinition(pipelineModuleDefinition);

        PipelineTask pipelineTask = new PipelineTask(pipelineInstance,
            pipelineDefinitionNode, pipelineInstanceNode);

        return pipelineTask;
    }

    private void createMrReportForCreation() {
        final MrReport report = new MrReport(pipelineTask, KNOWN_FILENAME,
            MIME_TYPE, fsId.toString());

        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).create(report);
            }
        });
    }

    private void createMrReportForCreation(String identifier) {
        final MrReport report = new MrReport(pipelineTask, identifier,
            KNOWN_FILENAME, MIME_TYPE, fsId.toString());

        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).create(report);
            }
        });
    }

    private void createBogusMrReport(final long bogusPipelineTaskId) {
        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).retrieveReport(bogusPipelineTaskId);
                will(returnValue(null));
            }
        });
    }

    private void createBogusMrReport(final String bogusIdentifier) {
        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).retrieveReport(pipelineTask.getId(),
                    bogusIdentifier);
                will(returnValue(null));
            }
        });
    }

    private MrReport createMrReport() {
        final MrReport report = new MrReport(pipelineTask, KNOWN_FILENAME,
            MIME_TYPE, fsId.toString());

        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).retrieveReport(pipelineTask.getId());
                will(returnValue(report));
            }
        });

        return report;
    }

    private MrReport createMrReport(final String string) {
        final MrReport report = new MrReport(pipelineTask, string,
            KNOWN_FILENAME, MIME_TYPE, fsId.toString());

        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).retrieveReport(pipelineTask.getId(), string);
                will(returnValue(report));
            }
        });

        return report;
    }

    private void createBlob() {
        mockery.checking(new Expectations() {
            {
                one(fsClient).beginLocalFsTransaction();
                one(fsClient).writeBlob(fsId, pipelineTask.getId(),
                    new File(KNOWN_FILENAME));
                one(fsClient).commitLocalFsTransaction();
            }
        });
    }

    private void createBlobWithIdentifier() {
        mockery.checking(new Expectations() {
            {
                one(fsClient).beginLocalFsTransaction();
                one(fsClient).writeBlob(fsIdWithIdentifier,
                    pipelineTask.getId(), new File(KNOWN_FILENAME));
                one(fsClient).commitLocalFsTransaction();
            }
        });
    }

    private void createBlobFile(final MrReport report, final File file) {
        mockery.checking(new Expectations() {
            {
                one(fsClient).readBlob(new FsId(report.getFsId()), file);
            }
        });
    }

    private InputStream createInputStream(final MrReport report) {
        InputStream inputStream = new InputStream() {
            @Override
            public int read() throws IOException {
                return 0;
            }
        };
        final StreamedBlobResult stream = new StreamedBlobResult(0, 0,
            inputStream);

        mockery.checking(new Expectations() {
            {
                one(fsClient).readBlobAsStream(new FsId(report.getFsId()));
                will(returnValue(stream));
            }
        });

        return inputStream;
    }

    private void createBogusMrReports(final String moduleName,
        final long pipelineInstanceId) {
        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).retrieveReports(moduleName,
                    pipelineInstanceId);
                will(returnValue(new ArrayList<MrReport>()));
            }
        });
    }

    private List<MrReport> createMrReports() {
        final List<MrReport> reports = new ArrayList<MrReport>();
        MrReport report = new MrReport(pipelineTask, MODULE_NAME,
            KNOWN_FILENAME, MIME_TYPE, fsId.toString());
        reports.add(report);

        mockery.checking(new Expectations() {
            {
                one(mrReportCrud).retrieveReports(MODULE_NAME,
                    pipelineTask.getPipelineInstance()
                        .getId());
                will(returnValue(reports));
            }
        });

        return reports;
    }
}
