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

package gov.nasa.kepler.mc.blob;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.intervals.CadenceBlob;
import gov.nasa.kepler.common.intervals.CadenceBlobCalculator;
import gov.nasa.kepler.common.intervals.CadenceBlobDataFactory;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.cal.CalOneDBlackFitMetadata;
import gov.nasa.kepler.hibernate.cal.SmearMetadata;
import gov.nasa.kepler.hibernate.cal.UncertaintyTransformationMetadata;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.UkirtImageBlobMetadata;
import gov.nasa.kepler.hibernate.dynablack.DynablackCrud;
import gov.nasa.kepler.hibernate.dynablack.DynamicTwoDBlackBlobMetadata;
import gov.nasa.kepler.hibernate.mc.AbstractCadenceBlob;
import gov.nasa.kepler.hibernate.mc.AbstractModOutCadenceBlob;
import gov.nasa.kepler.hibernate.mc.AbstractSkyGroupBlob;
import gov.nasa.kepler.hibernate.mc.AbstractTargetBlob;
import gov.nasa.kepler.hibernate.mc.SkyGroupBlob;
import gov.nasa.kepler.hibernate.mc.TargetBlob;
import gov.nasa.kepler.hibernate.pa.BackgroundBlobMetadata;
import gov.nasa.kepler.hibernate.pa.FfiMotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.MotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pa.UncertaintyBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.CbvBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.PdcBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.prf.FpgGeometryBlobMetadata;
import gov.nasa.kepler.hibernate.prf.PrfCrud;
import gov.nasa.kepler.hibernate.tip.TipBlobMetadata;
import gov.nasa.kepler.hibernate.tip.TipCrud;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.FpgFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.TipFsIdFactory;

import java.io.File;
import java.io.IOException;
import java.util.List;

/**
 * Support for the retrieval of blobs (for example, background blobs, motion
 * blobs, etc.).
 * 
 * @author Forrest Girouard
 * 
 */
public class BlobOperations {

    private DynablackCrud dynablackCrud = new DynablackCrud();
    private CalCrud calCrud = new CalCrud();
    private DvCrud dvCrud = new DvCrud();
    private PaCrud paCrud = new PaCrud();
    private PdcCrud pdcCrud = new PdcCrud();
    private PrfCrud prfCrud = new PrfCrud();
    private TipCrud tipCrud = new TipCrud();
    private File outputDir = new File(".");

    /**
     * Simple no-arg constructor. Note that blob data for
     * {@code BlobSeries<String>} instances will be written to files in the
     * current working directory unless {@link #setOutputDir} is used to specify
     * a different location.
     */
    public BlobOperations() {
    }

    /**
     * Constructor which allows for specifying an output directory. The blob
     * data for {@code BlobSeries<String>} instances will be written to files in
     * this directory (see also {@link #setOutputDir}).
     * 
     * @param outputDir the directory in which blob data files are created.
     */
    public BlobOperations(File outputDir) {

        setOutputDir(outputDir);
    }

    /**
     * Sets the output directory. The blob data for {@code BlobSeries<String>}
     * instances will be written to files in this directory. The default is the
     * current working directory.
     * <p>
     * Classes which extend {@link gov.nasa.kepler.pi.MatlabPipelineModule}
     * should explicitly specify the output directory as
     * {@code getExternalBridge(pipelineTask).getWorkingDir()} by either using
     * this setter or calling the {@link #BlobOperations(File)} constructor.
     * 
     * @param outputDir the directory in which blob data files are created.
     */
    public void setOutputDir(File outputDir) {

        if (outputDir == null) {
            throw new NullPointerException("outputDir is null");
        }
        if (!outputDir.exists()) {
            throw new IllegalArgumentException(outputDir
                + ": no such directory");
        }
        if (!outputDir.isDirectory()) {
            throw new IllegalArgumentException(outputDir
                + ": is not a directory");
        }
        if (!outputDir.canWrite()) {
            throw new IllegalArgumentException(outputDir + ": is not writable");
        }
        this.outputDir = outputDir;
    }

    public BlobSeries<String> retrieveBackgroundBlobFileSeries(int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        return retrieveBackgroundBlobSeries(new BackgroundBlobFileFactory(),
            ccdModule, ccdOutput, startCadence, endCadence);
    }

