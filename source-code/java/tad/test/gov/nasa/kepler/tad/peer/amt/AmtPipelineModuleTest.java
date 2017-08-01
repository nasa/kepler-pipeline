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

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.tad.PersistableFactory;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.tad.operations.TargetOperations;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.tad.peer.AmtModuleParameters;
import gov.nasa.kepler.tad.peer.MaskDefinition;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.kepler.tad.peer.PipelineModuleTest;
import gov.nasa.kepler.tad.xml.ImportedMaskTable;
import gov.nasa.kepler.tad.xml.MaskReader;
import gov.nasa.kepler.tad.xml.MaskReaderFactory;
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
public class AmtPipelineModuleTest extends JMockTest {

    private static final Date START = new Date(1000);
    private static final Date END = new Date(2000);
    private static final byte[] BYTE_ARRAY = new byte[] { 3 };
    private static final long PIPELINE_TASK_ID = 4;
    private static final gov.nasa.kepler.mc.tad.Offset MATLAB_OFFSET = new gov.nasa.kepler.mc.tad.Offset(
        5, 6);
    private static final int KEPLER_ID = 7;
    private static final int REFERENCE_ROW = 8;
    private static final int REFERENCE_COLUMN = 9;
    private static final int BAD_PIXEL_COUNT = 10;

    private static final String TARGET_LIST_SET_NAME = "TARGET_LIST_SET_NAME";
    private static final TargetType TARGET_TYPE = TargetType.LONG_CADENCE;
    private static final State STATE = State.LOCKED;
    private static final String LABEL = "LABEL";
    private static final Set<String> LABELS = ImmutableSet.of(LABEL);
    private static final Offset OFFSET = MATLAB_OFFSET.toDatabaseOffset();
    private static final List<Offset> OFFSETS = ImmutableList.of(OFFSET);

    private String maskTableCopySourceTargetListSetName = "maskTableCopySourceTargetListSetName";
    private String maskTableImportSourceFileName = "maskTableImportSourceFileName";
    private FsId fsId = DrFsIdFactory.getFile(DispatcherType.MASK_TABLE,
        maskTableImportSourceFileName);

    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private TadParameters tadParameters = mock(TadParameters.class);
    private TargetListSet targetListSet = mock(TargetListSet.class);
    private TargetTable targetTable = mock(TargetTable.class);
    private MaskTable maskTable = mock(MaskTable.class);
    private AmtModuleParameters amtModuleParameters = mock(AmtModuleParameters.class);
    private BlobResult blobResult = mock(BlobResult.class);
    private ModuleOutputListsParameters moduleOutputListsParameters = new ModuleOutputListsParameters();
    private MaskReader maskReader = mock(MaskReader.class);
    private Mask mask = mock(Mask.class);
    private List<Mask> masks = newArrayList(mask);
    private ImportedMaskTable importedMaskTable = new ImportedMaskTable(
        maskTable, masks);
    private int totalSum = masks.size();
    private MaskTableParameters maskTableParameters = mock(MaskTableParameters.class);
    private AmaModuleParameters amaModuleParameters = mock(AmaModuleParameters.class);
    private ObservedTarget observedTarget = mock(ObservedTarget.class);
    private List<ObservedTarget> observedTargets = ImmutableList.of(observedTarget);
    private Aperture aperture = mock(Aperture.class);
    private AmtInputs amtInputs = mock(AmtInputs.class);
    private AmtOutputs amtOutputs = mock(AmtOutputs.class);
    private MaskDefinition maskDefinition = mock(MaskDefinition.class);
    private List<MaskDefinition> maskDefinitions = ImmutableList.of(maskDefinition);
    private List<gov.nasa.kepler.mc.tad.Offset> matlabOffsets = ImmutableList.of(MATLAB_OFFSET);

    private TargetCrud targetCrud = mock(TargetCrud.class);
    private TargetSelectionCrud targetSelectionCrud = mock(TargetSelectionCrud.class);
    private FileStoreClient fileStoreClient = mock(FileStoreClient.class);
    private MaskReaderFactory maskReaderFactory = mock(MaskReaderFactory.class);
    private TargetOperations targetOperations = mock(TargetOperations.class);
    private PersistableFactory persistableFactory = mock(PersistableFactory.class);

    private AmtPipelineModule amtPipelineModule = new AmtPipelineModule(
        targetCrud, targetSelectionCrud, fileStoreClient, maskReaderFactory,
        targetOperations, persistableFactory) {
        @Override
        protected void executeAlgorithm(PipelineTask pipelineTask,
            Persistable inputs, Persistable outputs) {
            assertEquals(amtInputs, inputs);
            assertEquals(amtOutputs, outputs);
        }
    };

    @Test
    public void testFrameworkMethods() {
        PipelineModuleTest.testFrameworkMethods(amtPipelineModule);
    }

