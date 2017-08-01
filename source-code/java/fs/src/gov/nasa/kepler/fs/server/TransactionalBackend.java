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

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.server.scheduler.*;
import gov.nasa.kepler.fs.server.xfiles.FileMetadata;
import gov.nasa.kepler.fs.server.xfiles.FileTransactionManager;
import gov.nasa.kepler.fs.server.xfiles.TransactionalMjdTimeSeriesFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalStreamFile;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * CRUD for file store objects.
 * 
 * @author Sean McCauliff
 * @author Jason Brittain jbrittain@mail.arc.nasa.gov
 */

public final class TransactionalBackend implements BackendInterface {

    /**
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(TransactionalBackend.class);

    public static class Factory {
        private TransactionalBackend inst;
        
        public synchronized TransactionalBackend instance(Configuration config, FileTransactionManager.Factory ftmFactory)
                throws FileStoreException {

                    if (inst != null) {
                        return inst;
                    }
                    inst = new TransactionalBackend(config, ftmFactory);
                    return inst;
                }
    }

    private final Configuration config;

    private final boolean allowCleanup;
    private final int fsIdLockTimeOutSeconds;
    private final FileTransactionManager.Factory ftmFactory;
    

    /**
     * Constructs a FileStore with the specified configuration settings.
     * 
     * @param config the configuration settings for this FileStore.
     */
    TransactionalBackend(Configuration config, FileTransactionManager.Factory ftmFactory) {
        this.ftmFactory = ftmFactory;
        this.config = config;
        allowCleanup = config.getBoolean(FS_ALLOW_CLEANUP, FS_ALLOW_CLEANUP_DEFAULT);
        fsIdLockTimeOutSeconds = config.getInt(FS_SERVER_FSID_LOCK_TIMEOUT_SEC,
            FS_SERVER_FSID_LOCK_TIMEOUT_SEC_DEFAULT);
    }

    /**
     * @throws IOException 
     * @see gov.nasa.kepler.fs.server.BackendInterface#getCadenceIntervalsForId(gov.nasa.kepler.fs.api.FsId[])
     */
    @SuppressWarnings("unchecked")
    public List<Interval>[] getCadenceIntervalsForId(FsId[] ids, Xid xid)
        throws FileStoreException, InterruptedException, IOException {

        if (ids.length == 0) {
            return new List[0];
        }

        List<Interval>[] rv = new List[ids.length];

        for (int i = 0; i < ids.length; i++) {
            FsId id = ids[i];

            TransactionalRandomAccessFile xrf = null;
            try {
                xrf = fileTransactionManager().openRandomAccessFile(
                    xid, id, false);
                if (xrf != null) {
                    FileMetadata meta = xrf.metadata(xid);
                    meta = meta.internalToUser(0, Integer.MAX_VALUE);
                    rv[i] = (List<Interval>) (Object) meta.valid;
                } else {
                    rv[i] = Collections.EMPTY_LIST;
                }
            } catch (IOException ioe) {
                String msg = "Failed to access metadata file for id \"" + id
                    + "\".";
                log.error(msg, ioe);
                throw new FileStoreException(msg, ioe);
            } finally {
                if (xrf != null) {
                    fileTransactionManager().doneWithFile(xid, xrf);
                }
            }
        }

        return rv;

    }

    /**
     * This operation is not even isolation level read_committed.
     * 
     * @throws InterruptedException
     * @see gov.nasa.kepler.fs.server.BackendInterface#getIdsForSeries(gov.nasa.kepler.fs.api.FsId)
     */
    public Set<FsId> getIdsForSeries(FsId series) throws FileStoreException,
        InterruptedException {

        return fileTransactionManager().findFsIds(series);

    }
    

