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

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Finds the missing cosmic rays and generates the empty series needed to
 * erase old cosmic rays that where not found in the current crop of
 * cosmic rays.  
 * 
 * 
 * @author Sean McCauliff
 *
 */
public class CosmicRayEraser {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(CosmicRayEraser.class);
    
    private final Collection<FsId> allFsIds;
    
    // Authoritative 
    private final List<FloatMjdTimeSeries> authoritativeEvents;
    
    public CosmicRayEraser(List<FloatMjdTimeSeries> discoveredEvents, Collection<FsId> allIds) { 
        this.authoritativeEvents = discoveredEvents;
        this.allFsIds = allIds;
    }
    
    public void storeAndErase(double startMjd, double endMjd, long originator) {
        Set<FsId> difference = new HashSet<FsId>(allFsIds);
        for (FloatMjdTimeSeries ts : authoritativeEvents) {
            difference.remove(ts.id());
        }
        
        List<FloatMjdTimeSeries> storeMe = new ArrayList<FloatMjdTimeSeries>(authoritativeEvents);
        for (FsId emptyId : difference) {
            FloatMjdTimeSeries eraseMe =
                new FloatMjdTimeSeries(emptyId,startMjd, endMjd, 
                        FloatMjdTimeSeries.EMPTY_MJD, FloatMjdTimeSeries.EMPTY_VALUES, originator );
            storeMe.add(eraseMe);
        }
        
        FloatMjdTimeSeries[] finalArray = new FloatMjdTimeSeries[storeMe.size()];
        storeMe.toArray(finalArray);
        //This is here so the mocked objects will work correctly.
        Arrays.sort(finalArray, new Comparator<FloatMjdTimeSeries>() {

            @Override
            public int compare(FloatMjdTimeSeries o1, FloatMjdTimeSeries o2) {
                return o1.id().compareTo(o2.id());
            }
            
        });
        
        FileStoreClient fsClient = getFileStoreClient();
        log.info("Writing " + finalArray.length + " cosmic ray series.");
        fsClient.writeMjdTimeSeries(finalArray);
        log.info("Completed writing cosmic ray series.");
    }
    
    protected FileStoreClient getFileStoreClient() {
        return FileStoreClientFactory.getInstance();
    }
    
}
