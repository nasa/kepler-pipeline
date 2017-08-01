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

package gov.nasa.kepler.ar.exporter.ktc;

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.tad.KtcInfo;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.concurrent.MiniWork;
import gov.nasa.spiffy.common.concurrent.MiniWorkFactory;
import gov.nasa.spiffy.common.concurrent.MiniWorkPool;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.util.*;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.atomic.AtomicInteger;

import javax.transaction.SystemException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Exports the KTC. See the DMC to SOC ICD for information on this file format.
 * 
 * @author Sean McCauliff
 * 
 */
public class KtcExporter implements KtcTimes {
    
    public static final String COMMENT_CHAR = "#";

    private static final Log log = LogFactory.getLog(KtcExporter.class);

    private final TargetCrud targetCrud;
    private final LogCrud logCrud;
    private final AtomicInteger completeCount = new AtomicInteger(0);

    /**
     * Order a contiguous count of exported target tables. In this way we can
     * see if there is a gap in the coverage for a target.
     */
    private final Map<Integer, Integer> lcExternalIdToOrder;
    private final Map<Integer, Integer> scExternalIdToOrder;

    /**
     * A map from external target table id to observed mjd (start, end) times.
     */
    private final Map<Integer, Pair<Double, Double>> lcExternalIdToActual;
    private final Map<Integer, Pair<Double, Double>> scExternalIdtoActual;


    public KtcExporter(TargetCrud targetCrud, LogCrud logCrud) {
        this.targetCrud = targetCrud;
        this.logCrud = logCrud;

        lcExternalIdToOrder = createOrderMap(TargetType.LONG_CADENCE);
        scExternalIdToOrder = createOrderMap(TargetType.SHORT_CADENCE);

        lcExternalIdToActual = createActualMap(TargetType.LONG_CADENCE);
        scExternalIdtoActual = createActualMap(TargetType.SHORT_CADENCE);

    }

    /**
     * Generate the map from external target table ids to actual mjd <start,end>
     * observation times for all pixels.
     * 
     * @param targetType
     * @return
     */
    private Map<Integer, Pair<Double, Double>> createActualMap(
        TargetType targetType) {

        Collection<Integer> externalIds;
        switch (targetType) {
            case LONG_CADENCE:
                externalIds = lcExternalIdToOrder.keySet();
                break;
            case SHORT_CADENCE:
                externalIds = scExternalIdToOrder.keySet();
                break;
            default:
                throw new IllegalStateException("Unsupported target type \""
                    + targetType + "\"");
        }

        Map<Integer, Pair<Double, Double>> actualTimesMap = 
            new HashMap<Integer, Pair<Double, Double>>(externalIds.size() * 2);

        for (Integer exId : externalIds) {
            actualTimesMap.put(exId,
                logCrud.retrieveActualObservationTimeForTargetTable(exId,
                    targetType));
        }

        return Collections.unmodifiableMap(actualTimesMap);
    }

