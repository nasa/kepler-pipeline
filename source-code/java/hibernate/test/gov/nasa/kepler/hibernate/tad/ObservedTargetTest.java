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

package gov.nasa.kepler.hibernate.tad;

import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.jmock.JMockTest;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class ObservedTargetTest extends JMockTest {

    @Test
    public void testObservedTargetWithSuppObservedTarget() {
        int origIntValue = 1;
        int suppIntValue = 2;

        int keplerId = 3;

        Aperture origAperture = mock(Aperture.class, "origAperture");
        Aperture suppAperture = mock(Aperture.class, "suppAperture");

        ObservedTarget origObservedTarget = new ObservedTarget(keplerId);
        origObservedTarget.setDistanceFromEdge(origIntValue);
        origObservedTarget.setAperture(origAperture);

        ObservedTarget suppObservedTarget = new ObservedTarget(keplerId);
        suppObservedTarget.setDistanceFromEdge(suppIntValue);
        suppObservedTarget.setAperture(suppAperture);

        origObservedTarget.setSupplementalObservedTarget(suppObservedTarget);

        assertEquals(suppIntValue, origObservedTarget.getDistanceFromEdge());
        assertEquals(suppAperture, origObservedTarget.getAperture());
    }

    @Test
    public void testObservedTargetWithNullSuppObservedTarget() {
        int origIntValue = 1;
        int suppIntValue = 2;

        int keplerId = 3;

        Aperture origAperture = mock(Aperture.class, "origAperture");
        Aperture suppAperture = mock(Aperture.class, "suppAperture");

        ObservedTarget origObservedTarget = new ObservedTarget(keplerId);
        origObservedTarget.setDistanceFromEdge(origIntValue);
        origObservedTarget.setAperture(origAperture);

        ObservedTarget suppObservedTarget = new ObservedTarget(keplerId);
        suppObservedTarget.setDistanceFromEdge(suppIntValue);
        suppObservedTarget.setAperture(suppAperture);

        origObservedTarget.setSupplementalObservedTarget(null);

        assertEquals(origIntValue, origObservedTarget.getDistanceFromEdge());
        assertEquals(origAperture, origObservedTarget.getAperture());
    }

    @Test
    public void testObservedTargetWithRejectedSuppObservedTarget() {
        int origIntValue = 1;
        int suppIntValue = 2;

        int keplerId = 3;

        Aperture origAperture = mock(Aperture.class, "origAperture");
        Aperture suppAperture = mock(Aperture.class, "suppAperture");

        ObservedTarget origObservedTarget = new ObservedTarget(keplerId);
        origObservedTarget.setDistanceFromEdge(origIntValue);
        origObservedTarget.setAperture(origAperture);

        ObservedTarget suppObservedTarget = new ObservedTarget(keplerId);
        suppObservedTarget.setDistanceFromEdge(suppIntValue);
        suppObservedTarget.setAperture(suppAperture);

        suppObservedTarget.setRejected(true);
        origObservedTarget.setSupplementalObservedTarget(suppObservedTarget);

        assertEquals(origIntValue, origObservedTarget.getDistanceFromEdge());
        assertEquals(origAperture, origObservedTarget.getAperture());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testErrorIfDifferingKeplerIds() {
        int origKeplerId = 1;
        int suppKeplerId = 2;

        ObservedTarget origObservedTarget = new ObservedTarget(origKeplerId);
        ObservedTarget suppObservedTarget = new ObservedTarget(suppKeplerId);

        origObservedTarget.setSupplementalObservedTarget(suppObservedTarget);

        origObservedTarget.getKeplerId();
    }

    @Test
    public void testObservedTargetWithSuppObservedTargetWithClippedPixels() {
        int keplerId = 3;
        int origRow = 4;
        int origColumn = 5;
        int suppRow = 6;
        int suppColumn = 7;

        Offset offset = new Offset(0, 0);
        Aperture suppAperture = mock(Aperture.class);
        TargetDefinition origTargetDefinition = mock(TargetDefinition.class);
        Mask mask = mock(Mask.class);

        ObservedTarget suppObservedTarget = new ObservedTarget(keplerId);
        suppObservedTarget.setAperture(suppAperture);

        ObservedTarget origObservedTarget = new ObservedTarget(keplerId);
        origObservedTarget.setSupplementalObservedTarget(suppObservedTarget);
        origObservedTarget.setTargetDefinitions(ImmutableList.of(origTargetDefinition));

        allowing(suppAperture).getOffsets();
        will(returnValue(ImmutableList.of(offset)));

        allowing(suppAperture).getReferenceRow();
        will(returnValue(suppRow));

        allowing(suppAperture).getReferenceColumn();
        will(returnValue(suppColumn));

        allowing(origTargetDefinition).getMask();
        will(returnValue(mask));

        allowing(mask).getOffsets();
        will(returnValue(ImmutableList.of(offset)));

        allowing(origTargetDefinition).getReferenceRow();
        will(returnValue(origRow));

        allowing(origTargetDefinition).getReferenceColumn();
        will(returnValue(origColumn));

        int clippedPixelCount = origObservedTarget.getClippedPixelCount();

        assertEquals(1, clippedPixelCount);
    }

}
