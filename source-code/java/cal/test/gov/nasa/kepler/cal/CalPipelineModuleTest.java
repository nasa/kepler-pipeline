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

package gov.nasa.kepler.cal;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.cal.io.CalCosmicRayParameters;
import gov.nasa.kepler.cal.io.CalHarmonicsIdentificationParameters;
import gov.nasa.kepler.cal.io.CalInputs;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.cal.io.CalOutputs;
import gov.nasa.kepler.cal.io.CommonParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.QuarterToParameterValueMap;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.pmrf.SciencePmrfTable;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.module.*;

import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;

@RunWith(JMock.class)
public class CalPipelineModuleTest {

    private final int startCadence = 100;
    private final int endCadence = 200;
    private final CadenceType cadenceType = CadenceType.LONG;
    private final int ccdModule = 2;
    private final int ccdOutput = 1;
    private final int maxChunkSize = 2000;
    private final long originator = 1121;
    private final long pipelineTaskId = 234234324L;
    private final int ttableId = 555;
    private final int bkgTtableId= 777;

    private String quarter = "3";
    private List<String> quartersList = newArrayList(quarter);

    private String value = "value";
    private List<String> values = newArrayList(value);

    private Mockery mockery;
    
    @Before
    public void setup() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void calPipelineModuleTest() throws Exception {
        Pixel px0 = new Pixel(5, 6, 
            DrFsIdFactory.getSciencePixelTimeSeries(TimeSeriesType.ORIG, 
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, 5, 6));
                
        Pixel px1 = new Pixel(6, 7, 
            DrFsIdFactory.getSciencePixelTimeSeries(TimeSeriesType.ORIG,
                TargetType.BACKGROUND, ccdModule, ccdOutput, 6, 7));
        
        Set<Pixel> tnbPixels = ImmutableSet.of(px0, px1);
        Set<Pixel> targetPixels = ImmutableSet.of(px0);
        Set<Pixel> bkgPixels = ImmutableSet.of(px1);
        Map<FsId, Pixel> fsIdToPixel = ImmutableMap.of(px0.getFsId(), px0, px1.getFsId(), px1);
        
        CalModuleParameters calModuleParameters = new CalModuleParameters();
        calModuleParameters.setMaxCalibrateFsIds(maxChunkSize);
        calModuleParameters.setBlackAlgorithmQuarters(quarter);
        calModuleParameters.setBlackAlgorithm(value);
        
        final File blobDir = new File("/dev/null");
        
        final CalOutputsConsumer outputsConsumer = 
            createCalOutputsConsumer(blobDir);
        
        final PmrfOperations pmrfOps = createPmrfOps(tnbPixels, targetPixels, bkgPixels);
        
        final PipelineTask pipelineTask = createPipelineTask(calModuleParameters);
        final CommonParameters commonParameters = createCommonParameters(calModuleParameters);
        
        final CalWorkParticleFactory calWorkParticleFactory = 
            createCalWorkParticleFactory(tnbPixels, fsIdToPixel);
        final DataAccountabilityTrailCrud daTrailCrud = createDaTrailCrud();
        
        final ProducerTaskIdsStream ptis = createProducerTaskIdsStream(blobDir);
        
        final CalPipelineModule calPipelineModule = new CalPipelineModule() {
            
            @Override
            protected PmrfOperations createPmrfOperations(CommonParameters commonParameters) {
                return pmrfOps;
            }
            
            @Override
            protected QuarterToParameterValueMap quarterToParameterValueMap() {
                return createParameterValues();
            }
            
            @Override
            protected DataAccountabilityTrailCrud getDaTrailCrud() {
                return daTrailCrud;
            }
            
            @Override
            protected CalWorkParticleFactory createCalWorkParticleFactory(CommonParameters commonParameters) {
                return calWorkParticleFactory;
            }
            
            @Override
            protected CalOutputsConsumer createCalOutputsConsumer() {
                return outputsConsumer;
            }
            
            @Override
            protected CommonParameters createCommonParameters(PipelineTask pipelineTask,
                CadenceType cadenceType,
                int startCadence, int endCadence, int ccdModule, int ccdOutput,
                File blobOutputDir, CalModuleParameters calModuleParameters,
                PouModuleParameters pouModuleParameters,
                CalCosmicRayParameters calCosmicRayParameters,
                CalHarmonicsIdentificationParameters harmonicsParameters,
                GapFillModuleParameters gapFillParameters) {
                return commonParameters;
            }

            @Override
            protected ProducerTaskIdsStream createProducerTaskIdsStream() {
                return ptis;
            }

        };
        
        final InputsGroup inputsGroup = mockery.mock(InputsGroup.class);
        final InputsHandler inputsHandler = mockery.mock(InputsHandler.class);
        mockery.checking(new Expectations() {{
            one(inputsHandler).createGroup();
            will(returnValue(inputsGroup));
            one(inputsGroup).add(0, 0);
            one(inputsGroup).add(1, 1);
            one(inputsGroup).add(2, 2);
            exactly(3).of(inputsGroup).addSubTaskInputs(with(aNonNull(CalInputs.class)));
        }});
        
        calPipelineModule.generateInputs(inputsHandler, pipelineTask, blobDir);
        
        List<AlgorithmResults> resultsList = Lists.newArrayList();
        for (int i=0; i < 3; i++) {
            AlgorithmResults algorithmResults = 
                    new AlgorithmResults(new CalOutputs(), blobDir, blobDir, blobDir, null);
            resultsList.add(algorithmResults);
        }
        
        calPipelineModule.processOutputs(pipelineTask, resultsList.iterator());
    }
    
