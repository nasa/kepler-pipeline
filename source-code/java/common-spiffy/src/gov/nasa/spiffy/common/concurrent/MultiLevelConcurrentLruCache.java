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

package gov.nasa.spiffy.common.concurrent;

import gov.nasa.spiffy.common.collect.Cache;
import gov.nasa.spiffy.common.collect.LruCache;

/**
 * Also keeps thread local copies of frequently used cache entries.  Somewhat less
 * LRU than ConcurrentLruCache.  Changes to the cache are written through to 
 * the primary cache.  But changes to the primary cache are not reflected in
 * the thread local caches.  The thread local caches are not coherent either.
 * This can lead to problem if you expect the return values from put() or 
 * remove to be consistent.  get() may return different values from different
 * threads.
 * 
 * @author Sean McCauliff
 *
 */
public class MultiLevelConcurrentLruCache<K,V> implements Cache<K, V> {

    private final static int MAX_L1_SIZE = 8;
    
    private final ThreadLocal<LruCache<K, V>> L1Cache = new ThreadLocal<LruCache<K,V>>() {
        @Override
        protected LruCache<K,V> initialValue() {
            return new LruCache<K,V>(MAX_L1_SIZE);
        }
    };
    
    private final ConcurrentLruCache<K, V> L2Cache;
    
    public MultiLevelConcurrentLruCache(int capacity) {
        L2Cache = new ConcurrentLruCache<K, V>(capacity);
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public V get(Object key) {
        V value = L1Cache.get().get(key);
        if (value != null) {
            return value;
        }
        value = L2Cache.get(key);
        if (value == null) {
            return null;
        }
        L1Cache.get().put((K)key, value);
        return value;
    }

    @Override
    public V put(K key, V value) {
        V oldL1 = L1Cache.get().put(key, value);
        V oldL2 = L2Cache.put(key, value);
        if (oldL2 != null) {
            return oldL2;
        } else if (oldL1 != null) {
            return oldL1;
        } 
        return null;
    }

    @Override
    public V remove(Object key) {
        V oldL1 = L1Cache.get().remove(key);
        V oldL2 = L2Cache.remove(key);
        if (oldL2 != null) {
            return oldL2;
        } else if (oldL1 != null) {
            return oldL1;
        } else {
            return null;
        }
    }
}
