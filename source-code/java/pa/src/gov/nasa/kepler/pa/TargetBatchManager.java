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

package gov.nasa.kepler.pa;

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.pa.PaTarget;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Batches a given list of {@link PaTarget}s according to the
 * {@code maxBatchSize} and {@code maxReadFsIds} parameters. The
 * {@code maxBatchSize} parameter controls the maximum size in terms of the
 * pixel time series contained within the targets returned by the
 * {@code nextBatch} method while the {@code maxReadFsIds} parameter controls
 * the maximum number of time series requested in a single file store read. </p>
 * The given list of {@link PaTarget} instances must contain valid pixel sets,
 * in other words, the {@code getPixels} method must return the complete set of
 * pixel for the given target and they must have valid {@code FsId}s for both
 * the values and uncertainties(see {@link PaTargetOperations}).
 * 
 * @author Forrest Girouard
 * 
 */
class TargetBatchManager implements Iterable<List<PaTarget>> {

    private static final Log log = LogFactory.getLog(TargetBatchManager.class);

    private Set<Long> producerTaskIds = new HashSet<Long>();

    private final List<PaTarget> targets;
    private final int maxReadFsIds;

    private final int ccdModule;
    private final int ccdOutput;
    private final int startCadence;
    private final int endCadence;

    // derived value from maxBatchSize, startCadence, and endCadence
    private final int maxTimeSeriesCount;

    private final Map<FsId, FloatTimeSeries> timeSeriesCache = new HashMap<FsId, FloatTimeSeries>();

    // index in targets list of the next target to be included in a batch
    private int nextTargetIndex;

    private List<PaTarget> lastBatch = Collections.emptyList();

    /**
     * Manages the fetching of pixel time series according to the
     * {@code maxReadFsIds} and {@code maxBatchSize} parameters.
     * 
     * @param targets List of {@code PaTarget}s to manage and populate.
     * @param maxBatchSize The maximum number of pixel samples in a single
     * batch, in other words, the product of the number of pixel time series and
     * the number of cadences.
     * @param ccdModule
     * @param ccdOutput
     * @param startCadence The initial cadence for the pixel time series.
     * @param endCadence The final cadence for the pixel time series.
     * @param maxReadFsIds The maximum number of pixel time series in a single
     * read.
     */
    TargetBatchManager(final List<PaTarget> targets, final int maxBatchSize,
        final int maxReadFsIds, final int ccdModule, final int ccdOutput,
        final int startCadence, final int endCadence) {

        if (targets == null) {
            throw new NullPointerException("targets is null");
        }
        if (maxReadFsIds <= 0) {
            throw new IllegalArgumentException("maxReadFsIds must be greater "
                + "than zero, got " + maxReadFsIds + ".");
        }

        this.targets = targets;
        this.maxReadFsIds = maxReadFsIds;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.startCadence = startCadence;
        this.endCadence = endCadence;

        // derived value
        int timeSeriesCount = maxBatchSize / (endCadence - startCadence + 1);
        maxTimeSeriesCount = timeSeriesCount > 0 ? timeSeriesCount : 1;

        if (log.isDebugEnabled()) {
            log.debug("max batch size: " + maxBatchSize);
            log.debug("max read size: " + maxReadFsIds);
            log.debug("max time series per batch: " + maxTimeSeriesCount);
        }
    }

    @Override
    public Iterator<List<PaTarget>> iterator() {
        return new Iterator<List<PaTarget>>() {

            @Override
            public boolean hasNext() {
                return TargetBatchManager.this.hasNext();
            }

            @Override
            public List<PaTarget> next() {
                return nextBatch();
            }

            @Override
            public void remove() {
                throw new UnsupportedOperationException();
            }

        };
    }

    /**
     * True iff there are more targets available.
     */
    public boolean hasNext() {
        return nextTargetIndex < targets.size();
    }

    /**
     * Returns the number of time series for the given target.
     */
    public static int timeSeriesCount(final PaTarget target) {
        // each pixel has values and uncertainties time series
        return target.getPixels()
            .size() * 2;
    }

    /**
     * Returns the total number of time series for the given list of targets.
     */
    public static int timeSeriesCount(final List<PaTarget> targets) {

        int fsIdCount = 0;
        for (PaTarget target : targets) {
            fsIdCount += timeSeriesCount(target);
        }
        return fsIdCount;
    }

    /**
     * Returns the total batch size for the given targets.
     */
    public static int batchSize(final List<PaTarget> targets,
        final int cadenceCount) {
        return timeSeriesCount(targets) * cadenceCount;
    }

    /**
     * Prepares the next batch of targets from the {@code targets} input list
     * that meet the constraints of the {@code maxBatchSize} and
     * {@code maxReadFsIds} parameters.
     * 
     * @return next batch of {@code PaTarget} instances
     * @throws FileStoreException on unsuccessful reads from the file store
     */
    public List<PaTarget> nextBatch() {

        log.debug("nextBatch");

        for (PaTarget target : lastBatch) {
            target.setPaPixelTimeSeries(null);
        }

        List<PaTarget> nextTargets = new ArrayList<PaTarget>();

        nextTargetIndex = nextTargets(nextTargets);

        // populate the targets from the cache
        Set<FsId> missingFsIds = populateTargets(nextTargets);

        // read time series from file store iff necessary
        while (!missingFsIds.isEmpty()) {
            refillCache(missingFsIds);
            missingFsIds = populateTargets(nextTargets);
        }

        lastBatch = nextTargets;
        return nextTargets;
    }

