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

package gov.nasa.kepler.ar.exporter.collateral;

import gov.nasa.kepler.ar.exporter.RollingBandUtils;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.pmrf.CollateralPmrfTable;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.*;

import org.apache.commons.lang.StringUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import static gov.nasa.kepler.ar.exporter.TestUtils.*;
import static gov.nasa.kepler.common.CollateralType.*;
import static org.junit.Assert.*;

/**
 * 
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class CollateralPixelExporterTest {

    private static final File outputDir = 
        new File(Filenames.BUILD_TEST, CollateralPixelExporterTest.class.getSimpleName());
    private static final File truthDir = new File("testdata");
    private static final String fileName = "kplr021-timestamp_coll.fits";
    private final List<Short> blackOffsets =         ImmutableList.of((short)1, (short) 2);
    private final List<Short> maskedSmearOffsets =   ImmutableList.of((short)3, (short) 4);
    private final List<Short> virtualSmearOffsets =  ImmutableList.of((short) 5, (short) 6);
    private final int[] rollingBandPulseDurations = new int[] { 4 };
    
    
    private Mockery mockery;
    
    @Before
    public void setUp() throws Exception {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
        
        FileUtil.cleanDir(outputDir);
        FileUtil.mkdirs(outputDir);
    }
    
    @Test
    public void exportCollateralPixels() throws Exception {
        final CollateralPixelExporterSource source = 
            mockery.mock(CollateralPixelExporterSource.class);
        
        final TimestampSeries cadenceTimes = createTimestampSeries();
        
        final double startStartMjd = cadenceTimes.startTimestamps[0];
        final double endEndMjd = cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];
        final double startMidMjd = cadenceTimes.midTimestamps[0];
        final double endMidMjd = cadenceTimes.midTimestamps[cadenceTimes.midTimestamps.length - 1];
        
        ConfigMap configMap = configureConfigMap(mockery);
        final List<ConfigMap> configMaps = ImmutableList.of(configMap);
        
        final MjdToCadence mjdToCadence = createMjdToCadence(mockery, cadenceTimes, CadenceType.LONG);
        final CollateralPmrfTable collateralPmrfTable = createCollateralPmrfTable();
        final RollingBandUtils rollingBandUtils = createRollingBandUtils();
        
        final FileStoreClient fsClient = createFileStoreClient(cadenceTimes, startMidMjd, endMidMjd, collateralPmrfTable);
       
        final Date generatedAt = new Date(Integer.MAX_VALUE * 1000L);
        mockery.checking(new Expectations() {{
            atLeast(1).of(source).cadenceType();
            will(returnValue(CadenceType.LONG));
            atLeast(1).of(source).ccdModule();
            will(returnValue(ccdModule));
            atLeast(1).of(source).ccdOutput();
            will(returnValue(ccdOutput));
            atLeast(1).of(source).configMaps();
            will(returnValue(configMaps));
            atLeast(1).of(source).dataRelease();
            will(returnValue(-1));
            atLeast(1).of(source).defaultFileTimestamp();
            will(returnValue("timestamp"));
            atLeast(1).of(source).endCadence();
            will(returnValue(endCadence));
            atLeast(1).of(source).endMidMjd();
            will(returnValue(endMidMjd));
            atLeast(1).of(source).endEndMjd();
            will(returnValue(endEndMjd));
            atLeast(1).of(source).exportDir();
            will(returnValue(outputDir));
            atLeast(1).of(source).fileStoreClient();
            will(returnValue(fsClient));
            atLeast(1).of(source).gainE();
            will(returnValue(-2.2));
            atLeast(1).of(source).meanBlack();
            will(returnValue(-3));
            atLeast(1).of(source).mjdToCadence();
            will(returnValue(mjdToCadence));
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(-4L));
            atLeast(1).of(source).prmfTable();
            will(returnValue(collateralPmrfTable));
            atLeast(1).of(source).quarter();
            will(returnValue(-5));
            atLeast(1).of(source).readNoseE();
            will(returnValue(-6.6));
            atLeast(1).of(source).season();
            will(returnValue(-7));
            atLeast(1).of(source).skyGroup();
            will(returnValue(-8));
            atLeast(1).of(source).startCadence();
            will(returnValue(startCadence));
            atLeast(1).of(source).startMidMjd();
            will(returnValue(startMidMjd));
            atLeast(1).of(source).startStartMjd();
            will(returnValue(startStartMjd));
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            atLeast(1).of(source).subversionUrl();
            will(returnValue("svn+ssh://host/path/to/code"));
            atLeast(1).of(source).subversionRevision();
            will(returnValue("45916"));
            atLeast(1).of(source).targetTableId();
            will(returnValue(42));
            atLeast(1).of(source).rollingBandUtils();
            will(returnValue(rollingBandUtils));
            atLeast(1).of(source).blackAlgorithm();
            will(returnValue(BlackAlgorithm.EXP_1D_BLACK));
        }});
        
        CollateralPixelExporter collateralPixelExporter = new CollateralPixelExporter();
        collateralPixelExporter.export(source);
        
        
        FitsDiff fitsDiff = new FitsDiff();
        File truthFile = new File(truthDir, fileName);
        File outputFile = new File(outputDir, fileName);
        List<String> diffs = Lists.newArrayList();
        fitsDiff.diff(truthFile, outputFile, diffs);
        assertEquals(StringUtils.join(diffs.iterator(), '\n'), 0, diffs.size());
    }
    
    private RollingBandUtils createRollingBandUtils() {
        final RollingBandUtils rollingBandUtils = mockery.mock(RollingBandUtils.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(rollingBandUtils).fluxThreshold(with(any(Double.class)));
            will(returnValue(9.9));
            
            atLeast(1).of(rollingBandUtils).columnCutoff();
            will(returnValue(108));
            
            atLeast(1).of(rollingBandUtils).rollingBandPulseDurations();
            will(returnValue(rollingBandPulseDurations));
        }});
        return rollingBandUtils;
    }
    
    private FileStoreClient createFileStoreClient(TimestampSeries cadenceTimes, final double startMjd, final double endMjd, CollateralPmrfTable collateralPmrfTable) {
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        
        final Map<FsId, TimeSeries> allTimeSeries = Maps.newHashMap();
        final Map<FsId, FloatMjdTimeSeries> cosmicRays = Maps.newHashMap();
        generateTimeSeries(allTimeSeries, cosmicRays, collateralPmrfTable, blackOffsets, BLACK_LEVEL, cadenceTimes);
        generateTimeSeries(allTimeSeries, cosmicRays, collateralPmrfTable, virtualSmearOffsets, VIRTUAL_SMEAR, cadenceTimes);
        generateTimeSeries(allTimeSeries, cosmicRays, collateralPmrfTable, maskedSmearOffsets, MASKED_SMEAR, cadenceTimes);

        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeries(allTimeSeries.keySet(), startCadence, endCadence, false);
            will(returnValue(allTimeSeries));
            one(fsClient).readMjdTimeSeries(cosmicRays.keySet(), startMjd, endMjd);
            will(returnValue(cosmicRays));
        }});
        return fsClient;
    }
    
    /**
     * 
     * @param allTimeSeries this map is modified.
     * @param cosmicRays this map is modified.
     * @param collateralPmrfTable expectations involving this object are created
     * @param offsets
     * @param collateralType
     * @param cadenceTimes
     */
    private void generateTimeSeries(Map<FsId, TimeSeries> allTimeSeries,
        Map<FsId, FloatMjdTimeSeries> cosmicRays, final CollateralPmrfTable collateralPmrfTable, List<Short> offsets,
        final CollateralType collateralType, TimestampSeries cadenceTimes) {
        
        final List<FsId> origFsIds = Lists.newArrayList();
        final List<FsId> calFsIds = Lists.newArrayList();
        final List<FsId> ummFsIds = Lists.newArrayList();
        final List<FsId> crFsIds = Lists.newArrayList();
        final List<FsId> rollingBandVariationIds = Lists.newArrayList();
        final List<FsId> rollingBandFlagsIds = Lists.newArrayList();
        
        for (short offset : offsets) {
            FsId origFsId = 
                DrFsIdFactory.getCollateralPixelTimeSeries(DrFsIdFactory.TimeSeriesType.ORIG,
                CadenceType.LONG, collateralType, ccdModule, ccdOutput, offset);
            IntTimeSeries origSeries = 
                generateIntTimeSeries(offset + collateralType.ordinal(), origFsId, 1L, startCadence, endCadence);
            
            FsId calFsId = 
                CalFsIdFactory.getCalibratedCollateralFsId(collateralType, CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                    CadenceType.LONG, ccdModule, ccdOutput, offset);
            FloatTimeSeries calSeries = 
                generateFloatTimeSeries(offset + collateralType.ordinal() + 1, calFsId, 1, startCadence, endCadence);
            
            FsId ummId =
                CalFsIdFactory.getCalibratedCollateralFsId(collateralType, CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                                                           CadenceType.LONG, ccdModule, ccdOutput, offset);
            FloatTimeSeries ummSeries  =
                generateFloatTimeSeries(offset + collateralType.ordinal() + 2, ummId, 1L, startCadence, endCadence);
            
            FsId cosmicRayId =
                CalFsIdFactory.getCosmicRaySeriesFsId(collateralType, CadenceType.LONG, ccdModule, ccdOutput, offset);
            
            double[] mjds = new double[] { cadenceTimes.midTimestamps[1] };
            float[] values = new float[] { 1.5f };
            double startMjd = cadenceTimes.startTimestamps[0];
            double endMjd = cadenceTimes.endTimestamps[cadenceTimes.endTimestamps.length - 1];
            FloatMjdTimeSeries crSeries = 
                new FloatMjdTimeSeries(cosmicRayId, startMjd, endMjd, mjds, values, 1L);
               
            allTimeSeries.put(origFsId, origSeries);
            allTimeSeries.put(calFsId, calSeries);
            allTimeSeries.put(ummId, ummSeries);
            cosmicRays.put(cosmicRayId, crSeries);
            
            origFsIds.add(origFsId);
            calFsIds.add(calFsId);
            ummFsIds.add(ummId);
            crFsIds.add(cosmicRayId);
        }
        
        if (collateralType == BLACK_LEVEL) {
            for (int duration : rollingBandPulseDurations) {
                for (short blackOffset : blackOffsets) {
                    FsId rbFlagsId = 
                        DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(ccdModule, ccdOutput, blackOffset, duration);
                    IntTimeSeries rbFlagsTimeSeries = 
                        generateIntTimeSeries(7, rbFlagsId, 1, startCadence, endCadence);
                    FsId rbVariationId = DynablackFsIdFactory.getRollingBandArtifactVariationFsId(ccdModule, ccdOutput, blackOffset, duration);
                    DoubleTimeSeries rbVariationTimeSeries = 
                        generateDoubleTimeSeries(rbVariationId, blackOffset + collateralType.ordinal() + 1, false, (long) 1, startCadence, endCadence);
                    allTimeSeries.put(rbFlagsId, rbFlagsTimeSeries);
                    allTimeSeries.put(rbVariationId, rbVariationTimeSeries);
                    rollingBandFlagsIds.add(rbFlagsId);
                    rollingBandVariationIds.add(rbVariationId);
                }
            }
        }
        
        mockery.checking(new Expectations() {{
            atLeast(1).of(collateralPmrfTable).getPixelFsIds(collateralType);
            will(returnValue(origFsIds));
            
            atLeast(1).of(collateralPmrfTable).getCalibratedPixelFsIds(collateralType);
            will(returnValue(calFsIds));
            
            atLeast(1).of(collateralPmrfTable).getCalibratedUncertainityFsIds(collateralType);
            will(returnValue(ummFsIds));
            
            atLeast(1).of(collateralPmrfTable).getCosmicRayFsIds(collateralType);
            will(returnValue(crFsIds));
            
            atLeast(1).of(collateralPmrfTable).getRollingBandFlags(collateralType, rollingBandPulseDurations);
            will(returnValue(rollingBandFlagsIds));
            
            atLeast(1).of(collateralPmrfTable).getRollingBandVariation(collateralType, rollingBandPulseDurations);
            will(returnValue(rollingBandVariationIds));
            
        }});
        
    }
    
    /**
     * FsId expectations are handled elsewhere.
     * @return
     */
    private CollateralPmrfTable createCollateralPmrfTable() {
        final CollateralPmrfTable collateralPmrfTable = mockery.mock(CollateralPmrfTable.class);
        mockery.checking(new Expectations() {{
            atLeast(1).of(collateralPmrfTable).getPixelCoordinates(BLACK_LEVEL);
            will(returnValue(blackOffsets));
            atLeast(1).of(collateralPmrfTable).getPixelCoordinates(MASKED_SMEAR);
            will(returnValue(maskedSmearOffsets));
            atLeast(1).of(collateralPmrfTable).getPixelCoordinates(VIRTUAL_SMEAR);
            will(returnValue(virtualSmearOffsets));
            atLeast(1).of(collateralPmrfTable).length();
            will(returnValue(blackOffsets.size() + maskedSmearOffsets.size() + virtualSmearOffsets.size()));
            
        }});
        
        return collateralPmrfTable;
    }
    
}
