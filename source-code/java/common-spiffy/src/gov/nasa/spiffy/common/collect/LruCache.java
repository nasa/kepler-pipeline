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

package gov.nasa.spiffy.common.collect;


import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Least recently used cache.  Note the accessOrder parameter which lets you
 * use determine if you want the cache ordered on insert or last access time.
 * 
 * @author Sean McCauliff
 *
 */
public class LruCache<K,V> extends LinkedHashMap<K,V> implements Cache<K,V> {

    private static final long serialVersionUID = -2160084513590863217L;
    
    private final int maxItems;
    
    /**
     * 
     */
    public LruCache(int maxItems) {
        super();
        this.maxItems = maxItems;
        checkMaxItems();
    }

    /**
     * @param initialCapacity
     */
    public LruCache(int maxItems, int initialCapacity) {
        super(initialCapacity);
        this.maxItems = maxItems;
        checkMaxItems();
    }

    /**
     * @param m
     */
    public LruCache(int maxItems, Map<K,V> m) {
        super(m);
        this.maxItems = maxItems;
        if (m.size() > maxItems) {
            throw new IllegalArgumentException("Map too large for maxItems.");
        }
        checkMaxItems();
    }

    /**
     * @param initialCapacity
     * @param loadFactor
     */
    public LruCache(int maxItems, int initialCapacity, float loadFactor) {
        super(initialCapacity, loadFactor);
        this.maxItems = maxItems;
        checkMaxItems();
    }

    /**
     * @param initialCapacity
     * @param loadFactor
     * @param accessOrder
     */
    public LruCache(int maxItems, int initialCapacity, float loadFactor, boolean accessOrder) {
        super(initialCapacity, loadFactor, accessOrder);
        this.maxItems = maxItems;
        checkMaxItems();
    }

    public LruCache(int maxItems, boolean accessOrder) {
        super(16, 0.75f, accessOrder);
        this.maxItems = maxItems;
        checkMaxItems();
    }
    
    private void checkMaxItems() {
        if (maxItems <=0) {
            throw new IllegalArgumentException("maxItems must be positive.");
        }
    }
    
    @Override
    protected boolean removeEldestEntry(Map.Entry<K,V> eldest) {
        return this.size() > maxItems;
    }
}
