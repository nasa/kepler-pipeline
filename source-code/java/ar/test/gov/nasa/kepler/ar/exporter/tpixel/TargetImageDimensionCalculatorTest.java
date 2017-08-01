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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.ar.exporter.tpixel.TargetImageDimensionCalculator.TargetImageDimensions;
import gov.nasa.kepler.mc.Pixel;

import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;

import org.junit.Test;

public class TargetImageDimensionCalculatorTest {
    
    @Test
    public void testTargetImageDimensions() {
        final SortedSet<Pixel> pixels = 
            new TreeSet<Pixel>(PixelByRowColumn.INSTANCE);

        final int nRows = 10;
        final int nColumns = 22;
        for (int i=0; i < nRows; i++) {
            for (int j = i; j < nColumns; j++) {
                pixels.add(new Pixel(i,j));
            }
        }
        
        TargetImageDimensionCalculator imageDimensionCalculator = 
            new TargetImageDimensionCalculator();
        
        TargetImageDimensions imageDimensions = 
            imageDimensionCalculator.imageDimensions(pixels);
        assertEquals(0, imageDimensions.referenceColumn);
        assertEquals(0, imageDimensions.referenceRow);
        assertEquals(nColumns, imageDimensions.nColumns);
        assertEquals(nRows, imageDimensions.nRows);
        
        Iterator<Pixel> boundingPixelIt = imageDimensions.boundingPixelsByRowCol.iterator();
        for (int i=0; i < nRows; i++) {
            for (int j=0; j < nColumns; j++) {
                assertEquals(new Pixel(i,j), boundingPixelIt.next());
            }
        }
    }
}
