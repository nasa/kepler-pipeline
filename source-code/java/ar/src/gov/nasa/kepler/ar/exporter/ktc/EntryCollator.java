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

import gov.nasa.kepler.hibernate.tad.KtcInfo;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.spiffy.common.concurrent.MiniWork;

import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.atomic.AtomicInteger;

import javax.transaction.InvalidTransactionException;
import javax.transaction.SystemException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Collects KtcInfo and other additional data into the KtcEntries.
 * 
 * @author Sean McCauliff
 *
 */
public class EntryCollator extends MiniWork<List<KtcInfo>> {
    
    private static final Log log = LogFactory.getLog(EntryCollator.class);
    
    private final TargetCrud targetCrud;
    private final InvestigationClassifier investigationClassifier = 
        new InvestigationClassifier();
    private final ConcurrentSkipListSet<CompletedKtcEntry> completedEntries;
    private final KtcTimes ktcTimes;
    private final AtomicInteger completeCount;
    private final Set<String> excludeLabels;

    private KtcInfo prevEntry;
    private String prevCategory;
    private String prevInvestigationName;
    private Double prevStart;
    private Double prevStop;

    /** 
     * 
     * @param targetCrud
     * @param completedEntries
     * @param transaction  this may be null.
     * @param excludeLabels Targets containing these labels will be excluded.
     */
    public EntryCollator(TargetCrud targetCrud, 
        ConcurrentSkipListSet<CompletedKtcEntry> completedEntries,
        KtcTimes ktcTimes, AtomicInteger completeCount,
        Set<String> excludeLabels) {
        this.targetCrud = targetCrud;
        this.completedEntries = completedEntries;
        this.ktcTimes = ktcTimes;
        this.completeCount = completeCount;
        this.excludeLabels = excludeLabels;
    }

    @Override
    protected void last(List<KtcInfo> lastEntry) {
        if (lastEntry == null) {
            return;
        }
        
        if (prevEntry == null) {
            //This can happen if all the targets have some excluded label.
            return;
        }
        completedEntries.add(new CompletedKtcEntry(prevEntry, 
            prevCategory, prevStart, prevStop, 
            prevInvestigationName));
    }
    
    /**
     * Merges consecutive entries into each other, otherwise this prints
     * the entries into the KTC file. Consecutive entries are ones with the
     * same keplerId and have contiguous target tables of the same type with
     * the same category.
     * 
     * @param entry
     * @throws SystemException 
     * @throws IllegalStateException 
     * @throws InvalidTransactionException 
     * @throws IOException
     */
    @Override
    protected void doIt(List<KtcInfo> entryList) 
        throws InvalidTransactionException, IllegalStateException, SystemException {

        for (KtcInfo entry : entryList) {
            processEntry(entry);
        }
    }
    
    private boolean isContainedInExcludeLabels(List<String> targetLabels) {
        for (String targetLabel : targetLabels) {
            if (excludeLabels.contains(targetLabel)) {
                return true;
            }
        }
        return false;
    }
    
    
    private void processEntry(KtcInfo entry) {
        
        List<String> nextCategory = targetCrud.retrieveCategoriesForTarget(
            entry.targetId, entry.targetTableId);
        List<String> labels = targetCrud.retrieveLabelsForObservedTarget(entry.targetId);
        String investigationName = investigationClassifier.assign(nextCategory, labels);
        
        
        if (isContainedInExcludeLabels(labels)) {
            return;
        }
        
        if (prevEntry == null) {
            // Initial
            prevEntry = entry;
            prevCategory=categoryString(nextCategory);
            prevStart = ktcTimes.actualStartTime(entry.type, entry.externalId);
            prevStop = ktcTimes.actualStopTime(entry.type, entry.externalId, null);
            prevInvestigationName = investigationName;
        } else if (isConcecutive(prevEntry, entry)
            && categoryString(nextCategory).equals(prevCategory) 
            && investigationName.equals(prevInvestigationName)) {
            // Merge
            prevEntry = new KtcInfo(entry.keplerId, entry.type,
                prevEntry.start, entry.end, entry.targetId,
                entry.externalId, entry.targetTableId);
            prevStop = ktcTimes.actualStopTime(entry.type, entry.externalId, prevStop);
        } else {
            // New
            completedEntries.add(new CompletedKtcEntry(prevEntry, 
                prevCategory, prevStart, prevStop,
                prevInvestigationName));
            prevEntry = entry;
            prevCategory = categoryString(nextCategory);
            prevStart = ktcTimes.actualStartTime(entry.type, entry.externalId);
            prevStop = ktcTimes.actualStopTime(entry.type, entry.externalId, null);
            prevInvestigationName = investigationName;
            
            int count = completeCount.incrementAndGet();
            if (count % 1000 == 0) {
                log.info("Generated " + count + " KTC entries.");
            }
        }

    }

    private boolean isConcecutive(KtcInfo previous, KtcInfo next) {
        // Check if they are the same..
        if (previous.keplerId != next.keplerId) {
            return false;
        }

        if (previous.type != next.type) {
            return false;
        }

        int previousExternalIndex = ktcTimes.orderForExternalId(previous.type,
            previous.externalId);
        int nextExternalIndex = ktcTimes.orderForExternalId(next.type,
            next.externalId);
        return previousExternalIndex + 1 == nextExternalIndex;
    }

    
    private String categoryString(List<String> categories) {
        StringBuilder category = new StringBuilder();
        for (String label : categories) {
            category.append(label);
            category.append(',');
        }
        if (category.length() != 0) {
            category.setLength(category.length() - 1);
        }

        return category.toString();
    }
    
}


