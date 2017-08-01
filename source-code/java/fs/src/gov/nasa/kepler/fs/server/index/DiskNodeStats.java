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

package gov.nasa.kepler.fs.server.index;

import gov.nasa.spiffy.common.jmx.AbstractCompositeData;
import gov.nasa.spiffy.common.jmx.CompositeTypeDescription;
import gov.nasa.spiffy.common.jmx.ItemDescription;
import gov.nasa.spiffy.common.jmx.TableIndex;

import java.io.Serializable;
import java.util.Date;
import java.util.concurrent.atomic.AtomicReference;

import javax.management.openmbean.CompositeData;
import javax.management.openmbean.OpenDataException;

/**
 * Used to track the effectiveness of the disk node io caching.
 * 
 * @author Sean McCauliff
 *
 */
public class DiskNodeStats {
    private final AtomicReference<Stats> stats;
    private final String treeName;

    public DiskNodeStats(String treeName) {
        this.treeName = treeName;
        try {
            stats = new AtomicReference<Stats>(new Stats(treeName));
        } catch (OpenDataException e) {
            throw new IllegalStateException(e);
        }
    }
    
    void incrementCacheHit() {
        stats.get().cacheHits++;
    }
    
    void incrementCacheMiss() {
        stats.get().cacheMiss++;
    }
    
    public void reset() {
        try {
            stats.set(new Stats(treeName));
        } catch (OpenDataException e) {
            throw new IllegalStateException(e);
        }
    }
    
    public Stats stats() {
        return stats.get();
    }
    
    @CompositeTypeDescription("B-Tree disk node cache statistics.")
    public final static class Stats extends AbstractCompositeData 
        implements CompositeData, Serializable {
        
        private static final long serialVersionUID = -8271231589025323800L;
        private  int cacheHits = 0;
        private  int cacheMiss = 0;
        private final String treeName;
        private final Date startTime = new Date();
        
        private Stats(String treeName) throws OpenDataException {
            this.treeName = treeName;
        }
        
        @TableIndex(0)
        @ItemDescription("The name of the B-Tree")
        public String getTreeName() {
            return treeName;
        }
        
        @ItemDescription("The number of disk I/O cache hits since the start or the last reset time.")
        public int getHits() {
            return cacheHits;
        }
        
        @ItemDescription("The number of disk I/O cache misses since the start or the last reset time.")
        public int getMisses() {
            return cacheMiss;
        }
        
        @ItemDescription("The ratio of cache hits to cache misses.")
        public double getHitToMissRatio() {
            if (cacheMiss == 0) {
                return 1;
            }
            return (double) cacheHits / (double) cacheMiss;
        }
        
        @ItemDescription("The time the counters where started.  This is the local time on the server.")
        public Date getStartTime() {
            return startTime;
        }
        
        @Override
        public String toString() {
            double total = cacheMiss + cacheHits;
            double hitPercent = (total > 0) ? cacheHits / total : Double.NaN;
            
            StringBuilder bldr = new StringBuilder();
            bldr.append(treeName).append(" hits: ").append(cacheHits)
                .append(" misses: ").append(cacheMiss)
                .append(" hit pct: :").append(hitPercent);
            return bldr.toString();
        }
    }
}
