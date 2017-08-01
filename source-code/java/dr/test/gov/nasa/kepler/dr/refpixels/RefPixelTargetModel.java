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

package gov.nasa.kepler.dr.refpixels;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

/**
 * This class models a reference pixel target table (target definitions and
 * aperture masks).
 * 
 * Target definitions are layed out on a grid that includes points spread evenly
 * across the imaging pixels. The grid is computed as follows. - Initialize the
 * grid locations. These are the locations where visible targets will be
 * created. - Divide the imaging ccd pixel space into N x N bins, where N =
 * TARGET_GRID_SIZE + 2. We only need TARGET_GRID_SIZE x TARGET_GRID_SIZE
 * locations, but we add 2 so that we can ignore the ones along the edges. -
 * Compute the row/col coordinates of all of the non-edge (inner) bins. This
 * gives us TARGET_GRID_SIZE x TARGET_GRID_SIZE coordinates where we can put
 * visible target definitionss. These coordinates are also used to determine
 * where to put the collateral target definitions.
 * 
 * Also generated are collateral targets definitions that exactly shadow all of
 * the visible target definitions. The number of collateral target definitions
 * is TARGET_GRID_SIZE * 4, one for each collateral type.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class RefPixelTargetModel {

    private static final int TARGET_GRID_SIZE = 3; // TARGET_GRID_SIZE x
    // TARGET_GRID_SIZE targets
    // will be created
    private static final int ROWS_PER_TARGET = 5;
    private static final int COLS_PER_TARGET = 5;

    /**
     * The above settings produce the following reference pixels (calculated
     * using pixelCount.m)
     * 
     * The total pixel count must match the contents of the test reference pixel
     * binary files! >> pixelCount(5,5)
     * 
     * numTargets: 9 numCollateralTargets: 12 numLBPixels: 180 numTBPixels: 300
     * numVSPixels: 390 numMSPixels: 300 numTargetPixels: 225
     * numCollateralPixels: 1170 pixelsPerModOut: 1395 targetsPerModOut: 21
     * totalPixels: 117180 totalTargets: 1764
     */

    private int[] gridRowLocations;
    private int[] gridColumnLocations;
    private int returnedPixelCount;

    public RefPixelTargetModel() {
        initializeModel();
    }

    /**
     * Initialize the grid locations. These are the locations where visible
     * targets will be created.
     */
    public void initializeModel() {

        gridRowLocations = new int[TARGET_GRID_SIZE];
        gridColumnLocations = new int[TARGET_GRID_SIZE];

        int rowBinSize = FcConstants.nRowsImaging / (TARGET_GRID_SIZE + 2);
        int columnBinSize = FcConstants.nColsImaging / (TARGET_GRID_SIZE + 2);

        for (int i = 0; i < TARGET_GRID_SIZE; i++) {
            gridRowLocations[i] = (i + 1) * rowBinSize;
            gridColumnLocations[i] = (i + 1) * columnBinSize;
        }
    }

    public List<TargetDefinition> generateTargetDefsForRefPixelTest() {
        return generateTargetDefs(false);
    }

    public List<TargetDefinition> generateTargetDefsForTadExport() {
        return generateTargetDefs(true);
    }

    /**
     * Generate a set of target definitions for a single CCD module/output.
     * 
     * @return
     */
    private List<TargetDefinition> generateTargetDefs(boolean isForTadExport) {
        List<TargetDefinition> targetDefs = new LinkedList<TargetDefinition>();
        Pair<TargetDefinition, Integer> targetDef; // recycled return class
        // from createTargetDef
        returnedPixelCount = 0;

        // Targets on visible pixels

        for (int gridRowIndex = 0; gridRowIndex < TARGET_GRID_SIZE; gridRowIndex++) {
            for (int gridColIndex = 0; gridColIndex < TARGET_GRID_SIZE; gridColIndex++) {
                // lower-left corner set at grid location
                targetDef = createTargetDef(gridRowLocations[gridRowIndex],
                    gridColumnLocations[gridColIndex], COLS_PER_TARGET,
                    ROWS_PER_TARGET);
                returnedPixelCount += targetDef.right;
                targetDefs.add(targetDef.left);
            }
        }

        // Collateral Targets
        int virtualSmearStartRow = FcConstants.nMaskedSmear
            + FcConstants.nRowsImaging + 1;
        int maskedSmearStartRow = 0;
        int leadingBlackStartCol = 0;
        int trailingBlackStartCol = FcConstants.nLeadingBlack
            + FcConstants.nColsImaging + 1;

        // Smear
        for (int gridColIndex = 0; gridColIndex < TARGET_GRID_SIZE; gridColIndex++) {

            // virtual: height = all virtual smear rows
            // starts on a grid column
            if (isForTadExport) {
                targetDef = createTargetDef(virtualSmearStartRow,
                    gridColumnLocations[gridColIndex], COLS_PER_TARGET,
                    ROWS_PER_TARGET);
            } else {
                targetDef = createTargetDef(virtualSmearStartRow,
                    gridColumnLocations[gridColIndex], COLS_PER_TARGET,
                    FcConstants.nVirtualSmear);
            }
            returnedPixelCount += targetDef.right;
            targetDefs.add(targetDef.left);

            // masked: height = all masked smear rows
            // starts on a grid column
            if (isForTadExport) {
                targetDef = createTargetDef(maskedSmearStartRow,
                    gridColumnLocations[gridColIndex], COLS_PER_TARGET,
                    ROWS_PER_TARGET);
            } else {
                targetDef = createTargetDef(maskedSmearStartRow,
                    gridColumnLocations[gridColIndex], COLS_PER_TARGET,
                    FcConstants.nMaskedSmear);
            }
            returnedPixelCount += targetDef.right;
            targetDefs.add(targetDef.left);
        }

        // Black
        for (int gridRowIndex = 0; gridRowIndex < TARGET_GRID_SIZE; gridRowIndex++) {

            // leading black: width = all leading black columns
            // starts on a grid row
            if (isForTadExport) {
                targetDef = createTargetDef(gridRowLocations[gridRowIndex],
                    leadingBlackStartCol, ROWS_PER_TARGET, COLS_PER_TARGET);
            } else {
                targetDef = createTargetDef(gridRowLocations[gridRowIndex],
                    leadingBlackStartCol, ROWS_PER_TARGET,
                    FcConstants.nLeadingBlack);
            }
            returnedPixelCount += targetDef.right;
            targetDefs.add(targetDef.left);

            // trailing black: width = all trailing black columns
            // starts on a grid row
            if (isForTadExport) {
                targetDef = createTargetDef(gridRowLocations[gridRowIndex],
                    trailingBlackStartCol, ROWS_PER_TARGET, COLS_PER_TARGET);
            } else {
                targetDef = createTargetDef(gridRowLocations[gridRowIndex],
                    trailingBlackStartCol, ROWS_PER_TARGET,
                    FcConstants.nTrailingBlack);
            }
            returnedPixelCount += targetDef.right;
            targetDefs.add(targetDef.left);
        }

        return targetDefs;
    }

    /**
     * Create a single target definition of the specified size at the specified
     * location.
     * 
     * @param startRow
     * @param startCol
     * @param width
     * @param height
     * @return
     */
    private Pair<TargetDefinition, Integer> createTargetDef(int startRow,
        int startCol, int width, int height) {
        int endRow = startRow + height - 1;
        int endCol = startCol + width - 1;

        int returnedPixelCount = 0;

        List<Offset> pixels = new ArrayList<Offset>();
        for (int row = startRow; row <= endRow; row++) {
            for (int col = startCol; col <= endCol; col++) {
                Offset pixel = new Offset(row - startRow, col - startCol);

                pixels.add(pixel);

                returnedPixelCount++;
            }
        }

        Mask mask = new Mask(null, pixels);
        TargetDefinition targetDef = new TargetDefinition(startRow, startCol,
            0, mask);

        return Pair.of(targetDef, returnedPixelCount);
    }

    public int getReturnedPixelCount() {
        return returnedPixelCount;
    }
}
