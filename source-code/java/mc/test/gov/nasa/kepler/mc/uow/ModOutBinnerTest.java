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
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;

import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import org.junit.Test;

public class ModOutBinnerTest {

    @Test
    public void testNoFilters() {
        testSubdivide(new int[0], new int[0], 0, 84);
    }

    @Test
    public void testIncludes() {
        testSubdivide(new int[] { 1, 2, 3 }, new int[0], 0, 3);
    }

    @Test
    public void testExcludes() {
        testSubdivide(new int[0], new int[] { 1, 2, 3 }, 0, 81);
    }

    @Test
    public void testExcludeOverride() {
        testSubdivide(new int[] { 1, 2, 3 }, new int[] { 2 }, 0, 2);
    }

    @Test
    public void testNoFiltersWithTwoChannelsPerTask() {
        testSubdivide(new int[0], new int[0], 2, 42);
    }

    @Test
    public void testIncludesWithTwoChannelsPerTask() {
        testSubdivide(new int[] { 1, 2, 3 }, new int[0], 2, 2);
    }

    @Test
    public void testExcludesWithTwoChannelsPerTask() {
        testSubdivide(new int[0], new int[] { 1, 2, 3 }, 2, 41);
    }

    @Test
    public void testExcludeOverrideWithTwoChannelsPerTask() {
        testSubdivide(new int[] { 1, 2, 3 }, new int[] { 2 }, 2, 1);
    }

    private void testSubdivide(int[] channelIncludeArray,
        int[] channelExcludeArray, int channelsPerTask, int expectedTaskCount) {
        ModOutCadenceUowTask task = new ModOutCadenceUowTask();
        List<ModOutCadenceUowTask> list = new LinkedList<ModOutCadenceUowTask>();
        list.add(task);

        ModuleOutputListsParameters modOutLists = new ModuleOutputListsParameters(
            channelIncludeArray, channelExcludeArray);
        modOutLists.setChannelsPerTask(channelsPerTask);

        List<ModOutCadenceUowTask> newTasks = ModOutBinner.subDivide(list,
            modOutLists);

        assertEquals(expectedTaskCount, newTasks.size());
    }

    // If the channel group tests are updated, consider updating the
    // similar tests in ModuleOutputListsParametersTest.

    @Test(expected = IllegalArgumentException.class)
    public void testSubdivideWithNullChannelGroup() {
        testSubdivide((String) null,
            Arrays.asList(Arrays.asList(new Integer[] {})));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSubdivideWithEmptyChannelGroup() {
        testSubdivide("", Arrays.asList(Arrays.asList(new Integer[] {})));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSubdivideWithInvalidChannelGroup() {
        testSubdivide("X", Arrays.asList(Arrays.asList(new Integer[] {})));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSubdivideWithValidAndInvalidChannelGroup() {
        testSubdivide("1;X", Arrays.asList(Arrays.asList(new Integer[] {})));
    }

    @Test
    public void testSubdivideWithOneChannelGroup() {
        testSubdivide("1", Arrays.asList(Arrays.asList(new Integer[] { 1 })));
        testSubdivide("1,2",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 })));
        testSubdivide("  1  ,  2  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 })));
    }

    @Test
    public void testSubdivideWithTwoChannelGroups() {
        testSubdivide(
            "1;2",
            Arrays.asList(Arrays.asList(new Integer[] { 1 }),
                Arrays.asList(new Integer[] { 2 })));
        testSubdivide(
            "1,2;3,4",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 }),
                Arrays.asList(new Integer[] { 3, 4 })));
        testSubdivide(
            "  1  ,  3  ;  2  ,  4  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 2, 4 })));
    }

    @Test
    public void testSubdivideWithThreeChannelGroups() {
        testSubdivide(
            "1;2;3",
            Arrays.asList(Arrays.asList(new Integer[] { 1 }),
                Arrays.asList(new Integer[] { 2 }),
                Arrays.asList(new Integer[] { 3 })));
        testSubdivide(
            "1,2;3,4;5,6",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 }),
                Arrays.asList(new Integer[] { 3, 4 }),
                Arrays.asList(new Integer[] { 5, 6 })));
        testSubdivide(
            "  1  ,  3   ;  2  ,  5  ;  4  ,  6  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 2, 5 }),
                Arrays.asList(new Integer[] { 4, 6 })));
    }

    @Test
    public void testSubdivideWithThreeChannelGroupsSomeEmpty() {
        testSubdivide(
            "   ;  2  ,  5  ;  4  ,  6  ",
            Arrays.asList(Arrays.asList(new Integer[] { 2, 5 }),
                Arrays.asList(new Integer[] { 4, 6 })));

        testSubdivide(
            "  1  ,  3   ;    ;  4  ,  6  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 4, 6 })));
        testSubdivide(
            "  1  ,  3   ;  2  ,  5  ;    ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 2, 5 })));
    }

    @Test
    public void testSubdivideWithThreeChannelGroupsAndExcludedChannels() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1,2;3,4;5,6");
        moduleOutputListsParameters.setChannelExcludeArray(new int[] { 1, 3, 5,
            8 });
        testSubdivide(
            moduleOutputListsParameters,
            Arrays.asList(Arrays.asList(new Integer[] { 2 }),
                Arrays.asList(new Integer[] { 4 }),
                Arrays.asList(new Integer[] { 6 })));

        moduleOutputListsParameters.setChannelExcludeArray(new int[] { 1, 2, 5,
            8 });
        testSubdivide(
            moduleOutputListsParameters,
            Arrays.asList(Arrays.asList(new Integer[] { 3, 4 }),
                Arrays.asList(new Integer[] { 6 })));
    }

    private void testSubdivide(String channelGroups,
        List<List<Integer>> channelGroupsList) {

        testSubdivide(new ModuleOutputListsParameters(channelGroups),
            channelGroupsList);
    }

    private void testSubdivide(
        ModuleOutputListsParameters moduleOutputListsParameters,
        List<List<Integer>> channelGroupsList) {

        List<ModOutCadenceUowTask> list = new LinkedList<ModOutCadenceUowTask>();
        list.add(new ModOutCadenceUowTask());
        List<ModOutCadenceUowTask> newTasks = ModOutBinner.subDivide(list,
            moduleOutputListsParameters);

        assertEquals("number of channel groups", channelGroupsList.size(),
            newTasks.size());

        for (int i = 0; i < newTasks.size(); i++) {
            ModOutCadenceUowTask task = newTasks.get(i);
            int[] channels = task.getChannels();
            List<Integer> channelGroup = channelGroupsList.get(i);
            assertEquals("channel group size", channelGroup.size(),
                channels.length);
            for (int j = 0; j < channels.length; j++) {
                assertEquals("channel", channelGroup.get(j),
                    (Integer) channels[j]);
            }
        }
    }
}
