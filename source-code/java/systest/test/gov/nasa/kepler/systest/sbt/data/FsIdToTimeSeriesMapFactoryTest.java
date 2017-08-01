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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class FsIdToTimeSeriesMapFactoryTest extends JMockTest {

    @Test
    public void testGetInstance() {
        int startCadence = 1;
        int endCadence = 2;

        boolean exists = true;

        FsId fsId = new FsId("/fsid/fsid");

        Set<FsId> fsIds = ImmutableSet.of(fsId);

        FsIdSet fsIdSet = new FsIdSet(startCadence, endCadence, fsIds);

        List<FsIdSet> fsIdSets = ImmutableList.of(fsIdSet);

        TimeSeriesBatch timeSeriesBatch = mock(TimeSeriesBatch.class);

        List<TimeSeriesBatch> timeSeriesBatches = ImmutableList.of(timeSeriesBatch);

        TimeSeries timeSeries = mock(TimeSeries.class);

        Map<FsId, TimeSeries> timeSeriesBatchFsIdToTimeSeriesMap = ImmutableMap.of(fsId, timeSeries);

        FileStoreClient fileStoreClient = mock(FileStoreClient.class);

        allowing(fileStoreClient).readTimeSeriesBatch(fsIdSets, false);
        will(returnValue(timeSeriesBatches));

        allowing(timeSeriesBatch).timeSeries();
        will(returnValue(timeSeriesBatchFsIdToTimeSeriesMap));

        allowing(timeSeries).exists();
        will(returnValue(exists));

        allowing(timeSeries).id();
        will(returnValue(fsId));

        FsIdToTimeSeriesMapFactory fsIdToTimeSeriesMapFactory = new FsIdToTimeSeriesMapFactory(
            fileStoreClient);
        Map<FsId, TimeSeries> fsIdToTimeSeriesMap = fsIdToTimeSeriesMapFactory.createForFsIds(fsIdSets);

        Map<FsId, TimeSeries> expectedFsIdToTimeSeriesMap = ImmutableMap.of(fsId, timeSeries);

        assertEquals(expectedFsIdToTimeSeriesMap, fsIdToTimeSeriesMap);
    }

    @Test
    public void testGetInstanceMjd() {
        double startMjd = 1.1;
        double endMjd = 2.2;

        boolean exists = true;

        FsId fsId = new FsId("/fsid/fsid");

        Set<FsId> fsIds = ImmutableSet.of(fsId);

        MjdFsIdSet fsIdSet = new MjdFsIdSet(startMjd, endMjd, fsIds);

        List<MjdFsIdSet> fsIdSets = ImmutableList.of(fsIdSet);

        MjdTimeSeriesBatch timeSeriesBatch = mock(MjdTimeSeriesBatch.class);

        List<MjdTimeSeriesBatch> timeSeriesBatches = ImmutableList.of(timeSeriesBatch);

        FloatMjdTimeSeries timeSeries = mock(FloatMjdTimeSeries.class);

        Map<FsId, FloatMjdTimeSeries> timeSeriesBatchFsIdToTimeSeriesMap = ImmutableMap.of(fsId, timeSeries);

        FileStoreClient fileStoreClient = mock(FileStoreClient.class);

        allowing(fileStoreClient).readMjdTimeSeriesBatch(fsIdSets);
        will(returnValue(timeSeriesBatches));

        allowing(timeSeriesBatch).timeSeries();
        will(returnValue(timeSeriesBatchFsIdToTimeSeriesMap));

        allowing(timeSeries).exists();
        will(returnValue(exists));

        allowing(timeSeries).id();
        will(returnValue(fsId));

        FsIdToTimeSeriesMapFactory fsIdToTimeSeriesMapFactory = new FsIdToTimeSeriesMapFactory(
            fileStoreClient);
        Map<FsId, FloatMjdTimeSeries> fsIdToTimeSeriesMap = fsIdToTimeSeriesMapFactory.createForMjdFsIds(fsIdSets);

        Map<FsId, FloatMjdTimeSeries> expectedFsIdToTimeSeriesMap = ImmutableMap.of(fsId, timeSeries);

        assertEquals(expectedFsIdToTimeSeriesMap, fsIdToTimeSeriesMap);
    }

}
