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

package gov.nasa.kepler.gar.hgn;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Sets.newTreeSet;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.gar.AbstractGarPipelineModuleTest;
import gov.nasa.kepler.gar.CadencePixelValues;
import gov.nasa.kepler.gar.Histogram;
import gov.nasa.kepler.gar.HistogramPipelineParameters;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

/**
 * Tests the {@link HgnPipelineModule}.
 * 
 * @author Bill Wohler
 */
public class HgnPipelineModuleTest extends AbstractGarPipelineModuleTest {

    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;
    private static final int START_CADENCE = 1;
    private static final int END_CADENCE = 42;
    private static final int COMPRESSION_TABLE_ID = 180;
    private static final int TARGET_TABLE_ID = 188;
    private static final int TARGETS_PER_TABLE = 1;
    private static final int MAX_PIXELS_PER_TARGET = 4;
    private static final long PRODUCER_TASK_ID = 42L;

    private HgnPipelineModule pipelineModule;
    private PipelineTask pipelineTask;

    private CompressionCrud compressionCrud = mock(CompressionCrud.class);
    private DataAccountabilityTrailCrud daCrud = mock(DataAccountabilityTrailCrud.class);
    private FileStoreClient fsClient = mock(FileStoreClient.class);
    private MjdToCadence mjdToCadence = mock(MjdToCadence.class);
    private PmrfOperations pmrfOperations = mock(PmrfOperations.class);
    private TargetCrud targetCrud = mock(TargetCrud.class);

    private List<RequantTable> requantTables;
    private Set<FsId> allTargetFsIds;
    private List<Histogram> histogramsIn = newArrayList();

    @Test
    public void testHgnInputs() {
        // Add coverage where missing.
        HgnInputs hgnInputs = new HgnInputs();
        hgnInputs.setDebugFlag(42);
        assertEquals(42, hgnInputs.getDebugFlag());
        hgnInputs.setFirstMatlabInvocation(true);
        assertTrue(hgnInputs.isFirstMatlabInvocation());
    }

    @Test
    public void testHgnOutputs() {
        // Add coverage where missing.
        HgnOutputs hgnOutputs = new HgnOutputs();
        hgnOutputs.setCcdModule(CCD_MODULE);
        assertEquals(CCD_MODULE, hgnOutputs.getCcdModule());
        hgnOutputs.setCcdOutput(CCD_OUTPUT);
        assertEquals(CCD_OUTPUT, hgnOutputs.getCcdOutput());
        hgnOutputs.setInvocationCadenceStart(START_CADENCE);
        assertEquals(START_CADENCE, hgnOutputs.getInvocationCadenceStart());
        hgnOutputs.setInvocationCadenceEnd(END_CADENCE);
        assertEquals(END_CADENCE, hgnOutputs.getInvocationCadenceEnd());
    }

    @Test
    public void testGetModuleName() {
        assertEquals("hgn", new HgnPipelineModule().getModuleName());
    }

