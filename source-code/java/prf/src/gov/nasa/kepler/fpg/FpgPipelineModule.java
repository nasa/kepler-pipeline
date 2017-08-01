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

package gov.nasa.kepler.fpg;

import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.getMatlabBlobFsId;
import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType.FPG_GEOMETRY;
import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType.FPG_IMPORT;
import static gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType.FPG_RESULTS;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.mc.AbstractCadenceBlob;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.prf.FpgGeometryBlobMetadata;
import gov.nasa.kepler.hibernate.prf.FpgImportBlobMetadata;
import gov.nasa.kepler.hibernate.prf.FpgResultsBlobMetadata;
import gov.nasa.kepler.hibernate.prf.PrfCrud;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.FpgFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Focal plane geometry pipeline module. Given some initial geometry, and motion
 * polynomials this calculates a better geometry and a pointing solution.
 * 
 * @author Sean McCauliff
 * 
 */
public class FpgPipelineModule extends MatlabPipelineModule {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(FpgPipelineModule.class);

    public static final String MODULE_NAME = "fpg";

    private MjdToCadence mjdToCadence;
    private RaDec2PixOperations raDec2PixOperations;
    private BlobOperations blobOperations;
    private DataAccountabilityTrailCrud daTrailCrud;
    private PrfCrud prfCrud;
    private DoubleDbTimeSeriesCrud dddCrud;
    private GenericReportOperations reportOps;

    private final Set<Long> originatorTaskIds = new HashSet<Long>();

    private PipelineTask pipelineTask;

    private PipelineInstance pipelineInstance;

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(FpgModuleParameters.class);
        rv.add(CadenceRangeParameters.class);
        return rv;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {
        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;

        FpgModuleParameters fpgModuleParameters = pipelineTask.getParameters(FpgModuleParameters.class);

        CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);

        int startCadence = cadenceRangeParameters.getStartCadence();
        int endCadence = cadenceRangeParameters.getEndCadence();

        TimestampSeries cadenceTimes = getMjdToCadence().cadenceTimes(
            startCadence, endCadence);

        RaDec2PixModel raDec2PixModel = null;
        raDec2PixModel = getRaDec2PixOperations().retrieveRaDec2PixModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        BlobFileSeries[] blobSeries = motionPolynomialBlobs(startCadence,
            endCadence);

        String geoBlobName = retrieveGeometryBlobData(fpgModuleParameters);

        FpgInputs fpgInputs = new FpgInputs(cadenceTimes, fpgModuleParameters,
            raDec2PixModel, blobSeries, geoBlobName);

        FpgOutputs fpgOutputs = new FpgOutputs();
        executeAlgorithm(pipelineTask, fpgInputs, fpgOutputs);

        FpgGeometryBlobMetadata geoMeta = new FpgGeometryBlobMetadata(
            startCadence, endCadence, pipelineTask.getId(),
            fileExtension(fpgOutputs.getGeometryBlobFileName()));
        saveBlob(fpgOutputs.getGeometryBlobFileName(), FPG_GEOMETRY, geoMeta);

        FpgImportBlobMetadata fpgImportMeta = new FpgImportBlobMetadata(
            pipelineTask.getId(), startCadence, endCadence,
            fileExtension(fpgOutputs.getFpgImportFileName()));
        saveBlob(fpgOutputs.getFpgImportFileName(), FPG_IMPORT, fpgImportMeta);

        FpgResultsBlobMetadata resultsBlobMeta = new FpgResultsBlobMetadata(
            pipelineTask.getId(), startCadence, endCadence,
            fileExtension(fpgOutputs.getResultBlobFileName()));
        saveBlob(fpgOutputs.getResultBlobFileName(), FPG_RESULTS,
            resultsBlobMeta);

        FpgAttitudeSolution attitudeSolution = fpgOutputs.getSpacecraftAttitudeStruct();
        List<DoubleDbTimeSeries> attitudeSeries = attitudeSolution.toDoubleDbTimeSeries(
            startCadence, endCadence, pipelineTask.getId());
        for (DoubleDbTimeSeries attitudePart : attitudeSeries) {
            getDddCrud().create(attitudePart);
        }

        String reportFilename = fpgOutputs.getReportFileName();
        if (reportFilename.length() != 0) {
            getReportOps().createReport(pipelineTask, blobFile(reportFilename));
        }

