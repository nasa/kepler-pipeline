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

import static gov.nasa.kepler.fs.FileStoreConstants.FS_SERVER_MAX_TRAF_METADATA_CACHE;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_SERVER_MAX_TRAF_METADATA_CACHE_DEFAULT;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_SERVER_MAX_TRAF_OPS_CACHE;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_SERVER_MAX_TRAF_OPS_CACHE_DEFAULT;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.concurrent.atomic.AtomicLong;

import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Cache metadata for the TransactionalRandomAccessFile.  Metdata are the
 * intervals that define valid data and the originators that wrote them.
 * 
 * @author Sean McCauliff
 *
 */
public final class TransactionalRandomAccessFileMetadataCache {

    private static final Log log = LogFactory.getLog(TransactionalRandomAccessFileMetadataCache.class);
    
    public static final class OperationKey {
        private final long journalLocation;
        private final Xid xid;
        private final FsId fsId;
        
        /**
         * @param journalLocation
         * @param xid
         * @param fsId
         */
        public OperationKey(long journalLocation, Xid xid, FsId fsId) {
            super();
            this.journalLocation = journalLocation;
            this.xid = xid;
            this.fsId = fsId;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ((fsId == null) ? 0 : fsId.hashCode());
            result = prime * result
                + (int) (journalLocation ^ (journalLocation >>> 32));
            result = prime * result + ((xid == null) ? 0 : xid.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            final OperationKey other = (OperationKey) obj;
            if (fsId == null) {
                if (other.fsId != null)
                    return false;
            } else if (!fsId.equals(other.fsId))
                return false;
            if (journalLocation != other.journalLocation)
                return false;
            if (xid == null) {
                if (other.xid != null)
                    return false;
            } else if (!xid.equals(other.xid))
                return false;
            return true;
        }

    }
    
    public static final class Metadata {
        private final IntervalSet<SimpleInterval, SimpleInterval.Factory> valid;
        private final IntervalSet<TaggedInterval, TaggedInterval.Factory> origin;
        
        public Metadata(IntervalSet<SimpleInterval, SimpleInterval.Factory> valid,
            IntervalSet<TaggedInterval, TaggedInterval.Factory> origin) {
            this.valid = valid;
            this.origin = origin;
        }
        
        public IntervalSet<SimpleInterval, SimpleInterval.Factory> valid() {
            return valid;
        }
        
        public IntervalSet<TaggedInterval, TaggedInterval.Factory> origin() {
            return origin;
        }
    }
    
    private final AtomicLong metaDataCacheHit = new AtomicLong();
    private final AtomicLong metaDataCacheMiss = new AtomicLong();
      
    /**
     * This uses the ConcurrentLruCache rather than SoftReferences because
     * when the number of SoftReferences is very, very large like above 10M GC
     * slows down so much that it might take a half hour just to generate all
     * the SoftReferences needed to cache all the operations.
     */
    private final ConcurrentLruCache<OperationKey, Operation> globalOperationCache;
      
    private final ConcurrentLruCache<FsId, Metadata> globalMetadataCache;
    
    private final int META_CACHE_SIZE;
    private final int OPS_CACHE_SIZE;
    
    public TransactionalRandomAccessFileMetadataCache() {
        Configuration config  = ConfigurationServiceFactory.getInstance();
        META_CACHE_SIZE = config.getInt(FS_SERVER_MAX_TRAF_METADATA_CACHE, 
            FS_SERVER_MAX_TRAF_METADATA_CACHE_DEFAULT);
        
        log.info("Setting metadata cache size to " + META_CACHE_SIZE);
        
        OPS_CACHE_SIZE = config.getInt(FS_SERVER_MAX_TRAF_OPS_CACHE, 
            FS_SERVER_MAX_TRAF_OPS_CACHE_DEFAULT);
        
        log.info("Setting operation cache size to " + OPS_CACHE_SIZE);
        
        globalMetadataCache = new ConcurrentLruCache<FsId, Metadata>(OPS_CACHE_SIZE);
        
        globalOperationCache = new ConcurrentLruCache<OperationKey, Operation>(META_CACHE_SIZE);
    }
    
    public Metadata metadata(FsId id) {
        Metadata metadata = globalMetadataCache.get(id);

        if (metadata == null) {
            metaDataCacheMiss.incrementAndGet();
            return null;
        } else {
            metaDataCacheHit.incrementAndGet();
            return metadata;
        }
    }
    
    public void storeMetadata(FsId id, Metadata metadata) {
        globalMetadataCache.put(id, metadata);
    }
    
    public Metadata removeMetadata(FsId id) {
        return globalMetadataCache.remove(id);
    }
    
    public Operation operation(OperationKey opsKey) {
        return globalOperationCache.get(opsKey);
    }
    
    public void storeOperation(OperationKey opsKey, Operation ops) {
        globalOperationCache.put(opsKey, ops);
    }
    
    public Operation removeOperation(OperationKey opsKey) {
        return globalOperationCache.get(opsKey);
    }

    public long metadataMissCount() {
        return this.metaDataCacheMiss.get();
    }
    
    public long metdataHitCount() {
        return this.metaDataCacheHit.get();
    }

    public void clear() {
        globalOperationCache.clear();
        globalMetadataCache.clear();
        metaDataCacheHit.set(0);
        metaDataCacheHit.set(0);
    }
}
