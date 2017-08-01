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

import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.mc.tad.CoaObservedTargetRejecter;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class CoaObservedTargetRejecterTest extends JMockTest {

    private static final int KEPLER_ID = 1;

    @SuppressWarnings("unchecked")
    private List<Offset> offsetsEmpty = mock(List.class, "offsetsEmpty");
    @SuppressWarnings("unchecked")
    private List<Offset> offsetsNonEmpty = mock(List.class, "offsetsNonEmpty");

    private Aperture apertureEmpty = mock(Aperture.class, "apertureEmpty");
    private Aperture apertureNonEmpty = mock(Aperture.class, "apertureNonEmpty");

    private ObservedTarget origObservedTarget = mock(ObservedTarget.class,
        "origObservedTarget");
    private List<ObservedTarget> origObservedTargets = ImmutableList.of(origObservedTarget);

    private ObservedTarget suppObservedTarget = mock(ObservedTarget.class,
        "suppObservedTarget");
    private List<ObservedTarget> suppObservedTargets = ImmutableList.of(suppObservedTarget);

    private List<ObservedTarget> emptyObservedTargets = ImmutableList.of();

    @Before
    public void setUp() {
        allowing(offsetsEmpty).isEmpty();
        will(returnValue(true));

        allowing(offsetsNonEmpty).isEmpty();
        will(returnValue(false));

        allowing(apertureEmpty).getOffsets();
        will(returnValue(offsetsEmpty));

        allowing(apertureNonEmpty).getOffsets();
        will(returnValue(offsetsNonEmpty));

        allowing(origObservedTarget).getKeplerId();
        will(returnValue(KEPLER_ID));

        allowing(suppObservedTarget).getKeplerId();
        will(returnValue(KEPLER_ID));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testOrigWithNullOrigTargets() {
        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(null, null);
    }

    @Test
    public void testOrigWithNullApertureInOrig() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(null));

        oneOf(origObservedTarget).setRejected(true);

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets, null);
    }

    @Test
    public void testOrigWithEmptyApertureInOrig() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        oneOf(origObservedTarget).setRejected(true);

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets, null);
    }

    @Test
    public void testOrigWithNonEmptyApertureInOrig() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets, null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSuppWithTargetOnOrigListOnly() {
        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            emptyObservedTargets);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSuppWithTargetOnSuppListOnly() {
        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(emptyObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithNullApertureInOrigAndNullApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(null));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(null));

        oneOf(suppObservedTarget).setRejected(true);

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithNullApertureInOrigAndEmptyApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(null));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithNullApertureInOrigAndNonEmptyApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(null));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithEmptyApertureInOrigAndNullApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(null));

        oneOf(suppObservedTarget).setRejected(true);

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithEmptyApertureInOrigAndEmptyApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        oneOf(suppObservedTarget).setRejected(true);

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSuppWithEmptyApertureInOrigAndNonEmptyApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithNonEmptyApertureInOrigAndNullApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(null));

        oneOf(suppObservedTarget).setRejected(true);

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithNonEmptyApertureInOrigAndEmptyApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(apertureEmpty));

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

    @Test
    public void testSuppWithNonEmptyApertureInOrigAndNonEmptyApertureInSupp() {
        allowing(origObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        allowing(suppObservedTarget).getAperture();
        will(returnValue(apertureNonEmpty));

        CoaObservedTargetRejecter coaObservedTargetRejecter = new CoaObservedTargetRejecter();
        coaObservedTargetRejecter.reject(origObservedTargets,
            suppObservedTargets);
    }

}
