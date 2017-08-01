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

package gov.nasa.kepler.sggen;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.uow.KicGroup;
import gov.nasa.kepler.mc.uow.KicGroupUowTask;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.persistable.PersistableUtils;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Tests the {@link SkyGroupGenPipelineModule}.
 * 
 * @author Bill Wohler
 */
public abstract class AbstractSkyGroupGenPipelineModuleTest extends JMockTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(AbstractSkyGroupGenPipelineModuleTest.class);

    private static final long INSTANCE_ID = System.currentTimeMillis();
    private static final long PIPELINE_TASK_ID = INSTANCE_ID - 1000;
    private static final double MJD = 3.3;
    private static final int SEASON = 4;
    private static final int MODULE = 5;
    private static final int OUTPUT = 6;
    private static final int ROW = 7;
    private static final int COLUMN = 8;
    private static final int SKY_GROUP_ID = 9;

    private CelestialObjectOperations celestialObjectOperations;
    private KicCrud kicCrud;
    private MjdToCadence mjdToCadence;
    private RaDec2PixOperations raDec2PixOperations;
    private TargetSelectionOperations targetSelectionOperations;
    private RollTimeOperations rollTimeOperations;

    private PipelineInstance pipelineInstance;
    private final SkyGroupGenPipelineModule pipelineModule = new SkyGroupGenPipelineModuleNullScience(
        this);
    private PipelineTask pipelineTask;
    private RaDec2PixModel raDec2PixModel;
    private List<Star> stars;
    private UnitTestDescriptor unitTestDescriptor;

    protected SkyGroupGenPipelineModule getPipelineModule() {
        return pipelineModule;
    }

    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    protected PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    protected void setUnitTestDescriptor(UnitTestDescriptor unitTestDescriptor) {
        this.unitTestDescriptor = unitTestDescriptor;
    }

    protected boolean isSerializeInputs() {
        return unitTestDescriptor.isSerializeInputs();
    }

    protected boolean isSerializeOutputs() {
        return unitTestDescriptor.isSerializeOutputs();
    }

    protected boolean isValidateInputs() {
        return unitTestDescriptor.isValidateInputs();
    }

    protected boolean isValidateOutputs() {
        return unitTestDescriptor.isValidateOutputs();
    }

    protected void serializeInputs(SkyGroupGenInputs skyGroupGenInputs)
        throws IllegalAccessException {

        testSerialization(skyGroupGenInputs, new SkyGroupGenInputs(), new File(
            Filenames.BUILD_TMP, getClass().getSimpleName()
                + "-inputs.bin"));
    }

    private void testSerialization(SkyGroupGenInputs expected,
        SkyGroupGenInputs actual, File file) throws IllegalAccessException {

        // Save and read file.
        PersistableUtils.writeBinFile(expected, file);
        PersistableUtils.readBinFile(actual, file);

        // Test.
        ReflectionEquals re = new ReflectionEquals();
        re.excludeField(".*\\.ccdColumns");
        re.excludeField(".*\\.ccdModules");
        re.excludeField(".*\\.ccdOutputs");
        re.excludeField(".*\\.ccdRows");
        re.assertEquals(expected, actual);
    }

    protected void serializeOutputs(SkyGroupGenOutputs skyGroupGenOutputs)
        throws IllegalAccessException {

        SerializationTest.testSerialization(skyGroupGenOutputs,
            new SkyGroupGenOutputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-outputs.bin"));
    }

    protected void populateObjects() {
        createMockObjects();
        setMockObjects(getPipelineModule());
        pipelineTask = createPipelineTask(PIPELINE_TASK_ID,
            unitTestDescriptor.getStartKeplerId(),
            unitTestDescriptor.getEndKeplerId());
    }

    //
    private void createMockObjects() {
        celestialObjectOperations = mock(CelestialObjectOperations.class);
        kicCrud = mock(KicCrud.class);
        mjdToCadence = mock(MjdToCadence.class);
        raDec2PixOperations = mock(RaDec2PixOperations.class);
        targetSelectionOperations = mock(TargetSelectionOperations.class);
        rollTimeOperations = mock(RollTimeOperations.class);
    }

    private void setMockObjects(SkyGroupGenPipelineModule pipelineModule) {
        pipelineModule.setCelestialObjectOperations(celestialObjectOperations);
        pipelineModule.setKicCrud(kicCrud);
        pipelineModule.setRaDec2PixOperations(raDec2PixOperations);
        pipelineModule.setTargetSelectionOperations(targetSelectionOperations);
        pipelineModule.setRollTimeOperations(rollTimeOperations);
    }

    protected void createInputs() {
        TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(this,
            mjdToCadence, CadenceType.LONG,
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence());

        raDec2PixModel = MockUtils.mockRaDec2PixModel(this,
            raDec2PixOperations, cadenceTimes.startMjd(),
            cadenceTimes.endMjd(), 4);
        allowing(raDec2PixOperations).retrieveRaDec2PixModel();
        will(returnValue(raDec2PixModel));

        List<Kic> kics = createKics(unitTestDescriptor.getStartKeplerId(),
            unitTestDescriptor.getEndKeplerId());
        allowing(kicCrud).retrieveKics(unitTestDescriptor.getStartKeplerId(),
            unitTestDescriptor.getEndKeplerId());
        will(returnValue(kics));

        List<CelestialObjectParameters> celestialObjectParametersList = createCelestialObjectParametersList(kics);
        allowing(celestialObjectOperations).retrieveCelestialObjectParameters(
            unitTestDescriptor.getStartKeplerId(),
            unitTestDescriptor.getEndKeplerId());
        will(returnValue(celestialObjectParametersList));
        
        allowing(rollTimeOperations).mjdToSeason(MJD);
        will(returnValue(SEASON));
        
        allowing(targetSelectionOperations).skyGroupIdFor(MODULE, OUTPUT, SEASON);
        will(returnValue(SKY_GROUP_ID));

        stars = createStars(celestialObjectParametersList);
    }

    private List<Kic> createKics(int startKeplerId, int endKeplerId) {
        List<Kic> kics = new ArrayList<Kic>();
        for (int i = startKeplerId; i <= endKeplerId; i++) {
            kics.add(new Kic.Builder(i, 0, 0).build());
        }

        return kics;
    }

    private List<CelestialObjectParameters> createCelestialObjectParametersList(
        List<Kic> kics) {
        List<CelestialObjectParameters> celestialObjectParametersList = new ArrayList<CelestialObjectParameters>();
        for (Kic kic : kics) {
            CelestialObjectParameters celestialObjectParameters = new CelestialObjectParameters.Builder(
                kic).build();
            celestialObjectParametersList.add(celestialObjectParameters);
        }

        return celestialObjectParametersList;
    }

    private List<Star> createStars(
        List<CelestialObjectParameters> celestialObjectParametersList) {

        List<Star> stars = new ArrayList<Star>();
        for (CelestialObjectParameters celestialObjectParameters : celestialObjectParametersList) {
            Star star = new Star(celestialObjectParameters.getKeplerId(),
                celestialObjectParameters.getRa()
                    .getValue(), celestialObjectParameters.getDec()
                    .getValue());
            stars.add(star);
        }

        return stars;
    }

    protected void validate(SkyGroupGenInputs skyGroupGenInputs)
        throws IllegalAccessException {
        assertNotNull(skyGroupGenInputs);
        ReflectionEquals re = new ReflectionEquals();
        assertEquals(raDec2PixModel, skyGroupGenInputs.getRaDec2PixModel());
        re.assertEquals(stars, skyGroupGenInputs.getStars());
    }

    protected void createOutputs(SkyGroupGenInputs skyGroupGenInputs,
        SkyGroupGenOutputs skyGroupGenOutputs) {

        List<Star> stars = skyGroupGenInputs.getStars();
        for (Star star : stars) {
            star.setCcdColumn(COLUMN);
            star.setCcdModule(MODULE);
            star.setCcdOutput(OUTPUT);
            star.setCcdRow(ROW);
        }
        skyGroupGenOutputs.setStars(stars);

        if (unitTestDescriptor.isValidateOutputs()) {
        }
    }

    private PipelineTask createPipelineTask(long pipelineTaskId,
        int startKeplerId, int endKeplerId) {
        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineInstance instance = createPipelineInstance();
        PipelineDefinitionNode definitionNode = new PipelineDefinitionNode(
            moduleDefinition.getName());
        PipelineTask task = new PipelineTask(instance, definitionNode,
            createPipelineInstanceNode(moduleDefinition, instance,
                definitionNode));
        task.setId(pipelineTaskId);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUowTask(
            startKeplerId, endKeplerId)));
        task.setPipelineDefinitionNode(definitionNode);

        return task;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition() {
        PipelineModuleDefinition moduleDefinition = new PipelineModuleDefinition(
            SkyGroupGenPipelineModule.MODULE_NAME);
        moduleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            SkyGroupGenPipelineModule.class));
        moduleDefinition.setExeName("dv");

        return moduleDefinition;
    }

    private PipelineInstance createPipelineInstance() {
        PipelineInstance instance = new PipelineInstance();
        instance.setId(INSTANCE_ID);

        ParameterSet parameterSet = new ParameterSet("cadenceType");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new CadenceTypePipelineParameters(CadenceType.LONG)));
        instance.putParameterSet(new ClassWrapper<Parameters>(
            CadenceTypePipelineParameters.class), parameterSet);

        ParameterSet kicGroup = new ParameterSet("kicGroup");
        kicGroup.setParameters(new BeanWrapper<Parameters>(new KicGroup(1, 2, 3, 4, MJD)));
        instance.putParameterSet(new ClassWrapper<Parameters>(
            KicGroup.class), kicGroup);

        return instance;
    }

    private PipelineInstanceNode createPipelineInstanceNode(
        final PipelineModuleDefinition moduleDefinition,
        final PipelineInstance instance,
        final PipelineDefinitionNode definitionNode) {

        PipelineInstanceNode instanceNode = new PipelineInstanceNode(instance,
            definitionNode, moduleDefinition);

        return instanceNode;
    }

    private UnitOfWorkTask createUowTask(int startKeplerId, int endKeplerId) {

        KicGroupUowTask uowTask = new KicGroupUowTask(startKeplerId,
            endKeplerId);

        return uowTask;
    }
}