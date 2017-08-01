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

import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CelestialObjectUtils;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.Lists;

/**
 * @author Miles Cote
 * 
 */
public class CelestialObjectParametersListFactoryTest {

    private static final int KIC_VALUE_OFFSET = 1;
    private static final int KIC_OVERRIDE_VALUE_OFFSET = 2;
    private static final int KIC_OVERRIDE_UNCERTAINTY_OFFSET = 3;
    private static final int REVISION = 4;
    private static final int KEPLER_ID = 5;
    private static final String PROVENANCE = "KIC";
    private static int SKY_GROUP_ID = 42;

    @Test
    public void testGetInstanceWithKicOverrides() throws IllegalAccessException {
        CelestialObject celestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        KicOverrideModel kicOverrideModel = new KicOverrideModel(REVISION,
            createKicOverrides(KEPLER_ID, KIC_OVERRIDE_VALUE_OFFSET,
                KIC_OVERRIDE_UNCERTAINTY_OFFSET));

        CelestialObjectParameters expectedCelestialObjectParameters = createCelestialObjectParameters(
            CelestialObjectUtils.createCelestialObject(KEPLER_ID,
                SKY_GROUP_ID, KIC_OVERRIDE_VALUE_OFFSET), KIC_OVERRIDE_VALUE_OFFSET,
            KIC_OVERRIDE_UNCERTAINTY_OFFSET);

        testGetInstanceInternal(celestialObject, kicOverrideModel,
            expectedCelestialObjectParameters);
    }

    @Test
    public void testGetInstanceWithNullCelestialObject()
        throws IllegalAccessException {
        CelestialObject celestialObject = null;

        KicOverrideModel kicOverrideModel = new KicOverrideModel(REVISION,
            createKicOverrides(KEPLER_ID, KIC_OVERRIDE_VALUE_OFFSET,
                KIC_OVERRIDE_UNCERTAINTY_OFFSET));

        CelestialObjectParameters expectedCelestialObjectParameters = null;

        testGetInstanceInternal(celestialObject, kicOverrideModel,
            expectedCelestialObjectParameters);
    }

    @Test
    public void testGetInstanceWithNullKicOverrides()
        throws IllegalAccessException {
        CelestialObject celestialObject = CelestialObjectUtils.createCelestialObject(
            KEPLER_ID, SKY_GROUP_ID, KIC_VALUE_OFFSET);

        KicOverrideModel kicOverrideModel = null;

        CelestialObjectParameters expectedCelestialObjectParameters = createCelestialObjectParameters(
            CelestialObjectUtils.createCelestialObject(KEPLER_ID,
                SKY_GROUP_ID, KIC_VALUE_OFFSET), KIC_VALUE_OFFSET, null);

        testGetInstanceInternal(celestialObject, kicOverrideModel,
            expectedCelestialObjectParameters);
    }

    private void testGetInstanceInternal(CelestialObject celestialObject,
        KicOverrideModel kicOverrideModel,
        CelestialObjectParameters expectedCelestialObjectParameters)
        throws IllegalAccessException {
        List<CelestialObject> celestialObjects = Lists.newArrayList(celestialObject);

        CelestialObjectParametersListFactory celestialObjectParametersListFactory = new CelestialObjectParametersListFactory();
        List<CelestialObjectParameters> actualCelestialObjectParametersList = celestialObjectParametersListFactory.create(
            celestialObjects, kicOverrideModel);

        List<CelestialObjectParameters> expectedCelestialObjectParametersList = Lists.newArrayList(expectedCelestialObjectParameters);

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.excludeField(".*\\.provenance");
        reflectionEquals.assertEquals(expectedCelestialObjectParametersList,
            actualCelestialObjectParametersList);
    }

    private List<KicOverride> createKicOverrides(int keplerId, int valueOffset,
        int uncertaintyOffset) {
        List<KicOverride> kicOverrides = Lists.newArrayList();
        for (Field field : Field.values()) {
            kicOverrides.add(new KicOverride(keplerId, field, "Test",
                field.ordinal() + valueOffset,
                (double) (field.ordinal() + uncertaintyOffset)));
        }

        return kicOverrides;
    }

