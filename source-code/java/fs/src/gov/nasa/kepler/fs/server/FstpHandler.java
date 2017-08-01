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
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;
import static gov.nasa.kepler.fs.FileStoreConstants.*;
import static gov.nasa.kepler.fs.client.util.FileStoreMethods.*;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.DiskNodeStats;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringInfo;
import gov.nasa.kepler.fs.transport.TransportServer;
import gov.nasa.spiffy.common.collect.ListChunkIterator;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.*;
import java.net.InetAddress;
import java.security.NoSuchAlgorithmException;
import java.util.*;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.XAResource;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Every method from the client is decoded and processed by this task.
 * 
 * @author Sean McCauliff
 * 
 */
class FstpHandler extends AbstractFstpServer {

    /**
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(FstpHandler.class);

    private static Date startTime = new Date();

    /**
     * Batch up requests into idBatch.length size. In this way we limit the
     * amount of buffer this needs for sending back responses.
     */
    private static final int BATCH_SIZE = 128;

    /**
     * The size of the FsId reorder window.
     */
    private static final int READ_WINDOW_SIZE = 8* 1024;

    private final BackendInterface fileStore;

    private final ServerIdGenerator serverId;

    private static final AtomicBoolean shutdownInProgress = new AtomicBoolean(false);

    private final ShutdownListener shutdownListener;
    
    private final ShutdownExecutor shutdownExecutor;

    /**
     * This is used to throttle the number of clients reading or writing. This
     * does not protect any data structures.
     */
    private final ThrottleInterface throttle;

    /**
     * The client this handler serves.
     */
    private final InetAddress clientAddr;

    /**
     * When true client has asked to close this connection.
     */
    private boolean closed = false;

    /**
     * 
     * @param shutdownListener
     * @throws PipelineException
     * @throws NoSuchAlgorithmException
     * @throws ClassNotFoundException
     */
    FstpHandler(ShutdownListener shutdownListener, ShutdownExecutor shutdownExecutor,
        ThrottleInterface throttle,
        ServerIdGenerator serverId, InetAddress clientAddr,
        Configuration config, BackendInterface backend) {

        this.shutdownExecutor = shutdownExecutor;
        this.shutdownListener = shutdownListener;
        fileStore = backend;
        this.serverId = serverId;
        this.throttle = throttle;
        this.clientAddr = clientAddr;

    }

