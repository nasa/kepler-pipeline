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
 * Calculates which data are valid for the specified cadence interval.
 * 
 * This class is not MT-safe.
 * 
 * @author Forrest Girouard
 * 
 */
public class CadenceDataCalculator<T> {

    private static final TaggedInterval.Factory factory = new TaggedInterval.Factory();

    private final IntervalSet<TaggedInterval, TaggedInterval.Factory> intervalSet = new IntervalSet<TaggedInterval, TaggedInterval.Factory>(
        factory);

    private final TLongObjectHashMap<CadenceData> idToData = new TLongObjectHashMap<CadenceData>();

    private int minStartCadence = Integer.MAX_VALUE;
    private int maxEndCadence = Integer.MIN_VALUE;

    /**
     * this must be in ascending order.
     */
    private final SortedSet<CadenceData> sortedByTime;

    public CadenceDataCalculator(Collection<? extends CadenceData> allData) {
        Comparator<CadenceData> comp = new Comparator<CadenceData>() {

            @Override
            public int compare(CadenceData o1, CadenceData o2) {
                long diff = o1.getCreationTime() - o2.getCreationTime();
                if (diff < 0) {
                    return -1;
                } else if (diff > 0) {
                    return 1;
                }

                return 0;
            }
        };

        sortedByTime = new TreeSet<CadenceData>(comp);
        sortedByTime.addAll(allData); // This also removes duplicates.

        for (CadenceData data : sortedByTime) {
            idToData.put(data.getId(), data);
        }

        // Merge data by time order
        for (CadenceData data : sortedByTime) {
            if (data.getStartCadence() < minStartCadence) {
                minStartCadence = data.getStartCadence();
            }
            if (data.getEndCadence() > maxEndCadence) {
                maxEndCadence = data.getEndCadence();
            }

            intervalSet.mergeInterval(new TaggedInterval(
                data.getStartCadence(), data.getEndCadence(), data.getId()));
        }
    }

    /**
     * The list of data which are no longer needed; their cadence intervals are
     * completely covered by other data.
     * 
     * @return A unique list of data in no particular order.
     */
    public List<CadenceData> deletedData() {
        TLongHashSet idsSeen = new TLongHashSet();
        for (TaggedInterval interval : intervalSet.intervals()) {
            idsSeen.add(interval.tag());
        }

        List<CadenceData> rv = new ArrayList<CadenceData>();
        for (CadenceData data : sortedByTime) {
            if (!idsSeen.contains(data.getId())) {
                rv.add(data);
            }
        }

        return rv;
    }

    /**
     * The data which cover the [min,max] cadence interval of all data.
     * 
     * @return rv[0] is for minCadence and rv[rv.length - 1] is for maxCadence.
     * If there is a gap in at cadence n then rv[n - minCadence] will be null.
     * Otherwise the rv[i] represents the data which is valid at cadence i +
     * minCadence.
     */
    public CadenceData[] cadenceData() {
        return cadenceDataForInterval(minStartCadence, maxEndCadence);
    }

    public CadenceData[] cadenceDataForInterval(int startCadence, int endCadence) {
        CadenceData[] rv = new CadenceData[endCadence - startCadence + 1];
        for (TaggedInterval interval : intervalSet.spannedIntervals(
            new TaggedInterval(startCadence, endCadence, -1L), true)) {
            CadenceData data = this.idToData.get(interval.tag());
            for (int i = (int) (interval.start() - startCadence); i < interval.end()
                - startCadence + 1; i++) {
                rv[i] = data;
            }
        }

        return rv;
    }

    public DataSeries<T> dataSeries(CadenceDataFactory<T> factory) {
        return dataSeriesForCadenceInterval(factory, minStartCadence,
            maxEndCadence);
    }

    /**
     * The ids of the data which cover the [min, max] cadence interval of all
     * data.
     * 
     * @param startCadence
     * @param endCadnece inclusive
     * 
     */
    public DataSeries<T> dataSeriesForCadenceInterval(
        CadenceDataFactory<T> dataFactory, int startCadence, int endCadence) {
        boolean[] gapIndicators = new boolean[endCadence - startCadence + 1];
        Arrays.fill(gapIndicators, true);
        long[] dataIds = new long[gapIndicators.length];

        SortedMap<Long, CadenceData> seenData = new TreeMap<Long, CadenceData>();
        for (TaggedInterval interval : intervalSet.spannedIntervals(
            new TaggedInterval(startCadence, endCadence, -1L), true)) {

            for (int i = (int) (interval.start() - startCadence); i <= interval.end()
                - startCadence; i++) {

                gapIndicators[i] = false;
                dataIds[i] = interval.tag();
                seenData.put(dataIds[i], idToData.get(dataIds[i]));
            }
        }

        @SuppressWarnings("unchecked")
        T[] cadenceData = (T[]) new Object[seenData.size()];
        long[] originators = new long[seenData.size()];

        TLongIntHashMap idToDataIndex = new TLongIntHashMap();
        int index = 0;
        for (Map.Entry<Long, CadenceData> entry : seenData.entrySet()) {
            idToDataIndex.put(entry.getKey(), index);
            T data = dataFactory.dataForCadenceData(entry.getValue());
            if (data == null) {
                throw new NullPointerException("Data \"" + entry.getValue()
                    + "\" must not be null.");
            }
            originators[index] = dataFactory.originatorForCadenceData(entry.getValue());
            cadenceData[index++] = data;

        }

        int[] dataIndices = new int[gapIndicators.length];
        for (int i = 0; i < dataIds.length; i++) {
            if (!gapIndicators[i]) {
                dataIndices[i] = idToDataIndex.get(dataIds[i]);
            }
        }

        return new DataSeries<T>(dataIndices, gapIndicators, cadenceData,
            originators, startCadence, endCadence);
    }

    /**
     * 
     * @return The list of covering data for the min, max cadence interval.
     */
    public List<CadenceData> coveringData() {
        List<TaggedInterval> coveringCadences = intervalSet.intervals();
        List<CadenceData> rv = new ArrayList<CadenceData>(
            coveringCadences.size());
        for (TaggedInterval tv : coveringCadences) {
            rv.add(idToData.get(tv.tag()));
        }
        return rv;
    }
}
