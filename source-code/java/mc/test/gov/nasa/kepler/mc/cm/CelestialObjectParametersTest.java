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
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CelestialObjectUtils;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link CelestialObjectParameters} class.
 * 
 * @author Bill Wohler
 */
public class CelestialObjectParametersTest {

    private static final int SEED = 0;
    static final double UNCERTAINTY_SEED_DIVISOR = 1000.0;
    private static final String PROVENANCE = "TEST";
    private static int SKY_GROUP_ID = 42;

    private CelestialObject celestialObject;
    private CelestialObjectParameters celestialObjectParameters;

    @Before
    public void buildCelestialObjectParameters() {
        celestialObject = createCelestialObject(SEED);
        celestialObjectParameters = createCelestialObjectParameters(celestialObject);
    }

    @Test
    public void testBuilder() {
        testCelestialObjectParameters(celestialObject,
            celestialObjectParameters, true, true);
    }

    @Test
    public void testEquals() {
        CelestialObject celestialObject1 = createCelestialObject(1234);
        CelestialObjectParameters celestialObjectParameters1 = new CelestialObjectParameters.Builder(
            celestialObject1).alternateId(
            new CelestialObjectParameter(PROVENANCE, 1234))
            .build();

        CelestialObject celestialObject2 = createCelestialObject(1234);
        CelestialObjectParameters celestialObjectParameters2 = new CelestialObjectParameters.Builder(
            celestialObject2).alternateId(
            new CelestialObjectParameter(PROVENANCE, 5678))
            .build();

        CelestialObject celestialObject3 = createCelestialObject(4321);
        CelestialObjectParameters celestialObjectParameters3 = new CelestialObjectParameters.Builder(
            celestialObject3).alternateId(
            new CelestialObjectParameter(PROVENANCE, 5678))
            .build();

        assertEquals(celestialObjectParameters1, celestialObjectParameters2);
        assertNotSame(celestialObjectParameters1, celestialObjectParameters3);
    }

    @Test
    public void testHashCode() {
        CelestialObject celestialObject1 = createCelestialObject(1234);
        CelestialObjectParameters celestialObjectParameters1 = new CelestialObjectParameters.Builder(
            celestialObject1).alternateId(
            new CelestialObjectParameter(PROVENANCE, 1234))
            .build();

        CelestialObject celestialObject2 = createCelestialObject(1234);
        CelestialObjectParameters celestialObjectParameters2 = new CelestialObjectParameters.Builder(
            celestialObject2).alternateId(
            new CelestialObjectParameter(PROVENANCE, 5678))
            .build();

        CelestialObject celestialObject3 = createCelestialObject(4321);
        CelestialObjectParameters celestialObjectParameters3 = new CelestialObjectParameters.Builder(
            celestialObject3).alternateId(
            new CelestialObjectParameter(PROVENANCE, 5678))
            .build();

        assertEquals(celestialObjectParameters1.hashCode(),
            celestialObjectParameters2.hashCode());
        assertNotSame(celestialObjectParameters1.hashCode(),
            celestialObjectParameters3.hashCode());
    }

