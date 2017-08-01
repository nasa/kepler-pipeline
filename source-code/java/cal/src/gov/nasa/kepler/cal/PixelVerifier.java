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

package gov.nasa.kepler.cal;

import gnu.trove.TIntHashSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

import java.util.Collection;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Validates that the uncalibrated pixles are valid;  they match
 * something in the requantization table.
 * 
 * @author Sean McCauliff
 *
 */
class PixelVerifier {

    private static final Log log = LogFactory.getLog(PixelVerifier.class);
    
    private final TimestampSeries cadenceTimes;
    private final TIntHashSet validPixelValues = new TIntHashSet();
    
    PixelVerifier(List<RequantTable> requantTables, TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
        
        if (requantTables.size() == 1)  {
            int[] requantEntries = requantTables.get(0).getRequantEntries();
            for (int i=0; i < requantEntries.length; i++) {
                validPixelValues.add(requantEntries[i]);
            }
        } else {
            throw new IllegalStateException("Expected a single requant table but found "
                + requantTables.size() + " requant tables.");
        }
    }
    
    /**
     * Generates a log message if pixels are not present in the requantization
     * table.
     * 
     * @param uncalPixels a non-null collection of uncalibrated pixel
     * time series.
     * @return A count of pixel values not mentioned in the requant table.
     */
    int verify(Collection<TimeSeries> uncalPixels) {
        
        int missingPixels = 0;
        String missingMessage = null;
        for (TimeSeries ts : uncalPixels) {
            IntTimeSeries its = (IntTimeSeries) ts;
            int count = validatePixels(its);
            if (count > 0) {
                missingPixels += count;
                if (missingMessage == null) {
                    missingMessage = its.id().toString();
                }
            }
        }
        
        if (missingMessage != null) {
            log.error("Uncalibrated pixel time series \"" +
                missingMessage +
                "\" contains pixel values not present in the requantization table.  " +
                "There are a total of " + missingPixels +
                " pixel values not present in the requantization table.");
        }
        
        return missingPixels;
    }
    
    private int validatePixels(IntTimeSeries its) {
        int count=0;
        int[] pixelValues = its.iseries();
        for (SimpleInterval valid : its.validCadences()) {
            int i = (int) (valid.start() - its.startCadence());
            int iend = (int) (valid.end() - its.startCadence());
            for (; i <= iend; i++) {
                if (cadenceTimes.gapIndicators[i]) {
                    continue;
                }
                
                if (!cadenceTimes.requantEnabled[i]) {
                    continue;
                }
                
                if (!validPixelValues.contains(pixelValues[i])) {
                    count++;
                }
            }
        }
        
        return count;
    }
}
