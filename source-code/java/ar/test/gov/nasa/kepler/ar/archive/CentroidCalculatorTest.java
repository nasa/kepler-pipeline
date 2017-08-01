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

package gov.nasa.kepler.ar.archive;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.ar.exporter.CentroidCalculator;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.HashSet;
import java.util.Set;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class CentroidCalculatorTest {

    
    @Test
    public void centroidCalculatorTest1() {
        CentroidCalculator centroidCalc = new CentroidCalculator();
        Set<Pixel> pixels = new HashSet<Pixel>();
        pixels.add(new Pixel(15,23));
        Pair<Double,Double> centroid1 = centroidCalc.apertureCentroid(pixels);
        assertEquals(Pair.of(15.0, 23.0), centroid1);
        
    }
    
    /**
     * In this test the reference pixel is not included in the list of offsets.
     */
    @Test
    public void centroidCalculatorTest2() {
        CentroidCalculator centroidCalc = new CentroidCalculator();
        
        Set<Pixel> pixels = new HashSet<Pixel>();
        pixels.add(new Pixel(14,24));
        pixels.add(new Pixel(14,23));
        pixels.add(new Pixel(14,22));
        pixels.add(new Pixel(15,22));
        pixels.add(new Pixel(16,22));
        pixels.add(new Pixel(17,22));
        
        Pair<Double,Double> centroid2 = centroidCalc.apertureCentroid(pixels);
        assertEquals(Pair.of(15.0, 22.5), centroid2);
        
    }
}
