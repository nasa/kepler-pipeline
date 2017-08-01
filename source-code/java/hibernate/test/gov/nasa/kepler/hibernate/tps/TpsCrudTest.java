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

package gov.nasa.kepler.hibernate.tps;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.FakePipelineTaskFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Sean McCauliff
 * 
 */
public class TpsCrudTest {

    private TpsCrud tpsCrud;
    private DatabaseService dbService;
    private PipelineTask pipelineTask;
    private final FluxType fluxType = FluxType.DIA;
    private final WeakSecondaryDb weakSecondary = new WeakSecondaryDb(1.0f,
        2.0f, new float[] { 1.0f }, new float[] { 2.0f }, 3.0f, 4.0f, 5.0f,
        6.0f, 7.0f, 8.0f, 9, 10.0f);

    @Before
    public void createDatabase() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
        try {
            TestUtils.setUpDatabase(dbService);
            tpsCrud = new TpsCrud();
            FakePipelineTaskFactory taskFactory = new FakePipelineTaskFactory();
            pipelineTask = taskFactory.newTask();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @After
    public void destroyDatabase() {
        TestUtils.tearDownDatabase(dbService);
    }

    @Test
    public void retrieveTpsResultsTest() {
        TpsDbResult tpsDbResult = null;
        try {
            dbService.beginTransaction();
            tpsDbResult = new TpsDbResult(1, 3.0f, 10.0f, 3.0f, 1, 10,
                fluxType, pipelineTask, 365.0, true, 45.0f, 32.0f, 64.0, 7.0f,
                6.26f, 7.25f, 8.25, 9.25f, true, 7.0f, weakSecondary, 11f, 12f,
                13, 14.1f /* chiSquareDof2 */, 15.5f, 16.5f, 17, 18.1f);
            tpsCrud.create(tpsDbResult);
            dbService.flush();
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }

        List<TpsDbResult> readResult = tpsCrud.retrieveTpsResult(Arrays.asList(new Integer[] {
            1, 2 }));
        assertEquals(1, readResult.size());
        assertEquals(tpsDbResult, readResult.get(0));

    }

    @Test
    public void tpsResultsNonUniquenessTest() {
        try {
            dbService.beginTransaction();
            TpsDbResult tpsDbResult = new TpsDbResult(1, 3.0f, 10.0f, 3.0f, 1,
                10, fluxType, pipelineTask, 365.0, true, 42.0f, 32.0f, 90.0,
                7.0f, 6.26f, 55.25f, 56.25, 57.25f, true, 7.0f, weakSecondary,
                11f, 12f, 13, 14.1f /* chiSquareDof2 */, 15.5f, 16.5f, 17, 18.1f);
            tpsCrud.create(tpsDbResult);
            dbService.flush();
            dbService.commitTransaction();

            dbService.beginTransaction();
            TpsLiteDbResult tpsLiteDbResult = new TpsLiteDbResult(1, 3.0f,
                666.0f, 44.0f, 1, 10, fluxType, pipelineTask, false);
            tpsCrud.create(tpsLiteDbResult);
            dbService.flush();
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }

        List<TpsDbResult> tpsDbResults = tpsCrud.retrieveTpsResult(Collections.singleton(1));
        List<TpsLiteDbResult> tpsLiteDbResults = tpsCrud.retrieveTpsLiteResult(Collections.singleton(1));
        assertFalse(tpsDbResults.get(0)
            .equals(tpsLiteDbResults.get(0)));
    }

    @Test
    public void dealWithNullTpsResults() {
        TpsDbResult tpsDbResult = new TpsDbResult(7, 1.0f, null, null, 0, 128,
            FluxType.SAP, pipelineTask, null, null, null, null, null, null,
            null, null, null, null, null, 7.0f, null, null, null, null, null,
            null, null, null,18.1f);
        TpsCrud tpsCrud = new TpsCrud();

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        tpsCrud.create(tpsDbResult);
        databaseService.commitTransaction();

        List<TpsDbResult> readResults = tpsCrud.retrieveTpsResult(0, 10);
        assertEquals(1, readResults.size());
        assertEquals(tpsDbResult, readResults.get(0));

    }

    @Test
    public void testRetrieveLatestBestTpsResultsWithPlanetaryCandidateWithExceedsMesSesRatioWithOrbitalPeriodDaysGreaterThanZero() {
        TpsDbResult tpsDbResult = null;
        try {
            dbService.beginTransaction();
            tpsDbResult = new TpsDbResult(1, 3.0f, 10.0f, 3.0f, 1, 10,
                fluxType, pipelineTask, 365.0, true, 45.0f, 32.0f, 64.0, 7.0f,
                6.26f, 7.25f, 8.25, -1f, true, 7.0f, weakSecondary, 11f, 12f,
                13, 14.1f /* chiSquareDof2 */, 15.5f, 16.5f, 17,18.1f);
            tpsCrud.create(tpsDbResult);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        dbService.closeCurrentSession();

        List<TpsDbResult> actualTpsDbResults = tpsCrud.retrieveLatestTpsResults(null);

        List<TpsDbResult> expectedTpsDbResults = new ArrayList<TpsDbResult>();
        expectedTpsDbResults.add(tpsDbResult);

        assertEquals(expectedTpsDbResults, actualTpsDbResults);
    }

    @Test
    public void testRetrieveLatestBestTpsResultsForKeplerIdsWithPlanetaryCandidateWithExceedsMesSesRatioWithOrbitalPeriodDaysGreaterThanZero() {
        int keplerId = 1;
        List<Integer> keplerIds = new ArrayList<Integer>();
        keplerIds.add(keplerId);
        TpsDbResult tpsDbResult = null;
        try {
            dbService.beginTransaction();
            tpsDbResult = new TpsDbResult(keplerId, 3.0f, 10.0f, 3.0f,
                keplerId, 10, fluxType, pipelineTask, 365.0, true, 45.0f,
                32.0f, 64.0, 7.0f, 6.26f, 7.25f, 8.25, -1f, false, 7.0f,
                weakSecondary, 11f, 12f, 13, 14.1f /* chiSquareDof2 */, 15.5f, 16.5f, 17,18.1f);
            tpsCrud.create(tpsDbResult);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        dbService.closeCurrentSession();

        List<TpsDbResult> actualTpsDbResults = tpsCrud.retrieveLatestTpsResults(
            keplerIds, null);

        List<TpsDbResult> expectedTpsDbResults = new ArrayList<TpsDbResult>();
        expectedTpsDbResults.add(tpsDbResult);

        assertEquals(expectedTpsDbResults, actualTpsDbResults);
    }

    @Test
    public void testRetrieveTpsResultsByPipelineInstanceId() {
        int keplerId = 1;
        TpsDbResult tpsDbResult = null;
        try {
            dbService.beginTransaction();
            tpsDbResult = new TpsDbResult(keplerId, 3.0f, 10.0f, 3.0f,
                keplerId, 10, fluxType, pipelineTask, 365.0, true, 45.0f,
                32.0f, 64.0, 7.0f, 6.26f, 7.25f, 8.25, -1f, false, 7.0f, null,
                11f, 12f, 13, 14.1f /* chiSquareDof2 */, 15.5f, 16.5f, 17,18.1f);
            tpsCrud.create(tpsDbResult);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        dbService.closeCurrentSession();

        long pipelineInstanceId = tpsDbResult.getOriginator()
            .getPipelineInstance()
            .getId();
        List<TpsDbResult> actualResults = tpsCrud.retrieveTpsResultByPipelineInstanceId(
            0, Integer.MAX_VALUE, pipelineInstanceId);
        assertEquals(1, actualResults.size());
        assertEquals(tpsDbResult, actualResults.get(0));

        actualResults = tpsCrud.retrieveTpsResultByPipelineInstanceId(0,
            Integer.MAX_VALUE, pipelineInstanceId + 1);
        assertEquals(0, actualResults.size());

        List<Integer> actualKeplerIds = tpsCrud.retrieveTpsResultKeplerIdsByPipelineInstanceId(
            0, Integer.MAX_VALUE, pipelineInstanceId);
        assertEquals(1, actualKeplerIds.size());
        assertEquals(keplerId, (int) actualKeplerIds.get(0));

        actualKeplerIds = tpsCrud.retrieveTpsResultKeplerIdsByPipelineInstanceId(
            0, Integer.MAX_VALUE, pipelineInstanceId + 1);
        assertEquals(0, actualKeplerIds.size());
    }

    @Test
    public void testRetrieveTpsResultsForSbt() {
        int keplerId = 1;
        List<Integer> keplerIds = ImmutableList.of(keplerId);

        TpsDbResult tpsDbResult = createSomeTpsDbResult(keplerId);
        List<TpsDbResult> tpsDbResults = ImmutableList.of(tpsDbResult);

        try {
            dbService.beginTransaction();
            tpsCrud.create(tpsDbResult);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        dbService.closeCurrentSession();

        List<TpsDbResult> actualResults = tpsCrud.retrieveTpsResultsForSbt(keplerIds);
        assertEquals(tpsDbResults, actualResults);
    }
    
    @Test
    public void testRetrieveLatestTpsRun() {
        TpsDbResult tpsDbResult = createSomeTpsDbResult(34534);
        try {
            dbService.beginTransaction();
            tpsCrud.create(tpsDbResult);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        
        PipelineInstance latestInstance = tpsCrud.retrieveLatestTpsRun(TpsType.TPS_FULL);
        assertEquals(latestInstance.getId(), pipelineTask.getPipelineInstance().getId());
    }
    
    @Test
    public void testRetrieveLatestTpsRunForCadenceRange() {
        TpsDbResult tpsDbResult = createSomeTpsDbResult(34535); // different
        try {
            dbService.beginTransaction();
            tpsCrud.create(tpsDbResult);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        final int startCadence = 9; // 5th argument to TpsDbResult.TpsDbResult()
        final int endCadence = 10; // 6th argument to TpsDbResult.TpsDbResult()
        PipelineInstance latestInstance = 
            tpsCrud.retrieveLatestTpsRunForCadenceRange(TpsType.TPS_FULL,
                startCadence, endCadence);
        assertEquals(latestInstance.getId(), pipelineTask.getPipelineInstance().getId());
        
    }

    private TpsDbResult createSomeTpsDbResult(int keplerId) {
        return new TpsDbResult(keplerId, 3.0f, 10.0f, 3.0f,
            9, 10, fluxType, pipelineTask, 365.0, true, 45.0f, 32.0f,
            64.0, 7.0f, 6.26f, 7.25f, 8.25, -1f, false, 7.0f, weakSecondary,
            11f, 12f, 13, 14.1f /* chiSquareDof2 */, 15.5f, 16.5f, 17,18.1f);
    }
}
