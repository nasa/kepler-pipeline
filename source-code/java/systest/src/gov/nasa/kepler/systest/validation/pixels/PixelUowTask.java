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

package gov.nasa.kepler.systest.validation.pixels;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.mc.uow.CadenceBinner;
import gov.nasa.kepler.mc.uow.ModOutBinner;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.Arrays;
import java.util.Random;
import java.util.Set;
import java.util.TreeSet;

final class PixelUowTask extends ModOutCadenceUowTask implements
    Comparable<PixelUowTask> {

    private static final int RANDOM_SEED = 1843960572;

    private static final Random RANDOM = new Random(RANDOM_SEED);

    private Integer key;

    public PixelUowTask(int ccdModule, int ccdOutput, int startCadence,
        int endCadence) {
        super(ccdModule, ccdOutput, startCadence, endCadence);
        key = RANDOM.nextInt();
    }

    @Override
    public int compareTo(PixelUowTask other) {

        return key.compareTo(other.key);
    }

    @Override
    public PixelUowTask makeCopy() {

        return new PixelUowTask(getCcdModule(), getCcdOutput(),
            getStartCadence(), getEndCadence());
    }

    public static Set<PixelUowTask> createTasks(int ccdModule, int ccdOutput,
        Pair<Integer, Integer> cadenceRange, int chunkSize) {

        ModuleOutputListsParameters modOutLists = new ModuleOutputListsParameters();
        if (ccdModule > 0 && ccdOutput > 0) {
            modOutLists.setChannelIncludeArray(new int[] { FcConstants.getHdu(
                ccdModule, ccdOutput) });
        }

        CadenceRangeParameters cadenceRangeParameters = new CadenceRangeParameters(
            cadenceRange.left, cadenceRange.right, 0, chunkSize);

        // Set the initial task to an arbitrary valid mod/out. This is
        // acceptable because this task is only used as a template task from
        // which to create other tasks. So, this mod/out is never actually read.
        return new TreeSet<PixelUowTask>(CadenceBinner.subdivide(
            ModOutBinner.subDivide(Arrays.asList(new PixelUowTask(2, 1,
                cadenceRange.left, cadenceRange.right)), modOutLists),
            cadenceRangeParameters.getNumberOfBins(),
            cadenceRangeParameters.getMinimumBinSize()));
    }
}