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

package gov.nasa.kepler.tad.peer.tadval;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class TadValPipelineModuleTest {

    private static final String LC_TLS_NAME = "LC_TLS_NAME";

    private TadValPipelineModule tadvalPipelineModule;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;

    private DatabaseService databaseService;
    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;

    private ReflectionEquals reflectionEquals;

    private Mask mask;

    private TargetTable targetTable;

    private TargetListSet targetListSet;
    private MaskTable maskTable;
    private List<Mask> masks;

    private List<ObservedTarget> observedTargets;

    private ObservedTarget observedTarget;

    private TadParameters tadPipelineParameters;

    private List<PlannedTarget> plannedTargets;

    private PlannedTarget plannedTarget;

    private List<Offset> apertureOffsets;

    private List<Offset> maskOffsets;

    private Aperture aperture;

    private TargetDefinition targetDefinition;

    private TargetTable backgroundTable;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();

        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
        targetCrud = new TargetCrud(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);

        reflectionEquals = new ReflectionEquals();
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() throws Exception {
        populateObjectsHelper(true);
    }

    private void populateObjectsHelper(boolean createBackgroundTable)
        throws Exception {
        tadvalPipelineModule = new TadValPipelineModule();

        tadPipelineParameters = new TadParameters(LC_TLS_NAME, LC_TLS_NAME);

        ParameterSet parameterSet = new ParameterSet("tad");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            tadPipelineParameters));

        Map<ClassWrapper<Parameters>, ParameterSet> paramMap = ImmutableMap.of(
            new ClassWrapper<Parameters>(TadParameters.class), parameterSet);

        pipelineInstance = new PipelineInstance();
        pipelineInstance.setPipelineParameterSets(paramMap);

        pipelineTask = new PipelineTask(pipelineInstance,
            new PipelineDefinitionNode(), new PipelineInstanceNode());

        targetListSet = new TargetListSet(LC_TLS_NAME);
        targetListSet.setState(State.LOCKED);

        targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetListSet.setTargetTable(targetTable);

        plannedTarget = new PlannedTarget(
            TargetManagementConstants.INVALID_KEPLER_ID, 1);
        plannedTargets = ImmutableList.of(plannedTarget);

        apertureOffsets = newArrayList(new Offset(1, 1));

        aperture = new Aperture(true, 0, 0, apertureOffsets);

        observedTarget = new ObservedTarget(targetTable, 2, 1,
            TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START);
        observedTarget.setRejected(true);
        observedTarget.setAperture(aperture);
        observedTarget.setAperturePixelCount(1);
        observedTargets = ImmutableList.of(observedTarget);

        maskTable = new MaskTable(MaskType.TARGET);
        targetTable.setMaskTable(maskTable);

        maskOffsets = newArrayList(new Offset(1, 1));

        mask = new Mask(maskTable, maskOffsets);
        mask.setSupermask(true);

        masks = ImmutableList.of(mask);

        targetDefinition = new TargetDefinition(observedTarget);
        targetDefinition.setMask(mask);

        observedTarget.getTargetDefinitions()
            .add(targetDefinition);

        targetSelectionCrud.create(targetListSet);
        targetSelectionCrud.create(plannedTargets);
        targetCrud.createTargetTable(targetTable);
        targetCrud.createMaskTable(maskTable);
        targetCrud.createMasks(masks);
        targetCrud.createObservedTargets(observedTargets);

        if (createBackgroundTable) {
            backgroundTable = new TargetTable(TargetType.BACKGROUND);
            targetListSet.setBackgroundTable(backgroundTable);
            backgroundTable.setMaskTable(maskTable);
            targetCrud.createTargetTable(backgroundTable);
        }
    }

    @Test
    public void testValidate() throws Exception {
        populateObjects();

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.TAD_COMPLETED,
            targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        List<String> warnings = summary.getWarnings();
        assertEquals(0, warnings.size());
    }

    @Test
    public void pixelsOffCcd() throws Exception {
        populateObjects();

        // Add a pixel off the ccd.
        databaseService.beginTransaction();
        mask.getOffsets()
            .add(new Offset(-100, -100));
        databaseService.commitTransaction();

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxTargetMasksGenerated() throws Exception {
        populateObjects();

        List<Mask> masks = newArrayList();
        for (int i = 0; i < TargetManagementConstants.MAX_TARGET_APERTURES + 1; i++) {
            List<Offset> offsets = ImmutableList.of();
            Mask mask = new Mask(maskTable, offsets);
            mask.setIndexInTable(i + 1);
            masks.add(mask);
        }
        targetCrud.createMasks(masks);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxBackgroundMasksGenerated() throws Exception {
        populateObjects();

        maskTable = new MaskTable(MaskType.BACKGROUND);
        targetCrud.createMaskTable(maskTable);

        targetListSet.getTargetTable()
            .setMaskTable(maskTable);

        List<Mask> masks = newArrayList();
        for (int i = 0; i < TargetManagementConstants.MAX_BACKGROUND_APERTURES + 1; i++) {
            List<Offset> offsets = ImmutableList.of();
            Mask mask = new Mask(maskTable, offsets);
            mask.setIndexInTable(i);
            masks.add(mask);
        }
        targetCrud.createMasks(masks);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void notLocked() throws Exception {
        populateObjects();

        targetListSet.setState(State.UNLOCKED);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);
    }

    @Test
    public void noBackgroundTable() throws Exception {
        populateObjectsHelper(false);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxAperturePixels() throws Exception {
        populateObjects();

        // Create too many pixels in the aperture table.
        for (int i = 0; i < TargetManagementConstants.MAX_TOTAL_APERTURE_OFFSETS + 1; i++) {
            mask.getOffsets()
                .add(new Offset(1, 1));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void maskDoesNotContainAperture() throws Exception {
        populateObjects();

        apertureOffsets.add(new Offset(100, 100));
        observedTarget.setRejected(false);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxLcTargetDefsGenerated() throws Exception {
        populateObjects();

        // Create target defs.
        targetTable.setType(TargetType.LONG_CADENCE);
        for (int i = 0; i < TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS + 1; i++) {
            observedTarget.getTargetDefinitions()
                .add(new TargetDefinition(0, 0, 0, mask));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(2, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxScTargetDefsGenerated() throws Exception {
        populateObjects();

        // Create target defs.
        targetTable.setType(TargetType.SHORT_CADENCE);
        for (int i = 0; i < TargetManagementConstants.MAX_SHORT_CADENCE_TARGET_DEFS + 1; i++) {
            observedTarget.getTargetDefinitions()
                .add(new TargetDefinition(0, 0, 0, mask));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxRpTargetDefsGenerated() throws Exception {
        populateObjects();

        // Create target defs.
        targetTable.setType(TargetType.REFERENCE_PIXEL);
        for (int i = 0; i < TargetManagementConstants.MAX_REFERENCE_PIXEL_TARGET_DEFS + 1; i++) {
            observedTarget.getTargetDefinitions()
                .add(new TargetDefinition(0, 0, 0, mask));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxLcPixels() throws Exception {
        populateObjects();

        targetTable.setType(TargetType.LONG_CADENCE);
        for (int i = 0; i < TargetManagementConstants.MAX_LONG_CADENCE_PIXELS + 1; i++) {
            maskOffsets.add(new Offset(1, 1));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(2, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxScPixels() throws Exception {
        populateObjects();

        targetTable.setType(TargetType.SHORT_CADENCE);
        for (int i = 0; i < TargetManagementConstants.MAX_SHORT_CADENCE_PIXELS + 1; i++) {
            maskOffsets.add(new Offset(1, 1));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getErrors()
            .size());
    }

    @Test
    public void moreThanMaxRpPixels() throws Exception {
        populateObjects();

        targetTable.setType(TargetType.REFERENCE_PIXEL);
        for (int i = 0; i < TargetManagementConstants.MAX_REFERENCE_PIXEL_PIXELS + 1; i++) {
            maskOffsets.add(new Offset(1, 1));
        }

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.LOCKED, targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(2, summary.getErrors()
            .size());
    }

    @Test
    public void countTargetsAndPixels() throws Exception {
        populateObjects();

        // Call some apis for coverage.
        tadvalPipelineModule.getModuleName();
        tadvalPipelineModule.unitOfWorkTaskType();

        // Add a pixel from each region.
        maskOffsets.add(new Offset(1, 1));
        maskOffsets.add(new Offset(1, 500));
        maskOffsets.add(new Offset(1, 1122));
        maskOffsets.add(new Offset(1060, 500));

        // Add a target with each type of label.
        List<ObservedTarget> observedTargets = newArrayList();
        for (TargetLabel label : TargetLabel.values()) {
            ObservedTarget observedTarget = new ObservedTarget(targetTable, 2,
                1, 1);
            observedTarget.addLabel(label);
            observedTarget.setRejected(true);
            observedTarget.setAperture(aperture);
            observedTarget.setAperturePixelCount(1);

            TargetDefinition targetDefinition = new TargetDefinition(
                observedTarget);
            targetDefinition.setMask(mask);
            observedTarget.getTargetDefinitions()
                .add(targetDefinition);

            observedTargets.add(observedTarget);
        }

        // Create a collateral target for each region.
        int maskIndex = 1;
        List<Mask> masks = newArrayList();
        for (Offset offset : maskOffsets) {
            Mask mask = new Mask(maskTable, ImmutableList.of(offset));
            mask.setIndexInTable(maskIndex);
            masks.add(mask);

            ObservedTarget observedTarget = new ObservedTarget(targetTable, 2,
                1, 1);
            observedTarget.addLabel(TargetLabel.PDQ_BLACK_COLLATERAL);
            observedTarget.setRejected(true);
            observedTarget.setAperture(null);
            observedTarget.setAperturePixelCount(1);

            TargetDefinition targetDefinition = new TargetDefinition(
                observedTarget);
            targetDefinition.setMask(mask);
            observedTarget.getTargetDefinitions()
                .add(targetDefinition);

            observedTargets.add(observedTarget);

            maskIndex++;
        }

        targetCrud.createMasks(masks);
        targetCrud.createObservedTargets(observedTargets);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        TadReport summary = targetTable.getTadReport();

        reflectionEquals.assertEquals(State.TAD_COMPLETED,
            targetListSet.getState());

        List<String> warnings = summary.getWarnings();
        assertEquals(0, warnings.size());
    }

    @Test
    public void customTargetWithNullAperture() throws Exception {
        populateObjects();

        observedTarget.setAperture(null);

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.TAD_COMPLETED,
            targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        List<String> warnings = summary.getWarnings();
        assertEquals(1, warnings.size());
    }

    @Test
    public void testMissingSignalProcessingChains() throws Exception {
        populateObjects();

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        assertEquals(ImmutableSet.of(1, 2, 3, 5), targetTable.getTadReport()
            .getMissingSignalProcessingChains());
    }

    @Test
    public void hasEmptyApertureAndNoTargetDefPixels() throws Exception {
        populateObjects();

        aperture.getOffsets()
            .clear();
        mask.getOffsets()
            .clear();

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.TAD_COMPLETED,
            targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        List<String> warnings = summary.getWarnings();
        assertEquals(0, warnings.size());
    }

    @Test
    public void hasAperturePixelsAndNoTargetDefPixels() throws Exception {
        populateObjects();

        mask.getOffsets()
            .clear();

        tadvalPipelineModule.processTask(pipelineInstance, pipelineTask);

        reflectionEquals.assertEquals(State.TAD_COMPLETED,
            targetListSet.getState());

        TadReport summary = targetTable.getTadReport();
        assertEquals(1, summary.getWarnings()
            .size());
    }

}
