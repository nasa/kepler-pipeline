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

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.google.common.collect.Lists;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;

import static gov.nasa.kepler.cal.QuarterCadences.cadenceIntervalsByQuarter;
import static gov.nasa.kepler.cal.QuarterCadences.getNewPixelId;
/**
 * @author Sean McCauliff
 *
 */
public class ConvertToPerQuarterPixelStorage {

    /**
     * @param args
     */
    public static void main(String[] args) {
        int ccdModule = 15;
        int ccdOutput = 1;
        FsId queryTemplate = 
            CalFsIdFactory.getTimeSeriesFsId(PixelTimeSeriesType.SOC_CAL,
            TargetTable.TargetType.LONG_CADENCE, ccdModule, ccdOutput, 1024, 1023);
        String query = queryTemplate.toString().replace("1024", "\\d");
        query = query.replace("1023", "\\d");
        Pattern pixelRegex = Pattern.compile(query.replace("\\d", "(\\d+)"));
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        Set<FsId> allPixelIds = fsClient.queryIds2("TimeSeries@" + query);
        try {
            for (int quarterIndex=0; quarterIndex < cadenceIntervalsByQuarter.length; quarterIndex++) {
                int startCadence = cadenceIntervalsByQuarter[quarterIndex][0];
                int endCadence = cadenceIntervalsByQuarter[quarterIndex][1];
                fsClient.beginLocalFsTransaction();
                Map<FsId, TimeSeries> timeSeriesChunk = 
                    fsClient.readTimeSeries(allPixelIds, startCadence, endCadence, false);
                List<TimeSeries> seriesForQuarter = Lists.newLinkedList();
                for (TimeSeries ts : timeSeriesChunk.values()) {
                    if (!ts.exists() || ts.validCadences().isEmpty()) {
                        continue;
                    }
                    FloatTimeSeries origin = ts.asFloatTimeSeries();
                    Matcher m = pixelRegex.matcher(origin.id().toString());
                    m.matches();
                    int ccdRow = Integer.parseInt(m.group(1));
                    int ccdCol = Integer.parseInt(m.group(2));
                    FsId destFsId = getNewPixelId(PixelTimeSeriesType.SOC_CAL,
                        TargetTable.TargetType.LONG_CADENCE,
                        quarterIndex-1, ccdModule, ccdOutput, ccdRow, ccdCol);
                    FloatTimeSeries destination = 
                        new FloatTimeSeries(destFsId, origin.fseries(), origin.startCadence(),
                            origin.endCadence(), origin.validCadences(),
                            origin.originators());
                    seriesForQuarter.add(destination);
                }
                fsClient.writeTimeSeries(seriesForQuarter.toArray(new TimeSeries[0]));
                fsClient.commitLocalFsTransaction();
            }
        } finally {
            try {
                fsClient.rollbackLocalFsTransactionIfActive();
            } catch (Exception e) {
                System.err.println("Exception while rollingback transaction.");
                e.printStackTrace(System.err);
            }
        }
        
    }

}