    public BlobSeries<String> retrieveMotionBlobFileSeries(int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        return retrieveMotionBlobSeries(new MotionBlobFileFactory(), ccdModule,
            ccdOutput, startCadence, endCadence);
    }

    public BlobSeries<String> retrieveFfiMotionBlobFileSeries(int ccdModule,
        int ccdOutput, int startCadence, int endCadence) {

        return retrieveFfiMotionBlobSeries(new FfiMotionBlobFileFactory(), ccdModule,
            ccdOutput, startCadence, endCadence);
    }

    public BlobSeries<String> retrieveDynamicTwoDBlackBlobFileSeries(
        int ccdModule, int ccdOutput, int startCadence, int endCadence) {

        return retrieveDynamicTwoDBlackBlobSeries(
            new DynamicTwoDBlackBlobFileFactory(), ccdModule, ccdOutput,
            startCadence, endCadence);
    }
    
    /**
     * This justs get the originators for the pipeline task that produced the blobs
     * for the specified mod/out and cadence interval.  No files are written to disk.
     * @return non-null
     */
    public long[] retrieveDynamicTwoDBlackOriginators(int ccdModule, int ccdOutput, int startCadence, int endCadence) {
        return retrieveDynamicTwoDBlackBlobSeries(
                    new DynamicTwoDBlackBlobFileFactory() {
                        @Override
                        public String blobDataForCadenceBlob(CadenceBlob cadenceBlob) {
                            return "just-getting-originators.txt";
                        }
                    }, ccdModule, ccdOutput,
                    startCadence, endCadence).blobOriginators();
    }

    public BlobSeries<String> retrieveCbvBlobFileSeries(int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence, int endCadence) {

        return retrieveCbvBlobSeries(new CbvBlobFileFactory(), ccdModule,
            ccdOutput, cadenceType, startCadence, endCadence);
    }

    public BlobSeries<String> retrievePdcBlobFileSeries(int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence, int endCadence) {

        return retrievePdcBlobSeries(new PdcBlobFileFactory(), ccdModule,
            ccdOutput, cadenceType, startCadence, endCadence);
    }

    public BlobSeries<String> retrieveFpgGeometryBlob(int startCadence,
        int endCadence) {

        return retrieveFpgGeometryBlobSeries(new FpgGeometryBlobFileFactory(),
            startCadence, endCadence);
    }

    public BlobSeries<String> retrieveCalUncertaintiesBlobFileSeries(
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence) {

        return retrieveCalBlobSeries(
            new CalUncertaintyTransformationBlobFileFactory(), ccdModule,
            ccdOutput, cadenceType, startCadence, endCadence,
            UncertaintyTransformationMetadata.class);
    }

    public BlobSeries<String> retrieveSmearBlobFileSeries(int ccdModule,
        int ccdOutput, CadenceType cadenceType, int startCadence, int endCadence) {

        return retrieveCalBlobSeries(new SmearBlobFileFactory(), ccdModule,
            ccdOutput, cadenceType, startCadence, endCadence,
            SmearMetadata.class);
    }

    public BlobSeries<String> retrieveCalOneDBlackFitBlobFileSeries(
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence) {

        return retrieveCalBlobSeries(new CalOneDBlackFitBlobFileFactory(),
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            CalOneDBlackFitMetadata.class);
    }

    public BlobSeries<String> retrievePaUncertaintiesBlobFileSeries(
        int ccdModule, int ccdOutput, CadenceType cadenceType,
        int startCadence, int endCadence) {

        return retrievePaUncertaintiesBlobSeries(
            new PaUncertaintyBlobFileFactory(), ccdModule, ccdOutput,
            cadenceType, startCadence, endCadence);
    }

    public BlobData<String> retrieveUkirtImageBlobFile(int keplerId) {

        return retrieveUkirtImageBlobData(new UkirtImageBlobFileFactory(),
            keplerId);
    }

    public BlobData<String> retrieveTipBlobFile(int skyGroupId) {

        return retrieveTipBlobData(new TipBlobFileFactory(), skyGroupId);
    }

