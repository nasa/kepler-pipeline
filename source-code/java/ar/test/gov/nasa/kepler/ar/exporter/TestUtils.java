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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SetOfFsIdsMatcher;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.ThrusterActivityType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.jmock.Expectations;
import org.jmock.Mockery;

import com.google.common.base.Predicate;
import com.google.common.collect.Maps;

public class TestUtils {

    public static final int startCadence = 100;
    public static final int endCadence = 106;
    public static final int referenceCadence = (startCadence + endCadence) / 2;
    public static final long originator = 777L;
    public static final int ccdModule = 2;
    public static final int ccdOutput = 1;
    public static final int observingSeason = 33;
    public static final int cadenceLength = endCadence - startCadence + 1;
    public static final int ROLLING_BAND_TEST_PULSE_DURATION = 13;
    
    public static TimestampSeries createTimestampSeries() {
        double[] startMjds = new double[endCadence - startCadence + 1];
        double[] midMjds = new double[startMjds.length];
        double[] endMjds = new double[startMjds.length];

        int[] absoluteCadences = new int[startMjds.length];
        boolean[] gaps = new boolean[startMjds.length];
        boolean[] isFinePoint = new boolean[gaps.length];
        Arrays.fill(isFinePoint, true);
        boolean[] isMomentiumDump = 
            new boolean[] { false, true, false, false, false, false, false };

        for (int i = 0; i < startMjds.length; i++) {
            absoluteCadences[i] = startCadence + i;
            midMjds[i] = Math.PI * (i + 1);
            startMjds[i] = midMjds[i] - Math.PI / 2;
            endMjds[i] = midMjds[i] + Math.PI / 2;
        }

        boolean[] noAnomalies = new boolean[gaps.length];
        return new TimestampSeries(startMjds, midMjds, endMjds, gaps, null,
            absoluteCadences, noAnomalies, noAnomalies, noAnomalies, isFinePoint,
            isMomentiumDump, noAnomalies, noAnomalies);
    }
    
    /**
     * This actually just generates an empty time series.
     * @param startCadence
     * @param endCadence
     * @param cadenceType
     * @return
     */
    public static IntTimeSeries generateZeroCrossingsTimeSeries(
        int startCadence, int endCadence, CadenceType cadenceType, long originator) {
        
        FsId zeroCrossingId = PaFsIdFactory.getZeroCrossingFsId(cadenceType);
        
        int cadenceLength = endCadence - startCadence + 1;
        @SuppressWarnings("unchecked")
        IntTimeSeries emptySeries = new IntTimeSeries(zeroCrossingId, 
            new int[cadenceLength], 
            startCadence, endCadence,
            Collections.EMPTY_LIST, Collections.EMPTY_LIST);
        
        return emptySeries;
            
    }
    
    /**
     * 
     * @param startCadence
     * @param endCadence
     * @param cadenceType
     * @param originator
     * @return a pair of (thruster firing, possible thruster firing) each series
     * is empty for all cadences.
     */
    public static Pair<IntTimeSeries, IntTimeSeries> generateThrusterFiringTimeSeries(
     int startCadence, int endCadence, CadenceType cadenceType, long originator) {
        
        FsId thrusterFiringId = 
            PaFsIdFactory.getThrusterActivityFsId(cadenceType, ThrusterActivityType.DEFINITE_THRUSTER_ACTIVITY);
        FsId possibleThrusterFiringId = 
            PaFsIdFactory.getThrusterActivityFsId(cadenceType, ThrusterActivityType.POSSIBLE_THRUSTER_ACTIVITY);
        
        
        
        int cadenceLength = endCadence - startCadence + 1;
        @SuppressWarnings("unchecked")
        IntTimeSeries thrusterSeries = new IntTimeSeries(thrusterFiringId, 
            new int[cadenceLength], 
            startCadence, endCadence,
            Collections.EMPTY_LIST, Collections.EMPTY_LIST);
        
        @SuppressWarnings("unchecked")
        IntTimeSeries possibleThrusterSeries = new IntTimeSeries(possibleThrusterFiringId, 
            new int[cadenceLength], 
            startCadence, endCadence,
            Collections.EMPTY_LIST, Collections.EMPTY_LIST);
        
        return Pair.of(thrusterSeries, possibleThrusterSeries);
            
    }
    
