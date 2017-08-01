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

package gov.nasa.kepler.tad.peer.ama;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.tad.peer.ApertureStruct;
import gov.nasa.kepler.tad.peer.ApertureStructFactory;
import gov.nasa.kepler.tad.peer.KeplerIdMap;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.MaskDefinitionFactory;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.kepler.tad.peer.TargetDefinitionStruct;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

/**
 * Performs AMA.
 * 
 * @author Miles Cote
 */
public class AmaPipelineModule extends MatlabPipelineModule {

    public static final String MODULE_NAME = "ama";
    static final int REJECTED_STATUS = -2;
    private static final Log log = LogFactory.getLog(AmaPipelineModule.class);

    private PipelineTask pipelineTask;
    private TargetListSet targetListSet;
    private TargetListSet associatedLcTargetListSet;
    private List<Mask> masks;
    private List<ObservedTarget> observedTargets;
    private List<TargetDefinition> targetDefinitions = newArrayList();

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final PersistableFactory persistableFactory;
    private final MaskDefinitionFactory maskDefinitionFactory;
    private final ApertureStructFactory apertureStructFactory;

    public AmaPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(),
            new PersistableFactory(), new MaskDefinitionFactory(),
            new ApertureStructFactory());
    }

    AmaPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud,
        PersistableFactory persistableFactory,
        MaskDefinitionFactory maskDefinitionFactory,
        ApertureStructFactory apertureStructFactory) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.persistableFactory = persistableFactory;
        this.maskDefinitionFactory = maskDefinitionFactory;
        this.apertureStructFactory = apertureStructFactory;
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
        return ImmutableList.of(TadParameters.class, AmaModuleParameters.class,
            MaskTableParameters.class);
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;

        retrieveTargetListSets();

        TargetType type = targetListSet.getType();
        switch (type) {
            case LONG_CADENCE:
                generateTargetDefinitions();
                break;
            case SHORT_CADENCE:
                copyLcTargetDefinitions();
                break;
            default:
                throw new ModuleFatalProcessingException("Unexpected type."
                    + "\n  type: " + type);
        }
    }

    private void retrieveTargetListSets() {
        TadParameters tadParameters = pipelineTask.getParameters(TadParameters.class);
        targetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getTargetListSetName());
        if (tadParameters.getAssociatedLcTargetListSetName() != null) {
            associatedLcTargetListSet = targetSelectionCrud.retrieveTargetListSet(tadParameters.getAssociatedLcTargetListSetName());
        }

        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }
    }

    private void generateTargetDefinitions() {
        AmaInputs amaInputs = persistableFactory.create(AmaInputs.class);

        retrieveInputs(amaInputs);

        if (!amaInputs.getApertureStructs()
            .isEmpty()) {
            AmaOutputs amaOutputs = persistableFactory.create(AmaOutputs.class);

            executeAlgorithm(pipelineTask, amaInputs, amaOutputs);

            storeOutputs(amaOutputs);
        }
    }

    private void retrieveInputs(AmaInputs amaInputs) {
        amaInputs.setAmaConfigurationStruct(pipelineTask.getParameters(AmaModuleParameters.class));
        amaInputs.setMaskTableParametersStruct(pipelineTask.getParameters(MaskTableParameters.class));

        log.info("Retrieving masks...");
        amaInputs.setMaskDefinitions(retrieveMaskDefinitions());

        log.info("Retrieving apertures...");
        amaInputs.setApertureStructs(retrieveApertureStructs());
    }

    private List<MaskDefinition> retrieveMaskDefinitions() {
        retrieveMasks();

        List<MaskDefinition> maskDefinitions = newArrayList();
        for (Mask mask : masks) {
            maskDefinitions.add(maskDefinitionFactory.create(mask));
        }

        return maskDefinitions;
    }

    private void retrieveMasks() {
        MaskTable maskTable = targetListSet.getTargetTable()
            .getMaskTable();

        masks = targetCrud.retrieveMasks(maskTable);
        if (masks.isEmpty()) {
            throw new ModuleFatalProcessingException("masks cannot be empty."
                + "\n  targetListSet: " + targetListSet);
        }
    }

    private List<ApertureStruct> retrieveApertureStructs() {
        retrieveObservedTargets();

        List<ApertureStruct> apertures = newArrayList();
        for (ObservedTarget target : observedTargets) {
            apertures.add(apertureStructFactory.create(target));
        }

        return apertures;
    }

    private void retrieveObservedTargets() {
        List<ObservedTarget> retrievedObservedTargets = targetCrud.retrieveObservedTargetsPlusRejected(targetListSet.getTargetTable());
        if (retrievedObservedTargets.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "observedTargets cannot be empty." + "\n  targetListSet: "
                    + targetListSet);
        }

        rejectTargetsWithNullAperture(retrievedObservedTargets);

        observedTargets = newArrayList();
        for (ObservedTarget observedTarget : retrievedObservedTargets) {
            if (needsTargetDefinitions(observedTarget)) {
                observedTargets.add(observedTarget);
            }
        }
    }

    private void rejectTargetsWithNullAperture(
        List<ObservedTarget> observedTargets) {
        for (ObservedTarget observedTarget : observedTargets) {
            if (observedTarget.getAperture() == null) {
                observedTarget.setRejected(true);
            }
        }
    }

    private boolean needsTargetDefinitions(ObservedTarget observedTarget) {
        return !observedTarget.isRejected()
            && observedTarget.getTargetDefinitions()
                .isEmpty();
    }

    private void storeOutputs(AmaOutputs amaOutputs) {
        log.info("Storing target definitions...");
        storeTargetDefinitions(amaOutputs);

        log.info("Storing masks...");
        storeMasks(amaOutputs);
    }

    private void storeTargetDefinitions(AmaOutputs amaOutputs) {
        Map<Integer, ObservedTarget> keplerIdToObservedTarget = KeplerIdMap.of(observedTargets);

        for (TargetDefinitionStruct targetDefinitionStruct : amaOutputs.getTargetDefinitions()) {
            ObservedTarget observedTarget = keplerIdToObservedTarget.get(targetDefinitionStruct.getKeplerId());
            if (observedTarget != null) {
                updateObservedTarget(amaOutputs, targetDefinitionStruct,
                    observedTarget);
            }
        }

        setUsedMasks(amaOutputs);

        setTargetDefinitionIndices();
    }

    private void setUsedMasks(AmaOutputs amaOutputs) {
        for (int i = 0; i < masks.size(); i++) {
            boolean used = amaOutputs.getUsedMasks()[i];
            masks.get(i)
                .setUsed(used);
        }
    }

    private void setTargetDefinitionIndices() {
        for (List<TargetDefinition> channelTargetDefinitions : getChannelToTargetDefinitions().values()) {
            int index = 0;
            for (TargetDefinition targetDefinition : channelTargetDefinitions) {
                targetDefinition.setIndexInModuleOutput(index);
                index++;
            }
        }
    }

    private Map<Integer, List<TargetDefinition>> getChannelToTargetDefinitions() {
        Map<Integer, List<TargetDefinition>> channelToTargetDefinitions = newHashMap();
        for (TargetDefinition targetDefinition : targetDefinitions) {
            int channel = FcConstants.getChannelNumber(
                targetDefinition.getCcdModule(),
                targetDefinition.getCcdOutput());

            List<TargetDefinition> channelTargetDefinitions = channelToTargetDefinitions.get(channel);
            if (channelTargetDefinitions == null) {
                channelTargetDefinitions = newArrayList();
                channelToTargetDefinitions.put(channel,
                    channelTargetDefinitions);
            }

            channelTargetDefinitions.add(targetDefinition);
        }
        return channelToTargetDefinitions;
    }

    private void updateObservedTarget(AmaOutputs amaOutputs,
        TargetDefinitionStruct targetDefinitionStruct,
        ObservedTarget observedTarget) {
        int status = targetDefinitionStruct.getStatus();
        if (status != REJECTED_STATUS) {
            TargetDefinition targetDefinition = new TargetDefinition(
                observedTarget);
            targetDefinition.setPipelineTask(pipelineTask);
            targetDefinition.setMask(getMask(
                targetDefinitionStruct.getMaskIndex(), amaOutputs));
            targetDefinition.setReferenceColumn(targetDefinitionStruct.getReferenceColumn());
            targetDefinition.setReferenceRow(targetDefinitionStruct.getReferenceRow());
            targetDefinition.setExcessPixels(targetDefinitionStruct.getExcessPixels());
            targetDefinition.setStatus(status);

            observedTarget.getTargetDefinitions()
                .add(targetDefinition);
            observedTarget.setTargetDefsPixelCount(observedTarget.getTargetDefsPixelCount()
                + targetDefinition.getMask()
                    .getOffsets()
                    .size());

            targetDefinitions.add(targetDefinition);
        } else {
            observedTarget.setRejected(true);
        }
    }

    private void storeMasks(AmaOutputs amaOutputs) {
        MaskTable maskTable = targetListSet.getTargetTable()
            .getMaskTable();

        List<Mask> outputMasks = newArrayList();
        for (MaskDefinition maskDefinition : amaOutputs.getMaskDefinitions()) {
            Mask mask = maskDefinition.toMask(maskTable);
            outputMasks.add(mask);
        }

        for (int i = 0; i < masks.size(); i++) {
            Mask inputMask = masks.get(i);
            Mask outputMask = outputMasks.get(i);

            inputMask.setOffsets(outputMask.getOffsets());
        }
    }

    private void copyLcTargetDefinitions() {
        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargetsPlusRejected(targetListSet.getTargetTable());
        List<ObservedTarget> lcObservedTargets = targetCrud.retrieveObservedTargetsPlusRejected(associatedLcTargetListSet.getTargetTable());

        Map<Integer, ObservedTarget> keplerIdToLcObservedTarget = KeplerIdMap.of(lcObservedTargets);

        for (ObservedTarget observedTarget : observedTargets) {
            int keplerId = observedTarget.getKeplerId();
            ObservedTarget lcObservedTarget = keplerIdToLcObservedTarget.get(keplerId);
            if (lcObservedTarget == null) {
                throw new ModuleFatalProcessingException(
                    "observedTargets cannot be missing from the associatedLcTargetListSet."
                        + "\n  keplerId: " + keplerId
                        + "\n  targetListSetName: " + targetListSet
                        + "\n  associatedLcTargetListSet: "
                        + associatedLcTargetListSet);
            }

            for (TargetDefinition lcTargetDefinition : lcObservedTarget.getTargetDefinitions()) {
                TargetDefinition targetDefinition = new TargetDefinition();
                targetDefinition.setModOut(lcTargetDefinition.getModOut());
                targetDefinition.setExcessPixels(lcTargetDefinition.getExcessPixels());
                targetDefinition.setKeplerId(lcTargetDefinition.getKeplerId());
                targetDefinition.setMask(lcTargetDefinition.getMask());
                targetDefinition.setPipelineTask(pipelineTask);
                targetDefinition.setReferenceRow(lcTargetDefinition.getReferenceRow());
                targetDefinition.setReferenceColumn(lcTargetDefinition.getReferenceColumn());
                targetDefinition.setStatus(lcTargetDefinition.getStatus());
                targetDefinition.setTargetTable(targetListSet.getTargetTable());

                observedTarget.getTargetDefinitions()
                    .add(targetDefinition);
                targetDefinitions.add(targetDefinition);
            }
        }

        setTargetDefinitionIndices();
    }

    private Mask getMask(int maskIndex, AmaOutputs amaOutputs) {
        Mask mask;
        if (isNew(maskIndex)) {
            mask = createMask(amaOutputs, maskIndex);
        } else {
            mask = getExistingMask(maskIndex);
        }

        return mask;
    }

    private boolean isNew(int maskIndex) {
        return maskIndex >= masks.size();
    }

    private Mask createMask(AmaOutputs amaOutputs, int maskIndex) {
        MaskTable maskTable = targetListSet.getTargetTable()
            .getMaskTable();
        MaskDefinition maskDefinition = amaOutputs.getMaskDefinitions()
            .get(maskIndex);
        Mask mask = maskDefinition.toMask(maskTable);
        targetCrud.createMask(mask);
        return mask;
    }

    private Mask getExistingMask(int maskIndex) {
        Mask mask;
        mask = masks.get(maskIndex);
        return mask;
    }

}
