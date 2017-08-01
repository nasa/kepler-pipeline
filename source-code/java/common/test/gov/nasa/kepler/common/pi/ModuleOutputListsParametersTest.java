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

package gov.nasa.kepler.common.pi;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pojo.PojoTest;

import java.util.Arrays;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class ModuleOutputListsParametersTest {

    private static final int CHANNEL_1 = 1;
    private static final int CHANNEL_2 = 2;

    private static final int DEAD_CHANNEL = 3;
    private static final int DEATH_CADENCE = 4;

    @Test
    public void testGettersSetters() {
        PojoTest.testGettersSetters(new ModuleOutputListsParameters());
    }

    @Test
    public void testIncludedWithIncludedChannel() {
        int[] channelIncludeArray = { CHANNEL_1 };
        int[] channelExcludeArray = {};
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            channelIncludeArray, channelExcludeArray);

        assertEquals(true, included(moduleOutputListsParameters, CHANNEL_1));
    }

    @Test
    public void testIncludedWithExcludedChannel() {
        int[] channelIncludeArray = { CHANNEL_1, CHANNEL_2 };
        int[] channelExcludeArray = { CHANNEL_2 };
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            channelIncludeArray, channelExcludeArray);

        assertEquals(true, included(moduleOutputListsParameters, CHANNEL_1));
        assertEquals(false, included(moduleOutputListsParameters, CHANNEL_2));
    }

    @Test
    public void testIncludedWithEmptyArrays() {
        int[] channelIncludeArray = {};
        int[] channelExcludeArray = {};
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            channelIncludeArray, channelExcludeArray);

        assertEquals(true, included(moduleOutputListsParameters, CHANNEL_1));
        assertEquals(true, included(moduleOutputListsParameters, CHANNEL_2));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testIncludedWithEmptyChannelGroups() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            null);
        assertEquals(true, moduleOutputListsParameters.isChannelGroupsEnabled());
        included(moduleOutputListsParameters, 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testIncludedWithInvalidChannelGroup() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "X");
        included(moduleOutputListsParameters, 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testIncludedWithValidAndInvalidChannelGroup() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1;X");
        included(moduleOutputListsParameters, 1);
    }

    @Test
    public void testIncludedWithOneChannelGroup() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1");
        assertEquals(true, moduleOutputListsParameters.isChannelGroupsEnabled());
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(false, included(moduleOutputListsParameters, 2));

        moduleOutputListsParameters.setChannelGroups("1,2");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));

        moduleOutputListsParameters.setChannelGroups("  1  ,  2  ");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
    }

    @Test
    public void testIncludedWithTwoChannelGroups() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1;2");
        assertEquals(true, moduleOutputListsParameters.isChannelGroupsEnabled());
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(false, included(moduleOutputListsParameters, 3));
        assertEquals(false, included(moduleOutputListsParameters, 4));
        assertEquals(false, included(moduleOutputListsParameters, 5));

        moduleOutputListsParameters.setChannelGroups("1,2;3,4");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(false, included(moduleOutputListsParameters, 5));

        moduleOutputListsParameters.setChannelGroups("  1  ,  3  ;  2  ,  4  ");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(false, included(moduleOutputListsParameters, 5));
    }

    @Test
    public void testIncludedWithThreeChannelGroups() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1;2;3");
        assertEquals(true, moduleOutputListsParameters.isChannelGroupsEnabled());
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(false, included(moduleOutputListsParameters, 4));
        assertEquals(false, included(moduleOutputListsParameters, 5));
        assertEquals(false, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));

        moduleOutputListsParameters.setChannelGroups("1,2;3,4;5,6");
        assertEquals(true, moduleOutputListsParameters.isChannelGroupsEnabled());
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(true, included(moduleOutputListsParameters, 5));
        assertEquals(true, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));

        moduleOutputListsParameters.setChannelGroups("  1  ,  3   ;  2  ,  5  ;  4  ,  6  ");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(true, included(moduleOutputListsParameters, 5));
        assertEquals(true, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));
    }

    @Test
    public void testIncludedWithThreeChannelGroupsSomeEmpty() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "   ;  2  ,  5  ;  4  ,  6  ");
        assertEquals(false, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(false, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(true, included(moduleOutputListsParameters, 5));
        assertEquals(true, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));

        moduleOutputListsParameters.setChannelGroups("  1  ,  3   ;    ;  4  ,  6  ");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(false, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(false, included(moduleOutputListsParameters, 5));
        assertEquals(true, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));

        moduleOutputListsParameters.setChannelGroups("  1  ,  3   ;  2  ,  5  ;    ");
        assertEquals(true, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(true, included(moduleOutputListsParameters, 3));
        assertEquals(false, included(moduleOutputListsParameters, 4));
        assertEquals(true, included(moduleOutputListsParameters, 5));
        assertEquals(false, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));
    }

    @Test
    public void testIncludedWithThreeChannelGroupsAndExcludedChannels() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1,2;3,4;5,6");
        moduleOutputListsParameters.setChannelExcludeArray(new int[] { 1, 3, 5,
            8 });
        assertEquals(false, included(moduleOutputListsParameters, 1));
        assertEquals(true, included(moduleOutputListsParameters, 2));
        assertEquals(false, included(moduleOutputListsParameters, 3));
        assertEquals(true, included(moduleOutputListsParameters, 4));
        assertEquals(false, included(moduleOutputListsParameters, 5));
        assertEquals(true, included(moduleOutputListsParameters, 6));
        assertEquals(false, included(moduleOutputListsParameters, 7));
    }

    private boolean included(
        ModuleOutputListsParameters moduleOutputListsParameters, int channel) {
        Pair<Integer, Integer> moduleOutput = FcConstants.getModuleOutput(channel);
        return moduleOutputListsParameters.included(moduleOutput.left,
            moduleOutput.right);
    }

    // If the channel group tests are updated, consider updating the
    // similar tests in ModOutBinnerTest.

    @Test(expected = IllegalArgumentException.class)
    public void testChannelGroupsListsWithIllegalArgument() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            null);
        moduleOutputListsParameters.channelGroupsLists();
    }

    @Test(expected = IllegalStateException.class)
    public void testChannelGroupsListsWithIllegalState() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters();
        moduleOutputListsParameters.setChannelGroupsEnabled(false);
        moduleOutputListsParameters.channelGroupsLists();
    }

    @Test(expected = IllegalArgumentException.class)
    public void testChannelGroupsListsWithInvalidChannelGroup() {
        testChannelGroupsLists("X",
            Arrays.asList(Arrays.asList(new Integer[] {})));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testChannelGroupsListsWithValidAndInvalidChannelGroup() {
        testChannelGroupsLists("1;X",
            Arrays.asList(Arrays.asList(new Integer[] {})));
    }

    @Test
    public void testChannelGroupsListsWithOneChannelGroup() {
        testChannelGroupsLists("1",
            Arrays.asList(Arrays.asList(new Integer[] { 1 })));
        testChannelGroupsLists("1,2",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 })));
        testChannelGroupsLists("  1  ,  2  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 })));
    }

    @Test
    public void testChannelGroupsListsWithTwoChannelGroups() {
        testChannelGroupsLists(
            "1;2",
            Arrays.asList(Arrays.asList(new Integer[] { 1 }),
                Arrays.asList(new Integer[] { 2 })));
        testChannelGroupsLists(
            "1,2;3,4",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 }),
                Arrays.asList(new Integer[] { 3, 4 })));
        testChannelGroupsLists(
            "  1  ,  3  ;  2  ,  4  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 2, 4 })));
    }

    @Test
    public void testChannelGroupsListsWithThreeChannelGroups() {
        testChannelGroupsLists(
            "1;2;3",
            Arrays.asList(Arrays.asList(new Integer[] { 1 }),
                Arrays.asList(new Integer[] { 2 }),
                Arrays.asList(new Integer[] { 3 })));
        testChannelGroupsLists(
            "1,2;3,4;5,6",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2 }),
                Arrays.asList(new Integer[] { 3, 4 }),
                Arrays.asList(new Integer[] { 5, 6 })));
        testChannelGroupsLists(
            "  1  ,  3   ;  2  ,  5  ;  4  ,  6  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 2, 5 }),
                Arrays.asList(new Integer[] { 4, 6 })));
    }

    @Test
    public void testChannelGroupsListWithThreeChannelGroupsSomeEmpty() {
        testChannelGroupsLists(
            "   ;  2  ,  5  ;  4  ,  6  ",
            Arrays.asList(Arrays.asList(new Integer[] { 2, 5 }),
                Arrays.asList(new Integer[] { 4, 6 })));

        testChannelGroupsLists(
            "  1  ,  3   ;    ;  4  ,  6  ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 4, 6 })));
        testChannelGroupsLists(
            "  1  ,  3   ;  2  ,  5  ;    ",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 3 }),
                Arrays.asList(new Integer[] { 2, 5 })));
    }
    
    @Test
    public void testChannelGroupsListWithRealisticRanges() {
        testChannelGroupsLists(
            "1:3,7:9;4:6",
            Arrays.asList(Arrays.asList(new Integer[] { 1, 2, 3, 7, 8, 9}),
                Arrays.asList(new Integer[] { 4, 5, 6})));
    }
    
    @Test
    public void testChannelGroupsListWithThreeChannelGroupsAndExcludedChannels() {
        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters(
            "1,2;3,4;5,6");

        moduleOutputListsParameters.setChannelExcludeArray(new int[] { 1, 3, 5,
            8 });
        testChannelGroupsLists(
            moduleOutputListsParameters,
            Arrays.asList(Arrays.asList(new Integer[] { 2 }),
                Arrays.asList(new Integer[] { 4 }),
                Arrays.asList(new Integer[] { 6 })));

        moduleOutputListsParameters.setChannelExcludeArray(new int[] { 1, 2, 5,
            8 });
        testChannelGroupsLists(
            moduleOutputListsParameters,
            Arrays.asList(Arrays.asList(new Integer[] { 3, 4 }),
                Arrays.asList(new Integer[] { 6 })));
    }

    private void testChannelGroupsLists(String channelGroups,
        List<List<Integer>> channelGroupsList) {

        testChannelGroupsLists(new ModuleOutputListsParameters(channelGroups),
            channelGroupsList);
    }

    private void testChannelGroupsLists(
        ModuleOutputListsParameters moduleOutputListsParameters,
        List<List<Integer>> expectedChannelGroupsLists) {

        List<List<Integer>> channelGroupsLists = moduleOutputListsParameters.channelGroupsLists();

        assertEquals("number of channel groups",
            expectedChannelGroupsLists.size(), channelGroupsLists.size());

        for (int i = 0; i < channelGroupsLists.size(); i++) {
            List<Integer> expectedChannelGroup = expectedChannelGroupsLists.get(i);
            List<Integer> channelGroup = channelGroupsLists.get(i);
            assertEquals("channel group size", expectedChannelGroup.size(),
                expectedChannelGroup.size());
            for (int j = 0; j < expectedChannelGroup.size(); j++) {
                assertEquals("channel", expectedChannelGroup.get(j),
                    channelGroup.get(j));
            }
        }
    }

    @Test
    public void testToDeadChannelCadencePairs() {
        int[] deadChannelArray = { DEAD_CHANNEL };
        int[] cadenceOfDeathArray = { DEATH_CADENCE };

        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters();
        moduleOutputListsParameters.setDeadChannelArray(deadChannelArray);
        moduleOutputListsParameters.setCadenceOfDeathArray(cadenceOfDeathArray);

        List<Pair<Integer, Integer>> expectedPairs = ImmutableList.of(Pair.of(
            DEAD_CHANNEL, DEATH_CADENCE));
        assertEquals(expectedPairs,
            moduleOutputListsParameters.toDeadChannelCadencePairs());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testToDeadChannelCadencePairsWithIllegalDeadChannelArray() {
        int[] deadChannelArray = { DEAD_CHANNEL, DEATH_CADENCE };
        int[] cadenceOfDeathArray = { DEATH_CADENCE };

        ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters();
        moduleOutputListsParameters.setDeadChannelArray(deadChannelArray);
        moduleOutputListsParameters.setCadenceOfDeathArray(cadenceOfDeathArray);

        List<Pair<Integer, Integer>> expectedPairs = ImmutableList.of(Pair.of(
            DEAD_CHANNEL, DEATH_CADENCE));
        assertEquals(expectedPairs,
            moduleOutputListsParameters.toDeadChannelCadencePairs());
    }

}
