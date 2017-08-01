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

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class DeadChannelTrimmerTest {

    private static final int CHANNEL = 5;
    private static final int START_CADENCE = 100;
    private static final int END_CADENCE = 200;

    private DeadChannelTrimmer deadChannelTrimmer = new DeadChannelTrimmer();

    @Test
    public void testTrimForDifferentChannel() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL + 1, START_CADENCE));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(CHANNEL,
            START_CADENCE, END_CADENCE);
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithOneChannelBeforeStartCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL, START_CADENCE - 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf();
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithOneChannelEqualsStartCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL, START_CADENCE));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf();
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithOneChannelAfterStartCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL, START_CADENCE + 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(CHANNEL,
            START_CADENCE, START_CADENCE);
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithOneChannelBeforeEndCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL, END_CADENCE - 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(CHANNEL,
            START_CADENCE, END_CADENCE - 2);
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithOneChannelEqualsEndCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL, END_CADENCE));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(CHANNEL,
            START_CADENCE, END_CADENCE - 1);
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithOneChannelAfterEndCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(CHANNEL, START_CADENCE, END_CADENCE),
            deadChannelCadencePairsOf(CHANNEL, END_CADENCE + 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(CHANNEL,
            START_CADENCE, END_CADENCE);
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithThreeChannelsBeforeStartCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(taskOf(new int[] { CHANNEL, CHANNEL + 1, CHANNEL + 2 },
                START_CADENCE, END_CADENCE)),
            deadChannelCadencePairsOf(CHANNEL, START_CADENCE - 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(taskOf(new int[] {
            CHANNEL + 1, CHANNEL + 2 }, START_CADENCE, END_CADENCE));
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithThreeChannelsEqualsStartCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(taskOf(new int[] { CHANNEL, CHANNEL + 1, CHANNEL + 2 },
                START_CADENCE, END_CADENCE)),
            deadChannelCadencePairsOf(CHANNEL, START_CADENCE));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(taskOf(new int[] {
            CHANNEL + 1, CHANNEL + 2 }, START_CADENCE, END_CADENCE));
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithThreeChannelsAfterStartCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(taskOf(new int[] { CHANNEL, CHANNEL + 1, CHANNEL + 2 },
                START_CADENCE, END_CADENCE)),
            deadChannelCadencePairsOf(CHANNEL, START_CADENCE + 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(
            taskOf(new int[] { CHANNEL + 1, CHANNEL + 2 }, START_CADENCE,
                END_CADENCE), taskOf(CHANNEL, START_CADENCE, START_CADENCE));
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithThreeChannelsBeforeEndCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(taskOf(new int[] { CHANNEL, CHANNEL + 1, CHANNEL + 2 },
                START_CADENCE, END_CADENCE)),
            deadChannelCadencePairsOf(CHANNEL, END_CADENCE - 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(
            taskOf(new int[] { CHANNEL + 1, CHANNEL + 2 }, START_CADENCE,
                END_CADENCE), taskOf(CHANNEL, START_CADENCE, END_CADENCE - 2));
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithThreeChannelsEqualsEndCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(taskOf(new int[] { CHANNEL, CHANNEL + 1, CHANNEL + 2 },
                START_CADENCE, END_CADENCE)),
            deadChannelCadencePairsOf(CHANNEL, END_CADENCE));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(
            taskOf(new int[] { CHANNEL + 1, CHANNEL + 2 }, START_CADENCE,
                END_CADENCE), taskOf(CHANNEL, START_CADENCE, END_CADENCE - 1));
        assertEquals(expectedTasks, trimmedTasks);
    }

    @Test
    public void testTrimDeadCadenceWithThreeChannelsAfterEndCadence() {
        List<ModOutCadenceUowTask> trimmedTasks = deadChannelTrimmer.trim(
            taskListOf(taskOf(new int[] { CHANNEL, CHANNEL + 1, CHANNEL + 2 },
                START_CADENCE, END_CADENCE)),
            deadChannelCadencePairsOf(CHANNEL, END_CADENCE + 1));

        List<ModOutCadenceUowTask> expectedTasks = taskListOf(taskOf(new int[] {
            CHANNEL, CHANNEL + 1, CHANNEL + 2 }, START_CADENCE, END_CADENCE));
        assertEquals(expectedTasks, trimmedTasks);
    }

    private List<Pair<Integer, Integer>> deadChannelCadencePairsOf(int channel,
        int cadence) {
        return ImmutableList.of(deadChannelCadencePairOf(channel, cadence));
    }

    private Pair<Integer, Integer> deadChannelCadencePairOf(int channel,
        int cadence) {
        return Pair.of(channel, cadence);
    }

    private List<ModOutCadenceUowTask> taskListOf() {
        return new ArrayList<ModOutCadenceUowTask>();
    }

    private List<ModOutCadenceUowTask> taskListOf(ModOutCadenceUowTask... tasks) {
        List<ModOutCadenceUowTask> copiedTasks = newArrayList();
        for (ModOutCadenceUowTask task : tasks) {
            copiedTasks.add(task);
        }
        return copiedTasks;
    }

    private List<ModOutCadenceUowTask> taskListOf(int channelNumber,
        int startCadence, int endCadence) {
        return taskListOf(taskOf(channelNumber, startCadence, endCadence));
    }

    private ModOutCadenceUowTask taskOf(int channelNumber, int startCadence,
        int endCadence) {
        return taskOf(new int[] { channelNumber }, startCadence, endCadence);
    }

    private ModOutCadenceUowTask taskOf(int[] channelNumbers, int startCadence,
        int endCadence) {
        return new ModOutCadenceUowTask(channelNumbers, startCadence,
            endCadence);
    }

}
