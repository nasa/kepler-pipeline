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
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;

import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class PipelineTaskAttributeOperationsTest {
    private static final Log log = LogFactory.getLog(PipelineTaskAttributeOperationsTest.class);

    private static final long PIPELINE_TASK_ID = 42;
    private static final long PIPELINE_INSTANCE_ID = 5;

    private DatabaseService databaseService;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testCreateSingleTask() throws Exception {
        // CREATE
        update(PIPELINE_TASK_ID, PIPELINE_INSTANCE_ID,
            ProcessingState.RECEIVING, 15, 10, 5);

        // VERIFY
        verifyByTask(PIPELINE_TASK_ID, ProcessingState.RECEIVING, 15, 10, 5);
    }

    @Test
    public void testCreateAndUpdateSingleTask() throws Exception {
        // CREATE
        update(PIPELINE_TASK_ID, PIPELINE_INSTANCE_ID, ProcessingState.SENDING,
            15, 0, 0);

        // UPDATE
        update(PIPELINE_TASK_ID, PIPELINE_INSTANCE_ID,
            ProcessingState.RECEIVING, 15, 10, 5);

        // VERIFY
        verifyByTask(PIPELINE_TASK_ID, ProcessingState.RECEIVING, 15, 10, 5);

    }

    @Test
    public void testCreateAndUpdateMultipleTasks() throws Exception {
        // CREATE
        update(PIPELINE_TASK_ID, PIPELINE_INSTANCE_ID, ProcessingState.SENDING,
            15, 0, 0);

        // UPDATE
        update(PIPELINE_TASK_ID, PIPELINE_INSTANCE_ID,
            ProcessingState.RECEIVING, 15, 10, 5);

        // VERIFY
        verifyByInstance(PIPELINE_INSTANCE_ID, PIPELINE_TASK_ID,
            ProcessingState.RECEIVING, 15, 10, 5);

    }

    private void update(long taskId, long instanceId, ProcessingState state,
        int numTotal, int numComplete, int numFailed) {
        PipelineTaskAttributeOperations ops = new PipelineTaskAttributeOperations();

        try {

            // CREATE
            databaseService.beginTransaction();

            log.info("Updating processing state");

            ops.updateProcessingState(taskId, instanceId, state);

            log.info("Updating sub-task counts");

            ops.updateSubTaskCounts(taskId, instanceId, numTotal, numComplete,
                numFailed);

            log.info("committing");

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private PipelineTaskAttributes retrieveByTask(long taskId) throws Exception {
        PipelineTaskAttributeCrud crud = new PipelineTaskAttributeCrud();

        PipelineTaskAttributes dbAttrs = null;
        try {

            databaseService.beginTransaction();

            log.info("Retrieving");

            dbAttrs = crud.retrieveByTaskId(PIPELINE_TASK_ID);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        return dbAttrs;
    }

    private void verifyByTask(long taskId, ProcessingState expectedState,
        int expectedNumTotal, int expectedNumComplete, int expectedNumFailed)
        throws Exception {

        PipelineTaskAttributes dbAttrs = retrieveByTask(taskId);

        assertEquals("numTotal", expectedNumTotal,
            dbAttrs.getNumSubTasksTotal());
        assertEquals("numComplete", expectedNumComplete,
            dbAttrs.getNumSubTasksComplete());
        assertEquals("numFailed", expectedNumFailed,
            dbAttrs.getNumSubTasksFailed());
        assertEquals("processingState", expectedState,
            dbAttrs.getProcessingState());

    }

    private Map<Long, PipelineTaskAttributes> retrieveByInstance(long instanceId)
        throws Exception {
        PipelineTaskAttributeCrud crud = new PipelineTaskAttributeCrud();

        Map<Long, PipelineTaskAttributes> dbAttrs = null;
        try {

            databaseService.beginTransaction();

            log.info("Retrieving");

            dbAttrs = crud.retrieveByInstanceId(PIPELINE_INSTANCE_ID);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        return dbAttrs;
    }

    private void verifyByInstance(long instanceId, long expectedTaskId,
        ProcessingState expectedState, int expectedNumTotal,
        int expectedNumComplete, int expectedNumFailed) throws Exception {

        Map<Long, PipelineTaskAttributes> taskAttrMap = retrieveByInstance(instanceId);

        assertEquals("num tasks", 1, taskAttrMap.keySet()
            .size());

        PipelineTaskAttributes taskAttr = taskAttrMap.get(expectedTaskId);

        assertNotNull(taskAttr);

        assertEquals("numTotal", expectedNumTotal,
            taskAttr.getNumSubTasksTotal());
        assertEquals("numComplete", expectedNumComplete,
            taskAttr.getNumSubTasksComplete());
        assertEquals("numFailed", expectedNumFailed,
            taskAttr.getNumSubTasksFailed());
        assertEquals("processingState", expectedState,
            taskAttr.getProcessingState());

    }
}
