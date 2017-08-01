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

import static com.google.common.collect.Maps.newHashMap;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class KeplerIdChunkBinnerTest extends JMockTest {

    private static final int KEPLER_ID_1 = 1;
    private static final int KEPLER_ID_2 = 2;
    private static final int KEPLER_ID_3 = 3;
    private static final int KEPLER_ID_4 = 4;
    private static final int KEPLER_ID_5 = 5;
    private static final int SKY_GROUP_ID = 6;

    private static final int ODD_CHUNK_SIZE = 3;
    private static final int EVEN_CHUNK_SIZE = 4;
    private static final int NO_BINNING_CHUNK_SIZE = 0;

    private List<PlanetaryCandidatesChunkUowTask> tasks = ImmutableList.of(taskOf(
        Integer.MIN_VALUE, Integer.MAX_VALUE));

    private CelestialObjectOperations celestialObjectOperations = mock(CelestialObjectOperations.class);

    private KeplerIdChunkBinner keplerIdChunkBinner = new KeplerIdChunkBinner(
        celestialObjectOperations);

    @Test
    public void testOddChunkSizeWithOneLessThanChunkSizeKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, ODD_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(taskOf(
            KEPLER_ID_1, KEPLER_ID_2));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testOddChunkSizeWithChunkSizeKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, ODD_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(
            taskOf(KEPLER_ID_1, KEPLER_ID_2), taskOf(KEPLER_ID_3, KEPLER_ID_3));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testOddChunkSizeWithOneMoreThanChunkSizeKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3, KEPLER_ID_4);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, ODD_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(
            taskOf(KEPLER_ID_1, KEPLER_ID_3), taskOf(KEPLER_ID_4, KEPLER_ID_4));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testEvenChunkSizeWithOneLessThanChunkSizeKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, EVEN_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(taskOf(
            KEPLER_ID_1, KEPLER_ID_3));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testEvenChunkSizeWithChunkSizeKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3, KEPLER_ID_4);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, EVEN_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(
            taskOf(KEPLER_ID_1, KEPLER_ID_3), taskOf(KEPLER_ID_4, KEPLER_ID_4));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testEvenChunkSizeWithOneMoreThanChunkSizeKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3, KEPLER_ID_4, KEPLER_ID_5);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, EVEN_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(
            taskOf(KEPLER_ID_1, KEPLER_ID_3), taskOf(KEPLER_ID_4, KEPLER_ID_5));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testNoBinning() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3, KEPLER_ID_4, KEPLER_ID_5);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, NO_BINNING_CHUNK_SIZE,
            createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of(taskOf(
            KEPLER_ID_1, KEPLER_ID_5));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testEmptyTasks() {
        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID_1, KEPLER_ID_2,
            KEPLER_ID_3, KEPLER_ID_4, KEPLER_ID_5);

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            new ArrayList<PlanetaryCandidatesChunkUowTask>(), EVEN_CHUNK_SIZE,
            createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = ImmutableList.of();
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testEmptyKeplerIds() {
        List<Integer> keplerIds = ImmutableList.of();

        List<PlanetaryCandidatesChunkUowTask> subdividedTasks = keplerIdChunkBinner.subdivide(
            tasks, EVEN_CHUNK_SIZE, createKeplerIdToSkyGroupMap(keplerIds));

        List<PlanetaryCandidatesChunkUowTask> expectedTasks = tasks;
        assertEquals(expectedTasks, subdividedTasks);
    }

    private Map<Integer, Integer> createKeplerIdToSkyGroupMap(
        List<Integer> keplerIds) {
        Map<Integer, Integer> keplerIdToSkyGroupMap = newHashMap();
        for (Integer keplerId : keplerIds) {
            keplerIdToSkyGroupMap.put(keplerId, SKY_GROUP_ID);
        }

        return keplerIdToSkyGroupMap;
    }

    private PlanetaryCandidatesChunkUowTask taskOf(int startKeplerId,
        int endKeplerId) {
        return new PlanetaryCandidatesChunkUowTask(SKY_GROUP_ID, startKeplerId,
            endKeplerId);
    }

}
