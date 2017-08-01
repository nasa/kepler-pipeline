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

import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.ar.FitsVerify;
import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.exporter.PerTargetExporterTestUtils;
import gov.nasa.kepler.ar.exporter.PixelByRowColumn;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
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

import nom.tam.fits.HeaderCard;

import org.apache.commons.lang.StringUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ForwardingMap;
import com.google.common.collect.Maps;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class TargetPixelExporterTest extends PerTargetExporterTestUtils {

    private static final String CUSTOM_TARGET_FILE_NAME = "kplr100000000-"
        + TIMESTAMP + "_lpd-targ.fits";
    private static final String NORMAL_TARGET_FILE_NAME = "kplr000123456-"
        + TIMESTAMP + "_lpd-targ.fits.gz";

    private Mockery mockery;
    private final File exportDirectory = new File(Filenames.BUILD_TEST,
        "TargetPixelExporter");

    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        FileUtil.cleanDir(exportDirectory);
        FileUtil.mkdirs(exportDirectory);
    }

    @After
    public void tearDown() throws Exception {
        // FileUtil.cleanDir(exportDirectory);
    }

    /**
     * This exports the target pixels of two targets: a kic object and a custom
     * target.  The custom target has an aperture with a single pixel.
     * The kic object has an aperture like this:
     * 
     * <pre>
     * .**.
     * **** 
     * .**.
     * </pre>
     * @throws Exception
     */
    @Test
    public void targetPixelExporterTest() throws Exception { 

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

        final Map<Pixel, BackgroundPixelValue> background = new HashMap<Pixel, BackgroundPixelValue>();
        for (Pixel pixel : allTargetPixels) {
            BackgroundPixelValue backgroundPixelValue = new BackgroundPixelValue(
                2, 1, new double[cadenceLength], new boolean[cadenceLength],
                new double[cadenceLength], new boolean[cadenceLength]);
            background.put(pixel, backgroundPixelValue);
        }

        final OriginatorsModelRegistryChecker originatorsModelRegistryChecker =
            createOmrc(mockery);

        final TargetPixelExporterSource source = mockery.mock(TargetPixelExporterSource.class);
        commonSourceExpectations(mockery, source, configMap, exportDirectory, fsClient,
            mjdToCadence, sciOps, observedTarget,
            customObservedTarget, originatorsModelRegistryChecker, false);
        addTpsResultsExpectations(mockery, source);
        addWcsExpectations(mockery, source);
        
        mockery.checking(new Expectations() {{
                one(source).background(allTargetPixels);
                will(returnValue(background));
                
                atLeast(1).of(source).compressionThresholdInPixels();
                will(returnValue(2));
                
                atLeast(1).of(source).k2Campaign();
                will(returnValue(-1));
  
                atLeast(1).of(source).blackAlgorithm();
                will(returnValue(BlackAlgorithm.DYNABLACK));
            }
        });

        TargetPixelExporter exporter = new TargetPixelExporter();
        TLongHashSet originatorsFound = exporter.exportPixelsForTargets(source);
        assertEquals(1, originatorsFound.size());
        assertTrue(originatorsFound.contains(originator));

        File[] exportedFiles = exportDirectory.listFiles();
        assertEquals(2, exportedFiles.length);
        FitsVerify fitsVerify = new FitsVerify();
        for (File exportedFile : exportedFiles) {
            fitsVerify.verify(exportedFile);
        }

        FitsDiff fitsDiff = new FitsDiff() {
            @Override
            protected String diffHeaderCard(HeaderCard card1, HeaderCard card2) {
                if (card1.getKey().equals(DATE_END_KW) ||
                    card1.getKey().equals(PROCVER_KW) ||
                    card1.getKey().equals(CHECKSUM_KW)) {
                    return null;
                }
                return super.diffHeaderCard(card1, card2);
            }
        };

        File exportedNormalTargetFile = new File(exportDirectory,
            NORMAL_TARGET_FILE_NAME);
        File truthFile = new File("testdata", NORMAL_TARGET_FILE_NAME);
        List<String> differences = new ArrayList<String>();
        fitsDiff.diff(exportedNormalTargetFile, truthFile, differences);
        assertTrue(StringUtils.join(differences.iterator(), "\n"),
            differences.size() == 0);

        truthFile = new File("testdata", CUSTOM_TARGET_FILE_NAME);
        File exportedCustomTargetFile = new File(exportDirectory, CUSTOM_TARGET_FILE_NAME);
        fitsDiff.diff(exportedCustomTargetFile, truthFile, differences);
        assertTrue(StringUtils.join(differences.iterator(), "\n"),
            differences.size() == 0);
    }



    /**
     * This will create data that is one less cadence that the specified start
     * and end. This is to simulate targets that have truncated data for
     * whatever reason.
     * 
     * @param targetPixels
     * @param ccdModule
     * @param ccdOutput
     * @param originator
     * @param startCadence
     * @param endCadence
     * @param keplerId
     * @param timestampSeries
     * @param ttableExternalId
     * @return
     */
    private FileStoreClient createFileStoreClient(Set<Pixel> targetPixels,
        int ccdModule, int ccdOutput, long originator, final int startCadence,
        final int endCadence, List<Integer> keplerIds,
        TimestampSeries timestampSeries, int ttableExternalId,
        int referenceCadence) {

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
        pixelTimeSeries(ccdModule, ccdOutput,
            startCadence, endCadence, timestampSeries, 
            timeSeriesIds, idToTimeSeries,
            targetPixelsByRowCol, true);
        
        pixelMjdTimeSeries(mjdTimeSeriesIds, idToMjdTimeSeries,
            midStartMjd, midEndMjd, targetPixelsByRowCol);
        
        
        qualityAndCentroidRelated(startCadence, endCadence,
            keplerIds, timestampSeries, nCadences, midStartMjd, midEndMjd,
            timeSeriesIds, mjdTimeSeriesIds, idToTimeSeries, idToMjdTimeSeries);
        
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
        
        final ForwardingMap<FsId, TimeSeries> checkedFsIdToTimeSeries = 
            new ForwardingMap<FsId, TimeSeries>() {

                @Override
                protected Map<FsId, TimeSeries> delegate() {
                    return idToTimeSeries;
                }
                
                @Override
                public TimeSeries put(FsId key, TimeSeries value) {
                    if (key.toString().toLowerCase().contains("centroid")) {
                        throw new IllegalStateException("Can't update centroids.");
                    }
                    return super.put(key, value);
                }
            };
            
        
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        mockery.checking(new Expectations() {{
                one(fsClient).readTimeSeriesBatch(
                    Collections.singletonList(new FsIdSet(startCadence,
                        endCadence, timeSeriesIds)), false);
                will(returnValue(Collections.singletonList(new TimeSeriesBatch(
                    startCadence, endCadence, checkedFsIdToTimeSeries))));
                one(fsClient).readMjdTimeSeriesBatch(
                    Collections.singletonList(new MjdFsIdSet(midStartMjd,
                        midEndMjd, mjdTimeSeriesIds)));
                will(returnValue(Collections.singletonList(new MjdTimeSeriesBatch(
                    midStartMjd, midEndMjd, idToMjdTimeSeries))));
        }});
        
        final Set<FsId> rollingBandFlagIds = new HashSet<FsId>();
        final Map<FsId, TimeSeries> rollingBandFlagReturnValue = Maps.newHashMap();
        rollingBandFlagTimeSeries(rollingBandFlagIds, rollingBandFlagReturnValue, targetPixelsByRowCol);
        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeries(rollingBandFlagIds, startCadence, endCadence, false);
            will(returnValue(rollingBandFlagReturnValue));
        }});
        
        // Yea! All done.
        return fsClient;
    }


 
}
