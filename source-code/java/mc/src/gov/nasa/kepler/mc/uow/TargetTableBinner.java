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
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLogResult;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.List;
import java.util.Set;

/**
 * Utility class that subdivides a list of tasks along target table boundaries.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class TargetTableBinner {

    public static <T extends CadenceBinnable> List<T> subdivide(List<T> tasks,
        Cadence.CadenceType cadenceType, List<Integer> excludeCadences) {

        TargetTable.TargetType targetType = TargetTable.TargetType.valueOf(cadenceType);
        LogCrud logCrud = new LogCrud();

        List<T> newTasks = newArrayList();

        for (T task : tasks) {
            int start = task.getStartCadence();
            int end = task.getEndCadence();

            List<PixelLogResult> pixelLogResults = logCrud.retrieveTableIdsForCadenceRange(
                targetType, start, end);

            checkForOutOfOrderTargetTables(pixelLogResults);

            trimExcludeCadences(pixelLogResults, excludeCadences);

            for (int i = 0; i < pixelLogResults.size(); i++) {
                PixelLogResult pixelLogResult = pixelLogResults.get(i);

                // makeCopy always returns T, so this is safe
                @SuppressWarnings("unchecked")
                T newTask = (T) task.makeCopy();
                newTask.setStartCadence(Math.max(
                    pixelLogResult.getCadenceStart(), newTask.getStartCadence()));
                newTask.setEndCadence(Math.min(pixelLogResult.getCadenceEnd(),
                    newTask.getEndCadence()));
                newTasks.add(newTask);
            }
        }

        return newTasks;
    }

    private static void trimExcludeCadences(
        List<PixelLogResult> pixelLogResults, List<Integer> excludeCadences) {
        Set<Integer> excludeCadenceSet = newHashSet(excludeCadences);
        for (PixelLogResult pixelLogResult : pixelLogResults) {
            while (excludeCadenceSet.contains(pixelLogResult.getCadenceStart())) {
                excludeCadenceSet.remove(pixelLogResult.getCadenceStart());
                pixelLogResult.setCadenceStart(pixelLogResult.getCadenceStart() + 1);
            }

            while (excludeCadenceSet.contains(pixelLogResult.getCadenceEnd())) {
                excludeCadenceSet.remove(pixelLogResult.getCadenceEnd());
                pixelLogResult.setCadenceEnd(pixelLogResult.getCadenceEnd() - 1);
            }
        }
    }

    private static void checkForOutOfOrderTargetTables(
        List<PixelLogResult> targetTables) {
        PixelLogResult previousPixelLogResult = null;
        for (PixelLogResult pixelLogResult : targetTables) {
            if (previousPixelLogResult != null) {
                if (previousPixelLogResult.getCadenceEnd() >= pixelLogResult.getCadenceStart()) {
                    throw new IllegalStateException(
                        "TargetTables are out of order." + "\n  targetTableId "
                            + previousPixelLogResult.getTableId()
                            + " has cadence range "
                            + previousPixelLogResult.getCadenceStart() + " to "
                            + previousPixelLogResult.getCadenceEnd()
                            + "\n  targetTableId "
                            + pixelLogResult.getTableId()
                            + " has cadence range "
                            + pixelLogResult.getCadenceStart() + " to "
                            + pixelLogResult.getCadenceEnd());
                }
            }

            previousPixelLogResult = pixelLogResult;
        }
    }
}