    private ProducerTaskIdsStream createProducerTaskIdsStream(final File blobDir) {
        final ProducerTaskIdsStream ptis = mockery.mock(ProducerTaskIdsStream.class);
        final Set<Long> originatorSet = ImmutableSet.of(originator);
        mockery.checking(new Expectations() {{
            one(ptis).write(blobDir, originatorSet);
            one(ptis).read(blobDir);
            will(returnValue(originatorSet));
        }});
        return ptis;
    }
    
    private CalOutputsConsumer createCalOutputsConsumer(final File outputDir) {
        final CalOutputsConsumer outputsConsumer = mockery.mock(CalOutputsConsumer.class);
        mockery.checking(new Expectations() {{
            exactly(3).of(outputsConsumer).storeOutputs(new CalOutputs(), outputDir);
        }});
        return outputsConsumer;
    }
    
    static SciencePmrfTable pixelSetToPmrfTable(Set<Pixel> pixels, 
        TargetType targetType, int ccdModule, int ccdOutput) {
        
        short[] ccdRowsTargetPixels = new short[pixels.size()];
        short[] ccdColsTargetPixels = new short[pixels.size()];
        int pmrfTableIndex = 0;
        for (Pixel px : pixels) {
            ccdRowsTargetPixels[pmrfTableIndex] = (short) px.getRow();
            ccdColsTargetPixels[pmrfTableIndex++] = (short) px.getColumn();
        }
        return new SciencePmrfTable(targetType, ccdModule, ccdOutput,
            ccdRowsTargetPixels, ccdColsTargetPixels);
    }
    
    private PmrfOperations createPmrfOps(final Set<Pixel> tnbPixels,
        final Set<Pixel> targetPixels, final Set<Pixel> bkgPixels) {

        TargetType targetType = TargetType.valueOf(cadenceType);
        final SciencePmrfTable targetPmrf = pixelSetToPmrfTable(targetPixels, targetType, ccdModule, ccdOutput);
        final SciencePmrfTable backgroundPmrf = pixelSetToPmrfTable(bkgPixels, TargetType.BACKGROUND, ccdModule, ccdOutput);
        
        final PmrfOperations pmrfOps = mockery.mock(PmrfOperations.class);
        mockery.checking(new Expectations() {{
            one(pmrfOps).getSciencePmrfTable(cadenceType, ttableId, ccdModule, ccdOutput);
            will(returnValue(targetPmrf));
            
            one(pmrfOps).getBackgroundPmrfTable(bkgTtableId, ccdModule, ccdOutput);
            will(returnValue(backgroundPmrf));
        }});
        return pmrfOps;
    }

    private DataAccountabilityTrailCrud createDaTrailCrud() {
        final DataAccountabilityTrailCrud daTrailCrud = mockery.mock(DataAccountabilityTrailCrud.class);
        final DataAccountabilityTrail expected = new DataAccountabilityTrail(pipelineTaskId);
        expected.setProducerTaskIds(Collections.singleton(originator));
        mockery.checking(new Expectations() {{
            one(daTrailCrud).create(expected);
        }});
        return daTrailCrud;
    }
        
    private QuarterToParameterValueMap createParameterValues() {
        final QuarterToParameterValueMap parameterValues = mockery.mock(QuarterToParameterValueMap.class);
        mockery.checking(new Expectations() {{
            one(parameterValues).getValue(quartersList, values, cadenceType, startCadence, endCadence);
            will(returnValue(value));
        }});
        return parameterValues;
    }
        
