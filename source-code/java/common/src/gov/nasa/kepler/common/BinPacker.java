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

package gov.nasa.kepler.common;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.LinkedList;

/**
 * Implements the First Fit Decreasing algorithm for bin packing.
 * 
 * @author Sean McCauliff
 *
 */
public final class BinPacker<T> {
    
    /**
     * Pack a collection of objects into as few bins as possible.
     * @param items A non-null collection of things to pack into bins.  An
     * entry in this collection may be null in which case it will be skipped.
     * @param sizer Something that returns a size for a given object.  This may
     * not be null.
     * @param maxBinSize a positive integer.
     * @return a list of bins (other lists). If sizer.sizeOf(items[i]) returns a
     * number greater than binSize then items[i] will have it's own bin.
     */
    public List<List<T>> pack(Collection<T> items, Sizer<T> sizer, int maxBinSize) {
        ArrayList<ItemWithSize<T>> itemsWithSize = new ArrayList<ItemWithSize<T>>(items.size());
        
        for (T item : items) {
            if (item == null) {
                continue;
            }
            itemsWithSize.add(new ItemWithSize<T>(sizer.sizeOf(item), item));
        }
        Collections.sort(itemsWithSize);
        
        List<Integer> binSizes = new ArrayList<Integer>();
        List<List<T>> bins = new ArrayList<List<T>>();
        for (ItemWithSize<T> itemWithSize : itemsWithSize) {
            boolean packed = false;
            for (int i=0; i < binSizes.size(); i++) {
                if (binSizes.get(i) + itemWithSize.sizeOf <= maxBinSize) {
                    binSizes.set(i, binSizes.get(i) + itemWithSize.sizeOf);
                    bins.get(i).add(itemWithSize.item);
                    packed = true;
                    break;
                }
            }
            
            if (!packed) {
                //Does not fit into existing bins so add a bin.
                binSizes.add(itemWithSize.sizeOf);
                List<T> bin = new LinkedList<T>();
                bin.add(itemWithSize.item);
                bins.add(bin);
            }
        }
        
        return bins;
    }
    
    /**
     * Return the size of the object to be packed into a bin.
     * 
     * @author Sean McCauliff
     *
     */
    public interface Sizer<T> {

        /**
         * 
         * @param item non-null
         * @return a non-negative integer.  This should always return the same value
         * for the same item.
         */
        int sizeOf(T item);
    }
    
    private static final class ItemWithSize<T> implements Comparable<ItemWithSize<T>> {
        public final int sizeOf;
        public final T item;
        
        public ItemWithSize(int sizeOf, T item) {
            if (item == null) {
                throw new NullPointerException("item may not be null");
            }
            if (sizeOf < 0) {
                throw new IllegalArgumentException("sizeOf < 0");
            }
            this.sizeOf = sizeOf;
            this.item = item;
        }
        @Override
        public int compareTo(ItemWithSize<T> o) {
            return this.sizeOf - o.sizeOf; 
        }
        
        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ((item == null) ? 0 : item.hashCode());
            result = prime * result + sizeOf;
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
            
            ItemWithSize<?> other = (ItemWithSize<?>) obj;
            if (sizeOf != other.sizeOf)
                return false;
            if (item == null) {
                if (other.item != null)
                    return false;
            } else if (!item.equals(other.item))
                return false;
            
            return true;
        }
    }
}
