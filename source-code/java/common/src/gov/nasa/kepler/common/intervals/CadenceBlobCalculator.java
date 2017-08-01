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

package gov.nasa.kepler.common.intervals;

import gnu.trove.TLongHashSet;
import gnu.trove.TLongIntHashMap;
import gnu.trove.TLongObjectHashMap;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;

/**
 * Calculates which blobs are valid for the specified cadence interval.
 * 
 * This class is not MT-safe.
 * 
 * @author Sean McCauliff
 * 
 */
public class CadenceBlobCalculator<T> {

    private static final TaggedInterval.Factory factory = new TaggedInterval.Factory();

    private final IntervalSet<TaggedInterval, TaggedInterval.Factory> intervalSet = new IntervalSet<TaggedInterval, TaggedInterval.Factory>(
        factory);

    private final TLongObjectHashMap<CadenceBlob> idToBlob = new TLongObjectHashMap<CadenceBlob>();

    private int minStartCadence = Integer.MAX_VALUE;
    private int maxEndCadence = Integer.MIN_VALUE;

    /**
     * this must be in ascending order.
     */
    private final SortedSet<CadenceBlob> sortedByTime;

    public CadenceBlobCalculator(Collection<? extends CadenceBlob> allBlobs) {
        Comparator<CadenceBlob> comp = new Comparator<CadenceBlob>() {

            @Override
            public int compare(CadenceBlob o1, CadenceBlob o2) {
                long diff = o1.getCreationTime() - o2.getCreationTime();
                if (diff < 0) {
                    return -1;
                } else if (diff > 0) {
                    return 1;
                }

                return 0;
            }
        };

        sortedByTime = new TreeSet<CadenceBlob>(comp);
        sortedByTime.addAll(allBlobs); // This also removes duplicates.

        for (CadenceBlob blob : sortedByTime) {
            idToBlob.put(blob.getId(), blob);
        }

        // Merge blobs by time order
        for (CadenceBlob blob : sortedByTime) {
            if (blob.getStartCadence() < minStartCadence) {
                minStartCadence = blob.getStartCadence();
            }
            if (blob.getEndCadence() > maxEndCadence) {
                maxEndCadence = blob.getEndCadence();
            }

            intervalSet.mergeInterval(new TaggedInterval(
                blob.getStartCadence(), blob.getEndCadence(), blob.getId()));
        }

    }

    /**
     * The list of blobs which are no longer needed; their cadence intervals are
     * completely covered by other blobs.
     * 
     * @return A unique list of blobs in no particular order.
     */
    public List<CadenceBlob> deletedBlobs() {
        TLongHashSet idsSeen = new TLongHashSet();
        for (TaggedInterval interval : intervalSet.intervals()) {
            idsSeen.add(interval.tag());
        }

        List<CadenceBlob> rv = new ArrayList<CadenceBlob>();
        for (CadenceBlob blob : sortedByTime) {
            if (!idsSeen.contains(blob.getId())) {
                rv.add(blob);
            }
        }

        return rv;
    }

    /**
     * The blobs which cover the [min,max] cadence interval of all blobs.
     * 
     * @return rv[0] is for minCadence and rv[rv.length - 1] is for maxCadence.
     * If there is a gap in at cadence n then rv[n - minCadence] will be null.
     * Otherwise the rv[i] represents the blob which is valid at cadence i +
     * minCadence.
     */
    public CadenceBlob[] cadenceBlobs() {
        return cadenceBlobsForInterval(minStartCadence, maxEndCadence);
    }

    public CadenceBlob[] cadenceBlobsForInterval(int startCadence,
        int endCadence) {
        CadenceBlob[] rv = new CadenceBlob[endCadence - startCadence + 1];
        for (TaggedInterval interval : intervalSet.spannedIntervals(
            new TaggedInterval(startCadence, endCadence, -1L), true)) {
            CadenceBlob blob = this.idToBlob.get(interval.tag());
            for (int i = (int) (interval.start() - startCadence); i < interval.end()
                - endCadence; i++) {
                rv[i] = blob;
            }
        }

        return rv;
    }

    public BlobSeries<T> blobSeries(CadenceBlobDataFactory<T> factory) {
        return blobSeriesForCadenceInterval(factory, minStartCadence,
            maxEndCadence);
    }

    /**
     * The ids of the blobs which cover the [min, max] cadence interval of all
     * blobs.
     * 
     * @param startCadence
     * @param endCadnece inclusive
     * 
     */
    public BlobSeries<T> blobSeriesForCadenceInterval(
        CadenceBlobDataFactory<T> dataFactory, int startCadence, int endCadence) {
        boolean[] gapIndicators = new boolean[endCadence - startCadence + 1];
        Arrays.fill(gapIndicators, true);
        long[] blobIds = new long[gapIndicators.length];

        SortedMap<Long, CadenceBlob> seenBlobs = new TreeMap<Long, CadenceBlob>();
        for (TaggedInterval interval : intervalSet.spannedIntervals(
            new TaggedInterval(startCadence, endCadence, -1L), true)) {

            for (int i = (int) (interval.start() - startCadence); i <= interval.end()
                - startCadence; i++) {

                gapIndicators[i] = false;
                blobIds[i] = interval.tag();
                seenBlobs.put(blobIds[i], idToBlob.get(blobIds[i]));
            }
        }

        @SuppressWarnings("unchecked")
        T[] blobData = (T[]) new Object[seenBlobs.size()];
        long[] originators = new long[seenBlobs.size()];

        TLongIntHashMap idToBlobDataIndex = new TLongIntHashMap();
        int index = 0;
        for (Map.Entry<Long, CadenceBlob> entry : seenBlobs.entrySet()) {
            idToBlobDataIndex.put(entry.getKey(), index);
            T data = dataFactory.blobDataForCadenceBlob(entry.getValue());
            if (data == null) {
                throw new NullPointerException("Data for blob \""
                    + entry.getValue() + "\" must not be null.");
            }
            originators[index] = dataFactory.originatorForCadenceBlob(entry.getValue());
            blobData[index++] = data;

        }

        int[] blobDataIndices = new int[gapIndicators.length];
        for (int i = 0; i < blobIds.length; i++) {
            if (!gapIndicators[i]) {
                blobDataIndices[i] = idToBlobDataIndex.get(blobIds[i]);
            }
        }

        return new BlobSeries<T>(blobDataIndices, gapIndicators, blobData,
            originators, startCadence, endCadence);
    }

    /**
     * 
     * @return The list of covering blobs for the min, max cadence interval.
     */
    public List<CadenceBlob> coveringBlobs() {
        List<TaggedInterval> coveringCadences = intervalSet.intervals();
        List<CadenceBlob> rv = new ArrayList<CadenceBlob>(
            coveringCadences.size());
        for (TaggedInterval tv : coveringCadences) {
            rv.add(idToBlob.get(tv.tag()));
        }
        return rv;
    }

}
