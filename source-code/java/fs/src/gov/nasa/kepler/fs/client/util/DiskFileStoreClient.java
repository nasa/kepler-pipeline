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

package gov.nasa.kepler.fs.client.util;

import static gov.nasa.kepler.fs.FileStoreConstants.DISK_FILE_STORE_READ_ROOT_DEFAULT;
import static gov.nasa.kepler.fs.FileStoreConstants.DISK_FILE_STORE_READ_ROOT_PROPERTY;
import static gov.nasa.kepler.fs.FileStoreConstants.DISK_FILE_STORE_WRITE_ROOT_DEFAULT;
import static gov.nasa.kepler.fs.FileStoreConstants.DISK_FILE_STORE_WRITE_ROOT_PROPERTY;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_DATA_DIR_PROPERTY;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MixedTypeException;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.StreamedBlobResult;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.LocalTransactionalResource;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileFind;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This implementation of {@code gov.nasa.kepler.fs.api.FileStoreClient} stores
 * objects immediately to disk and, when possible, in a textual representation.
 * It also performs record-keeping by tracking which objects are read and
 * written.
 * 
 * @author Forrest Girouard (Forrest.Girouard@nasa.gov)
 * @author Sean McCauliff
 * 
 */
public class DiskFileStoreClient implements FileStoreClient,
    FileStoreTestInterface, LocalTransactionalResource {
    private static final Log log = LogFactory.getLog(DiskFileStoreClient.class);

    public static final String BLOBS_DIR = "blobs";
    public static final String TIMESERIES_DIR = "ts";
    public static final String MJD_TIMESERIES_DIR = "mts"; 
    
    private ThreadLocal<TransactionState> transactionState = new ThreadLocal<TransactionState>() {

        @Override
        protected TransactionState initialValue() {
            return TransactionState.INITIAL;
        }
    };
    private boolean throwAwayWrites = false;

    private File readRoot;
    private File writeRoot;

    // keeps a record of what is read and written
    private List<FsId> blobsRead = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> blobsWritten = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> timeSeriesRead = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> timeSeriesWritten = Collections.synchronizedList(new ArrayList<FsId>());
    private List<FsId> mjdTimeSeriesWritten = Collections.synchronizedList(new ArrayList<FsId>());

    private boolean allowOverwrite = false;

    public DiskFileStoreClient() {
        init(getConfiguredReadRoot(), getConfiguredWriteRoot(), false);
    }

    public DiskFileStoreClient(File readRoot, File writeRoot)
        {
        this(readRoot, writeRoot, false);
    }

    public DiskFileStoreClient(String readRoot, String writeRoot)
        {
        this(new File(readRoot), new File(writeRoot), false);
    }

    public DiskFileStoreClient(boolean clean) {
        init(getConfiguredReadRoot(), getConfiguredWriteRoot(), clean);
    }

    public DiskFileStoreClient(File readRoot, File writeRoot, boolean clean)
        {

        init(readRoot, writeRoot, clean);
    }

    /**
     * Returns the path to the root of the currently configured file
     * store.
     * 
     * @param defaultFsRoot
     * @return path to file store root
     */
    private static String getDefaultFsRoot(String defaultFsRoot) {

        Configuration config = ConfigurationServiceFactory.getInstance();
        String fsRoot = config.getString(FS_DATA_DIR_PROPERTY, defaultFsRoot);

        return fsRoot;
    }

    /**
     * Returns the {@code File} for the read root of the currently configured
     * file store.
     * 
     * @return
     */
    private static File getConfiguredReadRoot() {

        Configuration config = ConfigurationServiceFactory.getInstance();
        String readRootStr = config.getString(
            DISK_FILE_STORE_READ_ROOT_PROPERTY,
            getDefaultFsRoot(DISK_FILE_STORE_READ_ROOT_DEFAULT));
        return new File(readRootStr);
    }

    /**
     * Returns the {@code File} for the write root of the currently configured
     * file store.
     * 
     * @return
     */
    private static File getConfiguredWriteRoot() {

        Configuration config = ConfigurationServiceFactory.getInstance();
        String writeRootStr = config.getString(
            DISK_FILE_STORE_WRITE_ROOT_PROPERTY,
            getDefaultFsRoot(DISK_FILE_STORE_WRITE_ROOT_DEFAULT));
        return new File(writeRootStr);
    }

    private void init(File readRoot, File writeRoot, boolean clean) {

        if (readRoot == null && writeRoot == null) {
            throw new NullPointerException("both read and write roots are null");
        }
    if (log.isInfoEnabled()) {
        log.info(String.format("Initializing disk file store client:"
            + "readRoot=%s, writeRoot=%s, clean=%s",
            readRoot, writeRoot, clean));
        }

        if (readRoot != null) {
            checkRoot(readRoot);
            if (!readRoot.canRead()) {
                throw new IllegalArgumentException(readRoot
                    + ": must be readable.");
            }
        }
        this.readRoot = readRoot;

        if (writeRoot != null) {
            checkRoot(writeRoot);
            if (!writeRoot.canWrite()) {
                throw new IllegalArgumentException(writeRoot
                    + ": must be writable.");
            }
            if (clean) {
                cleanFileStore();
            }
        }
        this.writeRoot = writeRoot;
    }

    public boolean doesAllowOverwrite() {
        return allowOverwrite;
    }

    public void setAllowOverwrite(boolean allow) {
        allowOverwrite = allow;
    }

    // TransactionClient

    public synchronized Xid beginLocalFsTransaction() {

        getLog().debug(this.getClass()
            .getName() + ": begin transaction");
        setTransactionState(TransactionState.STARTED);
        return PersistableXid.newNullTransaction();
    }

    @Override
    public synchronized void commitLocalFsTransaction()
        {

        if (localTransactionState() != TransactionState.STARTED) {
            throw new FileStoreException("no active transaction");
        }
        getLog().debug(this.getClass()
            .getName() + ": commit transaction");
        setTransactionState(TransactionState.COMMITTED);
    }

    @Override
    public synchronized void rollbackLocalFsTransaction()
        {

        if (localTransactionState() != TransactionState.STARTED) {
            throw new FileStoreException("no active transaction");
        }
        getLog().debug(this.getClass()
            .getName() + ": rollback transaction");
        setTransactionState(TransactionState.ROLLEDBACK);
    }

    @Override
    public synchronized void rollbackLocalFsTransactionIfActive() {

        if (localTransactionState() == TransactionState.STARTED) {
            getLog().debug(this.getClass()
                .getName() + ": rollback transaction");
            setTransactionState(TransactionState.ROLLEDBACK);
        }
    }
    
    @Override
    public synchronized boolean localTransactionIsActive() {
        return localTransactionState() == TransactionState.STARTED;
    }

    // BlobClient

    public synchronized boolean blobExists(FsId id) {

        if (readRoot == null) {
            throw new IllegalStateException("write-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }

        String filePath = BLOBS_DIR + id.toString();
        File file = new File(readRoot, filePath);

        return file.exists();
    }

    public synchronized OutputStream writeBlob(FsId id, long origin) {
        throw new IllegalStateException("method not implemented.");
    }

    public synchronized long readBlob(FsId id, File dest)
        {

        StreamedBlobResult result = readBlobAsStream(id);
        InputStream inputStream = result.stream();
        OutputStream outputStream = null;
        try {
            outputStream = new FileOutputStream(dest);
            IOUtils.copy(inputStream, outputStream);
        } catch (IOException ioe) {
            throw new FileStoreException(dest + ": write blob to file failed.",
                ioe);
        } finally {
            FileUtil.close(inputStream);
            FileUtil.close(outputStream);
        }
        return result.originator();
    }

    public synchronized void writeBlob(FsId id, long origin, File src)
        {
        boolean ok = false;

        try {
            try {
                File destFile = checkBlobWrite(id, origin);
                if (!isThrowAwayWrites()) {
                    FileUtil.copyFiles(src, destFile);
                }
                blobsWritten.add(id);
                ok = true;
            } catch (IOException e) {
                throw new FileStoreException("Failed to write blob \"" + id
                    + "\".", e);
            }
        } finally {
            if (!ok) {
                log.error("Unable to write blob \"" + id + "\".");
            }
        }
    }

    private File checkBlobWrite(FsId blobId, long origin) throws IOException {
        String destFileDirName = BLOBS_DIR + blobId.toString();
        File destFileDir = new File(writeRoot, destFileDirName);

        if (destFileDir.exists() && !allowOverwrite) {
            throw new FileStoreException(destFileDir + ": already exists.");
        }

        if (destFileDir.exists()) {
            FileUtils.deleteDirectory(destFileDir);
        }

        destFileDir.mkdirs();
        File destFile = new File(destFileDir, Long.toString(origin));

        return destFile;
    }

    public synchronized StreamedBlobResult readBlobAsStream(FsId id)
        {

        if (readRoot == null) {
            throw new IllegalStateException("write-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }

        String filePath = BLOBS_DIR + id.toString();
        File file = new File(readRoot, filePath);
        if (!file.exists()) {
            throw new FileStoreException(file + ": does not exist.");
        }

        long originator = 0L;
        if (file.isDirectory()) {
            String[] blobs = file.list();
            if (blobs.length == 1) {
                file = new File(file, blobs[0]);
                originator = Long.parseLong(blobs[0]);
            } else {
                throw new FileStoreException(file
                    + ": unexpected blob contents.");
            }
        }

        InputStream inputStream = null;
        try {
            inputStream = new BufferedInputStream(new FileInputStream(file));
        } catch (IOException ioe) {
            FileUtil.close(inputStream);
            throw new FileStoreException(file + ": read blob file failed.", ioe);
        }
        return new StreamedBlobResult(originator, file.length(), inputStream);
    }

    public synchronized BlobResult readBlob(FsId id) {

        StreamedBlobResult streamedBlobResult = readBlobAsStream(id);
        InputStream stream = streamedBlobResult.stream();
        byte[] contents = null;
        try {
            int length = stream.available();
            int bytesRead = 0;
            boolean eof = false;
            contents = new byte[length];
            while (bytesRead < length && !eof) {
                int read = stream.read(contents, bytesRead, length - bytesRead);
                if (read == 0) {
                    eof = true;
                } else {
                    bytesRead += read;
                }
            }
            if (bytesRead == length) {
                getBlobsRead().add(id);
            } else {
                throw new FileStoreException(id
                    + ": failed to read blob fully.");
            }
        } catch (IOException ioe) {
            throw new FileStoreException(id + ": read blob file failed.", ioe);
        } finally {
            FileUtil.close(stream);
        }
        return new BlobResult(streamedBlobResult.originator(), contents);
    }

    public synchronized void writeBlob(FsId id, long origin, byte[] fileData)
        {

        if (writeRoot == null) {
            throw new IllegalStateException("read-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }
        if (fileData == null) {
            throw new NullPointerException("fileData must not be null.");
        }

        File destFile = null;

        FileOutputStream stream = null;
        try {
            destFile = checkBlobWrite(id, origin);
            if (!isThrowAwayWrites()) {
                stream = new FileOutputStream(destFile);
                stream.write(fileData);
            }
            getBlobsWritten().add(id);
        } catch (IOException ioe) {
            throw new FileStoreException(
                destFile + ": write blob file failed.", ioe);
        } finally {
            FileUtil.close(stream);
        }
    }

    // TimeSeriesClient

    public synchronized IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] ids)
        {
        return readAllTimeSeriesAsInt(ids, true);
    }

    public synchronized IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] ids,
        boolean existsError) {

        if (ids == null) {
            throw new NullPointerException("ids must not be null.");
        }

        IntTimeSeries[] timeSeries = new IntTimeSeries[ids.length];
        for (int i = 0; i < ids.length; i++) {
            if (timeSeriesExists(ids[i])) {
                timeSeries[i] = readTimeSeriesAsInt(ids[i]);
            } else {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(ids[i],
                        timeSeriesExistsReason(ids[i]));
                }
                timeSeries[i] = (IntTimeSeries) emptySeries(ids[i], false, -1,
                    -1, false, false);
            }
        }
        return timeSeries;

    }

    public synchronized IntTimeSeries[] readTimeSeriesAsInt(FsId[] ids,
        int startCadence, int endCadence) {
        return readTimeSeriesAsInt(ids, startCadence, endCadence, true);
    }

    public synchronized IntTimeSeries[] readTimeSeriesAsInt(FsId[] ids,
        int startCadence, int endCadence, boolean existsError)
        {

        if (ids == null) {
            throw new NullPointerException("ids must not be null.");
        }
        if (ids.length == 0) {
            throw new IllegalArgumentException("ids must not be zero length.");
        }

        IntTimeSeries[] timeSeries = new IntTimeSeries[ids.length];
        for (int i = 0; i < ids.length; i++) {
            if (timeSeriesExists(ids[i])) {
                timeSeries[i] = readTimeSeries(ids[i], startCadence,
                    endCadence, IntTimeSeries.class);
            } else {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(ids[i],
                        timeSeriesExistsReason(ids[i]));
                }
                timeSeries[i] = (IntTimeSeries) emptySeries(ids[i], true,
                    startCadence, endCadence, false, false);
            }
        }
        return timeSeries;
    }

    public synchronized FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] ids)
        {
        return readAllTimeSeriesAsFloat(ids, true);
    }

    public synchronized FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] ids,
        boolean existsError) {

        if (ids == null) {
            throw new NullPointerException("ids must not be null.");
        }

        FloatTimeSeries[] timeSeries = new FloatTimeSeries[ids.length];
        for (int i = 0; i < ids.length; i++) {
            if (timeSeriesExists(ids[i])) {
                timeSeries[i] = readTimeSeriesAsFloat(ids[i]);
            } else {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(ids[i],
                        timeSeriesExistsReason(ids[i]));
                }
                timeSeries[i] = (FloatTimeSeries) emptySeries(ids[i], false,
                    -1, -1, true, false);
            }
        }
        return timeSeries;

    }

    public synchronized FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] ids,
        int startCadence, int endCadence) {
        return readTimeSeriesAsFloat(ids, startCadence, endCadence, true);
    }

    public synchronized FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] ids,
        int startCadence, int endCadence, boolean existsError)
        {

        if (ids == null) {
            throw new NullPointerException("ids must not be null.");
        }

        FloatTimeSeries[] timeSeries = new FloatTimeSeries[ids.length];
        for (int i = 0; i < ids.length; i++) {
            if (timeSeriesExists(ids[i])) {
                timeSeries[i] = readTimeSeriesAsFloat(ids[i], startCadence,
                    endCadence);
            } else {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(ids[i],
                        timeSeriesExistsReason(ids[i]));
                }
                timeSeries[i] = (FloatTimeSeries) emptySeries(ids[i], true,
                    startCadence, endCadence, true, false);
            }
        }
        return timeSeries;
    }

    public synchronized void writeTimeSeries(TimeSeries[] ts, boolean overwrite)
        {

        if (writeRoot == null) {
            throw new IllegalStateException("read-only file store");
        }
        if (ts == null) {
            throw new NullPointerException("ts must not be null.");
        }
        if (!overwrite) {
            log.warn("overwrite=false not supported.");
        }

        for (TimeSeries timeSeries : ts) {
            writeTimeSeries(timeSeries);
        }
    }

    public synchronized void writeTimeSeries(TimeSeries[] ts) {
        writeTimeSeries(ts, true);
    }

    public synchronized Set<FsId> getIdsForSeries(FsId path) {

        String basePath = path.path();
        Set<FsId> fsIds = new HashSet<FsId>();
        File readRoot = new File(getReadRoot(), basePath);
        File writeRoot = new File(getWriteRoot(), basePath);

        DirectoryWalker readWalker = null;
        if (readRoot.exists()) {
            readWalker = new DirectoryWalker(readRoot);
        }

        DirectoryWalker writeWalker = null;
        if (!readRoot.equals(writeRoot) && writeRoot.exists()) {
            writeWalker = new DirectoryWalker(writeRoot);
        }

        FileFind fileVisitor = new FileFind(".*");
        try {
            if (readWalker != null) {
                readWalker.traverse(fileVisitor);
            }
            if (writeWalker != null) {
                writeWalker.traverse(fileVisitor);
            }
        } catch (IOException ioe) {
            throw new FileStoreException(ioe.getMessage());
        }
        List<File> files = fileVisitor.found();
        if (files != null) {
            for (File file : files) {
                if (file.isFile()) {
                    if (file.getPath()
                        .startsWith(basePath)) {
                        fsIds.add(new FsId(file.getPath()
                            .substring(basePath.length())));
                    } else {
                        log.warn(String.format("unexpected FsId: %s",
                            file.getPath()));
                    }
                }
            }
        }
        return fsIds;
    }

    public synchronized List<Interval>[] getCadenceIntervalsForId(FsId[] ids) {
        throw new IllegalStateException("method not implemented.");
    }

    // XAResource

    /**
     * This does nothing.
     */
    public void initialize(TransactionService xService) {
    }

    public XAResource getXAResource() {
        throw new IllegalStateException("method not implemented.");
    }

    // FileStoreTestInterface

    /**
     * This removes all file store objects created by this client. This will not
     * be enabled by default. This may take some time to complete.
     * 
     * @throws FileStoreException If this is not implemented or if the operation
     * could not complete.
     */
    public synchronized void cleanFileStore() {

        getBlobsRead().clear();
        getBlobsWritten().clear();
        getTimeSeriesRead().clear();
        getTimeSeriesWritten().clear();
        setTransactionState(TransactionState.INITIAL);

        if (writeRoot != null) {
            try {
                FileUtils.cleanDirectory(writeRoot);
            } catch (IOException ioe) {
                throw new FileStoreException(writeRoot
                    + ": clean write root failed.", ioe);
            }
        }
    }
    
    /**
     * This does nothing.  Counters are always enabled for the DiskFileStoreClient.
     */
    @Override
    public synchronized void setEnableFsIdCounters(boolean enable) {
        
    }

    /**
     * Return true if the specified time series file store object exists and
     * false otherwise.
     * 
     * @param id
     * @return true if time series exists and false otherwise.
     * @throws FileStoreException If not implemented or operation could not
     * complete successfully.
     */
    public synchronized boolean timeSeriesExists(FsId id)
        {

        if (readRoot == null) {
            throw new IllegalStateException("write-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }

        TimeSeries timeSeries = null;
        String filePath = TIMESERIES_DIR + id.toString();
        File file = new File(readRoot, filePath);
        if (file.exists()) {
            timeSeries = readTimeSeries(id);
            return timeSeries.exists();
        }
        return false;
    }

    /**
     * Return true if the specified mjd time series file store object exists and
     * false otherwise.
     * 
     * @param id
     * @return true if time series exists and false otherwise.
     * @throws FileStoreException If not implemented or operation could not
     * complete successfully.
     */
    public synchronized boolean mjdTimeSeriesExists(FsId id)
        {

        if (readRoot == null) {
            throw new IllegalStateException("write-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }
        String filePath = MJD_TIMESERIES_DIR + id.toString();
        File file = new File(readRoot, filePath);
        return file.exists();
    }

    /**
     * This returns a string that explains why a time series does not exist.
     * Reasons include: the file does not exist, the file is not readable, or
     * the file contains just filler.
     * 
     * @param id the fsid
     * @return a string
     */
    public synchronized String timeSeriesExistsReason(FsId id) {
        String filePath = TIMESERIES_DIR + id.toString();
        File file = new File(readRoot, filePath);
        if (!file.exists()) {
            return file.getAbsolutePath() + " does not exist";
        }
        if (!file.canRead()) {
            return "Can not read " + file.getAbsolutePath();
        }
        if (!readTimeSeries(id).exists()) {
            return "Time series exists flag for " + id.toString() + " is false";
        }

        return "Time series for " + id.toString() + " exists";
    }

    public synchronized Map<FsId, TimeSeries> getTimeSeries()
        {

        Map<FsId, TimeSeries> allTimeSeries = new HashMap<FsId, TimeSeries>();
        List<FsId> fsIds = getTimeSeriesWritten();
        for (FsId fsId : fsIds) {
            allTimeSeries.put(fsId, readTimeSeries(fsId));
        }
        return allTimeSeries;
    }

    public synchronized FloatMjdTimeSeries[] readMjdTimeSeries(FsId[] ids,
        double startMjd, double endMjd) {

        if (ids == null) {
            throw new NullPointerException("ids must not be null.");
        }

        FloatMjdTimeSeries[] timeSeries = new FloatMjdTimeSeries[ids.length];
        for (int i = 0; i < ids.length; i++) {
            FsId id = ids[i];
            if (mjdTimeSeriesExists(ids[i])) {
                timeSeries[i] = readMjdTimeSeries(id, startMjd, endMjd, true);
            } else {
                timeSeries[i] = FloatMjdTimeSeries.emptySeries(id, startMjd,
                    endMjd, false);
            }
        }
        return timeSeries;
    }

    public synchronized void writeMjdTimeSeries(FloatMjdTimeSeries[] series) {
        for (FloatMjdTimeSeries s : series) {
            writeMjdTimeSeries(s);
        }
    }

    public synchronized Set<FsId> listMjdTimeSeries(FsId prefix) {
        throw new IllegalStateException(
            "DiskFileStoreClient has not implemented this method.");
    }

    public synchronized FloatMjdTimeSeries[] readAllMjdTimeSeries(FsId[] ids) {
        return readMjdTimeSeries(ids, 0.0, Double.MAX_VALUE);
    }

    /**
     * This does nothing.
     */
    public void disassociateThread() {
    }

    @Override
    public synchronized void deleteBlob(FsId id) {
        delete(id, BLOBS_DIR, "blob");
    }

    @Override
    public synchronized void deleteTimeSeries(FsId[] ids)
        {
        for (FsId id : ids) {
            delete(id, TIMESERIES_DIR, "time series");
        }
    }

    @Override
    public synchronized void deleteMjdTimeSeries(FsId[] ids)
        {
        for (FsId id : ids) {
            delete(id, MJD_TIMESERIES_DIR, "mjd time series");
        }
    }

    // LocalTransactionalResource

    public void beginLocalTransaction() {
        beginLocalFsTransaction();
    }

    public void rollbackLocalTransactionIfActive() {
        rollbackLocalFsTransactionIfActive();
    }

    public void commitLocalTransaction() {
        commitLocalFsTransaction();
    }

    // getters/setters

    public static Log getLog() {
        return log;
    }

    public List<FsId> getBlobsRead() {
        return blobsRead;
    }

    public List<FsId> getBlobsWritten() {
        return blobsWritten;
    }

    public File getReadRoot() {
        return readRoot;
    }

    public boolean isThrowAwayWrites() {
        return throwAwayWrites;
    }

    public void setThrowAwayWrites(boolean throwAwayWrites) {
        this.throwAwayWrites = throwAwayWrites;
    }

    public List<FsId> getTimeSeriesRead() {
        return timeSeriesRead;
    }

    public List<FsId> getTimeSeriesWritten() {
        return timeSeriesWritten;
    }

    public List<FsId> getMjdTimeSeriesWritten() {
        return mjdTimeSeriesWritten;
    }

    public File getWriteRoot() {
        return writeRoot;
    }

    // internal

    private void setTransactionState(TransactionState transactionState) {
        this.transactionState.set(transactionState);
    }

    /**
     * Read the specified integer time series returning data from the first
     * known value to through the last known value, inclusive.
     * 
     * @param id
     * @return integer time series for known value range
     * @throws FileStoreException If not implemented or operation could not
     * complete successfully.
     */
    private IntTimeSeries readTimeSeriesAsInt(FsId id)
        {
        return readTimeSeries(id, TimeSeries.NOT_EXIST_CADENCE,
            TimeSeries.NOT_EXIST_CADENCE, IntTimeSeries.class);
    }

    /**
     * Read the specified float time series returning data from the first known
     * value to through the last known value, inclusive.
     * 
     * @param id
     * @return float time series for known value range
     * @throws FileStoreException If not implemented or operation could not
     * complete successfully.
     */
    private FloatTimeSeries readTimeSeriesAsFloat(FsId id)
        {

        return readTimeSeries(id, TimeSeries.NOT_EXIST_CADENCE,
            TimeSeries.NOT_EXIST_CADENCE, FloatTimeSeries.class);
    }

    private TimeSeries readTimeSeries(FsId id) {
        return readTimeSeries(id, TimeSeries.NOT_EXIST_CADENCE,
            TimeSeries.NOT_EXIST_CADENCE);
    }

    private TimeSeries readTimeSeries(FsId id, int startCadence, int endCadence)
        {

        if (readRoot == null) {
            throw new IllegalStateException("write-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }
        if (startCadence != TimeSeries.NOT_EXIST_CADENCE && startCadence < 0
            || endCadence != TimeSeries.NOT_EXIST_CADENCE && endCadence < 0
            || startCadence > endCadence) {
            throw new IllegalArgumentException("invalid cadence values.");
        }

        TimeSeries timeSeries = null;
        String filePath = TIMESERIES_DIR + id.toString();
        File file = new File(readRoot, filePath);
        if (!file.exists()) {
            throw new FileStoreIdNotFoundException(id);
        }

        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(file));
            timeSeries = TimeSeries.fromPipeString(reader.readLine());
        } catch (IOException ioe) {
            throw new FileStoreException(file + ": read time series failed.",
                ioe);
        } finally {
            FileUtil.close(reader);
        }

        if (startCadence != TimeSeries.NOT_EXIST_CADENCE
            && timeSeries.startCadence() != startCadence) {
            throw new FileStoreException(String.format(
                "%s: requested start cadence %d, but time series starts at %d",
                id, startCadence, timeSeries.startCadence()));
        }
        if (endCadence != TimeSeries.NOT_EXIST_CADENCE
            && timeSeries.endCadence() != endCadence) {
            throw new FileStoreException(String.format(
                "%s: requested end cadence %d, but time series ends with %d",
                id, endCadence, timeSeries.endCadence()));
        }
        return timeSeries;
    }

    private <T extends TimeSeries> T readTimeSeries(FsId id, int startCadence,
        int endCadence, Class<T> timeSeriesClass) {

        @SuppressWarnings("unchecked")
        T timeSeries = (T) readTimeSeries(id, startCadence, endCadence);
        getTimeSeriesRead().add(id);
        if (!timeSeriesClass.isAssignableFrom(timeSeries.getClass())) {
            throw new MixedTypeException("expected "+ timeSeriesClass + 
                " time series but found " + timeSeries.getClass(), id);
        }
        return timeSeries;
    }

    private FloatTimeSeries readTimeSeriesAsFloat(FsId id, int startCadence,
        int endCadence) {

        FloatTimeSeries floatTimeSeries = null;
        TimeSeries timeSeries = readTimeSeries(id, startCadence, endCadence);
        getTimeSeriesRead().add(id);
        if (timeSeries instanceof FloatTimeSeries) {
            floatTimeSeries = (FloatTimeSeries) timeSeries;
        } else {
            throw new MixedTypeException("expected float time series.", id);
        }
        return floatTimeSeries;
    }

    private void writeTimeSeries(TimeSeries timeSeries)
        {

        if (writeRoot == null) {
            throw new IllegalStateException("read-only file store");
        }

        String filePath = TIMESERIES_DIR + timeSeries.id()
            .toString();
        File file = new File(writeRoot, filePath);
        if (file.exists() && !allowOverwrite) {
            log.warn(file + ": already exists.");
        }

        file.getParentFile()
            .mkdirs();

        BufferedWriter writer = null;
        try {
            if (!isThrowAwayWrites()) {
                writer = new BufferedWriter(new FileWriter(file));
                writer.write(timeSeries.toPipeString());
            }
            getTimeSeriesWritten().add(timeSeries.id());
        } catch (IOException ioe) {
            throw new FileStoreException(file + ": write time series failed.",
                ioe);
        } finally {
            FileUtil.close(writer);
        }
    }

    /**
     * Creates an empty TimeSeries entry
     * 
     */
    private TimeSeries emptySeries(FsId id, boolean useDefaults,
        int startCadence, int endCadence, boolean isfloat, boolean exists) {

        int size = endCadence - startCadence + 1;
        List<TaggedInterval> originators = Collections.emptyList();
        List<SimpleInterval> validCandences = Collections.emptyList();
        int start = useDefaults ? startCadence : -1;
        int end = useDefaults ? endCadence : -1;
        if (isfloat) {
            float[] floatData = useDefaults ? new float[size] : new float[0];
            return new FloatTimeSeries(id, floatData, start, end,
                validCandences, originators, exists);
        }

        int[] intData = useDefaults ? new int[size] : new int[0];
        return new IntTimeSeries(id, intData, start, end, validCandences,
            originators, exists);
    }

    private void checkRoot(File root) {

        if (!root.exists()) {
            try {
                FileUtil.mkdirs(root);
            } catch (IOException e) {
                throw new IllegalArgumentException(root
                    + ": does not exist and attempt to create it failed.");
            }
        }
        if (!root.isDirectory()) {
            throw new IllegalArgumentException(root + ": must be a directory.");
        }
    }

    private void writeMjdTimeSeries(FloatMjdTimeSeries timeSeries)
        {

        if (writeRoot == null) {
            throw new IllegalStateException("read-only file store");
        }

        String filePath = MJD_TIMESERIES_DIR + timeSeries.id()
            .toString();
        File file = new File(writeRoot, filePath);
        if (file.exists() && !allowOverwrite) {
            log.warn(file + ": already exists.");
        }

        file.getParentFile()
            .mkdirs();

        BufferedWriter writer = null;
        try {
            if (!isThrowAwayWrites()) {
                writer = new BufferedWriter(new FileWriter(file));
                writer.write(timeSeries.toPipeString());
            }
            getMjdTimeSeriesWritten().add(timeSeries.id());
        } catch (IOException ioe) {
            throw new FileStoreException(file
                + ": write mjd time series failed.", ioe);
        } finally {
            FileUtil.close(writer);
        }
    }

    public gov.nasa.kepler.fs.api.FileStoreTestInterface.TransactionState localTransactionState() {
        return transactionState.get();
    }

    private FloatMjdTimeSeries readMjdTimeSeries(FsId id, double startMjd,
        double endMjd, boolean useQueryTimes) {

        if (readRoot == null) {
            throw new IllegalStateException("write-only file store");
        }
        if (id == null) {
            throw new NullPointerException("id must not be null.");
        }

        if (startMjd > endMjd) {
            throw new IllegalArgumentException("Start mjd " + startMjd
                + " comes after end mjd " + endMjd + ".");
        }

        FloatMjdTimeSeries timeSeries = null;
        String filePath = MJD_TIMESERIES_DIR + id.toString();
        File file = new File(readRoot, filePath);
        if (!file.exists()) {
            throw new FileStoreException(id + ": does not exist.");
        }

        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(file));
            timeSeries = FloatMjdTimeSeries.fromPipeString(reader.readLine());

            if (timeSeries.startMjd() < startMjd
                || timeSeries.endMjd() > endMjd) {
                throw new IllegalStateException(
                    "DiskFileStore can not query subsets of mjd time series.");
            }
        } catch (IOException ioe) {
            throw new FileStoreException(file + ": read time series failed.",
                ioe);
        } finally {
            FileUtil.close(reader);
        }

        if (useQueryTimes) {
            // Set start end times to match the absolute start end times.
            timeSeries = new FloatMjdTimeSeries(id, startMjd, endMjd,
                timeSeries.mjd(), timeSeries.values(),
                timeSeries.originators(), true);
        }

        return timeSeries;
    }

    private void delete(FsId id, String rootDir, String typeName) {
        File f = new File(rootDir + id.toString());
        if (!f.exists()) {
            return;
        }
        if (!f.delete()) {
            throw new FileStoreException("Can not delete " + typeName + " \""
                + f + "\".");
        }
    }

    /**
     * This does nothing.
     */
    @Override
    public void ping() {
        // Nothing.
    }

    @Override
    public Set<FsId> queryIds(String queryString) {
        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public Set<FsId> queryPaths(String queryString) {
        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public void writeMjdTimeSeries(FloatMjdTimeSeries[] series,
        boolean overwrite) {

        writeMjdTimeSeries(series);
        
    }

    @Override
    public void close() {
        //This does nothing
    }
    
    @Override
    public Xid xidForCurrentThread() {
        return null;
    }

    @Override
    public synchronized List<TimeSeriesBatch> readTimeSeriesBatch(List<FsIdSet> fsIdSet, boolean existsError)
        {

        List<TimeSeriesBatch> rv = new ArrayList<TimeSeriesBatch>(fsIdSet.size());
        for (FsIdSet idSet : fsIdSet) {
            rv.add(readTimeSeriesSet(idSet, existsError));
        }
        return rv;
    }
    
    @SuppressWarnings("unchecked")
    private TimeSeriesBatch readTimeSeriesSet(FsIdSet fsIdSet, boolean existsError)
        {
        
        Map<FsId, TimeSeries> batchTimeSeries = new HashMap<FsId, TimeSeries>(fsIdSet.ids().size());
        for (FsId id: fsIdSet.ids()) {
            TimeSeries timeSeries = null;
            if (timeSeriesExists(id)) {
                timeSeries = readTimeSeries(id);
                this.timeSeriesRead.add(id);
            } else if (existsError) {
                throw new FileStoreIdNotFoundException(id);
            } else {
                int len = fsIdSet.endCadence() - fsIdSet.startCadence() + 1;
                timeSeries = 
                    new IntTimeSeries(id, new int[len], fsIdSet.startCadence(), 
                        fsIdSet.endCadence(), Collections.EMPTY_LIST, 
                        Collections.EMPTY_LIST, false);
            }
            batchTimeSeries.put(id, timeSeries);
        }
        
        return new TimeSeriesBatch(fsIdSet.startCadence(), fsIdSet.endCadence(),
            batchTimeSeries);
    }

    @Override
    public synchronized List<MjdTimeSeriesBatch> readMjdTimeSeriesBatch(
        List<MjdFsIdSet> mjdFsIdSetList) {

        List<MjdTimeSeriesBatch> rv = new ArrayList<MjdTimeSeriesBatch>(mjdFsIdSetList.size());
        
        for (MjdFsIdSet idSet : mjdFsIdSetList) {
            rv.add(readMjdTimeSeriesSet(idSet));
        }
        
        return rv;
    }
    
    private MjdTimeSeriesBatch readMjdTimeSeriesSet(MjdFsIdSet idSet) 
        {
        
        Map<FsId, FloatMjdTimeSeries> batchTimeSeries =
                new HashMap<FsId, FloatMjdTimeSeries>(idSet.ids().size());
        for (FsId id : idSet.ids()) {
            FloatMjdTimeSeries mjdTimeSeries = null;
            if (mjdTimeSeriesExists(id)) {
                mjdTimeSeries = readMjdTimeSeries(id, idSet.startMjd(), idSet.endMjd(), true);
            } else {
                mjdTimeSeries = FloatMjdTimeSeries.emptySeries(id, idSet.startMjd(), idSet.endMjd(), false);
            }
            batchTimeSeries.put(id, mjdTimeSeries);
        }
        
        return new MjdTimeSeriesBatch(idSet.startMjd(), idSet.endMjd(), batchTimeSeries);
    }

    @Override
    public synchronized DoubleTimeSeries[] readAllTimeSeriesAsDouble(FsId[] ids,
        boolean existsError) {

        return readTimeSeriesAsDouble(ids, TimeSeries.NOT_EXIST_CADENCE, 
            TimeSeries.NOT_EXIST_CADENCE, existsError);
    }
    
    @Override
    public DoubleTimeSeries[] readTimeSeriesAsDouble(FsId[] ids,
        int startCadence, int endCadence, boolean existsError)
        {
        
        if (ids == null) {
            throw new NullPointerException("ids must not be null.");
        }

        DoubleTimeSeries[] timeSeries = new DoubleTimeSeries[ids.length];
        for (int i = 0; i < ids.length; i++) {
            if (timeSeriesExists(ids[i])) {
                timeSeries[i] = readTimeSeries(ids[i], 
                    startCadence, endCadence,
                    DoubleTimeSeries.class);
            } else {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(ids[i],
                        timeSeriesExistsReason(ids[i]));
                }
                timeSeries[i] = (DoubleTimeSeries) emptySeries(ids[i], false, -1,
                    -1, false, false);
            }
        }
        return timeSeries;
    }

    @Override
    public Map<FsId, TimeSeries> readTimeSeries(Collection<FsId> fsIds,
        int startCadence, int endCadence, boolean existsError) {

        Set<FsId> fsIdsAsSet = new HashSet<FsId>(fsIds);
        List<FsIdSet> singleSet = Collections.singletonList(new FsIdSet(startCadence, endCadence, fsIdsAsSet));
        List<TimeSeriesBatch> batches = readTimeSeriesBatch(singleSet, existsError);
        return batches.get(0).timeSeries();
    }


    @Override
    public Map<FsId, FloatMjdTimeSeries> readMjdTimeSeries(
        Collection<FsId> fsIds, double startMjd, double endMjd) {

        Set<FsId> fsIdsAsSet = new HashSet<FsId>(fsIds);
        List<MjdFsIdSet> singleSet = 
            Collections.singletonList(new MjdFsIdSet(startMjd, endMjd, fsIdsAsSet));
        List<MjdTimeSeriesBatch> batches = readMjdTimeSeriesBatch(singleSet);
        return batches.get(0).timeSeries();
    }

    @Override
    public Set<FsId> queryIds2(String queryString) {
        return queryIds(queryString);
    }

    @Override
    public boolean isStreamOpen() {
        return false;
    }
}
