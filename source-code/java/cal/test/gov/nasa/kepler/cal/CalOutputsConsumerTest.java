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

import java.io.File;
import java.util.*;

import gov.nasa.kepler.cal.io.BlackResidualTimeSeries;
import gov.nasa.kepler.cal.io.CalCollateralCosmicRay;
import gov.nasa.kepler.cal.io.CalCompressionTimeSeries;
import gov.nasa.kepler.cal.io.CalCosmicRayMetrics;
import gov.nasa.kepler.cal.io.CalMetricsTimeSeries;
import gov.nasa.kepler.cal.io.CalOutputPixelTimeSeries;
import gov.nasa.kepler.cal.io.CalOutputs;
import gov.nasa.kepler.cal.io.CalTargetMetricsTimeSeries;
import gov.nasa.kepler.cal.io.CalibratedCollateralPixels;
import gov.nasa.kepler.cal.io.CalibratedSmearTimeSeries;
import gov.nasa.kepler.cal.io.CollateralMetrics;
import gov.nasa.kepler.cal.io.CosmicRayEvents;
import gov.nasa.kepler.cal.io.CosmicRayMetrics;
import gov.nasa.kepler.cal.io.EmbeddedPipelineInfo;
import gov.nasa.kepler.cal.io.SingleResidualBlackTimeSeries;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.*;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.CosmicRayEraser;
import gov.nasa.kepler.mc.MjdTimeSeriesArrayMatcher;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.TimeSeriesArrayMatcher;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.pmrf.SciencePmrfTable;
import gov.nasa.kepler.services.alert.AlertService;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Lists;

import static gov.nasa.kepler.mc.fs.CalFsIdFactory.*;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType.*;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType.*;
import static java.util.Collections.singletonList;
import static java.util.Collections.emptyList;
import static gov.nasa.kepler.common.CollateralType.*;


