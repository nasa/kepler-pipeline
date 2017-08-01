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

package gov.nasa.kepler.hibernate.pa;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * Unit tests for the PA:BPP data model.
 * 
 * @author Forrest Giroaurd (fgirouard)
 * 
 */
public class PaCrudTest {

    private static final Log log = LogFactory.getLog(PaCrudTest.class);

    private DatabaseService databaseService;
    private PaCrud paCrud;

    private static final int CADENCE_OFFSET = 96;
    private static final int PIPELINE_TASK_ID = 123456;
    private static final int CCD_MODULE = 13;
    private static final int CCD_OUTPUT = 3;
    private static final CadenceType CADENCE_TYPE = CadenceType.LONG;
    private static final int START_CADENCE = 1001;
    private static final int END_CADENCE = START_CADENCE + CADENCE_OFFSET;
    private static final int KEPLER_ID = 123456789;
    private static final String MAT_FILE_EXTENSION = ".mat";
    private static final int TABLE_ID = 1;

    private int pipelineTaskId = PIPELINE_TASK_ID;

    private List<BackgroundBlobMetadata> backgroundBlobMetadataList1;
    private List<BackgroundBlobMetadata> backgroundBlobMetadataList2;

    private BackgroundBlobMetadata backgroundBlobMetadata1;
    private BackgroundBlobMetadata backgroundBlobMetadata2;

    private List<MotionBlobMetadata> motionBlobMetadataList1;
    private List<MotionBlobMetadata> motionBlobMetadataList2;
    private List<MotionBlobMetadata> motionBlobMetadataList3;

    private MotionBlobMetadata motionBlobMetadata1;
    private MotionBlobMetadata motionBlobMetadata2;

    private UncertaintyBlobMetadata uncertaintyBlobMetadata1;
    private UncertaintyBlobMetadata uncertaintyBlobMetadata2;

    private TargetAperture targetAperture1;
    private TargetAperture targetAperture2;
    // private RollingBandContaminationPulses rbcPulses1;
    // private RollingBandContaminationPulses rbcPulses2;

    private PipelineTask pipelineTask;
    private TargetTable targetTable;

