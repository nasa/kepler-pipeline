/**
 * $Source$ $Date: 2017-07-27 10:04:13 -0700 (Thu, 27 Jul 2017) $
 * 
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
package gov.nasa.kepler.fs.api;

import gov.nasa.kepler.fs.api.gen.*;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.spiffy.common.intervals.Interval;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * The interface methods for dealing with TimeSeries data.
 * 
 * @author Sean McCauliff
 */
public interface TimeSeriesClient {

    /**
     * Requests time series data for one or more time series. This starts and
     * rollsback a local transaction if none has been started. All TimeSeries
     * returned by this method will have the same length.
     * 
     * @param id A unique id. This is generated elsewhere from timeseries
     * specific parameters.
     * @param startCadence A non-negative integer. Inclusive.
     * @param endCadence A non-negative integer. Inclusive. So [start, end]
     * where start = 10 and end = 10 will result in an series with a single
     * value returned.
     * @param existsError enables FileStoreIdNotFoundException else exists()
     * will return false on all the time series returned by this method.
     * @return IntTimeSeries data ordered by increasing cadence and return[i]
     * will have id[i]
     * @throws FileStoreIdNotFoundException If no data has been written to one
     * of the ids.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    IntTimeSeries[] readTimeSeriesAsInt(FsId[] id, int startCadence,
        int endCadence, boolean existsError);

    /**
     * If a TimeSeries does not exist then this method WILL throw an error.
     * 
     * @param id
     * @param startCadence
     * @param endCadence
     * @return
     * @throws FileStoreException
     */
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    IntTimeSeries[] readTimeSeriesAsInt(FsId[] id, int startCadence,
        int endCadence);

