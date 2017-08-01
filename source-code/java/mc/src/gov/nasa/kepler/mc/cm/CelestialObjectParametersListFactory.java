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
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Creates a {@link List} of {@link CelestialObjectParameters}.
 * 
 * @author Miles Cote
 * 
 */
public class CelestialObjectParametersListFactory {

    public List<CelestialObjectParameters> create(
        List<CelestialObject> originalCelestialObjects,
        KicOverrideModel kicOverrideModel) {
        Map<Integer, List<KicOverride>> keplerIdToKicOverrides = new HashMap<Integer, List<KicOverride>>();

        if (kicOverrideModel != null) {
            for (KicOverride kicOverride : kicOverrideModel.getKicOverrides()) {
                int keplerId = kicOverride.getKeplerId();

                List<KicOverride> kicOverrides = keplerIdToKicOverrides.get(keplerId);
                if (kicOverrides == null) {
                    kicOverrides = new ArrayList<KicOverride>();
                    keplerIdToKicOverrides.put(keplerId, kicOverrides);
                }

                kicOverrides.add(kicOverride);
            }
        }

        List<CelestialObjectParameters> celestialObjectParameters = new ArrayList<CelestialObjectParameters>(
            originalCelestialObjects.size());
        for (CelestialObject celestialObject : originalCelestialObjects) {
            CelestialObjectParameters updatedCelestialObjectParameters = null;
            if (celestialObject != null) {
                updatedCelestialObjectParameters = updateCelestialObjectParameters(
                    celestialObject,
                    keplerIdToKicOverrides.get(celestialObject.getKeplerId()));
            }

            celestialObjectParameters.add(updatedCelestialObjectParameters);
        }

        return celestialObjectParameters;
    }

