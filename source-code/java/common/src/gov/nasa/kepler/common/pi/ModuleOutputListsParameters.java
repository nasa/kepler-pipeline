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

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ranges.Range;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * These parameters control which channels the {@link ModOutBinner} (used by
 * several {@link UowTaskGenerator}s) will generate tasks for.
 * 
 * This interface must be implemented by sub-classes of {@link Parameters} for
 * pipelines that contain nodes that use the ModOutUowTaskGenerator (or a
 * sub-class of it).
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Bill Wohler
 */
public class ModuleOutputListsParameters implements Parameters {

    /*
     * See ModuleOutputListsParametersBeanInfo for documentation of these
     * fields.
     */
    private boolean channelGroupsEnabled;
    private String channelGroups = "";

    private int[] channelIncludeArray = new int[0];
    private int[] channelExcludeArray = new int[0];
    private int channelsPerTask;

    private int[] deadChannelArray = new int[0];
    private int[] cadenceOfDeathArray = new int[0];
    
    private int channelForStoringNonChannelSpecificData;

    public ModuleOutputListsParameters() {
        this(new int[0], new int[0]);
    }

    public ModuleOutputListsParameters(int[] channelIncludeArray,
        int[] channelExcludeArray) {
        this.channelIncludeArray = channelIncludeArray;
        this.channelExcludeArray = channelExcludeArray;
    }

    public ModuleOutputListsParameters(String channelGroups) {
        channelGroupsEnabled = true;
        this.channelGroups = channelGroups;
    }

    /**
     * Returns true if the specified mod/out passes the specified
     * include/exclude filters
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param includeArray
     * @param excludeArray
     * @return
     */
    public boolean included(int ccdModule, int ccdOutput) {
        int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);

        // excludes trump includes, so check those first
        if (channelExcludeArray != null && channelExcludeArray.length != 0
            && ArrayUtils.contains(channelExcludeArray, channel)) {
            return false;
        }

        if (channelGroupsEnabled) {
            return channelGroupsList().contains(channel);
        }

        if (channelIncludeArray != null && channelIncludeArray.length != 0) {
            return ArrayUtils.contains(channelIncludeArray, channel);
        } else {
            // an empty include array means include everything
            return true;
        }
    }

    private List<Integer> channelGroupsList() {
        if (channelGroupsEnabled == false) {
            throw new IllegalStateException(
                "Cannot call channelGroupsList unless channelGroupsEnabled is true");
        }

        if (channelGroups == null || channelGroups.isEmpty()) {
            throw new IllegalArgumentException(
                "channelGroups cannot be empty if channelGroupsEnabled is true");
        }

        return extractChannelGroup(channelGroups.split("(,|;)"));
    }

    public List<List<Integer>> channelGroupsLists() {
        if (channelGroupsEnabled == false) {
            throw new IllegalStateException(
                "Cannot call channelGroupsLists unless channelGroupsEnabled is true");
        }

        if (channelGroups == null || channelGroups.isEmpty()) {
            throw new IllegalArgumentException(
                "channelGroups cannot be empty if channelGroupsEnabled is true");
        }

        List<List<Integer>> channelGroupsLists = newArrayList();
        String[] groups = channelGroups.split(";");
        for (String group : groups) {
            String trimmedGroup = group.trim();
            if (trimmedGroup.isEmpty()) {
                continue;
            }
            List<Integer> channelGroup = extractChannelGroup(trimmedGroup.split(","));
            if (!channelGroup.isEmpty()) {
                channelGroupsLists.add(channelGroup);
            }
        }

        return channelGroupsLists;
    }

    private List<Integer> extractChannelGroup(String[] items) {
        List<Integer> channelGroup = newArrayList();
        for (String item : items) {
            try {
                String trimmedChannel = item.trim();
                if (!trimmedChannel.isEmpty()) {
                    List<Integer> channels = newArrayList();
                    if (trimmedChannel.contains(":")) {
                        // it's actually a range of channels
                        Range range = Range.forString(trimmedChannel);
                        channels.addAll(range.toIntegers());
                    } else {
                        // just a single channel
                        channels.add(Integer.parseInt(trimmedChannel));
                    }

                    for (int channel : channels) {
                        if (channelExcludeArray == null
                            || channelExcludeArray.length == 0
                            || !ArrayUtils.contains(channelExcludeArray,
                                channel)) {
                            channelGroup.add(channel);
                        }
                    }
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException(String.format(
                    "The entry %s is not permitted in channelGroups", item));
            }
        }
        return channelGroup;
    }

    public List<Pair<Integer, Integer>> toDeadChannelCadencePairs() {
        if (cadenceOfDeathArray.length != deadChannelArray.length) {
            throw new IllegalArgumentException(
                "cadenceOfDeathArray cannot have a different length than deadChannelArray."
                    + "\n  cadenceOfDeathArray: " + cadenceOfDeathArray.length
                    + "\n  deadChannelArray: " + deadChannelArray.length);
        }

        List<Pair<Integer, Integer>> deadChannelCadencePairs = newArrayList();
        for (int i = 0; i < cadenceOfDeathArray.length; i++) {
            deadChannelCadencePairs.add(Pair.of(deadChannelArray[i],
                cadenceOfDeathArray[i]));
        }

        return deadChannelCadencePairs;
    }

    public int[] getChannelExcludeArray() {
        return channelExcludeArray;
    }

    public void setChannelExcludeArray(int[] channelExcludeArray) {
        this.channelExcludeArray = channelExcludeArray;
    }

    public String getChannelGroups() {
        return channelGroups;
    }

    public void setChannelGroups(String channelGroups) {
        this.channelGroups = channelGroups;
    }

    public boolean isChannelGroupsEnabled() {
        return channelGroupsEnabled;
    }

    public void setChannelGroupsEnabled(boolean channelGroupsEnabled) {
        this.channelGroupsEnabled = channelGroupsEnabled;
    }

    public int[] getChannelIncludeArray() {
        return channelIncludeArray;
    }

    public void setChannelIncludeArray(int[] channelIncludeArray) {
        this.channelIncludeArray = channelIncludeArray;
    }

    public int getChannelsPerTask() {
        return channelsPerTask;
    }

    public void setChannelsPerTask(int channelsPerTask) {
        this.channelsPerTask = channelsPerTask;
    }

    public int[] getDeadChannelArray() {
        return deadChannelArray;
    }

    public void setDeadChannelArray(int[] deadChannelArray) {
        this.deadChannelArray = deadChannelArray;
    }

    public int[] getCadenceOfDeathArray() {
        return cadenceOfDeathArray;
    }

    public void setCadenceOfDeathArray(int[] cadenceOfDeathArray) {
        this.cadenceOfDeathArray = cadenceOfDeathArray;
    }

    public int getChannelForStoringNonChannelSpecificData() {
        return channelForStoringNonChannelSpecificData;
    }

    public void setChannelForStoringNonChannelSpecificData(
        int channelForStoringNonChannelSpecificData) {
        this.channelForStoringNonChannelSpecificData = channelForStoringNonChannelSpecificData;
    }
}
