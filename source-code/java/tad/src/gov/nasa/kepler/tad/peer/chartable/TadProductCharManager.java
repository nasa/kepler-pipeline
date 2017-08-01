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

package gov.nasa.kepler.tad.peer.chartable;

import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.tad.peer.chartable.TadProductsToCharTablePipelineModule.TadProductType;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class contains the logic by which {@link TadProductType} characteristics
 * are created, updated, and deleted.
 * 
 * @author Miles Cote
 * 
 */
class TadProductCharManager {

    private static final Log log = LogFactory.getLog(TadProductCharManager.class);

    void manage(String targetListSetName, ModOut modOut) {
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        KicCrud kicCrud = new KicCrud();
        TargetCrud targetCrud = new TargetCrud();
        CharacteristicCrud charCrud = new CharacteristicCrud();

        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet(targetListSetName);
        if (targetListSet == null) {
            throw new IllegalArgumentException(
                "The target list set must exist in the database.\n  targetListSetName: "
                    + targetListSetName);
        }

        log.info(TargetListSetOperations.getTlsInfo(targetListSet));

        TargetType type = targetListSet.getType();
        if (type != TargetType.LONG_CADENCE) {
            throw new IllegalArgumentException(
                "The targetListSet must be of type " + TargetType.LONG_CADENCE
                    + " targetListSet.\n  targetType: " + type
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        TargetTable targetTable = targetListSet.getTargetTable();
        if (targetTable == null) {
            throw new IllegalArgumentException(
                "The targetTable for the tls must be non-null.  "
                    + "A null targetTable indicates that this tls has not run through tad, "
                    + "which means it has no tad products to store in the char table.  "
                    + "Make sure to use a tls that has run through tad."
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        int season = targetTable.getObservingSeason();
        int skyGroupId = kicCrud.retrieveSkyGroupId(modOut.getCcdModule(),
            modOut.getCcdOutput(), season);

        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, modOut.getCcdModule(), modOut.getCcdOutput());
        for (TadProductType tadProductType : TadProductType.values()) {
            String charTypeName = tadProductType.getCharTypeName(season);
            CharacteristicType charType = charCrud.retrieveCharacteristicType(charTypeName);
            if (charType == null) {
                throw new IllegalStateException(
                    "Tad product char types must exist in the database.\n  tadProductCharType: "
                        + charTypeName
                        + "\n  Note: There is a runjava nickname called create-tad-product-char-types "
                        + "to create all of the tad product char types in "
                        + "the database.  Try running that before calling this pipeline module.");
            }

            log.info("Deleting any existing charactieristics for "
                + charTypeName + ", for skyGroupId " + skyGroupId);
            charCrud.deleteCharacteristics(charType, skyGroupId);

            log.info("Creating charactieristics for " + charTypeName
                + ", for skyGroupId " + skyGroupId);
            for (ObservedTarget target : observedTargets) {
                double value;
                switch (tadProductType) {
                    case SIGNAL_TO_NOISE_RATIO:
                        value = target.getSignalToNoiseRatio();
                        break;
                    case CROWDING:
                        value = target.getCrowdingMetric();
                        break;
                    case FLUX_FRACTION_IN_APERTURE:
                        value = target.getFluxFractionInAperture();
                        break;
                    case DISTANCE_FROM_EDGE:
                        value = target.getDistanceFromEdge();
                        break;
                    case SKY_CROWDING:
                        value = target.getSkyCrowdingMetric();
                        break;
                    default:
                        throw new IllegalArgumentException(
                            "Unexpected tad product type: " + tadProductType);
                }

                Characteristic c = new Characteristic(target.getKeplerId(),
                    charType, value);

                charCrud.create(c);
            }
        }
    }

}