    private CelestialObjectParameters createCelestialObjectParameters(
        CelestialObject celestialObject, int valueOffset,
        Integer uncertaintyOffset) {
        CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
            celestialObject).ra(
            new CelestialObjectParameter(PROVENANCE, Field.RA.ordinal()
                + valueOffset, applyUncertaintyOffset(Field.RA.ordinal(),
                uncertaintyOffset)))
            .dec(
                new CelestialObjectParameter(PROVENANCE, Field.DEC.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.DEC.ordinal(),
                    uncertaintyOffset)))
            .raProperMotion(
                new CelestialObjectParameter(PROVENANCE, Field.PMRA.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.PMRA.ordinal(),
                    uncertaintyOffset)))
            .decProperMotion(
                new CelestialObjectParameter(PROVENANCE, Field.PMDEC.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.PMDEC.ordinal(), uncertaintyOffset)))
            .uMag(
                new CelestialObjectParameter(PROVENANCE, Field.UMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.UMAG.ordinal(),
                    uncertaintyOffset)))
            .gMag(
                new CelestialObjectParameter(PROVENANCE, Field.GMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.GMAG.ordinal(),
                    uncertaintyOffset)))
            .rMag(
                new CelestialObjectParameter(PROVENANCE, Field.RMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.RMAG.ordinal(),
                    uncertaintyOffset)))
            .iMag(
                new CelestialObjectParameter(PROVENANCE, Field.IMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.IMAG.ordinal(),
                    uncertaintyOffset)))
            .zMag(
                new CelestialObjectParameter(PROVENANCE, Field.ZMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.ZMAG.ordinal(),
                    uncertaintyOffset)))
            .gredMag(
                new CelestialObjectParameter(PROVENANCE,
                    Field.GREDMAG.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.GREDMAG.ordinal(),
                        uncertaintyOffset)))
            .d51Mag(
                new CelestialObjectParameter(PROVENANCE, Field.D51MAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.D51MAG.ordinal(), uncertaintyOffset)))
            .twoMassJMag(
                new CelestialObjectParameter(PROVENANCE, Field.JMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.JMAG.ordinal(),
                    uncertaintyOffset)))
            .twoMassHMag(
                new CelestialObjectParameter(PROVENANCE, Field.HMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.HMAG.ordinal(),
                    uncertaintyOffset)))
            .twoMassKMag(
                new CelestialObjectParameter(PROVENANCE, Field.KMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.KMAG.ordinal(),
                    uncertaintyOffset)))
            .keplerMag(
                new CelestialObjectParameter(PROVENANCE, Field.KEPMAG.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.KEPMAG.ordinal(), uncertaintyOffset)))
            .twoMassId(
                new CelestialObjectParameter(PROVENANCE, Field.TMID.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.TMID.ordinal(),
                    uncertaintyOffset)))
            .internalScpId(
                new CelestialObjectParameter(PROVENANCE, Field.SCPID.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.SCPID.ordinal(), uncertaintyOffset)))
            .alternateId(
                new CelestialObjectParameter(PROVENANCE, Field.ALTID.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.ALTID.ordinal(), uncertaintyOffset)))
            .alternateSource(
                new CelestialObjectParameter(PROVENANCE,
                    Field.ALTSOURCE.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.ALTSOURCE.ordinal(),
                        uncertaintyOffset)))
            .galaxyIndicator(
                new CelestialObjectParameter(PROVENANCE, Field.GALAXY.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.GALAXY.ordinal(), uncertaintyOffset)))
            .blendIndicator(
                new CelestialObjectParameter(PROVENANCE, Field.BLEND.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.BLEND.ordinal(), uncertaintyOffset)))
            .variableIndicator(
                new CelestialObjectParameter(PROVENANCE,
                    Field.VARIABLE.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.VARIABLE.ordinal(),
                        uncertaintyOffset)))
            .effectiveTemp(
                new CelestialObjectParameter(PROVENANCE, Field.TEFF.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.TEFF.ordinal(),
                    uncertaintyOffset)))
            .log10SurfaceGravity(
                new CelestialObjectParameter(PROVENANCE, Field.LOGG.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.LOGG.ordinal(),
                    uncertaintyOffset)))
            .log10Metallicity(
                new CelestialObjectParameter(PROVENANCE, Field.FEH.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.FEH.ordinal(),
                    uncertaintyOffset)))
            .ebMinusVRedding(
                new CelestialObjectParameter(PROVENANCE,
                    Field.EBMINUSV.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.EBMINUSV.ordinal(),
                        uncertaintyOffset)))
            .avExtinction(
                new CelestialObjectParameter(PROVENANCE, Field.AV.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.AV.ordinal(),
                    uncertaintyOffset)))
            .radius(
                new CelestialObjectParameter(PROVENANCE, Field.RADIUS.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.RADIUS.ordinal(), uncertaintyOffset)))
            .photometryQuality(
                new CelestialObjectParameter(PROVENANCE, Field.PQ.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.PQ.ordinal(),
                    uncertaintyOffset)))
            .astrophysicsQuality(
                new CelestialObjectParameter(PROVENANCE, Field.AQ.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.AQ.ordinal(),
                    uncertaintyOffset)))
            .catalogId(
                new CelestialObjectParameter(PROVENANCE, Field.CATKEY.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.CATKEY.ordinal(), uncertaintyOffset)))
            .scpId(
                new CelestialObjectParameter(PROVENANCE, Field.SCPKEY.ordinal()
                    + valueOffset, applyUncertaintyOffset(
                    Field.SCPKEY.ordinal(), uncertaintyOffset)))
            .parallax(
                new CelestialObjectParameter(PROVENANCE,
                    Field.PARALLAX.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.PARALLAX.ordinal(),
                        uncertaintyOffset)))
            .galacticLongitude(
                new CelestialObjectParameter(PROVENANCE, Field.GLON.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.GLON.ordinal(),
                    uncertaintyOffset)))
            .galacticLatitude(
                new CelestialObjectParameter(PROVENANCE, Field.GLAT.ordinal()
                    + valueOffset, applyUncertaintyOffset(Field.GLAT.ordinal(),
                    uncertaintyOffset)))
            .totalProperMotion(
                new CelestialObjectParameter(PROVENANCE,
                    Field.PMTOTAL.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.PMTOTAL.ordinal(),
                        uncertaintyOffset)))
            .grColor(
                new CelestialObjectParameter(PROVENANCE,
                    Field.GRCOLOR.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.GRCOLOR.ordinal(),
                        uncertaintyOffset)))
            .jkColor(
                new CelestialObjectParameter(PROVENANCE,
                    Field.JKCOLOR.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.JKCOLOR.ordinal(),
                        uncertaintyOffset)))
            .gkColor(
                new CelestialObjectParameter(PROVENANCE,
                    Field.GKCOLOR.ordinal() + valueOffset,
                    applyUncertaintyOffset(Field.GKCOLOR.ordinal(),
                        uncertaintyOffset)))
            .build();

        return celestialObjectParameters;
    }

    private double applyUncertaintyOffset(int ordinal, Integer uncertaintyOffset) {
        double returnValue = 0;
        if (uncertaintyOffset != null) {
            returnValue = ordinal + uncertaintyOffset;
        } else {
            // Use the default uncertainty in this case.
            returnValue = new CelestialObjectParameter().getUncertainty();
        }

        return returnValue;
    }
}