    private CelestialObjectParameters createCelestialObjectParameters(
        CelestialObject celestialObject) {
        // Order of builder methods defined by CelestialObject.Field.
        return new CelestialObjectParameters.Builder(celestialObject)
        // .skyGroupId(seed + 0)
        .ra(new CelestialObjectParameter(PROVENANCE, SEED + 1, (SEED + 1)
            / UNCERTAINTY_SEED_DIVISOR))
            .dec(
                new CelestialObjectParameter(PROVENANCE, SEED + 2, (SEED + 2)
                    / UNCERTAINTY_SEED_DIVISOR))
            .raProperMotion(
                new CelestialObjectParameter(PROVENANCE, SEED + 3F, (SEED + 3)
                    / UNCERTAINTY_SEED_DIVISOR))
            .decProperMotion(
                new CelestialObjectParameter(PROVENANCE, SEED + 4F, (SEED + 4)
                    / UNCERTAINTY_SEED_DIVISOR))
            .uMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 5F, (SEED + 5)
                    / UNCERTAINTY_SEED_DIVISOR))
            .gMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 6F, (SEED + 6)
                    / UNCERTAINTY_SEED_DIVISOR))
            .rMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 7F, (SEED + 7)
                    / UNCERTAINTY_SEED_DIVISOR))
            .iMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 8F, (SEED + 8)
                    / UNCERTAINTY_SEED_DIVISOR))
            .zMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 9F, (SEED + 9)
                    / UNCERTAINTY_SEED_DIVISOR))
            .gredMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 10F,
                    (SEED + 10) / UNCERTAINTY_SEED_DIVISOR))
            .d51Mag(
                new CelestialObjectParameter(PROVENANCE, SEED + 11F,
                    (SEED + 11) / UNCERTAINTY_SEED_DIVISOR))
            .twoMassJMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 12F,
                    (SEED + 12) / UNCERTAINTY_SEED_DIVISOR))
            .twoMassHMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 13F,
                    (SEED + 13) / UNCERTAINTY_SEED_DIVISOR))
            .twoMassKMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 14F,
                    (SEED + 14) / UNCERTAINTY_SEED_DIVISOR))
            .keplerMag(
                new CelestialObjectParameter(PROVENANCE, SEED + 15F,
                    (SEED + 15) / UNCERTAINTY_SEED_DIVISOR))
            // .keplerId(SEED + 16F)
            .twoMassId(
                new CelestialObjectParameter(PROVENANCE, SEED + 17, (SEED + 17)
                    / UNCERTAINTY_SEED_DIVISOR))
            .internalScpId(
                new CelestialObjectParameter(PROVENANCE, SEED + 18, (SEED + 18)
                    / UNCERTAINTY_SEED_DIVISOR))
            .alternateId(
                new CelestialObjectParameter(PROVENANCE, SEED + 19, (SEED + 19)
                    / UNCERTAINTY_SEED_DIVISOR))
            .alternateSource(
                new CelestialObjectParameter(PROVENANCE, SEED + 20, (SEED + 20)
                    / UNCERTAINTY_SEED_DIVISOR))
            .galaxyIndicator(
                new CelestialObjectParameter(PROVENANCE, SEED + 21, (SEED + 21)
                    / UNCERTAINTY_SEED_DIVISOR))
            .blendIndicator(
                new CelestialObjectParameter(PROVENANCE, SEED + 22, (SEED + 22)
                    / UNCERTAINTY_SEED_DIVISOR))
            .variableIndicator(
                new CelestialObjectParameter(PROVENANCE, SEED + 23, (SEED + 23)
                    / UNCERTAINTY_SEED_DIVISOR))
            .effectiveTemp(
                new CelestialObjectParameter(PROVENANCE, SEED + 24, (SEED + 24)
                    / UNCERTAINTY_SEED_DIVISOR))
            .log10SurfaceGravity(
                new CelestialObjectParameter(PROVENANCE, SEED + 25F,
                    (SEED + 25) / UNCERTAINTY_SEED_DIVISOR))
            .log10Metallicity(
                new CelestialObjectParameter(PROVENANCE, SEED + 26F,
                    (SEED + 26) / UNCERTAINTY_SEED_DIVISOR))
            .ebMinusVRedding(
                new CelestialObjectParameter(PROVENANCE, SEED + 27F,
                    (SEED + 27) / UNCERTAINTY_SEED_DIVISOR))
            .avExtinction(
                new CelestialObjectParameter(PROVENANCE, SEED + 28F,
                    (SEED + 28) / UNCERTAINTY_SEED_DIVISOR))
            .radius(
                new CelestialObjectParameter(PROVENANCE, SEED + 29F,
                    (SEED + 29) / UNCERTAINTY_SEED_DIVISOR))
            // .source(Integer.toString(new CelestialObjectParameter(PROVENANCE,
            // SEED + 30, (SEED + 30) / UNCERTAINTY_SEED_DIVISOR))
            .photometryQuality(
                new CelestialObjectParameter(PROVENANCE, SEED + 31, (SEED + 31)
                    / UNCERTAINTY_SEED_DIVISOR))
            .astrophysicsQuality(
                new CelestialObjectParameter(PROVENANCE, SEED + 32, (SEED + 32)
                    / UNCERTAINTY_SEED_DIVISOR))
            .catalogId(
                new CelestialObjectParameter(PROVENANCE, SEED + 33, (SEED + 33)
                    / UNCERTAINTY_SEED_DIVISOR))
            .scpId(
                new CelestialObjectParameter(PROVENANCE, SEED + 34, (SEED + 34)
                    / UNCERTAINTY_SEED_DIVISOR))
            .parallax(
                new CelestialObjectParameter(PROVENANCE, SEED + 35F,
                    (SEED + 35) / UNCERTAINTY_SEED_DIVISOR))
            .galacticLongitude(
                new CelestialObjectParameter(PROVENANCE, SEED + 36.0,
                    (SEED + 36) / UNCERTAINTY_SEED_DIVISOR))
            .galacticLatitude(
                new CelestialObjectParameter(PROVENANCE, SEED + 37.0,
                    (SEED + 37) / UNCERTAINTY_SEED_DIVISOR))
            .totalProperMotion(
                new CelestialObjectParameter(PROVENANCE, SEED + 38F,
                    (SEED + 38) / UNCERTAINTY_SEED_DIVISOR))
            .grColor(
                new CelestialObjectParameter(PROVENANCE, SEED + 39F,
                    (SEED + 39) / UNCERTAINTY_SEED_DIVISOR))
            .jkColor(
                new CelestialObjectParameter(PROVENANCE, SEED + 40F,
                    (SEED + 40) / UNCERTAINTY_SEED_DIVISOR))
            .gkColor(
                new CelestialObjectParameter(PROVENANCE, SEED + 41F,
                    (SEED + 41) / UNCERTAINTY_SEED_DIVISOR))
            .build();
    }

    static void testCelestialObjectParameters(CelestialObject celestialObject,
        CelestialObjectParameters celestialObjectParameters, boolean hasValues,
        boolean hasUncertainties) {

        // Must have been an invalid Kepler ID.
        if (celestialObject == null || celestialObjectParameters == null) {
            assertNull(celestialObject);
            assertNull(celestialObjectParameters);

            return;
        }

        // Required fields (keplerId, ra, dec, and sky group ID have override
        // value of hasValues with true.
        testCelestialObjectParameter(celestialObject.getAlternateId(),
            celestialObjectParameters.getAlternateId(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getAlternateSource(),
            celestialObjectParameters.getAlternateSource(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getAstrophysicsQuality(),
            celestialObjectParameters.getAstrophysicsQuality(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getAvExtinction(),
            celestialObjectParameters.getAvExtinction(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getBlendIndicator(),
            celestialObjectParameters.getBlendIndicator(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getCatalogId(),
            celestialObjectParameters.getCatalogId(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getD51Mag(),
            celestialObjectParameters.getD51Mag(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getDec(),
            celestialObjectParameters.getDec(), true, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getDecProperMotion(),
            celestialObjectParameters.getDecProperMotion(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getEbMinusVRedding(),
            celestialObjectParameters.getEbMinusVRedding(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getEffectiveTemp(),
            celestialObjectParameters.getEffectiveTemp(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGalacticLatitude(),
            celestialObjectParameters.getGalacticLatitude(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGalacticLongitude(),
            celestialObjectParameters.getGalacticLongitude(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGalaxyIndicator(),
            celestialObjectParameters.getGalaxyIndicator(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGkColor(),
            celestialObjectParameters.getGkColor(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGMag(),
            celestialObjectParameters.getGMag(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGrColor(),
            celestialObjectParameters.getGrColor(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getGredMag(),
            celestialObjectParameters.getGredMag(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getIMag(),
            celestialObjectParameters.getIMag(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getInternalScpId(),
            celestialObjectParameters.getInternalScpId(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getJkColor(),
            celestialObjectParameters.getJkColor(), hasValues, hasUncertainties);
        assertEquals(celestialObject.getKeplerId(),
            celestialObjectParameters.getKeplerId());
        testCelestialObjectParameter(celestialObject.getKeplerMag(),
            celestialObjectParameters.getKeplerMag(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getLog10Metallicity(),
            celestialObjectParameters.getLog10Metallicity(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getLog10SurfaceGravity(),
            celestialObjectParameters.getLog10SurfaceGravity(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getParallax(),
            celestialObjectParameters.getParallax(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getPhotometryQuality(),
            celestialObjectParameters.getPhotometryQuality(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getRa(),
            celestialObjectParameters.getRa(), true, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getRadius(),
            celestialObjectParameters.getRadius(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getRaProperMotion(),
            celestialObjectParameters.getRaProperMotion(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getRMag(),
            celestialObjectParameters.getRMag(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getScpId(),
            celestialObjectParameters.getScpId(), hasValues, hasUncertainties);
        // assertEquals(celestialObject.getSkyGroupId(),
        // celestialObjectParameters.getSkyGroupId());
        // testCelestialObjectParameter(celestialObject.getSource(),
        // celestialObject.getSource(), hasValues,
        // hasUncertainties);
        testCelestialObjectParameter(celestialObject.getTotalProperMotion(),
            celestialObjectParameters.getTotalProperMotion(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getTwoMassHMag(),
            celestialObjectParameters.getTwoMassHMag(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getTwoMassId(),
            celestialObjectParameters.getTwoMassId(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getTwoMassJMag(),
            celestialObjectParameters.getTwoMassJMag(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getTwoMassKMag(),
            celestialObjectParameters.getTwoMassKMag(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getUMag(),
            celestialObjectParameters.getUMag(), hasValues, hasUncertainties);
        testCelestialObjectParameter(celestialObject.getVariableIndicator(),
            celestialObjectParameters.getVariableIndicator(), hasValues,
            hasUncertainties);
        testCelestialObjectParameter(celestialObject.getZMag(),
            celestialObjectParameters.getZMag(), hasValues, hasUncertainties);
    }

    private static void testCelestialObjectParameter(double expected,
        CelestialObjectParameter celestialObjectParameter, boolean hasValues,
        boolean hasUncertainties) {

        assertEquals(expected, celestialObjectParameter.getValue(), 0F);

        assertEquals(expected / UNCERTAINTY_SEED_DIVISOR,
            celestialObjectParameter.getUncertainty(),
            1 / UNCERTAINTY_SEED_DIVISOR);
    }

    private static CelestialObject createCelestialObject(int seed) {
        return CelestialObjectUtils.createCelestialObject(seed, SKY_GROUP_ID, seed);
    }

}
