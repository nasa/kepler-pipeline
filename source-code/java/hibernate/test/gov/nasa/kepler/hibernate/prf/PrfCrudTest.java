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

package gov.nasa.kepler.hibernate.prf;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
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
import gov.nasa.kepler.hibernate.pi.TestUowTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;

import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import org.hibernate.HibernateException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for the PRF data model.
 * 
 * @author Forrest Giroaurd (fgirouard)
 * 
 */
public class PrfCrudTest {

    private DatabaseService databaseService;
    private PrfCrud prfCrud;

    private static final int CADENCE_OFFSET = 96;
    private static final int PIPELINE_TASK_ID = 123456;
    private static final int CCD_MODULE = 13;
    private static final int CCD_OUTPUT = 3;
    private static final int START_CADENCE = 1001;
    private static final int END_CADENCE = START_CADENCE + CADENCE_OFFSET;
    private static final String FILE_EXT = ".mat";

    private int pipelineTaskId = PIPELINE_TASK_ID;

    private List<PrfBlobMetadata> prfBlobMetadataList1;
    private List<PrfBlobMetadata> prfBlobMetadataList2;

    private PrfBlobMetadata prfBlobMetadata1;
    private PrfBlobMetadata prfBlobMetadata2;

    private PipelineTask task;

    @Before
    public void setUp() throws Exception {

        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        prfCrud = new PrfCrud(databaseService);

        try {
            databaseService.beginTransaction();

            PipelineTaskCrud taskCrud = new PipelineTaskCrud(databaseService);
            PipelineDefinitionCrud defCrud = new PipelineDefinitionCrud(
                databaseService);

            PipelineDefinition pipeDef = new PipelineDefinition("PrfCrudTest");

            PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
                "ModuleDef");
            PipelineModuleDefinitionCrud modDefCrud = new PipelineModuleDefinitionCrud(
                databaseService);
            modDefCrud.create(pipelineModuleDefinition);

            PipelineDefinitionNode pipeNodeDef = new PipelineDefinitionNode(
                pipelineModuleDefinition.getName());

            pipeDef.getRootNodes()
                .add(pipeNodeDef);

            defCrud.create(pipeDef);

            PipelineInstance pipelineInstance = new PipelineInstance(pipeDef);
            PipelineInstanceCrud instCrud = new PipelineInstanceCrud(
                databaseService);
            instCrud.create(pipelineInstance);

            PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
                pipelineInstance, pipeNodeDef, pipelineModuleDefinition);
            PipelineInstanceNodeCrud instNodeCrud = new PipelineInstanceNodeCrud(
                databaseService);
            instNodeCrud.create(pipelineInstanceNode);

            databaseService.flush();

            task = new PipelineTask(pipelineInstance, pipeNodeDef,
                pipelineInstanceNode);
            task.setEndProcessingTime(new Date());
            task.setUowTask(new BeanWrapper<UnitOfWorkTask>(new TestUowTask()));

