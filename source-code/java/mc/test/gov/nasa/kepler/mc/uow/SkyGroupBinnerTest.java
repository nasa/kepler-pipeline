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

package gov.nasa.kepler.mc.uow;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;
import java.util.Map;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class SkyGroupBinnerTest extends JMockTest {

    private static final int SKY_GROUP_ID_1 = 1;
    private static final int SKY_GROUP_ID_2 = 2;

    private static final int KEPLER_ID_1 = 3;
    private static final int KEPLER_ID_2 = 4;

    @Test
    public void testSubdivideSameSkyGroup() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2);

        Map<Integer, Integer> keplerIdToSkyGroupMap = ImmutableMap.of(
            KEPLER_ID_1, SKY_GROUP_ID_1, KEPLER_ID_2, SKY_GROUP_ID_1);

        List<PlanetaryCandidatesChunkUowTask> tasks = ImmutableList.of(new PlanetaryCandidatesChunkUowTask(
            0, KEPLER_ID_1, KEPLER_ID_2));

        CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

        allowing(celestialObjectOperations).retrieveSkyGroupIdsForKeplerIds(
            keplerIds);
        will(returnValue(keplerIdToSkyGroupMap));

        SkyGroupBinner skyGroupBinner = new SkyGroupBinner(
            celestialObjectOperations);
        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = skyGroupBinner.subdivide(
            tasks, keplerIds, new SkyGroupIdListsParameters());

        assertEquals(ImmutableList.of(new PlanetaryCandidatesChunkUowTask(
            SKY_GROUP_ID_1, KEPLER_ID_1, KEPLER_ID_2)), subdividedTasks);
    }

    @Test
    public void testSubdivideDifferentSkyGroups() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2);

        Map<Integer, Integer> keplerIdToSkyGroupMap = ImmutableMap.of(
            KEPLER_ID_1, SKY_GROUP_ID_1, KEPLER_ID_2, SKY_GROUP_ID_2);

        List<PlanetaryCandidatesChunkUowTask> tasks = ImmutableList.of(new PlanetaryCandidatesChunkUowTask(
            0, KEPLER_ID_1, KEPLER_ID_2));

        CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

        allowing(celestialObjectOperations).retrieveSkyGroupIdsForKeplerIds(
            keplerIds);
        will(returnValue(keplerIdToSkyGroupMap));

        SkyGroupBinner skyGroupBinner = new SkyGroupBinner(
            celestialObjectOperations);
        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = skyGroupBinner.subdivide(
            tasks, keplerIds, new SkyGroupIdListsParameters());

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(
            new PlanetaryCandidatesChunkUowTask(SKY_GROUP_ID_1, KEPLER_ID_1,
                KEPLER_ID_2), new PlanetaryCandidatesChunkUowTask(
                SKY_GROUP_ID_2, KEPLER_ID_1, KEPLER_ID_2));

        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testEmptyTasks() {
        List<PlanetaryCandidatesChunkUowTask> tasks = ImmutableList.of();

        CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

        List<Integer> keplerIds = ImmutableList.of();
        allowing(celestialObjectOperations).retrieveSkyGroupIdsForKeplerIds(
            keplerIds);
        will(returnValue(ImmutableMap.of()));

        SkyGroupBinner skyGroupBinner = new SkyGroupBinner(
            celestialObjectOperations);
        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = skyGroupBinner.subdivide(
            tasks, keplerIds, new SkyGroupIdListsParameters());

        assertEquals(tasks, subdividedTasks);
    }

    @Test
    public void testSubdivideDifferentSkyGroupsWithOnlyOneIncluded() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2);

        Map<Integer, Integer> keplerIdToSkyGroupMap = ImmutableMap.of(
            KEPLER_ID_1, SKY_GROUP_ID_1, KEPLER_ID_2, SKY_GROUP_ID_2);

        SkyGroupIdListsParameters skyGroupIdListsParameters = new SkyGroupIdListsParameters(
            new int[] { SKY_GROUP_ID_1 }, new int[0]);

        List<PlanetaryCandidatesChunkUowTask> tasks = ImmutableList.of(new PlanetaryCandidatesChunkUowTask(
            0, KEPLER_ID_1, KEPLER_ID_2));

        CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

        allowing(celestialObjectOperations).retrieveSkyGroupIdsForKeplerIds(
            keplerIds);
        will(returnValue(keplerIdToSkyGroupMap));

        SkyGroupBinner skyGroupBinner = new SkyGroupBinner(
            celestialObjectOperations);
        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = skyGroupBinner.subdivide(
            tasks, keplerIds, skyGroupIdListsParameters);

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(new PlanetaryCandidatesChunkUowTask(
            SKY_GROUP_ID_1, KEPLER_ID_1, KEPLER_ID_2));

        assertEquals(expectedTasks, subdividedTasks);
    }

}