    public BlobData<String> retrieveTipBlobFile(int skyGroupId, long createTime) {

        return retrieveTipBlobData(new TipBlobFileFactory(), skyGroupId,
            createTime);
    }

    // methods for determining FsIds, one per blob type

    public static FsId getFsId(CalOneDBlackFitMetadata metadata) {

        return CalFsIdFactory.getOneDBlackFitBlobFsId(
            metadata.getCadenceType(), metadata.getCcdModule(),
            metadata.getCcdOutput(), metadata.getPipelineTaskId());
    }

    public static FsId getFsId(SmearMetadata metadata) {

        return CalFsIdFactory.getSmearBlobFsId(metadata.getCadenceType(),
            metadata.getCcdModule(), metadata.getCcdOutput(),
            metadata.getPipelineTaskId());
    }

    public static FsId getFsId(FpgGeometryBlobMetadata metadata) {

        return FpgFsIdFactory.getMatlabBlobFsId(
            FpgFsIdFactory.BlobSeriesType.FPG_GEOMETRY,
            metadata.getStartCadence(), metadata.getEndCadence(),
            metadata.getPipelineTaskId());
    }

    public static FsId getFsId(UncertaintyTransformationMetadata metadata) {

        return CalFsIdFactory.getUncertaintyTransformBlobFsId(
            metadata.getCadenceType(), metadata.getCcdModule(),
            metadata.getCcdOutput(), metadata.getPipelineTaskId());
    }

    public static FsId getFsId(UncertaintyBlobMetadata metadata) {

        return PaFsIdFactory.getMatlabBlobFsId(
            PaFsIdFactory.BlobSeriesType.UNCERTAINTIES,
            metadata.getCcdModule(), metadata.getCcdOutput(),
            metadata.getCadenceType(), metadata.getPipelineTaskId());
    }

    public static FsId getFsId(BackgroundBlobMetadata metadata) {

        return PaFsIdFactory.getMatlabBlobFsId(
            PaFsIdFactory.BlobSeriesType.BACKGROUND, metadata.getCcdModule(),
            metadata.getCcdOutput(), metadata.getPipelineTaskId());
    }

    public static FsId getFsId(MotionBlobMetadata metadata) {

        return PaFsIdFactory.getMatlabBlobFsId(
            PaFsIdFactory.BlobSeriesType.MOTION, metadata.getCcdModule(),
            metadata.getCcdOutput(), metadata.getPipelineTaskId());
    }

    public static FsId getFsId(FfiMotionBlobMetadata metadata) {

        return PaFsIdFactory.getMatlabBlobFsId(
            PaFsIdFactory.BlobSeriesType.FFI_MOTION, metadata.getCcdModule(),
            metadata.getCcdOutput(), metadata.getPipelineTaskId());
    }

    public static FsId getFsId(CbvBlobMetadata metadata) {

        return PdcFsIdFactory.getMatlabBlobFsId(
            PdcFsIdFactory.BlobSeriesType.CBV, metadata.getCadenceType(),
            metadata.getCcdModule(), metadata.getCcdOutput(),
            metadata.getPipelineTaskId());
    }

    public static FsId getFsId(PdcBlobMetadata metadata) {

        return PdcFsIdFactory.getMatlabBlobFsId(
            PdcFsIdFactory.BlobSeriesType.PDC, metadata.getCadenceType(),
            metadata.getCcdModule(), metadata.getCcdOutput(),
            metadata.getPipelineTaskId());
    }

    public static FsId getFsId(DynamicTwoDBlackBlobMetadata metadata) {

        return DynablackFsIdFactory.getDynamicTwoDBlackBlobFsId(
            metadata.getCcdModule(), metadata.getCcdOutput(),
            metadata.getPipelineTaskId());
    }

    public static FsId getFsId(UkirtImageBlobMetadata metadata) {

        return DrFsIdFactory.getUkirtImageBlobFsId(metadata.getKeplerId(),
            metadata.getFileExtension(), metadata.getCreationTime());
    }

    public static FsId getFsId(TipBlobMetadata metadata) {

        return TipFsIdFactory.getTipBlobFsId(metadata.getSkyGroupId(),
            metadata.getFileExtension(), metadata.getCreationTime());
    }

    public static long getOriginator(AbstractCadenceBlob metadata) {
        return metadata.getPipelineTaskId();
    }

