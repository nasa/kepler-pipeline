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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class validates that a new tad run with new {@link Aperture}s is
 * compatible with a historical tad run which was sent to the spacecraft.
 * 
 * @author Miles Cote
 * 
 */
public class TargetTableComparator {

    private static final Log log = LogFactory.getLog(TargetTableComparator.class);

    private TargetCrud targetCrud = new TargetCrud();
    private ClipReportFactory clipReportFactory = new ClipReportFactory();

    public int validate(TargetTable oldTargetTable, TargetTable newTargetTable,
        int ccdModule, int ccdOutput) {
        return validate(oldTargetTable, newTargetTable, ccdModule, ccdOutput,
            false);
    }

    public int validate(TargetTable oldTargetTable, TargetTable newTargetTable,
        int ccdModule, int ccdOutput, boolean commandLineMode) {

        List<ObservedTarget> oldObservedTargets = retrieveNonCustomObservedTargets(
            oldTargetTable, ccdModule, ccdOutput);

        List<ObservedTarget> newObservedTargets = retrieveNonCustomObservedTargets(
            newTargetTable, ccdModule, ccdOutput);

        int clippedTargetCount = validate(oldTargetTable, oldObservedTargets,
            newTargetTable, newObservedTargets, commandLineMode);

        if (clippedTargetCount > 0) {
            String warningMsg = "mod/out: " + ccdModule + "/" + ccdOutput
                + " has " + clippedTargetCount + "/"
                + oldObservedTargets.size() + " targets with clipped optAps";
            log.warn(warningMsg);
        }

        return clippedTargetCount;
    }

    public int validate(TargetTable oldTargetTable,
        List<ObservedTarget> oldObservedTargets, TargetTable newTargetTable,
        List<ObservedTarget> newObservedTargets, boolean commandLineMode) {
        if (oldTargetTable.getObservingSeason() != newTargetTable.getObservingSeason()) {
            log.warn("oldTargetTable and newTargetTable must have the same observing season.\n  oldObservingSeason: "
                + oldTargetTable.getObservingSeason()
                + "\n  newObservingSeason: "
                + newTargetTable.getObservingSeason());
        }

        if (oldObservedTargets.size() != newObservedTargets.size()) {
            log.warn("oldTargetTable and newTargetTable must have the same number of ObservedTargets.\n  oldObservedTargetCount: "
                + oldObservedTargets.size()
                + "\n  newObservedTargetCount: "
                + newObservedTargets.size());
        }

        Map<Integer, ObservedTarget> oldKeplerIdToObservedTargetMap = new HashMap<Integer, ObservedTarget>();
        for (ObservedTarget oldObservedTarget : oldObservedTargets) {
            if (!newObservedTargets.contains(oldObservedTarget)) {
                log.warn("All oldObservedTargets must be included in the newObservedTargets.\n  oldObservedTargetNotInNewObservedTargets: "
                    + oldObservedTarget.getKeplerId());
            }

            oldKeplerIdToObservedTargetMap.put(oldObservedTarget.getKeplerId(),
                oldObservedTarget);
        }

        Map<Integer, ObservedTarget> newKeplerIdToObservedTargetMap = new HashMap<Integer, ObservedTarget>();
        for (ObservedTarget newObservedTarget : newObservedTargets) {
            if (!oldObservedTargets.contains(newObservedTarget)) {
                log.warn("All newObservedTargets must be included in the oldObservedTargets.\n  newObservedTargetNotInOldObservedTargets: "
                    + newObservedTarget.getKeplerId());
            }

            newKeplerIdToObservedTargetMap.put(newObservedTarget.getKeplerId(),
                newObservedTarget);
        }

        int clippedTargetCount = 0;

        for (ObservedTarget newObservedTarget : newKeplerIdToObservedTargetMap.values()) {
            if (newObservedTarget.getAperture() != null) {
                ObservedTarget oldObservedTarget = oldKeplerIdToObservedTargetMap.get(newObservedTarget.getKeplerId());
                if (oldObservedTarget != null) {
                    ClipReport clipReport = clipReportFactory.create(
                        oldObservedTarget.getTargetDefinitions(),
                        newObservedTarget.getAperture());

                    if (clipReport.getClippedOptApPixels() > 0) {
                        clippedTargetCount++;
                        if (commandLineMode) {
                            log.warn("KepId: "
                                + oldObservedTarget.getKeplerId() + ": "
                                + clipReport.getClippedOptApPixels() + "/"
                                + clipReport.getTotalOptApPixels()
                                + " new optAp pixels clipped by old mask");
                        }
                    }
                }
            }
        }

        return clippedTargetCount;
    }

    private List<ObservedTarget> retrieveNonCustomObservedTargets(
        TargetTable targetTable, int ccdModule, int ccdOutput) {
        List<ObservedTarget> observedTargetsWithCustom = targetCrud.retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            targetTable, ccdModule, ccdOutput, false);
        List<ObservedTarget> observedTargets = new ArrayList<ObservedTarget>();
        for (ObservedTarget observedTarget : observedTargetsWithCustom) {
            if (!TargetManagementConstants.isCustomTarget(observedTarget.getKeplerId())) {
                observedTargets.add(observedTarget);
            }
        }

        return observedTargets;
    }

    public void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("USAGE: compare-target-tables OLD_TLS_NAME NEW_TLS_NAME");
            System.exit(-1);
        }

        final String oldTlsName = args[0];
        final String newTlsName = args[1];

        TransactionWrapper.run(new Runnable() {
            @Override
            public void run() {
                TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
                TargetListSet oldTls = targetSelectionCrud.retrieveTargetListSet(oldTlsName);
                TargetListSet newTls = targetSelectionCrud.retrieveTargetListSet(newTlsName);

                int totalClippedTargets = 0;

                for (int ccdModule : FcConstants.modulesList) {
                    for (int ccdOutput : FcConstants.outputsList) {
                        log.info("Validating mod/out " + ccdModule + "/"
                            + ccdOutput);

                        TargetTableComparator validator = new TargetTableComparator();
                        totalClippedTargets += validator.validate(
                            oldTls.getTargetTable(), newTls.getTargetTable(),
                            ccdModule, ccdOutput, true);
                    }
                }

                if (totalClippedTargets > 0) {
                    log.warn("A total of "
                        + totalClippedTargets
                        + " targets had optAps that were clipped by the original mask");
                }
            }
        });
    }

}
