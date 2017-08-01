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
import gov.nasa.kepler.ar.exporter.PerTargetExporterTestUtils;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.FsIdSetMatcher;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryChecker;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.*;

import org.hamcrest.TypeSafeMatcher;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class K2ExporterTest extends PerTargetExporterTestUtils {

    private Mockery mockery;
    private final File exportDirectory = 
        new File(Filenames.BUILD_TEST, "K2ExporterTest");
    
    @Before
    public void setup() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        FileUtil.mkdirs(exportDirectory);
    }
    
    @Test
    public void k2ExporterTest() throws Exception {
        final ConfigMap configMap = configureConfigMap(mockery);
        
        final FileStoreClient fsClient = createFileStoreClient(allTargetPixels,
            ccdModule, ccdOutput, originator, startCadence, endCadence,
            keplerIds, timestampSeries, ttableExternalId, referenceCadence);

        final MjdToCadence mjdToCadence = createMjdToCadence(mockery, timestampSeries, cadenceType);
        
        final PipelineTask pipelineTask = createPipelineTask(mockery);

        final ObservedTarget observedTarget = 
            createKicObservedTarget(mockery, pipelineTask);

        final ObservedTarget customObservedTarget =
            createCustomObservedTarget(mockery, pipelineTask);
            

        final SciencePixelOperations sciOps = 
            createSciencePixelOperations(mockery, observedTarget, customObservedTarget);
        
        final OriginatorsModelRegistryChecker originatorsModelRegistryChecker =
            createOmrc(mockery);

        final K2Source k2Source = mockery.mock(K2Source.class);
        commonSourceExpectations(mockery, k2Source, configMap,
            exportDirectory, fsClient, mjdToCadence, sciOps, observedTarget,
            customObservedTarget, originatorsModelRegistryChecker, true);
        mockery.checking(new Expectations() {{
            atLeast(1).of(k2Source).k2Campaign();
            will(returnValue(0));
            atLeast(1).of(k2Source).tpsDbResults();
            will(returnValue(Collections.emptyList()));
        }});
        addWcsExpectations(mockery, k2Source);
        
        K2Exporter k2Exporter = new K2Exporter();
        mockery.checking(new Expectations() {{
            atLeast(1).of(k2Source).compressionThresholdInPixels();
            will(returnValue(targetPixels.size() - 1));
        }});
        TLongHashSet originatorsFound = k2Exporter.exportPixelsForTargets(k2Source);
        assertEquals(1, originatorsFound.size());
        assertTrue(originatorsFound.contains(originator));

    }

    private FileStoreClient createFileStoreClient(
        SortedSet<Pixel> allTargetPixels, int ccdmodule, int ccdoutput,
        long originator, int startcadence, int endcadence,
        List<Integer> keplerIds, TimestampSeries timestampSeries,
        int ttableExternalId, int referenceCadence) {

        final int nCadences = endCadence - startCadence + 1;
        final double midStartMjd = timestampSeries.midTimestamps[0];
        final double midEndMjd = timestampSeries.midTimestamps[timestampSeries.midTimestamps.length - 1];
        final Set<FsId> timeSeriesIds = new HashSet<FsId>();
        final Set<FsId> mjdTimeSeriesIds = new HashSet<FsId>();
        final Map<FsId, TimeSeries> idToTimeSeries = new HashMap<FsId, TimeSeries>();
        final Map<FsId, FloatMjdTimeSeries> idToMjdTimeSeries = new HashMap<FsId, FloatMjdTimeSeries>();

        SortedSet<Pixel> targetPixelsByRowCol =
            new TreeSet<Pixel>(PixelByRowColumn.INSTANCE);
        
        targetPixelsByRowCol.addAll(targetPixels);
        targetPixelsByRowCol.add(customTargetPixel);
        
        pixelTimeSeries(ccdModule, ccdOutput,
            startCadence, endCadence, timestampSeries, 
            timeSeriesIds, idToTimeSeries,
            targetPixelsByRowCol, false);
        
        qualityAndCentroidRelated(startCadence, endCadence,
            keplerIds, timestampSeries, nCadences, midStartMjd, midEndMjd,
            timeSeriesIds, mjdTimeSeriesIds, idToTimeSeries, idToMjdTimeSeries);
        
        pixelMjdTimeSeries(mjdTimeSeriesIds, idToMjdTimeSeries,
            midStartMjd, midEndMjd, targetPixelsByRowCol);
        
        IntTimeSeries paArgabrightening = generatePaArgabrighteningTimeSeries(
            startCadence, endCadence, referenceCadence, ttableExternalId,
            ccdModule, ccdOutput, originator);
        idToTimeSeries.put(paArgabrightening.id(), paArgabrightening);
        timeSeriesIds.add(paArgabrightening.id());
        
        IntTimeSeries zeroCrossings = 
            generateZeroCrossingsTimeSeries(startCadence, endCadence, cadenceType, originator);
        idToTimeSeries.put(zeroCrossings.id(), zeroCrossings);
        timeSeriesIds.add(zeroCrossings.id());

        Pair<IntTimeSeries, IntTimeSeries> thrusterFirings = 
            generateThrusterFiringTimeSeries(startCadence, endCadence, cadenceType, originator);
        idToTimeSeries.put(thrusterFirings.left.id(), thrusterFirings.left);
        timeSeriesIds.add(thrusterFirings.left.id());
        idToTimeSeries.put(thrusterFirings.right.id(), thrusterFirings.right);
        timeSeriesIds.add(thrusterFirings.right.id());
        
        //Collateral cosmic rays
        Map<FsId, FloatMjdTimeSeries> collateralCosmicRays = 
            collateralCosmicRays(originator, timestampSeries, targetPixels,
                keepOptimalAperture, cadenceType);
        mjdTimeSeriesIds.addAll(collateralCosmicRays.keySet());
        idToMjdTimeSeries.putAll(collateralCosmicRays);
            
        final TypeSafeMatcher<List<FsIdSet>> timeSeriesIdSetMatcher = new FsIdSetMatcher(
            Collections.singletonList(new FsIdSet(startCadence,
                endCadence, timeSeriesIds)));
        
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeriesBatch(with(timeSeriesIdSetMatcher),
                with(equals(false)));
            will(returnValue(Collections.singletonList(new TimeSeriesBatch(
                startCadence, endCadence, idToTimeSeries))));
            
            one(fsClient).readMjdTimeSeriesBatch(
                Collections.singletonList(new MjdFsIdSet(midStartMjd,
                    midEndMjd, mjdTimeSeriesIds)));
            will(returnValue(Collections.singletonList(new MjdTimeSeriesBatch(
                midStartMjd, midEndMjd, idToMjdTimeSeries))));
        }});
        
        return fsClient;
    }
    
    

}