    public void reset() {
        nextTargetIndex = 0;
    }

    public List<PaTarget> nextTargets() {

        List<PaTarget> nextTargets = new ArrayList<PaTarget>();
        nextTargets(nextTargets);
        return nextTargets;
    }

    private int nextTargets(final List<PaTarget> nextTargets) {

        if (log.isDebugEnabled()) {
            log.debug("next target index: " + nextTargetIndex);
        }
        int targetIndex = nextTargetIndex;
        for (; targetIndex < targets.size()
            && timeSeriesCount(nextTargets)
                + timeSeriesCount(targets.get(targetIndex)) <= maxTimeSeriesCount; targetIndex++) {
            nextTargets.add(targets.get(targetIndex));
        }

        if (nextTargets.isEmpty()) {
            if (log.isDebugEnabled()) {
                log.debug("pixels per target ("
                    + timeSeriesCount(targets.get(targetIndex))
                    + ") exceeds max batch time series count ("
                    + maxTimeSeriesCount + ") for keplerId="
                    + targets.get(targetIndex)
                        .getKeplerId());
            }
            nextTargets.add(targets.get(targetIndex++));
        }
        log.debug("next targets size: " + nextTargets.size());
        return targetIndex;
    }

    /**
     * Populates the given list of {@code PaTarget}s with their pixel time
     * series using the cache.
     * 
     * @param targets the {@code PaTarget}s to be populated
     * @return a {@code List} containing all the {@code FsId}s missing from the
     * cache that are needed to fully populate the given list of targets
     */
    private Set<FsId> populateTargets(final List<PaTarget> targets) {

        Set<FsId> missingFsIds = new HashSet<FsId>();
        Set<FsId> usedFsIds = new HashSet<FsId>();

        if (timeSeriesCache.size() > 0) {
            // fully populate as many targets from the cache as possible
            for (PaTarget target : targets) {
                if (!target.isPopulated()
                    && target.setAllTimeSeries(ccdModule, ccdOutput,
                        timeSeriesCache)) {
                    usedFsIds.addAll(target.getAllFsIds());
                }
            }
        }

        // determine which FsIds are missing from the cache
        for (PaTarget target : targets) {
            if (!target.isPopulated()) {
                for (FsId fsId : target.getAllFsIds()) {
                    // handle overlaps between targets
                    if (usedFsIds.contains(fsId)) {
                        usedFsIds.remove(fsId);
                    }
                    if (!timeSeriesCache.containsKey(fsId)) {
                        missingFsIds.add(fsId);
                    }
                }
            }
        }

        // purge FsIds from cache not needed by still unpopulated targets
        for (FsId fsId : usedFsIds) {
            timeSeriesCache.remove(fsId);
        }

        log.debug("cache size = " + cacheSize());

        return missingFsIds;
    }

    /**
     * Reads pixel time series from the file store and adds them to the cache.
     * Note that this method may not satisfy the entire requested list or may
     * read more than the requested list.
     * 
     * @param requestedFsIds a {@code List} of requested {@code FsId}s
     */
    private void refillCache(final Set<FsId> requestedFsIds) {

        Set<FsId> readFsIds = new TreeSet<FsId>();
        if (requestedFsIds.size() > maxReadFsIds) {
            // trim requested list
            Iterator<FsId> fsIds = requestedFsIds.iterator();
            for (int i = 0; i < maxReadFsIds; i++) {
                readFsIds.add(fsIds.next());
            }
        } else {
            // extend requested list
            readFsIds.addAll(requestedFsIds);
            for (int targetIndex = nextTargetIndex; targetIndex < targets.size()
                && readFsIds.size() + timeSeriesCount(targets.get(targetIndex)) <= maxReadFsIds; targetIndex++) {
                readFsIds.addAll(targets.get(targetIndex)
                    .getAllFsIds());
            }
        }

        if (log.isDebugEnabled()) {
            log.debug("refill cache: read " + readFsIds.size()
                + " time series.");
        }
        FloatTimeSeries[] fetchTimeSeries = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsFloat(
                readFsIds.toArray(new FsId[readFsIds.size()]), startCadence,
                endCadence, false);

        for (FloatTimeSeries timeSeries : fetchTimeSeries) {
            if (!timeSeries.exists()) {
                float[] fseries = new float[endCadence - startCadence + 1];
                boolean[] gaps = new boolean[endCadence - startCadence + 1];
                Arrays.fill(gaps, true);
                timeSeries = new FloatTimeSeries(timeSeries.id(), fseries, startCadence, endCadence, gaps, 0L, false);
            }
            timeSeriesCache.put(timeSeries.id(), timeSeries);
            TimeSeriesOperations.addToDataAccountability(timeSeries,
                producerTaskIds);
        }
    }

    /**
     * Get the task ids of the blobs retrieved since the last call to this
     * method.
     * 
     * @return a {@code Set} of producer task ids
     */
    public Set<Long> latestProducerTaskIds() {
        Set<Long> currentTaskIds = producerTaskIds;
        producerTaskIds = new HashSet<Long>();
        return currentTaskIds;
    }

    /** The current cache size. */
    public int cacheSize() {
        return timeSeriesCache.size();
    }
}
