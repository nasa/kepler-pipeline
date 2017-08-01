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

package gov.nasa.kepler.fs.server;

import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.server.xfiles.RecoveryException;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.util.List;
import java.util.Set;

import javax.transaction.xa.Xid;

/**
 * 
 * @author Sean McCauliff
 *
 */
public interface BackendInterface {

    
    List<Interval>[] getCadenceIntervalsForId(FsId[] ids, Xid xid)
        throws FileStoreException, IOException, InterruptedException;

    /**
     * This method is not even Transaction Isolation level READ_COMITTED
     * @param series
     * @return
     * @throws FileStoreException
     * @throws IOException
     * @throws InterruptedException
     */
     Set<FsId> getIdsForSeries(FsId series)
        throws FileStoreException, IOException, InterruptedException;

     /**
      * 
      * @param expectedDataType  When specified TimeSeries will be of this type.
      *   When null return either Float or Int TimeSeries.
      * @param useDefaults Use the default start and end cadences provided.
      * @param ids
      * @param defaultStartCadence  Fit (not in the mathematical way) 
      *     the time series to this start.  This value may not exceed Integer.MAX_VALUE.
      * @param defaultEndCadence Fit (not in the mathematical way)
      *    the time series to this end.  This value may not exceed Integer.MAX_VALUE.
      * @param xid An active transaction.
      * @param readCallback How results are returned.
      * @param startOrder The absolute order number ot use when returning TimeSeries
      * results.  FsId[0] will be assigned startOrder.
      * @param permits The level of parallelism allowed.
      * @throws FileStoreException
      * @throws IOException
      * @throws InterruptedException
      */
     void readTimeSeries(  TimeSeriesDataType expectedDataType,
                           boolean useDefaults,
                           List<FsId> ids,
                           long defaultStartCadence, 
                           long defaultEndCadence,
                           Xid xid, boolean existsError,
                           CompleteReadCallback<TimeSeriesCarrier> readCallback,
                           int startOrder,
                           AcquiredPermits permits)
        throws FileStoreException, IOException, InterruptedException;



     boolean fileExists(FsId id, Xid xid) 
        throws FileStoreException, InterruptedException, IOException;

     /**
      *
      * @param ts
      * @param overwrite When true [start, end] cadence is removed.
      * @param xid
      * @throws FileStoreException
      * @throws IOException
      * @throws InterruptedException
      */
     void writeTimeSeries(List<TimeSeriesCarrier> ts, boolean overwrite, Xid xid, 
         AcquiredPermits permits)
        throws FileStoreException, IOException, InterruptedException;

     void cleanFileStore() throws FileStoreException;

    /**
     * @return null if this file does not exist.
     */
     ReadableBlob readBlob(FsId id, Xid xid)
        throws FileStoreException, IOException, InterruptedException;

     WritableBlob writeBlob(FsId id, Xid xid, long origin)
        throws FileStoreException, IOException, InterruptedException;
    
     FileTransactionManagerInterface fileTransactionManager() 
         throws RecoveryException, PipelineException;

     /**
      * 
      * @param series
      * @param overwrite
      * @param xid
      * @param permits The allowed level of parallelism.
      * @throws FileStoreException
      * @throws IOException
      * @throws InterruptedException
      */
     void writeMjdTimeSeries(List<FloatMjdTimeSeries> series, 
         boolean overwrite, Xid xid, AcquiredPermits permits)
         throws  FileStoreException, IOException, InterruptedException;
     
     /**
      * Reads mjd time series out of order.
      * @param readCallback Where to send the results of a successful read.
      * @param seriesId
      * @param readMjd
      * @param writeMjd
      * @param xid
      * @param replaceStartEnd replace the start, end time of the time series with the start, 
      * end time of the beginning of the time stamp series.
      * @param order where to start the ordering of the time series that are returned.
      * @param permits The number of allowed concurrent read opertions.
      * @throws FileStoreException
      * @throws IOException
      * @throws InterruptedException
      */
     void readMjdTimeSeries(List<FsId> seriesId, double readMjd, 
                             double writeMjd, Xid xid, boolean replaceStartEnd,
                             CompleteReadCallback<FloatMjdTimeSeries> readCallback,
                             int order, AcquiredPermits permits)
         throws  FileStoreException, IOException, InterruptedException;
     
     /**
      * A non-transactional method to list CosmicRaySeries ids.
      * 
      * @param rootId  Only the part part of the id is used.
      * @return A set of CosmicRaySeries fsids with that all have the same
      * path as rootId.  An empty set is returned if none are found.
      */
     Set<FsId> listCosmicRaySeries(FsId rootId) throws FileStoreException, IOException;
     
     /**
      * Stops all transactions.  Waits some time for all threads to terminate.
      *
      */
    void shutdown();
    
    
    void deleteTimeSeries(Xid Xid, FsId id) throws FileStoreException, IOException, InterruptedException;

    void deleteBlob(Xid xid, FsId id) throws FileStoreException, IOException, InterruptedException;

    void deleteMjdTimeSeries(Xid xid, FsId id) throws FileStoreException, IOException, InterruptedException;
    


}