    @Before
    public void setUp() {
        databaseService = DatabaseServiceFactory.getInstance();
        paCrud = new PaCrud(databaseService);

        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void createBackgroundBlobMetadata() {
        populateBackgroundBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createBackgroundBlobMetadata(backgroundBlobMetadata1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = HibernateException.class)
    public void storeBackgroundBlobMetadataWithEmptyDatabase() {
        try {
            databaseService.beginTransaction();
            databaseService.getDdlInitializer()
                .cleanDB();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        createBackgroundBlobMetadata();
    }

    @Test(expected = NullPointerException.class)
    public void createNullBackgroundBlobMetadata() {

        try {
            databaseService.beginTransaction();
            paCrud.createBackgroundBlobMetadata((BackgroundBlobMetadata) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createBackgroundBlobMetadataList() {
        populateBackgroundBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createBackgroundBlobMetadata(backgroundBlobMetadataList1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void createEmptyBackgroundBlobMetadataList() {
        populateBackgroundBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createBackgroundBlobMetadata(new ArrayList<BackgroundBlobMetadata>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createBackgroundBlobMetadataAll() {
        populateBackgroundBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createBackgroundBlobMetadata(backgroundBlobMetadataList1);
            paCrud.createBackgroundBlobMetadata(backgroundBlobMetadataList2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void deleteBackgroundBlobMetadata() {

        createBackgroundBlobMetadataList();
        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
                CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
            assertNotNull(backgroundBlobMetadata);
            assertEquals(1, backgroundBlobMetadata.size());
            paCrud.delete(backgroundBlobMetadata.get(0));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertNotNull(backgroundBlobMetadata);
        assertTrue(backgroundBlobMetadata.isEmpty());

    }

    @Test
    public void retrieveEmptyBackgroundBlobMetadata() {
        // empty database
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue(backgroundBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveEmpty2BackgroundBlobMetadata() {
        // add motionBlobMetadata to database
        createMotionBlobMetadata();

        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue(backgroundBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveBackgroundBlobMetadata() {
        // add backgroundBlobMetadataList to database
        createBackgroundBlobMetadataList();

        // get backgroundBlobMetadataList1 from database
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE + CADENCE_OFFSET
                + 1);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(backgroundBlobMetadataList1, backgroundBlobMetadata);

        // get non-existent metadata from database
        backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE + 1, CCD_OUTPUT - 1, START_CADENCE, END_CADENCE);
        assertTrue(backgroundBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveAllBackgroundBlobMetadata() {

        // add all metadata to database
        createBackgroundBlobMetadataAll();

        // get all metadata from database
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE + 3
                * CADENCE_OFFSET);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(4, backgroundBlobMetadata.size());
    }

    @Test
    public void retrieveBackgroundBlobMetadataExactMatch() {

        // add all metadata to database
        createBackgroundBlobMetadataAll();

        // get only first entry from database: exact match
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(1, backgroundBlobMetadata.size());
        assertEquals(START_CADENCE, backgroundBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE, backgroundBlobMetadata.get(0)
            .getEndCadence());
    }

    @Test
    public void retrieveBackgroundBlobMetadataSubsetMatch() {
        // add all metadata to database
        createBackgroundBlobMetadataAll();

        // get only first entry from database: subset match
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + 1, END_CADENCE - 1);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(1, backgroundBlobMetadata.size());
        assertEquals(START_CADENCE, backgroundBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE, backgroundBlobMetadata.get(0)
            .getEndCadence());
    }

    @Test
    public void retrieveBackgroundBlobMetadataOverlapMatch() {
        // add all metadata to database
        createBackgroundBlobMetadataAll();

        // get second and third entries from database: overlap match
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + CADENCE_OFFSET
                + CADENCE_OFFSET / 2, END_CADENCE + CADENCE_OFFSET
                + CADENCE_OFFSET / 2);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(2, backgroundBlobMetadata.size());
        assertEquals(END_CADENCE + 1, backgroundBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE + CADENCE_OFFSET + 1,
            backgroundBlobMetadata.get(0)
                .getEndCadence());
        assertEquals(END_CADENCE + CADENCE_OFFSET + 2,
            backgroundBlobMetadata.get(1)
                .getStartCadence());
        assertEquals(END_CADENCE + 2 * CADENCE_OFFSET + 2,
            backgroundBlobMetadata.get(1)
                .getEndCadence());
    }

    @Test
    public void createBackgroundBlobMetadataDuplicate() {
        // add all metadata to database
        createBackgroundBlobMetadataAll();

        // get only first entry from database: exact match
        List<BackgroundBlobMetadata> backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(1, backgroundBlobMetadata.size());

        BackgroundBlobMetadata bcm = createBackgroundBlobMetadata(
            backgroundBlobMetadata.get(0)
                .getCcdModule(), backgroundBlobMetadata.get(0)
                .getCcdOutput(), backgroundBlobMetadata.get(0)
                .getStartCadence(), backgroundBlobMetadata.get(0)
                .getEndCadence());
        try {
            databaseService.beginTransaction();
            paCrud.createBackgroundBlobMetadata(bcm);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        // get only the new entry from database: exact match
        backgroundBlobMetadata = paCrud.retrieveBackgroundBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(backgroundBlobMetadata.isEmpty());
        assertEquals(2, backgroundBlobMetadata.size());
    }

    @Test
    public void createMotionBlobMetadata() {
        populateMotionBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createMotionBlobMetadata(motionBlobMetadata1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = HibernateException.class)
    public void createMotionBlobMetadataWithEmptyDatabase() {
        try {
            databaseService.beginTransaction();
            databaseService.getDdlInitializer()
                .cleanDB();
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        createMotionBlobMetadata();
    }

    @Test(expected = NullPointerException.class)
    public void createNullMotionBlobMetadata() {

        try {
            databaseService.beginTransaction();
            paCrud.createMotionBlobMetadata((MotionBlobMetadata) null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createMotionBlobMetadataList() {
        populateMotionBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createMotionBlobMetadata(motionBlobMetadataList1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void createEmptyMotionBlobMetadataList() {

        try {
            databaseService.beginTransaction();
            paCrud.createMotionBlobMetadata(new ArrayList<MotionBlobMetadata>());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void createMotionBlobMetadataAll() {
        populateMotionBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createMotionBlobMetadata(motionBlobMetadataList1);
            paCrud.createMotionBlobMetadata(motionBlobMetadataList2);
            paCrud.createMotionBlobMetadata(motionBlobMetadataList3);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void deleteMotionBlobMetadata() {

        createMotionBlobMetadataList();
        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
                CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
            assertNotNull(motionBlobMetadata);
            assertEquals(1, motionBlobMetadata.size());
            paCrud.delete(motionBlobMetadata.get(0));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertNotNull(motionBlobMetadata);
        assertTrue(motionBlobMetadata.isEmpty());

    }

    @Test
    public void retrieveEmptyMotionBlobMetadata() {

        // empty database
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue(motionBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveEmpty2MotionBlobMetadata() {
        // add backgroundBlobMetadata to database
        createBackgroundBlobMetadata();

        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue(motionBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveMotionBlobMetadata() {
        // add motionBlobMetadataList to database
        createMotionBlobMetadataList();

        // get motionBlobMetadataList1 from database
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE + CADENCE_OFFSET
                + 1);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(motionBlobMetadataList1, motionBlobMetadata);

        // get non-existent metadata from database
        motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(CCD_MODULE + 1,
            CCD_OUTPUT - 1, START_CADENCE, END_CADENCE);
        assertTrue(motionBlobMetadata.isEmpty());
    }

    @Test
    public void retrieveAllMotionBlobMetadata() {
        // add all metadata to database
        createMotionBlobMetadataAll();

        // get all metadata from database
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE + 5
                * CADENCE_OFFSET);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(4, motionBlobMetadata.size());
    }

    @Test
    public void retrieveMotionBlobMetadataExactMatch() {
        // add all metadata to database
        createMotionBlobMetadataAll();

        // get only first entry from database: exact match
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(1, motionBlobMetadata.size());
        assertEquals(START_CADENCE, motionBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE, motionBlobMetadata.get(0)
            .getEndCadence());
    }

    @Test
    public void retrieveMotionBlobMetadataSubsetMatch() {
        // add all metadata to database
        createMotionBlobMetadataAll();

        // get only first entry from database: subset match
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + 1, END_CADENCE - 1);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(1, motionBlobMetadata.size());
        assertEquals(START_CADENCE, motionBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE, motionBlobMetadata.get(0)
            .getEndCadence());
    }

    @Test
    public void retrieveMotionBlobMetadataOverlapMatch() {
        // add all metadata to database
        createMotionBlobMetadataAll();

        // get second and third entries from database: overlap match
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE + CADENCE_OFFSET
                + CADENCE_OFFSET / 2, END_CADENCE + CADENCE_OFFSET
                + CADENCE_OFFSET / 2);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(2, motionBlobMetadata.size());
        assertEquals(END_CADENCE + 1, motionBlobMetadata.get(0)
            .getStartCadence());
        assertEquals(END_CADENCE + CADENCE_OFFSET + 1,
            motionBlobMetadata.get(0)
                .getEndCadence());
        assertEquals(END_CADENCE + CADENCE_OFFSET + 2,
            motionBlobMetadata.get(1)
                .getStartCadence());
        assertEquals(END_CADENCE + 2 * CADENCE_OFFSET + 2,
            motionBlobMetadata.get(1)
                .getEndCadence());
    }

    @Test
    public void createMotionBlobMetadataDuplicate() {
        // add all metadata to database
        createMotionBlobMetadataAll();

        // get only first entry from database: exact match
        List<MotionBlobMetadata> motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(1, motionBlobMetadata.size());

        MotionBlobMetadata mcm = createMotionBlobMetadata(
            motionBlobMetadata.get(0)
                .getCcdModule(), motionBlobMetadata.get(0)
                .getCcdOutput(), motionBlobMetadata.get(0)
                .getCadenceType(), motionBlobMetadata.get(0)
                .getStartCadence(), motionBlobMetadata.get(0)
                .getEndCadence());
        try {
            databaseService.beginTransaction();
            paCrud.createMotionBlobMetadata(mcm);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        // get only the new entry from database: exact match
        motionBlobMetadata = paCrud.retrieveMotionBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertFalse(motionBlobMetadata.isEmpty());
        assertEquals(2, motionBlobMetadata.size());
    }

    @Test
    public void createUncertaintyBlobMetadata() {

        populateUncertaintyBlobMetadata();

        try {
            databaseService.beginTransaction();
            paCrud.createUncertaintyBlobMetadata(uncertaintyBlobMetadata1);
            paCrud.createUncertaintyBlobMetadata(uncertaintyBlobMetadata2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void deleteUncertaintyBlobMetadata() {

        createUncertaintyBlobMetadata();
        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<UncertaintyBlobMetadata> uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
                CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE,
                END_CADENCE);
            assertNotNull(uncertaintyBlobMetadata);
            assertEquals(1, uncertaintyBlobMetadata.size());
            paCrud.delete(uncertaintyBlobMetadata.get(0));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<UncertaintyBlobMetadata> uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE);
        assertNotNull(uncertaintyBlobMetadata);
        assertTrue(uncertaintyBlobMetadata.isEmpty());

    }

    @Test
    public void retrieveUncertaintyBlobMetadata() {

        createUncertaintyBlobMetadata();

        // get uncertaintyBlobMetadata1 from database
        List<UncertaintyBlobMetadata> uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE);
        assertFalse(uncertaintyBlobMetadata.isEmpty());
        assertEquals(uncertaintyBlobMetadata1, uncertaintyBlobMetadata.get(0));
        assertEquals(1, uncertaintyBlobMetadata.size());

        // get non-existent metadata from database
        uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE + 1, CCD_OUTPUT - 1, CADENCE_TYPE, START_CADENCE,
            END_CADENCE);
        assertTrue(uncertaintyBlobMetadata.isEmpty());

        uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE
                + CADENCE_OFFSET + 1);
        assertFalse(uncertaintyBlobMetadata.isEmpty());
        assertEquals(uncertaintyBlobMetadata1, uncertaintyBlobMetadata.get(0));
        assertEquals(2, uncertaintyBlobMetadata.size());
        assertEquals(uncertaintyBlobMetadata2, uncertaintyBlobMetadata.get(1));

        uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE + 1,
            END_CADENCE + 1);
        assertFalse(uncertaintyBlobMetadata.isEmpty());
        assertEquals(uncertaintyBlobMetadata1, uncertaintyBlobMetadata.get(0));
        assertEquals(2, uncertaintyBlobMetadata.size());
        assertEquals(uncertaintyBlobMetadata2, uncertaintyBlobMetadata.get(1));

        uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE + 1,
            END_CADENCE - 1);
        assertFalse(uncertaintyBlobMetadata.isEmpty());
        assertEquals(uncertaintyBlobMetadata1, uncertaintyBlobMetadata.get(0));
        assertEquals(1, uncertaintyBlobMetadata.size());

        UncertaintyBlobMetadata ubm = createUncertaintyBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE);
        try {
            databaseService.beginTransaction();
            paCrud.createUncertaintyBlobMetadata(ubm);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        uncertaintyBlobMetadata = paCrud.retrieveUncertaintyBlobMetadata(
            CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE, START_CADENCE, END_CADENCE);
        assertFalse(uncertaintyBlobMetadata.isEmpty());
        assertEquals(uncertaintyBlobMetadata1, uncertaintyBlobMetadata.get(0));
        assertEquals(2, uncertaintyBlobMetadata.size());
        assertEquals(ubm, uncertaintyBlobMetadata.get(1));
        assertTrue(!ubm.equals(uncertaintyBlobMetadata.get(0)));
    }

    @Test
    public void createTargetAperture() {

        populateTargetAperture();

        try {
            databaseService.beginTransaction();
            paCrud.createTargetAperture(targetAperture1);
            paCrud.createTargetAperture(targetAperture2);

            targetAperture1 = createTargetAperture(targetTable, pipelineTask,
                KEPLER_ID + 2, CCD_MODULE, CCD_OUTPUT);
            paCrud.createTargetAperture(targetAperture1);
            targetAperture1 = createTargetAperture(targetTable, pipelineTask,
                KEPLER_ID + 3, CCD_MODULE, CCD_OUTPUT);
            paCrud.createTargetAperture(targetAperture1);
            targetAperture2 = createTargetAperture(targetTable, pipelineTask,
                KEPLER_ID + 4, CCD_MODULE, CCD_OUTPUT);
            paCrud.createTargetAperture(targetAperture2);
            targetAperture2 = createTargetAperture(targetTable, pipelineTask,
                KEPLER_ID + 5, CCD_MODULE, CCD_OUTPUT);
            paCrud.createTargetAperture(targetAperture2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        try {
            databaseService.beginTransaction();
            List<TargetAperture> targetApertures = paCrud.retrieveTargetApertures(
                targetTable, CCD_MODULE, CCD_OUTPUT);
            assertNotNull(targetApertures);
            assertEquals(6, targetApertures.size());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        try {
            databaseService.beginTransaction();
            List<TargetAperture> targetApertures = paCrud.retrieveTargetApertures(pipelineTask);
            assertNotNull(targetApertures);
            assertEquals(6, targetApertures.size());
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        databaseService.closeCurrentSession();
    }

    @Test
    public void deleteTargetAperture() {

        createTargetAperture();

        databaseService.closeCurrentSession();

        try {
            databaseService.beginTransaction();
            List<TargetAperture> targetApertures = paCrud.retrieveTargetApertures(
                targetTable, CCD_MODULE, CCD_OUTPUT);
            assertNotNull(targetApertures);
            assertEquals(6, targetApertures.size());
            paCrud.deleteTargetApertures(targetApertures);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<TargetAperture> targetApertures = paCrud.retrieveTargetApertures(
            targetTable, CCD_MODULE, CCD_OUTPUT);
        assertNotNull(targetApertures);
        assertTrue(targetApertures.isEmpty());

    }

    @Test
    public void retrieveTargetAperture() {

        createTargetAperture();

        databaseService.closeCurrentSession();

        List<TargetAperture> targetApertures = paCrud.retrieveTargetApertures(
            targetTable, CCD_MODULE, CCD_OUTPUT);
        assertNotNull(targetApertures);
        assertEquals(6, targetApertures.size());
        assertNotNull(targetApertures.get(0)
            .getCentroidPixels());
        assertEquals(2, targetApertures.get(0)
            .getCentroidPixels()
            .size());

        targetApertures = paCrud.retrieveTargetApertures(targetTable,
            CCD_MODULE, CCD_OUTPUT, ImmutableList.of(KEPLER_ID + 1));
        assertNotNull(targetApertures);
        assertEquals(1, targetApertures.size());

        try {
            databaseService.beginTransaction();
            targetApertures = paCrud.retrieveTargetApertures(targetTable,
                CCD_MODULE, CCD_OUTPUT);
            paCrud.deleteTargetApertures(targetApertures);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        targetApertures = paCrud.retrieveTargetApertures(targetTable,
            CCD_MODULE, CCD_OUTPUT);
        assertNotNull(targetApertures);
        assertTrue(targetApertures.isEmpty());
    }

    @Test
    public void retrieveEmptyTargetAperture() {

        createTargetAperture();

        databaseService.closeCurrentSession();

        List<TargetAperture> targetApertures = paCrud.retrieveTargetApertures(
            targetTable, CCD_MODULE + 1, CCD_OUTPUT);
        assertNotNull(targetApertures);
        assertTrue(targetApertures.isEmpty());

        targetApertures = paCrud.retrieveTargetApertures(targetTable,
            CCD_MODULE, CCD_OUTPUT + 1);
        assertNotNull(targetApertures);
        assertTrue(targetApertures.isEmpty());

        targetApertures = paCrud.retrieveTargetApertures(targetTable,
            CCD_MODULE, CCD_OUTPUT, ImmutableList.of(KEPLER_ID + 6));
        assertNotNull(targetApertures);
        assertTrue(targetApertures.isEmpty());

    }

    private void createPipelineTask(long id) {
        log.info(String.format("createPipelineTask(%d)", id));
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(id);
        new PipelineTaskCrud().create(pipelineTask);
    }

    private void createTargetTable(int tableId) {
        log.info(String.format("createTargetTable(%d)", tableId));
        TargetTable targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setExternalId(tableId);
        targetTable.setState(State.UPLINKED);
        new TargetCrud().createTargetTable(targetTable);
    }

    private void populateBackgroundBlobMetadata() {
        BackgroundBlobMetadata bcm = null;
        int start = START_CADENCE;
        int end = END_CADENCE;

        backgroundBlobMetadataList1 = new LinkedList<BackgroundBlobMetadata>();
        backgroundBlobMetadata1 = createBackgroundBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, start, end);
        backgroundBlobMetadataList1.add(backgroundBlobMetadata1);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        backgroundBlobMetadata2 = createBackgroundBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, start, end);
        backgroundBlobMetadataList1.add(backgroundBlobMetadata2);

        backgroundBlobMetadataList2 = new LinkedList<BackgroundBlobMetadata>();
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        bcm = createBackgroundBlobMetadata(CCD_MODULE, CCD_OUTPUT, start, end);
        backgroundBlobMetadataList2.add(bcm);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        bcm = createBackgroundBlobMetadata(CCD_MODULE, CCD_OUTPUT, start, end);
        backgroundBlobMetadataList2.add(bcm);
    }

    private void populateMotionBlobMetadata() {
        MotionBlobMetadata mcm = null;
        int start = START_CADENCE;
        int end = END_CADENCE;

        motionBlobMetadataList1 = new LinkedList<MotionBlobMetadata>();
        motionBlobMetadata1 = createMotionBlobMetadata(CCD_MODULE, CCD_OUTPUT,
            CADENCE_TYPE, start, end);
        motionBlobMetadataList1.add(motionBlobMetadata1);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        motionBlobMetadata2 = createMotionBlobMetadata(CCD_MODULE, CCD_OUTPUT,
            CADENCE_TYPE, start, end);
        motionBlobMetadataList1.add(motionBlobMetadata2);

        motionBlobMetadataList2 = new LinkedList<MotionBlobMetadata>();
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        mcm = createMotionBlobMetadata(CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE,
            start, end);
        motionBlobMetadataList2.add(mcm);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        mcm = createMotionBlobMetadata(CCD_MODULE, CCD_OUTPUT, CADENCE_TYPE,
            start, end);
        motionBlobMetadataList2.add(mcm);

        motionBlobMetadataList3 = new LinkedList<MotionBlobMetadata>();
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        mcm = createMotionBlobMetadata(CCD_MODULE + 1, CCD_OUTPUT,
            CADENCE_TYPE, start, end);
        motionBlobMetadataList3.add(mcm);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        mcm = createMotionBlobMetadata(CCD_MODULE + 1, CCD_OUTPUT,
            CADENCE_TYPE, start, end);
        motionBlobMetadataList3.add(mcm);
    }

    private void populateUncertaintyBlobMetadata() {
        int start = START_CADENCE;
        int end = END_CADENCE;

        uncertaintyBlobMetadata1 = createUncertaintyBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, CADENCE_TYPE, start, end);
        start += CADENCE_OFFSET + 1;
        end = start + CADENCE_OFFSET;
        uncertaintyBlobMetadata2 = createUncertaintyBlobMetadata(CCD_MODULE,
            CCD_OUTPUT, CADENCE_TYPE, start, end);
    }

    private void populateTargetAperture() {
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
        TargetCrud targetCrud = new TargetCrud();
        try {
            databaseService.beginTransaction();
            createPipelineTask(1L);
            createTargetTable(TABLE_ID);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        pipelineTask = pipelineTaskCrud.retrieve(1L);
        targetTable = targetCrud.retrieveTargetTable(TargetType.LONG_CADENCE,
            TABLE_ID);

        targetAperture1 = createTargetAperture(targetTable, pipelineTask,
            KEPLER_ID, CCD_MODULE, CCD_OUTPUT);
        targetAperture2 = createTargetAperture(targetTable, pipelineTask,
            KEPLER_ID + 1, CCD_MODULE, CCD_OUTPUT);
    }

    private BackgroundBlobMetadata createBackgroundBlobMetadata(int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {
        return new BackgroundBlobMetadata(getPipelineTaskId(), ccdModule,
            ccdOutput, startCadence, endCadence, MAT_FILE_EXTENSION);
    }

    private MotionBlobMetadata createMotionBlobMetadata(int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence, int endCadence) {
        return new MotionBlobMetadata(getPipelineTaskId(), ccdModule,
            ccdOutput, startCadence, endCadence, MAT_FILE_EXTENSION);
    }

    private UncertaintyBlobMetadata createUncertaintyBlobMetadata(
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence) {
        return new UncertaintyBlobMetadata(getPipelineTaskId(), ccdModule,
            ccdOutput, cadenceType, startCadence, endCadence,
            MAT_FILE_EXTENSION);
    }

    private TargetAperture createTargetAperture(TargetTable targetTable,
        PipelineTask pipelineTask, int keplerId, int ccdModule, int ccdOutput) {

        TargetAperture targetAperture = new TargetAperture.Builder(
            pipelineTask, targetTable, keplerId).ccdModule(ccdModule)
            .ccdOutput(ccdOutput)
            .build();
        List<CentroidPixel> centroidPixels = newArrayList(new CentroidPixel(
            345, 456, false, false), new CentroidPixel(345, 457, true, false));
        targetAperture.setCentroidPixels(centroidPixels);

        return targetAperture;
    }

    private synchronized int getPipelineTaskId() {
        return pipelineTaskId++;
    }

}