    public static IntTimeSeries generatePaArgabrighteningTimeSeries(
        int startCadence, int endCadence, int referenceCadence,
        int ttableExternalId, int ccdModule, int ccdOutput, long originator) {
        FsId paArgabrighteningId = PaFsIdFactory.getArgabrighteningFsId(
            CadenceType.LONG, ttableExternalId, ccdModule, ccdOutput);
        SimpleInterval paArgabrighteningIntervalOne = new SimpleInterval(
            startCadence, referenceCadence - 1);
        SimpleInterval paArgabrighteningIntervalTwo = new SimpleInterval(
            referenceCadence + 1, endCadence);
        TaggedInterval paArgabrighteningIntervalOneOrig = new TaggedInterval(
            startCadence, referenceCadence - 1, originator);
        TaggedInterval paArgabrighteningIntervalTwoOrig = new TaggedInterval(
            referenceCadence + 1, endCadence, originator);
        List<SimpleInterval> paArgabrighteningDetections = new ArrayList<SimpleInterval>();
        paArgabrighteningDetections.add(paArgabrighteningIntervalOne);
        paArgabrighteningDetections.add(paArgabrighteningIntervalTwo);
        List<TaggedInterval> paArgabrighteningDetectionsOrig = new ArrayList<TaggedInterval>();
        paArgabrighteningDetectionsOrig.add(paArgabrighteningIntervalOneOrig);
        paArgabrighteningDetectionsOrig.add(paArgabrighteningIntervalTwoOrig);
        int[] data = new int[endCadence - startCadence + 1];
        IntTimeSeries paArgabrightening = new IntTimeSeries(
            paArgabrighteningId, data ,
            startCadence, endCadence, paArgabrighteningDetections,
            paArgabrighteningDetectionsOrig);
        
        for (SimpleInterval valid : paArgabrightening.validCadences()) {
            for (int c=(int)valid.start(); c <= valid.end(); c++) {
                data[c - startCadence] = 1;
            }
        }
        return paArgabrightening;
    }
    
    public static ConfigMap configureConfigMap(Mockery mockery) throws Exception {
        final ConfigMap configMap = mockery.mock(ConfigMap.class);
        mockery.checking(new Expectations() {
            {
                atLeast(1).of(configMap)
                    .get(ConfigMapMnemonic.fgsFramesPerIntegration.mnemonic());
                will(returnValue("8"));
                atLeast(1).of(configMap)
                    .get(ConfigMapMnemonic.integrationsPerShortCadence.mnemonic());
                will(returnValue("10"));
                atLeast(1).of(configMap)
                    .get(ConfigMapMnemonic.millisecondsPerFgsFrame.mnemonic());
                will(returnValue("25.5"));
                atLeast(1).of(configMap)
                    .get(ConfigMapMnemonic.millisecondsPerReadout.mnemonic());
                will(returnValue("" + (25.5 * 5)));
                atLeast(1).of(configMap)
                    .get(ConfigMapMnemonic.shortCadencesPerLongCadence.mnemonic());
                will(returnValue("30"));
                atLeast(1).of(configMap)
                    .get(ConfigMapMnemonic.lcRequantFixedOffset.mnemonic());
                will(returnValue("45000"));
                atLeast(1).of(configMap).get(ConfigMapMnemonic.scRequantFixedOffset.mnemonic());
                will(returnValue("32000"));
                
                allowing(configMap).get(ConfigMapMnemonic.darkStartCol.mnemonic());
                will(returnValue(Integer.toString(FcConstants.LEADING_BLACK_START)));
                
                allowing(configMap).get(ConfigMapMnemonic.darkEndCol.mnemonic());
                will(returnValue(Integer.toString(FcConstants.LEADING_BLACK_END)));
                
                allowing(configMap).get(ConfigMapMnemonic.darkStartRow.mnemonic());
                will(returnValue("0"));
                
                allowing(configMap).get(ConfigMapMnemonic.darkEndRow.mnemonic());
                will(returnValue(Integer.toString(FcConstants.CCD_ROWS - 1)));
                
                allowing(configMap).get(ConfigMapMnemonic.maskedStartCol.mnemonic());
                will(returnValue(Integer.toString(FcConstants.LEADING_BLACK_END + 1)));
                
                allowing(configMap).get(ConfigMapMnemonic.maskedEndCol.mnemonic());
                will(returnValue(Integer.toString(FcConstants.TRAILING_BLACK_START - 1)));
                
                allowing(configMap).get(ConfigMapMnemonic.maskedStartRow.mnemonic());
                will(returnValue(Integer.toString(FcConstants.MASKED_SMEAR_START)));
                
                allowing(configMap).get(ConfigMapMnemonic.maskedEndRow.mnemonic());
                will(returnValue(Integer.toString(FcConstants.MASKED_SMEAR_END)));
                
                allowing(configMap).get(ConfigMapMnemonic.smearStartCol.mnemonic());
                will(returnValue(Integer.toString(FcConstants.LEADING_BLACK_END + 1)));
                
                allowing(configMap).get(ConfigMapMnemonic.smearEndCol.mnemonic());
                will(returnValue(Integer.toString(FcConstants.TRAILING_BLACK_START - 1)));
                
                allowing(configMap).get(ConfigMapMnemonic.smearStartRow.mnemonic());
                will(returnValue(Integer.toString(FcConstants.VIRTUAL_SMEAR_START)));
                
                allowing(configMap).get(ConfigMapMnemonic.smearEndRow.mnemonic());
                will(returnValue(Integer.toString(FcConstants.VIRTUAL_SMEAR_END)));
            }
        });
        return configMap;
    }
    
