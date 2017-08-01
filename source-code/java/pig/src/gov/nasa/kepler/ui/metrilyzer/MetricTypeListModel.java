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

package gov.nasa.kepler.ui.metrilyzer;

import gov.nasa.kepler.hibernate.metrics.MetricType;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import javax.swing.DefaultComboBoxModel;

import org.apache.commons.collections.list.TreeList;

/**
 * Wraps the metrics types in a ComboBoxModel.
 * 
 * @author tklaus
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("serial")
abstract class MetricTypeListModel extends DefaultComboBoxModel {
    private TreeList types = new TreeList();

    public MetricTypeListModel() {
    }

    protected void updateTypes(Set<MetricType> metricTypes) {
        MetricType[] sortableArray = new MetricType[metricTypes.size()];
        metricTypes.toArray(sortableArray);
        Arrays.sort(sortableArray);
        types = new TreeList(Arrays.asList(sortableArray));
        fireContentsChanged(this, 0, sortableArray.length);
    }
    
    /**
     * Completely refresh the metric types.
     */
    public abstract void loadMetricTypes();
    

    @Override
    public Object getElementAt(int index) {
        return ((MetricType)types.get(index)).getName();
    }

    @Override
    public int getSize() {
        return types.size();
    }

    @SuppressWarnings("unchecked")
    public void add(MetricType metricType) {
        int insertIndex = Collections.binarySearch(types, metricType);
        if (insertIndex >= 0) {
            //dup
            return;
        }
        insertIndex = -insertIndex - 1;
        types.add(insertIndex, metricType);
        fireContentsChanged(this, insertIndex, insertIndex);
    }

    public MetricType remove(int index) {
        MetricType mt = (MetricType) types.remove(index);
        fireContentsChanged(this, index, index);
        return mt;
    }

    @SuppressWarnings("unchecked")
    public List<MetricType> getTypes() {
       return types;
    }
}