    @Override
    public void readTimeSeries(TimeSeriesDataType dataType, boolean useDefaults,
        List<FsId> ids, long defaultStartCadence, long defaultEndCadence, Xid xid,
        boolean existsError, CompleteReadCallback<TimeSeriesCarrier> readCallback, 
        int startOrder, AcquiredPermits permits) 
        throws FileStoreException, IOException,  InterruptedException {

        Scheduler readScheduler = scheduler(xid, false);
        List<FsIdOrder> orderList = DefaultFsIdOrder.makeOrder(ids, startOrder);
        
        List<List<FsIdOrder>> idChunks = readScheduler.accessOrder(orderList, startOrder);
        if (log.isInfoEnabled()) {
            log.info("Number of scheduled read chunks is " + idChunks.size() + ".");
        }
        
        List<Callable<TimeSeriesCarrier>> readTasks = new ArrayList<Callable<TimeSeriesCarrier>>();
        AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        for (List<FsIdOrder> chunk : idChunks) {
            readTasks.add(new ReadTimeSeriesCallable(readCallback, chunk, defaultStartCadence, defaultEndCadence, 
                xid, fileTransactionManager(), error, useDefaults, existsError,  dataType));
        }
        List<Future<TimeSeriesCarrier>> futures = fileTransactionManager().executorService(xid, permits).invokeAll(readTasks);
        for (Future<TimeSeriesCarrier> future : futures) {
            try {
                future.get();
            } catch (Throwable t) {
                continue;  //clean up remaining tasks.
            }
        }
        if (error.get() != null) {
            disentangleThrowable(error.get(), "While reading time series.");
        }
 
    }
    


    /**
     * @throws InterruptedException
     * @throws IOException
     * @see gov.nasa.kepler.fs.server.BackendInterface#fileExists(gov.nasa.kepler.fs.api.FsId)
     */
    public boolean fileExists(FsId id, Xid xid) throws FileStoreException,
        InterruptedException, IOException {
        return fileTransactionManager().streamFileExists(xid, id);
    }

    /**
     * @see gov.nasa.kepler.fs.server.BackendInterface#writeTimeSeries(gov.nasa.kepler.fs.api.TimeSeries[])
     */
    public void writeTimeSeries(List<TimeSeriesCarrier> ts, boolean overwrite, Xid xid,
            AcquiredPermits permits)
        throws FileStoreException, IOException, InterruptedException {
        if (xid == null) {
            throw new NullPointerException("Xid may not be null.");
        }

        if (ts.size() == 0) {
            return;
        }
        if (log.isDebugEnabled()) {
            StringBuilder sb = new StringBuilder("Writing data for series: ");
            for (TimeSeriesCarrier t : ts) {
                sb.append(t.id());
                sb.append(',');
            }
            if (sb.length() > 0) {
                sb.setLength(sb.length() - 1);
            }
            log.debug(sb);
        }

        Collection<WriteTimeSeriesTask> taskList = new ArrayList<WriteTimeSeriesTask>(ts.size());
        for (TimeSeriesCarrier t : ts) {
            taskList.add(new WriteTimeSeriesTask(t, xid, fileTransactionManager(),
                overwrite));
        }
        
        exec(xid, taskList, permits);
    }

    private <T> void exec(Xid xid, Collection<? extends Callable<T>> tasks, 
            AcquiredPermits permits) 
        throws IOException, FileStoreException, InterruptedException {
        
        List<Future<T>> results = 
            fileTransactionManager().executorService(xid, permits).invokeAll(tasks);
        try {
            for (Future<T> f : results) {
                f.get(); // This will throw an exception on unsuccessful
                            // completion.
            }
        } catch (ExecutionException xex) {
            disentangleThrowable(xex.getCause() , "While writing time series.");
        }
    }

    private static void disentangleThrowable(Throwable cause , String genericErrorMsg )
        throws IOException, InterruptedException, OutOfMemoryError {
       // Throwable cause = xex.getCause();
        if (cause instanceof IOException) {
            throw (IOException) cause;
        } else if (cause instanceof FileStoreException) {
            throw (FileStoreException) cause;
        } else if (cause instanceof InterruptedException) {
            throw (InterruptedException) cause;
        } else if (cause instanceof OutOfMemoryError) {
            throw (OutOfMemoryError) cause;
        } else {
            throw new FileStoreException(genericErrorMsg, cause);
        }
    }
    private static TimeSeriesCarrier emptySeries(FsId id, boolean useDefaults, long start,
        long end, TimeSeriesDataType dataType) {

        return emptySeries(id, useDefaults, start, end, dataType, false);
    }