    public static  TargetDva createTargetDva(int i, Integer keplerId,
        int startCadence, int endCadence) {
        float[] columnDva = new float[endCadence - startCadence + 1];
        Arrays.fill(columnDva, 0.1f * i);
        float[] rowDva = new float[columnDva.length];
        Arrays.fill(rowDva, 0.1f * (i + 1));
        boolean[] gapIndicator = new boolean[columnDva.length];
        gapIndicator[1] = true;

        TargetDva targetDva = new TargetDva(keplerId, columnDva, gapIndicator,
            rowDva, gapIndicator);
        return targetDva;
    }
    
    public static MjdToCadence createMjdToCadence(Mockery mockery, final TimestampSeries timestampSeries,
        final CadenceType cadenceType) {
        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);
        mockery.checking(new Expectations() {{
            for (int c = startCadence; c <= endCadence; c++) {
                allowing(mjdToCadence).cadenceToMjd(c);// unbounded
                will(returnValue(timestampSeries.midTimestamps[c- startCadence]));
                allowing(mjdToCadence).mjdToCadence(timestampSeries.midTimestamps[c - startCadence]);
                will(returnValue(c));
                allowing(mjdToCadence).hasCadence(c);
                will(returnValue(true));
            }
            allowing(mjdToCadence).cadenceType();
            will(returnValue(cadenceType));
        }
        });
        
