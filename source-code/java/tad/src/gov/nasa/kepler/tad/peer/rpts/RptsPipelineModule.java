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

package gov.nasa.kepler.tad.peer.rpts;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
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
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.TargetListSetOperations;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.tad.operations.TargetOperations;
import gov.nasa.kepler.tad.peer.ApertureStruct;
import gov.nasa.kepler.tad.peer.ApertureStructFactory;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.MaskDefinitionFactory;
import gov.nasa.kepler.tad.peer.RptsModuleParameters;
import gov.nasa.kepler.tad.peer.TargetDefinitionStruct;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Creates reference pixel {@link TargetDefinition}s and {@link Mask}s.
 * Preconditions: {@link MergePipelineModule} has run on the
 * {@link TargetListSet}. Postconditions: Refernce pixel
 * {@link TargetDefinition}s and {@link Mask}s are generated for the
 * {@link TargetListSet}.
 * 
 * @author Miles Cote
 */
public class RptsPipelineModule extends MatlabPipelineModule {

    static final boolean INCLUDE_NULL_APERTURES = true;

    public static final String MODULE_NAME = "rpts";

    private PipelineTask pipelineTask;

    private ModOut modOut;
    private TargetListSet targetListSet;
    private TargetListSet associatedLcTargetListSet;
    private List<Mask> existingMasks;
    private Mask backgroundMask;
    private Mask blackMask;
    private Mask smearMask;
    private List<ObservedTarget> rpTargets;

    private static final Log log = LogFactory.getLog(RptsPipelineModule.class);

    private final TargetCrud targetCrud;
    private final TargetSelectionCrud targetSelectionCrud;
    private final ReadNoiseOperations readNoiseOperations;
    private final PersistableFactory persistableFactory;
    private final ApertureStructFactory apertureStructFactory;
    private final MaskDefinitionFactory maskDefinitionFactory;
    private final ObservedTargetFactory observedTargetFactory;

    public RptsPipelineModule() {
        this(new TargetCrud(), new TargetSelectionCrud(),
            new ReadNoiseOperations(), new PersistableFactory(),
            new ApertureStructFactory(), new MaskDefinitionFactory(),
            new ObservedTargetFactory());
    }

    RptsPipelineModule(TargetCrud targetCrud,
        TargetSelectionCrud targetSelectionCrud,
        ReadNoiseOperations readNoiseOperations,
        PersistableFactory persistableFactory,
        ApertureStructFactory apertureStructFactory,
        MaskDefinitionFactory maskDefinitionFactory,
        ObservedTargetFactory observedTargetFactory) {
        this.targetCrud = targetCrud;
        this.targetSelectionCrud = targetSelectionCrud;
        this.readNoiseOperations = readNoiseOperations;
        this.persistableFactory = persistableFactory;
        this.apertureStructFactory = apertureStructFactory;
        this.maskDefinitionFactory = maskDefinitionFactory;
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
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(TadParameters.class);
        requiredParams.add(RptsModuleParameters.class);
        requiredParams.add(PlannedSpacecraftConfigParameters.class);
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;

        validate();

        Persistable inputs = createInputs();

        retrieveInputs(inputs);

        RptsInputs rptsInputs = (RptsInputs) inputs;
        if (!rptsInputs.getStellarApertures()
            .isEmpty() || !rptsInputs.getDynamicRangeApertures()
            .isEmpty()) {
            Persistable outputs = createOutputs();

            executeAlgorithm(pipelineTask, inputs, outputs);

            storeOutputs(outputs);
        }
    }

