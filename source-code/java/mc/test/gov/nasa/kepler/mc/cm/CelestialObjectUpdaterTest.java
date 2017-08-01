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

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CelestialObjectUtils;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class CelestialObjectUpdaterTest {

    private static final int KIC_VALUE_OFFSET = 1;
    private static final int KIC_OVERRIDE_VALUE_OFFSET = 2;
    private static final int REVISION = 3;
    private static final int KEPLER_ID = 4;
    private static final int SKY_GROUP_ID = 42;

    @Test
    public void testUpdateWithOverridesSet() throws IllegalAccessException {
        CelestialObject celestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        KicOverrideModel kicOverrideModel = new KicOverrideModel(REVISION,
            createKicOverrides(KEPLER_ID, KIC_OVERRIDE_VALUE_OFFSET));

        CelestialObject expectedCelestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_OVERRIDE_VALUE_OFFSET);

        testUpdateInternal(celestialObject, kicOverrideModel,
            expectedCelestialObject);
    }

    @Test
    public void testUpdateWithOverridesNotSet() throws IllegalAccessException {
        CelestialObject celestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        List<KicOverride> kicOverrides = ImmutableList.of();
        KicOverrideModel kicOverrideModel = new KicOverrideModel(REVISION,
            kicOverrides);

        CelestialObject expectedCelestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        testUpdateInternal(celestialObject, kicOverrideModel,
            expectedCelestialObject);
    }

    @Test
    public void testUpdateWithNullCelestialObject()
        throws IllegalAccessException {
        CelestialObject celestialObject = null;

        KicOverrideModel kicOverrideModel = new KicOverrideModel(REVISION,
            createKicOverrides(KEPLER_ID, KIC_OVERRIDE_VALUE_OFFSET));

        CelestialObject expectedCelestialObject = null;

        testUpdateInternal(celestialObject, kicOverrideModel,
            expectedCelestialObject);
    }

    @Test
    public void testUpdateWithNullKicOverrides() throws IllegalAccessException {
        CelestialObject celestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        KicOverrideModel kicOverrideModel = null;

        CelestialObject expectedCelestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        testUpdateInternal(celestialObject, kicOverrideModel,
            expectedCelestialObject);
    }

    private void testUpdateInternal(CelestialObject celestialObject,
        KicOverrideModel kicOverrideModel,
        CelestialObject expectedCelestialObject) throws IllegalAccessException {
        List<CelestialObject> celestialObjects = newArrayList(celestialObject);

        CelestialObjectUpdater celestialObjectUpdater = new CelestialObjectUpdater();
        List<CelestialObject> actualCelestialObjects = celestialObjectUpdater.update(
            celestialObjects, kicOverrideModel);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(newArrayList(expectedCelestialObject),
            actualCelestialObjects);
    }

    private List<KicOverride> createKicOverrides(int keplerId, int valueOffset) {
        List<KicOverride> kicOverrides = newArrayList();
        for (Field field : Field.values()) {
            kicOverrides.add(new KicOverride(keplerId, field, "Test",
                field.ordinal() + valueOffset, 0.0));
        }

        return kicOverrides;
    }

}
