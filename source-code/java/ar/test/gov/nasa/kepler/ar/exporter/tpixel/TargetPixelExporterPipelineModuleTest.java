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

package gov.nasa.kepler.ar.exporter.tpixel;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.exporter.ExporterParameters;
import gov.nasa.kepler.ar.exporter.ExporterPipelineUtils;
import gov.nasa.kepler.ar.exporter.FrontEndPipelineMetadata;
import gov.nasa.kepler.ar.exporter.TargetLabelFilterParameters;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.*;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsLiteDbResult;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
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
public class TargetPixelExporterPipelineModuleTest {

    private Mockery mockery;
    private File exportDirectory = new File(Filenames.BUILD_TEST,
        "TargetPixelExporterPipelineModuleTest");

    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        FileUtil.mkdirs(exportDirectory);
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(exportDirectory);
    }

    @Test
    public void targetPixelExporterPipelineModuleTest() throws Exception {
        final long PIPELINE_TASK_ID = 23L;
        final long ORIGINATOR_ID = 444L;
        final int START_CADENCE = 128;
        final int END_CADENCE = 255;
        final int QUARTER = 8;
        final int DATAREL = 99;
        final int KEPLER_ID = 888;
        final int OBSERVING_SEASON = 1;
        final long TTABLE_DB_ID = 883983L;
        final int TTABLE_EXTERNAL_ID = 4;
        final double READ_NOISE = Math.PI;
        final double GAIN = Math.E;
        final int COMPRESSION_THRESHOLD = 124;
        final String fileTimestamp = "20101010101010";
        final TargetType targetType = TargetType.LONG_CADENCE;
        final int MEAN_BLACK = 1000;
        final int CCD_MODULE = 2;
        final int CCD_OUTPUT = 3;
        final long TPS_PIPELINE_INSTANCE_ID = 324234;

        final TargetTable ttable = mockery.mock(TargetTable.class);
        mockery.checking(new Expectations() {
            {
                one(ttable).getObservingSeason();
                will(returnValue(OBSERVING_SEASON));
                atLeast(1).of(ttable).getType();
                will(returnValue(targetType));
                allowing(ttable).getExternalId();
                will(returnValue(TTABLE_EXTERNAL_ID));
            }
        });

        final File nfsExportDir = new File(exportDirectory, "nfs");

        final ExporterParameters exporterParams =
            new ExporterParameters(nfsExportDir.getAbsolutePath(), START_CADENCE,
                END_CADENCE, QUARTER, DATAREL, TPS_PIPELINE_INSTANCE_ID,
                fileTimestamp, "mod3", 
                ExporterParameters.AUTOMATIC_FRONT_END_PIPELINE_INSTANCE, -1);
        final TargetPixelExporterParameters parameters = 
            new TargetPixelExporterParameters(true, COMPRESSION_THRESHOLD,
                 TPS_PIPELINE_INSTANCE_ID, true);
        final TargetLabelFilterParameters filterParams =
            new TargetLabelFilterParameters(new String[] { "ARP" });
        
        final TpsTypeParameters tpsTypeParams = new TpsTypeParameters(TpsType.TPS_LITE.toString());

        final PipelineTask task = mockery.mock(PipelineTask.class);
        final ObservedKeplerIdUowTask uow = new ObservedKeplerIdUowTask(
            KEPLER_ID, KEPLER_ID, TTABLE_DB_ID, CCD_MODULE, CCD_OUTPUT, 3);

        mockery.checking(new Expectations() {
            {
                one(task).getId();
                will(returnValue(PIPELINE_TASK_ID));
                atLeast(1).of(task).getParameters(TargetPixelExporterParameters.class);
                // will(returnValue(new
                // BeanWrapper<TargetPixelExporterParameters>(parameters)));
                will(returnValue(parameters));
                atLeast(1).of(task).getParameters(TpsTypeParameters.class);
                will(returnValue(tpsTypeParams));
                
                atLeast(1).of(task).getParameters(ExporterParameters.class);
                will(returnValue(exporterParams));
                
                atLeast(1).of(task).getParameters(TargetLabelFilterParameters.class);
                will(returnValue(filterParams));
                
                one(task).uowTaskInstance();
                will(returnValue(uow));
            }
        });

        final List<DataAnomaly> anomalies = Collections.singletonList(new DataAnomaly(
            DataAnomalyType.ARGABRIGHTENING, targetType.toCadenceType()
                .intValue(), START_CADENCE, END_CADENCE));

        final List<ConfigMap> configMaps = Collections.singletonList(new ConfigMap(
            1, 7.0, new HashMap<String, String>()));
        final TargetPixelExporter exporter = new TargetPixelExporter() {
            @Override
            public TLongHashSet exportPixelsForTargets(
                TargetPixelExporterSource source) {
                assertEquals(anomalies, source.anomalies());
                assertEquals(configMaps, source.configMaps());
                assertEquals(uow.getCcdModule(), source.ccdModule());
                assertEquals(uow.getCcdOutput(), source.ccdOutput());
                assertEquals(DATAREL, source.dataReleaseNumber());
                assertEquals(END_CADENCE, source.endCadence());
                assertEquals(nfsExportDir, source.exportDirectory());
                assertEquals(GAIN, source.gainE(), 0);
                assertEquals(END_CADENCE - START_CADENCE + 1, source.cadenceCount());
                assertEquals(PIPELINE_TASK_ID, source.pipelineTaskId());
                assertEquals(
                    TargetPixelExporterPipelineModule.class.getSimpleName(),
                    source.programName());
                assertEquals(QUARTER, source.quarter());
                assertEquals(READ_NOISE * GAIN, source.readNoiseE(), 0);
                assertEquals(MEAN_BLACK, source.meanBlackValue());
                assertEquals(OBSERVING_SEASON, source.season());
                TLongHashSet rv = new TLongHashSet();
                rv.add(ORIGINATOR_ID);
                assertEquals(Collections.singleton("ARP"),
                    source.excludeTargetsWithLabel());
                assertEquals(COMPRESSION_THRESHOLD,
                    source.compressionThresholdInPixels());
                assertTrue(source.tpsDbResults().size() > 0);
                return rv;
            }
        };

        final DataAccountabilityTrailCrud daTrailCrud = mockery.mock(DataAccountabilityTrailCrud.class);
        mockery.checking(new Expectations() {
            {
                one(daTrailCrud).create(task,
                    Collections.singleton(ORIGINATOR_ID));
            }
        });

        final LogCrud logCrud = mockery.mock(LogCrud.class);
        final TargetCrud targetCrud = mockery.mock(TargetCrud.class);

        final CelestialObjectOperations celestialObjectOperations = mockery.mock(CelestialObjectOperations.class);

        final RequantTable requantTable = mockery.mock(RequantTable.class);
        final CompressionCrud compressionCrud = mockery.mock(CompressionCrud.class);
        mockery.checking(new Expectations() {
            {
                one(requantTable).getMeanBlackValue(CCD_MODULE, CCD_OUTPUT);
                will(returnValue(MEAN_BLACK));
                
                one(compressionCrud).retrieveRequantTable(ttable);
                will(returnValue(Collections.singletonList(requantTable)));
            }
        });
        final ConfigMapOperations configMapOps = 
            mockery.mock(ConfigMapOperations.class);
        final TimestampSeries timestampSeries = 
            createCadenceTimes(START_CADENCE, END_CADENCE);
        final double firstMidMjd = timestampSeries.midTimestamps[0];
        final double lastMidMjd = timestampSeries.midTimestamps[END_CADENCE - START_CADENCE];
        mockery.checking(new Expectations() {
            {
                one(configMapOps).retrieveConfigMaps(firstMidMjd, lastMidMjd);
                will(returnValue(configMaps));
            }
        });
        ;

        final DataAnomalyOperations dataAnomalyOperations = mockery.mock(DataAnomalyOperations.class);
        mockery.checking(new Expectations() {
            {
                one(dataAnomalyOperations).retrieveDataAnomalies(
                    targetType.toCadenceType()
                        .intValue(), START_CADENCE, END_CADENCE);
                will(returnValue(anomalies));
            }
        });
        final GainOperations gainOps = mockery.mock(GainOperations.class);
        mockery.checking(new Expectations() {
            {
                one(gainOps).retrieveGainModel(firstMidMjd, lastMidMjd);
                will(returnValue(new GainModel(new double[1],
                    new double[][] { { 0, 0, GAIN } })));
            }
        });
        final ReadNoiseOperations readNoiseOps = mockery.mock(ReadNoiseOperations.class);
        mockery.checking(new Expectations() {
            {
                one(readNoiseOps).retrieveReadNoiseModel(firstMidMjd,
                    lastMidMjd);
                will(returnValue(new ReadNoiseModel(new double[1],
                    new double[][] { { 0, 0, READ_NOISE } })));
            }
        });

        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);

        mockery.checking(new Expectations() {
            {
                one(mjdToCadence).cadenceTimes(START_CADENCE, END_CADENCE);
                will(returnValue(timestampSeries));
                one(mjdToCadence).cadenceType();
                will(returnValue(targetType.toCadenceType()));
                for (int c = START_CADENCE; c <= END_CADENCE; c++) {
                    allowing(mjdToCadence).cadenceToMjd(c);
                    will(returnValue(timestampSeries.midTimestamps[c
                        - START_CADENCE]));
                }
            }
        });

        final ExporterPipelineUtils utils = mockery.mock(ExporterPipelineUtils.class);
        mockery.checking(new Expectations() {
            {
                one(utils).calculateStartEndCadences(START_CADENCE,
                    END_CADENCE, ttable, logCrud);
                will(returnValue(Pair.of(START_CADENCE, END_CADENCE)));
                one(utils).createOutputDirectory(nfsExportDir.getAbsoluteFile());
                will(returnValue(nfsExportDir));
                one(utils).targetTableForTargetTableId(TTABLE_DB_ID);
                will(returnValue(ttable));
                one(utils).defaultFileTimestamp(timestampSeries);
                will(returnValue("default"));
            }
        });

        final PipelineInstance pipelineInstanceFrontEnd = mockery.mock(PipelineInstance.class, "pipelineInstanceFrontEnd");
        final FrontEndPipelineMetadata frontEndPipelineMetadata = mockery.mock(FrontEndPipelineMetadata.class);
        mockery.checking(new Expectations() {
            {
                allowing(frontEndPipelineMetadata).getPipelineInstance(
                    CadenceType.LONG, START_CADENCE, END_CADENCE);
                will(returnValue(pipelineInstanceFrontEnd));
            }
        });

        TargetPixelExporterPipelineModule module = new TargetPixelExporterPipelineModule() {

            @Override
            protected ExporterPipelineUtils createExporterPipelineUtils() {
                return utils;
            }

            @Override
            protected TargetPixelExporter createTargetPixelExporter() {
                return exporter;
            }
        };
        
        final TpsCrud tpsCrud = mockery.mock(TpsCrud.class);
        mockery.checking(new Expectations() {{
            //TODO: the task used to construct this TPS result is the current
            //task and not a separate one.
            one(tpsCrud).retrieveTpsLiteResultByPipelineInstanceId(KEPLER_ID, KEPLER_ID, TPS_PIPELINE_INSTANCE_ID);
            will(returnValue(Collections.singletonList(new TpsLiteDbResult(KEPLER_ID, 3.0f, 0f, 12.3f, START_CADENCE, END_CADENCE, FluxType.SAP, task, false))));
        }});
        
        module.setCompressionCrud(compressionCrud);
        module.setConfigMapOps(configMapOps);
        module.setDataAnomalyOperations(dataAnomalyOperations);
        module.setDaTrailCrud(daTrailCrud);
        module.setGainOperations(gainOps);
        module.setCelestialObjectOperations(celestialObjectOperations);
        module.setLogCrud(logCrud);
        module.setMjdToCadence(mjdToCadence);
        module.setReadNoiseOperations(readNoiseOps);
        module.setTargetCrud(targetCrud);
        module.setFrontEndPipelineMetadata(frontEndPipelineMetadata);
        module.setTpsCrud(tpsCrud);

        final PipelineInstance pipelineInstance = mockery.mock(PipelineInstance.class, "pipelineInstance");

        module.processTask(pipelineInstance, task);
    }

    private TimestampSeries createCadenceTimes(int startCadence, int endCadence) {
        double[] midMjd = new double[endCadence - startCadence + 1];
        double[] endMjd = new double[midMjd.length];
        double[] startMjd = new double[midMjd.length];
        final double base = Math.sqrt(2);
        for (int i = 0; i < midMjd.length; i++) {
            midMjd[i] = base * (i + 1);
            startMjd[i] = midMjd[i] - base / 2;
            endMjd[i] = midMjd[i] + base / 2;
        }
        return new TimestampSeries(startMjd, midMjd, endMjd, null, null, null,
            null, null, null, null, null, null, null, null);
    }

}