    private void validate() {
        TadParameters params = pipelineTask.getParameters(TadParameters.class);
        targetListSet = targetSelectionCrud.retrieveTargetListSet(params.getTargetListSetName());
        if (params.getAssociatedLcTargetListSetName() != null) {
            associatedLcTargetListSet = targetSelectionCrud.retrieveTargetListSet(params.getAssociatedLcTargetListSetName());
        }

        log.info(TargetListSetOperations.getTlsInfo(targetListSet,
            associatedLcTargetListSet));

        if (targetListSet.getState() != State.LOCKED) {
            throw new ModuleFatalProcessingException(
                TargetListSetOperations.getNotLockedTlsErrorText(targetListSet));
        }

        if (targetListSet.getType() != TargetType.REFERENCE_PIXEL) {
            throw new ModuleFatalProcessingException(MODULE_NAME
                + " must run on a " + TargetType.REFERENCE_PIXEL
                + " targetListSet.\n  targetType: " + targetListSet.getType()
                + TargetListSetOperations.getTlsInfo(targetListSet));
        }

        MaskTable maskTable = targetListSet.getTargetTable()
            .getMaskTable();
        if (maskTable.getState() == State.UPLINKED) {
            throw new ModuleFatalProcessingException(
                TargetOperations.getUplinkedMaskTableErrorText(maskTable)
                    + TargetListSetOperations.getTlsInfo(targetListSet));
        }
    }

    private Persistable createInputs() {
        return persistableFactory.create(RptsInputs.class);
    }

    private void retrieveInputs(Persistable inputs) {
        ModOutUowTask modOutUowTask = pipelineTask.uowTaskInstance();
        modOut = modOutUowTask.modOut();

        RptsInputs rptsInputs = (RptsInputs) inputs;

        rptsInputs.setModule(modOut.getCcdModule());
        rptsInputs.setOutput(modOut.getCcdOutput());

        RptsModuleParameters params = pipelineTask.getParameters(RptsModuleParameters.class);
        rptsInputs.setRptsModuleParametersStruct(params);
        PlannedSpacecraftConfigParameters scConfigParams = pipelineTask.getParameters(PlannedSpacecraftConfigParameters.class);
        rptsInputs.setScConfigParameters(scConfigParams);

        log.info("Retrieving module output image...");
        retrieveModuleOutputImage(rptsInputs);

        log.info("Retrieving apertures...");
        retrieveApertures(rptsInputs);

        log.info("Retrieving masks...");
        retrieveMasks(rptsInputs);

        double startMjd = ModifiedJulianDate.dateToMjd(targetListSet.getStart());
        double endMjd = ModifiedJulianDate.dateToMjd(targetListSet.getEnd());

        rptsInputs.setReadNoiseModel(readNoiseOperations.retrieveReadNoiseModel(
            startMjd, endMjd));
    }

    private Persistable createOutputs() {
        return persistableFactory.create(RptsOutputs.class);
    }

    private void storeOutputs(Persistable outputs) {
        RptsOutputs rptsOutputs = (RptsOutputs) outputs;

        log.info("Storing masks...");
        storeMasks(rptsOutputs);

        log.info("Storing target definitions...");
        storeTargetDefinitions(rptsOutputs);
    }

    private void retrieveModuleOutputImage(RptsInputs rptsInputs) {
        Image image = targetCrud.retrieveImage(
            associatedLcTargetListSet.getTargetTable(), modOut.getCcdModule(),
            modOut.getCcdOutput());

        if (image == null) {
            throw new ModuleFatalProcessingException("No image was retrieved."
                + TargetListSetOperations.getTlsInfo(targetListSet,
                    associatedLcTargetListSet));
        }

        rptsInputs.setModuleOutputImage(image.getModuleOutputImage());
    }

