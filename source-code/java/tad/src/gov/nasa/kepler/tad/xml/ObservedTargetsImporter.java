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

package gov.nasa.kepler.tad.xml;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newLinkedHashMap;
import static com.google.common.collect.Sets.newLinkedHashSet;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.observedTargets.ApertureOffsetXB;
import gov.nasa.kepler.observedTargets.ApertureXB;
import gov.nasa.kepler.observedTargets.ObservedTargetXB;
import gov.nasa.kepler.observedTargets.ObservedTargetsDocument;
import gov.nasa.kepler.observedTargets.ObservedTargetsXB;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModule;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlObject;
import org.apache.xmlbeans.XmlOptions;

/**
 * Imports fields of {@link ObservedTarget} that are produced by
 * {@link CoaPipelineModule}.
 * 
 * @author Miles Cote
 * 
 */
public class ObservedTargetsImporter implements Runnable {

    private static final Log log = LogFactory.getLog(ObservedTargetsImporter.class);

    static final String VALIDATION_ENABLED_PROP_NAME = "tad.ObservedTargetsImporter.validationEnabled";

    private final TargetCrud targetCrud;
    private final DatabaseService databaseService;
    private final File srcFile;
    private final TargetListSet destTargetListSet;
    private final ModuleOutputListsParameters moduleOutputListsParameters;

    public ObservedTargetsImporter(File srcFile,
        TargetListSet destTargetListSet,
        ModuleOutputListsParameters moduleOutputListsParameters) {
        this(new TargetCrud(), DatabaseServiceFactory.getInstance(), srcFile,
            destTargetListSet, moduleOutputListsParameters);
    }

    ObservedTargetsImporter(TargetCrud targetCrud,
        DatabaseService databaseService, File srcFile,
        TargetListSet destTargetListSet,
        ModuleOutputListsParameters moduleOutputListsParameters) {
        this.targetCrud = targetCrud;
        this.databaseService = databaseService;
        this.srcFile = srcFile;
        this.destTargetListSet = destTargetListSet;
        this.moduleOutputListsParameters = moduleOutputListsParameters;
    }