    private CelestialObjectParameters updateCelestialObjectParameters(
        CelestialObject celestialObject, List<KicOverride> kicOverrides) {

        CelestialObjectParameters.Builder celestialObjectParametersBuilder = new CelestialObjectParameters.Builder(
            celestialObject);

        celestialObjectParametersBuilder.alternateId(createCelestialObjectParameter(
            celestialObject.getAlternateId(), kicOverrides, Field.ALTID,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.alternateSource(createCelestialObjectParameter(
            celestialObject.getAlternateSource(), kicOverrides,
            Field.ALTSOURCE, celestialObject.getProvenance()));
        celestialObjectParametersBuilder.astrophysicsQuality(createCelestialObjectParameter(
            celestialObject.getAstrophysicsQuality(), kicOverrides, Field.AQ,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.avExtinction(createCelestialObjectParameter(
            celestialObject.getAvExtinction(), kicOverrides, Field.AV,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.blendIndicator(createCelestialObjectParameter(
            celestialObject.getBlendIndicator(), kicOverrides, Field.BLEND,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.catalogId(createCelestialObjectParameter(
            celestialObject.getCatalogId(), kicOverrides, Field.CATKEY,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.d51Mag(createCelestialObjectParameter(
            celestialObject.getD51Mag(), kicOverrides, Field.D51MAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.dec(createCelestialObjectParameter(
            celestialObject.getDec(), kicOverrides, Field.DEC,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.decProperMotion(createCelestialObjectParameter(
            celestialObject.getDecProperMotion(), kicOverrides, Field.PMDEC,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.ebMinusVRedding(createCelestialObjectParameter(
            celestialObject.getEbMinusVRedding(), kicOverrides, Field.EBMINUSV,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.effectiveTemp(createCelestialObjectParameter(
            celestialObject.getEffectiveTemp(), kicOverrides, Field.TEFF,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.galacticLatitude(createCelestialObjectParameter(
            celestialObject.getGalacticLatitude(), kicOverrides, Field.GLAT,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.galacticLongitude(createCelestialObjectParameter(
            celestialObject.getGalacticLongitude(), kicOverrides, Field.GLON,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.galaxyIndicator(createCelestialObjectParameter(
            celestialObject.getGalaxyIndicator(), kicOverrides, Field.GALAXY,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.gkColor(createCelestialObjectParameter(
            celestialObject.getGkColor(), kicOverrides, Field.GKCOLOR,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.gMag(createCelestialObjectParameter(
            celestialObject.getGMag(), kicOverrides, Field.GMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.grColor(createCelestialObjectParameter(
            celestialObject.getGrColor(), kicOverrides, Field.GRCOLOR,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.gredMag(createCelestialObjectParameter(
            celestialObject.getGredMag(), kicOverrides, Field.GREDMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.iMag(createCelestialObjectParameter(
            celestialObject.getIMag(), kicOverrides, Field.IMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.internalScpId(createCelestialObjectParameter(
            celestialObject.getInternalScpId(), kicOverrides, Field.SCPID,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.jkColor(createCelestialObjectParameter(
            celestialObject.getJkColor(), kicOverrides, Field.JKCOLOR,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.keplerMag(createCelestialObjectParameter(
            celestialObject.getKeplerMag(), kicOverrides, Field.KEPMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.log10Metallicity(createCelestialObjectParameter(
            celestialObject.getLog10Metallicity(), kicOverrides, Field.FEH,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.log10SurfaceGravity(createCelestialObjectParameter(
            celestialObject.getLog10SurfaceGravity(), kicOverrides, Field.LOGG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.parallax(createCelestialObjectParameter(
            celestialObject.getParallax(), kicOverrides, Field.PARALLAX,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.photometryQuality(createCelestialObjectParameter(
            celestialObject.getPhotometryQuality(), kicOverrides, Field.PQ,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.ra(createCelestialObjectParameter(
            celestialObject.getRa(), kicOverrides, Field.RA,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.radius(createCelestialObjectParameter(
            celestialObject.getRadius(), kicOverrides, Field.RADIUS,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.raProperMotion(createCelestialObjectParameter(
            celestialObject.getRaProperMotion(), kicOverrides, Field.PMRA,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.rMag(createCelestialObjectParameter(
            celestialObject.getRMag(), kicOverrides, Field.RMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.scpId(createCelestialObjectParameter(
            celestialObject.getScpId(), kicOverrides, Field.SCPKEY,
            celestialObject.getProvenance()));
        // celestialObjectParametersBuilder.source(source);
        celestialObjectParametersBuilder.totalProperMotion(createCelestialObjectParameter(
            celestialObject.getTotalProperMotion(), kicOverrides,
            Field.PMTOTAL, celestialObject.getProvenance()));
        celestialObjectParametersBuilder.twoMassHMag(createCelestialObjectParameter(
            celestialObject.getTwoMassHMag(), kicOverrides, Field.HMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.twoMassId(createCelestialObjectParameter(
            celestialObject.getTwoMassId(), kicOverrides, Field.TMID,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.twoMassJMag(createCelestialObjectParameter(
            celestialObject.getTwoMassJMag(), kicOverrides, Field.JMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.twoMassKMag(createCelestialObjectParameter(
            celestialObject.getTwoMassKMag(), kicOverrides, Field.KMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.uMag(createCelestialObjectParameter(
            celestialObject.getUMag(), kicOverrides, Field.UMAG,
            celestialObject.getProvenance()));
        celestialObjectParametersBuilder.variableIndicator(createCelestialObjectParameter(
            celestialObject.getVariableIndicator(), kicOverrides,
            Field.VARIABLE, celestialObject.getProvenance()));
        celestialObjectParametersBuilder.zMag(createCelestialObjectParameter(
            celestialObject.getZMag(), kicOverrides, Field.ZMAG,
            celestialObject.getProvenance()));

        CelestialObjectParameters celestialObjectParameters = celestialObjectParametersBuilder.build();
        return celestialObjectParameters;
    }

    private CelestialObjectParameter createCelestialObjectParameter(
        Integer value, List<KicOverride> kicOverrides, Field field,
        String provenance) {
        return createCelestialObjectParameter(
            value != null ? value.doubleValue() : null, kicOverrides, field,
            provenance);
    }

    private CelestialObjectParameter createCelestialObjectParameter(
        Float value, List<KicOverride> kicOverrides, Field field,
        String provenance) {
        return createCelestialObjectParameter(
            value != null ? value.doubleValue() : null, kicOverrides, field,
            provenance);
    }

    private CelestialObjectParameter createCelestialObjectParameter(
        Double value, List<KicOverride> kicOverrides, Field field,
        String provenance) {
        CelestialObjectParameter celestialObjectParameter = new CelestialObjectParameter(
            provenance, value);
        if (kicOverrides != null) {
            for (KicOverride kicOverride : kicOverrides) {
                if (kicOverride.getField()
                    .equals(field)) {
                    celestialObjectParameter = new CelestialObjectParameter(
                        kicOverride.getProvenance(), kicOverride.getValue(),
                        kicOverride.getUncertainty());
                }
            }
        }

        return celestialObjectParameter;
    }

}