    @Test
    public void taskType() {
        assertEquals(ModOutUowTask.class,
            new HgnPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void testRequiredParameters() {
        assertEquals(ImmutableList.of(CadenceRangeParameters.class,
            CadenceTypePipelineParameters.class, HgnModuleParameters.class,
            HistogramPipelineParameters.class),
            new HgnPipelineModule().requiredParameters());
    }

    @Test
    public void testProcessTask() throws Exception {
        populateObjects();
        createInputs();
        pipelineModule.processTask(pipelineTask.getPipelineInstance(),
            pipelineTask);
    }

    private void populateObjects() {
        pipelineModule = new HgnPipelineModuleNullScience();
        pipelineModule.setCompressionCrud(compressionCrud);
        pipelineModule.setDaCrud(daCrud);
        pipelineModule.setMjdCadence(mjdToCadence);
        pipelineModule.setPmrfOperations(pmrfOperations);
        pipelineModule.setTargetCrud(targetCrud);

        pipelineTask = createPipelineTask(PRODUCER_TASK_ID, new ModOutUowTask(
            CCD_MODULE, CCD_OUTPUT), ImmutableList.of(
            new CadenceRangeParameters(START_CADENCE, END_CADENCE),
            new CadenceTypePipelineParameters(CadenceType.LONG)),
            ImmutableList.of(new HgnModuleParameters(),
                new HistogramPipelineParameters()));

        FileStoreClientFactory.setInstance(fsClient);
    }

    private void createInputs() {
        TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(this,
            mjdToCadence, CadenceType.LONG, START_CADENCE, END_CADENCE);
        double mjdStart = cadenceTimes.midTimestamps[0];
        double mjdEnd = cadenceTimes.midTimestamps[cadenceTimes.cadenceNumbers.length - 1];

        allowing(mjdToCadence).cadenceToMjd(cadenceTimes.cadenceNumbers[0]);
        will(returnValue(mjdStart));
        allowing(mjdToCadence).cadenceToMjd(
            cadenceTimes.cadenceNumbers[cadenceTimes.cadenceNumbers.length - 1]);
        will(returnValue(mjdEnd));

        requantTables = MockUtils.mockRequantTables(this, compressionCrud,
            mjdStart, mjdEnd, COMPRESSION_TABLE_ID);

        List<ObservedTarget> allTargets = createTargets(TargetType.LONG_CADENCE);
        allTargets.addAll(createTargets(TargetType.BACKGROUND));

        allTargetFsIds = newTreeSet();
        for (ObservedTarget target : allTargets) {
            allTargetFsIds.addAll(DrFsIdFactory.getSciencePixelTimeSeries(
                TimeSeriesType.ORIG, target));
        }
        MockUtils.mockReadIntTimeSeries(this, fsClient, START_CADENCE,
            END_CADENCE, PRODUCER_TASK_ID, allTargetFsIds.toArray(new FsId[0]), false);

        createCollateralFsIds();
    }

    private List<ObservedTarget> createTargets(TargetType targetType) {
        TargetTable targetTable = MockUtils.mockTargetTable(this, targetType,
            TARGET_TABLE_ID);
        MockUtils.mockTargetTableLog(this, targetCrud, targetType,
            START_CADENCE, END_CADENCE, targetTable);

        return MockUtils.mockTargets(this, targetCrud, null, false,
            targetTable, TARGETS_PER_TABLE, MAX_PIXELS_PER_TARGET, CCD_MODULE,
            CCD_OUTPUT, new HashSet<Pixel>(), new HashSet<FsId>());
    }

    private void createCollateralFsIds() {
        // allowing(pmrfOperations).getCollateralPixelFsIds(
        // with(equal(CadenceType.LONG)),
        // with(equal(TARGET_TABLE_ID)),
        // with(equal(CCD_MODULE)),
        // with(equal(CCD_OUTPUT)),
        // with(equal(CollateralType.BLACK_LEVEL)));
        // will(returnValue(Collections.EMPTY_LIST));
        allowing(pmrfOperations).getCollateralPixelFsIds(CadenceType.LONG,
            TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT, CollateralType.BLACK_LEVEL);
        will(returnValue(Collections.EMPTY_LIST));
        allowing(pmrfOperations).getCollateralPixelFsIds(CadenceType.LONG,
            TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            CollateralType.BLACK_MASKED);
        will(returnValue(Collections.EMPTY_LIST));
        allowing(pmrfOperations).getCollateralPixelFsIds(CadenceType.LONG,
            TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            CollateralType.BLACK_VIRTUAL);
        will(returnValue(Collections.EMPTY_LIST));
        allowing(pmrfOperations).getCollateralPixelFsIds(CadenceType.LONG,
            TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            CollateralType.MASKED_SMEAR);
        will(returnValue(Collections.EMPTY_LIST));
        allowing(pmrfOperations).getCollateralPixelFsIds(CadenceType.LONG,
            TARGET_TABLE_ID, CCD_MODULE, CCD_OUTPUT,
            CollateralType.VIRTUAL_SMEAR);
        will(returnValue(Collections.EMPTY_LIST));
    }

    private void createOutputs() {
        List<gov.nasa.kepler.hibernate.gar.Histogram> histogramsOut = newArrayList();
        HistogramGroup histogramGroup = new HistogramGroup(
            pipelineTask.getPipelineInstance(), pipelineTask, CCD_MODULE,
            CCD_OUTPUT);
        createHistograms(histogramsIn, histogramsOut, histogramGroup);
        for (gov.nasa.kepler.hibernate.gar.Histogram histogramOut : histogramsOut) {
            oneOf(compressionCrud).create(histogramOut);
        }
        oneOf(compressionCrud).create(histogramGroup);

        MockUtils.mockDataAccountabilityTrail(this, daCrud, pipelineTask,
            ImmutableSet.of(PRODUCER_TASK_ID));
    }

    private class HgnPipelineModuleNullScience extends HgnPipelineModule {

        @Override
        protected void executeAlgorithm(PipelineTask pipelineTask,
            Persistable inputs, Persistable outputs) {

            validate((HgnInputs) inputs);
            createOutputs();
            populateOutputs((HgnInputs) inputs, (HgnOutputs) outputs);
        }

        private void validate(HgnInputs hgnInputs) {
            List<CadencePixelValues> cadencePixels = hgnInputs.getCadencePixels();
            assertEquals(END_CADENCE - START_CADENCE + 1, cadencePixels.size());
            for (CadencePixelValues cadencePixelValues : cadencePixels) {
                assertEquals(allTargetFsIds.size(),
                    cadencePixelValues.getPixelValues().length);
            }
            assertEquals(CCD_MODULE, hgnInputs.getCcdModule());
            assertEquals(CCD_OUTPUT, hgnInputs.getCcdOutput());
            assertEquals(0, hgnInputs.getDebugFlag());
            assertNotNull(hgnInputs.getFcConstants());
            assertNotNull(hgnInputs.getHgnModuleParameters());
            assertEquals(END_CADENCE, hgnInputs.getInvocationCadenceEnd());
            assertEquals(START_CADENCE, hgnInputs.getInvocationCadenceStart());
            assertEquals(requantTables.get(0)
                .getRequantEntries()
                .size(), hgnInputs.getRequantTable()
                .getRequantEntries().length);
            assertEquals(requantTables.get(0)
                .getMeanBlackEntries()
                .size(), hgnInputs.getRequantTable()
                .getMeanBlackEntries().length);
        }

        private void populateOutputs(HgnInputs hgnInputs, HgnOutputs hgnOutputs) {
            hgnOutputs.setCcdModule(hgnInputs.getCcdModule());
            hgnOutputs.setCcdOutput(hgnInputs.getCcdOutput());
            hgnOutputs.setHistograms(histogramsIn);
            hgnOutputs.setInvocationCadenceEnd(hgnInputs.getInvocationCadenceEnd());
            hgnOutputs.setInvocationCadenceStart(hgnInputs.getInvocationCadenceStart());
            hgnOutputs.setModOutBestBaselineInterval(BEST_BASELINE_INTERVAL);
            hgnOutputs.setModOutBestStorageRate(BEST_STORAGE_RATE);
        }
    }
}