    @Override
    public void run() {
        List<ModOut> modOuts = newArrayList();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                if (moduleOutputListsParameters.included(ccdModule, ccdOutput)) {
                    modOuts.add(ModOut.of(ccdModule, ccdOutput));
                }
            }
        }

        XmlObject xmlObject;
        try {
            xmlObject = XmlObject.Factory.parse(srcFile);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to parse.", e);
        }

        ObservedTargetsDocument doc;
        if (xmlObject instanceof ObservedTargetsDocument) {
            doc = (ObservedTargetsDocument) xmlObject;
        } else {
            throw new IllegalArgumentException(
                "Unexpected file type.\n  fileType: " + xmlObject.getClass());
        }

        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new IllegalArgumentException("XML validation error.  "
                + errors);
        }

        ObservedTargetsXB observedTargetsXB = doc.getObservedTargets();
        Set<Integer> keplerIdsInTls = newLinkedHashSet();

        Map<Integer, ObservedTargetXB> keplerIdToObservedTargetXB = newLinkedHashMap();
        for (ObservedTargetXB observedTargetXB : observedTargetsXB.getObservedTargetArray()) {
            keplerIdToObservedTargetXB.put(observedTargetXB.getKeplerId(),
                observedTargetXB);
        }

        TargetTable targetTable = destTargetListSet.getTargetTable();
        for (ModOut modOut : modOuts) {
            Integer ccdModule = modOut.getCcdModule();
            Integer ccdOutput = modOut.getCcdOutput();
            log.info("Importing observedTargets for modOut " + ccdModule + "/"
                + ccdOutput);

            List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
                targetTable, ccdModule, ccdOutput, true);
            for (ObservedTarget observedTarget : observedTargets) {
                int keplerIdFromTls = observedTarget.getKeplerId();
                keplerIdsInTls.add(keplerIdFromTls);

                ObservedTargetXB observedTargetXB = keplerIdToObservedTargetXB.get(keplerIdFromTls);
                if (observedTargetXB != null) {
                    ModOut modOutFromFile = ModOut.of(
                        observedTargetXB.getCcdModule(),
                        observedTargetXB.getCcdOutput());
                    ModOut modOutFromTls = ModOut.of(
                        observedTarget.getCcdModule(),
                        observedTarget.getCcdOutput());
                    if (!modOutFromFile.equals(modOutFromTls)) {
                        throw new IllegalArgumentException(
                            "The modOut from the file must equal the modOut from the tls.\n  keplerId: "
                                + observedTargetXB.getKeplerId()
                                + "\n  modOutFromFile: " + modOutFromFile
                                + "\n  modOutFromTls: " + modOutFromTls);
                    }

                    observedTarget.setAperturePixelCount(observedTargetXB.getAperturePixelCount());
                    observedTarget.setBadPixelCount(observedTargetXB.getBadPixelCount());
                    observedTarget.setSignalToNoiseRatio(observedTargetXB.getSignalToNoiseRatio());
                    observedTarget.setMagnitude(observedTargetXB.getMagnitude());
                    observedTarget.setRa(observedTargetXB.getRa());
                    observedTarget.setDec(observedTargetXB.getDec());
                    observedTarget.setEffectiveTemp(observedTargetXB.getEffectiveTemp());
                    observedTarget.setCrowdingMetric(observedTargetXB.getCrowdingMetric());
                    observedTarget.setSkyCrowdingMetric(observedTargetXB.getSkyCrowdingMetric());
                    observedTarget.setFluxFractionInAperture(observedTargetXB.getFluxFractionInAperture());
                    observedTarget.setDistanceFromEdge(observedTargetXB.getDistanceFromEdge());
                    observedTarget.setSaturatedRowCount(observedTargetXB.getSaturatedRowCount());

                    ApertureXB apertureXB = observedTargetXB.getAperture();

                    List<Offset> offsets = newArrayList();
                    for (ApertureOffsetXB apertureOffsetXB : apertureXB.getOffsetArray()) {
                        offsets.add(new Offset(apertureOffsetXB.getRow(),
                            apertureOffsetXB.getColumn()));
                    }

                    observedTarget.setAperture(new Aperture(
                        apertureXB.getUserDefined(),
                        apertureXB.getReferenceRow(),
                        apertureXB.getReferenceColumn(), offsets));
                }
            }

            databaseService.flush();
            databaseService.evictAll(observedTargets);
        }

        Set<Integer> keplerIdsInFile = newLinkedHashSet();
        for (ObservedTargetXB observedTargetXB : keplerIdToObservedTargetXB.values()) {
            keplerIdsInFile.add(observedTargetXB.getKeplerId());
        }

        boolean validationEnabled = ConfigurationServiceFactory.getInstance()
            .getBoolean(VALIDATION_ENABLED_PROP_NAME, true);
        if (validationEnabled && !keplerIdsInFile.equals(keplerIdsInTls)) {
            Set<Integer> keplerIdsInFileOrig = newLinkedHashSet(keplerIdsInFile);
            Set<Integer> keplerIdsInTlsOrig = newLinkedHashSet(keplerIdsInTls);

            keplerIdsInFile.removeAll(keplerIdsInTlsOrig);
            keplerIdsInTls.removeAll(keplerIdsInFileOrig);

            throw new IllegalArgumentException(
                "The keplerIds in the srcFile should equal the keplerIds in the destTargetListSet.\n"
                    + "To disable this validation and simply import targets that are in both sets, add this line to kepler.properties: "
                    + VALIDATION_ENABLED_PROP_NAME
                    + "=false.\n  keplerIds in srcFile but not in destTls: "
                    + keplerIdsInFile
                    + "\n  keplerIds in destTls but not in srcFile: "
                    + keplerIdsInTls);
        }
    }

    public static void main(String[] args) throws IOException, XmlException {
        if (args.length != 2) {
            System.err.println("USAGE: import-observed-targets SRC_FILE DEST_TARGET_LIST_SET_NAME");
            System.err.println("EXAMPLE: import-observed-targets "
                + "kplr2010078192810-quarter6_summer2010_trimmed_v3_lc_observed-targets.xml "
                + "quarter6_summer2010_trimmed_v3_lc");
            System.exit(-1);
        }

        String fileName = args[0];
        String tlsName = args[1];

        final File file = new File(fileName);
        if (!file.exists()) {
            throw new IllegalArgumentException(
                "The srcFile needs to exist.\n  fileName: " + fileName);
        }

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        final TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
        if (tls == null) {
            throw new IllegalArgumentException(
                "The destTargetListSet needs to exist in the database.\n  tlsName: "
                    + tlsName);
        }

        TransactionWrapper.run(new ObservedTargetsImporter(file, tls,
            new ModuleOutputListsParameters()));
    }

}
