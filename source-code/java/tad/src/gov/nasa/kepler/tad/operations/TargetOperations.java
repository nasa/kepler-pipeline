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

package gov.nasa.kepler.tad.operations;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.Pixel;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Contains operations related to {@link ObservedTarget}s.
 * 
 * @author jbrittain
 * @author Miles Cote
 * 
 */
public class TargetOperations {

    /**
     * @return keplerId -> pixel list (where each pixel is in the absolute ccd
     * coordinates). Additionally these pixels will only be the pixels in the
     * original aperture not the optimal aperture.
     */
    public Map<Integer, List<Pixel>> getAperturePixelsForLabeledTargets(
        TargetCrud targetCrud, TargetTable targetTable, int ccdModule,
        int ccdOutput, Set<String> labels) {

        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, ccdModule, ccdOutput);

        Map<Integer, List<Pixel>> rv = newHashMap();

        for (ObservedTarget observedTarget : observedTargets) {
            Set<String> otLabels = observedTarget.getLabels();
            if (Collections.disjoint(otLabels, labels)) {
                continue;
            }

            List<Pixel> pixels = newArrayList();
            Aperture aperture = observedTarget.getAperture();
            for (Offset offset : aperture.getOffsets()) {
                int absRow = aperture.getReferenceRow() + offset.getRow();
                int absCol = aperture.getReferenceColumn() + offset.getColumn();
                Pixel pixel = new Pixel(absRow, absCol);

                pixels.add(pixel);
            }

            rv.put(observedTarget.getKeplerId(), pixels);

            observedTarget.getKeplerId();
        }

        return rv;

    }

    public static String getUplinkedMaskTableErrorText(MaskTable maskTable) {
        return "Mask table must be in a state other than UPLINKED.\n  state: "
            + maskTable.getState();
    }

    /**
     * Copies a {@link MaskTable} and its {@link Mask}s and stores them in the
     * database. This method will not copy supermasks.
     * 
     * @param maskTable The {@link MaskTable} to copy.
     * @return The new {@link MaskTable} that was stored in the database.
     */
    public MaskTable copy(MaskTable maskTable, PipelineTask pipelineTask) {
        TargetCrud targetCrud = new TargetCrud();
        List<Mask> masks = targetCrud.retrieveMasks(maskTable);

        MaskTable newMaskTable = new MaskTable(maskTable);

        int count = 0;
        List<Mask> newMasks = newArrayList();
        for (Mask mask : masks) {
            // Don't copy supermasks.
            if (!mask.isSupermask()) {
                Mask newMask = new Mask(mask);
                newMask.setMaskTable(newMaskTable);
                newMask.setIndexInTable(count);
                newMask.setPipelineTask(pipelineTask);
                newMasks.add(newMask);

                count++;
            }
        }

        targetCrud.createMaskTable(newMaskTable);
        targetCrud.createMasks(newMasks);

        return newMaskTable;
    }

}
