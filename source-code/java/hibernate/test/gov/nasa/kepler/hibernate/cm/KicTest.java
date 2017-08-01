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

package gov.nasa.kepler.hibernate.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotSame;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the Kic class.
 * 
 * @author Bill Wohler
 */
public class KicTest {

    private Kic kic;

    @Before
    public void buildKic() {
        kic = buildKic(75, 1);
    }

    public static final Kic buildKic(int keplerId, int skyGroupId) {
        return new Kic.Builder(keplerId, 14.5048607, 0.079690).uMag(17.984F)
            .gMag(16.929F)
            .rMag(16.456F)
            .iMag(16.224F)
            .zMag(16.121F)
            .gredMag(17.238F)
            .d51Mag(16.735F)
            .twoMassJMag(15.300F)
            .twoMassHMag(14.775F)
            .twoMassKMag(14.845F)
            .keplerMag(16.436F)
            .twoMassId(1259050706)
            .alternateSource(1000)
            .effectiveTemp(5750)
            .log10SurfaceGravity(4.000F)
            .log10Metallicity(-3.000F)
            .ebMinusVRedding(0.000F)
            .avExtinction(0.000F)
            .radius(0.039F)
            .source("SCP")
            .photometryQuality(11)
            .astrophysicsQuality(6)
            .scpId(2236363)
            .galacticLongitude(348.283350)
            .galacticLatitude(54.008841)
            .grColor(0.473F)
            .jkColor(0.455F)
            .gkColor(2.084F)
            .skyGroupId(skyGroupId)
            .build();
    }

    @Test
    public void testBuilder() {
        assertEquals(kic.getRa(), 14.5048607, 0);
        assertEquals(kic.getDec(), 0.079690, 0);
        assertEquals(kic.getRaProperMotion(), null);
        assertEquals(kic.getDecProperMotion(), null);
        assertEquals(kic.getUMag(), 17.984, .0001);
        assertEquals(kic.getGMag(), 16.929, .0001);
        assertEquals(kic.getRMag(), 16.456, .0001);
        assertEquals(kic.getIMag(), 16.224, .0001);
        assertEquals(kic.getZMag(), 16.121, .0001);
        assertEquals(kic.getGredMag(), 17.238, .0001);
        assertEquals(kic.getD51Mag(), 16.735, .0001);
        assertEquals(kic.getTwoMassJMag(), 15.300, .0001);
        assertEquals(kic.getTwoMassHMag(), 14.775, .0001);
        assertEquals(kic.getTwoMassKMag(), 14.845, .0001);
        assertEquals(kic.getKeplerMag(), 16.436, .0001);
        assertEquals(kic.getKeplerId(), 75);
        assertEquals((int) kic.getTwoMassId(), 1259050706);
        assertEquals(kic.getInternalScpId(), null);
        assertEquals(kic.getAlternateId(), null);
        assertEquals((int) kic.getAlternateSource(), 1000);
        assertEquals(kic.getGalaxyIndicator(), null);
        assertEquals(kic.getBlendIndicator(), null);
        assertEquals(kic.getVariableIndicator(), null);
        assertEquals((int) kic.getEffectiveTemp(), 5750);
        assertEquals(kic.getLog10SurfaceGravity(), 4.000, .0001);
        assertEquals(kic.getLog10Metallicity(), -3.000, .0001);
        assertEquals(kic.getEbMinusVRedding(), 0.000, .0001);
        assertEquals(kic.getAvExtinction(), 0.000, .0001);
        assertEquals(kic.getRadius(), 0.039, .0001);
        assertEquals(kic.getSource(), "SCP");
        assertEquals((int) kic.getPhotometryQuality(), 11);
        assertEquals((int) kic.getAstrophysicsQuality(), 6);
        assertEquals(kic.getCatalogId(), null);
        assertEquals((int) kic.getScpId(), 2236363);
        assertEquals(kic.getParallax(), null);
        assertEquals(kic.getGalacticLongitude(), 348.283350, .00001);
        assertEquals(kic.getGalacticLatitude(), 54.008841, .00001);
        assertEquals(kic.getTotalProperMotion(), null);
        assertEquals(kic.getGrColor(), 0.473, .0001);
        assertEquals(kic.getJkColor(), 0.455, .0001);
        assertEquals(kic.getGkColor(), 2.084, .0001);
        assertEquals(kic.getSkyGroupId(), 1);

        assertEquals(kic, new Kic.Builder(kic).build());

        Kic kic2 = new Kic.Builder(kic, 42.0, 42.1).build();
        assertEquals(kic, kic2);
        assertEquals(kic2.getRa(), 42.0, 0);
        assertEquals(kic2.getDec(), 42.1, 0);
        assertEquals(kic2.getSkyGroupId(), 1);
    }

