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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Container for reference pixel meta information on a per reference pixel file
 * basis. In other words, each array contains a value for each known reference
 * pixel file for the current target table. The entries are in ascending time
 * order.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqTimestampSeries implements Persistable {

    @ProxyIgnore
    private static final Log log = LogFactory.getLog(PdqTimestampSeries.class);

    private double[] startTimes = ArrayUtils.EMPTY_DOUBLE_ARRAY;
    private String[] refPixelFileNames = ArrayUtils.EMPTY_STRING_ARRAY;
    private boolean[] processed = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private boolean[] excluded = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    @ProxyIgnore
    private List<RefPixelLog> refPixelLogs = new ArrayList<RefPixelLog>();

    public PdqTimestampSeries() {
    }

    public PdqTimestampSeries(double[] startTimes, String[] refPixelFileNames,
        boolean[] processed, boolean[] excluded) {

        this.startTimes = startTimes;
        this.refPixelFileNames = refPixelFileNames;
        this.processed = processed;
        this.excluded = excluded;
    }

    /**
     * Creates an instance based on a complete list of all reference pixel
     * files. The {@code excludeCadences} parameter can be used to exclude
     * specific files. The pseudo-cadences are zero-based.
     * 
     * @param refPixelLogs {@link List} of all {@link RefPixelLog} entries
     * @param excludeCadences array of pseudo-cadences (indexes) to be excluded
     */
    public PdqTimestampSeries(List<RefPixelLog> refPixelLogs,
        int[] excludeCadences) {

        if (refPixelLogs == null) {
            throw new NullPointerException("refPixelLogs can't be null");
        }

        int seriesLength = refPixelLogs.size();
        startTimes = new double[seriesLength];
        refPixelFileNames = new String[seriesLength];
        processed = new boolean[seriesLength];
        excluded = new boolean[seriesLength];

        for (int i = 0; i < seriesLength; i++) {
            RefPixelLog refPixelLog = refPixelLogs.get(i);
            startTimes[i] = refPixelLog.getMjd();
            refPixelFileNames[i] = refPixelLog.getFileLog()
                .getFilename();
            processed[i] = refPixelLog.isProcessed();
        }

        for (int pseudoCadence : excludeCadences) {
            if (pseudoCadence > seriesLength) {
                throw new IllegalArgumentException(String.format(
                    "invalid excludeCadence %d, must be less than %d",
                    pseudoCadence, seriesLength));
            }
            log.info(String.format("exclude cadence %d from processing",
                pseudoCadence));
            excluded[pseudoCadence] = true;
        }

        this.refPixelLogs = new ArrayList<RefPixelLog>(refPixelLogs);
    }

    /**
     * Creates an instance with an updated {@code processed} field that takes
     * into account the affects of the {@code excluded} field and the specified
     * {@code forceReprocessing}.
     */
    public PdqTimestampSeries getUpdatedInstance(boolean forceReprocessing) {

        boolean[] updatedProcessed = Arrays.copyOf(processed, processed.length);
        boolean forcesReprocessing = forcesReprocessing();
        for (int i = 0; i < processed.length; i++) {
            if (forceReprocessing || forcesReprocessing || isExcluded(i)) {
                updatedProcessed[i] = false;
            }
        }
        return new PdqTimestampSeries(startTimes, refPixelFileNames,
            updatedProcessed, excluded);
    }

    public double getStartTime(int index) {

        return startTimes[index];
    }

    public boolean isProcessed(int index) {

        return processed[index];
    }

    public boolean isExcluded(int index) {

        return excluded[index];
    }

    /**
     * Return a count of the reference pixel files that have been processed.
     */
    public int processedCount() {

        int processedCount = 0;
        for (int i = 0; i < processed.length; i++) {
            if (isProcessed(i)) {
                processedCount++;
            }
        }

        return processedCount;
    }

    /**
     * Return a count of the reference pixel files that have not been processed.
     */
    public int unprocessedCount() {

        int unprocessedCount = 0;
        for (int i = 0; i < processed.length; i++) {
            if (!isProcessed(i) && !isExcluded(i)) {
                unprocessedCount++;
            }
        }

        return unprocessedCount;
    }

    /**
     * Return time stamps of the reference pixel files that have been processed.
     */
    public double[] processedTimes() {

        double[] processedTimes = new double[processedCount()];
        for (int i = 0, j = 0; i < processed.length; i++) {
            if (isProcessed(i)) {
                processedTimes[j++] = getStartTime(i);
            }
        }

        return processedTimes;
    }

    /**
     * Return time stamps of the reference pixel files that have not been
     * processed.
     */
    public double[] unprocessedTimes() {

        double[] unprocessedTimes = new double[unprocessedCount()];
        for (int i = 0, j = 0; i < processed.length; i++) {
            if (!isProcessed(i) && !isExcluded(i)) {
                unprocessedTimes[j++] = getStartTime(i);
            }
        }

        return unprocessedTimes;
    }

    /**
     * Return a {@link List} of all the non-excluded {@link RefPixelLog}
     * entries.
     */
    public List<RefPixelLog> nonExcludedLogs() {

        List<RefPixelLog> refPixelLogList = new ArrayList<RefPixelLog>(
            refPixelLogs.size());
        for (int i = 0; i < excluded.length; i++) {
            if (!isExcluded(i)) {
                refPixelLogList.add(refPixelLogs.get(i));
            }
        }

        return refPixelLogList;
    }

    /**
     * Return a {@link List} of all the unprocessed {@link RefPixelLog} entries.
     */
    public List<RefPixelLog> unprocessedLogs() {

        List<RefPixelLog> refPixelLogList = new ArrayList<RefPixelLog>(
            refPixelLogs.size());
        for (int i = 0; i < processed.length; i++) {
            if (!isProcessed(i) && !isExcluded(i)) {
                refPixelLogList.add(refPixelLogs.get(i));
            }
        }

        return refPixelLogList;
    }

    /**
     * Update the processed flag for all the excluded {@link RefPixelLog}
     * entries.
     */
    public void updateExcludedLogs() {

        for (int i = 0; i < excluded.length; i++) {
            if (isExcluded(i) && isProcessed(i)) {
                refPixelLogs.get(i)
                    .setProcessed(false);
            }
        }
    }

    /**
     * Return true iff the reprocessing is needed, in other words, if there
     * exist {@link RefPixelLog} entries that are to be excluded but have
     * previously been processed. Note that once the {@code updateExcluded}
     * method has been called this method always returns {@code false}.
     */
    public boolean forcesReprocessing() {

        boolean forcesReprocessing = false;
        for (int i = 0; i < excluded.length; i++) {
            if (isExcluded(i) && isProcessed(i)) {
                forcesReprocessing = true;
            }
        }
        return forcesReprocessing;
    }

    /**
     * Return the time of the first non-excluded {@link RefPixelLog}.
     */
    public double startMjd() {

        double startMjd = getStartTime(0);
        for (int i = 0; i < excluded.length; i++) {
            if (!isExcluded(i)) {
                startMjd = getStartTime(i);
                break;
            }
        }

        return startMjd;
    }

    /**
     * Return the time of the last non-excluded {@link RefPixelLog}.
     */
    public double endMjd() {

        double endMjd = getStartTime(startTimes.length - 1);
        for (int i = startTimes.length - 1; i >= 0; i--) {
            if (!isExcluded(i)) {
                endMjd = getStartTime(i);
                break;
            }
        }

        return endMjd;
    }

    public double[] getStartTimes() {
        return startTimes;
    }

    public String[] getRefPixelFileNames() {
        return refPixelFileNames;
    }

    public boolean[] getProcessed() {
        return processed;
    }

    public boolean[] getExcluded() {
        return excluded;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(excluded);
        result = prime * result + Arrays.hashCode(processed);
        result = prime * result + Arrays.hashCode(refPixelFileNames);
        result = prime * result + Arrays.hashCode(startTimes);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PdqTimestampSeries other = (PdqTimestampSeries) obj;
        if (!Arrays.equals(excluded, other.excluded)) {
            return false;
        }
        if (!Arrays.equals(processed, other.processed)) {
            return false;
        }
        if (!Arrays.equals(refPixelFileNames, other.refPixelFileNames)) {
            return false;
        }
        if (!Arrays.equals(startTimes, other.startTimes)) {
            return false;
        }
        return true;
    }

}
