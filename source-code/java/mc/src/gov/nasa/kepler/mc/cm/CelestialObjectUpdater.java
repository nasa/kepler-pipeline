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
import gov.nasa.kepler.hibernate.cm.CelestialObjectBuilder;
import gov.nasa.kepler.hibernate.cm.Kic.Field;
import gov.nasa.kepler.hibernate.cm.KicOverride;
import gov.nasa.kepler.hibernate.cm.KicOverrideModel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Updates {@link CelestialObject}s.
 * 
 * @author Miles Cote
 * 
 */
public class CelestialObjectUpdater {

    private final CelestialObjectBuilderFactory celestialObjectBuilderFactory;

    public CelestialObjectUpdater() {
        celestialObjectBuilderFactory = new CelestialObjectBuilderFactory();
    }

    public CelestialObjectUpdater(
        CelestialObjectBuilderFactory celestialObjectBuilderFactory) {
        this.celestialObjectBuilderFactory = celestialObjectBuilderFactory;
    }

    public List<CelestialObject> update(
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

        List<CelestialObject> celestialObjects = new ArrayList<CelestialObject>(
            originalCelestialObjects.size());
        for (CelestialObject celestialObject : originalCelestialObjects) {
            CelestialObject updatedCelestialObject = null;
            if (celestialObject != null) {
                updatedCelestialObject = updateCelestialObject(celestialObject,
                    keplerIdToKicOverrides.get(celestialObject.getKeplerId()));
            }

            celestialObjects.add(updatedCelestialObject);
        }

        return celestialObjects;
    }

    private CelestialObject updateCelestialObject(
        CelestialObject celestialObject, List<KicOverride> kicOverrides) {
        if (kicOverrides == null) {
            return celestialObject;
        }

        CelestialObjectBuilder celestialObjectBuilder = celestialObjectBuilderFactory.create(celestialObject);
        for (KicOverride kicOverride : kicOverrides) {
            Field field = kicOverride.getField();
            if (field.equals(Field.ALTID)) {
                celestialObjectBuilder.alternateId((int) kicOverride.getValue());
            } else if (field.equals(Field.ALTSOURCE)) {
                celestialObjectBuilder.alternateSource((int) kicOverride.getValue());
            } else if (field.equals(Field.AQ)) {
                celestialObjectBuilder.astrophysicsQuality((int) kicOverride.getValue());
            } else if (field.equals(Field.AV)) {
                celestialObjectBuilder.avExtinction((float) kicOverride.getValue());
            } else if (field.equals(Field.BLEND)) {
                celestialObjectBuilder.blendIndicator((int) kicOverride.getValue());
            } else if (field.equals(Field.CATKEY)) {
                celestialObjectBuilder.catalogId((int) kicOverride.getValue());
                // } else if (field.equals(Field.CQ)) {
                // celestialObjectBuilder.source(kicOverride.getValue().stringValue());
            } else if (field.equals(Field.D51MAG)) {
                celestialObjectBuilder.d51Mag((float) kicOverride.getValue());
            } else if (field.equals(Field.DEC)) {
                celestialObjectBuilder.dec(kicOverride.getValue());
            } else if (field.equals(Field.EBMINUSV)) {
                celestialObjectBuilder.ebMinusVRedding((float) kicOverride.getValue());
            } else if (field.equals(Field.FEH)) {
                celestialObjectBuilder.log10Metallicity((float) kicOverride.getValue());
            } else if (field.equals(Field.GALAXY)) {
                celestialObjectBuilder.galaxyIndicator((int) kicOverride.getValue());
            } else if (field.equals(Field.GKCOLOR)) {
                celestialObjectBuilder.gkColor((float) kicOverride.getValue());
            } else if (field.equals(Field.GLAT)) {
                celestialObjectBuilder.galacticLatitude(kicOverride.getValue());
            } else if (field.equals(Field.GLON)) {
                celestialObjectBuilder.galacticLongitude(kicOverride.getValue());
            } else if (field.equals(Field.GMAG)) {
                celestialObjectBuilder.gMag((float) kicOverride.getValue());
            } else if (field.equals(Field.GRCOLOR)) {
                celestialObjectBuilder.grColor((float) kicOverride.getValue());
            } else if (field.equals(Field.GREDMAG)) {
                celestialObjectBuilder.gredMag((float) kicOverride.getValue());
            } else if (field.equals(Field.HMAG)) {
                celestialObjectBuilder.twoMassHMag((float) kicOverride.getValue());
            } else if (field.equals(Field.IMAG)) {
                celestialObjectBuilder.iMag((float) kicOverride.getValue());
            } else if (field.equals(Field.JKCOLOR)) {
                celestialObjectBuilder.jkColor((float) kicOverride.getValue());
            } else if (field.equals(Field.JMAG)) {
                celestialObjectBuilder.twoMassJMag((float) kicOverride.getValue());
                // } else if
                // (field.equals(Field.KEPLER_ID)) {
                // celestialObjectBuilder.keplerId(kicOverride.getValue());
            } else if (field.equals(Field.KEPMAG)) {
                celestialObjectBuilder.keplerMag((float) kicOverride.getValue());
            } else if (field.equals(Field.KMAG)) {
                celestialObjectBuilder.twoMassKMag((float) kicOverride.getValue());
            } else if (field.equals(Field.LOGG)) {
                celestialObjectBuilder.log10SurfaceGravity((float) kicOverride.getValue());
            } else if (field.equals(Field.PARALLAX)) {
                celestialObjectBuilder.parallax((float) kicOverride.getValue());
            } else if (field.equals(Field.PMDEC)) {
                celestialObjectBuilder.decProperMotion((float) kicOverride.getValue());
            } else if (field.equals(Field.PMRA)) {
                celestialObjectBuilder.raProperMotion((float) kicOverride.getValue());
            } else if (field.equals(Field.PMTOTAL)) {
                celestialObjectBuilder.totalProperMotion((float) kicOverride.getValue());
            } else if (field.equals(Field.PQ)) {
                celestialObjectBuilder.photometryQuality((int) kicOverride.getValue());
            } else if (field.equals(Field.RA)) {
                celestialObjectBuilder.ra(kicOverride.getValue());
            } else if (field.equals(Field.RADIUS)) {
                celestialObjectBuilder.radius((float) kicOverride.getValue());
            } else if (field.equals(Field.RMAG)) {
                celestialObjectBuilder.rMag((float) kicOverride.getValue());
            } else if (field.equals(Field.SCPID)) {
                celestialObjectBuilder.internalScpId((int) kicOverride.getValue());
            } else if (field.equals(Field.SCPKEY)) {
                celestialObjectBuilder.scpId((int) kicOverride.getValue());
                // } else if
                // (field.equals(Field.SKY_GROUP_ID)) {
                // celestialObjectBuilder.skyGroupId(kicOverride.getValue());
            } else if (field.equals(Field.TEFF)) {
                celestialObjectBuilder.effectiveTemp((int) kicOverride.getValue());
            } else if (field.equals(Field.TMID)) {
                celestialObjectBuilder.twoMassId((int) kicOverride.getValue());
            } else if (field.equals(Field.UMAG)) {
                celestialObjectBuilder.uMag((float) kicOverride.getValue());
            } else if (field.equals(Field.VARIABLE)) {
                celestialObjectBuilder.variableIndicator((int) kicOverride.getValue());
            } else if (field.equals(Field.ZMAG)) {
                celestialObjectBuilder.zMag((float) kicOverride.getValue());
            }
        }

        return celestialObjectBuilder.build();
    }

}