    private void retrieveApertures(RptsInputs rptsInputs) {
        List<ObservedTarget> lcTargets = targetCrud.retrieveObservedTargetsPlusRejected(
            associatedLcTargetListSet.getTargetTable(), modOut.getCcdModule(),
            modOut.getCcdOutput());
        Map<Integer, ObservedTarget> lcTargetMap = newHashMap();
        for (ObservedTarget target : lcTargets) {
            lcTargetMap.put(target.getKeplerId(), target);
        }

        rpTargets = targetCrud.retrieveObservedTargetsPlusRejected(
            targetListSet.getTargetTable(), modOut.getCcdModule(),
            modOut.getCcdOutput(), INCLUDE_NULL_APERTURES);

        List<ApertureStruct> stellarApertures = newArrayList();
        List<ApertureStruct> dynamicRangeApertures = newArrayList();

        for (ObservedTarget rpTarget : rpTargets) {
            if (TargetManagementConstants.isCustomTarget(rpTarget.getKeplerId())) {
                if (rpTarget.getAperture() != null && !rpTarget.isRejected()) {
                    dynamicRangeApertures.add(apertureStructFactory.create(rpTarget));
                }
            } else { // It's a stellar target.
                ObservedTarget lcTarget = lcTargetMap.get(rpTarget.getKeplerId());
                if (lcTarget != null) {
                    rpTarget.setBadPixelCount(lcTarget.getBadPixelCount());
                    rpTarget.setCrowdingMetric(lcTarget.getCrowdingMetric());
                    rpTarget.setRejected(lcTarget.isRejected());
                    rpTarget.setSignalToNoiseRatio(lcTarget.getSignalToNoiseRatio());
                    rpTarget.setMagnitude(lcTarget.getMagnitude());
                    rpTarget.setFluxFractionInAperture(lcTarget.getFluxFractionInAperture());
                    rpTarget.setDistanceFromEdge(lcTarget.getDistanceFromEdge());
                    rpTarget.setAperturePixelCount(lcTarget.getAperturePixelCount());
                    rpTarget.setRa(lcTarget.getRa());
                    rpTarget.setDec(lcTarget.getDec());
                    rpTarget.setEffectiveTemp(lcTarget.getEffectiveTemp());
                    rpTarget.setSkyCrowdingMetric(lcTarget.getSkyCrowdingMetric());
                    rpTarget.setSaturatedRowCount(lcTarget.getSaturatedRowCount());

                    if (lcTarget.getAperture() != null) {
                        rpTarget.setAperture(lcTarget.getAperture()
                            .createCopy());
                        rpTarget.getAperture()
                            .setTargetTable(targetListSet.getTargetTable());
                        rpTarget.setAperturePixelCount(lcTarget.getAperturePixelCount());

                        if (!rpTarget.isRejected()) {
                            stellarApertures.add(apertureStructFactory.create(rpTarget));
                        }
                    }
                } else {
                    throw new ModuleFatalProcessingException(
                        "Discovered a stellar rp target for which there is no corresponding lc target.\n  keplerId:"
                            + rpTarget.getKeplerId()
                            + TargetListSetOperations.getTlsInfo(targetListSet,
                                associatedLcTargetListSet));
                }
            }
        }

        rptsInputs.setStellarApertures(stellarApertures);
        rptsInputs.setDynamicRangeApertures(dynamicRangeApertures);
    }

    private void retrieveMasks(RptsInputs rptsInputs)
        throws ModuleFatalProcessingException {
        MaskTable maskTable = targetListSet.getTargetTable()
            .getMaskTable();
        existingMasks = targetCrud.retrieveMasks(maskTable);

        if (existingMasks.isEmpty()) {
            throw new ModuleFatalProcessingException("No masks were retrieved."
                + TargetListSetOperations.getTlsInfo(targetListSet,
                    associatedLcTargetListSet));
        }

        // Remove supermasks from the list because they are not used by rpts
        // matlab.
        List<Mask> newList = newArrayList();
        for (Mask mask : existingMasks) {
            if (!mask.isSupermask()) {
                newList.add(mask);
            }
        }
        existingMasks = newList;

        List<MaskDefinition> maskDefinitions = newArrayList();
        for (Mask mask : existingMasks) {
            maskDefinitions.add(maskDefinitionFactory.create(mask));
        }

        rptsInputs.setExistingMasks(maskDefinitions);
    }

