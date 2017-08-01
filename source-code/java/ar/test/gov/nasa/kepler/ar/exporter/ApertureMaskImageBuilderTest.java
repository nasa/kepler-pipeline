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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.hibernate.pa.CentroidPixel;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.mc.Pixel;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.Assert;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class ApertureMaskImageBuilderTest {

    /**
     * <pre>
     *   00100
     *   01310
     *   13331
     *   01310
     *   00300
     *   00100
     * </pre>
     */
    @Test
    public void apertureMaskImageBuilderTest() {
        ApertureMaskImageBuilder builder = new ApertureMaskImageBuilder();
        
        int referenceRow = 102;
        int referenceCol = 556;
        
        List<CentroidPixel> centroidPixels = 
            ImmutableList.of(new CentroidPixel(referenceRow, referenceCol, true, false),
                             new CentroidPixel(referenceRow+1, referenceCol, false, true));
            
        TargetAperture targetAperture = new TargetAperture.Builder(null, null, 1)
        .ccdModule(2).ccdOutput(1)
        .pixels(centroidPixels)
        .build();
        
        Set<Pixel> pixels = new HashSet<Pixel>();
        pixels.add(new Pixel(referenceRow, referenceCol +2, null, false));
        pixels.add(new Pixel(referenceRow + 1, referenceCol + 1, null, false));
        pixels.add(new Pixel(referenceRow + 1, referenceCol + 2, null, true));
        pixels.add(new Pixel(referenceRow + 1, referenceCol + 3, null, false));
        pixels.add(new Pixel(referenceRow + 2, referenceCol, null, false));
        pixels.add(new Pixel(referenceRow + 2, referenceCol + 1, null, true));
        pixels.add(new Pixel(referenceRow + 2, referenceCol + 2, null, true));
        pixels.add(new Pixel(referenceRow + 2, referenceCol + 3, null, true));
        pixels.add(new Pixel(referenceRow + 2, referenceCol + 4, null, false));
        pixels.add(new Pixel(referenceRow + 3, referenceCol + 1, null, false));
        pixels.add(new Pixel(referenceRow + 3, referenceCol + 2, null, true));
        pixels.add(new Pixel(referenceRow + 3, referenceCol + 3, null, false));
        pixels.add(new Pixel(referenceRow + 4, referenceCol + 2, null, true));
        pixels.add(new Pixel(referenceRow + 5, referenceCol + 2, null, false));
        int nColumns = 5;
        int nRows = 6;
        int[][] apertureMaskImage = 
            builder.buildImage(pixels, referenceRow, referenceCol, nColumns, nRows, targetAperture);
        int[][] expectedImage = {{4, 0, 1, 0, 0},
                                 {8, 1, 3, 1, 0},
                                 {1, 3, 3, 3, 1},
                                 {0, 1, 3, 1, 0},
                                 {0, 0, 3, 0, 0},
                                 {0, 0, 1, 0, 0} };
        Assert.assertArrayEquals(expectedImage, apertureMaskImage);
        
    }
}
