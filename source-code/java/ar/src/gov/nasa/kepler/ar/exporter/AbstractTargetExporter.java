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

import static com.google.common.base.Preconditions.checkNotNull;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.barycentricCorrectionEndOfLastCadence;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.barycentricCorrectionStartOfFirstCadence;
import static gov.nasa.kepler.ar.exporter.FluxTimeSeriesProcessing.bkjdTimestampSeries;
import gnu.trove.TLongHashSet;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeriesDataType;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.IOException;
import java.util.*;

import nom.tam.fits.FitsException;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.Lists;

/**
 * This is the base class for both the single and multi-quarter
 * target exporters.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class AbstractTargetExporter
    <M extends AbstractTargetMetadata,
     S extends BaseExporterSource> {

    private static final Log log = LogFactory.getLog(AbstractTargetExporter.class);
    
    /**
     * Remove from the target-to-metadata map all entries whose values lack time series.
     * @param keplerIdToTargetPixelMetadatM must not be null
     * @param allTimeSeries must not be null
     */
    protected void removeEmptyEntries(
            SortedMap<Integer, M> keplerIdToTargetPixelMetadata,
            Map<FsId, TimeSeries> fsIdToTimeSeries, 
            Map<FsId, FloatMjdTimeSeries> fsIdToFloatMjdTimeSeries) {
        Iterator<Map.Entry<Integer, M>> it = 
            keplerIdToTargetPixelMetadata.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry<Integer, M> entry = it.next();
            if (!entry.getValue().hasData(fsIdToTimeSeries,
                fsIdToFloatMjdTimeSeries)) {
                it.remove();
                log.warn("Target " + entry.getKey() +
                    " does not have data.  Skipping.");
            }
        }
    }

    /**
     * If M given List contains any Kepler IDs that are not keys in M given
     * Map, log M warning.
     * @param keplerIds M non-null List of Kepler IDs as Integers
     * @param keplerIdToTargetPixelMetadatM M non-null Map with Kepler ID as
     * key
     */
    protected void skippedTargetsReport(List<Integer> keplerIds,
            SortedMap<Integer, M> keplerIdToTargetPixelMetadata) {

        List<Integer> skippedKeplerIds = new ArrayList<Integer>();
        for (Integer keplerId : keplerIds) {
            if (keplerId == null) {
                continue;
            }
            if (!keplerIdToTargetPixelMetadata.containsKey(keplerId)) {
                skippedKeplerIds.add(keplerId);
            }
        }
        if (skippedKeplerIds.size() > 0) {
            log.warn("Skipped M total of " + skippedKeplerIds.size() + ":");
            log.warn(StringUtils.join(skippedKeplerIds.iterator(), ','));
        }
    }
    
    /**
     * 
     * @return generates M map from kepler id to the target's cdpp. The
     * resulting map may not contain an entry for all, some or none of the
     * kepler ids for this unit of work. This returns M empty, but non-null map
     * in the case there are no applicable results.
     */
    protected <T extends AbstractTpsDbResult> Map<Integer, RmsCdpp> toTpsDbResultMap(
        List<T> rawResults) {
    
        List<T> sortedTpsResults = new ArrayList<T>(rawResults.size());
        for (T tpsr : rawResults) {
            if (tpsr == null) {
                continue;
            }
            sortedTpsResults.add(tpsr);
        }
        Collections.sort(sortedTpsResults,
            new Comparator<T>() {
                @Override
                public int compare(T o1, T o2) {
                    int diff = o1.getKeplerId() - o2.getKeplerId();
                    if (diff != 0) {
                        return diff;
                    }
                    return Float.compare(o1.getTrialTransitPulseInHours(),
                        o2.getTrialTransitPulseInHours());
                }
            });

        Map<Integer, RmsCdpp> rv = new HashMap<Integer, RmsCdpp>();
        int prevKeplerId = -1;
        Map<Float, Float> ttpToRmsCdpp = new HashMap<Float, Float>();
        for (T tpsr : sortedTpsResults) {
            if (tpsr.getKeplerId() != prevKeplerId) {
                RmsCdpp cdpp = new RmsCdpp(ttpToRmsCdpp.get(3.0f),
                    ttpToRmsCdpp.get(6.0f), ttpToRmsCdpp.get(12.0f));
                rv.put(prevKeplerId, cdpp);
                prevKeplerId = tpsr.getKeplerId();
                ttpToRmsCdpp = new HashMap<Float, Float>();
            }
            if (tpsr.getRmsCdpp() == null) {
                continue;
            }
            ttpToRmsCdpp.put(tpsr.getTrialTransitPulseInHours(),
                tpsr.getRmsCdpp());
        }
        rv.remove(-1);
        return rv;
    }

    protected int[] createQualityColumn(
        M targetMetadata, Map<FsId, TimeSeries> timeSeries,
        Map<FsId, FloatMjdTimeSeries> mjdTimeSeries,
        DataQualityMetadata<M> qualityMetadata) {

        log.info("Quality column for " + qualityMetadata.cadenceType() + " cadence.");
        qualityMetadata.setAllTimeSeries(timeSeries);
        qualityMetadata.setAllMjdTimeSeries(mjdTimeSeries);
        qualityMetadata.setTargetMetadata(targetMetadata);
        QualityFieldCalculator qualityFieldCalc = new QualityFieldCalculator();
        int[] qualityFlags = qualityFieldCalc.calculateQualityFlags(qualityMetadata);
        log.info("Quality column construction is complete.");
        return qualityFlags;
    }

    /**
     * Writes M single file for the specified target.
     * 
     * @param targetMetadata
     * @param source
     * @param exportData
     * @throws IOException
     * @throws FitsException
     */
    protected void exportFile(M targetMetadata, S source, ExportData<M> exportData)
        throws IOException, FitsException {
        

        BufferedDataOutputStream bufOut = outputStream(targetMetadata, source, exportData);

        ChecksumsAndOutputs checksumsAndOutputs =
            computeChecksums(targetMetadata, source, exportData, bufOut);

        try {
            writeFileUnsafe(source, targetMetadata, exportData,
                checksumsAndOutputs);
        } finally {
            try {
                if (bufOut != null) {
                    bufOut.flush();
                }
            } catch (IOException ignored) {
                log.warn(ignored);
            }
            FileUtil.close(bufOut);
        }
        if (checkExport(targetMetadata, source, exportData)) {
            log.info("File for target " + targetMetadata.keplerId()
                + " seems good.");
        } else {
            log.warn("File for target " + targetMetadata.keplerId()
                + " seems bad.");
        }
    }
    
    /**
     * Performs M dummy write, the results of which are discarded, in order to
     * compute the checksums.
     * @param targetMetadata
     * @param source
     * @param exportData
     * @param bufOut
     * @return M ChecksumsAndOutputs object containing the actual checksums
     * @throws IOException
     * @throws FitsException
     */
    protected ChecksumsAndOutputs 
        computeChecksums(M targetMetadata,
            S source,
            ExportData<M> exportData,
            BufferedDataOutputStream bufOut)
                throws IOException, FitsException {

        log.info("Begin checksum computation.");
        int nHdus = targetMetadata.hduCount();

        // Perform M dummy write to compute the actual checksums
        ChecksumsAndOutputs defaultChecksums = 
            ChecksumsAndOutputs.newInstanceWithDefaults(nHdus);
        writeFileUnsafe(source, targetMetadata, exportData, defaultChecksums);
        defaultChecksums.close();
      
        log.info("Checksums have been computed.");

        // The return value
        ChecksumsAndOutputs realChecksumsAndOutputs =
            ChecksumsAndOutputs.newInstance(nHdus, bufOut, defaultChecksums);
        
        return realChecksumsAndOutputs;
    }

    /**
     * @param targetMetadatM the KIC entry, beefed up; must not be null
     * @param source information all target exporters need in order to export;
     * must not be null
     * @param exportDatM contains maps from FsId to time series; must not be
     * null
     * @return whether the FITS file created by writeFileUnsafe() satisfies
     * correctness tests, using the same objects passed to that method
     */
    protected abstract boolean checkExport(M targetMetadata, S source, ExportData<M> exportData);

    /**
     * This is unsafe in the sense the cleanup code is outside of this method.
     */
    protected abstract 
        void writeFileUnsafe(S source,
            M targetMetadata, ExportData<M> exportData, ChecksumsAndOutputs outputs)
            throws IOException, FitsException;

    /** Factory method to return a new Stream for exporting data for a single target. */
    protected abstract 
        BufferedDataOutputStream outputStream(M targetMetadata,
        S source, ExportData<M> exportData)
        throws IOException, FitsException;

    /** POJO for aggregating data to be exported. */
    public static final class ExportData<T extends AbstractTargetMetadata> {
        public final Map<FsId, TimeSeries> allTimeSeries;
        public final Map<FsId, FloatMjdTimeSeries> floatMjdTimeSeries;
        public final Collection<T> targetMetdatas;
        public final TLongHashSet originators;

        /** The only constructor, supplying values for all fields. */
        public ExportData(Map<FsId, TimeSeries> allTimeSeries,
            Map<FsId, FloatMjdTimeSeries> floatMjdTimeSeries,
            Collection<T> targetPixelMetdatas, 
            TLongHashSet originators) {

            this.allTimeSeries = allTimeSeries;
            this.floatMjdTimeSeries = floatMjdTimeSeries;
            this.targetMetdatas = targetPixelMetdatas;
            this.originators = originators;
        }

        /** Factory method to return an ExportData with all fields non-null but empty. */
        @SuppressWarnings({ "unchecked", "rawtypes" })
        public static <T extends AbstractTargetMetadata> ExportData<T> empty() {
            return new ExportData(Collections.emptyMap(),
                Collections.emptyMap(), Collections.emptyList(),
                new TLongHashSet());
        }
    }
    
    /**
     * Populates the rollingBandFlags in the target metadata.  This is in a separate call to the file store because
     * we are interested in casting these to a smaller data type.
     * @param keplerIdToTargetPixelMetadata
     * @param longCadenceTimestampSeries
     */
    protected void fetchRollingBandFlags(
            int targetTableExternalId,
            SortedMap<Integer, ? extends AbstractTargetMetadata> keplerIdToTargetMetadata,
            TimestampSeries longCadenceTimestampSeries,
            FileStoreClient fsClient) {
        log.info("Getting rolling band flags for target table " + targetTableExternalId + ".");
        Set<FsId> allRollingBandFlags = new HashSet<FsId>(keplerIdToTargetMetadata.size() * 200);
        for (AbstractTargetMetadata metadata : keplerIdToTargetMetadata.values()) {
            allRollingBandFlags.addAll(metadata.rollingBandFlagsFsId(targetTableExternalId));
        }
        
        if (allRollingBandFlags.isEmpty()) {
            log.info("Didn't get any rolling band FsIds for target table " + targetTableExternalId + ".");
            return;
        }
        
        int lcStart = longCadenceTimestampSeries.cadenceNumbers[0];
        int lcEnd = longCadenceTimestampSeries.cadenceNumbers[longCadenceTimestampSeries.cadenceNumbers.length - 1];
        Map<FsId, TimeSeries> timeSeries = 
            fsClient.readTimeSeries(allRollingBandFlags, lcStart, lcEnd, false);
        
        Map<FsId, byte[]> rbBytes = RollingBandFlags.fromAllTimeSeries(timeSeries.values());
        
        for (AbstractTargetMetadata metadata : keplerIdToTargetMetadata.values()) {
            RollingBandFlags rbFlags = RollingBandFlags.newRollingBandFlags(
                metadata.rollingBandFlagsFsId(targetTableExternalId), rbBytes);
            metadata.setRollingBandFlags(rbFlags, targetTableExternalId);
            RollingBandFlags optimalApertureRbFlags = RollingBandFlags.newRollingBandFlags(
                metadata.rollingBandFlagsOptimalApertureFsId(targetTableExternalId), rbBytes);
            metadata.setOptimalApertureRollingBandFlags(optimalApertureRbFlags, targetTableExternalId);
        }
        //GC help?
        timeSeries = null;
    }
    
    /**
     * Given FsId objects and metadata, fetch the TimeSeries and
     * FloatMjdTimeSeries from the File Store.
     * @param timeSeriesFsIds This is map from the FsId to its expected type.
     * @param mjdTimeSeriesFsIds
     * @param sourceTaskIds
     * @param source
     * @param lcTimeSeriesIds
     * @return a Pair, the first element of which is a Map from FsId to the
     * TimeSeries that it fetched, and the second element of which is a Map
     * from FsId to the FloatMjdTimeSeries that it fetched.
     */
    protected Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>> fetchFileStoreStuff(
        Map<FsId, TimeSeriesDataType> timeSeriesFsIds,
        Set<FsId> mjdTimeSeriesFsIds, TLongHashSet sourceTaskIds,
        int startCadence, int endCadence,
        CadenceType cadenceType,
        int lcStartCadence, int lcEndCadence,
        Map<FsId, TimeSeriesDataType> lcTimeSeriesIds,
        MjdToCadence mjdToCadence,
        FileStoreClient fsClient) {
        
        List<TimeSeriesBatch> timeSeriesBatches =
            fetchTimeSeriesBatches(timeSeriesFsIds, lcTimeSeriesIds,
                startCadence, endCadence, 
                cadenceType,
                lcStartCadence, lcEndCadence,
                fsClient);
                
        List<MjdTimeSeriesBatch> mjdTimeSeriesBatches =
            fetchMjdTimeSeriesBatches(mjdTimeSeriesFsIds, startCadence, endCadence,
                mjdToCadence, fsClient);

        for (TimeSeriesBatch batch : timeSeriesBatches) {
            for (TimeSeries timeSeries : batch.timeSeries().values()) {
                timeSeries.uniqueOriginators(sourceTaskIds);
            }
        }

        for (FloatMjdTimeSeries mjdTimeSeries : 
            mjdTimeSeriesBatches.get(0).timeSeries().values()) {
            sourceTaskIds.addAll(mjdTimeSeries.originators());
        }

        // Merge TimeSeries batches.
        Map<FsId, TimeSeries> fsIdToTimeSeries = 
            new HashMap<FsId, TimeSeries>(timeSeriesFsIds.size() * 2);
        Map<FsId, TimeSeriesDataType> allTypes = new HashMap<FsId, TimeSeriesDataType>(timeSeriesFsIds.size() * 2);
        allTypes.putAll(timeSeriesFsIds);
        allTypes.putAll(lcTimeSeriesIds);
        for (TimeSeriesBatch batch : timeSeriesBatches) {
            for (TimeSeries ts : batch.timeSeries().values()) {
                fsIdToTimeSeries.put(ts.id(),
                    typeCorrectedTimeSeries(ts, allTypes));
            }
        }

        log.info("Fetching file store data is complete.");
        return Pair.of(fsIdToTimeSeries, mjdTimeSeriesBatches.get(0).timeSeries());
    }
    
    /**
     * @param timeSeriesFsIds a non-null, but possibly empty, Map from FsId to the
     * data type of the time series fetched with that FsId
     * @param lcTimeSeriesIds a Set of FsId objects for Long-Cadence time series
     * @return a non-null, but possibly empty, List of TimeSeriesBatch objects
     */
    private List<TimeSeriesBatch> fetchTimeSeriesBatches(
        Map<FsId, TimeSeriesDataType> timeSeriesFsIds,
        Map<FsId, TimeSeriesDataType> lcTimeSeriesIds,
        int startCadence, int endCadence,
        CadenceType cadenceType,
        int lcStart, int lcEnd,
        FileStoreClient fsClient) {

        log.info("Reading " + timeSeriesFsIds.size() + " time series.");
        List<FsIdSet> fsIdSets = Lists.newArrayList();
        FsIdSet nativeCadenceSet = new FsIdSet(startCadence,endCadence, new TreeSet<FsId>(timeSeriesFsIds.keySet()));
        fsIdSets.add(nativeCadenceSet);

        int nExpectedBatches = 1;
        if (cadenceType == CadenceType.SHORT) {
//            int lcStart = source.cadenceToLongCadence(source.startCadence());
//            int lcEnd   = source.cadenceToLongCadence(source.endCadence());
            log.info("Reading long cadence fsids [" + lcStart + "," + lcEnd + "].");
            nExpectedBatches++;

            FsIdSet lcSet = new FsIdSet(lcStart, lcEnd, new TreeSet<FsId>(
                lcTimeSeriesIds.keySet()));

            fsIdSets.add(lcSet);
        }

        // The return value
        List<TimeSeriesBatch> timeSeriesBatches = 
            fsClient.readTimeSeriesBatch(fsIdSets, false);
        if (timeSeriesBatches.size() != nExpectedBatches) {
            throw new IllegalStateException(
                "Incorrect number of batches returned. Found "
                    + timeSeriesBatches.size() + " batches, but expected "
                    + nExpectedBatches + ".");
        } else {
            return timeSeriesBatches;
        }
    }
    
    /**
     * 
     * @param mjdTimeSeriesFsIds a non-null, but possibly empty Set of FsId objects,
     * each for an MJD time series
     * @param source a non-null data source for a single Target
     * @return a non-null, a length zero or one list.
     */
    private List<MjdTimeSeriesBatch> fetchMjdTimeSeriesBatches(
        Set<FsId> mjdTimeSeriesFsIds,
        int startCadence, int endCadence, MjdToCadence mjdToCadence,
        FileStoreClient fsClient) {
        
        log.info("Reading " + mjdTimeSeriesFsIds.size() + " mjd time series.");
        double startMjd = mjdToCadence.cadenceToMjd(startCadence);
        double endMjd = mjdToCadence.cadenceToMjd(endCadence);

        MjdFsIdSet mjdFsIdSet =
            new MjdFsIdSet(startMjd, endMjd, new TreeSet<FsId>(mjdTimeSeriesFsIds));
        List<MjdTimeSeriesBatch> mjdTimeSeriesBatches = 
            fsClient.readMjdTimeSeriesBatch(Collections.singletonList(mjdFsIdSet));
        if (mjdTimeSeriesBatches.size() != 1) {
            throw new IllegalStateException(
                "Incorrect number of mjd batches returned.");
        } else {
            return mjdTimeSeriesBatches;
        }
    }

    /**
     * If the time series never existed then we may not get back the correct
     * type from the file store server.
     * 
     * @param timeSeries This may not be null.
     * @param fsIdTypeMap The time series may not be mentioned in this map, but
     * the map itself must exist.
     * @return A non-null value.
     */
    private static TimeSeries typeCorrectedTimeSeries(TimeSeries timeSeries,
        Map<FsId, TimeSeriesDataType> fsIdTypeMap) {
        if (!fsIdTypeMap.containsKey(timeSeries.id())) {
            return timeSeries;
        }

        switch (fsIdTypeMap.get(timeSeries.id())) {
            case IntType:
                if (log.isDebugEnabled()) {
                    log.debug("IntType: timeSeries.id()=" + timeSeries.id() + " " + timeSeries.getClass().getSimpleName());
                }
                return timeSeries.asIntTimeSeries();
            case FloatType:
                if (log.isDebugEnabled()) {
                    log.debug("FloatType: timeSeries.id()=" + timeSeries.id() + " " + timeSeries.getClass().getSimpleName());
                }
                return timeSeries.asFloatTimeSeries();
            case DoubleType:
                if (log.isDebugEnabled()) {
                    log.debug("DoubleType: timeSeries.id()=" + timeSeries.id() + " " +  timeSeries.getClass().getSimpleName());
                }
                return timeSeries.asDoubleTimeSeries();
            default:
                throw new IllegalStateException("Unhandled case.");
        }
    }

    /**
     * Insert into a supplied Map the CelestialObjects that are supplied in a
     * List.
     * @param keplerIdToCelestialObject a non-null out parameter
     * @param celestialObjects a non-null List of CelestialObject, the non-null
     * elements of which are inserted into a given Map
     */
    protected static <C extends CelestialObject> void addCelestialObjectsToMap(
        Map<Integer, CelestialObject> keplerIdToCelestialObject,
        List<C> celestialObjects) {

        for (C celestialObject : celestialObjects) {
            if (celestialObject == null) {
                continue;
            }
            keplerIdToCelestialObject.put(celestialObject.getKeplerId(),
                celestialObject);
        }
    }
    
    /** Factory method to return a new TargetTime for a single target. */
    protected 
        TargetTime targetTime(S source,
        M targetMetadata, Map<FsId, TimeSeries> allTimeSeries, float gapFill) {

        FloatTimeSeries barycentricCorrection = targetMetadata.barycentricCorrectionSeries(
            allTimeSeries, source.startCadence(), source.endCadence());

        Pair<Integer, Integer> targetsStartEndCadence = targetMetadata.actualStartAndEnd(allTimeSeries);

        double startBkjd = ModifiedJulianDate.mjdToKjd(source.timestampSeries().startTimestamps[targetsStartEndCadence.left
            - source.startCadence()])
            + barycentricCorrectionStartOfFirstCadence(barycentricCorrection,
                targetsStartEndCadence.left, targetsStartEndCadence.right);
        double endBkjd = ModifiedJulianDate.mjdToKjd(source.timestampSeries().endTimestamps[targetsStartEndCadence.right
            - source.startCadence()])
            + barycentricCorrectionEndOfLastCadence(barycentricCorrection,
                targetsStartEndCadence.left, targetsStartEndCadence.right);

        double startMjd = source.mjdToCadence()
            .cadenceToMjd(targetsStartEndCadence.left);
        double endMjd = source.mjdToCadence()
            .cadenceToMjd(targetsStartEndCadence.right);

        CadenceType cadenceType = source.mjdToCadence().cadenceType();

        final double[] time = bkjdTimestampSeries(
            source.timestampSeries().midTimestamps,
            source.timestampSeries().gapIndicators, barycentricCorrection,
            gapFill);

        return new TargetTime(cadenceType, startMjd, endMjd, startBkjd,
            endBkjd, targetsStartEndCadence.left, targetsStartEndCadence.right,
            time, barycentricCorrection);
    }

    /**
     * The returned value is bitwise anded with every pixel in the aperture mask
     * image. The goal of this is to produce a simplified aperture mask
     * suitable for Human understanding.
     * 
     * @return any integer containing valid image flags or their compliment.
     */
    protected abstract int apertureMaskPixelMask();

    /**
     * This class exists as a container for all the different time information
     * that we need to drag around for a specific target.
     *
     */
    public static final class TargetTime {
        public final CadenceType cadenceType;
        public final double startMjd;
        public final double endMjd;
        public final double startBkjd;
        public final double endBkjd;
        /** The actual start cadence of this target. */
        public final int actualStart;
        /** The actual end cadence of this target. */
        public final int actualEnd;
        public final double[] time;
        public final FloatTimeSeries barycentricCorrection;

        public TargetTime(CadenceType cadenceType, double startMjd,
            double endMjd, double startBkjd, double endBkjd, int actualStart,
            int actualEnd, double[] time, FloatTimeSeries barycentricCorrection) {
            
            checkNotNull(time, "time is null");
            checkNotNull(barycentricCorrection, "barycentricCorrection is null");
            
            this.cadenceType = cadenceType;
            this.startMjd = startMjd;
            this.endMjd = endMjd;
            this.startBkjd = startBkjd;
            this.endBkjd = endBkjd;
            this.barycentricCorrection = barycentricCorrection;
            this.actualStart = actualStart;
            this.actualEnd = actualEnd;
            this.time = time;
        }

    }

}