        getDaTrailCrud().create(pipelineTask, originatorTaskIds);

    }

    private void saveBlob(String blobFileName, BlobSeriesType blobType,
        AbstractCadenceBlob cadenceBlob) {
        if (blobFileName.length() == 0) {
            return;
        }

        getPrfCrud().create(cadenceBlob);

        FsId blobId = getMatlabBlobFsId(blobType,
            cadenceBlob.getStartCadence(), cadenceBlob.getEndCadence(),
            pipelineTask.getId());
        File srcFile = blobFile(blobFileName);
        FileStoreClientFactory.getInstance()
            .writeBlob(blobId, pipelineTask.getId(), srcFile);

    }

    private String fileExtension(String blobFileName) {
        int dotIndex = blobFileName.indexOf('.');
        if (dotIndex == -1) {
            return "";
        }
        return blobFileName.substring(dotIndex);
    }

    private File blobFile(String blobFileName) {
        try {
            if (blobFileName.charAt(0) == '/') {
                return new File(blobFileName).getCanonicalFile();
            } else {
                return new File(getMatlabWorkingDir(), blobFileName).getCanonicalFile();
            }
        } catch (IOException ioe) {
            throw new PipelineException(
                "Error while attempting to resolve file returned from matlab with name \""
                    + blobFileName + "\".", ioe);
        }
    }

    /**
     * @param startCadence
     * @param endCadence
     * @param motionFilter
     * @return
     */
    private BlobFileSeries[] motionPolynomialBlobs(int startCadence,
        int endCadence) {

        List<BlobSeries<String>> blobSeries = new ArrayList<BlobSeries<String>>();
        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                BlobSeries<String> nameSeries = getBlobOperations().retrieveMotionBlobFileSeries(
                    ccdModule, ccdOutput, startCadence, endCadence);

                if (nameSeries.blobFilenames().length == 0) {
                    continue;
                }
                blobSeries.add(nameSeries);
                originatorTaskIds.addAll(Arrays.asList(ArrayUtils.toObject(nameSeries.blobOriginators())));
            }
        }

        BlobFileSeries[] blobFileSeries = new BlobFileSeries[blobSeries.size()];
        for (int i = 0; i < blobSeries.size(); i++) {
            blobFileSeries[i] = new BlobFileSeries(blobSeries.get(i));
        }
        return blobFileSeries;
    }

    /**
     * @param fpgModuleParameters
     * @return The name of the blob file, which may be an empty string if a blob
     * does not exist.
     */
    private String retrieveGeometryBlobData(
        FpgModuleParameters fpgModuleParameters) {

        if (fpgModuleParameters.isBootstrapGeometryModel()) {
            return "";
        }

        FpgGeometryBlobMetadata geometryMeta = null;
        if (fpgModuleParameters.getUseGeometryModelFromTaskId() != -1) {
            geometryMeta = getPrfCrud().retrieveGeometryBlobMetadata(
                fpgModuleParameters.getUseGeometryModelFromTaskId());
            if (geometryMeta == null) {
                throw new ModuleFatalProcessingException(
                    "UseGeometryModelFromTaskId parameter specified a bad task id ("
                        + fpgModuleParameters.getUseGeometryModelFromTaskId()
                        + ").");
            }
        } else {
            geometryMeta = getPrfCrud().retrieveLastGeometryBlobMetadata();
        }

        if (geometryMeta == null) {
            return "";
        }

        FsId geoBlobId = getMatlabBlobFsId(FPG_GEOMETRY,
            geometryMeta.getStartCadence(), geometryMeta.getEndCadence(),
            geometryMeta.getPipelineTaskId());
        String destFileName = "geometry-" + geoBlobId.name() + ".mat";
        File destFile = new File(getMatlabWorkingDir(), destFileName);
        long originatorTask = FileStoreClientFactory.getInstance()
            .readBlob(geoBlobId, destFile);
        originatorTaskIds.add(originatorTask);
        return destFileName;

    }

    private MjdToCadence getMjdToCadence() {
        if (mjdToCadence != null) {
            return mjdToCadence;
        }
        mjdToCadence = new MjdToCadence(CadenceType.LONG,
            new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        return mjdToCadence;
    }

    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    private RaDec2PixOperations getRaDec2PixOperations() {
        if (raDec2PixOperations != null) {
            return raDec2PixOperations;
        }
        raDec2PixOperations = new RaDec2PixOperations();
        return raDec2PixOperations;
    }

    void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    private BlobOperations getBlobOperations() {
        if (blobOperations != null) {
            return blobOperations;
        }

        blobOperations = new BlobOperations(getMatlabWorkingDir());
        return blobOperations;
    }

    void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    private PrfCrud getPrfCrud() {
        if (prfCrud != null) {
            return prfCrud;
        }

        prfCrud = new PrfCrud();
        return prfCrud;
    }

    void setPrfCrud(PrfCrud prfCrud) {
        this.prfCrud = prfCrud;
    }

    private DataAccountabilityTrailCrud getDaTrailCrud() {
        if (daTrailCrud != null) {
            return daTrailCrud;
        }
        daTrailCrud = new DataAccountabilityTrailCrud();
        return daTrailCrud;
    }

    void setDaTrailCrud(DataAccountabilityTrailCrud daTrailCrud) {
        this.daTrailCrud = daTrailCrud;
    }

    private DoubleDbTimeSeriesCrud getDddCrud() {
        if (dddCrud != null) {
            return dddCrud;
        }
        dddCrud = new DoubleDbTimeSeriesCrud();
        return dddCrud;
    }

    void setDddCrud(DoubleDbTimeSeriesCrud dddCrud) {
        this.dddCrud = dddCrud;
    }

    File getMatlabWorkingDir() {
        return allocateWorkingDir(pipelineTask);
    }

    private GenericReportOperations getReportOps() {
        if (reportOps == null) {
            reportOps = new GenericReportOperations();
        }
        return reportOps;
    }

    void setReportOps(GenericReportOperations reportOps) {
        this.reportOps = reportOps;
    }

}
