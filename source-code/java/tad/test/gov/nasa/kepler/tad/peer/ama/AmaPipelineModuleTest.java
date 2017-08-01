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
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.tad.peer.ApertureStruct;
import gov.nasa.kepler.tad.peer.ApertureStructFactory;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.MaskDefinitionFactory;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.kepler.tad.peer.PipelineModuleTest;
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
public class AmaPipelineModuleTest extends JMockTest {

    private static final Date START = new Date(1000);
    private static final Date END = new Date(2000);
    private static final long PIPELINE_TASK_ID = 4;
    private static final gov.nasa.kepler.mc.tad.Offset MATLAB_OFFSET = new gov.nasa.kepler.mc.tad.Offset(
        5, 6);
    private static final int KEPLER_ID = 7;
    private static final int REFERENCE_ROW = 8;
    private static final int REFERENCE_COLUMN = 9;
    private static final int BAD_PIXEL_COUNT = 10;
    private static final int STATUS = 11;
    private static final ModOut MOD_OUT = ModOut.of(12, 13);
    private static final int EXCESS_PIXELS = 14;
    private static final int TARGET_DEFS_PIXEL_COUNT = 15;
    private static final int NONEXISTENT_KEPLER_ID = 16;
    private static final int SATURATED_ROW_COUNT = 17;

    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private static final String ASSOCIATED_LC_TARGET_LIST_SET_NAME = "ASSOCIATED_LC_TARGET_LIST_SET_NAME";
    private static final State STATE = State.LOCKED;
    private static final String LABEL = "LABEL";
    private static final Set<String> LABELS = ImmutableSet.of(LABEL);
    private static final Offset OFFSET = MATLAB_OFFSET.toDatabaseOffset();
    private static final List<Offset> OFFSETS = ImmutableList.of(OFFSET);
    private static final boolean USED_MASK = true;
    private static final boolean[] USED_MASKS = new boolean[] { USED_MASK };

    private boolean rejected = true;
    private TargetType targetType = TargetType.LONG_CADENCE;

    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private TargetListSet targetListSet = mock(TargetListSet.class,
        "targetListSet");
    private TargetListSet associatedLcTargetListSet = mock(TargetListSet.class,
        "associatedLcTargetListSet");
    private TargetTable targetTable = mock(TargetTable.class, "targetTable");
    private TargetTable associatedLcTargetTable = mock(TargetTable.class,
        "associatedLcTargetTable");
    private MaskTable maskTable = mock(MaskTable.class);
    private ModuleOutputListsParameters moduleOutputListsParameters = mock(ModuleOutputListsParameters.class);
    private Mask mask = mock(Mask.class);
    private List<Mask> masks = newArrayList(mask);
    private int indexInTable = masks.size() - 1;
    private int totalSum = masks.size();
    private MaskTableParameters maskTableParameters = mock(MaskTableParameters.class);
    private AmaModuleParameters amaModuleParameters = mock(AmaModuleParameters.class);
    private ObservedTarget observedTarget = mock(ObservedTarget.class,
        "observedTarget");
    private List<ObservedTarget> observedTargets = newArrayList(observedTarget);
    private ObservedTarget associatedLcObservedTarget = mock(
        ObservedTarget.class, "associatedLcObservedTarget");
    private List<ObservedTarget> associatedLcObservedTargets = newArrayList(associatedLcObservedTarget);
    private Aperture aperture = mock(Aperture.class);
    private AmaInputs amaInputs = mock(AmaInputs.class);
    private AmaOutputs amaOutputs = mock(AmaOutputs.class);
    private MaskDefinition maskDefinition = mock(MaskDefinition.class);
    private List<MaskDefinition> maskDefinitions = ImmutableList.of(maskDefinition);
    private List<MaskDefinition> twoMaskDefinitions = ImmutableList.of(
        maskDefinition, maskDefinition);
    private ApertureStruct apertureStruct = mock(ApertureStruct.class);
    private List<ApertureStruct> apertureStructs = newArrayList(apertureStruct);
    private List<gov.nasa.kepler.mc.tad.Offset> matlabOffsets = ImmutableList.of(MATLAB_OFFSET);
    private TargetDefinition targetDefinition = mock(TargetDefinition.class);
    private List<TargetDefinition> targetDefinitions = newArrayList(targetDefinition);
    private List<TargetDefinition> associatedLcTargetDefinitions = newArrayList(targetDefinition);
    private TargetDefinitionStruct targetDefinitionStruct = mock(TargetDefinitionStruct.class);
    private List<TargetDefinitionStruct> targetDefinitionStructs = ImmutableList.of(targetDefinitionStruct);

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private PersistableFactory persistableFactory = mock(PersistableFactory.class);
    private MaskDefinitionFactory maskDefinitionFactory = mock(MaskDefinitionFactory.class);
    private ApertureStructFactory apertureStructFactory = mock(ApertureStructFactory.class);

