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

package gov.nasa.kepler.ar.exporter.dv;

import static gov.nasa.kepler.mc.fs.DvFsIdFactory.createSingleEventStatisticsQuery;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getBarycentricCorrectedTimestampsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getCorrectedFluxTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getLightCurveTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getResidualTimeSeriesFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.getSingleEventStatisticsFsId;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.INITIAL;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.MODEL_LIGHT_CURVE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.FitsVerify;
import gov.nasa.kepler.ar.FitsVerify.FitsVerifyResults;
import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud.DvPlanetSummary;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.uow.DvResultUowTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;


/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class PlanetarySystemTimeSeriesTest {
    
    private final int minKeplerId = 4000000;
    private final int keplerId =    5000000;
    private final int maxKeplerId = 8000000;
    private final int startCadence = 1024;
    private final int endCadence = 5000;
    private final int cadenceLength = endCadence - startCadence + 1;
    private final FluxType fluxType = FluxType.DIA;
    private final long pipelineInstanceId = 7L;
    private final long pipelineTaskId = 666777888L;

    private final int planetNumber = 1;
    private final float trialTransitPulseDuration = 3.0f;
    
    private final FsId initialFsId =
        getCorrectedFluxTimeSeriesFsId(fluxType, INITIAL, 
            DvTimeSeriesType.FLUX, pipelineInstanceId, keplerId, planetNumber);
    private final FsId initialUncertFsId = 
        getCorrectedFluxTimeSeriesFsId(fluxType, INITIAL, DvTimeSeriesType.UNCERTAINTIES, pipelineInstanceId, 
            keplerId, planetNumber);
    private final FsId initialFilledId =
        getCorrectedFluxTimeSeriesFsId(fluxType, INITIAL, 
            DvTimeSeriesType.FILLED_INDICES, pipelineInstanceId,  keplerId, planetNumber);
    private final FsId residualId = 
        getResidualTimeSeriesFsId(fluxType, DvTimeSeriesType.FLUX, 
            pipelineInstanceId, keplerId);
    private final FsId residualUncertId = 
        getResidualTimeSeriesFsId(fluxType, DvTimeSeriesType.UNCERTAINTIES, 
            pipelineInstanceId, keplerId);
    private final FsId residualFilledId =
        getResidualTimeSeriesFsId(fluxType, DvTimeSeriesType.FILLED_INDICES, 
            pipelineInstanceId, keplerId);
    private final FsId sevNormId = 
            getSingleEventStatisticsFsId(fluxType, DvSingleEventStatisticsType.NORMALIZATION,
            pipelineInstanceId, keplerId,trialTransitPulseDuration);
    private final FsId sevCorrId = 
        getSingleEventStatisticsFsId(fluxType, DvSingleEventStatisticsType.CORRELATION,
            pipelineInstanceId, keplerId, trialTransitPulseDuration);
    private final FsId barycentricCorrectedTimeId = 
        getBarycentricCorrectedTimestampsFsId(fluxType, pipelineInstanceId, keplerId);
    private final FsId modeLightCurveId = 
        getLightCurveTimeSeriesFsId(fluxType, 
            MODEL_LIGHT_CURVE, pipelineInstanceId, keplerId, planetNumber);
    
    private final FitsVerify fitsVerify = new FitsVerify();
    private final File outputDir = new File(Filenames.BUILD_TEST, "PlanetarySystemTimeSeriesTest");
    
    private Mockery mockery;
    
    @Before
    public void setUp() throws Exception {
        FileUtil.mkdirs(outputDir);
        mockery = new JUnit4Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(outputDir);
    }
    
    @Test
    public void testPlanetarySystemTimeSeries() throws Exception {

        
        Set<FsId> expectedFsIdSet = createExpectedFsIdSet();

        DvPlanetSummary planetSummary = 
            new DvPlanetSummary(startCadence, endCadence, 
                new int[] { planetNumber}, keplerId, pipelineInstanceId, pipelineTaskId);
        
        List<FsId> singleEventIds = new ArrayList<FsId>();
        singleEventIds.add(sevCorrId);
        singleEventIds.add(sevNormId);
        
        PlanetarySystemTimeSeries solarSystem = 
            new PlanetarySystemTimeSeries(planetSummary, singleEventIds, fluxType);
        Set<FsId> actualIds = new HashSet<FsId>();
        solarSystem.addIds(actualIds);
    
        assertEquals(expectedFsIdSet, actualIds);

        Map<FsId, TimeSeries> timeSeries = createTimeSeries(pipelineInstanceId,
            expectedFsIdSet);
        
        TimestampSeries cadenceTimes = createCadenceTimes();
        DvTimeSeriesFitsFile fitsFile =
            solarSystem.toFluxFitsFile(timeSeries, cadenceTimes, Float.NEGATIVE_INFINITY);
        File outputFile = new File(outputDir, "output.fits");
        fitsFile.export(outputFile);
        FitsVerifyResults verificationResults = fitsVerify.verify(outputFile, true);
        assertEquals(verificationResults.output, 0, verificationResults.returnCode);
    }
    
    @Test
    public void testTimeSeriesExporter() throws Exception {
        final Set<FsId> expectedFsIdSet = createExpectedFsIdSet();
        
        final FileStoreClient fsClient = createFileStoreClient(expectedFsIdSet);
       
        final DvCrud dvCrud = createDvCrud();

        final MjdToCadence mjdToCadence = createMjdToCadence();
        
        PipelineInstance pipelineInstance = new PipelineInstance();
        final PipelineInstanceCrud pipeCrud = createPipelineInstanceCrud(pipelineInstance);
        DvTimeSeriesExporter exporter = 
            new DvTimeSeriesExporter(dvCrud, fsClient, outputDir, mjdToCadence, pipeCrud);
        exporter.export(minKeplerId, maxKeplerId, pipelineInstanceId, fluxType);
        
        FileNameFormatter fnameFormatter  = new FileNameFormatter();
        String fname = fnameFormatter.dataValidationTimeSeriesName(keplerId, pipelineInstance.getEndProcessingTime());
        File outputFile = new File(outputDir , fname);
        assertTrue(outputFile.exists());
        fitsVerify.verify(outputFile, true);
        
        assertTrue(outputFile.delete());
        
        
    }
    
    @Test
    public void testTimeSeriesExporterPipelineModule() throws Exception {
        final Set<FsId> expectedFsIdSet = createExpectedFsIdSet();
        
        final FileStoreClient fsClient = createFileStoreClient(expectedFsIdSet);
       
        final DvCrud dvCrud = createDvCrud();

        final MjdToCadence mjdToCadence = createMjdToCadence();
        
        PipelineInstance pipelineInstance = new PipelineInstance();
        final PipelineInstanceCrud pipeCrud = createPipelineInstanceCrud(pipelineInstance);
        
        final DvTimeSeriesExporterPipelineModuleParameters expParams =
            new DvTimeSeriesExporterPipelineModuleParameters();
        expParams.setNfsExportDir(outputDir.toString());

        final FluxTypeParameters fluxTypeParameters = new FluxTypeParameters();
        fluxTypeParameters.setFluxType(fluxType.toString());
        
        PipelineTask exporterPipelineTask = new PipelineTask() {
            @SuppressWarnings("unchecked")
            @Override
            public <T extends Parameters> T getParameters(Class<T> parametersClass) {
                if (parametersClass == DvTimeSeriesExporterPipelineModuleParameters.class) {
                    return (T) expParams;
                } else if (parametersClass == FluxTypeParameters.class) {
                    return (T) fluxTypeParameters;
                }
                return null;
            }
        };
        
        DvResultUowTask dvResultTask = new DvResultUowTask(minKeplerId, maxKeplerId, pipelineInstanceId);
        exporterPipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(dvResultTask));
        DvTimeSeriesExporterPipelineModule module =
            new DvTimeSeriesExporterPipelineModule() {
            
            @Override
            protected DvCrud dvCrud() {
                return dvCrud;
            }
            @Override
            protected PipelineInstanceCrud pipelineInstanceCrud() {
                return pipeCrud;
            }
            @Override
            protected FileStoreClient fileStoreClient() {
                return fsClient;
            }
            @Override
            protected MjdToCadence mjdToCadence() {
                return mjdToCadence;
            }
        };
        
        module.processTask(pipelineInstance, exporterPipelineTask);
        
        FileNameFormatter fnameFormatter  = new FileNameFormatter();
        String fname = fnameFormatter.dataValidationTimeSeriesName(keplerId, pipelineInstance.getEndProcessingTime());
        File outputFile = new File(outputDir , fname);
        assertTrue(outputFile.exists());
        fitsVerify.verify(outputFile, true);
        
        assertTrue(outputFile.delete());
        
        
    }

    private PipelineInstanceCrud createPipelineInstanceCrud(
        final PipelineInstance pipelineInstance) {
        final PipelineInstanceCrud pipeCrud = mockery.mock(PipelineInstanceCrud.class);
 
        pipelineInstance.setId(pipelineInstanceId);
        pipelineInstance.setEndProcessingTime(new Date());
        
        mockery.checking(new Expectations() {{
            one(pipeCrud).retrieve(pipelineInstanceId);
            will(returnValue(pipelineInstance));
        }});
        return pipeCrud;
    }

    private MjdToCadence createMjdToCadence() {
        final TimestampSeries cadenceTimes = createCadenceTimes();
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        mockery.checking(new Expectations() {{
            one(mjdToCadence).cadenceTimes(startCadence, endCadence);
            will(returnValue(cadenceTimes));
        }});
        return mjdToCadence;
    }

    private DvCrud createDvCrud() {
        final List<DvPlanetSummary> planetSummaryRv =  new ArrayList<DvPlanetSummary>();
        planetSummaryRv.add(new DvPlanetSummary(startCadence, endCadence, 
            new int[] { planetNumber }, keplerId, pipelineInstanceId, pipelineTaskId));
        
        final DvCrud dvCrud = mockery.mock(DvCrud.class);
        mockery.checking(new Expectations() {{
            one(dvCrud).retrievePlanetSummaryByPipelineInstanceId(pipelineInstanceId, minKeplerId, maxKeplerId);
            will(returnValue(planetSummaryRv));
        }});
        return dvCrud;
    }

    private FileStoreClient createFileStoreClient(
        final Set<FsId> expectedFsIdSet) {
        final Map<FsId, TimeSeries> timeSeries = createTimeSeries(pipelineInstanceId, expectedFsIdSet);
        final Set<FsId> singleEventIds = new HashSet<FsId>();
        singleEventIds.add(sevCorrId);
        singleEventIds.add(sevNormId);

        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        mockery.checking(new Expectations() {{ 
            one(fsClient).queryIds2(createSingleEventStatisticsQuery(fluxType, 
                Collections.singletonList(pipelineInstanceId), minKeplerId, maxKeplerId));
            will(returnValue(singleEventIds));
            
            one(fsClient).readTimeSeriesBatch(Collections.singletonList(new FsIdSet(startCadence, endCadence, expectedFsIdSet)), true);
            will(returnValue(Collections.singletonList(new TimeSeriesBatch(startCadence, endCadence, timeSeries))));
        }});
        return fsClient;
    }

    private Set<FsId> createExpectedFsIdSet() {
        Set<FsId> expectedFsIdSet = new HashSet<FsId>();
        expectedFsIdSet.add(modeLightCurveId);
        expectedFsIdSet.add(initialFsId);
        expectedFsIdSet.add(initialUncertFsId);
        expectedFsIdSet.add(initialFilledId);
        expectedFsIdSet.add(residualId);
        expectedFsIdSet.add(residualUncertId);
        expectedFsIdSet.add(residualFilledId);
        expectedFsIdSet.add(sevNormId);
        expectedFsIdSet.add(sevCorrId);
        expectedFsIdSet.add(barycentricCorrectedTimeId);
        return expectedFsIdSet;
    }

    
    private Map<FsId, TimeSeries> createTimeSeries(long pipelineTaskId,
        Set<FsId> expectedFsIdSet) {
        Map<FsId, TimeSeries> timeSeries = new HashMap<FsId, TimeSeries>();
        int value = 1;
        boolean[] gaps = new boolean[cadenceLength];
        gaps[1000] = true;
        for (FsId id : expectedFsIdSet) {
            TimeSeries t = null;
            if (id.toString().toLowerCase().contains("filled")) {
                int[] data = new int[cadenceLength];
                Arrays.fill(data, value++);
                t = new IntTimeSeries(id, data, startCadence, endCadence, gaps, pipelineTaskId);
            } else if (id.equals(barycentricCorrectedTimeId)) {
                double[] bcTimes = new double[cadenceLength];
                Arrays.fill(bcTimes, value++);
                t = new DoubleTimeSeries(id, bcTimes, startCadence, endCadence, gaps, pipelineTaskId);
            } else {
                float[] data = new float[cadenceLength];
                Arrays.fill(data, value++);
                t = new FloatTimeSeries(id, data, startCadence, endCadence, gaps, pipelineTaskId);
            }
            timeSeries.put(id, t);
        }
        return timeSeries;
    }

    private TimestampSeries createCadenceTimes() {
        double[] midTimes = new double[cadenceLength];
        int[] cadences = new int[cadenceLength];
        for (int i=0; i < midTimes.length; i++) {
            midTimes[i] = Math.PI * (i+1);
            cadences[i] = i + 1;
        }
        
        TimestampSeries cadenceTimes = new TimestampSeries(null, midTimes, null, 
            new boolean[cadenceLength], null, cadences, null, null, null, null, 
            null, null, null, null);
        return cadenceTimes;
    }
    
    
}
