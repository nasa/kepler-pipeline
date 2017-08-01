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

package gov.nasa.kepler.pdc;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pdc.CbvBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.PdcBlobMetadata;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.List;
import java.util.Set;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is the Pre-Search Data Conditioning pipeline module. It uses relative
 * flux time series to create corrected flux time series.
 * 
 * SOC 1065.PDC.1: SOC processing shall be able to process input data sets
 * received out of time order. This requirement is satisfied by DR.
 * 
 * @author jgunter
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class PdcOutputsStorer {

    private static final Log log = LogFactory.getLog(PdcOutputsStorer.class);

    static final int MJD_GAP_FILL_VALUE = 0;

    private FluxType fluxType;
    private CadenceType cadenceType;
    private int cadenceStart;
    private int cadenceEnd;

    private TargetCrud targetCrud = new TargetCrud();
    private LogCrud logCrud = new LogCrud();
    private PdcCrud pdcCrud = new PdcCrud();
    private DataAnomalyOperations dataAnomalyOperations;
    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();
    private ProducerTaskIdsStream producerTaskIdsStream = new ProducerTaskIdsStream();

    private boolean mapEnabled;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;
    private ModOutCadenceUowTask task;

    private MjdToCadence mjdToCadence;
    private MjdToCadence mjdToLongCadence;

    private File matlabWorkingDir;

    public PdcOutputsStorer() {
    }

    private String getModuleName() {
        return PdcPipelineModule.MODULE_NAME;
    }

    public void storeOutputs(PipelineTask pipelineTask, File matlabWorkingDir,
        PdcOutputs pdcOutputs) throws PipelineException {

        setMatlabWorkingDir(matlabWorkingDir);

        mapEnabled = pipelineTask.getParameters(PdcModuleParameters.class)
            .isMapEnabled();

        setPipelineInstance(pipelineTask.getPipelineInstance());
        setPipelineTask(pipelineTask);

        task = pipelineTask.uowTaskInstance();

        cadenceStart = task.getStartCadence();
        cadenceEnd = task.getEndCadence();

        log.info("cadenceStart: " + cadenceStart);
        log.info("cadenceEnd: " + cadenceEnd);
        log.info("pipelineTask.getId(): " + pipelineTask.getId());

        FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);
        fluxType = FluxType.valueOf(fluxTypeParameters.getFluxType());
        log.info("fluxType: " + fluxType);

        CadenceTypePipelineParameters pipelineParams = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
        log.info("pipelineParams: " + pipelineParams);
        cadenceType = CadenceType.valueOf(pipelineParams.getCadenceType());
        log.info("cadenceType: " + cadenceType);

        // Determine targetTableType.
        TargetTable.TargetType targetTableType = TargetTable.TargetType.valueOf(cadenceType);

        // A single TargetTableLog should be available for the supplied
        // cadence range.
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            targetTableType, cadenceStart, cadenceEnd);
        if (targetTableLogs.size() == 0) {
            throw new ModuleFatalProcessingException(
                String.format(
                    "%s cadence target table missing for cadence interval [%d, %d].",
                    targetTableType, cadenceStart, cadenceEnd));
        }

        if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException(String.format(
                "Found %d %s target tables for [%d, %d] cadence interval.",
                targetTableLogs.size(), targetTableType, cadenceStart,
                cadenceEnd));
        }

        TargetTableLog targetTableLog = targetTableLogs.get(0);
        log.debug("targetTableLog.getCadenceStart(): "
            + targetTableLog.getCadenceStart());
        log.debug("targetTableLog.getCadenceEnd(): "
            + targetTableLog.getCadenceEnd());

        storeOutputsInternal(pdcOutputs);
    }

    public void storeProducerTaskIds(File taskWorkingDir) {
        if (pipelineTask != null) {
            log.info("Creating data accountability trail");
            Set<Long> producerTaskIds = producerTaskIdsStream.read(taskWorkingDir);
            daCrud.create(pipelineTask, producerTaskIds);
        }
    }

    private TimestampSeries retrieveCadenceTimes() {
        return getMjdToCadence().cadenceTimes(cadenceStart, cadenceEnd);
    }

    protected void storeOutputsInternal(PdcOutputs pdcOutputs) {
        log.info("Storing target data");
        storeTargetOutputData(pdcOutputs.getTargetResultsStruct());

        if (mapEnabled && cadenceType == CadenceType.LONG) {
            boolean[] useCbvBlobs = pipelineTask.getParameters(
                PdcMapParameters.class)
                .getUseBasisVectorsFromBlob();
            boolean useBasisVectorsFromBlob = false;
            for (boolean useCbvBlob : useCbvBlobs) {
                if (useCbvBlob) {
                    useBasisVectorsFromBlob = true;
                    break;
                }
            }

            for (PdcOutputChannelData pdcChannelData : pdcOutputs.getChannelData()) {
                int ccdModule = pdcChannelData.getCcdModule();
                int ccdOutput = pdcChannelData.getCcdOutput();
                log.info("Storing PDC blob for " + ccdModule + ", " + ccdOutput);

                storePdcBlob(ccdModule, ccdOutput,
                    pdcChannelData.getPdcBlobFileName());
                if (!useBasisVectorsFromBlob) {
                    log.info("Storing CBV blob for " + ccdModule + ", "
                        + ccdOutput);
                    storeCbvBlob(ccdModule, ccdOutput,
                        pdcChannelData.getCbvBlobFileName());
                }
            }
        }

        log.info("Generating alerts");
        storeAlerts(pdcOutputs);
    }

    private void storePdcBlob(int ccdModule, int ccdOutput, String blobFileName) {

        if (blobFileName != null && blobFileName.length() > 0) {
            PdcBlobMetadata pdcBlobMetadata = new PdcBlobMetadata(
                pipelineTask.getId(), ccdModule, ccdOutput, cadenceType,
                task.getStartCadence(), task.getEndCadence(),
                FilenameUtils.getExtension(blobFileName));
            pdcCrud.createPdcBlobMetadata(pdcBlobMetadata);

            FileStoreClientFactory.getInstance()
                .writeBlob(BlobOperations.getFsId(pdcBlobMetadata),
                    pipelineTask.getId(),
                    new File(getMatlabWorkingDir(), blobFileName));
        }
    }

    private void storeCbvBlob(int ccdModule, int ccdOutput, String blobFileName) {

        if (blobFileName != null && blobFileName.length() > 0) {
            CbvBlobMetadata cbvBlobMetadata = new CbvBlobMetadata(
                pipelineTask.getId(), ccdModule, ccdOutput, cadenceType,
                task.getStartCadence(), task.getEndCadence(),
                FilenameUtils.getExtension(blobFileName));
            pdcCrud.createCbvBlobMetadata(cbvBlobMetadata);

            FileStoreClientFactory.getInstance()
                .writeBlob(BlobOperations.getFsId(cbvBlobMetadata),
                    pipelineTask.getId(),
                    new File(getMatlabWorkingDir(), blobFileName));
        }
    }

    // SOC PDC1: log a warning if the complete set of ancillary data required is
    // unavailable.
    protected void storeAlerts(PdcOutputs pdcOutputs) {
        if (pdcOutputs.getAlerts()
            .size() > 0) {
            for (ModuleAlert alert : pdcOutputs.getAlerts()) {
                AlertServiceFactory.getInstance()
                    .generateAlert(getModuleName(), pipelineTask.getId(),
                        Severity.valueOf(alert.getSeverity()),
                        alert.getMessage() + ": time=" + alert.getTime());
            }
        }
    }

    // SOC 71.PDC.1 replace previously generated data for same UOW.
    // SOC 126.PDC.10 new PDC results shall replace existing PDC results when
    // run on same data set.
    // SOC 126.PDC.9 store results with fluxType (SAP, OAP, DIA).
    // SOC PI3.PDC.1 outputs tagged with the taskId (see below).
    private void storeTargetOutputData(List<PdcTargetOutputData> outputTargets) {
        // Batch time series writes to minimize filestore calls.
        List<TimeSeries> timeSeriesList = newArrayList();
        List<FloatMjdTimeSeries> mjdTimeSeriesList = newArrayList();

        TimestampSeries cadenceTimes = retrieveCadenceTimes();
        double startMjd = cadenceTimes.startMjd();
        double endMjd = cadenceTimes.endMjd();

        for (PdcTargetOutputData outputTarget : outputTargets) {
            int keplerId = outputTarget.getKeplerId();

            timeSeriesList.addAll(outputTarget.getCorrectedFluxTimeSeries()
                .toTimeSeries(
                    PdcFsIdFactory.getFluxTimeSeriesFsId(
                        PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX,
                        fluxType, cadenceType, keplerId),
                    PdcFsIdFactory.getFluxTimeSeriesFsId(
                        PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
                        fluxType, cadenceType, keplerId),
                    PdcFsIdFactory.getFilledIndicesFsId(
                        PdcFilledIndicesTimeSeriesType.FILLED_INDICES,
                        fluxType, cadenceType, keplerId), cadenceStart,
                    cadenceEnd, pipelineTask.getId()));

            timeSeriesList.addAll(outputTarget.getHarmonicFreeCorrectedFluxTimeSeries()
                .toTimeSeries(
                    PdcFsIdFactory.getFluxTimeSeriesFsId(
                        PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX,
                        fluxType, cadenceType, keplerId),
                    PdcFsIdFactory.getFluxTimeSeriesFsId(
                        PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX_UNCERTAINTIES,
                        fluxType, cadenceType, keplerId),
                    PdcFsIdFactory.getFilledIndicesFsId(
                        PdcFilledIndicesTimeSeriesType.HARMONIC_FREE_FILLED_INDICES,
                        fluxType, cadenceType, keplerId), cadenceStart,
                    cadenceEnd, pipelineTask.getId()));

            timeSeriesList.add(outputTarget.toDiscontinuitiesTimeSeries(
                PdcFsIdFactory.getDiscontinuityIndicesFsId(fluxType,
                    cadenceType, keplerId), cadenceStart, cadenceEnd,
                pipelineTask.getId()));

            timeSeriesList.addAll(outputTarget.getPdcGoodnessMetric()
                .toTimeSeries(fluxType, cadenceType, cadenceStart, cadenceEnd,
                    keplerId, outputTarget.getCorrectedFluxTimeSeries()
                        .getGapIndicators(), pipelineTask.getId()));

            mjdTimeSeriesList.addAll(outputTarget.getOutliers()
                .toTimeSeries(
                    PdcFsIdFactory.getOutlierTimerSeriesId(
                        PdcOutliersTimeSeriesType.OUTLIERS, fluxType,
                        cadenceType, keplerId),
                    PdcFsIdFactory.getOutlierTimerSeriesId(
                        PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES,
                        fluxType, cadenceType, keplerId), cadenceStart,
                    startMjd, endMjd, pipelineTask.getId(), mjdToCadence));

            mjdTimeSeriesList.addAll(outputTarget.getHarmonicFreeOutliers()
                .toTimeSeries(
                    PdcFsIdFactory.getOutlierTimerSeriesId(
                        PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIERS,
                        fluxType, cadenceType, keplerId),
                    PdcFsIdFactory.getOutlierTimerSeriesId(
                        PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIER_UNCERTAINTIES,
                        fluxType, cadenceType, keplerId), cadenceStart,
                    startMjd, endMjd, pipelineTask.getId(), mjdToCadence));

            pdcCrud.createPdcProcessingCharacteristics(outputTarget.getPdcProcessingCharacteristics()
                .getDbInstance(pipelineTask.getId(), fluxType, cadenceType,
                    keplerId, cadenceStart, cadenceEnd));
        }

        // Store all time series in the filestore.
        FileStoreClient fsClient = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
        fsClient.writeTimeSeries(timeSeriesList.toArray(new TimeSeries[0]));
        fsClient.writeMjdTimeSeries(mjdTimeSeriesList.toArray(new FloatMjdTimeSeries[0]));
    }

    MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), cadenceType);
        }

        return mjdToCadence;
    }

    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    MjdToCadence getMjdToLongCadence() {
        if (mjdToLongCadence == null) {
            mjdToLongCadence = new MjdToCadence(logCrud,
                getDataAnomalyOperations(), CadenceType.LONG);
        }

        return mjdToLongCadence;
    }

    void setMjdToLongCadence(MjdToCadence mjdToLongCadence) {
        this.mjdToLongCadence = mjdToLongCadence;
    }

    File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    void setMatlabWorkingDir(File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }

    private DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }

        return dataAnomalyOperations;
    }

    void setDataAnomalyOperations(DataAnomalyOperations dataAnomalyOperations) {
        this.dataAnomalyOperations = dataAnomalyOperations;
    }

    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    void setPdcCrud(PdcCrud pdcCrud) {
        this.pdcCrud = pdcCrud;
    }

    /**
     * Sets this module's pipeline instance. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    void setPipelineInstance(final PipelineInstance pipelineInstance) {

        checkNotNull(pipelineInstance, "pipelineInstance can't be null");

        this.pipelineInstance = pipelineInstance;
        if (pipelineTask != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

}
