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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Maps.newLinkedHashMap;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;

import java.util.List;
import java.util.Map;

/**
 * This class creates {@link Map}s of {@link FsId} to time series.
 * 
 * @author Miles Cote
 * 
 */
public class FsIdToTimeSeriesMapFactory {

    private final FileStoreClient fileStoreClient;

    public FsIdToTimeSeriesMapFactory(FileStoreClient fileStoreClient) {
        this.fileStoreClient = fileStoreClient;
    }

    public Map<FsId, TimeSeries> createForFsIds(List<FsIdSet> fsIdSets) {
        int fsIdCount = 0;
        for (FsIdSet fsIdSet : fsIdSets) {
            fsIdCount += fsIdSet.ids()
                .size();
        }

        TicToc.tic("Retrieving " + fsIdCount
            + " time series from the filestore");

        TicToc.tic("Calling fileStoreClient.readTimeSeriesBatch()", 1);
        List<TimeSeriesBatch> timeSeriesBatches = fileStoreClient.readTimeSeriesBatch(
            fsIdSets, false);
        TicToc.toc();

        TicToc.tic("Creating fsIdToTimeSeries map", 2);
        Map<FsId, TimeSeries> fsIdToTimeSeries = newLinkedHashMap();
        for (TimeSeriesBatch timeSeriesBatch : timeSeriesBatches) {
            for (TimeSeries timeSeries : timeSeriesBatch.timeSeries()
                .values()) {
                if (timeSeries.exists()) {
                    fsIdToTimeSeries.put(timeSeries.id(), timeSeries);
                }
            }
        }
        TicToc.toc();

        TicToc.toc();

        return fsIdToTimeSeries;
    }

    public Map<FsId, FloatMjdTimeSeries> createForMjdFsIds(
        List<MjdFsIdSet> mjdFsIdSets) {
        int mjdFsIdCount = 0;
        for (MjdFsIdSet mjdFsIdSet : mjdFsIdSets) {
            mjdFsIdCount += mjdFsIdSet.ids()
                .size();
        }

        TicToc.tic("Retrieving " + mjdFsIdCount
            + " mjd time series from the filestore");

        TicToc.tic("Calling fileStoreClient.readMjdTimeSeriesBatch()", 1);
        List<MjdTimeSeriesBatch> mjdTimeSeriesBatches = fileStoreClient.readMjdTimeSeriesBatch(mjdFsIdSets);
        TicToc.toc();

        TicToc.tic("Creating fsIdToMjdTimeSeries map", 2);
        Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries = newLinkedHashMap();
        for (MjdTimeSeriesBatch mjdTimeSeriesBatch : mjdTimeSeriesBatches) {
            for (FloatMjdTimeSeries mjdTimeSeries : mjdTimeSeriesBatch.timeSeries()
                .values()) {
                if (mjdTimeSeries.exists()) {
                    fsIdToMjdTimeSeries.put(mjdTimeSeries.id(), mjdTimeSeries);
                }
            }
        }
        TicToc.toc();

        TicToc.toc();

        return fsIdToMjdTimeSeries;
    }

}