    /**
     * Creates an empty TimeSeries entry
     * 
     */
    private static TimeSeriesCarrier emptySeries(FsId id, boolean useDefaults, 
        long start, long end, TimeSeriesDataType dataType, boolean exists) {

        int size = (int) (end - start + 1);
        List<TaggedInterval> origin = Collections.emptyList();
        List<SimpleInterval> valid = Collections.emptyList();
        start = useDefaults ? start : TimeSeries.NOT_EXIST_CADENCE;
        end = useDefaults ? end : TimeSeries.NOT_EXIST_CADENCE;
        if (dataType == null) {
            dataType = TimeSeriesDataType.IntType;
        }
        byte[] data = useDefaults ? new byte[size] : ArrayUtils.EMPTY_BYTE_ARRAY;
        return new TimeSeriesCarrier(id, data, (int)start, (int)end, valid, origin, 
            exists, dataType);
    }

    /**
     * @see gov.nasa.kepler.fs.server.BackendInterface#cleanFileStore()
     */
    public void cleanFileStore() throws FileStoreException {
        if (!allowCleanup) {
            throw new FileStoreException(
                "Clean up of file store is not allowed.");
        }

        log.info("Cleaning file store.");
        try {
            fileTransactionManager().cleanUp();
            ftmFactory.clear();
        } catch (IOException ioe) {
            throw new FileStoreException("While cleaning data.", ioe);
        }
    }

    /**
     * Writes the specified time series data. Callable is part of the Executor
     * framework that is part of the java.util.concurrent package.
     * 
     * @author Sean McCauliff
     * 
     */
    private final class WriteTimeSeriesTask implements Callable<Object> {
        private final TimeSeriesCarrier t;
        private final Xid xid;
        private final FileTransactionManagerInterface ftm;
        private final boolean overwrite;

        public WriteTimeSeriesTask(TimeSeriesCarrier t, Xid xid,
            FileTransactionManagerInterface ftm, boolean overwrite) {
            this.t = t;
            this.xid = xid;
            this.ftm = ftm;
            this.overwrite = overwrite;
        }

        public Object call() throws Exception {
            final TimeSeriesDataType dataType = t.carriedType();
            TransactionalRandomAccessFile xf = 
                ftm.openRandomAccessFile(xid, t.id(), true);

            xf.acquireReadLock(xid, fsIdLockTimeOutSeconds);
            try {
                if (overwrite) {
                    xf.deleteInterval(t.startCadence(), t.endCadence(), xid);
                }
    
                Iterable<Pair<List<SimpleInterval>, List<TaggedInterval>>> it = null;
                if (overwrite) {
                    it = new TimeSeriesIntervalIterator(t.validCadences(), t.originators());
                } else {
                    FileMetadata meta = xf.metadata(xid);
                    it = new TimeSeriesMergeIntervalIterator(t.validCadences(), t.originators(), meta.valid);
                }
                
                for (Pair<List<SimpleInterval>, List<TaggedInterval>> writeAddresses : it) {
                        write(xf, writeAddresses.left, writeAddresses.right);
                }
    
                xf.setDataType(xid, dataType.typeByte());
            } finally {
                xf.releaseReadLock(xid);
            }
            return null;
        }

        private void write(TransactionalRandomAccessFile xf,
            List<SimpleInterval> valid, List<TaggedInterval> originators)
            throws FileStoreTransactionTimeOut, IOException,
            InterruptedException {

            int size = (int) (valid.get(valid.size() - 1)
                .end() - valid.get(0)
                .start()) + 1;
            if (size < 0) {
                throw new AssertionError(
                    "Attempt to write negative array size.");
            }
            int offset = (int)(valid.get(0).start() - t.startCadence());
            xf.write(t.data(), offset, size, valid.get(0).start(), xid, valid, originators);
        }


    }

    
    private static final class WriteMjdTimeSeriesTask implements Callable<Object> {
        private final FloatMjdTimeSeries t;
        private final Xid xid;
        private final FileTransactionManagerInterface ftm;
        private final boolean overwrite;