    private void storeMasks(RptsOutputs rptsOutputs) {
        // Put supermasks at the end of the table, so start from the largest
        // non-supermask index.
        int maxNonSupermaskIndex = Integer.MIN_VALUE;
        for (Mask mask : existingMasks) {
            if (!mask.isSupermask()
                && mask.getIndexInTable() > maxNonSupermaskIndex) {
                maxNonSupermaskIndex = mask.getIndexInTable();
            }
        }
        int supermaskStartIndex = maxNonSupermaskIndex + 1;

        int channel = FcConstants.getChannelNumber(modOut.getCcdModule(),
            modOut.getCcdOutput()) - 1;

        int backgroundMaskIndex = supermaskStartIndex + channel
            * TargetManagementConstants.RPTS_MASKS_PER_CHANNEL;
        int blackMaskIndex = backgroundMaskIndex + 1;
        int smearMaskIndex = backgroundMaskIndex + 2;

        MaskTable maskTable = targetListSet.getTargetTable()
            .getMaskTable();

        List<Mask> masksToCreate = newArrayList();

        if (rptsOutputs.getBackgroundMaskDefinition() != null) {
            backgroundMask = rptsOutputs.getBackgroundMaskDefinition()
                .toMask(maskTable);
            backgroundMask.setSupermask(true);
            backgroundMask.setIndexInTable(backgroundMaskIndex);
            backgroundMask.setPipelineTask(pipelineTask);
            masksToCreate.add(backgroundMask);
        }

        if (rptsOutputs.getBlackMaskDefinition() != null) {
            blackMask = rptsOutputs.getBlackMaskDefinition()
                .toMask(maskTable);
            blackMask.setSupermask(true);
            blackMask.setIndexInTable(blackMaskIndex);
            blackMask.setPipelineTask(pipelineTask);
            masksToCreate.add(blackMask);
        }

        if (rptsOutputs.getSmearMaskDefinition() != null) {
            smearMask = rptsOutputs.getSmearMaskDefinition()
                .toMask(maskTable);
            smearMask.setSupermask(true);
            smearMask.setIndexInTable(smearMaskIndex);
            smearMask.setPipelineTask(pipelineTask);
            masksToCreate.add(smearMask);
        }

        targetCrud.createMasks(masksToCreate);
    }

