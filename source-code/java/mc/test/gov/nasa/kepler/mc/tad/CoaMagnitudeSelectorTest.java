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

package gov.nasa.kepler.mc.tad;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.tad.CoaMagnitudeSelector;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class CoaMagnitudeSelectorTest {

    private static final float KEPMAG = 1.1F;
    private static final float SOC_MAG = 2.2F;

    private Kic kic;
    private Characteristic characteristic;

    private void setUp() {
        kic = new Kic.Builder(-1, -1, -1).keplerMag(KEPMAG)
            .build();

        characteristic = new Characteristic(-1, null, SOC_MAG);
    }

    @Test
    public void testBothMagsExist() {
        setUp();

        CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
            kic).build();

        CoaMagnitudeSelector selector = new CoaMagnitudeSelector();
        Float mag = selector.select(celestialObjectParameters, characteristic);

        assertEquals(SOC_MAG, mag, 0);
    }

    @Test
    public void testOnlyKepmagExists() {
        setUp();

        characteristic = null;

        CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
            kic).build();

        CoaMagnitudeSelector selector = new CoaMagnitudeSelector();
        Float mag = selector.select(celestialObjectParameters, characteristic);

        assertEquals(KEPMAG, mag, 0);
    }

    @Test
    public void testOnlySocmagExists() {
        setUp();

        kic = new Kic.Builder(-1, -1, -1).keplerMag(null)
            .build();

        CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
            kic).build();

        CoaMagnitudeSelector selector = new CoaMagnitudeSelector();
        Float mag = selector.select(celestialObjectParameters, characteristic);

        assertEquals(SOC_MAG, mag, 0);
    }

    @Test
    public void testNeitherMagExists() {
        setUp();

        kic = new Kic.Builder(-1, -1, -1).keplerMag(null)
            .build();

        characteristic = null;

        CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
            kic).build();

        CoaMagnitudeSelector selector = new CoaMagnitudeSelector();
        Float mag = selector.select(celestialObjectParameters, characteristic);

        assertTrue(Float.isNaN(mag));
    }

}
