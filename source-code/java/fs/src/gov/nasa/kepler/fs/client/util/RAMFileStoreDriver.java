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
package gov.nasa.kepler.fs.client.util;
import gov.nasa.kepler.hibernate.dbservice.LocalTransactionalResource;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.io.DataInputStream;

import gov.nasa.kepler.fs.api.*;
import gov.nasa.spiffy.common.collect.RemovableArrayList;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is an implementation of FileStoreDriver that just stores everything in
 * RAM instead of to disk. It does not use any network protocol at all --
 * everything stays local to the local JVM. You better have lots of RAM though! :)
 * 
 * @author Jason Brittain jbrittain@mail.arc.nasa.gov
 * @author Sean McCauiff
 */
public class RAMFileStoreDriver implements FileStoreClient,
    FileStoreTestInterface, LocalTransactionalResource, MaintenanceInterface {

    /**
     * How to make new SimpleIntervals.
     */
    private final SimpleInterval.Factory sFactory = new SimpleInterval.Factory();
    private final TaggedInterval.Factory tFactory = new TaggedInterval.Factory();

    private final PersistableXidThreadLocal xid = new PersistableXidThreadLocal();
    private final AtomicInteger nextXid = new AtomicInteger(3333);
    private final Comparator<CosmicRayDataPoint> dataPointComparator = new Comparator<CosmicRayDataPoint>() {

        public int compare(CosmicRayDataPoint o1, CosmicRayDataPoint o2) {
            return Double.compare(o1.mjd, o2.mjd);
        }

    };

    /**
     * Intervals are stored with byte addresses as opposed to integer/float
     * addresses. startByte = startInt * 2, endByte = startInt *2 + 3
     * 
     */
    private class TsMetadata {
        TsMetadata() {
            valid = new IntervalSet<SimpleInterval, SimpleInterval.Factory>(
                sFactory);
            originators = new IntervalSet<TaggedInterval, TaggedInterval.Factory>(
                tFactory);
            data = new byte[0];
            isFloat = false;
        }

        IntervalSet<SimpleInterval, SimpleInterval.Factory> valid;
        IntervalSet<TaggedInterval, TaggedInterval.Factory> originators;
        byte[] data;
        boolean isFloat;
    }

    private static class CosmicRayDataPoint {
        final double mjd;
        final float value;
        final long originator;

        CosmicRayDataPoint(double mjd, float value, long originator) {
            this.mjd = mjd;
            this.value = value;
            this.originator = originator;
        }
    }

    // TODO: Reduce duplication between all the readTimeSeries methods.

    /**
     * Logger for this class.
     */
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(RAMFileStoreDriver.class);

    private final Map<FsId, TsMetadata> tsStore = Collections.synchronizedMap(new HashMap<FsId, TsMetadata>());

    private final Map<FsId, BlobResult> genericFiles = Collections.synchronizedMap(new HashMap<FsId, BlobResult>());

    /**
     * IdPath -> Set<FsId> mapping.
     */
    private final Map<String, Set<FsId>> tsIds = new HashMap<String, Set<FsId>>();

    private final Map<FsId, RemovableArrayList<CosmicRayDataPoint>> crIds = new HashMap<FsId, RemovableArrayList<CosmicRayDataPoint>>();

    public RAMFileStoreDriver(Configuration config) {

    }

    /**
     * This starts a pseudo transaction. This is useful for checking your
     * beingLocalTransaction calls.
     * 
     * @see gov.nasa.kepler.fs.api.TransactionClient#beginLocalFsTransaction()
     */
    @Override
    public Xid beginLocalFsTransaction() {
        if (!xid.xid()
            .isNullTransaction()) {
            throw new FileStoreException("Transaction in progress.");
        }

        xid.setXid(new PersistableXid(nextXid.incrementAndGet(), 0, 555));

        return xid.xid();
    }

    /**
     * Disassocates the current pseudo transaction from the current thread.
     * 
     * @see gov.nasa.kepler.fs.api.TransactionClient#commitLocalFsTransaction()
     */
    @Override
    public void commitLocalFsTransaction() {
        xid.remove();
    }

    /**
     * Disassocates the current pseudo transaction from the current thread. This
     * does not actually rollback anything.
     * 
     * @see gov.nasa.kepler.fs.api.TransactionClient#rollbackLocalFsTransaction()
     */
    @Override
    public void rollbackLocalFsTransaction() {
        xid.remove();
    }

    /**
     * Disassocates the current pseudo transaction from the current thread. This
     * does not actually rollback anything.
     */
    @Override
    public void rollbackLocalFsTransactionIfActive() {
        xid.remove();
    }
    
    

    @Override
    public boolean localTransactionIsActive() {
        return !xid.xid().isNullTransaction();
    }
    
    /**
     * @see gov.nasa.kepler.fs.api.BlobClient#writeBlob(java.lang.String,
     * byte[])
     */
    public synchronized void writeBlob(FsId id, long originator, byte[] fileData)
        {

        if (xid.xid()
            .isNullTransaction()) {
            throw new FileStoreException("Transaction not started.");
        }
        genericFiles.put(id, new BlobResult(originator, fileData));
    }

    /**
     * @see gov.nasa.kepler.fs.api.BlobClient#readBlob(java.lang.String)
     */
    public synchronized BlobResult readBlob(FsId id) {
        return genericFiles.get(id);
    }

    /**
     * @see gov.nasa.kepler.fs.api.BlobClient#blobExists(java.lang.String)
     */
    public synchronized boolean blobExists(FsId id) {
        return genericFiles.containsKey(id);
    }

    /**
     * Convert from the internal byte indexed ts store into the cadence index
     * return values.
     * 
     * @param clampStart The user space minimum cadence.
     * @param clampEnd The user space maximum cadence.
     * @param ti The list of simple intervals
     * @return
     */
    private List<SimpleInterval> convertSimpleToUser(int clampStart,
        int clampEnd, List<SimpleInterval> ti) {
        List<SimpleInterval> rv = new ArrayList<SimpleInterval>(ti.size());
        for (SimpleInterval byteIndex : ti) {
            rv.add(new SimpleInterval(Math.max(clampStart,
                byteIndex.start() >>> 2), Math.min(clampEnd,
                byteIndex.end() >>> 2)));
        }
        return rv;
    }

    /**
     * Convert from the internal byte indexed ts store into the cadence index
     * return values.
     * 
     * @param clampStart The user space minimum cadence.
     * @param clampMax The user space maximum cadence.
     * @param ti The list of simple intervals
     * @return
     */
    private List<TaggedInterval> convertTypedToUser(int clampStart,
        int clampEnd, List<TaggedInterval> ti) {

        List<TaggedInterval> rv = new ArrayList<TaggedInterval>(ti.size());
        for (TaggedInterval byteIndex : ti) {
            TaggedInterval userIndex = new TaggedInterval(Math.max(clampStart,
                byteIndex.start() >>> 2), Math.min(clampEnd,
                byteIndex.end() >>> 2), byteIndex.tag());
            rv.add(userIndex);
        }
        return rv;
    }

    /**
     * Converts from the user space cadence indexed intervals into the internal
     * byte indexed intervals.
     * 
     * @param ti
     * @return
     */
    private List<TaggedInterval> convertTypedUserToInternal(
        List<TaggedInterval> ti) {
        List<TaggedInterval> rv = new ArrayList<TaggedInterval>(ti.size());
        for (TaggedInterval userIndex : ti) {
            TaggedInterval byteIndex = new TaggedInterval(
                userIndex.start() << 2, (userIndex.end() << 2) + 3,
                userIndex.tag());
            rv.add(byteIndex);
        }
        return rv;
    }

    @SuppressWarnings("resource")
    private FloatTimeSeries readTimeSeriesAsFloat(FsId id, int startCadence,
        int endCadence, boolean existsError) {

        int tsSize = endCadence - startCadence + 1;

        TsMetadata tsMeta = tsStore.get(id);

        if (tsMeta == null) {
            if (existsError) {
                throw new FileStoreIdNotFoundException(id);
            }
            return (FloatTimeSeries) emptySeries(id, true, startCadence,
                endCadence, true, false);
        }

        if (!tsMeta.isFloat) {
            throw new MixedTypeException("Fsid \"" + id + "\" is not a float.",
                id);
        }

        float[] tsChunk = new float[tsSize];

        SimpleInterval simpleSpan = new SimpleInterval(startCadence << 2,
            (endCadence << 2) + 3);
        List<SimpleInterval> validIntervals = tsMeta.valid.spannedIntervals(simpleSpan);

        int actualStart = startCadence << 2;
        int actualEnd = (endCadence << 2) + 3;
        for (SimpleInterval v : validIntervals) {
            int start = Math.max(actualStart, (int) v.start());
            int end = Math.min(actualEnd, (int) v.end());
            int intervalSize = (end - start + 1);
            DataInputStream din = new DataInputStream(new ByteArrayInputStream(
                tsMeta.data, start, intervalSize));

            for (int i = start; i <= end; i += 4) {
                try {
                    tsChunk[(i >> 2) - startCadence] = din.readFloat();
                } catch (IOException ioe) {
                    throw new FileStoreException(
                        "Unexpected IOException when reading from byte stream.",
                        ioe);
                }
            }
        }

        TaggedInterval typedSpan = new TaggedInterval(simpleSpan.start(),
            simpleSpan.end(), -1);

        List<TaggedInterval> originators = tsMeta.originators.spannedIntervals(typedSpan);

        FloatTimeSeries rv = new FloatTimeSeries(id, tsChunk, startCadence,
            endCadence, convertSimpleToUser(startCadence, endCadence,
                validIntervals), convertTypedToUser(startCadence, endCadence,
                originators));

        return rv;
    }

    public synchronized FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] ids,
        int startCadence, int endCadence) {
        return readTimeSeriesAsFloat(ids, startCadence, endCadence, true);
    }

    public synchronized FloatTimeSeries[] readTimeSeriesAsFloat(FsId[] ids,
        int startCadence, int endCadence, boolean existsError)
        {

        if (ids.length == 0) {
            return new FloatTimeSeries[0];
        }

        FloatTimeSeries[] rv = new FloatTimeSeries[ids.length];
        for (int i = 0; i < rv.length; i++) {
            rv[i] = readTimeSeriesAsFloat(ids[i], startCadence, endCadence,
                existsError);
        }
        return rv;
    }

    @SuppressWarnings("resource")
    private IntTimeSeries readTimeSeriesAsInt(FsId id, int startCadence,
        int endCadence, boolean existsError) {

        int tsSize = endCadence - startCadence + 1;
        assert tsSize >= 0;

        TsMetadata tsMeta = tsStore.get(id);

        if (tsMeta == null) {
            if (existsError) {
                throw new FileStoreIdNotFoundException(id);
            }
            return (IntTimeSeries) emptySeries(id, true, startCadence,
                endCadence, false, false);
        }

        if (tsMeta.isFloat) {
            throw new MixedTypeException(
                "FsId \"" + id + "\" is not type int.", id);
        }

        int[] tsChunk = new int[tsSize];

        SimpleInterval simpleSpan = new SimpleInterval(startCadence << 2,
            (endCadence << 2) + 3);
        List<SimpleInterval> validIntervals = tsMeta.valid.spannedIntervals(simpleSpan);

        int actualStart = startCadence << 2;
        int actualEnd = (endCadence << 2) + 3;
        for (SimpleInterval v : validIntervals) {
            int start = Math.max(actualStart, (int) v.start());
            int end = Math.min(actualEnd, (int) v.end());
            int intervalSize = (end - start + 1);
            DataInputStream din = new DataInputStream(new ByteArrayInputStream(
                tsMeta.data, start, intervalSize));

            for (int i = start; i <= end; i += 4) {
                try {
                    tsChunk[(i >> 2) - startCadence] = din.readInt();
                } catch (IOException ioe) {
                    throw new FileStoreException(
                        "Unexpected IOException when reading from byte stream.",
                        ioe);
                }
            }
        }

        TaggedInterval typedSpan = new TaggedInterval(simpleSpan.start(),
            simpleSpan.end(), -1);

        List<TaggedInterval> originators = tsMeta.originators.spannedIntervals(typedSpan);

        IntTimeSeries rv = new IntTimeSeries(id, tsChunk, startCadence,
            endCadence, convertSimpleToUser(startCadence, endCadence,
                validIntervals), convertTypedToUser(startCadence, endCadence,
                originators));

        return rv;
    }

    public synchronized IntTimeSeries[] readTimeSeriesAsInt(FsId[] id,
        int startCadence, int endCadence) {
        return readTimeSeriesAsInt(id, startCadence, endCadence, true);
    }

    public synchronized IntTimeSeries[] readTimeSeriesAsInt(FsId[] id,
        int startCadence, int endCadence, boolean existsError)
        {

        if (id.length == 0) {
            return new IntTimeSeries[0];
        }

        IntTimeSeries[] rv = new IntTimeSeries[id.length];
        for (int i = 0; i < rv.length; i++) {
            rv[i] = readTimeSeriesAsInt(id[i], startCadence, endCadence,
                existsError);
        }

        return rv;
    }

    public void writeTimeSeries(TimeSeries[] ts) {
        writeTimeSeries(ts, true);
    }

    /**
     * 
     */
    public void writeTimeSeries(TimeSeries[] ts, boolean overwrite)
        {

        if (xid.xid()
            .isNullTransaction()) {
            throw new FileStoreException("Transaction not started.");
        }
        for (TimeSeries t : ts) {
            writeTimeSeries(t, overwrite);
        }
    }

    private synchronized void writeTimeSeries(TimeSeries t, boolean overwrite)
        {

        if (t.startCadence() < 0 || t.endCadence() < 0
            || t.startCadence() > t.endCadence()) {
            throw new IllegalArgumentException("Bad cadence values.");
        }

        ByteSequence dataSource = null;
        if (t instanceof FloatTimeSeries) {
            FloatTimeSeries fts = (FloatTimeSeries) t;
            dataSource = ByteSequence.fromFloat(fts.fseries());
        } else {
            IntTimeSeries its = (IntTimeSeries) t;
            dataSource = ByteSequence.fromInt(its.iseries());
        }

        FsId id = t.id();
        TsMetadata tsMeta = tsStore.get(id);
        if (tsMeta == null) {
            tsMeta = new TsMetadata();
            tsStore.put(id, tsMeta);
            Set<FsId> idSet = tsIds.get(id.path());
            if (idSet == null) {
                idSet = new HashSet<FsId>();
                tsIds.put(id.path(), idSet);
            }
            idSet.add(t.id());
            tsMeta.isFloat = t.isFloat();
        }

        long byteStart = t.startCadence() << 2;
        long byteEnd = (t.endCadence() << 2) + 3;
        TaggedInterval deleteTagged = new TaggedInterval(byteStart, byteEnd, -1);
        SimpleInterval deleteSimple = new SimpleInterval(byteStart, byteEnd);
        if (overwrite) {
            tsMeta.valid.deleteInterval(deleteSimple);
            tsMeta.originators.deleteInterval(deleteTagged);
        }

        if (t.validCadences()
            .size() == 0) {
            return;
        }

        int newSize = (int) (t.validCadences()
            .get(t.validCadences()
                .size() - 1)
            .end() + 1);
        newSize = newSize << 2;

        if (tsMeta.data.length < newSize) {
            byte[] newBuffer = new byte[newSize];
            for (SimpleInterval valid : tsMeta.valid.intervals()) {
                int intervalSize = (int) (valid.end() - valid.start() + 1);
                System.arraycopy(tsMeta.data, (int) valid.start(), newBuffer,
                    (int) valid.start(), intervalSize);
            }
            tsMeta.data = newBuffer;
        }

        for (SimpleInterval newValid : t.validCadences()) {
            SimpleInterval internal = new SimpleInterval(newValid.start() << 2,
                (newValid.end() << 2) + 3);
            dataSource.seek((int) (newValid.start() - t.startCadence()));
            for (int offset = (int) internal.start(); offset <= (int) internal.end(); offset += 4) {

                dataSource.writeNextBytes(tsMeta.data, offset);
            }
            tsMeta.valid.mergeInterval(internal);
        }

        List<TaggedInterval> internalOriginator = convertTypedUserToInternal(t.originators());
        for (TaggedInterval ti : internalOriginator) {
            tsMeta.originators.mergeInterval(ti);
        }
    }

    @SuppressWarnings("unchecked")
    public synchronized List<Interval>[] getCadenceIntervalsForId(
        final FsId[] ids) {

        List<Interval>[] allIntervals = (List<Interval>[]) new List<?>[ids.length];
        for (int i = 0; i < ids.length; i++) {
            FsId id = ids[i];
            TsMetadata tsMeta = tsStore.get(id);
            if (tsMeta == null) {
                allIntervals[i] = Collections.emptyList();
            } else {
                List<SimpleInterval> user = convertSimpleToUser(0,
                    Integer.MAX_VALUE, tsMeta.valid.intervals());
                allIntervals[i] = (List<Interval>)(Object) user;
            }
        }

        return allIntervals;

    }

    public synchronized Set<FsId> getIdsForSeries(FsId fsId)
        {

        Set<FsId> rv = tsIds.get(fsId.path());
        if (rv == null) {
            return Collections.emptySet();
        }
        return Collections.unmodifiableSet(rv);
    }

    /**
     * Removes all the file store state.
     */
    public synchronized void cleanFileStore() {
        tsStore.clear();

        genericFiles.clear();

        tsIds.clear();

        crIds.clear();

    }

    /**
     * This is not implemented.
     */
    public StreamedBlobResult readBlobAsStream(FsId id)
        {

        return null;
    }

    /**
     * This is not implemented.
     */
    public OutputStream writeBlob(FsId id, long origin)
        {
        return null;
    }

    /**
     * Does not support XA transactions.
     */
    public XAResource getXAResource() {
        throw new IllegalStateException("Unimplemented method.");
    }

    public synchronized FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] ids)
        {
        return readAllTimeSeriesAsFloat(ids, true);
    }

    public synchronized FloatTimeSeries[] readAllTimeSeriesAsFloat(FsId[] ids,
        boolean existsError) {

        FloatTimeSeries[] rv = new FloatTimeSeries[ids.length];
        for (int i = 0; i < rv.length; i++) {
            FsId id = ids[i];
            TsMetadata meta = tsStore.get(id);
            if (meta == null) {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(id);
                }
                rv[i] = (FloatTimeSeries) emptySeries(id, false, -1, -1, true,
                    false);
                continue;
            } else if (meta.valid.intervals()
                .size() == 0) {
                rv[i] = (FloatTimeSeries) emptySeries(id, false, -1, -1, true,
                    true);
                continue;
            }

            long start = meta.valid.intervals()
                .get(0)
                .start() >> 2;
            long end = meta.valid.intervals()
                .get(meta.valid.intervals()
                    .size() - 1)
                .end();
            end = end - 1 >> 2;

            FloatTimeSeries fts = readTimeSeriesAsFloat(id, (int) start,
                (int) end, existsError);
            rv[i] = fts;
        }

        return rv;
    }

    public IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] ids)
        {
        return readAllTimeSeriesAsInt(ids, true);
    }

    public synchronized IntTimeSeries[] readAllTimeSeriesAsInt(FsId[] ids,
        boolean existsError) {

        IntTimeSeries[] rv = new IntTimeSeries[ids.length];
        for (int i = 0; i < rv.length; i++) {
            FsId id = ids[i];
            TsMetadata meta = tsStore.get(id);
            if (meta == null) {
                if (existsError) {
                    throw new FileStoreIdNotFoundException(id);
                }
                rv[i] = (IntTimeSeries) emptySeries(id, false, -1, -1, false,
                    false);
                continue;
            } else if (meta.valid.intervals()
                .size() == 0) {
                rv[i] = (IntTimeSeries) emptySeries(id, false, -1, -1, false,
                    true);
                continue;
            }

            long start = meta.valid.intervals()
                .get(0)
                .start() >> 2;
            long end = meta.valid.intervals()
                .get(meta.valid.intervals()
                    .size() - 1)
                .end();
            end = end - 1 >> 2;

            IntTimeSeries its = readTimeSeriesAsInt(id, (int) start, (int) end,
                false);
            rv[i] = its;
        }

        return rv;
    }

    /**
     * Creates an empty TimeSeries entry
     * 
     */
    private TimeSeries emptySeries(FsId id, boolean useDefaults, int start,
        int end, boolean isfloat, boolean exists) {

        int size = end - start + 1;
        List<TaggedInterval> origin = Collections.emptyList();
        List<SimpleInterval> valid = Collections.emptyList();
        start = useDefaults ? start : -1;
        end = useDefaults ? end : -1;
        if (isfloat) {
            float[] fdata = useDefaults ? new float[size] : new float[0];
            return new FloatTimeSeries(id, fdata, start, end, valid, origin,
                exists);
        } else {
            int[] idata = useDefaults ? new int[size] : new int[0];
            return new IntTimeSeries(id, idata, start, end, valid, origin,
                exists);
        }
    }

    public long readBlob(FsId id, File dest) {
        throw new FileStoreException("Not implemented.");

    }

    public void writeBlob(FsId id, long origin, File src)
        {
        throw new FileStoreException("Not implemented.");

    }

    /**
     * This does nothing.
     */
    public void initialize(TransactionService xService) {

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

    public TransactionState localTransactionState() {
        // TODO Auto-generated method stub
        return null;
    }

    public synchronized Set<FsId> listMjdTimeSeries(FsId prefix)
        {
        Set<FsId> rv = new HashSet<FsId>();
        for (FsId crId : crIds.keySet()) {
            if (crId.path()
                .equals(prefix.path())) {
                rv.add(crId);
            }
        }
        return rv;
    }

    public FloatMjdTimeSeries[] readAllMjdTimeSeries(FsId[] ids)
        {
        FloatMjdTimeSeries[] rv = readMjdTimeSeries(ids, Double.MIN_VALUE,
            Double.MAX_VALUE);
        for (int i = 0; i < rv.length; i++) {
            FloatMjdTimeSeries series = rv[i];
            double[] mjd = series.mjd();
            if (mjd.length == 0) {
                continue;
            }
            rv[i] = new FloatMjdTimeSeries(series.id(), mjd[0],
                mjd[mjd.length - 1], mjd, series.values(),
                series.originators(), series.exists());
        }

        return rv;
    }

    public FloatMjdTimeSeries[] readMjdTimeSeries(FsId[] ids, double mjdStart,
        double mjdEnd) {
        FloatMjdTimeSeries[] rv = new FloatMjdTimeSeries[ids.length];
        for (int i = 0; i < rv.length; i++) {
            rv[i] = readSingleSeries(ids[i], mjdStart, mjdEnd);
        }
        return rv;
    }

    private synchronized FloatMjdTimeSeries readSingleSeries(FsId id,
        double mjdStart, double mjdEnd) {
        if (mjdStart > mjdEnd) {
            throw new IllegalArgumentException("mjdStart comes after mjdEnd");
        }

        RemovableArrayList<CosmicRayDataPoint> dataPoints = crIds.get(id);
        if (dataPoints == null) {
            return FloatMjdTimeSeries.emptySeries(id, mjdStart, mjdEnd, false);
        }

        CosmicRayDataPoint startKey = new CosmicRayDataPoint(mjdStart, 0, 0);
        CosmicRayDataPoint endKey = new CosmicRayDataPoint(mjdEnd, 0, 0);

        int startIndex = Collections.binarySearch(dataPoints, startKey,
            dataPointComparator);
        if (startIndex < 0) {
            startIndex = -startIndex - 1;
        }

        // Exclusive
        int endIndex = Collections.binarySearch(dataPoints, endKey,
            dataPointComparator);
        if (endIndex < 0) {
            endIndex = -endIndex - 1;
        } else {
            endIndex++;
        }

        if (startIndex == endIndex) {
            return FloatMjdTimeSeries.emptySeries(id, mjdStart, mjdEnd, true);
        }

        double[] mjd = new double[endIndex - startIndex];
        float[] values = new float[mjd.length];
        long[] originators = new long[values.length];
        for (int i = startIndex; i < endIndex; i++) {
            CosmicRayDataPoint dp = dataPoints.get(i);
            mjd[i] = dp.mjd;
            values[i] = dp.value;
            originators[i] = dp.originator;
        }

        return new FloatMjdTimeSeries(id, mjdStart, mjdEnd, mjd, values,
            originators, true);
    }

    public void writeMjdTimeSeries(FloatMjdTimeSeries[] series_a)
        {
        for (FloatMjdTimeSeries series : series_a) {
            writeCosmicRaySeries(series);
        }
    }

    private synchronized void writeCosmicRaySeries(FloatMjdTimeSeries series) {
        RemovableArrayList<CosmicRayDataPoint> dataPoints = crIds.get(series.id());
        if (dataPoints == null) {
            dataPoints = new RemovableArrayList<CosmicRayDataPoint>();
            crIds.put(series.id(), dataPoints);
        }

        CosmicRayDataPoint startKey = new CosmicRayDataPoint(series.startMjd(),
            0, 0);
        int rmStart = Collections.binarySearch(dataPoints, startKey,
            dataPointComparator);
        if (rmStart < 0) {
            rmStart = -rmStart - 1;
        }
        CosmicRayDataPoint endKey = new CosmicRayDataPoint(series.endMjd(), 0,
            0);
        // Exclusive
        int rmEnd = Collections.binarySearch(dataPoints, endKey,
            dataPointComparator);
        if (rmEnd < 0) {
            rmEnd = -rmEnd - 1;
        } else {
            rmEnd++;
        }

        dataPoints.removeInterval(rmStart, rmEnd);

        double[] mjd = series.mjd();
        float[] values = series.values();
        long[] originators = series.originators();

        List<CosmicRayDataPoint> newPoints = new ArrayList<CosmicRayDataPoint>(
            mjd.length);
        for (int i = 0; i < mjd.length; i++) {
            newPoints.add(new CosmicRayDataPoint(mjd[i], values[i],
                originators[i]));
        }
        dataPoints.addAll(newPoints);
    }

    /**
     * This does nothing.
     */
    public void disassociateThread() {

    }

    @Override
    public synchronized void deleteBlob(FsId id) {
        if (xid.xid()
            .isNullTransaction()) {
            throw new FileStoreException("Transaction not started.");
        }
        genericFiles.remove(id);
    }

    @Override
    public void deleteTimeSeries(FsId[] ids) {
        if (xid.xid()
            .isNullTransaction()) {
            throw new FileStoreException("Transaction not started.");
        }
        
        for (FsId id : ids) {
            tsStore.remove(id);
        }
    }

    @Override
    public synchronized void deleteMjdTimeSeries(FsId[] ids)
        {
        if (xid.xid()
            .isNullTransaction()) {
            throw new FileStoreException("Transaction not started.");
        }
        for (FsId id : ids) {
            crIds.remove(id);
        }
    }

    @Override
    public synchronized List<String> status() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("RAM File Store Client\n");
        bldr.append(" Total Time Series Stored: ")
            .append(tsStore.size())
            .append('\n');
        bldr.append(" Total Blobs Stored: ")
            .append(genericFiles.size())
            .append('\n');
        bldr.append(" Total Mjd Time Series Stored: ")
            .append(crIds.size())
            .append('\n');
        return Collections.singletonList(bldr.toString());
    }

    /**
     * This does nothing.
     */
    @Override
    public void ping() {
        // Nothing
    }

    /**
     * This does nothing.
     */
    @Override
    public void shutdown() {

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
    public List<FsId> getBlobsRead() {
        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public List<FsId> getBlobsWritten() {
        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public List<FsId> getMjdTimeSeriesWritten() {
        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public List<FsId> getTimeSeriesRead() {
        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public List<FsId> getTimeSeriesWritten() {
        throw new IllegalStateException("Not implemented.");
    }

    /**
     * Counters are not tracked.
     */
    @Override
    public void setEnableFsIdCounters(boolean enable) {

    }

    @Override
    public List<TimeSeriesBatch> readTimeSeriesBatch(List<FsIdSet> fsIdSet, boolean existsError)
        {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public List<MjdTimeSeriesBatch> readMjdTimeSeriesBatch(
        List<MjdFsIdSet> mjdFsIdSetList) {
        // TODO Auto-generated method stub
        return null;
    }

    @Override
    public DoubleTimeSeries[] readAllTimeSeriesAsDouble(FsId[] id,
        boolean existsFlag) {


        throw new IllegalStateException("Not implemented.");
    }

    @Override
    public DoubleTimeSeries[] readTimeSeriesAsDouble(FsId[] id,
        int startCadence, int endCadence, boolean existsError)
        {

        throw new IllegalStateException("Not implemented.");
    }


    @Override
    public Map<FsId, TimeSeries> readTimeSeries(Collection<FsId> fsIds,
        int startCadence, int endCadence, boolean existsError) {

        throw new UnsupportedOperationException();
    }

    @Override
    public Map<FsId, FloatMjdTimeSeries> readMjdTimeSeries(
        Collection<FsId> fsId, double startMjd, double endMjd) {

        throw new UnsupportedOperationException();
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
