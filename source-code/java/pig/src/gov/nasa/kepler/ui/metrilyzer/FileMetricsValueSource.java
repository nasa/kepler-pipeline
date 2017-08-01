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
import gov.nasa.kepler.hibernate.metrics.MetricValue;
import gov.nasa.kepler.services.metrics.DeltaMetricValueGenerator;
import gov.nasa.kepler.services.metrics.MetricsFileParser;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.util.Collection;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;

/**
 * Read metric information from a file.
 * 
 * @author Sean McCauliff
 *
 */
class FileMetricsValueSource implements MetricsValueSource {

    private final MetricsFileParser metricsFileParser;
    
    
    public FileMetricsValueSource(MetricsFileParser metricsFileParser) {
        this.metricsFileParser = metricsFileParser;
    }

    @Override
    public Map<MetricType, Collection<MetricValue>> metricValues(
            List<MetricType> selectedMetricTypes, Date windowStart,
            Date windowEnd) {

        Map<MetricType, Collection<MetricValue>> rv = 
            Maps.newHashMapWithExpectedSize(selectedMetricTypes.size());
        Set<MetricType> typeSet = ImmutableSet.copyOf(selectedMetricTypes);
        DeltaMetricValueGenerator metricIt = null;
        try {
            metricIt = new DeltaMetricValueGenerator(metricsFileParser.parseFile());
        } catch (IOException ioe) {
            throw new PipelineException(ioe);
        }
        //TODO:  could probably break this off after seeing a date
        //greater than the date we are interested in.
       for (MetricValue metricDelta : metricIt) {
            if (metricDelta.getTimestamp().before(windowStart)) {
                continue;
            }
            if (metricDelta.getTimestamp().after(windowEnd)) {
                continue;
            }
            MetricType metricType = metricDelta.getMetricType();
            if (!typeSet.contains(metricType)) {
                continue;
            }
            Collection<MetricValue> valuesForType = rv.get(metricDelta.getMetricType());
            if (valuesForType == null) {
                //Todd likes linked lists for this kind of thing.
                valuesForType = new LinkedList<MetricValue>();
                rv.put(metricDelta.getMetricType(), valuesForType);
            }
            valuesForType.add(metricDelta);
        }
        return rv;
    }

    @Override
    public Map<MetricType, Pair<Date, Date>> metricStartEndDates(
            List<MetricType> selectedMetricTypes) {
        
         //This actually returns a map of all the metric ranges not just
         //the ones that were asked about.
         return metricsFileParser.getTimestampRange();
    }

}
