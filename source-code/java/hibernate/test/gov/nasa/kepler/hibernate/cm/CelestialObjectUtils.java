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

import gov.nasa.kepler.hibernate.cm.Kic.Field;

/**
 * {@link CelestialObject} utilities for test purposes.
 * 
 * @author Miles Cote
 * 
 */
public class CelestialObjectUtils {

    public static CelestialObject createCelestialObject(int keplerId,
        int skyGroupId, int valueOffset) {
        CelestialObject celestialObject = new Kic.Builder(keplerId,
            Field.RA.ordinal() + valueOffset, Field.DEC.ordinal() + valueOffset).skyGroupId(
            skyGroupId)
            .raProperMotion((float) (Field.PMRA.ordinal() + valueOffset))
            .decProperMotion((float) (Field.PMDEC.ordinal() + valueOffset))
            .uMag((float) (Field.UMAG.ordinal() + valueOffset))
            .gMag((float) (Field.GMAG.ordinal() + valueOffset))
            .rMag((float) (Field.RMAG.ordinal() + valueOffset))
            .iMag((float) (Field.IMAG.ordinal() + valueOffset))
            .zMag((float) (Field.ZMAG.ordinal() + valueOffset))
            .gredMag((float) (Field.GREDMAG.ordinal() + valueOffset))
            .d51Mag((float) (Field.D51MAG.ordinal() + valueOffset))
            .twoMassJMag((float) (Field.JMAG.ordinal() + valueOffset))
            .twoMassHMag((float) (Field.HMAG.ordinal() + valueOffset))
            .twoMassKMag((float) (Field.KMAG.ordinal() + valueOffset))
            .keplerMag((float) (Field.KEPMAG.ordinal() + valueOffset))
            .twoMassId(Field.TMID.ordinal() + valueOffset)
            .internalScpId(Field.SCPID.ordinal() + valueOffset)
            .alternateId(Field.ALTID.ordinal() + valueOffset)
            .alternateSource(Field.ALTSOURCE.ordinal() + valueOffset)
            .galaxyIndicator(Field.GALAXY.ordinal() + valueOffset)
            .blendIndicator(Field.BLEND.ordinal() + valueOffset)
            .variableIndicator(Field.VARIABLE.ordinal() + valueOffset)
            .effectiveTemp(Field.TEFF.ordinal() + valueOffset)
            .log10SurfaceGravity((float) (Field.LOGG.ordinal() + valueOffset))
            .log10Metallicity((float) (Field.FEH.ordinal() + valueOffset))
            .ebMinusVRedding((float) (Field.EBMINUSV.ordinal() + valueOffset))
            .avExtinction((float) (Field.AV.ordinal() + valueOffset))
            .radius((float) (Field.RADIUS.ordinal() + valueOffset))
            .photometryQuality(Field.PQ.ordinal() + valueOffset)
            .astrophysicsQuality(Field.AQ.ordinal() + valueOffset)
            .catalogId(Field.CATKEY.ordinal() + valueOffset)
            .scpId(Field.SCPKEY.ordinal() + valueOffset)
            .parallax((float) (Field.PARALLAX.ordinal() + valueOffset))
            .galacticLongitude((double) (Field.GLON.ordinal() + valueOffset))
            .galacticLatitude((double) (Field.GLAT.ordinal() + valueOffset))
            .totalProperMotion((float) (Field.PMTOTAL.ordinal() + valueOffset))
            .grColor((float) (Field.GRCOLOR.ordinal() + valueOffset))
            .jkColor((float) (Field.JKCOLOR.ordinal() + valueOffset))
            .gkColor((float) (Field.GKCOLOR.ordinal() + valueOffset))
            .build();

        return celestialObject;
    }

}
