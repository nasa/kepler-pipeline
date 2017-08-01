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
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;

import java.util.List;

import com.google.common.primitives.Ints;

/**
 * Utility class that subdivides a list of tasks by module/output (turns each
 * task in the input list into 84 tasks in the output list)
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Bill Wohler
 */
public class ModOutBinner {

    public static <T extends ModOutBinnable> List<T> subDivide(List<T> tasks,
        ModuleOutputListsParameters modOutLists) {

        if (modOutLists.isChannelGroupsEnabled()) {
            return binByChannelGroup(tasks, modOutLists);
        }

        return binByChannelsPerTask(tasks, modOutLists);
    }

    private static <T extends ModOutBinnable> List<T> binByChannelGroup(
        List<T> tasks, ModuleOutputListsParameters moduleOutputListsParameters) {

        List<T> bins = newArrayList();
        List<List<Integer>> channelGroupsLists = moduleOutputListsParameters.channelGroupsLists();

        for (T task : tasks) {
            for (List<Integer> channelGroup : channelGroupsLists) {
                @SuppressWarnings("unchecked")
                T newTask = (T) task.makeCopy();
                newTask.setChannels(Ints.toArray(channelGroup));
                bins.add(newTask);
            }
        }

        return bins;
    }

    private static <T extends ModOutBinnable> List<T> binByChannelsPerTask(
        List<T> tasks, ModuleOutputListsParameters modOutLists) {

        List<T> bins = newArrayList();
        for (T task : tasks) {
            List<Integer> channels = newArrayList();
            for (int ccdModule : FcConstants.modulesList) {
                for (int ccdOutput : FcConstants.outputsList) {
                    if (modOutLists.included(ccdModule, ccdOutput)) {
                        channels.add(FcConstants.getChannelNumber(ccdModule,
                            ccdOutput));

                        if (channels.size() >= modOutLists.getChannelsPerTask()) {
                            @SuppressWarnings("unchecked")
                            // makeCopy always returns T, so this is safe
                            T newTask = (T) task.makeCopy();
                            newTask.setChannels(Ints.toArray(channels));
                            bins.add(newTask);
                            channels = newArrayList();
                        }
                    }
                }
            }

            // If there were any channels not yet added to a task, add them now.
            if (!channels.isEmpty()) {
                @SuppressWarnings("unchecked")
                // makeCopy always returns T, so this is safe
                T newTask = (T) task.makeCopy();
                newTask.setChannels(Ints.toArray(channels));
                bins.add(newTask);
                channels = newArrayList();
            }
        }

        return bins;
    }
}