    private void storeTargetDefinitions(RptsOutputs rptsOutputs) {
        TargetTable targetTable = targetListSet.getTargetTable();

        Map<Integer, ObservedTarget> targetMap = newHashMap();
        for (ObservedTarget target : rpTargets) {
            targetMap.put(target.getKeplerId(), target);
        }

        int rpTargetDefIndex = 0;

        // Store stellar target defs.
        for (TargetDefinitionStruct struct : rptsOutputs.getStellarTargetDefinitions()) {
            ObservedTarget target = targetMap.get(struct.getKeplerId());

            if (target != null) {
                Mask mask = existingMasks.get(struct.getMaskIndex());
                mask.setUsed(true);

                TargetDefinition targetDefinition = new TargetDefinition(target);
                targetDefinition.setPipelineTask(pipelineTask);
                targetDefinition.setMask(mask);
                targetDefinition.setIndexInModuleOutput(rpTargetDefIndex);
                targetDefinition.setReferenceColumn(struct.getReferenceColumn());
                targetDefinition.setReferenceRow(struct.getReferenceRow());
                targetDefinition.setExcessPixels(struct.getExcessPixels());
                targetDefinition.setStatus(struct.getStatus());

                target.getTargetDefinitions()
                    .add(targetDefinition);

                rpTargetDefIndex++;
            }
        }

        // Store dynamic range target defs.
        for (TargetDefinitionStruct struct : rptsOutputs.getDynamicRangeTargetDefinitions()) {
            ObservedTarget target = targetMap.get(struct.getKeplerId());

            if (target != null) {
                Mask mask = existingMasks.get(struct.getMaskIndex());
                mask.setUsed(true);

                TargetDefinition targetDefinition = new TargetDefinition(target);
                targetDefinition.setPipelineTask(pipelineTask);
                targetDefinition.setMask(mask);
                targetDefinition.setIndexInModuleOutput(rpTargetDefIndex);
                targetDefinition.setReferenceColumn(struct.getReferenceColumn());
                targetDefinition.setReferenceRow(struct.getReferenceRow());
                targetDefinition.setExcessPixels(struct.getExcessPixels());
                targetDefinition.setStatus(struct.getStatus());

                target.getTargetDefinitions()
                    .add(targetDefinition);

                rpTargetDefIndex++;
            }
        }

        List<ObservedTarget> newObservedTargets = newArrayList();

        // Store background target def.
        if (rptsOutputs.getBackgroundTargetDefinition() != null) {
            TargetDefinitionStruct struct = rptsOutputs.getBackgroundTargetDefinition();

            ObservedTarget target = observedTargetFactory.create(targetTable,
                modOut, TargetManagementConstants.INVALID_KEPLER_ID);
            target.addLabel(TargetLabel.PDQ_BACKGROUND);
            target.setPipelineTask(pipelineTask);
            newObservedTargets.add(target);

            backgroundMask.setUsed(true);

            TargetDefinition targetDefinition = new TargetDefinition(target);
            targetDefinition.setPipelineTask(pipelineTask);
            targetDefinition.setMask(backgroundMask);
            targetDefinition.setIndexInModuleOutput(rpTargetDefIndex);
            targetDefinition.setReferenceColumn(struct.getReferenceColumn());
            targetDefinition.setReferenceRow(struct.getReferenceRow());
            targetDefinition.setExcessPixels(struct.getExcessPixels());
            targetDefinition.setStatus(struct.getStatus());

            target.getTargetDefinitions()
                .add(targetDefinition);

            rpTargetDefIndex++;
        }

        // Store black target defs.
        for (TargetDefinitionStruct struct : rptsOutputs.getBlackTargetDefinitions()) {
            ObservedTarget target = observedTargetFactory.create(targetTable,
                modOut, TargetManagementConstants.INVALID_KEPLER_ID);
            target.addLabel(TargetLabel.PDQ_BLACK_COLLATERAL);
            target.setPipelineTask(pipelineTask);
            newObservedTargets.add(target);

            blackMask.setUsed(true);

            TargetDefinition targetDefinition = new TargetDefinition(target);
            targetDefinition.setPipelineTask(pipelineTask);
            targetDefinition.setMask(blackMask);
            targetDefinition.setIndexInModuleOutput(rpTargetDefIndex);
            targetDefinition.setReferenceColumn(struct.getReferenceColumn());
            targetDefinition.setReferenceRow(struct.getReferenceRow());
            targetDefinition.setExcessPixels(struct.getExcessPixels());
            targetDefinition.setStatus(struct.getStatus());

            target.getTargetDefinitions()
                .add(targetDefinition);

            rpTargetDefIndex++;
        }

        // Store smear target defs.
        for (TargetDefinitionStruct struct : rptsOutputs.getSmearTargetDefinitions()) {
            ObservedTarget target = observedTargetFactory.create(targetTable,
                modOut, TargetManagementConstants.INVALID_KEPLER_ID);
            target.addLabel(TargetLabel.PDQ_SMEAR_COLLATERAL);
            target.setPipelineTask(pipelineTask);
            newObservedTargets.add(target);

            smearMask.setUsed(true);

            TargetDefinition targetDefinition = new TargetDefinition(target);
            targetDefinition.setPipelineTask(pipelineTask);
            targetDefinition.setMask(smearMask);
            targetDefinition.setIndexInModuleOutput(rpTargetDefIndex);
            targetDefinition.setReferenceColumn(struct.getReferenceColumn());
            targetDefinition.setReferenceRow(struct.getReferenceRow());
            targetDefinition.setExcessPixels(struct.getExcessPixels());
            targetDefinition.setStatus(struct.getStatus());

            target.getTargetDefinitions()
                .add(targetDefinition);

            rpTargetDefIndex++;
        }

        targetCrud.createObservedTargets(newObservedTargets);
    }

}