        // This is a hack to work around broken jmock
        for (int c = startCadence; c <= endCadence; c++) {
            double m = mjdToCadence.cadenceToMjd(c);
            mjdToCadence.mjdToCadence(m);
        }

        
        return mjdToCadence;
    }
    
    public static IntTimeSeries generateIntTimeSeries(int value, FsId id,
        long originator, int startCadence, int endCadence) {
        int[] iseries = new int[endCadence - startCadence + 1];
        Arrays.fill(iseries, value);

        List<SimpleInterval> valid = Collections.singletonList(new SimpleInterval(
            startCadence + 1, endCadence - 1));
        List<TaggedInterval> originators = Collections.singletonList(new TaggedInterval(
            startCadence + 1, endCadence - 1, originator));
        IntTimeSeries its = new IntTimeSeries(id, iseries, startCadence,
            endCadence, valid, originators);
        return its;
    }

    /**
     * These are the collateral cosmic ray series for all targets.  For test
     * purposes we assume that no collateral cosmic rays have been detected.
     * @param pixelFilter This may be null.  If pixel filter returns false then
     * the collateral cosmic ray will not be generated for the specified pixel.
     * @return
     */
    public static Map<FsId, FloatMjdTimeSeries> collateralCosmicRays( long originator,
        TimestampSeries timestampSeries, Collection<Pixel> pixels, Predicate<Pixel> pixelFilter,
        CadenceType cadenceType) {
        
        double startMjd = timestampSeries.midTimestamps[0];
        double endMjd = timestampSeries.midTimestamps[timestampSeries.midTimestamps.length - 1];
        
        Map<FsId,FloatMjdTimeSeries> rv = new HashMap<FsId, FloatMjdTimeSeries>();
        for (Pixel targetPixel : pixels) {
            if (pixelFilter != null && !pixelFilter.apply(targetPixel)) {
                continue;
            }
            
            FsId blackId = CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.BLACK_LEVEL,
                CadenceType.LONG, ccdModule, ccdOutput, targetPixel.getRow());
                
            FloatMjdTimeSeries black =
                new FloatMjdTimeSeries(blackId, startMjd, endMjd, ArrayUtils.EMPTY_DOUBLE_ARRAY,
                    ArrayUtils.EMPTY_FLOAT_ARRAY, originator);
            rv.put(blackId, black);
            
            FsId maskedSmearId = CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.MASKED_SMEAR,
                CadenceType.LONG, ccdModule, ccdOutput, targetPixel.getColumn());
                
            FloatMjdTimeSeries maskedSmear =
                new FloatMjdTimeSeries(maskedSmearId, startMjd, endMjd, ArrayUtils.EMPTY_DOUBLE_ARRAY,
                    ArrayUtils.EMPTY_FLOAT_ARRAY, originator);
            rv.put(maskedSmearId, maskedSmear);
            
            FsId virtualSmearId = CalFsIdFactory.getCosmicRaySeriesFsId(CollateralType.VIRTUAL_SMEAR,
                cadenceType, ccdModule, ccdOutput, targetPixel.getColumn());
                
            FloatMjdTimeSeries virtualSmear =
                new FloatMjdTimeSeries(virtualSmearId, startMjd, endMjd, ArrayUtils.EMPTY_DOUBLE_ARRAY,
                    ArrayUtils.EMPTY_FLOAT_ARRAY, originator);
            rv.put(virtualSmearId, virtualSmear);
        }
        
        return rv;
    }
    
    public static FloatTimeSeries generateFloatTimeSeries(int value, FsId id,
        long originator, int startCadence, int endCadence) {
        float[] fseries = new float[endCadence - startCadence + 1];
        Arrays.fill(fseries, value);

        List<SimpleInterval> valid = Collections.singletonList(new SimpleInterval(
            startCadence + 1, endCadence - 1));

        List<TaggedInterval> originators = Collections.singletonList(new TaggedInterval(
            startCadence + 1, endCadence - 1, originator));
        FloatTimeSeries fts = new FloatTimeSeries(id, fseries, startCadence,
            endCadence, valid, originators);
        return fts;
    }
    
    public static DoubleTimeSeries generateDoubleTimeSeries(FsId id, int datai,
        boolean isEmpty, long originator, int startCadence, int endCadence) {
        final int nCadence = endCadence - startCadence + 1;
        boolean[] gaps = new boolean[nCadence];
        double[] data = new double[nCadence];
        if (isEmpty) {
            Arrays.fill(gaps, true);
        } else {
            gaps[0] = true;
            gaps[gaps.length - 1] = true;
            Arrays.fill(data, datai + 1);
        }

        //log.info("DoubleTimeSeries("+id+", data, "+startCadence+", "+endCadence+", ...)");
        return new DoubleTimeSeries(id, data, startCadence, endCadence, gaps,
            originator, !isEmpty);
    }
    
    public static FileStoreClient createFileStoreClientForSparsePixelTargets(
        Mockery mockery,
        Collection<Pixel> pixels, TimestampSeries cadenceTimes, int externalTtableId,
        TargetType targetType, boolean doThrusterFirings) {
        final Map<FsId, TimeSeries> allTimeSeries = Maps.newHashMap();
        
        //zero crossings, argabrightening
        FsId paArgabrighteningId = 
            PaFsIdFactory.getArgabrighteningFsId(CadenceType.LONG, 
                externalTtableId, ccdModule, ccdOutput);
        TimeSeries paArgabrightening = generatePaArgabrighteningTimeSeries(
            startCadence, endCadence, referenceCadence, externalTtableId,
            ccdModule, ccdOutput, originator);
        
        allTimeSeries.put(paArgabrighteningId, paArgabrightening);
        
        FsId zeroCrossingsId = 
            PaFsIdFactory.getZeroCrossingFsId(CadenceType.LONG);
        TimeSeries zeroCrossings = 
            generateZeroCrossingsTimeSeries(startCadence, endCadence, CadenceType.LONG, originator);
        allTimeSeries.put(zeroCrossingsId, zeroCrossings);
        
        if (doThrusterFirings) {
            Pair<IntTimeSeries, IntTimeSeries> thrusterFirings = 
                generateThrusterFiringTimeSeries(startCadence, endCadence, CadenceType.LONG, originator);
            allTimeSeries.put(thrusterFirings.left.id(), thrusterFirings.left);
            allTimeSeries.put(thrusterFirings.right.id(), thrusterFirings.right);
        }
        
        final double startMjd = cadenceTimes.startTimestamps[0];
        final double endMjd = cadenceTimes.endTimestamps[cadenceLength - 1];
        
        final Map<FsId, FloatMjdTimeSeries> allMjdTimeSeries = Maps.newHashMap();
        
        //pixel: raw, cal, umm
        for (Pixel px : pixels) {
            FsId rawId = DrFsIdFactory.getSciencePixelTimeSeries(DrFsIdFactory.TimeSeriesType.ORIG,
                targetType, 
                ccdModule, ccdOutput, px.getRow(), px.getColumn());
            TimeSeries raw = generateIntTimeSeries(px.getRow(), rawId, originator, startCadence, endCadence);
            allTimeSeries.put(rawId, raw);
            
            FsId calId = CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                targetType, ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            TimeSeries cal = generateFloatTimeSeries(px.getRow() + 1, calId,
                originator, startCadence, endCadence);
            allTimeSeries.put(calId, cal);
            
            FsId ummId = CalFsIdFactory.getTimeSeriesFsId(CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                targetType, ccdModule, ccdOutput,
                px.getRow(), px.getColumn());
            TimeSeries umm = generateFloatTimeSeries(px.getRow() + 2, ummId,
                originator, startCadence, endCadence);
            allTimeSeries.put(ummId, umm);
            
            FsId rollingBandFlagId = DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(ccdModule, ccdOutput, px.getRow(), ROLLING_BAND_TEST_PULSE_DURATION);
            TimeSeries rbTimeSeries = generateIntTimeSeries(0, rollingBandFlagId, originator, startCadence, endCadence);
            allTimeSeries.put(rollingBandFlagId, rbTimeSeries);
            
            FsId crId = PaFsIdFactory.getCosmicRaySeriesFsId(targetType,
                ccdModule, ccdOutput, px.getRow(), px.getColumn());
            FloatMjdTimeSeries crseries = new FloatMjdTimeSeries(crId,
                startMjd, endMjd,
                new double[] { cadenceTimes.midTimestamps[1] },
                new float[1], originator);
            allMjdTimeSeries.put(crId, crseries);
        }
        
        //cosmic rays
        
        Map<FsId, FloatMjdTimeSeries> collateralCosmicRays = 
            collateralCosmicRays(originator, cadenceTimes, pixels, null, CadenceType.LONG);
        allMjdTimeSeries.putAll(collateralCosmicRays);

        //expectations.
        final SetOfFsIdsMatcher mjdTimeSeriesIdsMatcher = 
            new SetOfFsIdsMatcher(allMjdTimeSeries.keySet());
        final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
        mockery.checking(new Expectations() {{
            one(fsClient).readTimeSeries(allTimeSeries.keySet(), startCadence, endCadence, false);
            will(returnValue(allTimeSeries));
            one(fsClient).readMjdTimeSeries(with(mjdTimeSeriesIdsMatcher), with(startMjd), with(endMjd));
            will(returnValue(allMjdTimeSeries));
        }});
        

        return fsClient;
    }

}
