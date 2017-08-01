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

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
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
import gov.nasa.kepler.tad.peer.BpaModuleParameters;
import gov.nasa.kepler.tad.peer.MaskDefinition;
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

public class BpaPipelineModuleTest extends JMockTest {

    private static final Date START = new Date(1000);
    private static final Date END = new Date(2000);
    private static final long PIPELINE_TASK_ID = 4;
    private static final int REFERENCE_ROW = 8;
    private static final int REFERENCE_COLUMN = 9;
    private static final int BAD_PIXEL_COUNT = 10;
    private static final int STATUS = 11;
    private static final ModOut MOD_OUT = ModOut.of(12, 13);
    private static final int EXCESS_PIXELS = 14;

    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private static final String ASSOCIATED_LC_TARGET_LIST_SET_NAME = "ASSOCIATED_LC_TARGET_LIST_SET_NAME";
    private static final State STATE = State.LOCKED;
    private static final String LABEL = "LABEL";
    private static final Set<String> LABELS = ImmutableSet.of(LABEL);
    private static final List<Offset> OFFSETS = BpaPipelineModule.theOfficialTwoByTwoOffsets();
    private static final int KEPLER_ID = TargetManagementConstants.INVALID_KEPLER_ID;
    private static final int TARGET_DEFS_PIXEL_COUNT = OFFSETS.size();
    private static final int SATURATED_ROW_COUNT = 1;

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
    private TargetTable backgroundTable = mock(TargetTable.class,
        "backgroundTable");
    private TargetTable associatedLcTargetTable = mock(TargetTable.class,
        "associatedLcTargetTable");
    private MaskTable maskTable = mock(MaskTable.class);
    private ModuleOutputListsParameters moduleOutputListsParameters = mock(ModuleOutputListsParameters.class);
    private Mask mask = mock(Mask.class);
    private List<Mask> masks = newArrayList(mask);
    private int indexInTable = masks.size() - 1;
    private int totalSum = masks.size();
    private MaskTableParameters maskTableParameters = mock(MaskTableParameters.class);
    private BpaModuleParameters bpaModuleParameters = mock(BpaModuleParameters.class);
    private ObservedTarget observedTarget = mock(ObservedTarget.class,
        "observedTarget");
    private List<ObservedTarget> observedTargets = newArrayList(observedTarget);
    private ObservedTarget associatedLcObservedTarget = mock(
        ObservedTarget.class, "associatedLcObservedTarget");
    private List<ObservedTarget> associatedLcObservedTargets = newArrayList(associatedLcObservedTarget);
    private Aperture aperture = mock(Aperture.class);
    private BpaInputs bpaInputs = mock(BpaInputs.class);
    private BpaOutputs bpaOutputs = mock(BpaOutputs.class);
    private MaskDefinition maskDefinition = mock(MaskDefinition.class);
    private List<MaskDefinition> maskDefinitions = ImmutableList.of(maskDefinition);
    private List<gov.nasa.kepler.mc.tad.Offset> matlabOffsets = OffsetList.toList(OFFSETS);
    private TargetDefinition targetDefinition = mock(TargetDefinition.class);
    private List<TargetDefinition> targetDefinitions = newArrayList(targetDefinition);
    private List<TargetDefinition> associatedLcTargetDefinitions = newArrayList(targetDefinition);
    private TargetDefinitionStruct targetDefinitionStruct = mock(TargetDefinitionStruct.class);
    private List<TargetDefinitionStruct> targetDefinitionStructs = ImmutableList.of(targetDefinitionStruct);
    private ModOutUowTask modOutUowTask = mock(ModOutUowTask.class);
    private Image image = TestImageFactory.create();

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private PersistableFactory persistableFactory = mock(PersistableFactory.class);
    private ObservedTargetFactory observedTargetFactory = mock(ObservedTargetFactory.class);

