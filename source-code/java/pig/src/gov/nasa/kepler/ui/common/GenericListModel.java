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

package gov.nasa.kepler.ui.common;

import java.util.LinkedList;
import java.util.List;

import javax.swing.AbstractListModel;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class GenericListModel<T> extends AbstractListModel {

    private List<T> list = new LinkedList<T>();

    public GenericListModel() {
    }

    public GenericListModel(List<T> list) {
        this.list = list;
    }

    public int getSize() {
        return list.size();
    }

    public T getElementAt(int index) {
        return list.get(index);
    }

    /**
     * @return Returns the list.
     */
    public List<T> getList() {
        return list;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.util.LinkedList#add(E)
     */
    public boolean add(T o) {
        boolean added = list.add(o);
        if (added) {
            fireIntervalAdded(this, list.size(), list.size());
        }
        return added;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.util.LinkedList#clear()
     */
    public void clear() {
        int oldSize = list.size();
        list.clear();
        fireIntervalRemoved(this, 0, oldSize);
    }
    
    public void setList(List<T> newList){
        clear();
        
        this.list = newList;
        fireIntervalAdded(this, 0, list.size());
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.util.LinkedList#get(int)
     */
    public T get(int index) {
        return list.get(index);
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.util.AbstractCollection#isEmpty()
     */
    public boolean isEmpty() {
        return list.isEmpty();
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.util.LinkedList#remove(int)
     */
    public T remove(int index) {
        T o = list.remove(index);
        fireIntervalRemoved(this, list.size(), list.size());
        return o;
    }

}