    /**
     * Requests time series data for one or more time series. This starts and
     * rollsback a local transaction if none has been started. TimeSeries
     * returned by this method may be of different lengths.
     * 
     * @param id A unique id. This is generated elsewhere from timeseries
     * specific parameters.
     * @return IntTimeSeries returned by this method may be of different
     * lengths, if a TimeSeries does not exist then (has never been written)
     * then the TimeSeries returned with have its exists() flag set to false.
     * return[i] has FsId id[i]
     * @throws FileStoreException
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] id, boolean existsFlag);

    /**
     * This WILL throw an exception if any ids do not exist.
     * 
     * @param id
     * @return
     * @throws FileStoreException
     */
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] id);

    /**
     * Requests time series data for one or more time series. This starts and
     * rollsback a local transaction if none has been started. All TimeSeries
     * returned by this method will have the same length.
     * 
     * @param id A unique id. This is generated elsewhere from timeseries
     * specific parameters.
     * @param startCadence A non-negative integer. Inclusive.
     * @param endCadence A non-negative integer. Inclusive. So [start, end]
     * where start = 10 and end = 10 will result in an series with a single
     * value returned.
     * @param existsError enables FileStoreIdNotFoundException else exists()
     * will return false on all the time series returned by this method.
     * @return IntTimeSeries data ordered by increasing cadence and return[i]
     * will have id[i]
     * @throws FileStoreIdNotFoundException If no data has been written to one
     * of the ids.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    DoubleTimeSeries[] readTimeSeriesAsDouble(FsId[] id, int startCadence,
        int endCadence, boolean existsError);
    
    /**
     * Requests time series data for one or more time series. This starts and
     * rollsback a local transaction if none has been started. TimeSeries
     * returned by this method may be of different lengths.
     * 
     * @param id A unique id. This is generated elsewhere from timeseries
     * specific parameters.
     * @return IntTimeSeries returned by this method may be of different
     * lengths, if a TimeSeries does not exist then (has never been written)
     * then the TimeSeries returned with have its exists() flag set to false.
     * return[i] has FsId id[i]
     * @throws FileStoreException
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    DoubleTimeSeries[] readAllTimeSeriesAsDouble(FsId[] id, boolean existsFlag);
    
    /**
     * Requests time series data for one or more time series. This starts and
     * rollsback a local transaction if none has been started. All TimeSeries
     * returned by this method will have the same length.
     * 
     * @param id A unique id. This is generated elsewhere from timeseries
     * specific parameters.
     * @param startCadence A non-negative integer. Inclusive.
     * @param endCadence A non-negative integer. Inclusive. So [start, end]
     * where start = 10 and end = 10 will result in an series with a single
     * value returned.
     * @param existsError enables FileStoreIdNotFoundException else exists()
     * will return false on all the time series returned by this method.
     * @return FloatTimeSeries data ordered by increasing cadence.
     * @throws FileStoreIdNotFoundException If no data has been written to one
     * of the ids.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] id, int startCadence,
        int endCadence, boolean existsError);

    /**
     * If a TimeSeries does not exist then this method WILL throw an error.
     * 
     * @param id
     * @param startCadence
     * @param endCadence
     * @return
     * @throws FileStoreException
     */
    @IgnoreServerGeneration
    @IgnoreClientGeneration
    FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] id, int startCadence,
        int endCadence);

    /**
     * Requests time series data for one or more time series. This starts and
     * rollsback a local transaction if none has been started. TimeSeries
     * returned by this method may be of different lengths.
     * 
     * @param id A unique id. This is generated elsewhere from timeseries
     * specific parameters.
     * @param existsError enables FileStoreIdNotFoundException else exists()
     * will return false on all the time series returned by this method.
     * @return FloatTimeSeries returned by this method may be of different
     * lengths, if a TimeSeries does not exist then (has never been written)
     * then the TimeSeries returned with have its exists() flag set to false.
     * return[i] has FsId id[i]
     * @throws FileStoreException
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] id, boolean existsError);

    /**
     * Like readAllTimeSeriesAsFloat(FsId[], boolean). This WILL throw an error
     * if a time series does not exist.
     * 
     * @param id
     * @return
     * @throws FileStoreException
     */
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] id);

    /**
     * as writetimeSeries() where overwrite = true.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    @NeedClientEncoding
    void writeTimeSeries(TimeSeries[] ts);

    /**
     * Sends time series to the file store for writing. A transaction must be
     * active in order for this to work.
     * 
     * @param ts The time series to write.
     * @param overwrite When true writing the time series [start, end] cadence
     * is considered authoritative so data within [start,end] is removed, new
     * gaps may be introduced this way. Writes are more efficient. With
     * overwrite = false only the valid cadences are written. Data overwriting
     * will only happen if there was previously existing data at that particular
     * cadence. This mode is slower.
     * @throws FileStoreException If a transaction is not currently active.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    @NeedServerDecoding
    @NeedClientEncoding
    void writeTimeSeries(TimeSeries[] ts, boolean overwrite);

    /**
     * Reads batches of TimeSeries.  Any subclass of TimeSeries can be read with
     * method.  If the time series for a FsId does not exist and existsError is
     * false then it will be returned as an IntTimeSeries with exists()
     * returning false.
     * 
     * @param fsIdSet  a non-null list of FsIdSets of length zero or more.
     * @param existsError enables FileStoreIdNotFoundException else exists()
     * will return false on all the time series returned by this method.
     * @return Batch[i] will have the same [start,end] cadence
     * as fsIdSet[i] and the set of TimeSeries will be the same as
     * fsIdsSet[i].  A TimeSeries in FsIdSet will be what ever time it is stored
     * as unless it does not exist in which case it will be of type IntTimeSeries.
     * @exception FileStoreException
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    @NeedClientEncoding
    @NeedServerDecoding
    List<TimeSeriesBatch> readTimeSeriesBatch(List<FsIdSet> fsIdSet, boolean existsError);
    
    /**
     * This is equivalent to calling readTimeSeriesBatch with a single set of
     * fsIds.
     * 
     * @param fsIds
     * @param startCadence
     * @param endCadence
     * @param existsError
     * @return 
     * @exception FileStoreException
     */
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    Map<FsId, TimeSeries> readTimeSeries(Collection<FsId> fsIds, int startCadence, 
        int endCadence, boolean existsError);

    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    void deleteTimeSeries(FsId[] ids);

    /// Meta data

    /**
     * Finds out which ids are available for the specified time series path.
     * Note that this does not support any transaction isolation levels and it
     * may return uncommitted FsIds.
     * 
     * @param id The name part of the specified id is ignored.
     * @return ids This may be zero length if no ids are available for the
     * specified time series.
     */
    @Deprecated
    Set<FsId> getIdsForSeries(FsId path);

    /**
     * Finds out the cadence ranges available for the specified id.
     * 
     * @param ids A unique id.
     * @param timeSeriesType From TimeSeriesConstants
     * @param freq From TimeSeriesConstants
     * @return array[id]list of integer cadence ranges which are [start,end]
     * pairs
     * @throws FileStoreException if the id does not exist.
     */
    @ImplicitParameter(name = "xid", type = PersistableXid.class)
    List<Interval>[] getCadenceIntervalsForId(FsId[] ids);
    
    
}
