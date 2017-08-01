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

package gov.nasa.kepler.tad.peer.bpa;

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Image;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.ObservedTargetFactory;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.tad.peer.BpaModuleParameters;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.TargetDefinitionStruct;
import gov.nasa.kepler.tad.peer.bpasetup.BpaSetupPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

/**
 * Creates background {@link ObservedTarget}s and {@link TargetDefinition}s.
 * Preconditions: {@link BpaSetupPipelineModule} has run on the
 * {@link TargetListSet}. Postconditions: Background {@link TargetDefinition}s
 * are generated for the {@link TargetListSet}.
 * 
 * @author Miles Cote
 */
public class BpaPipelineModule extends MatlabPipelineModule {

    public static final String MODULE_NAME = "bpa";
    private static final Log log = LogFactory.getLog(BpaPipelineModule.class);

    private PipelineTask pipelineTask;
    private ModOut modOut;
    private TargetListSet targetListSet;
    private Image image;

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final PersistableFactory persistableFactory;
    private final ObservedTargetFactory observedTargetFactory;

    /**
     * Creates an instance of the 2x2 offset mask that BPA MATLAB uses. This
     * mask and the mask created in BPA MATLAB must be the same.
     * 
     * @return the {@link List} of {@link Offset}s for the 2x2 mask.
     */
    public static final List<Offset> theOfficialTwoByTwoOffsets() {
        return ImmutableList.of(new Offset(-1, -1), new Offset(-1, 0),
            new Offset(0, -1), new Offset(0, 0));
    }

    public BpaPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(),
            new PersistableFactory(), new ObservedTargetFactory());
    }

    BpaPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud,
        PersistableFactory persistableFactory,
        ObservedTargetFactory observedTargetFactory) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.persistableFactory = persistableFactory;
        this.observedTargetFactory = observedTargetFactory;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        return ImmutableList.of(TadParameters.class, BpaModuleParameters.class);
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;

        ModOutUowTask modOutUowTask = pipelineTask.uowTaskInstance();
        modOut = modOutUowTask.modOut();

        retrieveTargetListSet();

        retrieveImage();

        if (imageExists()) {
            generateTargetDefinitions();
        }
    }

    private void retrieveTargetListSet() {
        TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
        targetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());

        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        TargetType type = targetListSet.getType();
        if (type != TargetType.LONG_CADENCE) {
            throw new ModuleFatalProcessingException("type must be "
                + TargetType.LONG_CADENCE + "." + "\n  targetListSet: "
                + targetListSet + "\n  type: " + type);
        }
    }

    private void retrieveImage() {
        image = targetCrud.retrieveImage(targetListSet.getTargetTable(),
            modOut.getCcdModule(), modOut.getCcdOutput());
    }

    private boolean imageExists() {
        return image != null;
    }

    private void generateTargetDefinitions() {
        BpaInputs bpaInputs = persistableFactory.create(BpaInputs.class);

        retrieveInputs(bpaInputs);

        BpaOutputs bpaOutputs = persistableFactory.create(BpaOutputs.class);

        executeAlgorithm(pipelineTask, bpaInputs, bpaOutputs);

        storeOutputs(bpaOutputs);
    }

    private void retrieveInputs(BpaInputs bpaInputs) {
        bpaInputs.setModule(modOut.getCcdModule());
        bpaInputs.setOutput(modOut.getCcdOutput());

        bpaInputs.setBpaConfigurationStruct(retrieveBpaModuleParameters());

        bpaInputs.setModuleOutputImage(image.getModuleOutputImage());
    }

    private BpaModuleParameters retrieveBpaModuleParameters() {
        BpaModuleParameters bpaModuleParameters = pipelineTask.getParameters(BpaModuleParameters.class);
        bpaModuleParameters.setLineStartRow(image.getMinRow());
        bpaModuleParameters.setLineEndRow(image.getMaxRow());
        bpaModuleParameters.setLineStartCol(image.getMinCol());
        bpaModuleParameters.setLineEndCol(image.getMaxCol());

        return bpaModuleParameters;
    }

    private void storeOutputs(BpaOutputs bpaOutputs) {
        log.info("Storing target definitions...");
        storeTargetDefinitions(bpaOutputs);
    }

    private void storeTargetDefinitions(BpaOutputs bpaOutputs) {
        TargetTable backgroundTable = targetListSet.getBackgroundTable();
        MaskTable maskTable = backgroundTable.getMaskTable();
        List<Mask> masks = targetCrud.retrieveMasks(maskTable);

        checkMaskDefinitions(bpaOutputs, masks);

        storeTargetDefinitionStructs(bpaOutputs, backgroundTable, masks);
    }

    private void checkMaskDefinitions(BpaOutputs bpaOutputs, List<Mask> masks) {
        List<MaskDefinition> maskDefinitions = bpaOutputs.getMaskDefinitions();
        if (maskDefinitions.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "maskDefinitions cannot be empty.");
        }

        for (int i = 0; i < masks.size(); i++) {
            List<Offset> databaseOffsets = masks.get(i)
                .getOffsets();

            List<Offset> generatedOffsets = maskDefinitions.get(i)
                .toMask(null)
                .getOffsets();

            if (!databaseOffsets.equals(generatedOffsets)) {
                throw new ModuleFatalProcessingException(
                    "databaseOffsets cannot differ from generatedOffsets."
                        + "\n  databaseOffsets: " + databaseOffsets
                        + "\n  generatedOffsets: " + generatedOffsets);
            }
        }
    }

    private void storeTargetDefinitionStructs(BpaOutputs bpaOutputs,
        TargetTable backgroundTable, List<Mask> masks) {
        List<TargetDefinitionStruct> targetDefinitions = bpaOutputs.getTargetDefinitions();
        for (int i = 0; i < targetDefinitions.size(); i++) {
            TargetDefinitionStruct targetDefinitionStruct = targetDefinitions.get(i);

            ObservedTarget observedTarget = observedTargetFactory.create(
                backgroundTable, modOut,
                TargetManagementConstants.INVALID_KEPLER_ID);

            TargetDefinition targetDefinition = new TargetDefinition(
                observedTarget);
            targetDefinition.setPipelineTask(pipelineTask);
            targetDefinition.setMask(masks.get(targetDefinitionStruct.getMaskIndex()));
            targetDefinition.setIndexInModuleOutput(i);
            targetDefinition.setReferenceRow(targetDefinitionStruct.getReferenceRow());
            targetDefinition.setReferenceColumn(targetDefinitionStruct.getReferenceColumn());

            observedTarget.getTargetDefinitions()
                .add(targetDefinition);
            observedTarget.setTargetDefsPixelCount(observedTarget.getTargetDefsPixelCount()
                + targetDefinition.getMask()
                    .getOffsets()
                    .size());
            observedTarget.setPipelineTask(pipelineTask);

            targetCrud.createObservedTarget(observedTarget);
        }
    }

}