            taskCrud.create(task);
            databaseService.flush();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void storePrfConvergence() {
        try {
            databaseService.beginTransaction();
            PrfConvergence prfConvergence = new PrfConvergence(true, task, 0.01);
            prfCrud.create(prfConvergence);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void storeAndRetrieveFpgImportBlobMetadata() {
        try {
            FpgImportBlobMetadata fpgImportMetadata = new FpgImportBlobMetadata(
                1, 2, 3, "txt");
            databaseService.beginTransaction();
            prfCrud.create(fpgImportMetadata);
            databaseService.commitTransaction();
            FpgImportBlobMetadata read = prfCrud.retrieveImportBlobMetadata(fpgImportMetadata.getPipelineTaskId());
            assertEquals(fpgImportMetadata, read);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void storeAndRetrieveFpgResultsMetadata() {
        try {
            FpgResultsBlobMetadata fpgResultsMetadata = new FpgResultsBlobMetadata(
                1, 2, 3, "txt");
            databaseService.beginTransaction();
            prfCrud.create(fpgResultsMetadata);
            databaseService.commitTransaction();
            FpgResultsBlobMetadata read = prfCrud.retrieveResultsBlobMetadata(fpgResultsMetadata.getPipelineTaskId());
            assertEquals(fpgResultsMetadata, read);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createPrfBlobMetadata() {
        populatePrfBlobMetadata();

        try {
            databaseService.beginTransaction();
            prfCrud.createPrfBlobMetadata(prfBlobMetadata1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void storeAndRetrievePrfGeometryBlob() throws Exception {
        FpgGeometryBlobMetadata geoMeta = new FpgGeometryBlobMetadata(5, 7, 1L,
            ".mat");

        try {
            databaseService.beginTransaction();
            prfCrud.create(geoMeta);

            geoMeta = new FpgGeometryBlobMetadata(5, 7, 2L, ".mat");

            prfCrud.create(geoMeta);
            databaseService.flush();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        FpgGeometryBlobMetadata read = prfCrud.retrieveLastGeometryBlobMetadata();
        assertEquals(read, geoMeta);

        List<FpgGeometryBlobMetadata> metaList = prfCrud.retrieveGeometryBlobMetadata(
            6, 7);
        assertEquals(2, metaList.size());
        metaList = prfCrud.retrieveGeometryBlobMetadata(10, 11);
        assertEquals(0, metaList.size());

    }

    @Test(expected = HibernateException.class)
    public void storePrfBlobMetadataWithEmptyDatabase() throws Exception {

        try {
            databaseService.beginTransaction();
            DdlInitializer ddlInitializer = databaseService.getDdlInitializer();
            ddlInitializer.initDB();
            ddlInitializer.cleanDB();
            databaseService.clear();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        createPrfBlobMetadata();
    }

    @Test(expected = NullPointerException.class)
    public void createNullPrfBlobMetadata() {

        try {
            databaseService.beginTransaction();
            prfCrud.createPrfBlobMetadata((PrfBlobMetadata) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createPrfBlobMetadataList() {
        populatePrfBlobMetadata();

        try {
            databaseService.beginTransaction();
            prfCrud.createPrfBlobMetadata(prfBlobMetadataList1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void createEmptyPrfBlobMetadataList() {
        populatePrfBlobMetadata();

        try {
            databaseService.beginTransaction();
            prfCrud.createPrfBlobMetadata(new ArrayList<PrfBlobMetadata>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createPrfBlobMetadataAll() {
        populatePrfBlobMetadata();

        try {
            databaseService.beginTransaction();
            prfCrud.createPrfBlobMetadata(prfBlobMetadataList1);
            prfCrud.createPrfBlobMetadata(prfBlobMetadataList2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void deletePrfBlobMetadata() {

        createPrfBlobMetadataList();
        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
                CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
            assertNotNull(prfBlobMetadata);
            assertEquals(1, prfBlobMetadata.size());
            prfCrud.delete(prfBlobMetadata.get(0));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertNotNull(prfBlobMetadata);
        assertTrue(prfBlobMetadata.isEmpty());

    }

    @Test
    public void retrieveEmptyPrfBlobMetadata() {
        // empty database
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue(prfBlobMetadata.isEmpty());
    }

    @Test
    public void retrievePrfBlobMetadata() {
        // add prfBlobMetadataList to database
        createPrfBlobMetadataList();

        // get prfBlobMetadataList1 from database
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE + CADENCE_OFFSET
                + 1);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(prfBlobMetadataList1, prfBlobMetadata);

        // get non-existent metadata from database
        prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(CCD_MODULE + 1,
            CCD_OUTPUT - 1, START_CADENCE, END_CADENCE);
        assertTrue(prfBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveAllPrfBlobMetadata() {

        // add all metadata to database
        createPrfBlobMetadataAll();

        // get all metadata from database
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE + 3
                * CADENCE_OFFSET);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(4, prfBlobMetadata.size());
    }

    @Test
    public void retrievePrfBlobMetadataExactMatch() {

        // add all metadata to database
        createPrfBlobMetadataAll();

        // get only first entry from database: exact match
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(1, prfBlobMetadata.size());
        assertEquals(START_CADENCE, prfBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE, prfBlobMetadata.get(0)
            .getEndCadence());
    }

    @Test
    public void retrievePrfBlobMetadataSubsetMatch() {
        // add all metadata to database
        createPrfBlobMetadataAll();

        // get only first entry from database: subset match
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + 1, END_CADENCE - 1);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(1, prfBlobMetadata.size());
        assertEquals(START_CADENCE, prfBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE, prfBlobMetadata.get(0)
            .getEndCadence());
    }

    @Test
    public void retrievePrfBlobMetadataOverlapMatch() {
        // add all metadata to database
        createPrfBlobMetadataAll();

        // get second and third entries from database: overlap match
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + CADENCE_OFFSET
                + CADENCE_OFFSET / 2, END_CADENCE + CADENCE_OFFSET
                + CADENCE_OFFSET / 2);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(2, prfBlobMetadata.size());
        assertEquals(END_CADENCE + 1, prfBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE + CADENCE_OFFSET + 1, prfBlobMetadata.get(0)
            .getEndCadence());
        assertEquals(END_CADENCE + CADENCE_OFFSET + 2, prfBlobMetadata.get(1)
            .getStartCadence());
        assertEquals(END_CADENCE + 2 * CADENCE_OFFSET + 2,
            prfBlobMetadata.get(1)
                .getEndCadence());
    }

    @Test
    public void createPrfBlobMetadataDuplicate() {
        // add all metadata to database
        createPrfBlobMetadataAll();

        // get only first entry from database: exact match
        List<PrfBlobMetadata> prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(1, prfBlobMetadata.size());

        PrfBlobMetadata cm = createPrfBlobMetadata(prfBlobMetadata.get(0)
            .getCcdModule(), prfBlobMetadata.get(0)
            .getCcdOutput(), prfBlobMetadata.get(0)
            .getStartCadence(), prfBlobMetadata.get(0)
            .getEndCadence());
        try {
            databaseService.beginTransaction();
            prfCrud.createPrfBlobMetadata(cm);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        // get both entries from the database
        prfBlobMetadata = prfCrud.retrievePrfBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(prfBlobMetadata.isEmpty());
        assertEquals(2, prfBlobMetadata.size());
    }

    private void populatePrfBlobMetadata() {
        PrfBlobMetadata cm = null;
        int start = START_CADENCE;
        int end = END_CADENCE;

        prfBlobMetadataList1 = new LinkedList<PrfBlobMetadata>();
        prfBlobMetadata1 = createPrfBlobMetadata(CCD_MODULE, CCD_OUTPUT, start,
            end);
        prfBlobMetadataList1.add(prfBlobMetadata1);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        prfBlobMetadata2 = createPrfBlobMetadata(CCD_MODULE, CCD_OUTPUT, start,
            end);
        prfBlobMetadataList1.add(prfBlobMetadata2);

        prfBlobMetadataList2 = new LinkedList<PrfBlobMetadata>();
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        cm = createPrfBlobMetadata(CCD_MODULE, CCD_OUTPUT, start, end);
        prfBlobMetadataList2.add(cm);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        cm = createPrfBlobMetadata(CCD_MODULE, CCD_OUTPUT, start, end);
        prfBlobMetadataList2.add(cm);
    }

    private PrfBlobMetadata createPrfBlobMetadata(int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {
        return new PrfBlobMetadata(getPipelineTaskId(), ccdModule, ccdOutput,
            startCadence, endCadence, FILE_EXT);
    }

    private synchronized int getPipelineTaskId() {
        return pipelineTaskId++;
    }

}