    public static long getOriginator(AbstractTargetBlob metadata) {
        throw new UnsupportedOperationException(
            "TargetBlobs do not have originators");
    }

    public static long getOriginator(AbstractSkyGroupBlob metadata) {
        throw new UnsupportedOperationException(
            "SkyGroupBlobs do not have originators");
    }

    // parameterized methods for retrieving parameterized blob series, one per
    // blob type

    private <T> BlobSeries<T> retrieveFpgGeometryBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = prfCrud.retrieveGeometryBlobMetadata(
            startCadence, endCadence);

        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrieveBackgroundBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = paCrud.retrieveBackgroundBlobMetadata(
            ccdModule, ccdOutput, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrieveMotionBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = paCrud.retrieveMotionBlobMetadata(
            ccdModule, ccdOutput, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrieveFfiMotionBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = paCrud.retrieveFfiMotionBlobMetadata(
            ccdModule, ccdOutput, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrieveCbvBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = pdcCrud.retrieveCbvBlobMetadata(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrievePdcBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = pdcCrud.retrievePdcBlobMetadata(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrieveDynamicTwoDBlackBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) {
        List<? extends CadenceBlob> cadenceBlobs = dynablackCrud.retrieveDynamicTwoDBlackBlobMetadata(
            ccdModule, ccdOutput, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T, B extends AbstractModOutCadenceBlob> BlobSeries<T> retrieveCalBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        Class<B> calBlobType) {
        List<? extends CadenceBlob> cadenceBlobs = calCrud.retrieveCalBlobByModOut(
            ccdModule, ccdOutput, startCadence, endCadence, cadenceType,
            calBlobType);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobSeries<T> retrievePaUncertaintiesBlobSeries(
        CadenceBlobDataFactory<T> dataFactory, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence) {

        List<? extends CadenceBlob> cadenceBlobs = paCrud.retrieveUncertaintyBlobMetadata(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence);
        CadenceBlobCalculator<T> cadenceBlobCalculator = new CadenceBlobCalculator<T>(
            cadenceBlobs);

        return cadenceBlobCalculator.blobSeriesForCadenceInterval(dataFactory,
            startCadence, endCadence);
    }

    private <T> BlobData<T> retrieveUkirtImageBlobData(
        TargetBlobDataFactory<T> dataFactory, int keplerId) {

        List<? extends TargetBlob> targetBlobs = dvCrud.retrieveUkirtImageBlobMetadata(keplerId);
        TargetBlobCalculator<T> targetBlobCalculator = new TargetBlobCalculator<T>(
            targetBlobs);

        return targetBlobCalculator.blobDataForTarget(dataFactory, keplerId);
    }

    private <T> BlobData<T> retrieveTipBlobData(
        SkyGroupBlobDataFactory<T> dataFactory, int skyGroupId) {

        List<? extends SkyGroupBlob> skyGroupBlobs = tipCrud.retrieveTipBlobMetadata(skyGroupId);
        SkyGroupBlobCalculator<T> skyGroupBlobCalculator = new SkyGroupBlobCalculator<T>(
            skyGroupBlobs);

        return skyGroupBlobCalculator.blobDataForSkyGroup(dataFactory,
            skyGroupId);
    }

    private <T> BlobData<T> retrieveTipBlobData(
        SkyGroupBlobDataFactory<T> dataFactory, int skyGroupId, long createTime) {

        SkyGroupBlob skyGroupBlob = tipCrud.retrieveTipBlobMetadata(skyGroupId,
            createTime);

        return new BlobData<T>(
            dataFactory.blobDataForSkyGroupBlob(skyGroupBlob), skyGroupId);
    }

    /**
     * Convert the given long cadence blob series to a short cadence blob
     * series.
     * 
     * @param scTimes The short cadence timestamps for the blob series to be
     * returned.
     * @param lcTimes The long cadence timestamps for the given blob series.
     * @param blobSeries The long cadence blob series.
     * @return a blob series covering the given short cadence times.
     */
    public static BlobSeries<String> longToShortCadenceBlobSeries(
        TimestampSeries scTimes, TimestampSeries lcTimes,
        BlobSeries<String> blobSeries, int startShortCadence) {

        if (lcTimes.startTimestamps.length != blobSeries.blobIndices().length) {
            throw new IllegalArgumentException(
                String.format("lcTimes don't match blobSeries: "
                    + "(lcTimes.startTimestamps.length=%f) "
                    + " != (blobSeries.blobIndices().length=%f)",
                    lcTimes.startTimestamps.length,
                    blobSeries.blobIndices().length));
        }
        if (lcTimes.endMjd() < scTimes.startMjd()) {
            throw new IllegalArgumentException(String.format(
                "disjoint scTimes and lcTimes: "
                    + "(scTimes.startMjd()=%f) > (lcTimes.endMjd()=%f)",
                scTimes.startMjd(), lcTimes.endMjd()));
        }
        if (lcTimes.startMjd() > scTimes.endMjd()) {
            throw new IllegalArgumentException(String.format(
                "disjoint scTimes and lcTimes: "
                    + "(scTimes.endMjd()=%f) < lcTimes.startMjd()=%f)",
                scTimes.endMjd(), lcTimes.startMjd()));
        }

        int lcCount = blobSeries.gapIndicators().length;
        int[] lcBlobIndices = blobSeries.blobIndices();
        boolean[] lcBlobGaps = blobSeries.gapIndicators();

        int scCount = scTimes.gapIndicators.length;
        int[] scBlobIndices = new int[scCount];
        boolean[] scBlobGaps = new boolean[scCount];

        int lcIndex = 0;
        for (int scIndex = 0; scIndex < scCount; scIndex++) {
            // short cadence time gap
            if (scTimes.gapIndicators[scIndex]) {
                scBlobGaps[scIndex] = true;
                continue;
            }
            // skip long cadence time & blob gaps, skip short time gaps
            while (lcIndex < lcCount
                && (lcTimes.gapIndicators[lcIndex] || lcBlobGaps[lcIndex] || scTimes.midTimestamps[scIndex] > lcTimes.endTimestamps[lcIndex])) {
                lcIndex++;
            }
            if (lcIndex < lcCount) {
                if (scTimes.midTimestamps[scIndex] < lcTimes.startTimestamps[lcIndex]) {
                    scBlobGaps[scIndex] = true;
                } else {
                    scBlobIndices[scIndex] = lcBlobIndices[lcIndex];
                }
            } else {
                scBlobGaps[scIndex] = true;
            }
        }

        String[] blobFilenames = new String[blobSeries.blobFilenames().length];
        for (int i = 0; i < blobFilenames.length; i++) {
            blobFilenames[i] = (String) blobSeries.blobFilenames()[i];
        }

        return new BlobSeries<String>(scBlobIndices, scBlobGaps, blobFilenames,
            blobSeries.blobOriginators(), startShortCadence, startShortCadence
                + scBlobIndices.length - 1);
    }

    // blob data factory classes

    private abstract class AbstractCadenceBlobFileFactory implements
        CadenceBlobDataFactory<String> {

        public AbstractCadenceBlobFileFactory() {
        }

        public abstract FsId getFsId(CadenceBlob cadenceBlob);

        @Override
        public long originatorForCadenceBlob(CadenceBlob cadenceBlob) {
            return getOriginator((AbstractCadenceBlob) cadenceBlob);
        }

        public String getFileExtension(CadenceBlob cadenceBlob) {
            return ((AbstractCadenceBlob) cadenceBlob).getFileExtension();
        }

        @Override
        @SuppressWarnings("all")
        public String blobDataForCadenceBlob(CadenceBlob cadenceBlob) {

            File file = null;
            try {
                file = File.createTempFile("blob",
                    getFileExtension(cadenceBlob), outputDir);
                FileStoreClientFactory.getInstance()
                    .readBlob(getFsId(cadenceBlob), file);
            } catch (IOException ioe) {
                throw new FileStoreException(getFsId(cadenceBlob) + ": ", ioe);
            }

            return file.getName();
        }
    }

    private final class BackgroundBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public BackgroundBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((BackgroundBlobMetadata) cadenceBlob);
        }
    }

    private final class MotionBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public MotionBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((MotionBlobMetadata) cadenceBlob);
        }
    }

    private final class FfiMotionBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public FfiMotionBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((FfiMotionBlobMetadata) cadenceBlob);
        }
    }

