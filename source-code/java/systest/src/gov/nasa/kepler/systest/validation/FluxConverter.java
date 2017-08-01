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

package gov.nasa.kepler.systest.validation;

import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.fgsFramesPerIntegration;
import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.integrationsPerShortCadence;
import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.millisecondsPerFgsFrame;
import static gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic.shortCadencesPerLongCadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;

import java.util.Collection;

/**
 * Converts flux per cadence into flux per second to match the data contained in
 * the target pixel file.
 * 
 * @see {@link gov.nasa.kepler.ar.exporter.tpixel.ExposureCalculator}
 * @author Forrest Girouard
 * @author Sean McCauliff
 */
public class FluxConverter {

    private static final int SEC_PER_MILLIS = 1000;

    // GSprm_FGSPER
    private final double fgsFrameTimeMilliS;
    // FDMINTPER + 2
    private final int numberOfFgsFramesPerScienceFrame;
    private final int numberOfScienceFramesPerShortCadence;
    private final int numberOfShortCadencesPerLongCadence;
    private final double fluxPerCadenceToFluxPerSecond;

    /**
     * Creates a {@code FluxConverter} instance.
     * 
     * @param configMaps The spacecraft config maps stored in the database.
     * These maps should span the time for the exported data.
     * @param cadenceType the {@link CadenceType}.
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     */
    public FluxConverter(Collection<ConfigMap> configMaps,
        CadenceType cadenceType) {

        if (configMaps == null) {
            throw new NullPointerException("configMaps can't be null");
        }

        fgsFrameTimeMilliS = Double.parseDouble(configMapsShouldHaveUniqueValue(
            configMaps, millisecondsPerFgsFrame.mnemonic()));

        numberOfFgsFramesPerScienceFrame = Integer.parseInt(configMapsShouldHaveUniqueValue(
            configMaps, fgsFramesPerIntegration.mnemonic()));

        numberOfScienceFramesPerShortCadence = Integer.parseInt(configMapsShouldHaveUniqueValue(
            configMaps, integrationsPerShortCadence.mnemonic()));

        numberOfShortCadencesPerLongCadence = Integer.parseInt(configMapsShouldHaveUniqueValue(
            configMaps, shortCadencesPerLongCadence.mnemonic()));

        switch (cadenceType) {
            case SHORT:
                fluxPerCadenceToFluxPerSecond = SEC_PER_MILLIS
                    / (fgsFrameTimeMilliS * numberOfFgsFramesPerScienceFrame * numberOfScienceFramesPerShortCadence);
                break;
            case LONG:
                fluxPerCadenceToFluxPerSecond = SEC_PER_MILLIS
                    / (fgsFrameTimeMilliS * numberOfFgsFramesPerScienceFrame
                        * numberOfScienceFramesPerShortCadence * numberOfShortCadencesPerLongCadence);
                break;
            default:
                throw new IllegalStateException("Unhandled cadence type : "
                    + cadenceType);
        }
    }

    private static String configMapsShouldHaveUniqueValue(
        Collection<ConfigMap> configMaps, String mnemonic) {

        String value = null;
        for (ConfigMap configMap : configMaps) {
            String currentValue;
            try {
                currentValue = configMap.get(mnemonic);
            } catch (Exception e) {
                // I'm not sure why get() needs to throw Exception.
                throw new IllegalStateException(e);
            }
            if (value == null) {
                value = currentValue;
            } else if (!value.equals(currentValue)) {
                throw new IllegalStateException(
                    "config maps do not match for mnemonic \"" + mnemonic
                        + "\".");
            }
        }

        if (value == null) {
            throw new IllegalStateException(
                "Missing config map value for mnemonic \"" + mnemonic + "\".");
        }

        return value;
    }

    public float fluxPerCadenceToFluxPerSecond(double fluxPerCadence) {

        return (float) (fluxPerCadence * fluxPerCadenceToFluxPerSecond);
    }

}
