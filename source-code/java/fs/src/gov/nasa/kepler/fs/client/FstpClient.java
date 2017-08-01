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

package gov.nasa.kepler.fs.client;
import gnu.trove.TObjectIntHashMap;
import gov.nasa.kepler.hibernate.dbservice.LocalTransactionalResource;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import static gov.nasa.kepler.fs.FileStoreConstants.FS_FSTP_URL;
import static gov.nasa.kepler.fs.FileStoreConstants.NO_MORE_BLOB_TO_SEND;
import static gov.nasa.kepler.fs.client.util.FileStoreMethods.*;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.client.util.PersistableXidThreadLocal;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.fs.transport.ServerSideException;
import gov.nasa.kepler.fs.transport.TransportClient;
import gov.nasa.kepler.fs.transport.TransportException;
import gov.nasa.kepler.fs.transport.TransportFactory;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.lang.BooleanThreadLocal;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;

import java.io.*;
import java.lang.reflect.Array;
import java.net.SocketAddress;
import java.util.*;

import javax.transaction.xa.XAException;
import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.antlr.runtime.RecognitionException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Communicates with the file store via fstp.   Most of which is in
 * gov.nasa.kepler.fs.transport.  In general you don't want to instantiate this
 * class yourself and you never want to subclass it.  This is left as non-final
 * for testing purposes.  This class is MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public class FstpClient extends AbstractFstpClient 
    implements FileStoreClient, FileStoreTestInterface, RemoteXAResource,  LocalTransactionalResource {

    private static final long serialVersionUID = 1827796346187873725L;

    private static final Log log = LogFactory.getLog(FstpClient.class);
    
    private transient ThreadLocal<TransportClient> transportClient;
    private transient PersistableXidThreadLocal xidThreadLocal =
        new PersistableXidThreadLocal();
    private transient BooleanThreadLocal streamInUse =
        new BooleanThreadLocal(false);
    
    private transient XAResource xaResource;
    
    /** When this is true the read/written counters will be used. */
    private volatile transient boolean countersEnabled = false;
    private List<FsId> blobsRead= Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> blobsWritten = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> timeSeriesRead = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> timeSeriesWritten = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> mjdTimeSeriesWritten = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> mjdTimeSeriesRead = Collections.synchronizedList(new ArrayList<FsId>());

    private SocketAddress socketAddress;
    
    /**
     * @throws IllegalArgumentException 
     * @throws IOException 
     * 
     */
    public FstpClient(String fstpUrl) 
        throws IllegalArgumentException, IOException {
        
        if (fstpUrl == null) {
            throw new FileStoreException("Property \"" + FS_FSTP_URL +
                                                                "\" must be specified.");
        }

        socketAddress = Util.parseFstpUrl(fstpUrl);
        transportClient = new ThreadLocal<TransportClient>() {
            protected TransportClient initialValue() {
                try {
                    return TransportFactory.newTransportClient(socketAddress);
                } catch (TransportException e) {
                    throw new IllegalStateException(e);
                }
            }
        };
        xaResource = new RemoteXAAdapter(this);
    }

    /**  This is part of the Java serialization framework.  Yes, this is private.
     * 
     */
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
    }
    
    /**  This is part of the Java serialization framework.  Yes, this is private.
     * 
     */
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        
        in.defaultReadObject();
        
        xaResource = new RemoteXAAdapter(this);
        
        transportClient = new ThreadLocal<TransportClient>() {
            protected TransportClient initialValue() {
                try {
                    return TransportFactory.newTransportClient(socketAddress);
                } catch (TransportException e) {
                    throw new IllegalStateException(e);
                }
            }
        };
    }
    
    PersistableXidThreadLocal xidThreadLocal() {
        return xidThreadLocal;
    }
    
    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameBeginLocalTransaction()
     */
    @Override
    protected String protocolMethodNameBeginLocalFsTransaction() {
        return LOCAL_START.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameBlobExists()
     */
    @Override
    protected String protocolMethodNameBlobExists() {
        return BLOB_EXISTS.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameCleanFileStore()
     */
    @Override
    protected String protocolMethodNameCleanFileStore() {
        return CLEAN.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameCommit()
     */
    @Override
    protected String protocolMethodNameCommit() {
        return XA_COMMIT.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameCommitLocalTransaction()
     */
    @Override
    protected String protocolMethodNameCommitLocalFsTransaction() {
        return LOCAL_COMMIT.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameForget()
     */
    @Override
    protected String protocolMethodNameForget() {
        return XA_FORGET.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameGetCadenceIntervalsForId()
     */
    @Override
    protected String protocolMethodNameGetCadenceIntervalsForId() {
        return GET_INTERVALS.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameGetIdsForSeries()
     */
    @Override
    protected String protocolMethodNameGetIdsForSeries() {
        return  GET_IDS_FOR_SERIES.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameGetServerId()
     */
    @Override
    protected String protocolMethodNameGetServerId() {
        return GET_SERVER_ID.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNamePrepare()
     */
    @Override
    protected String protocolMethodNamePrepare() {
        return XA_PREPARE.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameReadAllTimeSeriesAsFloat()
     */
    @Override
    protected String protocolMethodNameReadAllTimeSeriesAsFloat2() {
        return FLOAT_READ_ALL_TS.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameReadAllTimeSeriesAsInt()
     */
    @Override
    protected String protocolMethodNameReadAllTimeSeriesAsInt2() {
        return INT_READ_ALL_TS.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameReadBlob()
     */
    @Override
    protected String protocolMethodNameReadBlob1() {
        return READ_BLOB.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameReadTimeSeriesAsFloat()
     */
    @Override
    protected String protocolMethodNameReadTimeSeriesAsFloat2() {
        return FLOAT_READ_TS.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameReadTimeSeriesAsInt()
     */
    @Override
    protected String protocolMethodNameReadTimeSeriesAsInt2() {
        return INT_READ_TS.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameRecover()
     */
    @Override
    protected String protocolMethodNameRecover() {
        return XA_RECOVER.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameRollback()
     */
    @Override
    protected String protocolMethodNameRollback() {
        return XA_ROLLBACK.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameRollbackLocalTransaction()
     */
    @Override
    protected String protocolMethodNameRollbackLocalFsTransaction() {
        return LOCAL_ROLLBACK.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameShutdown()
     */
    @Override
    protected String protocolMethodNameShutdown() {
        return SHUTDOWN.name();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#protocolMethodNameStart()
     */
    @Override
    protected String protocolMethodNameStart() {
        return XA_START.name();
    }

    @Override
    public void cleanFileStore() {
        super.cleanFileStore();
        xidThreadLocal.remove();
    }
    
    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnBeginLocalTransaction(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected Xid returnBeginLocalFsTransaction(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {

        PersistableXid pxid = new PersistableXid();
        pin.load(pxid);
        return pxid;
        
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnBlobExists(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected boolean returnBlobExists(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {
        return din.readBoolean();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnGetCadenceIntervalsForId(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @SuppressWarnings("unchecked")
    @Override
    protected List<Interval>[] returnGetCadenceIntervalsForId(
        DataInputStream din, BinaryPersistableInputStream pin) throws Exception {

        int size = din.readInt();
        List<Interval>[] rv = (List<Interval>[])(Object) new List[size];
        for (int i=0; i < size; i++) {
            rv[i] = new ArrayList<Interval>();
            pin.loadList(rv[i], SimpleInterval.class, 1);
        }
        return rv;
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnGetIdsForSeries(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected Set<FsId> returnGetIdsForSeries(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {

        Set<FsId> rv = new HashSet<FsId>();
        pin.loadSet(rv, FsId.class);
        return rv;
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnGetServerId(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected long returnGetServerId(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {

        return din.readLong();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnPrepare(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected int returnPrepare(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {

        
        return din.readInt();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractHttpClient#returnReadTimeSeriesAsFloat(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected FloatTimeSeries[] returnReadTimeSeriesAsFloat2(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {
      
        return (FloatTimeSeries[]) returnReadTimeSeries(din, pin, FloatTimeSeries.class);
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractHttpClient#returnReadTimeSeriesAsInt(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected IntTimeSeries[] returnReadTimeSeriesAsInt2(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {
        
        return (IntTimeSeries[]) returnReadTimeSeries(din, pin, IntTimeSeries.class);
    }

    @Override
    protected FloatTimeSeries[] returnReadAllTimeSeriesAsFloat2(DataInputStream din, BinaryPersistableInputStream pin) 
        throws Exception {
        return (FloatTimeSeries[]) returnReadTimeSeries(din, pin, FloatTimeSeries.class);
    }

    @Override
    protected IntTimeSeries[] returnReadAllTimeSeriesAsInt2(DataInputStream din, BinaryPersistableInputStream pin) throws Exception {
        return (IntTimeSeries[]) returnReadTimeSeries(din, pin, IntTimeSeries.class);
    }

    private TimeSeries[] returnReadTimeSeries(DataInputStream din,
        BinaryPersistableInputStream pin, Class<?> timeSeriesClass)
        throws Exception {

        int size = din.readInt();
        TimeSeries[] rv = (TimeSeries[]) Array.newInstance(timeSeriesClass, size);
        for (int i = 0; i < size; i++) {
            TimeSeries timeSeries = TimeSeries.transferFrom(din);
            rv[i] = timeSeries;
        }
        return rv;
    }
    
    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#returnRecover(java.io.DataInputStream, gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream)
     */
    @Override
    protected PersistableXid[] returnRecover(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {

        int size = din.readInt();
        PersistableXid[] rv = new PersistableXid[size];
        for (int i=0; i < size; i++) {
            rv[i] = new PersistableXid();
            pin.load(rv[i]);
        }
        
        return rv;
        
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#transportClient()
     */
    @Override
    protected TransportClient transportClient() {
        return transportClient.get();
    }

    /**
     * @see gov.nasa.kepler.fs.client.AbstractFstpClient#xid()
     */
    @Override
    protected PersistableXid xid() {
        return xidThreadLocal.xid();
    }

    /**
     * @see gov.nasa.kepler.fs.api.TransactionClient#rollbackLocalFsTransactionIfActive()
     */
    @Override
    public void rollbackLocalFsTransactionIfActive() {
        if (xidThreadLocal.xid().isNullTransaction()) {
            return;
        }
        this.rollbackLocalFsTransaction();
    }
    
    @Override
    public boolean localTransactionIsActive() {
        return !xidThreadLocal.xid().isNullTransaction();
    }

    /**
     * @see gov.nasa.kepler.fs.api.BlobClient#readBlobAsStream(gov.nasa.kepler.fs.api.FsId)
     */
    public StreamedBlobResult readBlobAsStream(FsId id)
        {
        
        boolean rollback = false;
        if (xid().isNullTransaction()) {
            beginLocalFsTransaction();
            rollback = true;
        }
        
        if (countersEnabled) {
            blobsRead.add(id);
        }
        
        try {
            transportClient().startMethod();
            DataOutputStream dout = new DataOutputStream(transportClient().outputStream());
            dout.writeUTF(READ_BLOB.name());
    
            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);
            pout.save(xid());
            pout.save(id);
            dout.flush();
            
            DataInputStream din = new DataInputStream(transportClient().inputStream());
            long origin = din.readLong();
            long fileLength = din.readLong();
            boolean streamRollback = rollback;
            rollback = false;
            FileStoreInputStream fin = new FileStoreInputStream(fileLength, streamRollback, din);
            return new StreamedBlobResult(origin, fileLength, fin);
        }  catch (ServerSideException sse) {
            if (sse.getCause() instanceof gov.nasa.kepler.fs.api.FileStoreException ) {
                throw (gov.nasa.kepler.fs.api.FileStoreException)sse.getCause();
            }
            throw new RuntimeException("Unexpected exception.",sse.getCause());
        } catch (IOException ioe) {
            throw new FileStoreException("Transport layer exception.", ioe);
        } catch (Exception e) {
            throw new RuntimeException("Transport layer exception.", e);
        } finally {
            if (rollback) {
                rollbackLocalFsTransaction();
            }
        }
    }

    
    /**
     * @see gov.nasa.kepler.fs.api.BlobClient#writeBlob(gov.nasa.kepler.fs.api.FsId, int)
     */
    public OutputStream writeBlob(FsId id, long origin) {
        
        if (countersEnabled) {
            blobsWritten.add(id);
        }
        
        try {
            transportClient().startMethod();
            DataOutputStream dout = new DataOutputStream(transportClient().outputStream());
            dout.writeUTF(WRITE_BLOB.name());

            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);
            pout.save(xid());
            pout.save(id);
            dout.writeLong(origin);
            dout.flush();

            return new FileStoreOutputStream();
            
        } catch (ServerSideException sse) {
            if (sse.getCause() instanceof gov.nasa.kepler.fs.api.FileStoreException ) {
                throw (gov.nasa.kepler.fs.api.FileStoreException)sse.getCause();
            }
            throw new RuntimeException("Unexpected exception.",sse.getCause());
        } catch (IOException ioe) {
            throw new FileStoreException("Transport layer exception.", ioe);
        } catch (Exception e) {
            throw new RuntimeException("Transport layer exception.", e);
        }
    }

    /**
     * Modifies the assoication of the Xid with the current thread.
     */
    public void end(PersistableXid xid, int flags) throws XAException {
        switch (flags) {
            case XAResource.TMSUCCESS:
            case XAResource.TMFAIL:
            case XAResource.TMSUSPEND:
                if (!this.xidThreadLocal.xid().equals(xid)) {
                    throw new XAException(XAException.XAER_NOTA);
                }
                this.xidThreadLocal.remove();
                break;
            default:
                throw new XAException(XAException.XAER_INVAL);
        }  
    }

    @Override
    protected BlobResult returnReadBlob1(DataInputStream din, 
        BinaryPersistableInputStream pin) throws Exception {
            
        long originator = din.readLong();
        long dataSize = din.readLong();
        if (dataSize > Integer.MAX_VALUE) {
            throw new FileStoreException("Blob too large to be read into a byte array.");
        }
        byte[] data = new byte[(int) dataSize];
        din.readFully(data);
        BlobResult bresult = new BlobResult(originator, data);
        return bresult;
    }
    
    @Override
    public void writeTimeSeries(TimeSeries[] timeSeries, boolean overwrite) {
        if (countersEnabled) {
            for (TimeSeries t : timeSeries) {
                timeSeriesWritten.add(t.id());
            }
        }
        super.writeTimeSeries(timeSeries, overwrite);
    }
    
    @Override
    public IntTimeSeries[] readTimeSeriesAsInt(FsId[] id, int startCadence, int endCadence) {
        return readTimeSeriesAsInt(id, startCadence, endCadence, true);
    }
    
    @Override
    public IntTimeSeries[] readTimeSeriesAsInt(final FsId[] ids, final int startCadence, 
            final int endCadence, final boolean existsError)
         {
        
        if (startCadence > endCadence) {
            throw new IllegalArgumentException("start cadence " + startCadence
                + " comes before end cadence " +endCadence);
        }
        if (countersEnabled) {
            timeSeriesRead.addAll(Arrays.asList(ids));
        }
        
        return new ImplicitTransactionLifecycle<IntTimeSeries[]>(this) {
            @Override
            protected IntTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                IntTimeSeries[] ordered = (IntTimeSeries[])
                    reorder(FstpClient.super.readTimeSeriesAsInt(ids, startCadence, endCadence, existsError), fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
    
    public IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] ids) {
        return readAllTimeSeriesAsInt(ids, true);
    }
    
    @Override
    public IntTimeSeries[] readAllTimeSeriesAsInt(final FsId[] ids, final boolean existsError)
        {
        
        if (countersEnabled) {
            timeSeriesRead.addAll(Arrays.asList(ids));
        }
        return new ImplicitTransactionLifecycle<IntTimeSeries[]>(this) {
            @Override
            protected IntTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                IntTimeSeries[] ordered = (IntTimeSeries[])
                    reorder(FstpClient.super.readAllTimeSeriesAsInt(ids, existsError), fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
    
    public FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] id) {
        return readAllTimeSeriesAsFloat(id, true);
    }
    
    @Override
    public FloatTimeSeries[] readAllTimeSeriesAsFloat(final FsId[] ids, final boolean existsError)
        {
        
        if (countersEnabled) {
            timeSeriesRead.addAll(Arrays.asList(ids));
        }
        
        return new ImplicitTransactionLifecycle<FloatTimeSeries[]>(this) {
            @Override
            protected FloatTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                FloatTimeSeries[] ordered = (FloatTimeSeries[])
                    reorder(FstpClient.super.readAllTimeSeriesAsFloat(ids, existsError), fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
     
    public FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] id, int startCadence, int endCadence) 
        {
        
        return readTimeSeriesAsFloat(id, startCadence, endCadence, true);
    }
    
    @Override
    public FloatTimeSeries[] readTimeSeriesAsFloat(final FsId[] ids,  
        final int startCadence, final int endCadence, final boolean existsError)
        {
        
        if (startCadence > endCadence) {
            throw new IllegalArgumentException("start cadence " + startCadence 
                + " comes after end cadence " + endCadence);
        }
        if (countersEnabled) {
            timeSeriesRead.addAll(Arrays.asList(ids));
        }
        
        return new ImplicitTransactionLifecycle<FloatTimeSeries[]>(this) {
            @Override
            protected FloatTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                FloatTimeSeries[] ordered = (FloatTimeSeries[])
                    reorder(FstpClient.super.readTimeSeriesAsFloat(ids, startCadence, endCadence, existsError),fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
    
    /**
     * This overrides the default startLocalTransaction so that it can set 
     * thread local variables.
     */
    @Override
    public Xid beginLocalFsTransaction() {
        if (!xidThreadLocal.xid().isNullTransaction()) {
            throw new FileStoreException("Transaction already started.");
        }
        PersistableXid xidFromServer =
            (PersistableXid) super.beginLocalFsTransaction();
        xidThreadLocal.setXid(xidFromServer);
        xidThreadLocal.setState(TransactionState.STARTED);
        return xidFromServer;
    }
    
    /**
     * Associates the current thread with the specified transaction.
     */
    @Override
    public void start(PersistableXid newXid, int timeOut) throws XAException {
        log.info("Starting XA transaction \"" + newXid + "\".");
        if (!this.xidThreadLocal.xid().isNullTransaction()) {
            log.error("Attempt to start transaction \"" + newXid + "\" with thread \"" 
                    + Thread.currentThread().getName() + "\" but has existing transaction \"" + xidThreadLocal.xid()
                    + "\" " + Thread.currentThread().getName() + "\".");
            throw new XAException(XAException.XAER_INVAL);
        }
        super.start(newXid, timeOut);
        this.xidThreadLocal.setXid(newXid);
    }
    
    @Override
    public int prepare(PersistableXid xid) throws XAException {
        try {
            return super.prepare(xid);
        } catch (Throwable t) {
            log.error("prepare failed", t);
            if (t instanceof XAException) {
                throw (XAException) t;
            }
            XAException xa = new XAException(XAException.XAER_RMERR);
            xa.initCause(t);
            throw xa;
        }
    }
    
    
    /**
     * This overrides the default rollback so that the xid can be reset.
     */
    @Override
    public void rollbackLocalFsTransaction() {
        try {
            super.rollbackLocalFsTransaction();
            xidThreadLocal.remove();
            xidThreadLocal.setState(TransactionState.ROLLEDBACK);
        } catch (TransactionNotExistException xnotexist) {
            //Our state is out of sync with the file store server state.  It must
            //be correct.
            xidThreadLocal.remove();
            xidThreadLocal.setState(TransactionState.ROLLEDBACK);
        }
    }
    
    /**
     * This overrides the default commitLocalTransaction so that the xid
     * can be reset.
     */
    @Override
    public void commitLocalFsTransaction() {
        super.commitLocalFsTransaction();
        xidThreadLocal.remove();
        xidThreadLocal.setState(TransactionState.COMMITTED);
    }
    
    /**
     * This implementation automatically creates a transaction and rolls it
     * back after it is done.
     */
    @Override
    public boolean blobExists(final FsId id) {
        return new ImplicitTransactionLifecycle<Boolean>(this) {
            @Override
            protected Boolean doit() {
                return FstpClient.super.blobExists(id);
            }
        }.execute();
    }
    
    /**
     * This implementation automatically creates a transaction and rolls it
     * back after it is done reading if there is not current transaction active.
     */
    @Override
    public BlobResult readBlob(final FsId id) {
        if (countersEnabled) {
            blobsRead.add(id);
        }
        
        return new ImplicitTransactionLifecycle<BlobResult>(this) {
            @Override
            protected BlobResult doit() {
                return FstpClient.super.readBlob(id);
            }
        }.execute();
    }
    
    @Override
    public List<Interval>[] getCadenceIntervalsForId(final FsId[] ids) {
        return new ImplicitTransactionLifecycle<List<Interval>[]>(this) {
            @Override
            protected List<Interval>[] doit() {
                return FstpClient.super.getCadenceIntervalsForId(ids);
            }
        }.execute();
    }
    
    private class FileStoreOutputStream extends OutputStream {

        private final DataOutputStream out;
        private final InputStream in;
        private boolean isClosed = false;
        private final Thread associatedThread;
        
        FileStoreOutputStream() throws IOException {
            out = new DataOutputStream(transportClient().outputStream());
            in = transportClient().inputStream();
            this.associatedThread = Thread.currentThread();
            streamInUse.set(true);
        }
        
        private void checkConcurrentModification() {
            if (Thread.currentThread() != associatedThread) {
                throw new ConcurrentModificationException("Expected creating " +
                    " thread \"" + associatedThread + "\", but called by thread" +
                    "\"" + Thread.currentThread() + "\".");
            }
        }
        @Override
        public void write(int b) throws IOException {
            checkConcurrentModification();
            out.writeLong(1);
            out.write(b);
        }
        
        
        @Override
        public void write(byte[] b) throws IOException {
            checkConcurrentModification();
            write(b, 0, b.length);
        }
        
        @Override
        public void write(byte[] b, int off, int len) throws IOException {
            checkConcurrentModification();
            if (len == 0) {
                return;
            }
            out.writeLong(len);
            out.write(b, off, len);
        }
        
        @Override
        public void close() throws IOException {
            checkConcurrentModification();
            try {
                if (isClosed) {
                    throw new IOException("Closed already.");
                }
                isClosed = true;
                out.writeLong(NO_MORE_BLOB_TO_SEND);
                out.flush();
                if (in.read() != 0) {
                    transportClient().close();
                    throw new IOException("Expected ack.");
                }
            } finally {
                streamInUse.set(false);
            }
        }
        
    }
    
    private class FileStoreInputStream extends InputStream {
        private final DataInputStream din;
        private long fileSize;
        private final boolean rollbackOnClose;
        private final Thread associatedThread;
        
        FileStoreInputStream(long fileSize, boolean rollbackOnClose, DataInputStream din)  {
            this.din = din;
            this.rollbackOnClose = rollbackOnClose;
            this.fileSize = fileSize;
            this.associatedThread = Thread.currentThread();
            streamInUse.set(true);
        }

        private void checkConcurrentModification() {
            if (Thread.currentThread() != associatedThread) {
                throw new ConcurrentModificationException("Stream created by " +
                    "thread \"" + associatedThread + "\" by accessed by " +
                    "thread \""  + Thread.currentThread() + "\".");
            }
        }
        
        @Override
        public int read() throws IOException {
            checkConcurrentModification();
            
            if (fileSize == 0) {
                return -1;
            }
            try {
                fileSize--;
                return din.read();
            } catch (IOException ioe) {
                fileSize = 0;
                throw ioe;
            } catch (RuntimeException rte) {
                fileSize = 0;
                throw rte;
            }
        }
        
        @Override
        public int read(byte[] b, int off, int len) throws IOException {
            checkConcurrentModification();
            
            if (fileSize == 0) {
                return -1;
            }

            try {
                long readLen = Math.min(len, fileSize);
                int nread = din.read(b, off, (int) readLen);
                fileSize -= nread;
                return nread;
            } catch (IOException ioe) {
                fileSize = 0;
                throw ioe;
            } catch (RuntimeException rte) {
                fileSize = 0;
                throw rte;
            }
        }
        
        @Override
        public void close() throws IOException {
            checkConcurrentModification();
            try {
                //Read all the slack in the file from the server, but don't write
                //it anywhere.
                while (fileSize > 0) {
                    byte[] buf = new byte[1024*16];
                    int readSize = (int) Math.min(fileSize, buf.length);
                    int nread =  din.read(buf,0,readSize);
                    if (nread < 0) {
                        break; //EOF
                    }
                    fileSize -= nread;
                }
                if (rollbackOnClose) {
                    try {
                        rollbackLocalFsTransaction();
                    } catch (FileStoreException e) {
                        throw new IOException(e);
                    }
                }
            } finally {
                streamInUse.set(false);
            }
        }
    }

    public XAResource getXAResource() {
        return xaResource;
    }

    @Override
    protected void encodeRequestWriteTimeSeries2(DataOutputStream dout, 
                                          BinaryPersistableOutputStream pout,
                                          TimeSeries[] tsa,
                                          boolean overwrite)
        throws Exception{

        dout.writeBoolean(overwrite);
        dout.writeInt(tsa.length);
        for (TimeSeries t : tsa) {
            t.transferTo(dout);
        }
        dout.flush();
        
    }

    @Override
    protected void encodeRequestWriteBlob3(DataOutputStream dout, 
                                         BinaryPersistableOutputStream pout,
                                         FsId id, long origin, 
                                         byte[] data)
        throws Exception {
        
        pout.save(id);
        dout.writeLong(origin);
        dout.writeLong(data.length);
        dout.write(data);
        dout.writeLong(NO_MORE_BLOB_TO_SEND);
        
    }

    @Override
    protected String protocolMethodNameWriteBlob3() {
        return WRITE_BLOB.name();
    }

    public long readBlob(FsId id, File dest) {
        boolean rollback = false;
        
        if (countersEnabled) {
            blobsRead.add(id);
        }
        
        if (xid().isNullTransaction()) {
            beginLocalFsTransaction();
            rollback = true;
        }
        
        RandomAccessFile destRaf = null;
        
        try {
            destRaf =  new RandomAccessFile(dest, "rw");
            
            transportClient().startMethod();
            BufferedOutputStream bout = 
                new BufferedOutputStream(transportClient().outputStream());
            DataOutputStream dout = new DataOutputStream(bout);
            dout.writeUTF(READ_BLOB.name());

            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);
            pout.save(xid());
            pout.save(id);
            bout.flush();
            
            InputStream in = transportClient().inputStream();
            DataInputStream din = new DataInputStream(in);
            long origin = din.readLong();
            long size = din.readLong();
            transportClient().receiveFile(destRaf.getChannel(), 0, size);
            
            return origin;
        } catch (Exception ioe) {
            throw new FileStoreException("IOException", ioe);
        } finally {
            if (rollback) {
                rollbackLocalFsTransaction();
            }
            if (destRaf != null) {
                try {
                    destRaf.close();
                } catch (IOException ioe) {
                    //ignore
                }
            }
        }

        
    }

    public void writeBlob(FsId id,  long origin, File src) {
       
        if (countersEnabled) {
            blobsWritten.add(id);
        }
        
       RandomAccessFile srcRaf = null;
        try {
            srcRaf =  new RandomAccessFile(src, "r");
            
            transportClient().startMethod();
            BufferedOutputStream bout = 
                new BufferedOutputStream(transportClient().outputStream());
            DataOutputStream dout = new DataOutputStream(bout);
            dout.writeUTF(WRITE_BLOB.name());

            BinaryPersistableOutputStream pout = new BinaryPersistableOutputStream(dout);
            pout.save(xid());
            pout.save(id);
            dout.writeLong(origin);
            dout.writeLong(src.length());
            bout.flush();
            
            transportClient().sendFile(srcRaf.getChannel(), 0, src.length());
            dout.writeLong(NO_MORE_BLOB_TO_SEND);
            dout.flush();
            
            if (transportClient().inputStream().read() != 0) {
                transportClient().close();
                throw new IOException("Expected ack.");
            }
        } catch (Exception x) {
            throw new FileStoreException("Wrapped exception.", x);
        } finally {
            if (srcRaf != null) {
                try {
                    srcRaf.close();
                } catch (IOException ioe) {
                    //Ignored
                }
            }
        }
        
    }

    /**
     * This does nothing,
     */
    public void initialize(TransactionService xService) {
        //Nothing
    }

    public void beginLocalTransaction() {
        beginLocalFsTransaction();
    }

    public void commitLocalTransaction() {
        commitLocalFsTransaction();
    }

    public void rollbackLocalTransactionIfActive() {
        rollbackLocalFsTransactionIfActive();
    }

    @Override
    protected String protocolMethodNameSetTransactionTimeout() {
        return XA_SET_TIMEOUT.name();
    }

    @Override
    protected boolean returnSetTransactionTimeout(DataInputStream din, BinaryPersistableInputStream pin) throws Exception {
        return din.readBoolean();
    }

    @Override
    protected String protocolMethodNameListMjdTimeSeries() {
        return LIST_CR.name();
    }

    @Override
    protected String protocolMethodNameReadAllMjdTimeSeries() {
        return READ_ALL_CR.name();
    }

    @Override
    protected String protocolMethodNameReadMjdTimeSeries1() {
        return READ_CR.name();
    }


    @Override
    public void writeMjdTimeSeries(FloatMjdTimeSeries[] series, boolean overwrite) {
        if (countersEnabled) {
            for (FloatMjdTimeSeries s : series) {
                mjdTimeSeriesWritten.add(s.id());
            }
        }
        super.writeMjdTimeSeries(series, overwrite);
    }
    
    @Override
    protected Set<FsId> returnListMjdTimeSeries(DataInputStream din, BinaryPersistableInputStream pin) throws Exception {
        Set<FsId> rv = new HashSet<FsId>();
        pin.loadSet(rv, FsId.class);
        return rv;
    }

    @Override
    public FloatMjdTimeSeries[] readMjdTimeSeries(final FsId[] ids, 
        final double mjdStart, final double mjdEnd) {
        if (countersEnabled) {
            mjdTimeSeriesRead.addAll(Arrays.asList(ids));
        }
        return new ImplicitTransactionLifecycle<FloatMjdTimeSeries[]>(this) {
            @Override
            protected FloatMjdTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                FloatMjdTimeSeries[] ordered = (FloatMjdTimeSeries[])
                    reorder(FstpClient.super.readMjdTimeSeries(ids, mjdStart, mjdEnd), fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
    
   
    private static TObjectIntHashMap<FsId> buildFsIdOrder(FsId[] ids) {
        TObjectIntHashMap<FsId> fsIdToOrder = new TObjectIntHashMap<FsId>(ids.length);
        int order = 0;
        for (FsId id : ids) {
            if (fsIdToOrder.contains(id)) {
                throw new FileStoreException("Duplicate id \"" + id + "\" not permitted.");
            }
            fsIdToOrder.put(id, order++);
        }
        return fsIdToOrder;
    }

    //There are some issues using generics here because arrays do not conform well.
    private static Object[] reorder(Object[] unordered, TObjectIntHashMap<FsId> fsIdToOrder) {
        Class<?> arrayComponentType = unordered.getClass().getComponentType();
        Object[] ordered = (Object[]) Array.newInstance(arrayComponentType, unordered.length);
        for (Object u : unordered) {
            ordered[fsIdToOrder.get(((FsTimeSeries)u).id())] = u;
        }
        return ordered;
    }
    
    @Override
    public FloatMjdTimeSeries[] readAllMjdTimeSeries(final FsId[] ids) {
        if (countersEnabled) {
            mjdTimeSeriesRead.addAll(Arrays.asList(ids));
        }
        return new ImplicitTransactionLifecycle<FloatMjdTimeSeries[]>(this) {
            @Override
            protected FloatMjdTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                FloatMjdTimeSeries[] ordered = (FloatMjdTimeSeries[])
                    reorder(FstpClient.super.readAllMjdTimeSeries(ids), fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
    
    @Override
    protected FloatMjdTimeSeries[] returnReadAllMjdTimeSeries(DataInputStream din, BinaryPersistableInputStream pin) throws Exception {
        return returnReadMjdTimeSeries1(din, pin);
    }

    @Override
    protected FloatMjdTimeSeries[] returnReadMjdTimeSeries1(DataInputStream din, BinaryPersistableInputStream pin) throws Exception {
        
        int nvalues = din.readInt();
        FloatMjdTimeSeries[] rv = new FloatMjdTimeSeries[nvalues];
        for (int i=0; i < nvalues; i++) {
            rv[i] = FloatMjdTimeSeries.readFrom(din);
        }
        
        return rv;
    }

    public void disassociateThread() {
        xidThreadLocal.disassociate();
    }

    @Override
    protected String protocolMethodNameDeleteBlob() {
        return DELETE_BLOB.name();
    }

    @Override
    protected String protocolMethodNameDeleteMjdTimeSeries() {
        return DELETE_CR.name();
    }

    @Override
    protected String protocolMethodNameDeleteTimeSeries() {
        return DELETE_TS.name();
    }

    @Override
    protected String protocolMethodNameStatus() {
        return STATUS.name();
    }

    @Override
    protected List<String> returnStatus(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {
        
        int nstrings = din.readInt();
        List<String> rv = new ArrayList<String>(nstrings);
        for (int i=0; i < nstrings; i++) {
            String s = din.readUTF();
            rv.add(s);
        }
        
        return rv;
    }

    @Override
    protected String protocolMethodNamePing() {
        return PING.name();
    }

    @Override
    protected String protocolMethodNameWriteTimeSeries2() {
        return WRITE_TS.name();
    }

    @Override
    public void writeTimeSeries(TimeSeries[] ts) {
        this.writeTimeSeries(ts, true);
    }

    @Override
    protected String protocolMethodNameQueryIds() {
        return QUERY_FS_ID.name();
    }

    @Override
    public Set<FsId> queryIds(final String query) {
        //Check query.
        try {
            new QueryEvaluator(query);
        } catch (RecognitionException e) {
            throw new FileStoreException("Bad query \"" + query + "\".", e);
        }
        
        return new ImplicitTransactionLifecycle<Set<FsId>>(this) {
            @Override
            protected Set<FsId> doit() {
                Set<FsId> rv = FstpClient.super.queryIds(query);
                return rv;
            }
        }.execute();
    }
    
    @Override
    protected Set<FsId> returnQueryIds(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {
        
        Set<FsId> rv = new HashSet<FsId>();
        pin.loadSet(rv, FsId.class);
        for (FsId id : rv) {
            id.intern();
        }
        return rv;
        
        
    }
    
    @Override
    protected String protocolMethodNameQueryIds2() {
        return QUERY_FS_IDS2.name();
    }

    @Override
    protected Set<FsId> returnQueryIds2(DataInputStream din,
            BinaryPersistableInputStream pin) throws Exception {

        int setSize = din.readInt();
        Set<FsId> rv = new HashSet<FsId>(setSize);
        for (int i=0; i < setSize; i++) {
            rv.add(FsId.readFrom(din));
        }
        return rv;
    }

    @Override
    protected String protocolMethodNameQueryPaths() {
        return QUERY_FS_ID_PATH.name();
    }

    @Override
    public Set<FsId> queryPaths(final String query) {
        //Check query.
        try {
            new QueryEvaluator(query);
        } catch (RecognitionException e) {
            throw new FileStoreException("Bad query \"" + query + "\".", e);
        }
        return new ImplicitTransactionLifecycle<Set<FsId>>(this) {
            @Override
            protected Set<FsId> doit() { 
                return FstpClient.super.queryPaths(query);
            }
        }.execute();
    }
    
    @Override
    protected Set<FsId> returnQueryPaths(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {
        
        Set<FsId> rv = new HashSet<FsId>();
        pin.loadSet(rv, FsId.class);
        for (FsId id : rv) {
            id.intern();
        }
        return rv;
    }

    @Override
    protected String protocolMethodNameWriteMjdTimeSeries2() {
        return WRITE_CR.name();
    }

    @Override
    public void writeMjdTimeSeries(FloatMjdTimeSeries[] series)
        {

        writeMjdTimeSeries(series, true);
    }

    @Override
    protected String protocolMethodNameClose() {
        return CLOSE.name();
    }
    
    @Override
    public void close() throws IOException {
        if (!this.transportClient.get().isConnected()) {
            return;
        }
        try {
            this.transportClient.get().setTimeOut(2);
        } catch (IOException ignored) {
            log.warn("Failed to set socket timeout during close.");
        }
        try {
            super.close();
        } catch (IOException ioe) {
            //This exception is not very interesting.
            log.warn("Exeption when sending close() message to server.", ioe);
        } finally {
            this.transportClient.get().close();
        }
    }
    
    @Override
    public Xid xidForCurrentThread() {
        if (this.xidThreadLocal.xid().isNullTransaction()) {
            return null;
        }
        return this.xidThreadLocal.xid();
    }

    @Override
    public List<FsId> getBlobsRead() {
        return Collections.unmodifiableList(blobsRead);
    }

    @Override
    public List<FsId> getBlobsWritten() {
        return Collections.unmodifiableList(blobsWritten);
    }

    @Override
    public List<FsId> getMjdTimeSeriesWritten() {
        return Collections.unmodifiableList(timeSeriesWritten);
    }

    @Override
    public List<FsId> getTimeSeriesRead() {
        return Collections.unmodifiableList(timeSeriesRead);
    }

    @Override
    public List<FsId> getTimeSeriesWritten() {
        return Collections.unmodifiableList(timeSeriesWritten);
    }

    @Override
    public void setEnableFsIdCounters(boolean enable) {
        countersEnabled = enable;
        
        if (!countersEnabled) {
            blobsRead.clear();
            blobsWritten.clear();
            timeSeriesRead.clear();
            timeSeriesWritten.clear();
            mjdTimeSeriesRead.clear();
            mjdTimeSeriesWritten.clear();
        }
    }

    @Override
    public TransactionState localTransactionState() {
        return xidThreadLocal.xState();
    }

    @Override
    protected void encodeRequestWriteMjdTimeSeries2(DataOutputStream dout,
        BinaryPersistableOutputStream pout,
        FloatMjdTimeSeries[] mjdTimeSeries, boolean overwrite)
        throws Exception {

        dout.writeBoolean(overwrite);
        dout.writeInt(mjdTimeSeries.length);
        for (FloatMjdTimeSeries mts : mjdTimeSeries) {
            pout.save(mts);
        }
        dout.flush();
    }

    @Override
    protected void encodeRequestReadTimeSeriesBatch(DataOutputStream dout,
        BinaryPersistableOutputStream pout, List<FsIdSet> fsIdSetList, boolean existsError)
        throws Exception {

        dout.writeBoolean(existsError);

        dout.writeInt(fsIdSetList.size());
        for (FsIdSet fsIdSet : fsIdSetList) {
            dout.writeInt(fsIdSet.startCadence());
            dout.writeInt(fsIdSet.endCadence());
            dout.writeInt(fsIdSet.ids().size());
            for (FsId id : fsIdSet.ids()) {
                dout.writeUTF(id.toString());
            }
        }
    }

    @Override
    protected String protocolMethodNameReadTimeSeriesBatch() {
        return READ_TS_BATCH.name();
    }

    @Override
    protected List<TimeSeriesBatch> returnReadTimeSeriesBatch(DataInputStream din,
        BinaryPersistableInputStream pin) throws Exception {

        int nBatches = din.readInt();
        List<TimeSeriesBatch> rv = new ArrayList<TimeSeriesBatch>(nBatches);
        for (int i=0; i < nBatches; i++) {
            int startCadence = din.readInt();
            int endCadence = din.readInt();
            int nSeries = din.readInt();
            Map<FsId, TimeSeries> map = new HashMap<FsId, TimeSeries>(nSeries);
            for (int seriesi=0; seriesi < nSeries; seriesi++) {
                TimeSeries ts = TimeSeries.transferFrom(din);
                map.put(ts.id(), ts);
            }
            TimeSeriesBatch batch = new TimeSeriesBatch(startCadence, endCadence, map);
            rv.add(batch);
        }
        
        return rv;
    }

    @Override
    public List<TimeSeriesBatch> readTimeSeriesBatch(final List<FsIdSet> fsIdSet,
        final boolean existsError) {


        List<TimeSeriesBatch> rv = new ImplicitTransactionLifecycle<List<TimeSeriesBatch>>(this) {
            @Override
            protected List<TimeSeriesBatch> doit() {
                return FstpClient.super.readTimeSeriesBatch(fsIdSet, existsError);
            }
        }.execute();

        if (this.countersEnabled) {
            for (TimeSeriesBatch batch : rv) {
                timeSeriesRead.addAll(batch.timeSeries().keySet());
            }
        }
        
        return rv;
    }


    @Override
    protected String protocolMethodNameReadMjdTimeSeriesBatch() {
        return READ_CR_BATCH.name();
    }

    @Override
    protected List<MjdTimeSeriesBatch> returnReadMjdTimeSeriesBatch(
        DataInputStream din, BinaryPersistableInputStream pin) throws Exception {

        final int nBatches = din.readInt();
        List<MjdTimeSeriesBatch> rv = new ArrayList<MjdTimeSeriesBatch>(nBatches);
        for (int batchi=0; batchi < nBatches; batchi++) {
            final double startMjd = din.readDouble();
            final double endMjd = din.readDouble();
            final int nSeries = din.readInt();
            Map<FsId, FloatMjdTimeSeries> series = new HashMap<FsId, FloatMjdTimeSeries>(nSeries);
            for (int seriesi=0; seriesi < nSeries; seriesi++) {
                FloatMjdTimeSeries s = FloatMjdTimeSeries.readFrom(din);
                series.put(s.id(), s);
            }
            MjdTimeSeriesBatch batch = 
                new MjdTimeSeriesBatch(startMjd, endMjd, series);
            rv.add(batch);
        }
        
        return rv;
    }
    
    @Override
    public List<MjdTimeSeriesBatch> readMjdTimeSeriesBatch(List<MjdFsIdSet> mjdFsIdSet) 
        {
        
        boolean rollback = false;
        if (xidThreadLocal.xid().isNullTransaction()) {
            beginLocalFsTransaction();
            rollback = true;
        }
        
        List<MjdTimeSeriesBatch> rv = null;
        try {
            rv = super.readMjdTimeSeriesBatch(mjdFsIdSet);
        } finally {
            if (rollback) {
                rollbackLocalFsTransaction();
            }
        }
        
        if (this.countersEnabled) {
            for (MjdTimeSeriesBatch batch : rv) {
                timeSeriesRead.addAll(batch.timeSeries().keySet());
            }
        }
        return rv;
    }

    @Override
    protected void encodeRequestReadMjdTimeSeriesBatch(DataOutputStream dout,
        BinaryPersistableOutputStream pout, List<MjdFsIdSet> list1)
        throws Exception {

        dout.writeInt(list1.size());
        for (MjdFsIdSet mjdFsIdSet : list1) {
            mjdFsIdSet.writeTo(dout);
        }
    }

    @Override
    protected String protocolMethodNameReadAllTimeSeriesAsDouble() {
        return READ_DOUBLE_ALL_TS.name();
    }

    @Override
    protected String protocolMethodNameReadTimeSeriesAsDouble() {
        return READ_DOUBLE_TS.name();
    }

    @Override
    public DoubleTimeSeries[] readAllTimeSeriesAsDouble(final FsId[] ids, final boolean existsError)
        {
        if (countersEnabled) {
            timeSeriesRead.addAll(Arrays.asList(ids));
        }
        
        return new ImplicitTransactionLifecycle<DoubleTimeSeries[]>(this) {
            @Override
            protected DoubleTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                DoubleTimeSeries[] ordered = (DoubleTimeSeries[])
                    reorder(FstpClient.super.readAllTimeSeriesAsDouble(ids, existsError),fsIdToOrder);
                return ordered;
            }
        }.execute();
    }
    
    @Override
    protected DoubleTimeSeries[] returnReadAllTimeSeriesAsDouble(
        DataInputStream din, BinaryPersistableInputStream pin) throws Exception {

        return (DoubleTimeSeries[]) returnReadTimeSeries(din, pin, DoubleTimeSeries.class);
    }

    @Override
    public DoubleTimeSeries[] readTimeSeriesAsDouble(final FsId[] ids, 
        final int startCadence, final int endCadence, final boolean existsError)
        {
        
        if (countersEnabled) {
            timeSeriesRead.addAll(Arrays.asList(ids));
        }
        
        return new ImplicitTransactionLifecycle<DoubleTimeSeries[]>(this) {
            @Override
            protected DoubleTimeSeries[] doit() {
                TObjectIntHashMap<FsId> fsIdToOrder = buildFsIdOrder(ids);
                DoubleTimeSeries[] ordered = (DoubleTimeSeries[])
                    reorder(FstpClient.super.readTimeSeriesAsDouble(ids, startCadence, 
                        endCadence, existsError),fsIdToOrder);
                return ordered;
            }
        }.execute();

    }
    
    @Override
    protected DoubleTimeSeries[] returnReadTimeSeriesAsDouble(
        DataInputStream din, BinaryPersistableInputStream pin) throws Exception {

        return (DoubleTimeSeries[]) returnReadTimeSeries(din, pin, DoubleTimeSeries.class);
    }

    @Override
    public Map<FsId, TimeSeries> readTimeSeries(Collection<FsId> fsIds,
        int startCadence, int endCadence, boolean existsError) {

        if (fsIds == null) {
            throw new NullPointerException("fsIds");
        }
        
        if (fsIds.isEmpty()) {
            return Collections.emptyMap();
        }
        
        Set<FsId> fsIdsAsSet = null;
        if (fsIds instanceof Set) {
            fsIdsAsSet = (Set<FsId>) fsIds;
        } else {
            fsIdsAsSet = new HashSet<FsId>(fsIds);
        }
        List<FsIdSet> singleSet = 
            Collections.singletonList(new FsIdSet(startCadence, endCadence, fsIdsAsSet));
        List<TimeSeriesBatch> batch = this.readTimeSeriesBatch(singleSet, existsError);
        if (batch.size() != 1) {
            throw new IllegalStateException("Expected only one batch returned, but got " + batch.size() + ".");
        }
        return batch.get(0).timeSeries();
    }

    @Override
    public Map<FsId, FloatMjdTimeSeries> readMjdTimeSeries(Collection<FsId> fsIds, double startMjd, double endMjd) {
        if (fsIds == null) {
            throw new NullPointerException("fsIds");
        }
        
        if (fsIds.isEmpty()) {
            return Collections.emptyMap();
        }
        
        Set<FsId> fsIdsAsSet = null;
        if (fsIds instanceof Set) {
            fsIdsAsSet = (Set<FsId>) fsIds;
        } else {
            fsIdsAsSet = new HashSet<FsId>(fsIds);
        }
        
        List<MjdFsIdSet> singleSet = 
            Collections.singletonList(new MjdFsIdSet(startMjd, endMjd, fsIdsAsSet));
        List<MjdTimeSeriesBatch> batch = this.readMjdTimeSeriesBatch(singleSet);
        if (batch.size() != 1) {
            throw new IllegalStateException("Expected only one batch returned, but got " + batch.size() + "\n");
        }
        
        return batch.get(0).timeSeries();
    }

    @Override
    public boolean isStreamOpen() {
        return streamInUse.get();
    }

}
