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

package gov.nasa.kepler.services.metrics;

import gnu.trove.TObjectFloatHashMap;
import gov.nasa.kepler.hibernate.metrics.MetricType;
import gov.nasa.kepler.hibernate.metrics.MetricValue;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

/**
 * Given an iterator of metric values this is a new iterator of metric values
 * that represent the delta's between metric values of the same type from the
 * same source.
 * 
 * @author Sean McCauliff
 *
 */
public class DeltaMetricValueGenerator implements Iterator<MetricValue>, Iterable<MetricValue> {

    private final Iterator<MetricValue> srcMetricValues;
    /** Maps (metric source, metric type) -> previous metric value */
    private final TObjectFloatHashMap<Pair<String, MetricType>> prevMetricSum = 
            new TObjectFloatHashMap<Pair<String,MetricType>>();
    
    public DeltaMetricValueGenerator(Iterator<MetricValue> src) {
        this.srcMetricValues = src;
    }
    
    @Override
    public Iterator<MetricValue> iterator() {
        return this;
    }

    @Override
    public boolean hasNext() {
        return srcMetricValues.hasNext();
    }

    @Override
    public MetricValue next() {
        MetricValue nextSrc = srcMetricValues.next();
        Pair<String, MetricType> key = Pair.of(nextSrc.getSource(), nextSrc.getMetricType());
        MetricValue rv = nextSrc;
        if (prevMetricSum.containsKey(key)) {
            float prevSum = prevMetricSum.get(key);
            float delta = nextSrc.getValue() - prevSum;
            if (delta < 0) {
                throw new IllegalStateException("delta " + delta +
                    " is not increasing or zero for metric value " + nextSrc);
            }
            rv = new MetricValue(nextSrc.getSource(), nextSrc.getMetricType(), nextSrc.getTimestamp(), delta);
        }
        prevMetricSum.put(key, nextSrc.getValue());
        return rv;
    }

    @Override
    public void remove() {
        throw new UnsupportedOperationException();
    }

}