    private BpaPipelineModule bpaPipelineModule = new BpaPipelineModule(
        targetCrud, targetSelectionCrud, persistableFactory,
        observedTargetFactory) {
        @Override
        protected void executeAlgorithm(PipelineTask pipelineTask,
            Persistable inputs, Persistable outputs) {
            assertEquals(bpaInputs, inputs);
            assertEquals(bpaOutputs, outputs);
        }
    };

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(bpaPipelineModule);
    }

    @Test
    public void testProcessTask() {
        setAllowances();

        oneOf(bpaModuleParameters).setLineStartRow(image.getMinRow());

        oneOf(bpaModuleParameters).setLineEndRow(image.getMaxRow());

        oneOf(bpaModuleParameters).setLineStartCol(image.getMinCol());

        oneOf(bpaModuleParameters).setLineEndCol(image.getMaxCol());

        oneOf(bpaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(bpaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(bpaInputs).setBpaConfigurationStruct(bpaModuleParameters);

        oneOf(bpaInputs).setModuleOutputImage(image.getModuleOutputImage());

        oneOf(targetCrud).createObservedTarget(observedTarget);

        oneOf(observedTarget).setPipelineTask(pipelineTask);

        oneOf(observedTarget).setTargetDefsPixelCount(
            TARGET_DEFS_PIXEL_COUNT + TARGET_DEFS_PIXEL_COUNT);

        bpaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithUnlockedTargetListSet() {
        allowing(targetListSet).getState();
        will(returnValue(State.UNLOCKED));

        setAllowances();

        bpaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithReferencePixelTargetListSet() {
        allowing(targetListSet).getType();
        will(returnValue(TargetType.REFERENCE_PIXEL));

        setAllowances();

        bpaPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithEmptyMaskDefinitions() {
        allowing(bpaOutputs).getMaskDefinitions();
        will(returnValue(ImmutableList.of()));

        setAllowances();

        oneOf(bpaModuleParameters).setLineStartRow(image.getMinRow());

        oneOf(bpaModuleParameters).setLineEndRow(image.getMaxRow());

        oneOf(bpaModuleParameters).setLineStartCol(image.getMinCol());

        oneOf(bpaModuleParameters).setLineEndCol(image.getMaxCol());

        oneOf(bpaInputs).setModule(MOD_OUT.getCcdModule());

        oneOf(bpaInputs).setOutput(MOD_OUT.getCcdOutput());

        oneOf(bpaInputs).setBpaConfigurationStruct(bpaModuleParameters);

        oneOf(bpaInputs).setModuleOutputImage(image.getModuleOutputImage());

        bpaPipelineModule.processTask(pipelineInstance, pipelineTask);
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

        allowing(pipelineTask).getParameters(BpaModuleParameters.class);
        will(returnValue(bpaModuleParameters));

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

        allowing(persistableFactory).create(BpaInputs.class);
        will(returnValue(bpaInputs));

        allowing(persistableFactory).create(BpaOutputs.class);
        will(returnValue(bpaOutputs));

        allowing(bpaOutputs).getMaskDefinitions();
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

        allowing(bpaOutputs).getTargetDefinitions();
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

        allowing(pipelineTask).uowTaskInstance();
        will(returnValue(modOutUowTask));

        allowing(modOutUowTask).modOut();
        will(returnValue(MOD_OUT));

        allowing(targetCrud).retrieveImage(targetTable, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput());
        will(returnValue(image));

        allowing(bpaInputs).getBpaConfigurationStruct();
        will(returnValue(bpaModuleParameters));

        allowing(targetListSet).getBackgroundTable();
        will(returnValue(backgroundTable));

        allowing(backgroundTable).getMaskTable();
        will(returnValue(maskTable));

        allowing(observedTargetFactory).create(backgroundTable, MOD_OUT,
            KEPLER_ID);
        will(returnValue(observedTarget));

        allowing(maskDefinition).toMask(null);
        will(returnValue(mask));
    }

}