    @Test
    public void testFormatters() {
    }

    @Test
    public void testEqualsObject() {
        Kic kic1 = new Kic.Builder(1234, 0, 0).source("1234")
            .build();
        Kic kic2 = new Kic.Builder(1234, 0, 0).source("5678")
            .build();
        Kic kic3 = new Kic.Builder(4321, 0, 0).source("5678")
            .build();

        assertEquals(kic1, kic2);
        assertFalse(kic1.equals(kic3));
    }

    @Test
    public void testHashCode() {
        Kic kic1 = new Kic.Builder(1234, 0, 0).source("1234")
            .build();
        Kic kic2 = new Kic.Builder(1234, 0, 0).source("5678")
            .build();
        Kic kic3 = new Kic.Builder(4321, 0, 0).source("5678")
            .build();

        assertEquals(kic1.hashCode(), kic2.hashCode());
        assertNotSame(kic1.hashCode(), kic3.hashCode());
    }

    @Test(expected = NullPointerException.class)
    public void testParseNullKic() throws Exception {
        Kic.valueOf(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseInvalidKic1() throws Exception {
        Kic.valueOf(""); // no fields at all
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseInvalidKic2() throws Exception {
        Kic.valueOf("||||"); // not enough fields
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testParseInvalidKic3() throws Exception {
        // Right number of fields, but missing required fields.
        Kic.valueOf("||||||||||||||||||||||||||||||||||||||||");
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testParseInvalidKic4() throws Exception {
        // Right number of fields, but missing required fields.
        Kic.valueOf("14.5048607||||||||||||||||||||||||||||||||||||||||");
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testParseInvalidKic5() throws Exception {
        // Right number of fields, but missing required fields.
        Kic.valueOf("14.5048607|0.079690|||||||||||||||||||||||||||||||||||||||");
    }

    @Test
    public void testParseKic() throws Exception {
        // Minimum number of fields are filled.
        String s = "14.5048607|0.079690||||||||||||||75|||||||||||||||||||||||||";
        assertEquals(s, Kic.valueOf(s)
            .toString());

        // All fields are filled.
        s = "14.5048607|0.079690|0.1520|-0.0020|17.984|16.929|16.456|16.224|16.121|17.238|16.735|15.300|14.775|14.845|16.436|75|1259050706|274110066|44546322|1000|0|0|0|5750|4.000|-3.000|0.000|0.000|0.039|SCP|11|6|6|2236363||348.283350|54.008841|0.7465|0.473|0.455|2.084";
        assertEquals(s, Kic.valueOf(s)
            .toString());
        assertEquals(0, Kic.valueOf(s)
            .getSkyGroupId());
    }

    @Test
    public void testToStringAndFormatters() {
        assertEquals(
            "14.5048607|0.079690|||17.984|16.929|16.456|16.224|16.121|17.238|16.735|15.300|14.775|14.845|16.436|75|1259050706|||1000||||5750|4.000|-3.000|0.000|0.000|0.039|SCP|11|6||2236363||348.283350|54.008841||0.473|0.455|2.084",
            kic.toString());
    }
}
