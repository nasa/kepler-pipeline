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

import java.util.List;

/**
 * This class subdivides {@link CadenceBinnable} tasks such that the subdivided
 * list of tasks have less than or equal to cadenceBinSize cadences. If
 * cadenceBinSize is 0, then no binning will be done.
 * 
 * @author Miles Cote
 * 
 */
public class CadenceBinner {

    public static <T extends CadenceBinnable> List<T> subdivide(List<T> tasks,
        int numberOfBins, int minimumBinSize) {
        List<T> subdividedTasks = newArrayList();
        for (T task : tasks) {
            int startCadence = task.getStartCadence();
            int endCadence = task.getEndCadence();

            List<Integer> allCadences = newArrayList();
            for (int i = startCadence; i <= endCadence; i++) {
                allCadences.add(i);
            }

            List<Integer> uowSizes = getUowSizes(startCadence, endCadence,
                numberOfBins, minimumBinSize);

            int taskStartCadence = startCadence;
            for (int uowSize : uowSizes) {
                @SuppressWarnings("unchecked")
                // makeCopy always returns T, so this is safe
                T subdividedTask = (T) task.makeCopy();
                subdividedTask.setStartCadence(taskStartCadence);
                subdividedTask.setEndCadence(taskStartCadence + uowSize - 1);
                subdividedTasks.add(subdividedTask);
                
                taskStartCadence += uowSize;
            }
        }

        return subdividedTasks;
    }

    private static List<Integer> getUowSizes(int startCadence, int endCadence,
        int numberOfBins, int minimumBinSize) {
        List<Integer> uowSizes = getUowSizes(startCadence, endCadence,
            numberOfBins);
        while (uowSizesTooSmall(uowSizes, minimumBinSize) && numberOfBins > 0) {
            numberOfBins--;
            uowSizes = getUowSizes(startCadence, endCadence, numberOfBins);
        }

        return uowSizes;
    }

    private static boolean uowSizesTooSmall(List<Integer> uowSizes,
        int minimumBinSize) {
        for (int uowSize : uowSizes) {
            if (uowSize < minimumBinSize) {
                return true;
            }
        }

        return false;
    }

    private static List<Integer> getUowSizes(int startCadence, int endCadence,
        int numberOfBins) {
        if (numberOfBins == 0) {
            // no binning
            return newArrayList(endCadence - startCadence + 1);
        }
        
        List<Integer> uowSizes = newArrayList();
        for (int i = 0; i < numberOfBins; i++) {
            // start with all bins initialized to 0.
            uowSizes.add(0);
        }

        int count = 0;
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
            int index = count % numberOfBins;
            Integer uowSize = uowSizes.get(index);
            uowSizes.set(index, uowSize + 1);
            count++;
        }

        return uowSizes;
    }
}
