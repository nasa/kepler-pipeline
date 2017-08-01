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
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
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
import gov.nasa.kepler.hibernate.tad.TestImageFactory;
import gov.nasa.kepler.mc.tad.OffsetList;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.tad.peer.ApertureStruct;
import gov.nasa.kepler.tad.peer.ApertureStructFactory;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.MaskDefinitionFactory;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.kepler.tad.peer.PipelineModuleTest;
import gov.nasa.kepler.tad.peer.RptsModuleParameters;
import gov.nasa.kepler.tad.peer.TargetDefinitionStruct;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.util.Date;
import java.util.List;
import java.util.Set;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class RptsPipelineModuleTest extends JMockTest {

    private static final Date START_DATE = new Date(1000);
    private static final Date END_DATE = new Date(2000);
    private static final long PIPELINE_TASK_ID = 4;
    private static final int ROW = 5;
    private static final int COLUMN = 6;
    private static final int REFERENCE_ROW = 8;
    private static final int REFERENCE_COLUMN = 9;
    private static final int BAD_PIXEL_COUNT = 10;
    private static final int STATUS = 11;
    private static final ModOut MOD_OUT = ModOut.of(12, 13);
    private static final int EXCESS_PIXELS = 14;
    private static final double CROWDING_METRIC = 21.21;
    private static final double SIGNAL_TO_NOISE_RATIO = 22.22;
    private static final float MAGNITUDE = 23.23F;
    private static final double FLUX_FRACTION_IN_APERTURE = 24.24;
    private static final int DISTANCE_FROM_EDGE = 25;
    private static final int APERTURE_PIXEL_COUNT = 26;
    private static final double RA = 27.27;
    private static final double DEC = 28.28;
    private static final float EFFECTIVE_TEMP = 29.29F;
    private static final double SKY_CROWDING_METRIC = 30.30;

    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private static final String ASSOCIATED_LC_TARGET_LIST_SET_NAME = "ASSOCIATED_LC_TARGET_LIST_SET_NAME";
    private static final String LABEL = "LABEL";
    private static final Set<String> LABELS = ImmutableSet.of(LABEL);
    private static final Offset OFFSET = new Offset(ROW, COLUMN);
    private static final List<Offset> OFFSETS = ImmutableList.of(OFFSET);
    private static final int TARGET_DEFS_PIXEL_COUNT = OFFSETS.size();
    private static final double START_MJD = ModifiedJulianDate.dateToMjd(START_DATE);
    private static final double END_MJD = ModifiedJulianDate.dateToMjd(END_DATE);
    private static final int CHANNEL_MINUS_ONE = FcConstants.getChannelNumber(
        MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput()) - 1;
    private static final int SATURATED_ROW_COUNT = 2;

    private boolean rejected = true;
    private boolean supermask = true;
    private boolean used = true;
    private TargetType targetType = TargetType.REFERENCE_PIXEL;
    private State state = State.LOCKED;
    private int keplerId = TargetManagementConstants.INVALID_KEPLER_ID;

    private Mask mask = mock(Mask.class);
    private List<Mask> masks = newArrayList(mask);
    private List<Mask> masksToCreate = newArrayList(mask, mask, mask);
    private int indexInTable = masks.size() - 1;
    private int totalSum = masks.size();
    private int supermaskStartIndex = masks.size();
    private int backgroundMaskIndex = supermaskStartIndex + CHANNEL_MINUS_ONE
        * TargetManagementConstants.RPTS_MASKS_PER_CHANNEL;
    private int blackMaskIndex = backgroundMaskIndex + 1;
    private int smearMaskIndex = backgroundMaskIndex + 2;

    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private TargetListSet targetListSet = mock(TargetListSet.class,
        "targetListSet");
    private TargetListSet associatedLcTargetListSet = mock(TargetListSet.class,
        "associatedLcTargetListSet");
    private TargetTable targetTable = mock(TargetTable.class, "targetTable");
    private TargetTable backgroundTable = mock(TargetTable.class,
        "backgroundTable");
    private TargetTable associatedLcTargetTable = mock(TargetTable.class,
        "associatedLcTargetTable");
    private MaskTable maskTable = mock(MaskTable.class);
    private ModuleOutputListsParameters moduleOutputListsParameters = mock(ModuleOutputListsParameters.class);
    private MaskTableParameters maskTableParameters = mock(MaskTableParameters.class);
    private RptsModuleParameters rptsModuleParameters = mock(RptsModuleParameters.class);
    private ObservedTarget observedTarget = mock(ObservedTarget.class,
        "observedTarget");
    private List<ObservedTarget> observedTargets = newArrayList(observedTarget);
    private List<ObservedTarget> observedTargetsToCreate = newArrayList(
        observedTarget, observedTarget, observedTarget);
    private ObservedTarget associatedLcObservedTarget = mock(
        ObservedTarget.class, "associatedLcObservedTarget");
    private List<ObservedTarget> associatedLcObservedTargets = newArrayList(associatedLcObservedTarget);
    private Aperture aperture = mock(Aperture.class);
    private RptsInputs rptsInputs = mock(RptsInputs.class);
    private RptsOutputs rptsOutputs = mock(RptsOutputs.class);
    private MaskDefinition maskDefinition = mock(MaskDefinition.class,
        "maskDefinition");
    private MaskDefinition backgroundMaskDefinition = mock(
        MaskDefinition.class, "backgroundMaskDefinition");
    private MaskDefinition blackMaskDefinition = mock(MaskDefinition.class,
        "blackMaskDefinition");
    private MaskDefinition smearMaskDefinition = mock(MaskDefinition.class,
        "smearMaskDefinition");
    private List<MaskDefinition> maskDefinitions = newArrayList(maskDefinition);
    private ApertureStruct apertureStruct = mock(ApertureStruct.class);
    private List<ApertureStruct> stellarApertures = newArrayList(apertureStruct);
    private List<ApertureStruct> dynamicRangeApertures = newArrayList(apertureStruct);
    private List<gov.nasa.kepler.mc.tad.Offset> matlabOffsets = OffsetList.toList(OFFSETS);
    private TargetDefinition targetDefinition = mock(TargetDefinition.class);
    private List<TargetDefinition> targetDefinitions = newArrayList(targetDefinition);
    private List<TargetDefinition> associatedLcTargetDefinitions = newArrayList(targetDefinition);
    private TargetDefinitionStruct targetDefinitionStruct = mock(TargetDefinitionStruct.class);
    private TargetDefinitionStruct backgroundTargetDefinitionStruct = targetDefinitionStruct;
    private List<TargetDefinitionStruct> stellarTargetDefinitionStructs = ImmutableList.of(targetDefinitionStruct);
    private List<TargetDefinitionStruct> dynamicRangeTargetDefinitionStructs = ImmutableList.of(targetDefinitionStruct);
    private List<TargetDefinitionStruct> blackTargetDefinitionStructs = ImmutableList.of(targetDefinitionStruct);
    private List<TargetDefinitionStruct> smearTargetDefinitionStructs = ImmutableList.of(targetDefinitionStruct);
    private ModOutUowTask modOutUowTask = mock(ModOutUowTask.class);
    private Image image = TestImageFactory.create();
    private PlannedSpacecraftConfigParameters plannedSpacecraftConfigParameters = mock(PlannedSpacecraftConfigParameters.class);
    private ReadNoiseModel readNoiseModel = mock(ReadNoiseModel.class);

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private PersistableFactory persistableFactory = mock(PersistableFactory.class);
    private MaskDefinitionFactory maskDefinitionFactory = mock(MaskDefinitionFactory.class);
    private ApertureStructFactory apertureStructFactory = mock(ApertureStructFactory.class);
    private ObservedTargetFactory observedTargetFactory = mock(ObservedTargetFactory.class);
    private ReadNoiseOperations readNoiseOperations = mock(ReadNoiseOperations.class);

    private RptsPipelineModule rptsPipelineModule = new RptsPipelineModule(
        targetCrud, targetSelectionCrud, readNoiseOperations,
        persistableFactory, apertureStructFactory, maskDefinitionFactory,
        observedTargetFactory) {
        @Override
        protected void executeAlgorithm(PipelineTask pipelineTask,
            Persistable inputs, Persistable outputs) {
            assertEquals(rptsInputs, inputs);
            assertEquals(rptsOutputs, outputs);
        }
    };

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(rptsPipelineModule);
    }

    @Test
    public void testProcessTaskWithRejectedTarget() {
        stellarApertures.clear();
        dynamicRangeApertures.clear();
        maskDefinitions.clear();

        setAllowances();

        oneOf(observedTarget).setBadPixelCount(BAD_PIXEL_COUNT);

        oneOf(observedTarget).setCrowdingMetric(CROWDING_METRIC);

        oneOf(observedTarget).setRejected(rejected);

        oneOf(observedTarget).setSignalToNoiseRatio(SIGNAL_TO_NOISE_RATIO);

        oneOf(observedTarget).setMagnitude(MAGNITUDE);

        oneOf(observedTarget).setFluxFractionInAperture(
            FLUX_FRACTION_IN_APERTURE);

        oneOf(observedTarget).setDistanceFromEdge(DISTANCE_FROM_EDGE);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(observedTarget).setRa(RA);

        oneOf(observedTarget).setDec(DEC);

        oneOf(observedTarget).setEffectiveTemp(EFFECTIVE_TEMP);

        oneOf(observedTarget).setSkyCrowdingMetric(SKY_CROWDING_METRIC);

        oneOf(observedTarget).setSaturatedRowCount(SATURATED_ROW_COUNT);

        oneOf(observedTarget).setAperture(aperture);

        oneOf(aperture).setTargetTable(targetTable);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(rptsInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(rptsInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(rptsInputs).setRptsModuleParametersStruct(rptsModuleParameters);

        oneOf(rptsInputs).setScConfigParameters(
            plannedSpacecraftConfigParameters);

        oneOf(rptsInputs).setModuleOutputImage(image.getModuleOutputImage());

        oneOf(rptsInputs).setStellarApertures(stellarApertures);

        oneOf(rptsInputs).setDynamicRangeApertures(dynamicRangeApertures);

        oneOf(rptsInputs).setExistingMasks(maskDefinitions);

        oneOf(rptsInputs).setReadNoiseModel(readNoiseModel);

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNonRejectedTarget() {
        rejected = false;
        dynamicRangeApertures.clear();
        supermask = false;

        setAllowances();

        oneOf(observedTarget).setBadPixelCount(BAD_PIXEL_COUNT);

        oneOf(observedTarget).setCrowdingMetric(CROWDING_METRIC);

        oneOf(observedTarget).setRejected(rejected);

        oneOf(observedTarget).setSignalToNoiseRatio(SIGNAL_TO_NOISE_RATIO);

        oneOf(observedTarget).setMagnitude(MAGNITUDE);

        oneOf(observedTarget).setFluxFractionInAperture(
            FLUX_FRACTION_IN_APERTURE);

        oneOf(observedTarget).setDistanceFromEdge(DISTANCE_FROM_EDGE);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(observedTarget).setRa(RA);

        oneOf(observedTarget).setDec(DEC);

        oneOf(observedTarget).setEffectiveTemp(EFFECTIVE_TEMP);

        oneOf(observedTarget).setSkyCrowdingMetric(SKY_CROWDING_METRIC);

        oneOf(observedTarget).setSaturatedRowCount(SATURATED_ROW_COUNT);

        oneOf(observedTarget).setAperture(aperture);

        oneOf(aperture).setTargetTable(targetTable);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(rptsInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(rptsInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(rptsInputs).setRptsModuleParametersStruct(rptsModuleParameters);

        oneOf(rptsInputs).setScConfigParameters(
            plannedSpacecraftConfigParameters);

        oneOf(rptsInputs).setModuleOutputImage(image.getModuleOutputImage());

        oneOf(rptsInputs).setStellarApertures(stellarApertures);

        oneOf(rptsInputs).setDynamicRangeApertures(dynamicRangeApertures);

        oneOf(rptsInputs).setExistingMasks(maskDefinitions);

        oneOf(rptsInputs).setReadNoiseModel(readNoiseModel);

        oneOf(mask).setSupermask(true);

        oneOf(mask).setIndexInTable(backgroundMaskIndex);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(mask).setSupermask(true);

        oneOf(mask).setIndexInTable(blackMaskIndex);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(mask).setSupermask(true);

        oneOf(mask).setIndexInTable(smearMaskIndex);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createMasks(masksToCreate);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(observedTarget).addLabel(TargetLabel.PDQ_BACKGROUND);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).addLabel(TargetLabel.PDQ_BLACK_COLLATERAL);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).addLabel(TargetLabel.PDQ_SMEAR_COLLATERAL);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createObservedTargets(observedTargetsToCreate);

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithUnlockedTargetListSet() {
        state = State.UNLOCKED;

        setAllowances();

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithLongCadenceTargetListSet() {
        targetType = TargetType.LONG_CADENCE;

        setAllowances();

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithUplinkedMaskTable() {
        allowing(maskTable).getState();
        will(returnValue(State.UPLINKED));

        setAllowances();

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithNullImage() {
        allowing(targetCrud).retrieveImage(associatedLcTargetTable,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(null));

        rejected = false;
        dynamicRangeApertures.clear();
        supermask = false;

        setAllowances();

        oneOf(rptsInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(rptsInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(rptsInputs).setRptsModuleParametersStruct(rptsModuleParameters);

        oneOf(rptsInputs).setScConfigParameters(
            plannedSpacecraftConfigParameters);

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNonRejectedCustomTarget() {
        keplerId = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;
        rejected = false;
        stellarApertures.clear();
        supermask = false;

        setAllowances();

        oneOf(rptsInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(rptsInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(rptsInputs).setRptsModuleParametersStruct(rptsModuleParameters);

        oneOf(rptsInputs).setScConfigParameters(
            plannedSpacecraftConfigParameters);

        oneOf(rptsInputs).setModuleOutputImage(image.getModuleOutputImage());

        oneOf(rptsInputs).setStellarApertures(stellarApertures);

        oneOf(rptsInputs).setDynamicRangeApertures(dynamicRangeApertures);

        oneOf(rptsInputs).setExistingMasks(maskDefinitions);

        oneOf(rptsInputs).setReadNoiseModel(readNoiseModel);

        oneOf(mask).setSupermask(true);

        oneOf(mask).setIndexInTable(backgroundMaskIndex);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(mask).setSupermask(true);

        oneOf(mask).setIndexInTable(blackMaskIndex);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(mask).setSupermask(true);

        oneOf(mask).setIndexInTable(smearMaskIndex);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createMasks(masksToCreate);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(mask).setUsed(used);

        oneOf(observedTarget).addLabel(TargetLabel.PDQ_BACKGROUND);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).addLabel(TargetLabel.PDQ_BLACK_COLLATERAL);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).addLabel(TargetLabel.PDQ_SMEAR_COLLATERAL);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createObservedTargets(observedTargetsToCreate);

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithMissingAssociatedLcObservedTarget() {
        rejected = false;
        dynamicRangeApertures.clear();
        supermask = false;

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(
            associatedLcTargetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(ImmutableList.of()));

        setAllowances();

        oneOf(rptsInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(rptsInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(rptsInputs).setRptsModuleParametersStruct(rptsModuleParameters);

        oneOf(rptsInputs).setScConfigParameters(
            plannedSpacecraftConfigParameters);

        oneOf(rptsInputs).setModuleOutputImage(image.getModuleOutputImage());

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithEmptyMasks() {
        rejected = false;
        dynamicRangeApertures.clear();
        supermask = false;

        masks.clear();

        setAllowances();

        oneOf(rptsInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(rptsInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(rptsInputs).setRptsModuleParametersStruct(rptsModuleParameters);

        oneOf(rptsInputs).setScConfigParameters(
            plannedSpacecraftConfigParameters);

        oneOf(rptsInputs).setModuleOutputImage(image.getModuleOutputImage());

        oneOf(observedTarget).setBadPixelCount(BAD_PIXEL_COUNT);

        oneOf(observedTarget).setCrowdingMetric(CROWDING_METRIC);

        oneOf(observedTarget).setRejected(rejected);

        oneOf(observedTarget).setSignalToNoiseRatio(SIGNAL_TO_NOISE_RATIO);

        oneOf(observedTarget).setMagnitude(MAGNITUDE);

        oneOf(observedTarget).setFluxFractionInAperture(
            FLUX_FRACTION_IN_APERTURE);

        oneOf(observedTarget).setDistanceFromEdge(DISTANCE_FROM_EDGE);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(observedTarget).setRa(RA);

        oneOf(observedTarget).setDec(DEC);

        oneOf(observedTarget).setEffectiveTemp(EFFECTIVE_TEMP);

        oneOf(observedTarget).setSkyCrowdingMetric(SKY_CROWDING_METRIC);
        
        oneOf(observedTarget).setSaturatedRowCount(SATURATED_ROW_COUNT);

        oneOf(observedTarget).setAperture(aperture);

        oneOf(aperture).setTargetTable(targetTable);

        oneOf(observedTarget).setAperturePixelCount(APERTURE_PIXEL_COUNT);

        oneOf(rptsInputs).setStellarApertures(stellarApertures);

        oneOf(rptsInputs).setDynamicRangeApertures(dynamicRangeApertures);

        rptsPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    private void setAllowances() {
        allowing(pipelineTask).getParameters(TadParameters.class);
        will(returnValue(tadParameters));

        allowing(tadParameters).getTargetListSetName();
        will(returnValue(TARGET_LIST_SET_NAME));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            TARGET_LIST_SET_NAME);
        will(returnValue(targetListSet));

        allowing(targetListSet).getType();
        will(returnValue(targetType));

        allowing(targetListSet).getSupplementalTls();
        will(returnValue(null));

        allowing(targetListSet).getState();
        will(returnValue(state));

        allowing(targetListSet).getTargetTable();
        will(returnValue(targetTable));

        allowing(targetTable).getMaskTable();
        will(returnValue(maskTable));

        allowing(maskTable).getState();
        will(returnValue(state));

        allowing(targetListSet).getStart();
        will(returnValue(START_DATE));

        allowing(targetListSet).getEnd();
        will(returnValue(END_DATE));

        allowing(pipelineTask).getParameters(ModuleOutputListsParameters.class);
        will(returnValue(moduleOutputListsParameters));

        allowing(pipelineTask).getParameters(MaskTableParameters.class);
        will(returnValue(maskTableParameters));

        allowing(maskTableParameters).getTotalSum();
        will(returnValue(totalSum));

        allowing(pipelineTask).getId();
        will(returnValue(PIPELINE_TASK_ID));

        allowing(pipelineTask).getParameters(RptsModuleParameters.class);
        will(returnValue(rptsModuleParameters));

        allowing(targetCrud).retrieveMasks(maskTable);
        will(returnValue(masks));

        allowing(mask).getOffsets();
        will(returnValue(OFFSETS));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable);
        will(returnValue(observedTargets));

        allowing(observedTarget).getAperture();
        will(returnValue(aperture));

        allowing(observedTarget).getKeplerId();
        will(returnValue(keplerId));

        allowing(aperture).getReferenceRow();
        will(returnValue(REFERENCE_ROW));

        allowing(aperture).getReferenceColumn();
        will(returnValue(REFERENCE_COLUMN));

        allowing(observedTarget).getBadPixelCount();
        will(returnValue(BAD_PIXEL_COUNT));

        allowing(aperture).getOffsets();
        will(returnValue(OFFSETS));

        allowing(observedTarget).getLabels();
        will(returnValue(LABELS));

        allowing(persistableFactory).create(RptsInputs.class);
        will(returnValue(rptsInputs));

        allowing(maskDefinitionFactory).create(mask);
        will(returnValue(maskDefinition));

        allowing(apertureStructFactory).create(observedTarget);
        will(returnValue(apertureStruct));

        allowing(persistableFactory).create(RptsOutputs.class);
        will(returnValue(rptsOutputs));

        allowing(maskDefinition).getOffsets();
        will(returnValue(matlabOffsets));

        allowing(tadParameters).getAssociatedLcTargetListSetName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            ASSOCIATED_LC_TARGET_LIST_SET_NAME);
        will(returnValue(associatedLcTargetListSet));

        allowing(observedTarget).isRejected();
        will(returnValue(rejected));

        allowing(observedTarget).getTargetDefinitions();
        will(returnValue(targetDefinitions));

        allowing(targetDefinitionStruct).getKeplerId();
        will(returnValue(keplerId));

        allowing(targetDefinitionStruct).getStatus();
        will(returnValue(STATUS));

        allowing(observedTarget).getTargetTable();
        will(returnValue(targetTable));

        allowing(observedTarget).getModOut();
        will(returnValue(MOD_OUT));

        allowing(targetDefinitionStruct).getMaskIndex();
        will(returnValue(indexInTable));

        allowing(targetDefinitionStruct).getReferenceRow();
        will(returnValue(REFERENCE_ROW));

        allowing(targetDefinitionStruct).getReferenceColumn();
        will(returnValue(REFERENCE_COLUMN));

        allowing(targetDefinitionStruct).getExcessPixels();
        will(returnValue(EXCESS_PIXELS));

        allowing(observedTarget).getTargetDefsPixelCount();
        will(returnValue(TARGET_DEFS_PIXEL_COUNT));

        allowing(observedTarget).getSaturatedRowCount();
        will(returnValue(SATURATED_ROW_COUNT));

        allowing(targetDefinition).getModOut();
        will(returnValue(MOD_OUT));

        allowing(targetDefinition).getExcessPixels();
        will(returnValue(EXCESS_PIXELS));

        allowing(targetDefinition).getKeplerId();
        will(returnValue(keplerId));

        allowing(targetDefinition).getMask();
        will(returnValue(mask));

        allowing(targetDefinition).getReferenceRow();
        will(returnValue(REFERENCE_ROW));

        allowing(targetDefinition).getReferenceColumn();
        will(returnValue(REFERENCE_COLUMN));

        allowing(targetDefinition).getStatus();
        will(returnValue(STATUS));

        allowing(associatedLcTargetListSet).getType();
        will(returnValue(TargetType.LONG_CADENCE));

        allowing(associatedLcTargetListSet).getTargetTable();
        will(returnValue(associatedLcTargetTable));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(
            associatedLcTargetTable);
        will(returnValue(associatedLcObservedTargets));

        allowing(associatedLcObservedTarget).getKeplerId();
        will(returnValue(keplerId));

        allowing(associatedLcObservedTarget).getTargetDefinitions();
        will(returnValue(associatedLcTargetDefinitions));

        allowing(targetListSet).getName();
        will(returnValue(TARGET_LIST_SET_NAME));

        allowing(associatedLcTargetListSet).getName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(pipelineTask).uowTaskInstance();
        will(returnValue(modOutUowTask));

        allowing(modOutUowTask).modOut();
        will(returnValue(MOD_OUT));

        allowing(targetCrud).retrieveImage(targetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(image));

        allowing(targetListSet).getBackgroundTable();
        will(returnValue(backgroundTable));

        allowing(backgroundTable).getMaskTable();
        will(returnValue(maskTable));

        allowing(observedTargetFactory).create(backgroundTable, MOD_OUT,
            keplerId);
        will(returnValue(observedTarget));

        allowing(pipelineTask).getParameters(
            PlannedSpacecraftConfigParameters.class);
        will(returnValue(plannedSpacecraftConfigParameters));

        allowing(targetCrud).retrieveImage(associatedLcTargetTable,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        will(returnValue(image));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(
            associatedLcTargetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(observedTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable,
            MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput(),
            RptsPipelineModule.INCLUDE_NULL_APERTURES);
        will(returnValue(observedTargets));

        allowing(observedTarget).getCrowdingMetric();
        will(returnValue(CROWDING_METRIC));

        allowing(observedTarget).getSignalToNoiseRatio();
        will(returnValue(SIGNAL_TO_NOISE_RATIO));

        allowing(observedTarget).getMagnitude();
        will(returnValue(MAGNITUDE));

        allowing(observedTarget).getFluxFractionInAperture();
        will(returnValue(FLUX_FRACTION_IN_APERTURE));

        allowing(observedTarget).getDistanceFromEdge();
        will(returnValue(DISTANCE_FROM_EDGE));

        allowing(observedTarget).getSaturatedRowCount();
        will(returnValue(SATURATED_ROW_COUNT));

        allowing(observedTarget).getAperturePixelCount();
        will(returnValue(APERTURE_PIXEL_COUNT));

        allowing(observedTarget).getRa();
        will(returnValue(RA));

        allowing(observedTarget).getDec();
        will(returnValue(DEC));

        allowing(observedTarget).getEffectiveTemp();
        will(returnValue(EFFECTIVE_TEMP));

        allowing(observedTarget).getSkyCrowdingMetric();
        will(returnValue(SKY_CROWDING_METRIC));

        allowing(aperture).createCopy();
        will(returnValue(aperture));

        allowing(mask).isSupermask();
        will(returnValue(supermask));

        allowing(readNoiseOperations).retrieveReadNoiseModel(START_MJD, END_MJD);
        will(returnValue(readNoiseModel));

        allowing(rptsInputs).getStellarApertures();
        will(returnValue(stellarApertures));

        allowing(rptsInputs).getDynamicRangeApertures();
        will(returnValue(dynamicRangeApertures));

        allowing(mask).getIndexInTable();
        will(returnValue(indexInTable));

        allowing(rptsOutputs).getBackgroundMaskDefinition();
        will(returnValue(backgroundMaskDefinition));

        allowing(backgroundMaskDefinition).getOffsets();
        will(returnValue(matlabOffsets));

        allowing(rptsOutputs).getBlackMaskDefinition();
        will(returnValue(blackMaskDefinition));

        allowing(blackMaskDefinition).getOffsets();
        will(returnValue(matlabOffsets));

        allowing(rptsOutputs).getSmearMaskDefinition();
        will(returnValue(smearMaskDefinition));

        allowing(smearMaskDefinition).getOffsets();
        will(returnValue(matlabOffsets));

        allowing(rptsOutputs).getStellarTargetDefinitions();
        will(returnValue(stellarTargetDefinitionStructs));

        allowing(rptsOutputs).getDynamicRangeTargetDefinitions();
        will(returnValue(dynamicRangeTargetDefinitionStructs));

        allowing(rptsOutputs).getBackgroundTargetDefinition();
        will(returnValue(backgroundTargetDefinitionStruct));

        allowing(rptsOutputs).getBlackTargetDefinitions();
        will(returnValue(blackTargetDefinitionStructs));

        allowing(rptsOutputs).getSmearTargetDefinitions();
        will(returnValue(smearTargetDefinitionStructs));

        allowing(observedTargetFactory).create(targetTable, MOD_OUT,
            TargetManagementConstants.INVALID_KEPLER_ID);
        will(returnValue(observedTarget));

        allowing(backgroundMaskDefinition).toMask(maskTable);
        will(returnValue(mask));

        allowing(blackMaskDefinition).toMask(maskTable);
        will(returnValue(mask));

        allowing(smearMaskDefinition).toMask(maskTable);
        will(returnValue(mask));
    }

}
