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

package gov.nasa.kepler.tad.peer.coa;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.mc.tad.DistanceFromEdgeCalculator;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class DistanceFromEdgeCalculatorTest {

    @Test
    public void testOnePixelNearTopEdge() {
        List<Offset> offsets = ImmutableList.of(new Offset(1042, 500));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(1, distanceFromEdge);
    }

    @Test
    public void testOnePixelNearBottomEdge() {
        List<Offset> offsets = ImmutableList.of(new Offset(21, 500));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(1, distanceFromEdge);
    }

    @Test
    public void testOnePixelNearLeftEdge() {
        List<Offset> offsets = ImmutableList.of(new Offset(500, 13));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(1, distanceFromEdge);
    }

    @Test
    public void testOnePixelNearRightEdge() {
        List<Offset> offsets = ImmutableList.of(new Offset(500, 1110));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(1, distanceFromEdge);
    }

    @Test
    public void testOnePixelTwoFromBottomEdgeOneFromLeftEdge() {
        List<Offset> offsets = ImmutableList.of(new Offset(22, 13));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(1, distanceFromEdge);
    }

    @Test
    public void testOnePixelOnTheEdge() {
        List<Offset> offsets = ImmutableList.of(new Offset(1043, 1111));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(0, distanceFromEdge);
    }

    @Test
    public void testOnePixelThatIsOnePixelOffOfVisible() {
        List<Offset> offsets = ImmutableList.of(new Offset(1043, 11));
        Aperture aperture = new Aperture(false, 0, 0, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(-1, distanceFromEdge);
    }

    @Test
    public void testRealisticAperture() {
        List<Offset> offsets = ImmutableList.of(new Offset(0, -1), new Offset(
            0, 0), new Offset(0, 1), new Offset(0, 2), new Offset(1, -2),
            new Offset(1, -1), new Offset(1, 0), new Offset(1, 1), new Offset(
                1, 2), new Offset(2, -2), new Offset(2, -1), new Offset(2, 0));

        Aperture aperture = new Aperture(false, 445, 1108, offsets);

        DistanceFromEdgeCalculator calculator = new DistanceFromEdgeCalculator();
        int distanceFromEdge = calculator.getDistanceFromEdge(aperture);

        assertEquals(1, distanceFromEdge);
    }

}