    /**
     * 
     * @param startUtc planned start date of the target tables.
     * @param stopUtc planned end date of the target tables.
     * @param outputFile The file to generate.
     * @param excludeLabels The non-null set of target labels.  Targets' with
     * these labels will be excluded from export.
     * @throws IOException
     * @throws InterruptedException
     * @throws SystemException
     */
    public void export(Date startUtc, Date stopUtc, File outputFile,
        final Set<String> excludeLabels)
        throws IOException, InterruptedException, SystemException {

        FileWriter fwriter = null;
        BufferedWriter bwriter = null;

        try {

            fwriter = new FileWriter(outputFile);
            bwriter = new BufferedWriter(fwriter, 128 * 1024);

            String timestamp = Iso8601Formatter.dateTimeFormatter().format(
                new Date());
            bwriter.append(COMMENT_CHAR + " generated at ");
            bwriter.append(timestamp);
            bwriter.append('\n');

            List<KtcInfo> initialKtcInfo = 
                targetCrud.retrieveKtcInfo(startUtc, stopUtc);
            
            Set<String> targetTableExternalIds = new TreeSet<String>();
            StringBuilder targetIdMsg = new StringBuilder();
            targetIdMsg.append("Target table externalIds. ");
            for (KtcInfo info : initialKtcInfo) {
                String ttableName = info.type.ktcName() + " " + info.externalId;
                targetTableExternalIds.add(ttableName);
            }
            for (String lcExternalId : targetTableExternalIds) {
                targetIdMsg.append(lcExternalId).append(' ');
            }
            log.info(targetIdMsg.toString());
            
            List<List<KtcInfo>> groupedByKeplerId = 
                new ArrayList<List<KtcInfo>>();
            int lastKeplerId = -1;
            for (KtcInfo info : initialKtcInfo) {
                if (lastKeplerId != info.keplerId) {
                    groupedByKeplerId.add(new ArrayList<KtcInfo>());
                }
                groupedByKeplerId.get(groupedByKeplerId.size() - 1).add(info);
                lastKeplerId = info.keplerId;
            }
            
            
            final ConcurrentSkipListSet<CompletedKtcEntry> completedEntries =
                new ConcurrentSkipListSet<CompletedKtcEntry>();

            MiniWorkPool<List<KtcInfo>> miniWorkerPool = 
                new MiniWorkPool<List<KtcInfo>>("ktc", groupedByKeplerId, 
                    new MiniWorkFactory<List<KtcInfo>>() {
                        @Override
                        public MiniWork<List<KtcInfo>> createMiniWork() {
                            return new EntryCollator(targetCrudForDbThread(), 
                                completedEntries, KtcExporter.this,
                                completeCount, excludeLabels);
                        }
                    });
            miniWorkerPool.performAllWork();
            
            log.info("Writing KTC entries.");
            for (CompletedKtcEntry ktcEntry : completedEntries) {
                ktcEntry.printEntry(bwriter);
            }

            log.info("Done writing KTC.");
            
        } finally {
            FileUtil.close(bwriter);
        }

    }

    protected TargetCrud targetCrudForDbThread() {
        return targetCrud;
    }
    
    /**
     * 
     * @param targetType
     * @return A map from external_id -> increasing order 0,1,2 (no gaps)
     */
    private Map<Integer, Integer> createOrderMap(TargetType targetType) {
        List<Integer> externalIds = targetCrud.retrieveOrderedExternalIds(targetType);
        Map<Integer, Integer> rv = new HashMap<Integer, Integer>(
            externalIds.size() * 2);
        int i = 0;
        for (Integer exId : externalIds) {
            rv.put(exId, i);
            i++;
        }

        return Collections.unmodifiableMap(rv);
    }

    public int orderForExternalId(TargetType type, int externalId) {
        switch (type) {
            case LONG_CADENCE:
                return this.lcExternalIdToOrder.get(externalId);
            case SHORT_CADENCE:
                return this.scExternalIdToOrder.get(externalId);
            default:
                throw new IllegalStateException("Invalid target type \"" + type
                    + "\".");
        }
    }

    /**
     * 
     * @param type
     * @param externalId
     * @return This may return null if there is not an actual start time.
     */
    public Double actualStartTime(TargetType type, int externalId) {
        Pair<Double, Double> startStopTime = null;

        switch (type) {
            case LONG_CADENCE:
                startStopTime = lcExternalIdToActual.get(externalId);
                break;
            case SHORT_CADENCE:
                startStopTime = scExternalIdtoActual.get(externalId);
                break;
            default:
                throw new IllegalStateException("Invalid target type \"" + type
                    + "\".");
        }

        if (startStopTime == null) {
            return null;
        }
        return startStopTime.left;
    }

    /**
     * 
     * @param type
     * @param externalId
     * @param old This may be null.
     * @return If there is not an actual start/stop time for this external id
     * then this will return old which may be null.
     */
    public Double actualStopTime(TargetType type, int externalId, Double old) {
        Pair<Double, Double> startStopTime = null;

        switch (type) {
            case LONG_CADENCE:
                startStopTime = lcExternalIdToActual.get(externalId);
                break;
            case SHORT_CADENCE:
                startStopTime = scExternalIdtoActual.get(externalId);
                break;
            default:
                throw new IllegalStateException("Invalid target type \"" + type
                    + "\".");
        }

        if (startStopTime == null) {
            return old;
        }

        if (startStopTime.right == null) {
            return old;
        }

        return startStopTime.right;
    }
}