    @Test
    public void testProcessTaskWithSourceFile() {
        maskTableCopySourceTargetListSetName = "";
        maskTableImportSourceFileName = "maskTableImportSourceFileName";

        setAllowances();

        oneOf(maskTable).setExternalId(ExportTable.INVALID_EXTERNAL_ID);

        oneOf(maskTable).setPlannedStartTime(START);

        oneOf(maskTable).setPlannedEndTime(END);

        oneOf(mask).setPipelineTask(pipelineTask);

        oneOf(targetCrud).createMaskTable(maskTable);

        oneOf(targetCrud).createMasks(masks);

        oneOf(targetTable).setMaskTable(maskTable);

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithSourceFileWithNoMasks() {
        maskTableCopySourceTargetListSetName = "";
        maskTableImportSourceFileName = "maskTableImportSourceFileName";
        masks.clear();
        importedMaskTable = new ImportedMaskTable(maskTable, masks);

        setAllowances();

        oneOf(maskTable).setExternalId(ExportTable.INVALID_EXTERNAL_ID);

        oneOf(maskTable).setPlannedStartTime(START);

        oneOf(maskTable).setPlannedEndTime(END);

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithSourceTargetListSet() {
        maskTableCopySourceTargetListSetName = "maskTableCopySourceTargetListSetName";
        maskTableImportSourceFileName = "";

        setAllowances();

        oneOf(maskTable).setPlannedStartTime(START);

        oneOf(maskTable).setPlannedEndTime(END);

        oneOf(targetTable).setMaskTable(maskTable);

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithBothSources() {
        maskTableCopySourceTargetListSetName = "maskTableCopySourceTargetListSetName";
        maskTableImportSourceFileName = "maskTableImportSourceFileName";

        setAllowances();

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void testProcessTaskWithNoSources() {
        maskTableCopySourceTargetListSetName = "";
        maskTableImportSourceFileName = "";

        setAllowances();

        oneOf(maskTable).setPlannedStartTime(START);

        oneOf(maskTable).setPlannedEndTime(END);

        oneOf(amtInputs).retrieveFor(pipelineTask);

        oneOf(amtOutputs).storeFor(pipelineTask);

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithUnlockedTargetListSet() {
        allowing(targetListSet).getState();
        will(returnValue(State.UNLOCKED));

        setAllowances();

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithShortCadenceTargetListSet() {
        allowing(targetListSet).getType();
        will(returnValue(TargetType.SHORT_CADENCE));

        setAllowances();

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void testProcessTaskWithUplinkedMaskTable() {
        allowing(maskTable).getState();
        will(returnValue(State.UPLINKED));

        setAllowances();

        amtPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    private void setAllowances() {
        allowing(pipelineTask).getParameters(TadParameters.class);
        will(returnValue(tadParameters));

        allowing(tadParameters).getTargetListSetName();
        will(returnValue(TARGET_LIST_SET_NAME));

        allowing(targetListSet).getType();
        will(returnValue(TARGET_TYPE));

        allowing(targetListSet).getSupplementalTls();
        will(returnValue(null));

        allowing(targetListSet).getState();
        will(returnValue(STATE));

        allowing(maskTable).getState();
        will(returnValue(STATE));

        allowing(targetListSet).getStart();
        will(returnValue(START));

        allowing(targetListSet).getEnd();
        will(returnValue(END));

        allowing(pipelineTask).getParameters(AmtModuleParameters.class);
        will(returnValue(amtModuleParameters));

        allowing(amtModuleParameters).getMaskTableCopySourceTargetListSetName();
        will(returnValue(maskTableCopySourceTargetListSetName));

        allowing(amtModuleParameters).getMaskTableImportSourceFileName();
        will(returnValue(maskTableImportSourceFileName));

        allowing(fileStoreClient).readBlob(fsId);
        will(returnValue(blobResult));

        allowing(blobResult).data();
        will(returnValue(BYTE_ARRAY));

        allowing(pipelineTask).getParameters(ModuleOutputListsParameters.class);
        will(returnValue(moduleOutputListsParameters));

        allowing(maskReaderFactory).create(BYTE_ARRAY);
        will(returnValue(maskReader));

        allowing(maskReader).read();
        will(returnValue(importedMaskTable));

        allowing(pipelineTask).getParameters(MaskTableParameters.class);
        will(returnValue(maskTableParameters));

        allowing(maskTableParameters).getTotalSum();
        will(returnValue(totalSum));

        allowing(pipelineTask).getId();
        will(returnValue(PIPELINE_TASK_ID));

        allowing(targetSelectionCrud).retrieveTargetListSet(
            maskTableCopySourceTargetListSetName);
        will(returnValue(targetListSet));

        allowing(targetOperations).copy(maskTable, pipelineTask);
        will(returnValue(maskTable));

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

        allowing(persistableFactory).create(AmtInputs.class);
        will(returnValue(amtInputs));

        allowing(amtInputs).getAmtConfigurationStruct();
        will(returnValue(amtModuleParameters));

        allowing(persistableFactory).create(AmtOutputs.class);
        will(returnValue(amtOutputs));

        allowing(amtOutputs).getMaskDefinitions();
        will(returnValue(maskDefinitions));

        allowing(maskDefinition).getOffsets();
        will(returnValue(matlabOffsets));

        allowing(maskDefinition).toMask(maskTable);
        will(returnValue(mask));

        allowing(tadParameters).targetListSet();
        will(returnValue(targetListSet));

        allowing(tadParameters).maskTable();
        will(returnValue(maskTable));

        allowing(tadParameters).targetTable();
        will(returnValue(targetTable));

        allowing(targetListSet).getTargetTable();
        will(returnValue(targetTable));

        allowing(targetTable).getMaskTable();
        will(returnValue(maskTable));
    }

}