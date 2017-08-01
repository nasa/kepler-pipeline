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

package gov.nasa.kepler.mc.dr;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.intervals.CadenceBlob;
import gov.nasa.kepler.common.intervals.CadenceBlobCalculator;
import gov.nasa.kepler.common.intervals.CadenceBlobDataFactory;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.RclcPixelBlobMetadata;
import gov.nasa.kepler.hibernate.dr.RclcPixelBlobMetadataCrud;
import gov.nasa.kepler.hibernate.dr.RclcPixelBlobMetadataFactory;
import gov.nasa.kepler.hibernate.mc.AbstractCadenceBlob;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.persistable.BinaryPersistableInputStream;
import gov.nasa.spiffy.common.persistable.BinaryPersistableOutputStream;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Contains operations for rclc pixel {@link TimeSeries}.
 * 
 * @author Miles Cote
 * 
 */
public class RclcPixelTimeSeriesOperations implements PixelTimeSeriesWriter,
    PixelTimeSeriesReader {

    private static final Log log = LogFactory.getLog(RclcPixelTimeSeriesOperations.class);

    private final DataSetType dataSetType;
    private final int ccdModule;
    private final int ccdOutput;

    private final RclcPixelBlobMetadataCrud rclcPixelBlobMetadataCrud;
    private final RclcPixelBlobMetadataFactory rclcPixelBlobMetadataFactory;

    public RclcPixelTimeSeriesOperations(DataSetType dataSetType,
        int ccdModule, int ccdOutput) {
        this(dataSetType, ccdModule, ccdOutput,
            new RclcPixelBlobMetadataCrud(), new RclcPixelBlobMetadataFactory());
    }

    RclcPixelTimeSeriesOperations(DataSetType dataSetType, int ccdModule,
        int ccdOutput, RclcPixelBlobMetadataCrud rclcPixelBlobMetadataCrud,
        RclcPixelBlobMetadataFactory rclcPixelBlobMetadataFactory) {
        this.dataSetType = dataSetType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.rclcPixelBlobMetadataCrud = rclcPixelBlobMetadataCrud;
        this.rclcPixelBlobMetadataFactory = rclcPixelBlobMetadataFactory;
    }

    @Override
    public void write(IntTimeSeries[] ts, boolean overwrite) {
        if (ts.length == 0) {
            return;
        }

        int startCadence = ts[0].startCadence();
        int endCadence = ts[0].endCadence();

        RclcPixelBlobMetadata rclcPixelBlobMetadata = rclcPixelBlobMetadataFactory.create(
            DrConstants.DATA_RECEIPT_ORIGIN_ID, ccdModule, ccdOutput,
            startCadence, endCadence);

        log.info("rclcPixelBlobMetadata: " + rclcPixelBlobMetadata);

        if (dataSetType.equals(DataSetType.Target)) {
            // Only store metadata blobs in the 'Target' case since the metadata
            // blob for the other dataSetTypes is the same. This prevents
            // duplicate metadata blobs from being written to the database.
            // Also, check if there already exists an identical metadata blob
            // before creating a new one.
            List<RclcPixelBlobMetadata> retrieveLatestRclcPixelBlobMetadata = rclcPixelBlobMetadataCrud.retrieveLatestRclcPixelBlobMetadata(
                ccdModule, ccdOutput, startCadence, endCadence);
            if (retrieveLatestRclcPixelBlobMetadata == null
                || retrieveLatestRclcPixelBlobMetadata.size() == 0
                || retrieveLatestRclcPixelBlobMetadata.get(0)
                    .getCreationTime() != rclcPixelBlobMetadata.getCreationTime()) {
                log.info("Storing rclcPixelBlobMetadata...");
                rclcPixelBlobMetadataCrud.createRclcPixelBlobMetadata(rclcPixelBlobMetadata);
            }
        }

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(new BufferedOutputStream(
            baos));
        try {
            BinaryPersistableOutputStream bpos = new BinaryPersistableOutputStream(
                dos);
            bpos.save(new IntTimeSeriesList(Arrays.asList(ts)));

            dos.flush();

            FsId fsId = DrFsIdFactory.getRclcPixelBlobFsId(
                dataSetType,
                rclcPixelBlobMetadata.getCcdModule(),
                rclcPixelBlobMetadata.getCcdOutput(),
                rclcPixelBlobMetadata.getStartCadence(),
                rclcPixelBlobMetadata.getEndCadence()
                    - rclcPixelBlobMetadata.getStartCadence() + 1);
            FileStoreClientFactory.getInstance()
                .writeBlob(fsId, DrConstants.DATA_RECEIPT_ORIGIN_ID,
                    baos.toByteArray());
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to save.", e);
        } finally {
            FileUtil.close(dos);
        }
    }

    @Override
    public IntTimeSeries[] readTimeSeriesAsInt(FsId[] fsIds, int startCadence,
        int endCadence) {
        return readTimeSeriesAsInt(fsIds, startCadence, endCadence, false);
    }

    public IntTimeSeries[] readTimeSeriesAsInt(FsId[] fsIds, int startCadence,
        int endCadence, boolean oldStyleFsId) {
        BlobSeries<BlobResult> blobSeries = retrieveRclcPixelBlobDataSeries(
            ccdModule, ccdOutput, startCadence, endCadence, oldStyleFsId);
        if (blobSeries.size() == 0) {
            return new IntTimeSeries[0];
        }

        if (log.isDebugEnabled()) {
            Object[] blobResults = blobSeries.blobFilenames();
            log.debug("blobSeries.blobFilenames().length: "
                + blobResults.length);
            int index = 0;
            log.debug("blobResults[0]: " + blobResults[0]);
            if (blobResults[0] instanceof BlobResult) {
                BlobResult reference = (BlobResult) blobResults[0];
                log.debug(String.format("reference[%d]: %s", index, reference));
                for (Object next : blobResults) {
                    BlobResult blobResult = (BlobResult) next;
                    if (!blobResult.equals(reference)) {
                        reference = blobResult;
                        log.debug(String.format("reference[%d]: %s", index,
                            reference));
                    }
                    index++;
                }
            } else {
                log.debug("unexpected blob \"filename\" type: "
                    + blobResults[0].getClass()
                        .getSimpleName());
            }
        }

        if (!(blobSeries.blobFilenames()[0] instanceof BlobResult)) {
            throw new IllegalStateException(String.format(
                "unexpected blob series type: %s",
                blobSeries.blobFilenames()[0].getClass()
                    .getSimpleName()));
        }
        BlobResult blobResult = (BlobResult) blobSeries.blobFilenames()[0];
        for (int cadence = startCadence; cadence < endCadence; cadence++) {
            BlobResult nextBlobResult = blobSeries.blobForCadence(cadence,
                startCadence);
            if (nextBlobResult != null && !blobResult.equals(nextBlobResult)) {
                log.error(String.format(
                    "blobSeries.blobForCadence(%d, %d): %s", cadence,
                    startCadence, nextBlobResult));
                throw new IllegalStateException(
                    String.format(
                        "Multiple distinct blobs in the cadence range [%d,%d] is not supported.",
                        startCadence, endCadence));
            }
        }

        IntTimeSeriesList intTimeSeriesList = new IntTimeSeriesList();

        DataInputStream dis = new DataInputStream(new BufferedInputStream(
            new ByteArrayInputStream(blobResult.data())));
        try {
            BinaryPersistableInputStream bpis = new BinaryPersistableInputStream(
                dis);
            bpis.load(intTimeSeriesList);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to load.", e);
        } finally {
            FileUtil.close(dis);
        }

        if (log.isDebugEnabled()) {
            log.debug(String.format("getIntTimeSeriesList().size(): %d",
                intTimeSeriesList.getIntTimeSeriesList()
                    .size()));
            log.debug(String.format(
                "getIntTimeSeriesList().get(0).length(): %d",
                intTimeSeriesList.getIntTimeSeriesList()
                    .get(0)
                    .endCadence() - intTimeSeriesList.getIntTimeSeriesList()
                    .get(0)
                    .startCadence() + 1));
            log.debug(String.format(
                "getIntTimeSeriesList().get(0) cadence range: [%d,%d]",
                intTimeSeriesList.getIntTimeSeriesList()
                    .get(0)
                    .startCadence(), intTimeSeriesList.getIntTimeSeriesList()
                    .get(0)
                    .endCadence()));
        }

        List<IntTimeSeries> intTimeSeriesJavaList = newArrayList();
        if (fsIds != null) {

            Map<FsId, IntTimeSeries> fsIdToTimeSeries = newHashMap();
            for (IntTimeSeries intTimeSeries : intTimeSeriesList.getIntTimeSeriesList()) {
                fsIdToTimeSeries.put(intTimeSeries.id(), intTimeSeries);
            }
            for (FsId fsId : fsIds) {
                intTimeSeriesJavaList.add(resizeTimeSeries(startCadence,
                    endCadence, fsIdToTimeSeries.get(fsId)));
            }
        } else {
            intTimeSeriesJavaList = intTimeSeriesList.getIntTimeSeriesList();
        }

        return intTimeSeriesJavaList.toArray(new IntTimeSeries[0]);
    }

    private BlobSeries<BlobResult> retrieveRclcPixelBlobDataSeries(
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        boolean oldStyleFsId) {

        return retrieveRclcPixelBlobSeries(new RclcPixelBlobDataFactory(
            oldStyleFsId), ccdModule, ccdOutput, startCadence, endCadence);
    }

    private BlobSeries<BlobResult> retrieveRclcPixelBlobSeries(
        CadenceBlobDataFactory<BlobResult> dataFactory, int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {
        List<RclcPixelBlobMetadata> cadenceBlobs = rclcPixelBlobMetadataCrud.retrieveLatestRclcPixelBlobMetadata(
            ccdModule, ccdOutput, startCadence, endCadence);
        log.debug("cadenceBlobs.size(): " + cadenceBlobs.size());
        CadenceBlobCalculator<BlobResult> cadenceBlobCalculator = new CadenceBlobCalculator<BlobResult>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private static IntTimeSeries resizeTimeSeries(int startCadence,
        int endCadence, IntTimeSeries intTimeSeries) {

        if (startCadence > endCadence) {
            throw new IllegalStateException(String.format(
                "startCadence, %d, must be less than endCadence, %d",
                startCadence, endCadence));
        }
        if (startCadence > intTimeSeries.startCadence()) {
            throw new IllegalStateException(
                String.format(
                    "invalid startCadence, %d, must precede time series cadence range [%d, %d]",
                    startCadence, intTimeSeries.startCadence(),
                    intTimeSeries.endCadence()));
        }
        if (endCadence < intTimeSeries.endCadence()) {
            throw new IllegalStateException(
                String.format(
                    "invalid endCadence, %d, must follow time series cadence range [%d, %d]",
                    endCadence, intTimeSeries.startCadence(),
                    intTimeSeries.endCadence()));
        }

        if (log.isDebugEnabled()) {
            log.debug(String.format("RCLC cadence range: [%d,%d]",
                startCadence, endCadence));
            log.debug(String.format("intTimeSeries cadence range: [%d,%d]",
                intTimeSeries.startCadence(), intTimeSeries.endCadence()));
        }

        if (intTimeSeries.startCadence() == startCadence
            && intTimeSeries.endCadence() == endCadence) {
            return intTimeSeries;
        }

        int offset = intTimeSeries.startCadence() - startCadence;
        int[] iseries = new int[endCadence - startCadence + 1];
        boolean[] gapIndicators = new boolean[iseries.length];
        Arrays.fill(gapIndicators, true);
        int length = intTimeSeries.endCadence() - intTimeSeries.startCadence()
            + 1;

        if (log.isDebugEnabled()) {
            log.debug(String.format(
                "System.arraycopy(intTimeSeries.iseries(), 0, iseries, %d, %d)",
                offset, length));
            log.debug(String.format(
                "System.arraycopy(intTimeSeries.getGapIndicators(), 0, gapIndicators, %d, %d)",
                offset, length));
        }

        System.arraycopy(intTimeSeries.iseries(), 0, iseries, offset, length);
        System.arraycopy(intTimeSeries.getGapIndicators(), 0, gapIndicators, offset,
            length);

        return new IntTimeSeries(intTimeSeries.id(), iseries, startCadence,
            endCadence, gapIndicators, DrConstants.DATA_RECEIPT_ORIGIN_ID);
    }

    private abstract class AbstractCadenceBlobDataFactory implements
        CadenceBlobDataFactory<BlobResult> {

        public AbstractCadenceBlobDataFactory() {
        }

        public abstract FsId getFsId(CadenceBlob cadenceBlob);

        @Override
        public long originatorForCadenceBlob(CadenceBlob cadenceBlob) {
            return ((AbstractCadenceBlob) cadenceBlob).getPipelineTaskId();
        }

        @Override
        @SuppressWarnings("all")
        public BlobResult blobDataForCadenceBlob(CadenceBlob cadenceBlob) {

            return FileStoreClientFactory.getInstance()
                .readBlob(getFsId(cadenceBlob));
        }
    }

    private final class RclcPixelBlobDataFactory extends
        AbstractCadenceBlobDataFactory {

        private final boolean oldStyleFsId;

        public RclcPixelBlobDataFactory(boolean oldStyleFsId) {
            this.oldStyleFsId = oldStyleFsId;
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            FsId blobFsId = null;
            if (oldStyleFsId) {
                blobFsId = DrFsIdFactory.getRclcPixelBlobFsId(dataSetType,
                    ccdModule, ccdOutput);
            } else {
                blobFsId = DrFsIdFactory.getRclcPixelBlobFsId(dataSetType,
                    ccdModule, ccdOutput, cadenceBlob.getStartCadence(),
                    cadenceBlob.getEndCadence() - cadenceBlob.getStartCadence()
                        + 1);
            }
            return blobFsId;
        }
    }

    private static final int ARGS_COUNT = 4;

    public static void main(String[] args) {

        int argIndex = 0;
        int maxCount = Integer.MAX_VALUE;
        boolean oldStyleFsId = false;
        if (args.length > ARGS_COUNT) {
            while (argIndex < args.length - ARGS_COUNT) {
                if (args[argIndex].equalsIgnoreCase("-c")) {
                    argIndex++; // skip over '-c'
                    maxCount = Integer.valueOf(args[argIndex++]);
                } else if (args[argIndex].equalsIgnoreCase("-o")) {
                    argIndex++; // skip over '-o'
                    oldStyleFsId = true;
                } else {
                    log.error("Invalid command line option: " + args[argIndex]);
                    break;
                }
            }
        }

        if (args.length != argIndex + ARGS_COUNT) {
            log.error("Usage: dump-rclc-blob [-o] [-c #] <ccdModule> <ccdOutput> <startCadence> <endCadence>");
            throw new IllegalArgumentException("Missing required args.");
        }

        int ccdModule = Integer.valueOf(args[argIndex++]);
        int ccdOutput = Integer.valueOf(args[argIndex++]);
        int startCadence = Integer.valueOf(args[argIndex++]);
        int endCadence = Integer.valueOf(args[argIndex++]);
        RclcPixelTimeSeriesOperations operations = new RclcPixelTimeSeriesOperations(
            DataSetType.Target, ccdModule, ccdOutput);
        IntTimeSeries[] intTimeSeriesArray = operations.readTimeSeriesAsInt(
            null, startCadence, endCadence, oldStyleFsId);
        for (IntTimeSeries intTimeSeries : intTimeSeriesArray) {
            if (maxCount-- == 0) {
                break;
            }
            log.info(String.format("id: %s", intTimeSeries.id()));
            log.info(String.format("\tcadences: [%d,%d]",
                intTimeSeries.startCadence(), intTimeSeries.endCadence()));
            log.info(String.format("\tccd: [%d,%d]", ccdModule, ccdOutput));
            log.info(String.format("\tlength: %d", intTimeSeries.endCadence()
                - intTimeSeries.startCadence() + 1));
            for (SimpleInterval interval : intTimeSeries.validCadences()) {
                log.info(String.format("\tvalidCadences: [%d,%d]",
                    interval.start(), interval.end()));
            }
        }
    }
}
