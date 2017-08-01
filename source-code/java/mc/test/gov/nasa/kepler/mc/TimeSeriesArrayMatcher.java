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

package gov.nasa.kepler.mc;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import gov.nasa.kepler.fs.api.TimeSeries;

import org.apache.commons.collections.Bag;
import org.apache.commons.collections.bag.HashBag;
import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hamcrest.Description;
import org.hamcrest.TypeSafeMatcher;

import com.google.common.collect.Lists;

/**
 * Compare against the time series array in an unordered manner.
 * This logs differences.
 * This does not make a defense copy of the expected parameter.
 * 
 * <pre>
 *   Map<FsId, TimeSeries> stuff = ...
 *   final TimeSeriesArrayMatcher matcher = new TimeSeriesArrayMatcher(stuff.values());
 *   final FileStoreClient fsClient = mockery.mock(FileStoreClient.class);
 *   mockery.checking(new Expectations() {{
 *       one(fsClient).writeTimeSeries(with(matcher));
 *   }});
 *</pre>
 * @author Sean McCauliff
 *
 */
public class TimeSeriesArrayMatcher extends TypeSafeMatcher<TimeSeries[]> {

    private static final Log log = LogFactory.getLog(TimeSeriesArrayMatcher.class);
    
    private final Collection<TimeSeries> expected;
    
    /**
     * 
     * @param expected defensive copy not made
     */
    public TimeSeriesArrayMatcher(TimeSeries[] expected) {
        this.expected = Arrays.asList(expected);
    }
    
    /**
     * 
     * @param expected defenseive copy not made
     */
    public TimeSeriesArrayMatcher(Collection<TimeSeries> expected) {
        this.expected = expected;
    }
    
    @Override
    public void describeTo(Description arg0) {
        arg0.appendText("expected TimeSeries[] " + 
            ReflectionToStringBuilder.toString(expected));
    }

    @SuppressWarnings("unchecked")
    @Override
    public boolean matchesSafely(TimeSeries[] actual) {
        Bag bag = new HashBag();
        bag.addAll(expected);
        
        List<TimeSeries> seriesMissingInExpected = Lists.newArrayList();
        for (TimeSeries actualSeries : actual) {
            if (!bag.remove(actualSeries)) {
                seriesMissingInExpected.add(actualSeries);
            }
        }
        
        StringBuilder err = new StringBuilder();
        if (!bag.isEmpty()) {
            err.append("Expected, but did not find the following time series: \n");
            for (Object o : bag) {
                err.append("\t").append(o).append("\n");
            }
        }
        
        if (!seriesMissingInExpected.isEmpty()) {
            err.append("Unexpected time series:  \n");
            for (TimeSeries unxpected : seriesMissingInExpected) {
                err.append("\t").append(unxpected).append("\n");
            }
        }
        
        if (err.length() != 0) {
            log.error(err);
            return false;
        }  else {
            return true;
        }
    }

}
