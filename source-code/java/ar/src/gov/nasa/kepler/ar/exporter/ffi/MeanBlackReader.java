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

package gov.nasa.kepler.ar.exporter.ffi;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.RequantTable;

import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;

import com.google.common.collect.Lists;

/**
 * Yes, this is a class to fetch a single, scalar value out of the database.
 * This is here because most of the data structures assume we have long cadences
 * for every possible time we are interested in.  This is not the case for FFIs.
 * 
 * @author Sean McCauliff
 *
 */
public class MeanBlackReader {

    
    public double meanBlack(double startMjd, double endMjd,
        int ccdModule, int ccdOutput) {

        List<RequantTable> requantTables = 
            getCompressionCrud().retrieveRequantTables(startMjd, endMjd);
    
        if (requantTables.isEmpty()) {
            //Try using planned start time since we may not have data
            //in the pixel log that would tell us what was going on when
            //data was collected.
            requantTables = Lists.newArrayList(getCompressionCrud().retrieveRequantTables(0, Float.MAX_VALUE));
            
            //Clean up all the crap.
            Iterator<RequantTable> it = requantTables.iterator();
            while (it.hasNext()) {
                RequantTable rqTable = it.next();
                if (rqTable == null || rqTable.getPlannedStartTime() == null) {
                    it.remove();
                }
            }
            
            //Sort so that tables with earlier planned start times are first.
            Collections.sort(requantTables, new Comparator<RequantTable>() {
    
                @Override
                public int compare(RequantTable o1, RequantTable o2) {
                    return o1.getPlannedStartTime().compareTo(o2.getPlannedStartTime());
                }
            });
            
            //Select the first requant table that has a planned start time after
            //our start time.
            for (RequantTable requantTable : requantTables) {
                double tablePlannedStartMjd = ModifiedJulianDate.dateToMjd(requantTable.getPlannedStartTime());
                if (tablePlannedStartMjd < startMjd) {
                    requantTables = Collections.singletonList(requantTable);
                    break;
                }
            }
        }
        if (requantTables.size() != 1) {
            throw new IllegalStateException("Expected one requant table," +
                    " but found " + requantTables.size() + ".");
        }
        return requantTables.get(0).getMeanBlackValue(ccdModule, ccdOutput);
    }
    
    protected CompressionCrud getCompressionCrud() {
        return new CompressionCrud();
    }
}