/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class CalOutputsConsumerTest {

    private Mockery mockery;
    
    private final int ccdModule = 2;
    private final int ccdOutput = 1;
    private final int startCadence = 200;
    private final int endCadence = 300;
    private final long originator = 2523532453L;
    private final int ttableId = 33;
    private final int lcTargetTableId = ttableId;
    private final int bkgTargetTableId = 55;
    private final float ldeMetricsFill = 1.5f;
    private final float twoDMetricsFill = 2.5f;
    private final ModuleAlert alert = new ModuleAlert("Ignore me, since that is what you are going to do anyway.");
    private final CadenceType cadenceType = CadenceType.LONG;
    private final EmbeddedPipelineInfo pipelineInfo = 
        new EmbeddedPipelineInfo(ccdModule, ccdOutput, startCadence,
            endCadence, originator, ttableId, lcTargetTableId, bkgTargetTableId,
            cadenceType.getName());
    private final BlackAlgorithm blackAlgorithm = BlackAlgorithm.DYNABLACK;
    
    private List<TimeSeries> ldeMetrics;
    private List<TimeSeries> twoDMetrics;
    
    
    
    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void storeCollateral() {
        final TimestampSeries cadenceTimes = 
            MockUtils.mockCadenceTimes(null, null, cadenceType, startCadence, endCadence);
        
        Pixel somePixelWeDontCareAbout = new Pixel(1, 2);
        Set<Pixel> somePixelSetWeDontCareAbout = ImmutableSet.of(somePixelWeDontCareAbout);
        
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        final PmrfOperations pmrfOps = mockery.mock(PmrfOperations.class);
        final CalOutputs calOutputs = createCollateralCalOutputs(cadenceTimes, fsClient, pmrfOps);
        createPixelExpectations(pmrfOps, somePixelSetWeDontCareAbout, somePixelSetWeDontCareAbout);
        final PipelineTask pipelineTask = createPipelineTask();
        final PipelineTaskCrud pipelineTaskCrud = createPipelineTaskCrud(pipelineTask);

        final AlertService alertService = mockery.mock(AlertService.class);
        final CalCrud calCrud = mockery.mock(CalCrud.class);
        final CalProcessingCharacteristics calPc =
            new CalProcessingCharacteristics(startCadence, endCadence, cadenceType,
                pipelineTask, blackAlgorithm, ccdModule, ccdOutput);
        mockery.checking(new Expectations() {{
            one(calCrud).create(calPc);
        }});
        
        
        CalOutputsConsumer outputsConsumer = new CalOutputsConsumer() {
            @Override
            protected AlertService getAlertService() {
                return alertService;
            }
            @Override
            protected PmrfOperations getPmrfOps() {
                return pmrfOps;
            }
            @Override
            protected FileStoreClient getFsClient() {
                return fsClient;
            }
            @Override
            protected CalCrud getCalCrud() {
                return calCrud;
            }
            @Override
            protected PipelineTaskCrud getPipelineTaskCrud() {
                return pipelineTaskCrud;
            }
            @Override
            protected TimestampSeries getCadenceTimes(CadenceType cadenceType,
                PipelineInstance calPipelineInstance, int startCadence, int endCadence) {
                return cadenceTimes;
            }
            
            @Override
            protected CosmicRayEraser getCosmicRayEraser(
                List<FloatMjdTimeSeries> cosmicRaySeries, List<FsId> allIds) {
                return new CosmicRayEraser(cosmicRaySeries, allIds) {
                    @Override
                    protected FileStoreClient getFileStoreClient() {
                        return fsClient;
                    }
                };
            }
        };
        
        outputsConsumer.storeOutputs(calOutputs, new File("/dev/null"));
    }
    
    @Test
    public void storePhotometric() {

        final TimestampSeries cadenceTimes = 
            MockUtils.mockCadenceTimes(null, null, cadenceType, startCadence, endCadence);
        final PmrfOperations pmrfOps = mockery.mock(PmrfOperations.class);
        
        //Sets share one pixel of overlap.
        Pixel px0 = new Pixel(234, 333);
        Pixel px1 = new Pixel(567, 111);
        Pixel px2 = new Pixel(890, 444);
        Set<Pixel> targetPixels = ImmutableSet.of(px0, px1);
        Set<Pixel> backgroundPixels = ImmutableSet.of(px1, px2);
        
        File blobDir = new File("/dev/null");
        File oneDBlackFile = new File(blobDir, "1dblack.mat");
        File ummFile = new File(blobDir, "umm.mat");
        File smearFile= new File(blobDir, "smear.mat");
        
        CalOutputs calOutputs = createCalOutputs(oneDBlackFile, ummFile, smearFile, px0, px1, px2);
        createPixelExpectations(pmrfOps, targetPixels, backgroundPixels);
        final PipelineTask pipelineTask = createPipelineTask();
        final PipelineTaskCrud pipelineTaskCrud = createPipelineTaskCrud(pipelineTask);
        final CalCrud calCrud = createCalCrud(pipelineTask);
        final FileStoreClient fsClient = 
            createFileStoreClient(oneDBlackFile, ummFile, smearFile, 
                targetPixels, backgroundPixels, px0, px1, px2);
        final AlertService alertService = createAlertService();
        
        CalOutputsConsumer calOutputsConsumer = new CalOutputsConsumer() {
            @Override
            protected TimestampSeries getCadenceTimes(CadenceType cadenceType, 
                PipelineInstance calPipelineInstance, int startCadence, int endCadence) {
                return cadenceTimes;
            }
            
            
            @Override
            protected PipelineTaskCrud getPipelineTaskCrud() {
                return pipelineTaskCrud;
            }
            
            @Override
            protected CalCrud getCalCrud() {
                return calCrud;
            }
            
            @Override
            protected FileStoreClient getFsClient() {
                return fsClient;
            }
            
            @Override
            protected PmrfOperations getPmrfOps() {
                return pmrfOps;
            }
            
            @Override
            protected AlertService getAlertService() {
                return alertService;
            }
        };
       

        calOutputsConsumer.storeOutputs(calOutputs, blobDir);
        
    }
    
    private FileStoreClient createFileStoreClient(
        final File oneDBlackFile, final File ummFile, final File smearFile,
        Set<Pixel> targetPixels,Set<Pixel> backgroundPixels, Pixel... pixels) {
        
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        final FsId ummBlobId = CalFsIdFactory.getUncertaintyTransformBlobFsId(cadenceType, ccdModule, ccdOutput, originator);
        final FsId oneDBlackBlobId = CalFsIdFactory.getOneDBlackFitBlobFsId(cadenceType, ccdModule, ccdOutput, originator);
        final FsId smearBlobId = CalFsIdFactory.getSmearBlobFsId(cadenceType, ccdModule, ccdOutput, originator);

        List<TimeSeries> timeSeries = Lists.newArrayList();
        for (Pixel px : pixels) {
            if (targetPixels.contains(px)) {
                addExpectedTimeSeries(timeSeries, TargetType.LONG_CADENCE, px);
            }
            if (backgroundPixels.contains(px)) {
                addExpectedTimeSeries(timeSeries, TargetType.BACKGROUND, px);
            }
        }
        
        //Target metric time series
        timeSeries.addAll(ldeMetrics);
        timeSeries.addAll(twoDMetrics);
        
        final TimeSeriesArrayMatcher matcher = new TimeSeriesArrayMatcher(timeSeries);
        
        mockery.checking(new Expectations() {{
            one(fsClient).writeBlob(ummBlobId, originator, ummFile);
            
            one(fsClient).writeBlob(oneDBlackBlobId, originator, oneDBlackFile);
            
            one(fsClient).writeTimeSeries(with(matcher));
            
            one(fsClient).writeBlob(smearBlobId, originator, smearFile);
        }});
        
        return fsClient;
    }

    private void addExpectedTimeSeries(List<TimeSeries> timeSeries, TargetType targetType, Pixel px) {
        FsId calId = getTimeSeriesFsId(SOC_CAL, targetType, ccdModule, ccdOutput, px.getRow(), px.getColumn());
        FsId ummId = getTimeSeriesFsId(SOC_CAL_UNCERTAINTIES, targetType, ccdModule, ccdOutput, px.getRow(), px.getColumn());
        float[] data = new float[endCadence - startCadence + 1];
        Arrays.fill(data, px.getRow());
        float[] ummData = new float[data.length];
        Arrays.fill(ummData, data[0] + 1.1f);
        boolean[] gaps = new boolean[data.length];
        
        FloatTimeSeries calSeries = 
            new FloatTimeSeries(calId, data, startCadence, endCadence, gaps, originator);
        FloatTimeSeries ummSeries = 
            new FloatTimeSeries(ummId, ummData, startCadence, endCadence, gaps, originator);
        timeSeries.add(calSeries);
        timeSeries.add(ummSeries);
    }

    private CalCrud createCalCrud(final PipelineTask pipelineTask) {
        final CalCrud calCrud = mockery.mock(CalCrud.class);
        
        //We need to have actual ids b/c they are used by the cadence
        //blob calculator to determine which blobs get deleted.
        final CalOneDBlackFitMetadata deleteMe = 
            new CalOneDBlackFitMetadata(originator - 1, startCadence,
                endCadence, cadenceType, ccdModule, ccdOutput, ".mat");
        deleteMe.testSetId(1);
        
        
        final CalOneDBlackFitMetadata newBlobMetadata =
            new CalOneDBlackFitMetadata(originator, startCadence, endCadence,
                cadenceType, ccdModule, ccdOutput, ".mat");
        newBlobMetadata.testSetId(2);
        
        
        final UncertaintyTransformationMetadata deleteUmm =
            new UncertaintyTransformationMetadata(originator - 1, startCadence, endCadence,
                cadenceType, ccdModule, ccdOutput, ".mat");
        deleteUmm.testSetId(3);
        
        final UncertaintyTransformationMetadata createUmm = 
            new UncertaintyTransformationMetadata(originator, startCadence, endCadence,
                cadenceType, ccdModule, ccdOutput, ".mat");
        createUmm.testSetId(4);
        
        final SmearMetadata deleteSmear = 
            new SmearMetadata(originator - 1, startCadence,
                endCadence, cadenceType, ccdModule, ccdOutput, ".mat");
        deleteSmear.testSetId(5);
        
        
        final SmearMetadata newSmear =
            new SmearMetadata(originator, startCadence, endCadence,
                cadenceType, ccdModule, ccdOutput, ".mat");
        newSmear.testSetId(6);
        
        
        final CalProcessingCharacteristics calPc =
            new CalProcessingCharacteristics(startCadence, endCadence, cadenceType, pipelineTask,
                BlackAlgorithm.DYNABLACK, ccdModule, ccdOutput);
        
        mockery.checking(new Expectations() {{
            one(calCrud).retrieveCalBlobByModOut(ccdModule, ccdOutput, startCadence, endCadence, cadenceType, CalOneDBlackFitMetadata.class);
            will(returnValue(singletonList(deleteMe)));
            
            one(calCrud).delete(deleteMe);
            
            one(calCrud).create(newBlobMetadata);
            
            one(calCrud).retrieveCalBlobByModOut(ccdModule, ccdOutput, startCadence, endCadence, cadenceType, UncertaintyTransformationMetadata.class);
            will(returnValue(singletonList(deleteUmm)));

            one(calCrud).delete(deleteUmm);
            
            one(calCrud).create(createUmm);
            
            one(calCrud).retrieveCalBlobByModOut(ccdModule, ccdOutput, startCadence, endCadence, cadenceType, SmearMetadata.class);
            will(returnValue(singletonList(deleteSmear)));
            
            one(calCrud).delete(deleteSmear);
            
            one(calCrud).create(newSmear);
            
            one(calCrud).create(calPc);
        }});
        
        return calCrud;
    }
    
    private PipelineTask createPipelineTask() {
        final PipelineTask pipelineTask = mockery.mock(PipelineTask.class);
        final PipelineInstance pipelineInstance = mockery.mock(PipelineInstance.class);
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(pipelineTask).getId();
            will(returnValue(originator));
            
            one(pipelineTask).getPipelineInstance();
            will(returnValue(pipelineInstance));
        }});
        
        return pipelineTask;
    }
    
    private PipelineTaskCrud createPipelineTaskCrud(final PipelineTask pipelineTask) {
        final PipelineTaskCrud pipelineTaskCrud = mockery.mock(PipelineTaskCrud.class);
        mockery.checking(new Expectations() {{
            one(pipelineTaskCrud).retrieve(originator);
            will(returnValue(pipelineTask));
        }});
        return pipelineTaskCrud;
    }
    
    private void createPixelExpectations(final PmrfOperations pmrfOps,
        Set<Pixel> targetPixels, Set<Pixel> backgroundPixels) {
        
        final SciencePmrfTable sciPixels = 
            CalPipelineModuleTest.pixelSetToPmrfTable(targetPixels, TargetType.LONG_CADENCE, ccdModule, ccdOutput);
        
        final SciencePmrfTable bkgPixels = 
            CalPipelineModuleTest.pixelSetToPmrfTable(backgroundPixels, TargetType.BACKGROUND, ccdModule, ccdOutput);
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(pmrfOps).getBackgroundPmrfTable(bkgTargetTableId, ccdModule, ccdOutput);
            will(returnValue(bkgPixels));
            
            atLeast(1).of(pmrfOps).getSciencePmrfTable(cadenceType, ttableId, ccdModule, ccdOutput);
            will(returnValue(sciPixels));
        }});
    }
    
    /**
     * So this test scenario is somewhat unrealistic since we have the
     * masked black and virtual black time series as long
     * cadence.  When these should only appear in short cadence
     * results.
     * @param fileStoreTimeSeries
     * @return
     */
    private CalibratedCollateralPixels calibratedCollateral(List<TimeSeries> fileStoreTimeSeries) {
        float[] values = new float[endCadence - startCadence + 1];
        Arrays.fill(values, 1.1f);
        float[] uncertainties = new float[values.length];
        Arrays.fill(uncertainties, 2.2f);
        boolean[] gaps = new boolean[values.length];

        BlackResidualTimeSeries black =
            new BlackResidualTimeSeries(1, values, uncertainties, gaps);
        FsId id = getCalibratedCollateralFsId(BLACK_LEVEL, SOC_CAL, cadenceType, ccdModule, ccdOutput, black.getRow());
        fileStoreTimeSeries.add(
            new FloatTimeSeries(id, black.getValues(), startCadence, endCadence, gaps, originator));
        id = getCalibratedCollateralFsId(BLACK_LEVEL, SOC_CAL_UNCERTAINTIES, cadenceType, ccdModule, ccdOutput, black.getRow());
        fileStoreTimeSeries.add(
            new FloatTimeSeries(id, black.getUncertainties(), startCadence, endCadence, gaps, originator));
        
        values = new float[values.length];
        Arrays.fill(values, 3.3f);
        SingleResidualBlackTimeSeries maskedBlack = 
            new SingleResidualBlackTimeSeries(values, uncertainties, gaps);
        id = getCalibratedCollateralFsId(BLACK_MASKED, SOC_CAL, cadenceType, ccdModule, ccdOutput, 0);
        fileStoreTimeSeries.add( new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getCalibratedCollateralFsId(BLACK_MASKED, SOC_CAL_UNCERTAINTIES, cadenceType, ccdModule, ccdOutput, 0);
        fileStoreTimeSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        values = new float[values.length];
        Arrays.fill(values, 4.4f);
        SingleResidualBlackTimeSeries virtualBlack =
            new SingleResidualBlackTimeSeries(values, uncertainties, gaps);
        id = getCalibratedCollateralFsId(BLACK_VIRTUAL, SOC_CAL, cadenceType, ccdModule, ccdOutput, 0);
        fileStoreTimeSeries.add(new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getCalibratedCollateralFsId(BLACK_VIRTUAL, SOC_CAL_UNCERTAINTIES, cadenceType, ccdModule, ccdOutput, 0);
        fileStoreTimeSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        values = new float[values.length];
        Arrays.fill(values, 5.5f);
        CalibratedSmearTimeSeries maskedSmear = 
            new CalibratedSmearTimeSeries(5, values, uncertainties, gaps);
        id = getCalibratedCollateralFsId(MASKED_SMEAR, SOC_CAL, cadenceType, ccdModule, ccdOutput, maskedSmear.getColumn());
        fileStoreTimeSeries.add(new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getCalibratedCollateralFsId(MASKED_SMEAR, SOC_CAL_UNCERTAINTIES, cadenceType, ccdModule, ccdOutput, maskedSmear.getColumn());
        fileStoreTimeSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        
        values = new float[values.length];
        Arrays.fill(values, 6.6f);
        CalibratedSmearTimeSeries virtualSmear = 
            new CalibratedSmearTimeSeries(6, values, uncertainties, gaps);
        id = getCalibratedCollateralFsId(VIRTUAL_SMEAR, SOC_CAL, cadenceType, ccdModule, ccdOutput, virtualSmear.getColumn());
        fileStoreTimeSeries.add(new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getCalibratedCollateralFsId(VIRTUAL_SMEAR, SOC_CAL_UNCERTAINTIES, cadenceType, ccdModule, ccdOutput, virtualSmear.getColumn());
        fileStoreTimeSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        return new CalibratedCollateralPixels(singletonList(black),
                virtualBlack, maskedBlack,
                singletonList(virtualSmear),
                singletonList(maskedSmear));
        
    }
    
    private CosmicRayEvents cosmicRayEvents(TimestampSeries cadenceTimes, List<FloatMjdTimeSeries> fileStoreSeries) {
        double crTime = cadenceTimes.midTimestamps[1];
        double[] mjds = new double[] { crTime };
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();
        CalCollateralCosmicRay blackCr = 
            new CalCollateralCosmicRay(crTime, 1, 1.1f);
        FsId id = getCosmicRaySeriesFsId(BLACK_LEVEL, cadenceType, ccdModule, ccdOutput, blackCr.getRowOrColumn());
        fileStoreSeries.add(new FloatMjdTimeSeries(id, startMjd, endMjd, mjds, new float[] { blackCr.getDelta() }, originator));
        
        CalCollateralCosmicRay virtualBlackCr = 
            new CalCollateralCosmicRay(crTime, 2, 2.2f);
        id = getCosmicRaySeriesFsId(BLACK_VIRTUAL, cadenceType, ccdModule, ccdOutput, virtualBlackCr.getRowOrColumn());
        fileStoreSeries.add(new FloatMjdTimeSeries(id, startMjd, endMjd, mjds, new float[] { virtualBlackCr.getDelta() }, originator));
        
        CalCollateralCosmicRay maskedBlackCr = 
            new CalCollateralCosmicRay(crTime, 3, 3.3f);
        id = getCosmicRaySeriesFsId(BLACK_MASKED, cadenceType, ccdModule, ccdOutput, maskedBlackCr.getRowOrColumn());
        fileStoreSeries.add(new FloatMjdTimeSeries(id, startMjd, endMjd, mjds, new float[] { maskedBlackCr.getDelta() }, originator));
        
        
        CalCollateralCosmicRay virtualSmearCr = 
            new CalCollateralCosmicRay(crTime, 4, 4.4f);
        id = getCosmicRaySeriesFsId(VIRTUAL_SMEAR, cadenceType, ccdModule, ccdOutput, virtualSmearCr.getRowOrColumn());
        fileStoreSeries.add(new FloatMjdTimeSeries(id, startMjd, endMjd, mjds, new float[] { virtualSmearCr.getDelta() }, originator));
        
        
        CalCollateralCosmicRay maskedSmearCr =
            new CalCollateralCosmicRay(crTime, 5, 5.5f);
        id = getCosmicRaySeriesFsId(MASKED_SMEAR, cadenceType, ccdModule, ccdOutput, maskedSmearCr.getRowOrColumn());
        fileStoreSeries.add(new FloatMjdTimeSeries(id, startMjd, endMjd, mjds, new float[] { maskedSmearCr.getDelta() }, originator));
        
        return
            new CosmicRayEvents(singletonList(virtualSmearCr), singletonList(maskedSmearCr),
                singletonList(blackCr), singletonList(maskedBlackCr), singletonList(virtualBlackCr));
    }
    
    private CosmicRayMetrics cosmicRayMetrics(CollateralType collateralType, 
        float metricSeed, List<TimeSeries> fileStoreSeries) {
        float[] values = new float[endCadence - startCadence + 1];
        
        boolean[] gaps = new boolean[values.length];
        float[] hitRates = new float[values.length];
        Arrays.fill(hitRates, metricSeed + 1.1f);
        FsId id = getCosmicRayMetricFsId(cadenceType, collateralType, CosmicRayMetricType.HIT_RATES, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, hitRates, startCadence, endCadence, gaps, originator));
        
        float[] meanEnergy = new float[values.length];
        Arrays.fill(meanEnergy, metricSeed + 2.2f);
        id = getCosmicRayMetricFsId(cadenceType, collateralType, CosmicRayMetricType.MEAN_ENERGY, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, meanEnergy, startCadence, endCadence, gaps, originator));
        
        float[] variance = new float[values.length];
        Arrays.fill(variance, metricSeed + 3.3f);
        id = getCosmicRayMetricFsId(cadenceType, collateralType, CosmicRayMetricType.ENERGY_VARIANCE, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, variance, startCadence, endCadence, gaps, originator));
        
        float[] skewness = new float[values.length];
        Arrays.fill(skewness, metricSeed + 4.4f);
        id = getCosmicRayMetricFsId(cadenceType, collateralType, CosmicRayMetricType.ENERGY_SKEWNESS, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, skewness, startCadence, endCadence, gaps, originator));
        
        float[] kurtosis = new float[values.length];
        Arrays.fill(kurtosis, metricSeed + 5.5f);
        id = getCosmicRayMetricFsId(cadenceType, collateralType, CosmicRayMetricType.ENERGY_KURTOSIS, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, kurtosis, startCadence, endCadence, gaps, originator));
        
        CosmicRayMetrics cosmicRayMetrics = 
            new CosmicRayMetrics(true, gaps, hitRates, //hit rates
                gaps, meanEnergy,
                gaps, variance,
                gaps, skewness,
                gaps, kurtosis);
        return cosmicRayMetrics;
    }
    
    private CalCosmicRayMetrics calCosmicRayMetrics(List<TimeSeries> fileStoreSeries) {
        CosmicRayMetrics blackLevel = cosmicRayMetrics(BLACK_LEVEL, 0f, fileStoreSeries);
        CosmicRayMetrics blackMasked = cosmicRayMetrics(BLACK_MASKED, 1f, fileStoreSeries);
        CosmicRayMetrics blackVirtual = cosmicRayMetrics(BLACK_VIRTUAL, 2f, fileStoreSeries);
        CosmicRayMetrics maskedSmear = cosmicRayMetrics(MASKED_SMEAR, 3f, fileStoreSeries);
        CosmicRayMetrics virtualSmear = cosmicRayMetrics(VIRTUAL_SMEAR, 4f, fileStoreSeries);
        
        return new CalCosmicRayMetrics(maskedSmear, virtualSmear, blackLevel, blackVirtual, blackMasked);
    }
    
    private CollateralMetrics collateralMetrics(List<TimeSeries> fileStoreSeries) {
        float[] values = new float[endCadence - startCadence + 1];
        float[] uncertainties = new float[values.length];
        boolean[] gaps = new boolean[values.length];
        
        Arrays.fill(values, 1.11f);
        CalMetricsTimeSeries blackLevelMetrics = new CalMetricsTimeSeries(values, uncertainties, gaps);
        FsId id = getMetricsTimeSeriesFsId(cadenceType, MetricsTimeSeriesType.BLACK_LEVEL, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getMetricsTimeSeriesFsId(cadenceType, MetricsTimeSeriesType.BLACK_LEVEL_UNCERTAINTIES, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        Arrays.fill(values, 2.22f);
        CalMetricsTimeSeries smearLevelMetrics = new CalMetricsTimeSeries(values, uncertainties, gaps);
        id = getMetricsTimeSeriesFsId(cadenceType, MetricsTimeSeriesType.SMEAR_LEVEL, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getMetricsTimeSeriesFsId(cadenceType, MetricsTimeSeriesType.SMEAR_LEVEL_UNCERTAINTIES, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        Arrays.fill(values, 3.33f);
        CalMetricsTimeSeries darkCurrentMetrics = new CalMetricsTimeSeries(values, uncertainties, gaps);
        id = getMetricsTimeSeriesFsId(cadenceType, MetricsTimeSeriesType.DARK_CURRENT, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, values, startCadence, endCadence, gaps, originator));
        id = getMetricsTimeSeriesFsId(cadenceType, MetricsTimeSeriesType.DARK_CURRENT_UNCERTAINTIES, ccdModule, ccdOutput);
        fileStoreSeries.add(new FloatTimeSeries(id, uncertainties, startCadence, endCadence, gaps, originator));
        
        return new CollateralMetrics(blackLevelMetrics, smearLevelMetrics, darkCurrentMetrics);
        
    }
    private CalOutputs createCollateralCalOutputs(TimestampSeries cadenceTimes,
        final FileStoreClient fsClient, final PmrfOperations pmrfOps) {
        final CalOutputs calOutputs = mockery.mock(CalOutputs.class);
        
        List<TimeSeries> fileStoreTimeSeries = Lists.newArrayList();
        List<FloatMjdTimeSeries> fileStoreMjdTimeSeries = Lists.newArrayList();
        

        final CalibratedCollateralPixels calibratedCollateral = 
           calibratedCollateral(fileStoreTimeSeries);
       
        final CosmicRayEvents cosmicRayEvents = 
           cosmicRayEvents(cadenceTimes, fileStoreMjdTimeSeries);
       
        final List<FsId> cosmicRayIds = Lists.newArrayList();
        for (FloatMjdTimeSeries cr : fileStoreMjdTimeSeries) {
            cosmicRayIds.add(cr.id());
        }
        
        final CalCosmicRayMetrics cosmicRayMetrics = 
           calCosmicRayMetrics(fileStoreTimeSeries);
        
        final CollateralMetrics collateralMetrics = 
            collateralMetrics(fileStoreTimeSeries);
        
        final TimeSeriesArrayMatcher timeSeriesArrayMatcher = 
            new TimeSeriesArrayMatcher(fileStoreTimeSeries);
        final MjdTimeSeriesArrayMatcher mjdTimeSeriesArrayMatcher = 
            new MjdTimeSeriesArrayMatcher(fileStoreMjdTimeSeries);
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(calOutputs).getCalibratedCollateralPixels();
            will(returnValue(calibratedCollateral));
            
            atLeast(1).of(calOutputs).getCosmicRayEvents();
            will(returnValue(cosmicRayEvents));
            
            atLeast(1).of(calOutputs).getCosmicRayMetrics();
            will(returnValue(cosmicRayMetrics));
            
            atLeast(1).of(calOutputs).getAlerts();
            will(returnValue(emptyList()));
            
            atLeast(1).of(calOutputs).getCollateralMetrics();
            will(returnValue(collateralMetrics));
            
            atLeast(1).of(calOutputs).getOneDBlackFitBlobFileName();
            will(returnValue(""));
            
            atLeast(1).of(calOutputs).getUncertaintyBlobFileName();
            will(returnValue(""));
            
            atLeast(1).of(calOutputs).smearBlobFileName();
            will(returnValue(""));
            
            atLeast(1).of(calOutputs).getTheoreticalCompressionEfficiency();
            will(returnValue(new CalCompressionTimeSeries()));
            
            atLeast(1).of(calOutputs).getAchievedCompressionEfficiency();
            will(returnValue(new CalCompressionTimeSeries()));
            
            atLeast(1).of(calOutputs).pipelineInfoStruct();
            will(returnValue(pipelineInfo));
            
            atLeast(1).of(calOutputs).getTargetAndBackgroundPixels();
            will(returnValue(emptyList()));
            
            atLeast(1).of(calOutputs).getLdeUndershootMetrics();
            will(returnValue(emptyList()));
            
            atLeast(1).of(calOutputs).getTwoDBlackMetrics();
            will(returnValue(emptyList()));
            
            one(fsClient).writeTimeSeries(with(timeSeriesArrayMatcher));
            
            one(fsClient).writeMjdTimeSeries(with(mjdTimeSeriesArrayMatcher));

            atLeast(1).of(pmrfOps).getCollateralCosmicRayFsIds(cadenceType, ttableId, ccdModule, ccdOutput);
            will(returnValue(cosmicRayIds));
            
            atLeast(1).of(calOutputs).blackAlgorithmApplied();
            will(returnValue(blackAlgorithm));
        }});
        
        return calOutputs;
    }
    
    private CalOutputs createCalOutputs(final File oneDBlackFile,
            final File ummFile, final File smearFile,
            Pixel... pixels) {
        final CalOutputs calOutputs = mockery.mock(CalOutputs.class);
        
        float[] lde = new float[endCadence - startCadence + 1];
        float[] ldeUmm = new float[lde.length];
        boolean[] gaps = new boolean[lde.length];
        Arrays.fill(lde, ldeMetricsFill);
        final CalTargetMetricsTimeSeries ldeMetrics = 
            new CalTargetMetricsTimeSeries(lde, ldeUmm, gaps, 777);
        this.ldeMetrics = Lists.newArrayList();
        this.ldeMetrics.add(new FloatTimeSeries(getTargetMetricsTimeSeriesFsId(cadenceType, UNDERSHOOT, ccdModule, ccdOutput, 777),
            lde, startCadence, endCadence, gaps, originator));
        this.ldeMetrics.add(new FloatTimeSeries(getTargetMetricsTimeSeriesFsId(cadenceType, UNDERSHOOT_UNCERTAINTIES, ccdModule, ccdOutput, 777),
            ldeUmm, startCadence, endCadence, gaps, originator));
        float[] twoD = new float[lde.length];
        Arrays.fill(twoD, twoDMetricsFill);
        final CalTargetMetricsTimeSeries twoDMetrucs =
            new CalTargetMetricsTimeSeries(twoD, ldeUmm, gaps, 888);
        this.twoDMetrics = Lists.newArrayList();
        this.twoDMetrics.add(new FloatTimeSeries(getTargetMetricsTimeSeriesFsId(cadenceType, TWOD_BLACK, ccdModule, ccdOutput, 888),
            twoD, startCadence, endCadence, gaps, originator));
        this.twoDMetrics.add(new FloatTimeSeries(getTargetMetricsTimeSeriesFsId(cadenceType, TWOD_BLACK_UNCERTAINTIES, ccdModule, ccdOutput, 888),
            ldeUmm, startCadence, endCadence, gaps, originator));
        
        final List<CalOutputPixelTimeSeries> tnbOutputTimeSeries = Lists.newArrayList();
        for (Pixel px : pixels) {
            float[] data = new float[endCadence - startCadence + 1];
            Arrays.fill(data, px.getRow());
            float[] umm = new float[data.length];
            Arrays.fill(umm, data[0] + 1.1f);
            tnbOutputTimeSeries.add(new CalOutputPixelTimeSeries(px.getRow(), px.getColumn(), data, umm, gaps));
        }
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(calOutputs).pipelineInfoStruct();
            will(returnValue(pipelineInfo));
            
            atLeast(1).of(calOutputs).getCalibratedCollateralPixels();
            will(returnValue(new CalibratedCollateralPixels()));
            
            atLeast(1).of(calOutputs).getAchievedCompressionEfficiency();
            will(returnValue(new CalCompressionTimeSeries()));
            
            atLeast(1).of(calOutputs).getTheoreticalCompressionEfficiency();
            will(returnValue(new CalCompressionTimeSeries()));
            
            atLeast(1).of(calOutputs).getCosmicRayMetrics();
            will(returnValue(new CalCosmicRayMetrics()));
            
            atLeast(1).of(calOutputs).getCollateralMetrics();
            will(returnValue(new CollateralMetrics()));
            
            atLeast(1).of(calOutputs).getOneDBlackFitBlobFileName();
            will(returnValue(oneDBlackFile.getName()));
            
            atLeast(1).of(calOutputs).getUncertaintyBlobFileName();
            will(returnValue(ummFile.getName()));
            
            atLeast(1).of(calOutputs).smearBlobFileName();
            will(returnValue(smearFile.getName()));
            
            atLeast(1).of(calOutputs).getTargetAndBackgroundPixels();
            will(returnValue(tnbOutputTimeSeries));
            
            atLeast(1).of(calOutputs).getLdeUndershootMetrics();
            will(returnValue(singletonList(ldeMetrics)));
            
            atLeast(1).of(calOutputs).getTwoDBlackMetrics();
            will(returnValue(singletonList(twoDMetrucs)));
            
            atLeast(1).of(calOutputs).getAlerts();
            will(returnValue(singletonList(alert)));
            
            atLeast(1).of(calOutputs).blackAlgorithmApplied();
            will(returnValue(BlackAlgorithm.DYNABLACK));
        }});
        return calOutputs;
    }
    
    private AlertService createAlertService() {
        final AlertService alertService = mockery.mock(AlertService.class);
        mockery.checking(new Expectations() {{
            one(alertService).generateAlert(with("cal"), with(originator), with(AlertService.Severity.ERROR), 
                with(aNonNull(String.class)));
        }});
        return alertService;
    }
    
}