        public WriteMjdTimeSeriesTask(FloatMjdTimeSeries t, Xid xid,
            FileTransactionManagerInterface ftm, boolean overwrite) {
            this.t = t;
            this.xid = xid;
            this.ftm = ftm;
            this.overwrite = overwrite;
        }

        public Object call() throws Exception {
            TransactionalMjdTimeSeriesFile xfile = 
                ftm.openMjdFile(xid, t.id(), true);

            xfile.write(t, overwrite, xid);

            return null;
        }
        
    }
    
    public void writeMjdTimeSeries(List<FloatMjdTimeSeries> series, 
        boolean overwrite, Xid xid, AcquiredPermits permits) 
        throws FileStoreException, IOException, InterruptedException {
        
        Collection<WriteMjdTimeSeriesTask> tasks = 
            new ArrayList<WriteMjdTimeSeriesTask>(series.size());
        for (FloatMjdTimeSeries mts : series) {
            tasks.add(new WriteMjdTimeSeriesTask(mts, xid, fileTransactionManager(), overwrite));
        }
        
        exec(xid, tasks, permits);
    }
    
    
    /**
     * @see gov.nasa.kepler.fs.server.BackendInterface#readBlobAsStream(gov.nasa.kepler.fs.api.FsId)
     */
    public ReadableBlob readBlob(FsId id, final Xid xid)
        throws FileStoreException, IOException, InterruptedException {

        if (!fileTransactionManager().streamFileExists(xid, id)) {
            throw new FileStoreIdNotFoundException(id);
        }

        final TransactionalStreamFile streamFile = fileTransactionManager().openStreamFile(
            xid, id, false);

        final ReadableBlob blob = streamFile.readBlob(xid);
        ReadableBlob cleanUpBlob = new ReadableBlob(blob.origin,
            blob.fileStart, blob.fileChannel, blob.length) {

            @Override
            public void close() throws IOException, FileStoreException,
                InterruptedException {
                blob.close();
                fileTransactionManager().doneWithFile(xid, streamFile);
            }

        };

        return cleanUpBlob;

    }

    /**
     * @see gov.nasa.kepler.fs.server.BackendInterface#writeBlob(gov.nasa.kepler.fs.api.FsId,
     * int)
     */
    public WritableBlob writeBlob(FsId id, Xid xid, long origin)
        throws FileStoreException, IOException, InterruptedException {

        if (log.isDebugEnabled()) {
            StringBuilder sb = new StringBuilder("Writing blob for id \" ");
            sb.append(id);
            sb.append("\" with originator ");
            sb.append(origin);
            sb.append('.');
            log.info(sb);
        }

        TransactionalStreamFile streamFile = fileTransactionManager().openStreamFile(
            xid, id, true);
        WritableBlob blob = streamFile.writeBlob(xid, origin);
        return blob;
    }

    public FileTransactionManagerInterface fileTransactionManager()
        throws FileStoreException {

        try {
            return ftmFactory.instance(config);
        } catch (FileStoreException fse) {
            throw fse;
        } catch (Exception e) {
            throw new FileStoreException("Wrapped initialization exception.", e);
        }
    }


    // TODO: Implement me.
    public void shutdown() {
        // TODO Auto-generated method stub

    }

