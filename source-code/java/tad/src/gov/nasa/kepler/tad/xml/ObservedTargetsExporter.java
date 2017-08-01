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
import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
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
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Exports fields of {@link ObservedTarget} that are produced by
 * {@link CoaPipelineModule}.
 * 
 * @author Miles Cote
 * 
 */
public class ObservedTargetsExporter {

    private static final Log log = LogFactory.getLog(ObservedTargetsExporter.class);

    private final TargetCrud targetCrud;
    private final ModuleOutputListsParameters moduleOutputListsParameters;

    private final DatabaseService databaseService;

    public ObservedTargetsExporter(TargetCrud targetCrud,
        ModuleOutputListsParameters moduleOutputListsParameters,
        DatabaseService databaseService) {
        this.targetCrud = targetCrud;
        this.moduleOutputListsParameters = moduleOutputListsParameters;
        this.databaseService = databaseService;
    }

    public File exportObservedTargets(TargetListSet srcTargetListSet)
        throws IOException {
        List<ModOut> modOuts = newArrayList();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                if (moduleOutputListsParameters.included(ccdModule, ccdOutput)) {
                    modOuts.add(ModOut.of(ccdModule, ccdOutput));
                }
            }
        }

        ObservedTargetsDocument doc = ObservedTargetsDocument.Factory.newInstance();
        ObservedTargetsXB observedTargetsXB = doc.addNewObservedTargets();

        TargetTable targetTable = srcTargetListSet.getTargetTable();
        for (ModOut modOut : modOuts) {
            Integer ccdModule = modOut.getCcdModule();
            Integer ccdOutput = modOut.getCcdOutput();
            log.info("Exporting observedTargets for modOut " + ccdModule + "/"
                + ccdOutput);

            List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
                targetTable, ccdModule, ccdOutput);
            for (ObservedTarget observedTarget : observedTargets) {
                ObservedTargetXB observedTargetXB = observedTargetsXB.addNewObservedTarget();
                observedTargetXB.setKeplerId(observedTarget.getKeplerId());
                observedTargetXB.setCcdModule(observedTarget.getCcdModule());
                observedTargetXB.setCcdOutput(observedTarget.getCcdOutput());
                observedTargetXB.setAperturePixelCount(observedTarget.getAperturePixelCount());
                observedTargetXB.setBadPixelCount(observedTarget.getBadPixelCount());
                observedTargetXB.setSignalToNoiseRatio(observedTarget.getSignalToNoiseRatio());
                observedTargetXB.setMagnitude(observedTarget.getMagnitude());
                observedTargetXB.setRa(observedTarget.getRa());
                observedTargetXB.setDec(observedTarget.getDec());
                observedTargetXB.setEffectiveTemp(observedTarget.getEffectiveTemp());
                observedTargetXB.setCrowdingMetric(observedTarget.getCrowdingMetric());
                observedTargetXB.setSkyCrowdingMetric(observedTarget.getSkyCrowdingMetric());
                observedTargetXB.setFluxFractionInAperture(observedTarget.getFluxFractionInAperture());
                observedTargetXB.setDistanceFromEdge(observedTarget.getDistanceFromEdge());
                observedTargetXB.setSaturatedRowCount(observedTarget.getSaturatedRowCount());

                Aperture aperture = observedTarget.getAperture();
                ApertureXB apertureXB = observedTargetXB.addNewAperture();
                apertureXB.setUserDefined(aperture.isUserDefined());
                apertureXB.setReferenceRow(aperture.getReferenceRow());
                apertureXB.setReferenceColumn(aperture.getReferenceColumn());

                for (Offset offset : aperture.getOffsets()) {
                    ApertureOffsetXB apertureOffsetXB = apertureXB.addNewOffset();
                    apertureOffsetXB.setRow(offset.getRow());
                    apertureOffsetXB.setColumn(offset.getColumn());
                }
            }

            databaseService.flush();
            databaseService.evictAll(observedTargets);
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);

        List<XmlError> errors = newArrayList();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new IllegalArgumentException("XML validation error.  "
                + errors);
        }

        File file = new File("kplr" + DateUtils.formatLikeDmc(new Date()) + "-"
            + srcTargetListSet.getName() + "_observed-targets.xml");
        doc.save(file, xmlOptions);

        return file;
    }

    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("USAGE: export-observed-targets TARGET_LIST_SET_NAME");
            System.err.println("EXAMPLE: export-observed-targets quarter6_summer2010_trimmed_v3_lc");
            System.exit(-1);
        }

        String tlsName = args[0];

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
        if (tls == null) {
            throw new IllegalArgumentException(
                "The targetListSet needs to exist in the database.\n  tlsName: "
                    + tlsName);
        }

        ObservedTargetsExporter exporter = new ObservedTargetsExporter(
            new TargetCrud(), new ModuleOutputListsParameters(),
            DatabaseServiceFactory.getInstance());
        File file = exporter.exportObservedTargets(tls);

        System.out.println("Completed export to file: "
            + file.getAbsolutePath());

        System.exit(0);
    }

}