    InetAddress clientAddr() {
        return clientAddr;
    }


    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#decodeReadBlob(gov.nasa.kepler.fs.transport.TransportServer)
     */
    @Override
    protected void decodeReadBlob1(TransportServer transportServer)
    throws Exception {

        checkShutDown();

        DataInputStream din = new DataInputStream(transportServer.inputStream());
        BinaryPersistableInputStream pin = new BinaryPersistableInputStream(din);
        PersistableXid xid = new PersistableXid();
        pin.load(xid);
        FsId id = new FsId();
        pin.load(id);

        checkXid(xid);

        if (!fileStore.fileExists(id, xid)) {
            throw new FileStoreIdNotFoundException(id);
        }

        OutputStream out = transportServer.outputStream();
        DataOutputStream dout = new DataOutputStream(out);

        ReadableBlob blob = null;
        IntervalMetricKey metricKey = null;
        throttle.acquireReadPermit();
        try {
            metricKey = IntervalMetric.start();
            blob = fileStore.readBlob(id, xid);
            log.debug("Reading blob \"" + id + "\", originator" + blob.origin
                + " and length " + blob.length + " .");
            dout.writeLong(blob.origin);
            dout.writeLong(blob.length);
            dout.flush();

            transportServer.sendFile(blob.fileChannel, blob.fileStart,
                blob.length);

        } catch (IOException x) {
            log.error("Failed to read blob " + id, x);
        } finally {
            throttle.releaseReadPermit();
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.read-blob", metricKey);
            }
            if (blob != null) {
                blob.close();
            }
        }

    }

    /**
     * This is not implemented. decodeReadBlob() handles this.
     * 
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#decodeReadBlobAsStream(gov.nasa.kepler.fs.transport.TransportServer)
     */
    @Override
    protected void decodeReadBlobAsStream(TransportServer transportServer)
    throws Exception {

        // This is not implemented. decodeBlob is used instead.

    }


    @Override
    protected void decodeWriteBlob1(TransportServer transportServer)
    throws Exception {

        checkShutDown();

        InputStream inStr = transportServer.inputStream();
        DataInputStream din = new DataInputStream(inStr);
        BinaryPersistableInputStream pin = new BinaryPersistableInputStream(din);

        PersistableXid xid = new PersistableXid();
        pin.load(xid);

        FsId id = new FsId();
        pin.load(id);

        long originator = din.readLong();

        checkXid(xid);

        WritableBlob writeChan = null;
        IntervalMetricKey metricKey = null;
        throttle.acquireWritePermit();
        try {
            metricKey = IntervalMetric.start();
            writeChan = fileStore.writeBlob(id, xid, originator);

            long fileStart = writeChan.fileStart;
            while (true) {
                long expectBytes = din.readLong();
                if (expectBytes == NO_MORE_BLOB_TO_SEND) {
                    break;
                }
                transportServer.receiveFile(writeChan.fileChannel, fileStart,
                    expectBytes);
                fileStart += expectBytes;
            }

            // SendOK.
            transportServer.outputStream().write(0);
            transportServer.outputStream().flush();
        } finally {
            throttle.releaseWritePermit();
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.write-blob", metricKey);
            }
            if (writeChan != null) {
                writeChan.close();
            }
        }

    }

    @Override
    protected void decodeWriteBlob2(TransportServer transportServer)
    throws Exception {

        decodeWriteBlob1(transportServer);

    }

    @Override
    protected void decodeWriteTimeSeries2(TransportServer transportServer)
    throws Exception {

        checkShutDown();

        BufferedInputStream bin = new BufferedInputStream(
            transportServer.inputStream(), 128 * 1024);
        final DataInputStream dis = new DataInputStream(bin);

        BinaryPersistableInputStream bpis = new BinaryPersistableInputStream(dis);
        PersistableXid xid = new PersistableXid();
        bpis.load(xid);

        boolean overwrite = dis.readBoolean();
        final int nSeries = dis.readInt();

        checkXid(xid);

        Iterator<TimeSeriesCarrier> inputIt = new Iterator<TimeSeriesCarrier>() {
            int counter = 0;

            @Override
            public boolean hasNext() {
                return this.counter < nSeries;
            }
            @Override
            public TimeSeriesCarrier next() {
                try {
                    counter++;
                    return TimeSeriesCarrier.transferFrom(dis);
                } catch (IOException e) {
                    throw new IllegalStateException(e);
                }
            }
            @Override
            public void remove() {
                throw new UnsupportedOperationException("Not supported. Go away.");
            }
        };

        IntervalMetricKey metricKey = null;
        final AcquiredPermits permits = throttle.greedyAcquirePermits();
        try {
            metricKey = IntervalMetric.start();

            ListChunkIterator<TimeSeriesCarrier> chunkIt = 
                new ListChunkIterator<TimeSeriesCarrier>(inputIt, BATCH_SIZE);

            for (List<TimeSeriesCarrier> chunk : chunkIt) {
                fileStore.writeTimeSeries(chunk, overwrite, xid, permits);
            }

        } finally {
            permits.releasePermits();
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.write-ts", metricKey);
            }
        }

        transportServer.outputStream()
        .write(0);
        transportServer.outputStream()
        .flush();
    }

    @Override
    protected void executeBeginLocalFsTransaction(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        checkShutDown();

        PersistableXid xid = fileStore.fileTransactionManager()
        .beginLocalTransaction(clientAddr, throttle);
        pout.save(xid);

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeBlobExists(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeBlobExists(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId fsid, PersistableXid xid)
    throws Exception {

        checkShutDown();

        checkXid(xid);
        dout.writeBoolean(fileStore.fileExists(fsid, xid));
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeCleanFileStore(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream)
     */
    @Override
    protected void executeCleanFileStore(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        checkShutDown();

        fileStore.cleanFileStore();
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeCommit(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.client.util.PersistableXid, boolean)
     */
    @Override
    protected void executeCommit(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid, boolean onePhase)
    throws Exception {

        checkShutDown();

        IntervalMetricKey metricKey = null;
        try {
            // Note that is this if not two phase then some files may be locked
            // from the prepare. If that is the case then then commit may not
            // block on acquiring write permits since that would cause deadlock.
            metricKey = IntervalMetric.start();
            fileStore.fileTransactionManager().commitXa(xid, onePhase, throttle);
        } finally {
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + "server.commit-xa", metricKey);
            }
        }
        
        System.gc();
        System.runFinalization();

    }

    @Override
    protected void executeCommitLocalFsTransaction(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid)
    throws Exception {

        checkShutDown();

        checkXid(xid);

        FileTransactionManagerInterface ftm = fileStore.fileTransactionManager();
        //Handle read-only case.
        if (ftm.isReadOnly(xid)) {

            if (!ftm.prepareLocal(xid, throttle)) {
                ftm.commitLocal(xid, throttle);
            }
            return;
        }


        IntervalMetricKey metricKey = null;
        try {
            metricKey = IntervalMetric.start();
            ftm.prepareLocal(xid, throttle);
            ftm.commitLocal(xid, throttle);
        } finally {
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.commit-local", metricKey);
            }
        }
        
        System.gc();
        System.runFinalization();

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeForget(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeForget(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid)
    throws Exception {

        checkShutDown();

        fileStore.fileTransactionManager()
        .forgetXa(xid);

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeGetCadenceIntervalsForId(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId[],
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeGetCadenceIntervalsForId(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, PersistableXid xid)
    throws Exception {

        checkShutDown();
        checkXid(xid);
        List<Interval>[] intervals = fileStore.getCadenceIntervalsForId(fsIds, xid);
        dout.writeInt(intervals.length);
        for (List<Interval> element : intervals) {
            pout.save(element);
        }
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeGetIdsForSeries(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId)
     */
    @Override
    protected void executeGetIdsForSeries(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId fsid) throws Exception {

        checkShutDown();
        pout.save(fileStore.getIdsForSeries(fsid));

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeGetServerId(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream)
     */
    @Override
    protected void executeGetServerId(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        checkShutDown();

        dout.writeLong(serverId.id());

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executePrepare(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executePrepare(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid)
    throws Exception {

        checkShutDown();
        IntervalMetricKey metricKey = null;

        //Handle the read-only case.
        FileTransactionManagerInterface ftm = fileStore.fileTransactionManager();
        if (ftm.isReadOnly(xid)) {
            if (ftm.prepareXa(xid, throttle)) {
                dout.writeInt(XAResource.XA_RDONLY);
            } else {
                dout.writeInt(XAResource.XA_OK);
            }
            return;
        }

        try {
            metricKey = IntervalMetric.start();
            ftm.prepareXa(xid, throttle);
            dout.writeInt(XAResource.XA_OK);
        } finally {
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.prepare-xa", metricKey);
            }
        }

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeReadAllTimeSeriesAsFloat(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId[],
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeReadAllTimeSeriesAsFloat2(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, boolean existsError,
        PersistableXid xid) throws Exception {

        readTimeSeries(dout, pout, fsIds, -1, -1, TimeSeriesDataType.FloatType, false, xid, existsError);

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeReadAllTimeSeriesAsInt(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId[],
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeReadAllTimeSeriesAsInt2(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, boolean existsError,
        PersistableXid xid) throws Exception {

        readTimeSeries(dout, pout, fsIds, -1, -1, TimeSeriesDataType.IntType, false, xid,
            existsError);

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeReadTimeSeriesAsFloat(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId[], int, int,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeReadTimeSeriesAsFloat2(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, int startCadence,
        int endCadence, boolean existsError, PersistableXid xid)
    throws Exception {

        readTimeSeries(dout, pout, fsIds, startCadence, endCadence, TimeSeriesDataType.FloatType, true,
            xid, existsError);

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeReadTimeSeriesAsInt(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.api.FsId[], int, int,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeReadTimeSeriesAsInt2(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, int startCadence,
        int endCadence, boolean existsError, PersistableXid xid)
    throws Exception {

        readTimeSeries(dout, pout, fsIds, startCadence, endCadence, TimeSeriesDataType.IntType,
            true, xid, existsError);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeRecover(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream, int)
     */
    @Override
    protected void executeRecover(DataOutputStream dout,
        BinaryPersistableOutputStream pout, int flags) throws Exception {

        fileStore.fileTransactionManager()
        .recoverXa(flags);

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeRollback(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeRollback(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid)
    throws Exception {

        checkXid(xid);
        fileStore.fileTransactionManager().rollbackXa(xid, throttle);
        
        System.gc();
        System.runFinalization();

    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeRollbackLocalTransaction(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.client.util.PersistableXid)
     */
    @Override
    protected void executeRollbackLocalFsTransaction(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid)
    throws Exception {

        checkXid(xid);
        fileStore.fileTransactionManager().rollback(xid, throttle);
        System.gc();
        System.runFinalization();
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeShutdown(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream)
     */
    @Override
    protected void executeShutdown(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        dout.write(0);
        dout.flush();

        shutdown();

    }

    /**
     * 
     */
    void shutdown() {
        if (!shutdownInProgress.compareAndSet(false, true)) {
            return;
        }

        Runnable shutdownRunnable = new Runnable() {
            public void run() {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ie) {
                    // Ignored.
                }
                log.info("File store server shutdown starting.");
                shutdownListener.shutdownStarted();
                fileStore.shutdown();
                log.info("File store server shutdown complete.");
                shutdownExecutor.doShutdown(0);
            }
        };

        shutdownInProgress.set(true);

        Thread t = new Thread(shutdownRunnable, "File store shutdown thread.");
        t.start();
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#executeStart(java.io.DataOutputStream,
     * gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream,
     * gov.nasa.kepler.fs.client.util.PersistableXid, int)
     */
    @Override
    protected void executeStart(DataOutputStream dout,
        BinaryPersistableOutputStream pout, PersistableXid xid, int timeOut)
    throws Exception {

        fileStore.fileTransactionManager()
        .startXaTransaction(xid, timeOut, clientAddr, throttle);

    }

    @Override
    protected boolean isDeleteBlob(String uriStr) {
        return DELETE_BLOB.name()
        .equals(uriStr);
    }

    @Override
    protected boolean isDeleteMjdTimeSeries(String uriStr) {
        return DELETE_CR.name()
        .equals(uriStr);
    }

    @Override
    protected boolean isDeleteTimeSeries(String uriStr) {
        return DELETE_TS.name()
        .equals(uriStr);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isBeginLocalTransaction(java.lang.String)
     */
    @Override
    protected boolean isBeginLocalFsTransaction(String methodName) {
        return LOCAL_START.name().equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isBlobExists(java.lang.String)
     */
    @Override
    protected boolean isBlobExists(String methodName) {
        return BLOB_EXISTS.name().equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isCleanFileStore(java.lang.String)
     */
    @Override
    protected boolean isCleanFileStore(String methodName) {
        return CLEAN.name().equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isCommit(java.lang.String)
     */
    @Override
    protected boolean isCommit(String methodName) {
        return XA_COMMIT.name().equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isCommitLocalTransaction(java.lang.String)
     */
    @Override
    protected boolean isCommitLocalFsTransaction(String methodName) {
        return LOCAL_COMMIT.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isForget(java.lang.String)
     */
    @Override
    protected boolean isForget(String methodName) {
        return XA_FORGET.name().equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isGetCadenceIntervalsForId(java.lang.String)
     */
    @Override
    protected boolean isGetCadenceIntervalsForId(String methodName) {
        return GET_INTERVALS.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isGetIdsForSeries(java.lang.String)
     */
    @Override
    protected boolean isGetIdsForSeries(String methodName) {
        return GET_IDS_FOR_SERIES.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isGetServerId(java.lang.String)
     */
    @Override
    protected boolean isGetServerId(String methodName) {
        return GET_SERVER_ID.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isPrepare(java.lang.String)
     */
    @Override
    protected boolean isPrepare(String methodName) {
        return XA_PREPARE.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isReadAllTimeSeriesAsFloat(java.lang.String)
     */
    @Override
    protected boolean isReadAllTimeSeriesAsFloat2(String methodName) {
        return FLOAT_READ_ALL_TS.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isReadAllTimeSeriesAsInt(java.lang.String)
     */
    @Override
    protected boolean isReadAllTimeSeriesAsInt2(String methodName) {
        return INT_READ_ALL_TS.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isReadBlobAsStream(java.lang.String)
     */
    @Override
    protected boolean isReadBlobAsStream(String methodName) {
        return READ_BLOB.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isReadTimeSeriesAsFloat(java.lang.String)
     */
    @Override
    protected boolean isReadTimeSeriesAsFloat2(String methodName) {
        return FLOAT_READ_TS.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isReadTimeSeriesAsInt(java.lang.String)
     */
    @Override
    protected boolean isReadTimeSeriesAsInt2(String methodName) {
        return INT_READ_TS.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isRecover(java.lang.String)
     */
    @Override
    protected boolean isRecover(String methodName) {
        return XA_RECOVER.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isRollback(java.lang.String)
     */
    @Override
    protected boolean isRollback(String methodName) {
        return XA_ROLLBACK.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isRollbackLocalTransaction(java.lang.String)
     */
    @Override
    protected boolean isRollbackLocalFsTransaction(String methodName) {
        return LOCAL_ROLLBACK.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isShutdown(java.lang.String)
     */
    @Override
    protected boolean isShutdown(String methodName) {
        return SHUTDOWN.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isStart(java.lang.String)
     */
    @Override
    protected boolean isStart(String methodName) {
        return XA_START.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isWriteBlob1(java.lang.String)
     */
    @Override
    protected boolean isWriteBlob1(String methodName) {
        return WRITE_BLOB.name()
        .equals(methodName);
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isWriteBlob2(java.lang.String)
     */
    @Override
    protected boolean isWriteBlob2(String methodName) {
        return false;
    }

    /**
     * @see gov.nasa.kepler.fs.server.AbstractFstpServer#isWriteTimeSeries(java.lang.String)
     */
    @Override
    protected boolean isWriteTimeSeries2(String methodName) {
        return WRITE_TS.name()
        .equals(methodName);
    }

    private void checkXid(PersistableXid xid) throws FileStoreException {
        if (xid.isNullTransaction()) {
            throw new FileStoreException("Transaction has not been started.");
        }
    }

    private void readTimeSeries(final DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] ids,
        int defaultStartCadence, int defaultEndCadence, TimeSeriesDataType expectedDataType,
        boolean useDefaults, PersistableXid xid, boolean existsError)
    throws Exception {

        checkShutDown();
        checkXid(xid);

        CompleteReadCallback<TimeSeriesCarrier> readCallback = 
            new CompleteReadCallback<TimeSeriesCarrier>() {
            
            private final AtomicReference<Exception> error = 
                new AtomicReference<Exception>();
            
            @Override
            public synchronized void sendBackToClient(TimeSeriesCarrier readResult)
            throws Exception {
                if (error.get() != null) {
                    throw new IllegalStateException("Found cached exception." +
                            "  Bailing out of read.");
                }
                try {
                    readResult.transferTo(dout);
                } catch (Exception ex) {
                    error.compareAndSet(null, ex);
                    throw ex;
                }
            }
        };

        //Reduce FsId memory consumption
        for (FsId id : ids) {
            id.intern();
        }
        IntervalMetricKey metricKey = null;
        try {
            if (log.isDebugEnabled()) {
                log.debug("doRead " + Arrays.deepToString(ids) + " "
                    + defaultStartCadence + " " + defaultEndCadence + " "
                    + (expectedDataType == null ? "auto" : expectedDataType));
            }

            ErrorInjector.generateOom();
            metricKey = IntervalMetric.start();
            dout.writeInt(ids.length);

            ListChunkIterator<FsId> it = 
                new ListChunkIterator<FsId>(Arrays.asList(ids).iterator(), READ_WINDOW_SIZE);
            int requestOrder = 0;
            for (List<FsId> chunk : it) {
                final AcquiredPermits permits = throttle.greedyAcquirePermits();
                try {
                    fileStore.readTimeSeries(expectedDataType, useDefaults, 
                        chunk, defaultStartCadence, defaultEndCadence, xid, 
                        existsError, readCallback, requestOrder, permits);
                    requestOrder += chunk.size();
                } finally {
                    permits.releasePermits();
                }
            }

        } finally {
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.read-ts", metricKey);
            }
            dout.flush();
        }

    }

    private void checkShutDown() throws FileStoreException {
        if (shutdownInProgress.get()) {
            throw new FileStoreException("Shutdown in progress.");
        }
    }

    @Override
    protected void decodeReadBlob2(TransportServer transportServer)
    throws Exception {
        decodeReadBlob1(transportServer);
    }

    @Override
    protected void decodeWriteBlob3(TransportServer transportServer)
    throws Exception {
        decodeWriteBlob1(transportServer);
    }

    @Override
    protected boolean isReadBlob1(String uriStr) {
        return READ_BLOB.name()
        .equals(uriStr);
    }

    @Override
    protected boolean isReadBlob2(String uriStr) {
        return isReadBlob1(uriStr);
    }

    @Override
    protected boolean isWriteBlob3(String uriStr) {
        return isWriteBlob1(uriStr);
    }

    @Override
    protected void executeSetTransactionTimeout(DataOutputStream dout,
        BinaryPersistableOutputStream pout, int timeOut, PersistableXid xid)
    throws Exception {

        fileStore.fileTransactionManager().setTransactionTimeout(xid, timeOut);

    }

    @Override
    protected boolean isSetTransactionTimeout(String methodName) {
        return XA_SET_TIMEOUT.name()
        .equals(methodName);
    }

    @Override
    protected void executeListMjdTimeSeries(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId rootId) throws Exception {

        Set<FsId> crSeriesList = fileStore.listCosmicRaySeries(rootId);
        pout.save(crSeriesList);
    }

    @Override
    protected void executeReadAllMjdTimeSeries(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] ids, PersistableXid xid)
    throws Exception {

        readMjdTimeSeries(dout, pout, ids, -Double.MAX_VALUE, Double.MAX_VALUE, xid, true);
    }

    @Override
    protected void executeReadMjdTimeSeries1(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsid_a1, double startMjd,
        double endMjd, PersistableXid xid) throws Exception {

        readMjdTimeSeries(dout, pout, fsid_a1, startMjd, endMjd, xid, false);
    }

    private void readMjdTimeSeries(final DataOutputStream dout,
        final BinaryPersistableOutputStream pout, FsId[] fsIds, double startMjd,
        double endMjd, PersistableXid xid, boolean replaceStartEnd) 
    throws InterruptedException, IOException, Exception {

        checkShutDown();
        checkXid(xid);

        CompleteReadCallback<FloatMjdTimeSeries> readCallback = 
            new CompleteReadCallback<FloatMjdTimeSeries>() {
            @Override
            public synchronized void sendBackToClient(FloatMjdTimeSeries readResult)
            throws Exception {
                readResult.writeTo(dout);
            }
        };

        for (FsId id : fsIds ) {
            id.intern();
        }

        IntervalMetricKey metricKey = null;

        try {
            metricKey = IntervalMetric.start();
            dout.writeInt(fsIds.length);

            ListChunkIterator<FsId> it = 
                new ListChunkIterator<FsId>(Arrays.asList(fsIds).iterator(), READ_WINDOW_SIZE);
            int requestOrder = 0;
            for (List<FsId> chunk : it) {
                final AcquiredPermits permits = throttle.greedyAcquirePermits();
                try {
                    fileStore.readMjdTimeSeries(chunk, startMjd, endMjd, xid, 
                        replaceStartEnd, readCallback, requestOrder, permits);
                    requestOrder += chunk.size();
                } finally {
                    permits.releasePermits();
                }
            }
        } finally {
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.read-mts", metricKey);
            }
            dout.flush();
        }
    }

    @Override
    protected boolean isListMjdTimeSeries(String uriStr) {
        return LIST_CR.name()
        .equals(uriStr);
    }

    @Override
    protected boolean isReadAllMjdTimeSeries(String uriStr) {
        return READ_ALL_CR.name().equals(uriStr);
    }

    @Override
    protected boolean isReadMjdTimeSeries1(String uriStr) {
        return READ_CR.name().equals(uriStr);
    }


    @Override
    protected void executeDeleteBlob(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId fsId, PersistableXid xid)
    throws Exception {

        fileStore.deleteBlob(xid, fsId);

    }

    @Override
    protected void executeDeleteMjdTimeSeries(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsid_a1, PersistableXid xid)
    throws Exception {

        checkXid(xid);

        for (FsId fsId : fsid_a1) {
            fileStore.deleteMjdTimeSeries(xid, fsId);
        }

    }

    @Override
    protected void executeDeleteTimeSeries(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsid_a1, PersistableXid xid)
    throws Exception {

        checkXid(xid);

        for (FsId fsId : fsid_a1) {
            fileStore.deleteTimeSeries(xid, fsId);
        }
    }

    @Override
    protected void executeStatus(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        List<String> rv = new ArrayList<String>();


        rv.add("File Store Server Status\n");
        rv.add("Version Info\n");
        rv.add("\tRelease: " + KeplerSocVersion.getRelease() + "\n");
        rv.add("\tRevision: " + KeplerSocVersion.getRevision() + "\n");
        rv.add("\tBuild date: " + KeplerSocVersion.getBuildDate() + "\n");
        rv.add("\tURL: " + KeplerSocVersion.getUrl() + "\n");
        rv.add("TransactionalRandomAccessFile meta data cache.");
        rv.add("\tmeta data cache hit " + 
            fileStore.fileTransactionManager().metadataCounterStats().right + "\n");
        rv.add ("\tmeta data cache miss " +
            fileStore.fileTransactionManager().metadataCounterStats().left + "\n");
        rv.add("\n\nUp time\n");
        rv.add("\tStarted :" + startTime + "\n");
        rv.add("\tUp for: " + uptime() + "\n");

        rv.add("Throttle\n");
        rv.add("\tqueue length: " + throttle.waitQueueLength() +
        '\n');
        rv.add("\tread cost: " + throttle.readCost() + "\n");
        rv.add("\twrite cost: " + throttle.writeCost() +'\n');
        rv.add("Transactions\n");
        for (TransactionMonitoringInfo xInfo : fileStore.fileTransactionManager()
            .transactionMonitoringInfo()) {
            StringBuilder bldr = new StringBuilder();
            bldr.append('\t')
            .append(xInfo)
            .append('\n');
            rv.add(bldr.toString());
        }
        rv.add("B-Tree I/O Stats\n");
        for (@SuppressWarnings("rawtypes") DiskNodeIO nodeIo : DiskNodeIO.diskNodeIOs) {
            DiskNodeStats stats = nodeIo.stats();
            if (Double.isNaN(stats.stats().getHitToMissRatio())) {
                continue;
            }
            StringBuilder bldr = new StringBuilder();
            bldr.append('\t').append(stats.stats().toString()).append('\n');
            rv.add(bldr.toString());
        }
        dout.writeInt(rv.size());
        for (String s : rv) {
            dout.writeUTF(s);
        }
    }

    private String uptime() {
        Date now = new Date();
        long upms = now.getTime() - startTime.getTime();
        long days = upms / (1000L * 24* 60 * 60);
        long hours = (upms % (1000L * 24* 60 * 60))/ (60L * 60L * 1000L);
        long min = (upms % (60L * 60 * 100L)) / (60L * 1000L);
        long sec = (upms % (60L * 1000L)) / (1000L);
        StringBuilder bldr = new StringBuilder();
        bldr.append(days).append("d ").append(hours).append("hr ")
        .append(min).append("min ").append(sec).append("s");
        return bldr.toString();
    }

    @Override
    protected boolean isStatus(String uriStr) {
        return STATUS.name().equals(uriStr);
    }

    /**
     * This does nothing.
     */
    @Override
    protected void executePing(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        // Yea! everything is ok.
    }

    @Override
    protected boolean isPing(String uriStr) {
        return uriStr.equals(PING.name());
    }

    @Override
    protected boolean isShutdown() {
        return shutdownInProgress.get();
    }

    @Override
    protected void executeQueryIds(DataOutputStream dout,
        BinaryPersistableOutputStream pout, String query,
        PersistableXid xid) throws Exception {

        Set<FsId> ids = fileStore.fileTransactionManager().queryFsId(query);

        pout.save(ids);
    }

    @Override
    protected boolean isQueryIds(String uriStr) {
        return uriStr.equals(QUERY_FS_ID.name());
    }

    @Override
    protected void executeQueryPaths(DataOutputStream dout,
        BinaryPersistableOutputStream pout, String query) throws Exception {

        Set<FsId> ids = fileStore.fileTransactionManager().queryFsIdPath(query);
        pout.save(ids);
    }

    @Override
    protected boolean isQueryPaths(String uriStr) {
        return QUERY_FS_ID_PATH.name().equals(uriStr);
    }


    @Override
    protected boolean isWriteMjdTimeSeries2(String uriStr) {
        return WRITE_CR.name().equals(uriStr);
    }

    @Override
    protected void executeClose(DataOutputStream dout,
        BinaryPersistableOutputStream pout) throws Exception {

        closed = true;

        if (log.isDebugEnabled()) {
            log.debug("Client \"" + this.clientAddr + 
            "\" has explicitly closed the connection.");
        }
    }

    @Override
    protected boolean isClose(String uriStr) {
        return CLOSE.name().equals(uriStr);
    }

    @Override
    protected boolean isClosed() {
        return closed;
    }

    @Override
    protected void decodeWriteMjdTimeSeries2(TransportServer transportServer)
    throws Exception {

        checkShutDown();

        final PersistableXid xid = new PersistableXid();
        BufferedInputStream bin = new BufferedInputStream(transportServer.inputStream(), 1024*1024);
        DataInputStream din = new DataInputStream(bin);
        final BinaryPersistableInputStream bpin = new BinaryPersistableInputStream(din);
        bpin.load(xid);
        checkXid(xid);

        final boolean overwrite = din.readBoolean();

        final int nSeries = din.readInt();

        Iterator<FloatMjdTimeSeries> inputIt = new Iterator<FloatMjdTimeSeries>() {
            int counter=0;
            @Override
            public boolean hasNext() {
                return counter < nSeries;
            }
            @Override
            public FloatMjdTimeSeries next() {
                try {
                    FloatMjdTimeSeries mts = new FloatMjdTimeSeries();
                    bpin.load(mts);
                    counter++;
                    return mts;
                } catch (Exception ioe) {
                    throw new IllegalStateException(ioe);
                }
            }
            @Override
            public void remove() {
                throw new UnsupportedOperationException("remove() not supported.");
            }
        };

        IntervalMetricKey metricKey = null;
        try {
            metricKey = IntervalMetric.start();

            ListChunkIterator<FloatMjdTimeSeries> chunkIt =
                new ListChunkIterator<FloatMjdTimeSeries>(inputIt, BATCH_SIZE);
            for (List<FloatMjdTimeSeries> series : chunkIt) {
                final AcquiredPermits permits = throttle.greedyAcquirePermits();
                try {
                    fileStore.writeMjdTimeSeries(series, overwrite, xid, permits);
                } finally {
                    permits.releasePermits();
                }
            }

        } finally {
            if (metricKey != null) {
                IntervalMetric.stop(FS_METRICS_PREFIX + ".server.write-mts", metricKey);
            }
        }


        transportServer.outputStream().write(0);

        transportServer.outputStream().flush();
    }

    @Override
    protected void decodeReadTimeSeriesBatch(TransportServer transportServer)
    throws Exception {

        checkShutDown();

        BufferedInputStream bufIn = 
            new BufferedInputStream(transportServer.inputStream(), 1024*1024);
        DataInputStream din = new DataInputStream(bufIn);
        BinaryPersistableInputStream pin = new BinaryPersistableInputStream(din);

        PersistableXid xid = new PersistableXid();
        pin.load(xid);

        checkXid(xid);

        final boolean existsError = din.readBoolean();

        final int nSets = din.readInt();
        List<FsIdSet> fsIdSets = new ArrayList<FsIdSet>(nSets);
        for (int seti=0; seti < nSets; seti++) {
            final int startCadence = din.readInt();
            final int endCadence = din.readInt();
            final int nFsId = din.readInt();
            Set<FsId> idSet = new HashSet<FsId>(nFsId);
            for (int fsidi=0; fsidi < nFsId; fsidi++) {
                idSet.add(new FsId(din.readUTF()));
            }
            FsIdSet fsIdSet = new FsIdSet(startCadence, endCadence, idSet);
            fsIdSets.add(fsIdSet);
        }

        BufferedOutputStream bufOut = 
            new BufferedOutputStream(transportServer.outputStream(), 1024*1024);
        DataOutputStream dout = new DataOutputStream(bufOut);
        BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);

        dout.writeInt(nSets);
        for (FsIdSet fsIdSet : fsIdSets) {
            FsId[] ids = new FsId[fsIdSet.ids().size()];
            fsIdSet.ids().toArray(ids);

            dout.writeInt(fsIdSet.startCadence());
            dout.writeInt(fsIdSet.endCadence());
            readTimeSeries(dout, pout, ids, fsIdSet.startCadence(), 
                fsIdSet.endCadence(), null, true, xid, existsError);
        }

        dout.flush();

    }

    @Override
    protected boolean isReadTimeSeriesBatch(String uriStr) {
        return READ_TS_BATCH.name().equals(uriStr);
    }

    @Override
    protected void decodeReadMjdTimeSeriesBatch(TransportServer transportServer)
    throws Exception {

        checkShutDown();

        BufferedInputStream bin = new BufferedInputStream(transportServer.inputStream(), 1024*1024);
        DataInputStream din = new DataInputStream(bin);
        BinaryPersistableInputStream bpin = new BinaryPersistableInputStream(din);

        PersistableXid xid = new PersistableXid();
        bpin.load(xid);

        checkXid(xid);

        int nSets = din.readInt();
        List<MjdFsIdSet> mjdFsIdSetList = new ArrayList<MjdFsIdSet>(nSets);
        for (int i=0; i < nSets; i++) {
            MjdFsIdSet mjdFsIdSet = MjdFsIdSet.readFrom(din);
            mjdFsIdSetList.add(mjdFsIdSet);
        }

        bpin = null;
        din = null;
        bin = null;

        BufferedOutputStream bout = new BufferedOutputStream(transportServer.outputStream(), 1024*1024);
        DataOutputStream dout = new DataOutputStream(bout);
        BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);

        dout.writeInt(mjdFsIdSetList.size());
        for (MjdFsIdSet mjdFsIdSet : mjdFsIdSetList) {
            FsId[] ids = new FsId[mjdFsIdSet.ids().size()];
            mjdFsIdSet.ids().toArray(ids);

            dout.writeDouble(mjdFsIdSet.startMjd());
            dout.writeDouble(mjdFsIdSet.endMjd());
            readMjdTimeSeries(dout, pout, ids, mjdFsIdSet.startMjd(), mjdFsIdSet.endMjd(), xid, false);
        }

        dout.flush();
    }

    @Override
    protected boolean isReadMjdTimeSeriesBatch(String uriStr) {
        return READ_CR_BATCH.name().equals(uriStr);
    }

    @Override
    protected void executeReadAllTimeSeriesAsDouble(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, boolean existsError,
        PersistableXid xid) throws Exception {

        readTimeSeries(dout, pout, fsIds, -1, -1, 
            TimeSeriesDataType.DoubleType, false, xid, existsError);

    }

    @Override
    protected void executeReadTimeSeriesAsDouble(DataOutputStream dout,
        BinaryPersistableOutputStream pout, FsId[] fsIds, int startCadence, int endCadence,
        boolean existsError, PersistableXid xid) throws Exception {

        readTimeSeries(dout, pout, fsIds, startCadence, endCadence, 
            TimeSeriesDataType.DoubleType, true, xid, existsError);
    }

    @Override
    protected boolean isReadAllTimeSeriesAsDouble(String uriStr) {
        return uriStr.equals(READ_DOUBLE_ALL_TS.name());
    }

    @Override
    protected boolean isReadTimeSeriesAsDouble(String uriStr) {
        return uriStr.equals(READ_DOUBLE_TS.name());
    }

    @Override
    protected void executeQueryIds2(DataOutputStream dout,
            BinaryPersistableOutputStream pout, String queryString,
            PersistableXid implicit) throws Exception {

        Set<FsId> ids = fileStore.fileTransactionManager().queryFsId(queryString);
        dout.writeInt(ids.size());
        for (FsId id : ids) {
            id.writeTo(dout);
        }
    }

    @Override
    protected boolean isQueryIds2(String uriStr) {
        return uriStr.equals(QUERY_FS_IDS2.name());
    }

}
