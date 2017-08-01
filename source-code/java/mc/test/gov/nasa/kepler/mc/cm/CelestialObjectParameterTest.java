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

package gov.nasa.kepler.mc.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link CelestialObjectParameter} class.
 * 
 * @author Bill Wohler
 */
public class CelestialObjectParameterTest {

    private static final Log log = LogFactory.getLog(CelestialObjectParameterTest.class);

    private static final double VALUE = 42.0;
    private static final double UNCERTAINTY = 42.1;

    private static final String PROVENANCE = "Test";

    private CelestialObjectParameter celestialObjectParameter;

    @Before
    public void createCelestialObjectParameter() {
        celestialObjectParameter = createCelestialObjectParameter(VALUE,
            UNCERTAINTY);
    }

    private CelestialObjectParameter createCelestialObjectParameter(
        Double value, Double uncertainty) {
        return new CelestialObjectParameter(PROVENANCE, value, uncertainty);
    }

    @Test
    public void testConstructor() {
        assertEquals(VALUE, celestialObjectParameter.getValue(), 0);
        assertEquals(UNCERTAINTY, celestialObjectParameter.getUncertainty(), 0);
    }

    @Test
    public void testEquals() {
        // Include all don't-care fields here.
        CelestialObjectParameter p = createCelestialObjectParameter(VALUE,
            UNCERTAINTY);
        assertEquals(celestialObjectParameter, p);

        p = createCelestialObjectParameter(VALUE + 1, UNCERTAINTY);
        assertFalse(celestialObjectParameter.equals(p));

        p = createCelestialObjectParameter(VALUE, UNCERTAINTY + 1);
        assertFalse(celestialObjectParameter.equals(p));
    }

    @Test
    public void testHashCode() {
        // Include all don't-care fields here.
        CelestialObjectParameter p = createCelestialObjectParameter(VALUE,
            UNCERTAINTY);
        assertEquals(celestialObjectParameter.hashCode(), p.hashCode());

        p = createCelestialObjectParameter(VALUE + 1, UNCERTAINTY);
        assertFalse("hashCode",
            celestialObjectParameter.hashCode() == p.hashCode());

        p = createCelestialObjectParameter(VALUE, UNCERTAINTY + 1);
        assertFalse("hashCode",
            celestialObjectParameter.hashCode() == p.hashCode());
    }

    @Test
    public void testToString() {
        // Check log and ensure that output isn't brutally long.
        log.info(celestialObjectParameter.toString());
    }

    @Test
    public void testCreateForValueWithValueNull() {
        CelestialObjectParameter celestialObjectParameter = new CelestialObjectParameter(
            PROVENANCE, (Double) null);

        assertEquals(new CelestialObjectParameter().getValue(),
            celestialObjectParameter.getValue(), 0);
        assertEquals(new CelestialObjectParameter().getUncertainty(),
            celestialObjectParameter.getUncertainty(), 0);
    }

    @Test
    public void testCreateForValueWithValueNotNull() {
        CelestialObjectParameter celestialObjectParameter = new CelestialObjectParameter(
            PROVENANCE, VALUE);

        assertEquals(VALUE, celestialObjectParameter.getValue(), 0);
        assertEquals(new CelestialObjectParameter().getUncertainty(),
            celestialObjectParameter.getUncertainty(), 0);
    }

    @Test
    public void testCreateForValueUncertaintyWithUncertaintyNull() {
        CelestialObjectParameter celestialObjectParameter = new CelestialObjectParameter(
            PROVENANCE, VALUE, (Number) null);

        assertEquals(VALUE, celestialObjectParameter.getValue(), 0);
        assertEquals(new CelestialObjectParameter().getUncertainty(),
            celestialObjectParameter.getUncertainty(), 0);
    }

    @Test
    public void testCreateForValueUncertaintyWithUncertaintyNotNull() {
        CelestialObjectParameter celestialObjectParameter = new CelestialObjectParameter(
            PROVENANCE, VALUE, UNCERTAINTY);

        assertEquals(VALUE, celestialObjectParameter.getValue(), 0);
        assertEquals(UNCERTAINTY, celestialObjectParameter.getUncertainty(), 0);
    }

}