    @Override
    public void readMjdTimeSeries(List<FsId> seriesIds, double startMjd,
        double endMjd, Xid xid, boolean replaceStartEnd, 
        CompleteReadCallback<FloatMjdTimeSeries> readCallback, int order,
        AcquiredPermits permits)
        throws FileStoreException, IOException,  InterruptedException {

        Scheduler readScheduler = scheduler(xid, true);
        List<FsIdOrder> orderList = DefaultFsIdOrder.makeOrder(seriesIds, order);
        
        List<List<FsIdOrder>> idChunks = readScheduler.accessOrder(orderList, order);
        
        List<Callable<FloatMjdTimeSeries>> readTasks = new ArrayList<Callable<FloatMjdTimeSeries>>();
        AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        for (List<FsIdOrder> chunk : idChunks) {
            readTasks.add(new ReadMjdTimeSeriesCallable(readCallback, chunk, 
                startMjd, endMjd, xid, fileTransactionManager(), replaceStartEnd, error));
        }
        List<Future<FloatMjdTimeSeries>> futures = 
            fileTransactionManager().executorService(xid, permits).invokeAll(readTasks);
        for (Future<FloatMjdTimeSeries> future : futures) {
            try {
                future.get();
            } catch (Throwable t) {
                continue;
            }
        }
        if (error.get() != null) {
            disentangleThrowable(error.get(), "While reading mjd time series.");
        }
    }

    private Scheduler scheduler(Xid xid, boolean mjdTimeSeries) {
        FsIdLocationFactory idLocationFactory = fileTransactionManager().locationFactory(xid, mjdTimeSeries);
        Scheduler readScheduler = new Scheduler(idLocationFactory);
        return readScheduler;
    }

    public Set<FsId> listCosmicRaySeries(FsId rootId)
        throws FileStoreException, IOException {

        return fileTransactionManager().listMjdTimeSeries(rootId);

    }

    @Override
    public void deleteBlob(Xid xid, FsId id) throws FileStoreException,
        IOException, InterruptedException {
        if (!fileTransactionManager().streamFileExists(xid, id)) {
            return;
        }

        TransactionalStreamFile streamFile = fileTransactionManager().openStreamFile(
            xid, id, false);

        streamFile.delete(xid);
    }

    @Override
    public void deleteMjdTimeSeries(Xid xid, FsId id)
        throws FileStoreException, IOException, InterruptedException {
        TransactionalMjdTimeSeriesFile xfile = fileTransactionManager().openMjdFile(
            xid, id, false);

        if (xfile == null) {
            return;
        }

        xfile.delete(xid);
    }

    @Override
    public void deleteTimeSeries(Xid xid, FsId id) throws FileStoreException,
        IOException, InterruptedException {
        TransactionalRandomAccessFile xfile = fileTransactionManager().openRandomAccessFile(
            xid, id, false);

        if (xfile == null) {
            return;
        }

        xfile.delete(xid);
    }

    private class ReadTimeSeriesCallable implements Callable<TimeSeriesCarrier> {
        private final CompleteReadCallback<TimeSeriesCarrier> readCallback;
        private final List<FsIdOrder> ids;
        private final long defaultStartCadence;
        private final long defaultEndCadence;
        private final Xid xid;
        private final FileTransactionManagerInterface fileTransactionManager;
        private final AtomicReference<Throwable> error;
        private final boolean useDefaults;
        private final boolean existsError;
        private final TimeSeriesDataType type;
        
        /**
         * 
         * @param readCallback
         * @param ids
         * @param defaultStartCadence  this is the cadence to use unless overridden
         * by a cadence from the file metadata.  Use of this is controlled by
         * the useDefaults parameter.
         * @param defaultEndCadence this is the cadence to use unless overridden
         * by a cadence from the file metadata.  Use of this is controlled by
         * the useDefaults parameter.
         * @param xid
         * @param fileTransactionManager
         * @param error
         * @param useDefaults
         * @param existsError
         * @param type  If type == null then this will not check and just return
         * either Int or Float TimeSeries.
         */
        public ReadTimeSeriesCallable(
            CompleteReadCallback<TimeSeriesCarrier> readCallback, List<FsIdOrder> ids,
            long defaultStartCadence, long defaultEndCadence, Xid xid,
            FileTransactionManagerInterface fileTransactionManager,
            AtomicReference<Throwable> error, boolean useDefaults, boolean existsError, TimeSeriesDataType type) {
            super();
            this.readCallback = readCallback;
            this.ids = ids;
            this.defaultStartCadence = defaultStartCadence;
            this.defaultEndCadence = defaultEndCadence;
            this.xid = xid;
            this.fileTransactionManager = fileTransactionManager;
            this.error = error;
            this.useDefaults = useDefaults;
            this.existsError = existsError;
            this.type = type;
        }
        