    private CalWorkParticleFactory createCalWorkParticleFactory(final Set<Pixel> tnbPixels, final Map<FsId, Pixel> fsIdToPixel)
    throws Exception {
        final CalWorkParticleFactory factory = mockery.mock(CalWorkParticleFactory.class);
        final CollateralWorkParticle collateralWork = mockery.mock(CollateralWorkParticle.class);
        final TargetAndBackgroundWorkParticle firstTnBWorkParticle = 
            mockery.mock(TargetAndBackgroundWorkParticle.class, "first tnb");
        final TargetAndBackgroundWorkParticle lastTnBWorkParticle = 
            mockery.mock(TargetAndBackgroundWorkParticle.class, "last tnb");
        
        List<CalWorkParticle> firstWorkList = Lists.newArrayList();
        firstWorkList.add(collateralWork);
        List<CalWorkParticle> secondWorkList = Lists.newArrayList();
        secondWorkList.add(firstTnBWorkParticle);
        List<CalWorkParticle> thirdWorkList = Lists.newArrayList();
        thirdWorkList.add(lastTnBWorkParticle);
        final Set<Long> originatorSet = ImmutableSet.of(originator);
        final List<List<CalWorkParticle>> listOfLists = 
            ImmutableList.of(firstWorkList, secondWorkList, thirdWorkList);
        
        workParticleExpectations(collateralWork, originatorSet, 0);
        workParticleExpectations(firstTnBWorkParticle, originatorSet, 1);
        workParticleExpectations(lastTnBWorkParticle, originatorSet, 2);
        
        mockery.checking(new Expectations() {{
            one(factory).create(with(equal(tnbPixels)), with(equal(fsIdToPixel)), with(equal(maxChunkSize)));
            will(returnValue(listOfLists));
        }});
        return factory;
    }
    
    private void workParticleExpectations(final CalWorkParticle workParticle,
        final Set<Long> originatorSet, final int particleNumber) throws Exception {
        mockery.checking(new Expectations() {{
            atLeast(1).of(workParticle).particleNumber();
            will(returnValue(particleNumber));
            one(workParticle).call();
            will(returnValue(workParticle));
            atLeast(1).of(workParticle).producerTaskIds();
            will(returnValue(originatorSet));
            one(workParticle).clear();
            atLeast(1).of(workParticle).calInputs();
            will(returnValue(new CalInputs()));
        }});
    }
    
    private CommonParameters createCommonParameters(final CalModuleParameters calModuleParameters) {
        final CommonParameters commonParameters = mockery.mock(CommonParameters.class);
        final TargetTable ttable = mockery.mock(TargetTable.class, "target");
        final TargetTable bkgTtable = mockery.mock(TargetTable.class, "bkg");
        mockery.checking(new Expectations() {{
            atLeast(1).of(commonParameters).moduleParametersStruct();
            will(returnValue(calModuleParameters));
            atLeast(1).of(commonParameters).backgroundTargetTable();
            will(returnValue(bkgTtable));
            atLeast(1).of(commonParameters).targetTable();
            will(returnValue(ttable));
            allowing(commonParameters).ccdModule();
            will(returnValue(ccdModule));
            allowing(commonParameters).ccdOutput();
            will(returnValue(ccdOutput));
            
            atLeast(1).of(ttable).getExternalId();
            will(returnValue(ttableId));
            
            atLeast(1).of(bkgTtable).getExternalId();
            will(returnValue(bkgTtableId));
            
        }});
        return commonParameters;
    }
    private PipelineTask createPipelineTask(final CalModuleParameters calModuleParameters) {
        final PipelineTask pipelineTask = mockery.mock(PipelineTask.class);
        
        mockery.checking(new Expectations() {{
            one(pipelineTask).getParameters(CalModuleParameters.class);
            will(returnValue(calModuleParameters));
            one(pipelineTask).getParameters(CalCosmicRayParameters.class);
            will(returnValue(new CalCosmicRayParameters()));
            one(pipelineTask).getParameters(PouModuleParameters.class);
            will(returnValue(new PouModuleParameters()));
            one(pipelineTask).getParameters(CadenceTypePipelineParameters.class);
            will(returnValue(new CadenceTypePipelineParameters(cadenceType)));
            one(pipelineTask).getParameters(CalHarmonicsIdentificationParameters.class);
            will(returnValue(new CalHarmonicsIdentificationParameters()));
            one(pipelineTask).getParameters(GapFillModuleParameters.class);
            will(returnValue(new GapFillModuleParameters()));
            atLeast(1).of(pipelineTask).uowTaskInstance();
            will(returnValue(new ModOutCadenceUowTask(ccdModule, ccdOutput, startCadence, endCadence)));
            
            atLeast(1).of(pipelineTask).getId();
            will(returnValue(pipelineTaskId));
        }});
        
        return pipelineTask;
    }
}