    private final class CbvBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public CbvBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((CbvBlobMetadata) cadenceBlob);
        }
    }

    private final class PdcBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public PdcBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((PdcBlobMetadata) cadenceBlob);
        }
    }

    private class DynamicTwoDBlackBlobFileFactory extends
        AbstractCadenceBlobFileFactory {
        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((DynamicTwoDBlackBlobMetadata) cadenceBlob);
        }
    }

    private final class CalUncertaintyTransformationBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public CalUncertaintyTransformationBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((UncertaintyTransformationMetadata) cadenceBlob);
        }
    }

    private final class CalOneDBlackFitBlobFileFactory extends
        AbstractCadenceBlobFileFactory {
        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((CalOneDBlackFitMetadata) cadenceBlob);
        }
    }

    private final class SmearBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((SmearMetadata) cadenceBlob);
        }
    }

    private final class PaUncertaintyBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        public PaUncertaintyBlobFileFactory() {
        }

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((UncertaintyBlobMetadata) cadenceBlob);
        }
    }

    private final class FpgGeometryBlobFileFactory extends
        AbstractCadenceBlobFileFactory {

        @Override
        public FsId getFsId(CadenceBlob cadenceBlob) {
            return BlobOperations.getFsId((FpgGeometryBlobMetadata) cadenceBlob);
        }
    }

    private abstract class AbstractTargetBlobFileFactory implements
        TargetBlobDataFactory<String> {

        public AbstractTargetBlobFileFactory() {
        }

        public abstract FsId getFsId(TargetBlob targetBlob);

        public String getFileExtension(TargetBlob targetBlob) {
            return ((AbstractTargetBlob) targetBlob).getFileExtension();
        }

        @Override
        @SuppressWarnings("all")
        public String blobDataForTargetBlob(TargetBlob targetBlob) {

            if (targetBlob == null) {
                return "";
            }

            File file = null;
            try {
                file = File.createTempFile("blob",
                    getFileExtension(targetBlob), outputDir);
                FileStoreClientFactory.getInstance()
                    .readBlob(getFsId(targetBlob), file);
            } catch (IOException ioe) {
                throw new FileStoreException(getFsId(targetBlob) + ": ", ioe);
            }

            return file.getName();
        }
    }

    private final class UkirtImageBlobFileFactory extends
        AbstractTargetBlobFileFactory {

        @Override
        public FsId getFsId(TargetBlob targetBlob) {
            return BlobOperations.getFsId((UkirtImageBlobMetadata) targetBlob);
        }

        @Override
        public long keplerIdForTargetBlob(TargetBlob targetBlob) {
            return targetBlob.getKeplerId();
        }

    }

    private abstract class AbstractSkyGroupBlobFileFactory implements
        SkyGroupBlobDataFactory<String> {

        public AbstractSkyGroupBlobFileFactory() {
        }

        public abstract FsId getFsId(SkyGroupBlob skyGroupBlob);

        public String getFileExtension(SkyGroupBlob skyGroupBlob) {
            return ((AbstractSkyGroupBlob) skyGroupBlob).getFileExtension();
        }

        @Override
        @SuppressWarnings("all")
        public String blobDataForSkyGroupBlob(SkyGroupBlob skyGroupBlob) {

            if (skyGroupBlob == null) {
                return "";
            }

            File file = null;
            try {
                file = File.createTempFile("blob",
                    getFileExtension(skyGroupBlob), outputDir);
                FileStoreClientFactory.getInstance()
                    .readBlob(getFsId(skyGroupBlob), file);
            } catch (IOException ioe) {
                throw new FileStoreException(getFsId(skyGroupBlob) + ": ", ioe);
            }

            return file.getName();
        }
    }

    private final class TipBlobFileFactory extends
        AbstractSkyGroupBlobFileFactory {

        @Override
        public FsId getFsId(SkyGroupBlob skyGroupBlob) {
            return BlobOperations.getFsId((TipBlobMetadata) skyGroupBlob);
        }

        @Override
        public long skyGroupIdForSkyGroupBlob(SkyGroupBlob skyGroupBlob) {
            return skyGroupBlob.getSkyGroupId();
        }

    }
}
