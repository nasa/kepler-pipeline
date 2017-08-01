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

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import com.google.common.collect.Lists;

import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.FitsConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;

import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.FILE_TIMESTAMP;

/**
 * Get all the FFIs for the specified start and end times.
 * @author Sean McCauliff
 *
 */
class FfiFinder {


    private final FileStoreClient fsClient;
    
    public FfiFinder(FileStoreClient fsClient) {
        this.fsClient = fsClient;
    }
    
    /**
     * 
     * @param startMjd
     * @param endMjd
     * @param ccdModule
     * @param ccdOutput
     * @return If no ffis are present then this returns the empty list.  Else
     * it will return a list of FsIds for ffis that are sorted by timestamp.
     * @throws ParseException 
     */
    public List<FsId> find(double startMjd, double endMjd,
        int ccdModule, int ccdOutput) throws ParseException {
        
        //Search for all timestamps with the specified mod/out and type.
        FsId templateId = 
            DrFsIdFactory.getSingleChannelFfiFile("blah", FfiType.ORIG, ccdModule, ccdOutput);
        String queryString = "BLOB@" + templateId.toString().replace("blah", "*");
        
        Set<FsId> queriedIds = fsClient.queryIds2(queryString);
        
        List<FsId> rv = Lists.newArrayList();
        final SimpleDateFormat dateParser = new SimpleDateFormat(FitsConstants.FILE_TIMESTAMP_FORMAT);
        dateParser.setTimeZone(TimeZone.getTimeZone("UTC"));
        for (FsId ffiId : queriedIds) {
            double ffiMjd = ffiToMjd(dateParser, ffiId);
            if (ffiMjd >= startMjd && ffiMjd > endMjd) {
                rv.add(ffiId);
            }
        }
        
        Comparator<FsId> byFsIdTimeStamp = new Comparator<FsId>() {

            @Override
            public int compare(FsId o1, FsId o2) {
                try {
                    double mjd1 = ffiToMjd(dateParser, o1);
                    double mjd2 = ffiToMjd(dateParser, o2);
                    return Double.compare(mjd1, mjd2);
                } catch (ParseException px) {
                    throw new IllegalStateException(px);
                }
            }
            
        };
        Collections.sort(rv, byFsIdTimeStamp);
        return rv;
        
    }

    private static double ffiToMjd(SimpleDateFormat dateParser, FsId ffiId)
        throws ParseException {
        Map<String, Object> parsedFsId = DrFsIdFactory.parseSingleChannelFfi(ffiId);
        String timestamp = (String) parsedFsId.get(FILE_TIMESTAMP);
        double ffiMjd = ModifiedJulianDate.dateToMjd(dateParser.parse(timestamp));
        return ffiMjd;
    }

}
