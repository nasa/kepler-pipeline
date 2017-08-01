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

package gov.nasa.kepler.ar.exporter.tpixel;

import java.util.SortedSet;
import java.util.TreeSet;

import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.mc.Pixel;

/**
 * Calculates the dimensions of a target image.
 * 
 * @author Sean McCauliff
 *
 */
public class TargetImageDimensionCalculator {
   

    public TargetImageDimensions imageDimensions(SortedSet<Pixel> pixelsByRowCol) {
        
        if (pixelsByRowCol.size() == 0) {
            throw new IllegalStateException("target does not have any pixels.");
        }
        
        int minRow = pixelsByRowCol.first().getRow();
        int maxRow = pixelsByRowCol.last().getRow();
        int minCol = Integer.MAX_VALUE;
        int maxCol = Integer.MIN_VALUE;
        
        for (Pixel pixel : pixelsByRowCol) {
            minCol = Math.min(minCol, pixel.getColumn());
            maxCol = Math.max(maxCol, pixel.getColumn());
        }
        
        int nRows = maxRow - minRow + 1;
        int nColumns = maxCol - minCol + 1;
        
        SortedSet<Pixel> boundingPixels = new TreeSet<Pixel>(PixelByRowColumn.INSTANCE);
        for (int r=minRow; r<= maxRow; r++) {
            for (int c=minCol; c <=maxCol; c++) {
                Pixel pixel = new Pixel(r,c);
                boundingPixels.add(pixel);
            }
        }
        return new TargetImageDimensions(boundingPixels, minRow, minCol,nRows , nColumns);
    }
    
    
    /**
     * Describes the bounding box for the image and the pixels which reside inside
     * the bounding box.
     * @author Sean McCauliff
     *
     */
    public static final class TargetImageDimensions {
        public final SortedSet<Pixel> boundingPixelsByRowCol;
        public final int referenceRow;
        public final int referenceColumn;
        public final int nRows;
        public final int nColumns;
        public final int sizeInPixels;
        
        
        TargetImageDimensions(SortedSet<Pixel> boundingPixelsByRowCol,
            int referenceRow, int referenceColumn,
            int nRows, int nColumns) {
            this.boundingPixelsByRowCol = boundingPixelsByRowCol;
            this.referenceRow = referenceRow;
            this.referenceColumn = referenceColumn;
            this.nRows = nRows;
            this.nColumns = nColumns;
            this.sizeInPixels = nRows * nColumns;
        }
        
    }
}
