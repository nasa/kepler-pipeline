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

package gov.nasa.kepler.tad.peer.amt;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.tad.operations.TargetOperations;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.tad.peer.AmtModuleParameters;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.kepler.tad.xml.ImportedMaskTable;
import gov.nasa.kepler.tad.xml.MaskReader;
import gov.nasa.kepler.tad.xml.MaskReaderFactory;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import com.google.common.collect.ImmutableList;

/**
 * Performs AMT
 * 
 * @author Miles Cote
 */
public class AmtPipelineModule extends MatlabPipelineModule {

    public static final String MODULE_NAME = "amt";

    private PipelineTask pipelineTask;
    private TadParameters tadParameters;

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private FileStoreClient fileStoreClient;
    private final MaskReaderFactory maskReaderFactory;
    private final TargetOperations targetOperations;
    private final PersistableFactory persistableFactory;

    public AmtPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(), null,
            new MaskReaderFactory(), new TargetOperations(),
            new PersistableFactory());
    }

    AmtPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud,
        FileStoreClient fileStoreClient, MaskReaderFactory maskReaderFactory,
        TargetOperations targetOperations, PersistableFactory persistableFactory) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.fileStoreClient = fileStoreClient;
        this.maskReaderFactory = maskReaderFactory;
        this.targetOperations = targetOperations;
        this.persistableFactory = persistableFactory;
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
        return ImmutableList.of(TadParameters.class, AmtModuleParameters.class,
            AmaModuleParameters.class, MaskTableParameters.class,
            ModuleOutputListsParameters.class);
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        if (fileStoreClient == null) {
            fileStoreClient = FileStoreClientFactory.getInstance();
        }

        this.pipelineTask = pipelineTask;
        tadParameters = pipelineTask.getParameters(TadParameters.class);

        retrieveTargetListSet();

        AmtModuleParameters amtModuleParameters = pipelineTask.getParameters(AmtModuleParameters.class);
        String maskTableCopySourceTlsName = amtModuleParameters.getMaskTableCopySourceTargetListSetName();
        String maskTableImportSourceFileName = amtModuleParameters.getMaskTableImportSourceFileName();

        checkMaskTableSources(maskTableCopySourceTlsName,
            maskTableImportSourceFileName);

        if (maskTableCopySourceTlsName != null
            && !maskTableCopySourceTlsName.isEmpty()) {
            copyMaskTable(maskTableCopySourceTlsName);
        } else if (maskTableImportSourceFileName != null
            && !maskTableImportSourceFileName.isEmpty()) {
            importMaskTable(maskTableImportSourceFileName);
        } else {
            generateMaskTable();
        }
    }

    private void retrieveTargetListSet() {
        TargetListSet targetListSet = tadParameters.targetListSet();

        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        if (targetListSet.getType() != TargetType.LONG_CADENCE) {
            throw new ModuleFatalProcessingException(MODULE_NAME
                + " must run on a " + TargetType.LONG_CADENCE
                + " targetListSet.\n  targetType: " + targetListSet.getType()
                + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        MaskTable maskTable = tadParameters.maskTable();
        if (maskTable.getState() == State.UPLINKED) {
            throw new ModuleFatalProcessingException(
                TargetOperations.getUplinkedMaskTableErrorText(maskTable)
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }
    }

    private void checkMaskTableSources(String maskTableCopySourceTlsName,
        String maskTableImportSourceFileName) {
        if (maskTableCopySourceTlsName != null
            && !maskTableCopySourceTlsName.isEmpty()
            && maskTableImportSourceFileName != null
            && !maskTableImportSourceFileName.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "Only one of maskTableCopySourceTlsName and maskTableImportSourceFileName can be set at a time.\n  maskTableCopySourceTlsName: "
                    + maskTableCopySourceTlsName
                    + "\n  maskTableImportSourceFileName: "
                    + maskTableImportSourceFileName
                    + TargetListSetOperations.getTlsInfo(tadParameters.targetListSet()));
        }
    }

    private void copyMaskTable(String maskTableCopySourceTlsName) {
        TargetListSet targetListSet = tadParameters.targetListSet();

        TargetListSet maskTableCopySourceTls = targetSelectionCrud.retrieveTargetListSet(maskTableCopySourceTlsName);

        MaskTable newMaskTable = targetOperations.copy(
            maskTableCopySourceTls.getTargetTable()
                .getMaskTable(), pipelineTask);
        newMaskTable.setPlannedStartTime(targetListSet.getStart());
        newMaskTable.setPlannedEndTime(targetListSet.getEnd());

        tadParameters.targetTable()
            .setMaskTable(newMaskTable);
    }

    private void importMaskTable(String filename) {
        TargetListSet targetListSet = tadParameters.targetListSet();

        FsId fsId = DrFsIdFactory.getFile(DispatcherType.MASK_TABLE, filename);
        BlobResult blob = fileStoreClient.readBlob(fsId);

        MaskReader maskReader = maskReaderFactory.create(blob.data());

        ImportedMaskTable importedMaskTable = maskReader.read();
        importedMaskTable.getMaskTable()
            .setExternalId(ExportTable.INVALID_EXTERNAL_ID);
        importedMaskTable.getMaskTable()
            .setPlannedStartTime(targetListSet.getStart());
        importedMaskTable.getMaskTable()
            .setPlannedEndTime(targetListSet.getEnd());

        checkThatSupermasksWereNotImported(importedMaskTable.getMasks());

        for (Mask mask : importedMaskTable.getMasks()) {
            mask.setPipelineTask(pipelineTask);
        }

        MaskTableParameters maskTableParameters = pipelineTask.getParameters(MaskTableParameters.class);
        checkMaskCount(importedMaskTable, maskTableParameters);

        targetCrud.createMaskTable(importedMaskTable.getMaskTable());
        targetCrud.createMasks(importedMaskTable.getMasks());

        tadParameters.targetTable()
            .setMaskTable(importedMaskTable.getMaskTable());
    }

    private void checkThatSupermasksWereNotImported(List<Mask> masks) {
        ModuleOutputListsParameters moduleOutputListsParameters = pipelineTask.getParameters(ModuleOutputListsParameters.class);

        int modOutCount = 0;
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                if (moduleOutputListsParameters.included(ccdModule, ccdOutput)) {
                    modOutCount++;
                }
            }
        }

        int maxNonSupermasks = TargetManagementConstants.MAX_TARGET_APERTURES
            - TargetManagementConstants.RPTS_MASKS_PER_CHANNEL * modOutCount;
        if (masks.size() > maxNonSupermasks) {
            throw new PipelineException(
                "Imported mask tables must not contain more than "
                    + maxNonSupermasks
                    + " masks to allow room for rpts supermasks.\n  maskCount: "
                    + masks.size());
        }
    }

    private void checkMaskCount(ImportedMaskTable importedMaskTable,
        MaskTableParameters maskTableParameters) {
        int maskTableParametersTotalSum = maskTableParameters.getTotalSum();
        int importedMaskCount = importedMaskTable.getMasks()
            .size();
        if (maskTableParametersTotalSum != importedMaskCount) {
            throw new ModuleFatalProcessingException(
                "maskTableParametersTotalSum cannot differ from the importedMaskCount."
                    + "\n  maskTableParametersTotalSum: "
                    + maskTableParametersTotalSum + "\n  importedMaskCount: "
                    + importedMaskCount);
        }
    }

    private void generateMaskTable() {
        TargetListSet targetListSet = tadParameters.targetListSet();
        MaskTable maskTable = tadParameters.maskTable();

        maskTable.setPlannedStartTime(targetListSet.getStart());
        maskTable.setPlannedEndTime(targetListSet.getEnd());

        AmtInputs amtInputs = persistableFactory.create(AmtInputs.class);

        amtInputs.retrieveFor(pipelineTask);

        AmtOutputs amtOutputs = persistableFactory.create(AmtOutputs.class);

        executeAlgorithm(pipelineTask, amtInputs, amtOutputs);

        amtOutputs.storeFor(pipelineTask);
    }

}
