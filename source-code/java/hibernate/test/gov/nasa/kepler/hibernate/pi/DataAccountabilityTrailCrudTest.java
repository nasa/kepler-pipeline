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

package gov.nasa.kepler.hibernate.pi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * 
 * @author tklaus
 * 
 */
public class DataAccountabilityTrailCrudTest {

    private static final long CONSUMER_PIPELINE_TASK_ID = 42L;

    private DatabaseService databaseService = null;

    private PipelineTask pipelineTask = new PipelineTask();
    private Set<Long> producerTaskIds = null;

    private DataAccountabilityTrailCrud dataAccountabilityTrailCrud;

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     * @throws ClassNotFoundException
     * @throws IOException
     */
    @Before
    public void createDatabase() throws SQLException, ClassNotFoundException,
        IOException {

        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        producerTaskIds = new HashSet<Long>();
        producerTaskIds.add(1L);
        producerTaskIds.add(2L);
        producerTaskIds.add(3L);

        pipelineTask.setId(CONSUMER_PIPELINE_TASK_ID);

        dataAccountabilityTrailCrud = new DataAccountabilityTrailCrud(
            databaseService);
    }

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     */
    @After
    public void destroyDatabase() throws SQLException {
        if (databaseService != null) {
            TestUtils.tearDownDatabase(databaseService);
        }
    }

    /**
     * Stores a new DataAccountabilityTrail instance in the db, then retrieves
     * it and makes sure it matches what was put in
     * 
     * @throws PipelineException
     */
    @Test
    public void testStoreAndRetrieve() {
        // Store
        databaseService.beginTransaction();

        DataAccountabilityTrail trail = new DataAccountabilityTrail(
            CONSUMER_PIPELINE_TASK_ID);
        trail.setProducerTaskIds(producerTaskIds);

        dataAccountabilityTrailCrud.create(trail);

        databaseService.commitTransaction();

        testRetrieve();
    }

    @Test
    public void testStoreAndRetrieve2() {
        // Store
        databaseService.beginTransaction();
        dataAccountabilityTrailCrud.create(pipelineTask, producerTaskIds);
        databaseService.commitTransaction();

        testRetrieve();
    }

    private void testRetrieve() {

        databaseService.beginTransaction();

        DataAccountabilityTrail retrievedTrail = dataAccountabilityTrailCrud.retrieve(CONSUMER_PIPELINE_TASK_ID);

        assertNotNull("Stored DataAccountabilityTrail not found in db",
            retrievedTrail);
        assertEquals("task ID does not match requested ID",
            CONSUMER_PIPELINE_TASK_ID, retrievedTrail.getConsumerTaskId());
        assertEquals(
            "producerTaskIds in retrieved instance do not match ones originally stored",
            producerTaskIds, retrievedTrail.getProducerTaskIds());

        databaseService.commitTransaction();
    }
}
