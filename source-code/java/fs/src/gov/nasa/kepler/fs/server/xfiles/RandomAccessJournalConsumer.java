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

package gov.nasa.kepler.fs.server.xfiles;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.kepler.fs.storage.StorageAllocatorFactory;
import gov.nasa.kepler.fs.storage.StorageAllocatorInterface;
import gov.nasa.spiffy.common.concurrent.ConcurrentUtil;

/**
 * This performs recovery on a set of TransactionalRandomAccessFiles.
 * 
 * @author Sean McCauliff
 *
 */
final class RandomAccessJournalConsumer<A extends StorageAllocatorInterface>  
    implements OneToManyRouter.Consumer<JournalEntry> {

    private static final Log log = 
        LogFactory.getLog(RandomAccessJournalConsumer.class);
    
    private final StorageAllocatorFactory<A> allocatorFactory;
    private final ConcurrentHashMap<FsId, RandomAccessRecovery> recoveryObjects = 
        new ConcurrentHashMap<FsId, RandomAccessRecovery>(1024*64, 0.75f,  ConcurrentUtil.numberOfConcurrentBins(2));
    private final Set<FsId> seenSet;
    private final RandomAccessRecoveryFactory recoveryFactory;
    private final AtomicLong journalEntryCount = new AtomicLong();
    
    /**
     * @param seenSet This gets populated with all the seen FsIds.  You might
     * want to make this MT-safe.
     * @param allocatorFactory
     * @param error  When this is non-null this runnable will exit.  If it gets
     * an error then it will attempt to set this runnable.
     */
    public RandomAccessJournalConsumer(
        Set<FsId> seenSet,
        StorageAllocatorFactory<A> allocatorFactory,
        RandomAccessRecoveryFactory recoveryFactory) {

        this.allocatorFactory = allocatorFactory;
        this.seenSet = seenSet;
        this.recoveryFactory = recoveryFactory;
    }

 
    /**
     * This is MT-safe.
     */
    @Override
    public void consume(JournalEntry journalEntry) 
        throws IOException, InterruptedException {
        
        FsId id = journalEntry.fsId();
        RandomAccessRecovery recovery = recoveryObjects.get(id);
        if (recovery == null) {
            //TODO:  this is kind of hacky.  At some point I need to clean up
            //the storage allocator (factory) class hierarchy.
            RandomAccessAllocator storageAllocator = (RandomAccessAllocator) (Object)
                allocatorFactory.findAllocator(id, false, true);
            RandomAccessStorage storage = 
                storageAllocator.randomAccessStorage(id);
            recovery = recoveryFactory.recoverFile(storage);
            recoveryObjects.put(id, recovery);
            seenSet.add(id);
        }
        recovery.mergeRecovery(journalEntry);
        journalEntryCount.incrementAndGet();
    }
    

    /***
     * This is not MT-safe.
     * @throws IOException
     */
    public void completeRecovery() throws IOException {
        for (RandomAccessRecovery recovery : recoveryObjects.values()) {
            recovery.recoveryComplete();
        }
        log.info("Processed " + journalEntryCount.get() + " journal entries.");
    }

}
