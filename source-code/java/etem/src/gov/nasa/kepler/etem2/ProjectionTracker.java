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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;

import java.util.ArrayList;
import java.util.List;

public class ProjectionTracker {
    
    private static final int BLACK_VIRTUAL_PIXEL_OFFSET = 0;
    private static final int BLACK_MASKED_PIXEL_OFFSET = 0;

    public List<SccPmrfFitsRow> getSccPmrfFitsRows(
        List<TargetDefinition> targetDefs) {
        
        List<Integer> rowsForCollateral = new ArrayList<Integer>();
        List<Integer> colsForCollateral = new ArrayList<Integer>();
        List<Integer> targetIdsForCollateral = new ArrayList<Integer>();
        
        for (TargetDefinition targetDef : targetDefs) {
            Mask mask = targetDef.getMask();
            for (Offset offset : mask.getOffsets()) {
                short absRow = (short) (targetDef.getReferenceRow() + offset.getRow());
                short absCol = (short) (targetDef.getReferenceColumn() + offset.getColumn());

                rowsForCollateral.add(new Integer(absRow));
                colsForCollateral.add(new Integer(absCol));
                targetIdsForCollateral.add(new Integer(
                    targetDef.getIndexInModuleOutput()));
            }
        }
        
        List<SccPmrfFitsRow> sccPmrfFitsRows = new ArrayList<SccPmrfFitsRow>();

        // Add the black-level pixels.
        for (int i = 0; i < targetIdsForCollateral.size(); i++) {
            SccPmrfFitsRow row = new SccPmrfFitsRow(
                CollateralType.BLACK_LEVEL.byteValue(),
                rowsForCollateral.get(i).shortValue(),
                targetIdsForCollateral.get(i));
            
            if (!sccPmrfFitsRows.contains(row)) {
                sccPmrfFitsRows.add(row);
            }
        }

        // Add the masked-smear pixels.
        for (int i = 0; i < targetIdsForCollateral.size(); i++) {
            SccPmrfFitsRow row = new SccPmrfFitsRow(
                CollateralType.MASKED_SMEAR.byteValue(),
                colsForCollateral.get(i).shortValue(),
                targetIdsForCollateral.get(i));
            
            if (!sccPmrfFitsRows.contains(row)) {
                sccPmrfFitsRows.add(row);
            }
        }

        // Add the virtual smeal pixels.
        for (int i = 0; i < targetIdsForCollateral.size(); i++) {
            SccPmrfFitsRow row = new SccPmrfFitsRow(
                CollateralType.VIRTUAL_SMEAR.byteValue(),
                colsForCollateral.get(i).shortValue(),
                targetIdsForCollateral.get(i));
            
            if (!sccPmrfFitsRows.contains(row)) {
                sccPmrfFitsRows.add(row);
            }
        }

        // Add the special black-masked pixels.
        for (int i = 0; i < targetIdsForCollateral.size(); i++) {
            SccPmrfFitsRow row = new SccPmrfFitsRow(
                CollateralType.BLACK_MASKED.byteValue(),
                (short) BLACK_MASKED_PIXEL_OFFSET,
                targetIdsForCollateral.get(i));
            
            if (!sccPmrfFitsRows.contains(row)) {
                sccPmrfFitsRows.add(row);
            }
        }

        // Add the special black-virtual pixels.
        for (int i = 0; i < targetIdsForCollateral.size(); i++) {
            SccPmrfFitsRow row = new SccPmrfFitsRow(
                CollateralType.BLACK_VIRTUAL.byteValue(),
                (short) BLACK_VIRTUAL_PIXEL_OFFSET,
                targetIdsForCollateral.get(i));
            
            if (!sccPmrfFitsRows.contains(row)) {
                sccPmrfFitsRows.add(row);
            }
        }
        
        return sccPmrfFitsRows;
    }

    public int getScCollateralPixelCount(TargetDefinition targetDefinition) {
        List<TargetDefinition> targetDefs = new ArrayList<TargetDefinition>();
        targetDefs.add(targetDefinition);

        return getSccPmrfFitsRows(targetDefs).size();
    }

    public int getScTargetPixelCount(TargetDefinition targetDefinition) {
        return targetDefinition.getMask()
            .getOffsets()
            .size();
    }

}
