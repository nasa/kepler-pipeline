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

import java.util.Collections;
import java.util.ConcurrentModificationException;
import java.util.Map;
import java.util.WeakHashMap;

/**
 * Allow more than one thread to read and write to the LRU cache at at time
 * at some loss of LRUness.
 * 
 * @author Sean McCauliff
 *
 */
public class ConcurrentLruCache<K,V> implements Cache<K, V>{

    private static final Map<ConcurrentLruCache<?,?>, Object> allCaches =
        Collections.synchronizedMap(new WeakHashMap<ConcurrentLruCache<?, ?>, Object>());
    
    public static void clearAllCaches() {
        boolean done = false;
        while (!done) {
            try {
                for (ConcurrentLruCache<?, ?> c : allCaches.keySet()) {
                    c.clear();
                }
                done = true;
            } catch (ConcurrentModificationException cmx) {
                //This can happen if the garbage collector collects an entry
                //while iterating through this collection.
            }
        }
    }
    
	private final Map<K,V>[] caches;
	
	@SuppressWarnings("unchecked")
    public ConcurrentLruCache(int capacity) {
		int stripeSize = ConcurrentUtil.numberOfConcurrentBins(2);
		int itemsPerCache = Math.max(1,capacity/stripeSize);

		caches = new Map[stripeSize];
		for (int i=0; i < stripeSize; i++) {
			caches[i] = Collections.synchronizedMap(new LruCache<K, V>(itemsPerCache));
		}

		allCaches.put(this, Boolean.TRUE);
	}
	
	@Override
    public V put(K key, V value) {
		return caches[cacheIndex(key)].put(key, value);
	}
	
	@Override
    public V get(Object key) {
		return caches[cacheIndex(key)].get(key);
	}
	
	@Override
    public V remove(Object key) {
		return caches[cacheIndex(key)].remove(key);
	}
	
	private int cacheIndex(Object key) {
		return ( key.hashCode() & 0x7FFFFFFF) % caches.length;
	}
	
	public void clear() {
		for (Map<K,V> c : caches) {
			c.clear();
		}
	}
}
