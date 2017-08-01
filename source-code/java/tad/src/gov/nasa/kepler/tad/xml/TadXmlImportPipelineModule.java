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
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet; 
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.ObservedTargetFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.tad.operations.TadXmlImportParameters;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlException;

/**
 * This {@link PipelineModule} accepts as input a {@link TargetListSet} which
 * has only run through the {@link MergePipelineModule}, and populates the
 * {@link TargetListSet} as if it had run through the rest of the tad pipeline.
 * It does this by importing {@link TargetDefinition}s from tad xml files. This
 * class also marks all {@link TargetTable}s and {@link MaskTable}s as uplinked.
 * 
 * @author Miles Cote
 * 
 */
public class TadXmlImportPipelineModule extends PipelineModule {
    
    private static final Log log = LogFactory.getLog(TadXmlImportPipelineModule.class);

    static final boolean INCLUDE_NULL_APERTURES = true;

    private static final String VALIDATE_KEPLER_IDS_PROP_NAME = "tadXmlImport.validateKeplerIds";

    public static final String MODULE_NAME = "tadXmlImport";

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final MaskReaderFactory maskReaderFactory;
    private final TargetReaderFactory targetReaderFactory;
    private final ObservedTargetFactory observedTargetFactory;
    private final TadXmlFileOperations tadXmlFileOperations;
    private final RollTimeOperations rollTimeOperations;
    private final DatabaseService databaseService;