    private AmaPipelineModule amaPipelineModule = new AmaPipelineModule(
        targetCrud, targetSelectionCrud, persistableFactory,
        maskDefinitionFactory, apertureStructFactory) {
        @Override
        protected void executeAlgorithm(PipelineTask pipelineTask,
            Persistable inputs, Persistable outputs) {
            assertEquals(amaInputs, inputs);
            assertEquals(amaOutputs, outputs);
        }
    };

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(amaPipelineModule);
    }

    @Test
    public void testProcessTaskWithRejectedTarget() {
        apertureStructs.clear();

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNonRejectedTargetWithTargetDefs() {
        rejected = false;
        apertureStructs.clear();

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNonRejectedTargetWithNoTargetDefs() {
        rejected = false;
        targetDefinitions = newArrayList();

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        oneOf(observedTarget).setTargetDefsPixelCount(
            TARGET_DEFS_PIXEL_COUNT + OFFSETS.size());

        oneOf(mask).setUsed(USED_MASK);

        oneOf(mask).setOffsets(OFFSETS);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithShortCadenceTargetListSet() {
        targetType = TargetType.SHORT_CADENCE;
        apertureStructs.clear();

        setAllowances();

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithUnlockedTargetListSet() {
        allowing(targetListSet).getState();
        will(returnValue(State.UNLOCKED));

        setAllowances();

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithReferencePixelTargetListSet() {
        allowing(targetListSet).getType();
        will(returnValue(TargetType.REFERENCE_PIXEL));

        setAllowances();

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithShortCadenceTargetListSetWithNoAssociatedLcTarget() {
        targetType = TargetType.SHORT_CADENCE;
        apertureStructs.clear();
        associatedLcObservedTargets.clear();

        setAllowances();

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithNoMasks() {
        rejected = false;
        targetDefinitions = newArrayList();
        masks.clear();

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNullAperture() {
        rejected = false;
        targetDefinitions = newArrayList();

        allowing(observedTarget).getAperture();
        will(returnValue(null));

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        oneOf(observedTarget).setTargetDefsPixelCount(
            TARGET_DEFS_PIXEL_COUNT + OFFSETS.size());

        oneOf(mask).setUsed(USED_MASK);

        oneOf(observedTarget).setRejected(true);

        oneOf(mask).setOffsets(OFFSETS);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithNoObservedTargets() {
        rejected = false;
        targetDefinitions = newArrayList();
        observedTargets.clear();
        apertureStructs.clear();

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNonexistentTargetDefStruct() {
        rejected = false;
        targetDefinitions = newArrayList();

        allowing(targetDefinitionStruct).getKeplerId();
        will(returnValue(NONEXISTENT_KEPLER_ID));

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        oneOf(mask).setUsed(USED_MASK);

        oneOf(mask).setOffsets(OFFSETS);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithRejectedStatus() {
        rejected = false;
        targetDefinitions = newArrayList();

        allowing(targetDefinitionStruct).getStatus();
        will(returnValue(AmaPipelineModule.REJECTED_STATUS));

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        oneOf(mask).setUsed(USED_MASK);

        oneOf(observedTarget).setRejected(true);

        oneOf(mask).setOffsets(OFFSETS);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithLargeMaskIndex() {
        rejected = false;
        targetDefinitions = newArrayList();
        indexInTable++;

        allowing(amaOutputs).getMaskDefinitions();
        will(returnValue(twoMaskDefinitions));

        setAllowances();

        oneOf(amaInputs).setAmaConfigurationStruct(amaModuleParameters);

        oneOf(amaInputs).setMaskTableParametersStruct(maskTableParameters);

        oneOf(amaInputs).setMaskDefinitions(maskDefinitions);

        oneOf(amaInputs).setApertureStructs(apertureStructs);

        oneOf(observedTarget).setTargetDefsPixelCount(
            TARGET_DEFS_PIXEL_COUNT + OFFSETS.size());

        oneOf(mask).setUsed(USED_MASK);

        oneOf(targetCrud).createMask(mask);

        oneOf(mask).setOffsets(OFFSETS);

        amaPipelineModule.processTask(pipelineInstance, pipelineTask);
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

        allowing(targetListSet).getState();
        will(returnValue(STATE));

        allowing(targetListSet).getTargetTable();
        will(returnValue(targetTable));

        allowing(targetTable).getMaskTable();
        will(returnValue(maskTable));

        allowing(maskTable).getState();
        will(returnValue(STATE));

        allowing(targetListSet).getStart();
        will(returnValue(START));

        allowing(targetListSet).getEnd();
        will(returnValue(END));

        allowing(pipelineTask).getParameters(ModuleOutputListsParameters.class);
        will(returnValue(moduleOutputListsParameters));

        allowing(pipelineTask).getParameters(MaskTableParameters.class);
        will(returnValue(maskTableParameters));

        allowing(maskTableParameters).getTotalSum();
        will(returnValue(totalSum));

        allowing(pipelineTask).getId();
        will(returnValue(PIPELINE_TASK_ID));

        allowing(pipelineTask).getParameters(AmaModuleParameters.class);
        will(returnValue(amaModuleParameters));

        allowing(targetCrud).retrieveMasks(maskTable);
        will(returnValue(masks));

        allowing(mask).getOffsets();
        will(returnValue(OFFSETS));

        allowing(targetCrud).retrieveObservedTargetsPlusRejected(targetTable);
        will(returnValue(observedTargets));

        allowing(observedTarget).getAperture();
        will(returnValue(aperture));

        allowing(observedTarget).getKeplerId();
        will(returnValue(KEPLER_ID));

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

        allowing(persistableFactory).create(AmaInputs.class);
        will(returnValue(amaInputs));

        allowing(maskDefinitionFactory).create(mask);
        will(returnValue(maskDefinition));

        allowing(apertureStructFactory).create(observedTarget);
        will(returnValue(apertureStruct));

        allowing(persistableFactory).create(AmaOutputs.class);
        will(returnValue(amaOutputs));

        allowing(amaOutputs).getMaskDefinitions();
        will(returnValue(maskDefinitions));

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

        allowing(amaInputs).getApertureStructs();
        will(returnValue(apertureStructs));

        allowing(amaOutputs).getTargetDefinitions();
        will(returnValue(targetDefinitionStructs));

        allowing(targetDefinitionStruct).getKeplerId();
        will(returnValue(KEPLER_ID));

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

        allowing(amaOutputs).getUsedMasks();
        will(returnValue(USED_MASKS));

        allowing(targetDefinition).getModOut();
        will(returnValue(MOD_OUT));

        allowing(targetDefinition).getExcessPixels();
        will(returnValue(EXCESS_PIXELS));

        allowing(targetDefinition).getKeplerId();
        will(returnValue(KEPLER_ID));

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
        will(returnValue(KEPLER_ID));

        allowing(associatedLcObservedTarget).getTargetDefinitions();
        will(returnValue(associatedLcTargetDefinitions));

        allowing(targetListSet).getName();
        will(returnValue(TARGET_LIST_SET_NAME));

        allowing(associatedLcTargetListSet).getName();
        will(returnValue(ASSOCIATED_LC_TARGET_LIST_SET_NAME));

        allowing(maskDefinition).toMask(maskTable);
        will(returnValue(mask));
    }

}