        @Override
        public TimeSeriesCarrier call() throws Exception {
            if (error.get() != null) {
                return null;
            }
            FsIdOrder currentFsIdOrder = null;
            try {
                for (FsIdOrder idLocation : ids) {
                    currentFsIdOrder = idLocation;
                    readTimeSeries(idLocation.id());
                }
                return null;
            } catch (Throwable t) {
                if (t instanceof OutOfMemoryError) {
                    throw new IllegalStateException(t);
                }
                if (currentFsIdOrder != null && !(t instanceof FileStoreException)) {
                    IOException ioe = new IOException("While processing \"" +
                        currentFsIdOrder + "\".", t);
                    error.compareAndSet(null, ioe);
                    throw ioe;
                } else {
                    error.compareAndSet(null, t);
                    if (t instanceof Exception) {
                        throw (Exception) t;
                    }
                    throw new IllegalStateException(t);
                }
            }
        }
        
        private void readTimeSeries(FsId id) throws Exception {
            if (!fileTransactionManager.randomAccessExists(xid, id)) {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(id);
                }
                TimeSeriesDataType defaultDataType = 
                    (type == null) ? TimeSeriesDataType.FloatType : type;
                TimeSeriesCarrier timeSeries = 
                    emptySeries(id, useDefaults , 
                                defaultDataType.startCadenceToByteStartCadence(defaultStartCadence),
                                defaultDataType.endCadenceToByteEndCadence(defaultEndCadence),
                                defaultDataType);
                readCallback.sendBackToClient(timeSeries);
                return;
            }

            TransactionalRandomAccessFile xf = fileTransactionManager.openRandomAccessFile(
                xid, id, false);
            xf.acquireReadLock(xid, fsIdLockTimeOutSeconds);