    public TadXmlImportPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(),
            new MaskReaderFactory(), new TargetReaderFactory(),
            new ObservedTargetFactory(), new TadXmlFileOperations(),
            new RollTimeOperations(), DatabaseServiceFactory.getInstance());
    }

    TadXmlImportPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud,
        MaskReaderFactory maskReaderFactory,
        TargetReaderFactory targetReaderFactory,
        ObservedTargetFactory observedTargetFactory,
        TadXmlFileOperations tadXmlFileOperations,
        RollTimeOperations rollTimeOperations, DatabaseService databaseService) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.maskReaderFactory = maskReaderFactory;
        this.targetReaderFactory = targetReaderFactory;
        this.observedTargetFactory = observedTargetFactory;
        this.tadXmlFileOperations = tadXmlFileOperations;
        this.rollTimeOperations = rollTimeOperations;
        this.databaseService = databaseService;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(TadParameters.class);
        requiredParams.add(TadXmlImportParameters.class);
        requiredParams.add(ModuleOutputListsParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        try {
            TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
            TadXmlImportParameters tadXmlImportParameters = pipelineTask.getParameters(TadXmlImportParameters.class);
            ModuleOutputListsParameters moduleOutputListsParameters = pipelineTask.getParameters(ModuleOutputListsParameters.class);

            String tlsName = tadParameters.getTargetListSetName();
            TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);

            File srcDir = new File(tadXmlImportParameters.getTadXmlAbsPath());
            ImportedMaskTable importedMaskTable;
            if (tls.getType() == TargetType.LONG_CADENCE) {
                // For long cadence, store the mask table, and store the
                // background target and mask tables.
                importedMaskTable = storeMaskData(pipelineTask, tls, srcDir);
                storeBackgroundTadData(pipelineTask,
                    moduleOutputListsParameters, tls, srcDir);
            } else {
                // For sc and rp, retrieve the mask table from the assocLcTls.
                String assocLcTlsName = tadParameters.getAssociatedLcTargetListSetName();
                TargetListSet assocLcTls = targetSelectionCrud.retrieveTargetListSet(assocLcTlsName);

                TargetCrud targetCrud = new TargetCrud();
                MaskTable maskTable = assocLcTls.getTargetTable()
                    .getMaskTable();
                List<Mask> masks = targetCrud.retrieveMasks(maskTable);

                importedMaskTable = new ImportedMaskTable(maskTable, masks);
            }

            storeTargetData(pipelineTask, tls, srcDir, importedMaskTable,
                tadXmlImportParameters.isValidateInputTargetsAgainstXmlTable());

            tls.setState(State.UPLINKED);

        } catch (Exception e) {
            throw new PipelineException("Unable to process task.", e);
        }
    }

    private ImportedMaskTable storeMaskData(PipelineTask pipelineTask,
        TargetListSet tls, File srcDir) {
        MaskType maskType = MaskType.TARGET;

        ImportedMaskTable targetMaskTable = importAndStoreMaskTable(
            pipelineTask, tls, srcDir, maskType);

        return targetMaskTable;
    }

    private ImportedMaskTable importAndStoreMaskTable(
        PipelineTask pipelineTask, TargetListSet tls, File srcDir,
        MaskType maskType) {
        File maskXmlFile = tadXmlFileOperations.getFile(srcDir,
            maskType.shortName(), tls);

        MaskReader maskReader = maskReaderFactory.create(maskXmlFile);
        ImportedMaskTable importedMaskTable = maskReader.read();

        validateMaskTable(importedMaskTable.getMaskTable());

        storeMaskTable(importedMaskTable, pipelineTask, maskXmlFile);

        return importedMaskTable;
    }

    private void storeMaskTable(ImportedMaskTable importedMaskTable,
        PipelineTask pipelineTask, File maskXmlFile) {
        MaskTable maskTable = importedMaskTable.getMaskTable();
        List<Mask> masks = importedMaskTable.getMasks();

        maskTable.setFileName(maskXmlFile.getName());

        maskTable.setState(State.UPLINKED);

        // Set the pipelineTask.
        for (Mask mask : masks) {
            mask.setPipelineTask(pipelineTask);
        }

        targetCrud.createMaskTable(maskTable);
        targetCrud.createMasks(masks);
    }

    private void validateMaskTable(MaskTable maskTable) {
        MaskTable existingUplinkedMaskTable = targetCrud.retrieveUplinkedMaskTable(
            maskTable.getExternalId(), maskTable.getType());

        if (existingUplinkedMaskTable != null) {
            throw new IllegalArgumentException(
                "The tad xml needs to not already exist in the database.\n  existingUplinkedMaskTable(externalId, type): "
                    + existingUplinkedMaskTable.getExternalId()
                    + ", "
                    + existingUplinkedMaskTable.getType());
        }
    }

    private void storeTargetData(PipelineTask pipelineTask, TargetListSet tls,
        File srcDir, ImportedMaskTable targetMaskTable,
        boolean validateInputTargetsAgainstXmlTable) throws XmlException,
        IOException {
        TargetType targetType = tls.getType();

        ImportedTargetTable importedTargetTable = importAndStoreTargetTable(
            pipelineTask, tls, srcDir, targetType, targetMaskTable);
        TargetTable newTargetTable = importedTargetTable.getTargetTable();
        List<TargetDefinition> lcTargetDefs = importedTargetTable.getTargetDefinitions();

        Map<Integer, List<TargetDefinition>> lcKeplerIdToTargetDefs = newHashMap();
        for (TargetDefinition targetDef : lcTargetDefs) {
            int keplerId = targetDef.getKeplerId();
            List<TargetDefinition> mappedTargetDefs = lcKeplerIdToTargetDefs.get(keplerId);
            if (mappedTargetDefs == null) {
                mappedTargetDefs = newArrayList();
                lcKeplerIdToTargetDefs.put(keplerId, mappedTargetDefs);
            }

            mappedTargetDefs.add(targetDef);
        }

        List<ObservedTarget> lcObservedTargets = targetCrud.retrieveObservedTargets(
            tls.getTargetTable(), INCLUDE_NULL_APERTURES);

        Configuration configService = ConfigurationServiceFactory.getInstance();
        if (configService.getBoolean(VALIDATE_KEPLER_IDS_PROP_NAME, true)) {
            if (!tls.getType()
                .equals(TargetType.REFERENCE_PIXEL)) {
                if (validateInputTargetsAgainstXmlTable) {
                    validateKeplerIds(lcObservedTargets, lcKeplerIdToTargetDefs);
                } else {
                    log.warn(
                        "Skipping validation of Kepler IDs per validateInputTargetsAgainstXmlTable parameter");
                }
            }
        }

        for (ObservedTarget lcObservedTarget : lcObservedTargets) {
            List<TargetDefinition> targetDefs = lcKeplerIdToTargetDefs.get(lcObservedTarget.getKeplerId());
            if (targetDefs != null) {
                lcObservedTarget.setTargetDefinitions(targetDefs);
            } else {
                // No targetDefs imported for this keplerId.
                lcObservedTarget.setRejected(true);
            }

            lcObservedTarget.setTargetTable(newTargetTable);

            Aperture aperture = lcObservedTarget.getAperture();
            if (aperture != null) {
                aperture.setTargetTable(newTargetTable);
            }
        }

        TargetTable oldTargetTable = tls.getTargetTable();

        tls.setTargetTable(newTargetTable);

        databaseService.flush();

        targetCrud.delete(oldTargetTable);
    }

    private ImportedTargetTable importAndStoreTargetTable(
        PipelineTask pipelineTask, TargetListSet tls, File srcDir,
        TargetType targetType, ImportedMaskTable importedMaskTable) {
        File targetXmlFile = tadXmlFileOperations.getFile(srcDir,
            targetType.shortName(), tls);

        TargetReader targetReader = targetReaderFactory.create(targetXmlFile);
        ImportedTargetTable importedTargetTable = targetReader.read();

        validateTargetTable(importedTargetTable.getTargetTable());

        importedTargetTable.getTargetTable()
            .setMaskTable(importedMaskTable.getMaskTable());

        storeTargetTable(importedTargetTable, pipelineTask, targetXmlFile);

        for (TargetDefinition targetDefinition : importedTargetTable.getTargetDefinitions()) {
            int indexInTable = targetDefinition.getMask()
                .getIndexInTable();
            targetDefinition.setMask(importedMaskTable.getMasks()
                .get(indexInTable));
        }

        return importedTargetTable;
    }

    private void storeTargetTable(ImportedTargetTable importedTargetTable,
        PipelineTask pipelineTask, File targetXmlFile) {
        TargetTable targetTable = importedTargetTable.getTargetTable();
        List<TargetDefinition> targetDefinitions = importedTargetTable.getTargetDefinitions();

        Date startTime = targetTable.getPlannedStartTime();

        // Verify that all of the dates are in the same season.
        ModifiedJulianDate startMjd = new ModifiedJulianDate(
            startTime.getTime());
        int startSeason = rollTimeOperations.mjdToSeason(startMjd.getMjd());

        targetTable.setObservingSeason(startSeason);

        targetTable.setFileName(targetXmlFile.getName());

        targetTable.setState(State.UPLINKED);

        // Set the pipelineTask.
        for (TargetDefinition targetDefinition : targetDefinitions) {
            targetDefinition.setPipelineTask(pipelineTask);
        }

        targetCrud.createTargetTable(targetTable);
    }

    private void validateTargetTable(TargetTable targetTable) {
        TargetTable existingUplinkedTargetTable = targetCrud.retrieveUplinkedTargetTable(
            targetTable.getExternalId(), targetTable.getType());

        if (existingUplinkedTargetTable != null) {
            throw new IllegalArgumentException(
                "The tad xml needs to not already exist in the database.\n  existingUplinkedTargetTable(externalId, type): "
                    + existingUplinkedTargetTable.getExternalId()
                    + ", "
                    + existingUplinkedTargetTable.getType());
        }
    }

    private void validateKeplerIds(List<ObservedTarget> lcObservedTargets,
        Map<Integer, List<TargetDefinition>> lcKeplerIdToTargetDefs) {
        Set<Integer> targetDefKeplerIds = lcKeplerIdToTargetDefs.keySet();

        Set<Integer> observedTargetKeplerIds = newHashSet();
        for (ObservedTarget lcObservedTarget : lcObservedTargets) {
            observedTargetKeplerIds.add(lcObservedTarget.getKeplerId());
        }

        for (Integer observedTargetKeplerId : observedTargetKeplerIds) {
            if (!targetDefKeplerIds.contains(observedTargetKeplerId)) {
                throw new IllegalArgumentException(
                    "keplerIds in the target list set need to be in the tad xml.\n  tlsKeplerId: "
                        + observedTargetKeplerId);
            }
        }

        for (Integer targetDefKeplerId : targetDefKeplerIds) {
            if (!observedTargetKeplerIds.contains(targetDefKeplerId)) {
                throw new IllegalArgumentException(
                    "keplerIds in the tad xml need to be in the target list set.\n  tadXmlKeplerId: "
                        + targetDefKeplerId);
            }
        }
    }

    private void storeBackgroundTadData(PipelineTask pipelineTask,
        ModuleOutputListsParameters moduleOutputListsParameters,
        TargetListSet tls, File srcDir) throws XmlException, IOException {
        MaskType maskType = MaskType.BACKGROUND;

        ImportedMaskTable backgroundMaskTable = importAndStoreMaskTable(
            pipelineTask, tls, srcDir, maskType);

        TargetType targetType = TargetType.BACKGROUND;

        ImportedTargetTable importedTargetTable = importAndStoreTargetTable(
            pipelineTask, tls, srcDir, targetType, backgroundMaskTable);
        TargetTable backgroundTable = importedTargetTable.getTargetTable();
        List<TargetDefinition> backgroundTargetDefs = importedTargetTable.getTargetDefinitions();

        // Create and store Targets.
        List<ObservedTarget> targets = newArrayList();
        for (TargetDefinition targetDef : backgroundTargetDefs) {
            ModOut modOut = targetDef.getModOut();
            if (moduleOutputListsParameters.included(modOut.getCcdModule(),
                modOut.getCcdOutput())) {
                ObservedTarget target = observedTargetFactory.create(
                    backgroundTable, modOut,
                    TargetManagementConstants.INVALID_KEPLER_ID);
                target.setPipelineTask(pipelineTask);

                target.getTargetDefinitions()
                    .add(targetDef);
                target.setTargetDefsPixelCount(target.getTargetDefsPixelCount()
                    + targetDef.getMask()
                        .getOffsets()
                        .size());

                targets.add(target);
            }
        }

        tls.setBackgroundTable(backgroundTable);

        targetCrud.createObservedTargets(targets);
    }

}
