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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Iterator;

/**
 * Allows for slightly more efficent means of removing and insterting 
 * intervals of data from an ArrayList.
 * 
 * Exposes the method which removes a range of elements from 
 * the ArrayList which for some reason is protected in java.util.ArrayList.
 *
 * 
 * @author Sean McCauliff
 *
 */
public class RemovableArrayList<T> extends ArrayList<T> {

    /**
     * 
     */
    private static final long serialVersionUID = -7536249496170417383L;

    /**
     * 
     */
    public RemovableArrayList() {
    }

    /**
     * @param initialCapacity
     */
    public RemovableArrayList(int initialCapacity) {
        super(initialCapacity);
    }

    /**
     * @param c
     */
    public RemovableArrayList(Collection<T> c) {
        super(c);
    }

    /**
     * Removes a section of the array.  ArrayList implements this method
     * as removeRange, but does not expose it as public.
     * @param start
     * @param end Exclusive
     */
    public void removeInterval(int start, int end) {
        super.removeRange(start, end);
    }
    
    /**
     * Inserts data at the speciried location.
     */
    public void insertAt(int start, final T[] data) {
        Collection< T> tmpCollection = new Collection<T>() {

            @Override
            public boolean add(T e) {
                throw new IllegalStateException("Read only.");
            }

            @Override
            public boolean addAll(Collection<? extends T> c) {
                throw new IllegalStateException("Read only.");
            }

            @Override
            public void clear() {
                throw new IllegalStateException("Read only.");
                
            }

            @Override
            public boolean contains(Object o) {
                throw new IllegalStateException("Not implemented.");
            }

            @Override
            public boolean containsAll(Collection<?> c) {
                throw new IllegalStateException("Not implemented.");
            }

            @Override
            public boolean isEmpty() {
                return data.length == 0;
            }

            @Override
            public Iterator<T> iterator() {
                throw new IllegalStateException("Not implemented.");
            }

            @Override
            public boolean remove(Object o) {
                throw new IllegalStateException("Read only.");
            }

            @Override
            public boolean removeAll(Collection<?> c) {
                throw new IllegalStateException("Read only.");
            }

            @Override
            public boolean retainAll(Collection<?> c) {
                throw new IllegalStateException("Not implemented.");
            }

            @Override
            public int size() {
                return data.length;
            }

            @Override
            public Object[] toArray() {
                return data;
            }

            @Override
            public <TRv> TRv[] toArray(TRv[] a) {
                throw new IllegalStateException("Not implemented.");
            }
           
        };
        
        super.addAll(start, tmpCollection);
    }
}