            try {

                FileMetadata fileMeta = xf.metadata(xid);
                long startCadenceInBytes;
                long endCadenceInBytes;
                final TimeSeriesDataType dataTypeFromFile = 
                    TimeSeriesDataType.valueOf(fileMeta.dataType);
                if (useDefaults) {
                    startCadenceInBytes = dataTypeFromFile.startCadenceToByteStartCadence(defaultStartCadence);
                    endCadenceInBytes = dataTypeFromFile.endCadenceToByteEndCadence(defaultEndCadence);
                    fileMeta = xf.fileMetaData(xid, startCadenceInBytes, endCadenceInBytes);
                } else {
                    if (fileMeta.valid.isEmpty()) {
                        if (this.type != null && type.typeByte() != fileMeta.dataType) {
                            throw new MixedTypeException("Wrong type for id \"" + id + "\".", id);
                        }
                        TimeSeriesCarrier timeSeries = 
                            emptySeries(id, true, 0, 0, type, true);
                        readCallback.sendBackToClient(timeSeries);
                        return;
                    }
                    startCadenceInBytes = fileMeta.valid.get(0).start();
                        
                    endCadenceInBytes = fileMeta.valid.get(fileMeta.valid.size() - 1).end();
                        
                }

                if (type != null && fileMeta.dataType != type.typeByte()) {
                    throw new MixedTypeException("Wrong type for id \"" + id
                        + "\".", id);
                }

                final long cadenceSizeInBytes = endCadenceInBytes - startCadenceInBytes + 1;
                //We can only read 2GiBytes a time
                if (cadenceSizeInBytes > Integer.MAX_VALUE) {
                    throw new FileStoreException("Reads must be limited to " + 
                            (Integer.MAX_VALUE >> dataTypeFromFile.bitShift())
                            + " cadences.");
                }

                TimeSeriesIntervalIterator intervalIt = new TimeSeriesIntervalIterator(
                    fileMeta.valid, fileMeta.origin);

                if (!intervalIt.hasNext()) {
                    TimeSeriesCarrier timeSeries = emptySeries(id, true, startCadenceInBytes, endCadenceInBytes,
                        dataTypeFromFile, true);
                    readCallback.sendBackToClient(timeSeries);
                    return;
                }

                byte[] buf = new byte[(int) cadenceSizeInBytes];

                for (Pair<List<SimpleInterval>, List<TaggedInterval>> chunk : intervalIt) {
                    SimpleInterval first = chunk.left.get(0);
                    SimpleInterval last = chunk.left.get(chunk.left.size() - 1);

                    int bufStart = (int) (first.start() - startCadenceInBytes);
                    int intervalSize = (int) (last.end() - first.start() + 1);
                    xf.read(buf, bufStart, intervalSize, first.start(), xid);
                }

                TimeSeriesCarrier timeSeriesCarrier = 
                    new TimeSeriesCarrier(id, buf, startCadenceInBytes,
                            endCadenceInBytes, fileMeta.valid, fileMeta.origin, 
                        true, dataTypeFromFile);
                readCallback.sendBackToClient(timeSeriesCarrier);
            } finally {
                xf.releaseReadLock(xid);
                fileTransactionManager.doneWithFile(xid, xf);
            }

        }
    }
    
    private static class ReadMjdTimeSeriesCallable implements Callable<FloatMjdTimeSeries> {

        private final CompleteReadCallback<FloatMjdTimeSeries> readCallback;
        private final List<FsIdOrder> ids;
        private final double startMjd;
        private final double endMjd;
        private final Xid xid;
        private final FileTransactionManagerInterface fileTransactionManager;
        private final boolean replaceStartEnd;
        private final AtomicReference<Throwable> error;
        
        public ReadMjdTimeSeriesCallable(
           CompleteReadCallback<FloatMjdTimeSeries> readCallback, List<FsIdOrder> ids,
            double startMjd, double endMjd,  Xid xid,
            FileTransactionManagerInterface fileTransactionManager,
            boolean replaceStartEnd, AtomicReference<Throwable> error) {
            
            this.readCallback = readCallback;
            this.ids = ids;
            this.startMjd = startMjd;
            this.endMjd = endMjd;
            this.fileTransactionManager = fileTransactionManager;
            this.xid = xid;
            this.replaceStartEnd = replaceStartEnd;
            this.error = error;
        }

        @Override
        public FloatMjdTimeSeries call() throws Exception {

            try {
                for (FsIdOrder idLocation : ids) {
                    if (error.get() != null) {
                        return null; // ok
                    }
                    
                    readMjdTimeSeries(idLocation.id(), idLocation.originalOrder());
                }
                return null; //ok
            } catch (Throwable t) {
                error.compareAndSet(null, t);
                if (t instanceof Exception) {
                    throw (Exception) t;
                }
                throw new IllegalStateException(t);
            }
        }   
        
        private void readMjdTimeSeries(FsId id, int order)  throws Exception {
            
            TransactionalMjdTimeSeriesFile xfile = 
                fileTransactionManager.openMjdFile(xid, id, false);

            FloatMjdTimeSeries returnSeries = null;
            if (xfile == null) {
                returnSeries = FloatMjdTimeSeries.emptySeries(id, startMjd, endMjd, false);
            } else {
                returnSeries = xfile.read(startMjd, endMjd, xid);
                fileTransactionManager.doneWithFile(xid, xfile);
            }
            
            double[] mjd = returnSeries.mjd();
            if (replaceStartEnd && mjd.length > 0) {
                       returnSeries = 
                        new FloatMjdTimeSeries(
                        returnSeries.id(), mjd[0], mjd[mjd.length - 1], mjd,
                        returnSeries.values(), returnSeries.originators(), returnSeries.exists());               
            }
            
            readCallback.sendBackToClient(returnSeries);
        }
    }
    
}
