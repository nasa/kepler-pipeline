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

package gov.nasa.kepler.pdq;

import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.fc.flatfield.FlatFieldOperations;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fc.twodblack.TwoDBlackOperations;
import gov.nasa.kepler.fc.undershoot.UndershootOperations;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.RefPixelLog;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.pdq.AttitudeAdjustment;
import gov.nasa.kepler.hibernate.pdq.FocalPlaneMetricReport;
import gov.nasa.kepler.hibernate.pdq.ModuleOutputMetricReport;
import gov.nasa.kepler.hibernate.pdq.PdqCrud;
import gov.nasa.kepler.hibernate.pdq.PdqDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pdq.RefPixelPipelineParameters;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.refpixels.RefPixelDescriptor;
import gov.nasa.kepler.mc.refpixels.RefPixelFileReader;
import gov.nasa.kepler.mc.refpixels.TimeSeriesBuffer;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.module.MatlabSerializerImpl;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.EOFException;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Pipeline module for processing PDQ data.
 * <p>
 * The processing is driven by a target table id which in turn is used to fetch
 * all the relevant ref pixel logs. The ref pixel logs contain a flag that is
 * set after the ref pixel data has been processed. Only the ref pixel data
 * associated with ref pixel log entries whose processed flag has not been set
 * are processed when this module runs.
 * <p>
 * All the PDQ metric time series produced by previous runs for a given target
 * table are read from the file store.
 * <p>
 * All the targets for the given target table are processed in module/output
 * order and appended to one of three lists depending upon whether the target is
 * of type background, collateral, or stellar. The target definitions are
 * retained internally and subsequently reused for parsing the ref pixel files.
 * <p>
 * The new ref pixel files are read one at a time and the parsed data is
 * buffered into integer time series per pixel. The target lists are traversed
 * and the target's pixels are updated with the buffered time series values.
 * <p>
 * Information from the following sources are required to prepare the input
 * data: ref pixel logs, space craft clock coefficients, target table, targets,
 * target definitions, Ra and Dec for stellar targets (KIC), numerous FC models,
 * existing PDQ metric time series data, and the raw ref pixel files (blobs).
 * <p>
 * After successfully executing the science algorithm the updated PDQ time
 * series, attitude adjustments, and summary reports are persisted.
 * <p>
 * This module outputs the following information: time series, summary metric
 * per time series, and attitude adjustment.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PdqPipelineModule extends MatlabPipelineModule {

    private static final Log log = LogFactory.getLog(PdqPipelineModule.class);

    private static final String EMPTY_STRING = "";

    public static final String MODULE_NAME = "pdq";

    protected PdqInputs inputs;
    protected PdqOutputs outputs;

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;

    private CompressionCrud compressionCrud = new CompressionCrud();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();
    private FlatFieldOperations flatFieldOperations = new FlatFieldOperations();
    private GainOperations gainOperations = new GainOperations();
    private GenericReportOperations genericReportOperations = new GenericReportOperations();
    private CelestialObjectOperations celestialObjectOperations;
    private LogCrud logCrud = new LogCrud();
    private PdqCrud pdqCrud = new PdqCrud();
    private PdqDbTimeSeriesCrud pdqDbTimeSeriesCrud = new PdqDbTimeSeriesCrud();
    private PrfOperations prfOperations = new PrfOperations();
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private ReadNoiseOperations readNoiseOperations = new ReadNoiseOperations();
    private TargetCrud targetCrud = new TargetCrud();
    private TwoDBlackOperations twoDBlackOperations = new TwoDBlackOperations();
    private UndershootOperations undershootOperations = new UndershootOperations();
    private File matlabWorkingDir;

    private int targetTableId;
    private TargetTable targetTable;
    private List<RefPixelLog> newRefPixelLogs;
    private final List<PdqTarget> backgroundPdqTargets = new ArrayList<PdqTarget>();
    private final List<PdqTarget> collateralPdqTargets = new ArrayList<PdqTarget>();
    private final List<PdqStellarTarget> stellarPdqTargets = new ArrayList<PdqStellarTarget>();
    private Map<Integer, List<TargetDefinition>> moduleOutputDefinitions = new HashMap<Integer, List<TargetDefinition>>(
        FcConstants.MODULE_OUTPUTS);
    private Set<Integer> moduleOutputsWithTargets = new HashSet<Integer>();

    private final Set<Long> producerTaskIds = new HashSet<Long>();

    // For debugging only.
    private boolean trace;

    private int minEndCadence;

    // Same as pipeline module parameter
    private boolean forceReprocessing;

    private PdqModuleParameters pdqModuleParameters;

    public PdqPipelineModule() {
        super();
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    /**
     * Setup and initialization of this pipeline for the given task. Extracts
     * the target table external id from the pipeline parameters for the current
     * pipeline task.
     */
    public void initializeTask() {
        SingleUowTask task = getPipelineTask().uowTaskInstance();

        log.info("[" + getModuleName() + "]instance node uow = " + task);

        RefPixelPipelineParameters pipelineParams = getPipelineTask().getParameters(
            RefPixelPipelineParameters.class);
        targetTableId = pipelineParams.getReferencePixelTargetTableId();
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(RefPixelPipelineParameters.class);
        requiredParameters.add(PdqModuleParameters.class);
        return requiredParameters;
    }

    @Override
    public void processTask(final PipelineInstance pipelineInstance,
        final PipelineTask pipelineTask) {

        setPipelineInstance(pipelineInstance);
        setPipelineTask(pipelineTask);

        PdqInputs inputs = createInputs();

        retrieveInputs(inputs);

        PdqOutputs outputs = createOutputs();

        if (pdqModuleParameters.isExecuteAlgorithmEnabled()) {
            executeAlgorithm(pipelineTask, inputs, outputs);
            storeOutputs(outputs);
        } else {
            new MatlabSerializerImpl().serializeInputsWithSeqNum(pipelineTask,
                inputs, allocateWorkingDir(pipelineTask), 0);
        }
    }

    /**
     * Caches the producer's pipeline task id for the given blob.
     * 
     * @param blobResult
     */
    protected void addToDataAccountability(final BlobResult blobResult) {
        long taskId = blobResult.originator();
        producerTaskIds.add(taskId);
    }

    /**
     * Retrieve all the inputs for a target table.
     */
    protected void retrieveInputs(final PdqInputs pdqInputs) {
        log.info("[" + getModuleName() + "]start");

        IntervalMetricKey metricKey = IntervalMetric.start();
        try {
            setInputs(pdqInputs);

            initializeTask();

            pdqInputs.setPipelineInstanceId(getPipelineInstance().getId());

            pdqModuleParameters = getPipelineTask().getParameters(
                PdqModuleParameters.class);
            getInputs().setPdqModuleParameters(pdqModuleParameters);
            forceReprocessing = pdqModuleParameters.isForceReprocessing();

            log.info("retrieve target table: " + targetTableId);
            targetTable = targetCrud.retrieveUplinkedTargetTable(targetTableId,
                TargetType.REFERENCE_PIXEL);

            // get all ref pixel log entries for the current target table id
            log.info("retrieve all ref pixel logs for target table: "
                + targetTableId);
            List<RefPixelLog> refPixelLogs = logCrud.retrieveAllRefPixelLogForTargetTable(targetTableId);
            if (refPixelLogs == null || refPixelLogs.isEmpty()) {
                throw new ModuleFatalProcessingException(
                    "no reference pixel data exists");
            }
            PdqTimestampSeries timestamps = new PdqTimestampSeries(
                refPixelLogs, pdqModuleParameters.getExcludeCadences());

            minEndCadence = timestamps.processedCount() - 1;
            if (!forceReprocessing && timestamps.forcesReprocessing()) {
                forceReprocessing = true;
            }
            refPixelLogs = timestamps.nonExcludedLogs();
            timestamps.updateExcludedLogs();
            PdqTimestampSeries updatedTimestamps = timestamps.getUpdatedInstance(forceReprocessing);
            if (refPixelLogs.isEmpty()) {
                throw new ModuleFatalProcessingException(
                    "all reference pixel data excluded");
            }

            double[] processedTimes = new double[0];
            if (!forceReprocessing) {
                processedTimes = updatedTimestamps.processedTimes();
            }

            if (processedTimes.length > 0) {
                newRefPixelLogs = timestamps.unprocessedLogs();
            } else {
                newRefPixelLogs = refPixelLogs;
            }
            if (newRefPixelLogs.isEmpty()) {
                throw new ModuleFatalProcessingException(
                    "no new reference pixel data available");
            }
            pdqInputs.setPdqTimestampSeries(updatedTimestamps);

            // retrieve PDQ time series data from previous runs
            if (processedTimes.length > 0) {
                log.info("retrieve all pdq time series");
                PdqTsData inputPdqTsData = new PdqTsData(pdqDbTimeSeriesCrud,
                    targetTableId, producerTaskIds, processedTimes);
                pdqInputs.setInputPdqTsData(inputPdqTsData);
            }

            double startMjd = timestamps.startMjd();
            double endMjd = timestamps.endMjd();

            log.info("retrieve the spacecraft configuration maps");
            List<ConfigMap> configMaps = configMapOperations.retrieveConfigMaps(
                startMjd, endMjd);
            if (configMaps == null || configMaps.size() < 1) {
                throw new ModuleFatalProcessingException(
                    "no config maps available for [" + startMjd + "," + endMjd
                        + "] mjd range.");
            }
            getInputs().setConfigMaps(configMaps);

            log.info("retrieve the gain model");
            GainModel gainModel = gainOperations.retrieveGainModel(startMjd,
                endMjd);
            pdqInputs.setGainModel(gainModel);

            log.info("retrieve the read noise model");
            ReadNoiseModel readNoiseModel = readNoiseOperations.retrieveReadNoiseModel(
                startMjd, endMjd);
            pdqInputs.setReadNoiseModel(readNoiseModel);

            log.info("retrieve the raDec2Pix model");
            RaDec2PixModel raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel(
                startMjd, endMjd);
            pdqInputs.setRaDec2PixModel(raDec2PixModel);

            log.info("retrieve the undershoot model");
            UndershootModel undershootModel = undershootOperations.retrieveUndershootModel(
                startMjd, endMjd);
            pdqInputs.setUndershootModel(undershootModel);

            List<RequantTable> requantTables = retrieveRequantTables(newRefPixelLogs);
            pdqInputs.setRequantTables(requantTables);

            // build target lists while retaining target definitions for reuse
            log.info("retrieve target lists for target table: " + targetTableId);
            List<TargetDefinition> targetDefs = createTargetLists(targetTable);

            if (log.isInfoEnabled()) {
                logTargetListReports();
            }

            String[] prfModelFilenames = retrievePrfModels(startMjd);
            pdqInputs.setPrfModelFilenames(prfModelFilenames);

            TwoDBlackModel[] twoDBlackModels = retrieveTwoDBlackModels(
                startMjd, endMjd);
            pdqInputs.setTwoDBlackModels(twoDBlackModels);

            FlatFieldModel[] flatFieldModels = retrieveFlatFieldModels(
                startMjd, endMjd);
            pdqInputs.setFlatFieldModels(flatFieldModels);

            // read and buffer all ref pixel data from new ref pixel log files
            log.info("read all reference pixel data from "
                + newRefPixelLogs.size() + " files");
            TimeSeriesBuffer timeSeriesBuffer = extractRefPixelTimeSeriesData(
                newRefPixelLogs, targetDefs);

            // traverse target lists and set pixel time series values
            log.info("populate target lists with new reference pixel data");
            setTimeSeries(targetTableId, timeSeriesBuffer);

            pdqInputs.setBackgroundPdqTargets(backgroundPdqTargets);
            pdqInputs.setCollateralPdqTargets(collateralPdqTargets);
            pdqInputs.setStellarPdqTargets(stellarPdqTargets);
            if (log.isInfoEnabled()) {
                logTargetListReports();
            }
        } catch (IllegalArgumentException iae) {
            throw new ModuleFatalProcessingException(iae.getMessage(), iae);
        } catch (IOException ioe) {
            throw new PipelineException(ioe.getMessage(), ioe);
        } finally {
            IntervalMetric.stop("pdq.PdqPipelineModule.retrieveInputs",
                metricKey);
        }
    }

    protected PdqInputs createInputs() {
        return new PdqInputs();
    }

    protected PdqOutputs createOutputs() {
        return new PdqOutputs();
    }

    /**
     * Store all the outputs to the database and file store and generate alerts
     * as appropriate. All outputs are associated with the current pipeline task
     * id (pipelineTask.getId()).
     * 
     * @param outputs
     */
    protected void storeOutputs(final PdqOutputs pdqOutputs) {
        IntervalMetricKey metricKey = IntervalMetric.start();
        try {
            setOutputs(pdqOutputs);

            long pipelineTaskId = getPipelineTask().getId();

            // store time series
            if (pdqOutputs.getOutputPdqTsData() != null) {
                log.info("write all time series to file store");
                pdqOutputs.getOutputPdqTsData()
                    .writeTimeSeries(targetTableId, pipelineTaskId,
                        minEndCadence);
                pdqOutputs.getOutputPdqTsData()
                    .createDbTimeSeries(pdqDbTimeSeriesCrud, targetTableId,
                        pipelineTaskId, minEndCadence);
            }

            // store module output reports
            List<PdqModuleOutputReport> moduleOutputReports = pdqOutputs.getPdqModuleOutputReports();
            if (moduleOutputReports != null && !moduleOutputReports.isEmpty()) {
                log.info("delete existing module output reports");
                pdqCrud.deleteModuleOutputMetricReports(targetTable);
                log.info("create module output reports");
                for (PdqModuleOutputReport report : moduleOutputReports) {
                    List<ModuleOutputMetricReport> metricReports = report.createModuleOutputMetricReports(
                        targetTable, pipelineTask);
                    pdqCrud.createModuleOutputMetricReports(metricReports);
                    generateAlerts(report.getCcdModule(),
                        report.getCcdOutput(), report);
                }
            }

            // store focal plane report
            PdqFocalPlaneReport focalPlaneReport = pdqOutputs.getPdqFocalPlaneReport();
            if (focalPlaneReport != null) {
                log.info("delete existing focal plane report");
                pdqCrud.deleteFocalPlaneMetricReports(targetTable);
                log.info("create focal plane report");
                List<FocalPlaneMetricReport> metricReports = focalPlaneReport.createFocalPlaneMetricReports(
                    targetTable, pipelineTask);
                pdqCrud.createFocalPlaneMetricReports(metricReports);
                generateAlerts(focalPlaneReport);
            }

            // store attitude adjustments
            List<AttitudeAdjustment> attitudeAdjustments = createAttitudeAdjustments(
                getPipelineTask(), newRefPixelLogs,
                pdqOutputs.getAttitudeAdjustments());
            if (attitudeAdjustments != null && !attitudeAdjustments.isEmpty()) {
                log.info("create attitude adjustments");
                pdqCrud.createAttitudeAdjustments(attitudeAdjustments);
            }

            // update ref pixel logs
            log.info("update ref pixel logs");
            for (RefPixelLog refPixelLog : newRefPixelLogs) {
                refPixelLog.setProcessed(true);
            }

            // store generic report
            if (pdqOutputs.getReportFilename() != null
                && pdqOutputs.getReportFilename()
                    .length() > 0) {
                log.info("create generic report");
                File file = new File(getMatlabWorkingDir(),
                    pdqOutputs.getReportFilename());
                genericReportOperations.createReport(pipelineTask, file);
            }

            // Update the data accountability trail.
            log.info("update data accountability");
            daCrud.create(pipelineTask, producerTaskIds);
            log.info("end processing");
        } catch (IllegalArgumentException iae) {
            throw new ModuleFatalProcessingException(iae.getMessage(), iae);
        } finally {
            IntervalMetric.stop("pdq.PdqPipelineModule.storeOutputs", metricKey);
        }
    }

    private TwoDBlackModel[] retrieveTwoDBlackModels(final double startMjd,
        final double endMjd) {

        // MATLAB expects a list of length FcConstants.MODULE_OUTPUTS
        TwoDBlackModel[] twoDBlackModels = new TwoDBlackModel[FcConstants.MODULE_OUTPUTS];
        for (int channelNumber = 1; channelNumber <= FcConstants.MODULE_OUTPUTS; channelNumber++) {
            Pair<Integer, Integer> channel = FcConstants.getModuleOutput(channelNumber);
            int ccdModule = channel.left;
            int ccdOutput = channel.right;

            TwoDBlackModel twoDBlackModel = null;
            if (getModuleOutputsWithTargets().contains(channelNumber)) {
                twoDBlackModel = twoDBlackOperations.retrieveTwoDBlackModel(
                    startMjd, endMjd, ccdModule, ccdOutput,
                    getModuleOutputDefinitions().get(channelNumber));
            } else {
                // This sucks but Persistable requires arrays to be fully
                // populated.
                twoDBlackModel = new TwoDBlackModel(new double[0],
                    new float[0][][], new float[0][][]);
            }
            twoDBlackModels[channelNumber - 1] = twoDBlackModel;
        }
        return twoDBlackModels;
    }

    private FlatFieldModel[] retrieveFlatFieldModels(final double startMjd,
        final double endMjd) {

        // MATLAB expects a list of length FcConstants.MODULE_OUTPUTS
        FlatFieldModel[] flatFieldModels = new FlatFieldModel[FcConstants.MODULE_OUTPUTS];
        for (int channelNumber = 1; channelNumber <= FcConstants.MODULE_OUTPUTS; channelNumber++) {
            Pair<Integer, Integer> channel = FcConstants.getModuleOutput(channelNumber);
            int ccdModule = channel.left;
            int ccdOutput = channel.right;

            FlatFieldModel flatFieldModel = null;
            if (getModuleOutputsWithTargets().contains(channelNumber)) {
                flatFieldModel = flatFieldOperations.retrieveFlatFieldModel(
                    startMjd, endMjd, ccdModule, ccdOutput,
                    getModuleOutputDefinitions().get(channelNumber));
            } else {
                // This sucks but Persistable requires arrays to be fully
                // populated.
                flatFieldModel = new FlatFieldModel(new double[0],
                    new float[0][][], new float[0][][]);
            }
            flatFieldModels[channelNumber - 1] = flatFieldModel;
        }
        return flatFieldModels;
    }

    private String[] retrievePrfModels(final double startMjd)
        throws IOException {

        // MATLAB expects a list of length FcConstants.MODULE_OUTPUTS
        String[] prfModelFilenames = new String[FcConstants.MODULE_OUTPUTS];
        for (int channelNumber = 1; channelNumber <= FcConstants.MODULE_OUTPUTS; channelNumber++) {
            Pair<Integer, Integer> channel = FcConstants.getModuleOutput(channelNumber);
            int ccdModule = channel.left;
            int ccdOutput = channel.right;

            String filename = null;
            if (getModuleOutputsWithTargets().contains(channelNumber)) {
                PrfModel prfModel = prfOperations.retrievePrfModel(startMjd,
                    ccdModule, ccdOutput);
                filename = String.format("prf%02d%d.dat", ccdModule, ccdOutput);
                File file = new File(getMatlabWorkingDir(), filename);
                prfModel.writeBlob(file);
            } else {
                // This sucks but Persistable requires arrays to be fully
                // populated.
                filename = EMPTY_STRING;
            }
            prfModelFilenames[channelNumber - 1] = filename;
        }
        return prfModelFilenames;
    }

    private List<RequantTable> retrieveRequantTables(
        List<RefPixelLog> refPixelLogs) {

        Map<Integer, RequantTable> requantTablesById = new TreeMap<Integer, RequantTable>();
        for (RefPixelLog refPixelLog : refPixelLogs) {
            double mjd = refPixelLog.getMjd();
            RequantTable requantTable = requantTablesById.get(refPixelLog.getCompressionTableId());
            if (requantTable == null) {
                gov.nasa.kepler.hibernate.gar.RequantTable hibernateRequant = compressionCrud.retrieveUplinkedRequantTable(refPixelLog.getCompressionTableId());
                if (hibernateRequant == null) {
                    throw new IllegalStateException(
                        refPixelLog.getCompressionTableId()
                            + ": no such compression table");
                }
                requantTable = new RequantTable(hibernateRequant, mjd);
                requantTablesById.put(refPixelLog.getCompressionTableId(),
                    requantTable);
            } else {
                requantTable.setStartMjd(Math.min(mjd,
                    requantTable.getStartMjd()));
            }
        }
        return new ArrayList<RequantTable>(requantTablesById.values());
    }

    private void generateAlerts(final int ccdModule, final int ccdOutput,
        final PdqModuleOutputReport moduleOutputReport) {

        if (moduleOutputReport.getBackgroundLevel() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.BACKGROUND_LEVEL,
                moduleOutputReport.getBackgroundLevel()
                    .getAlerts());
        }
        if (moduleOutputReport.getBlackLevel() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.BLACK_LEVEL,
                moduleOutputReport.getBlackLevel()
                    .getAlerts());
        }
        if (moduleOutputReport.getCentroidsMeanCol() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.CENTROIDS_MEAN_COL,
                moduleOutputReport.getCentroidsMeanCol()
                    .getAlerts());
        }
        if (moduleOutputReport.getCentroidsMeanRow() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.CENTROIDS_MEAN_ROW,
                moduleOutputReport.getCentroidsMeanRow()
                    .getAlerts());
        }
        if (moduleOutputReport.getDarkCurrent() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.DARK_CURRENT,
                moduleOutputReport.getDarkCurrent()
                    .getAlerts());
        }
        if (moduleOutputReport.getDynamicRange() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.DYNAMIC_RANGE,
                moduleOutputReport.getDynamicRange()
                    .getAlerts());
        }
        if (moduleOutputReport.getEncircledEnergy() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.ENCIRCLED_ENERGY,
                moduleOutputReport.getEncircledEnergy()
                    .getAlerts());
        }
        if (moduleOutputReport.getMeanFlux() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.MEAN_FLUX,
                moduleOutputReport.getMeanFlux()
                    .getAlerts());
        }
        if (moduleOutputReport.getPlateScale() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.PLATE_SCALE,
                moduleOutputReport.getPlateScale()
                    .getAlerts());
        }
        if (moduleOutputReport.getSmearLevel() != null) {
            generateAlerts(ccdModule, ccdOutput,
                ModuleOutputMetricReport.MetricType.SMEAR_LEVEL,
                moduleOutputReport.getSmearLevel()
                    .getAlerts());
        }
    }

    private void generateAlerts(final PdqFocalPlaneReport focalPlaneReport) {

        if (focalPlaneReport.getDeltaAttitudeDec() != null) {
            generateAlerts(
                FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_DEC,
                focalPlaneReport.getDeltaAttitudeDec()
                    .getAlerts());
        }
        if (focalPlaneReport.getDeltaAttitudeRa() != null) {
            generateAlerts(FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_RA,
                focalPlaneReport.getDeltaAttitudeRa()
                    .getAlerts());
        }
        if (focalPlaneReport.getDeltaAttitudeRoll() != null) {
            generateAlerts(
                FocalPlaneMetricReport.MetricType.DELTA_ATTITUDE_ROLL,
                focalPlaneReport.getDeltaAttitudeRoll()
                    .getAlerts());
        }
    }

    private void generateAlerts(final int ccdModule, final int ccdOutput,
        final ModuleOutputMetricReport.MetricType metricType,
        final List<ModuleAlert> alerts) {

        for (ModuleAlert alert : alerts) {
            String logMessage = alert.getMessage() + ": ccdModule=" + ccdModule
                + "; ccdOutput=" + ccdOutput + "; metricType=" + metricType;
            AlertServiceFactory.getInstance()
                .generateAlert(getModuleName(), pipelineTask.getId(),
                    Severity.valueOf(alert.getSeverity()), logMessage);
            if (alert.isError()) {
                log.error(logMessage);
            } else if (alert.isWarning()) {
                log.warn(logMessage);
            }
        }
    }

    private void generateAlerts(
        final FocalPlaneMetricReport.MetricType metricType,
        final List<ModuleAlert> alerts) {

        for (ModuleAlert alert : alerts) {
            String logMessage = alert.getMessage() + ": metricType="
                + metricType;
            AlertServiceFactory.getInstance()
                .generateAlert(getModuleName(), pipelineTask.getId(),
                    Severity.valueOf(alert.getSeverity()), logMessage);
            if (alert.isError()) {
                log.error(logMessage);
            } else if (alert.isWarning()) {
                log.warn(logMessage);
            }
        }
    }

    /**
     * Translates the given attitude adjustments into the persistable format.
     * 
     * @param targetTable
     * @param pipelineTask
     * @param refPixelLogs
     * @param outAttitudeAdjustments
     * @return
     */
    private List<AttitudeAdjustment> createAttitudeAdjustments(
        final PipelineTask pipelineTask, final List<RefPixelLog> refPixelLogs,
        final List<PdqAttitudeAdjustment> outAttitudeAdjustments) {

        if (outAttitudeAdjustments == null) {
            throw new IllegalArgumentException("attitude adjustments missing");
        }
        if (outAttitudeAdjustments.size() != refPixelLogs.size()) {
            throw new IllegalArgumentException("expected "
                + refPixelLogs.size() + " attitude adjustments but got "
                + outAttitudeAdjustments.size());
        }
        List<AttitudeAdjustment> existingAdjustments = pdqCrud.retrieveLatestAttitudeAdjustments(0);
        Map<RefPixelLog, AttitudeAdjustment> adjustmentByLog = new HashMap<RefPixelLog, AttitudeAdjustment>();
        if (existingAdjustments != null) {
            for (AttitudeAdjustment attitudeAdjustment : existingAdjustments) {
                if (refPixelLogs.contains(attitudeAdjustment.getRefPixelLog())) {
                    adjustmentByLog.put(attitudeAdjustment.getRefPixelLog(),
                        attitudeAdjustment);
                } else if (forceReprocessing) {
                    pdqCrud.delete(attitudeAdjustment);
                }
            }
        }
        List<AttitudeAdjustment> createAttitudeAdjustments = new ArrayList<AttitudeAdjustment>();
        for (int i = 0; i < refPixelLogs.size(); i++) {
            double[] quaternion = outAttitudeAdjustments.get(i)
                .getQuaternion();
            AttitudeAdjustment attitudeAdjustment = adjustmentByLog.get(refPixelLogs.get(i));
            if (attitudeAdjustment == null) {
                attitudeAdjustment = new AttitudeAdjustment(pipelineTask,
                    refPixelLogs.get(i),
                    quaternion[AttitudeAdjustment.QUATERNION_X],
                    quaternion[AttitudeAdjustment.QUATERNION_Y],
                    quaternion[AttitudeAdjustment.QUATERNION_Z],
                    quaternion[AttitudeAdjustment.QUATERNION_W]);
                createAttitudeAdjustments.add(attitudeAdjustment);
            } else {
                attitudeAdjustment.setPipelineTask(pipelineTask);
                attitudeAdjustment.setTimeGenerated(null);
                attitudeAdjustment.setX(quaternion[AttitudeAdjustment.QUATERNION_X]);
                attitudeAdjustment.setY(quaternion[AttitudeAdjustment.QUATERNION_Y]);
                attitudeAdjustment.setZ(quaternion[AttitudeAdjustment.QUATERNION_Z]);
                attitudeAdjustment.setW(quaternion[AttitudeAdjustment.QUATERNION_W]);
            }
        }
        return createAttitudeAdjustments;
    }

    /**
     * Read and parse a list of reference pixel files using the given target
     * definitions and populate a time series buffer with the reference pixel
     * values.
     * 
     * @param refPixelLogs
     * @param targetDefs
     * @return
     */
    public TimeSeriesBuffer extractRefPixelTimeSeriesData(
        final List<RefPixelLog> refPixelLogs,
        final List<TargetDefinition> targetDefs) {
        log.info("Extracting reference pixel time series data");
        TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(
            refPixelLogs.size());

        IntervalMetricKey key = null;

        try {

            long startTime = System.currentTimeMillis();
            int index = 0;

            for (RefPixelLog refPixelLog : refPixelLogs) {
                FsId fsId = DrFsIdFactory.getFile(DispatcherType.REF_PIXEL,
                    refPixelLog.getFileLog()
                        .getFilename());

                log.info("Processing: " + fsId);

                try {
                    key = IntervalMetric.start();

                    processRefPixelFile(refPixelLog.getTargetTableId(),
                        targetDefs, fsId, index++, timeSeriesBuffer);

                } finally {
                    IntervalMetric.stop("pdq.refpixel.oneFile.process", key);
                }
            }

            log.info("total time = " + (System.currentTimeMillis() - startTime)
                / 1000F + " secs.");
        } catch (Exception e) {
            log.error("process()", e);

            throw new ModuleFatalProcessingException(
                "failed to extract reference pixel metadata", e);
        }

        log.debug("process() - end");

        return timeSeriesBuffer;
    }

    /**
     * Process a single reference pixel file extracting the reference pixel data
     * and accumulating it into the given time series buffer.
     * 
     * @param tableId
     * @param targetDefs
     * @param fsId
     * @param index
     * @param timeSeriesBuffer
     */
    private void processRefPixelFile(final int tableId,
        final List<TargetDefinition> targetDefs, final FsId fsId,
        final int index, final TimeSeriesBuffer timeSeriesBuffer) {

        RefPixelDescriptor refPixelDescriptor = new RefPixelDescriptor(tableId,
            0, 0, 0, 0);
        DataInputStream dis = null;
        int numPixelsInFile = -1;
        int numPixelsInTad = 0;

        try {
            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            BlobResult blobResult = fsClient.readBlob(fsId);
            dis = new DataInputStream(new ByteArrayInputStream(
                blobResult.data()));
            RefPixelFileReader refPixelFileReader = new RefPixelFileReader(
                fsId, dis);

            log.info("Reading reference pixel file contents for FsId: " + fsId);

            numPixelsInFile = refPixelFileReader.getNumberOfReferencePixels();

            for (TargetDefinition targetDef : targetDefs) {
                refPixelDescriptor.setCcdModule(targetDef.getCcdModule());
                refPixelDescriptor.setCcdOutput(targetDef.getCcdOutput());
                int refRow = targetDef.getReferenceRow();
                int refColumn = targetDef.getReferenceColumn();
                List<Offset> pixels = targetDef.getMask()
                    .getOffsets();

                for (Offset pixel : pixels) {
                    int row = refRow + pixel.getRow();
                    int col = refColumn + pixel.getColumn();

                    int pixelValue;
                    try {
                        pixelValue = refPixelFileReader.readNextPixel();
                        if (trace && log.isTraceEnabled()) {
                            log.trace("read pixel: keplerId="
                                + targetDef.getKeplerId() + "; row=" + row
                                + "; col=" + col + "; value=" + pixelValue);
                        }
                    } catch (EOFException e) {
                        throw new ModuleFatalProcessingException(
                            "Reference pixel file ["
                                + fsId
                                + "] does not contain enough pixels!  pixelIndex="
                                + numPixelsInTad);
                    }

                    refPixelDescriptor.setCcdRow(row);
                    refPixelDescriptor.setCcdColumn(col);

                    timeSeriesBuffer.addValue(refPixelDescriptor, index,
                        pixelValue);
                    numPixelsInTad++;
                }
            }
        } finally {
            FileUtil.close(dis);
        }

        if (numPixelsInTad != numPixelsInFile) {
            throw new ModuleFatalProcessingException("More pixels found ("
                + numPixelsInFile + ") in file than expected ("
                + numPixelsInTad + ")");
        }
    }

    /**
     * Construct all target lists based on the given target table id.
     * 
     * All the targets are segregated into three distinct lists: background,
     * collateral, and stellar. Additional information is acquired for stellar
     * targets (for example, Ra and Dec).
     * 
     * @param targetTable
     */
    private List<TargetDefinition> createTargetLists(
        final TargetTable targetTable) {

        List<TargetDefinition> allTargetDefs = new ArrayList<TargetDefinition>();

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                List<TargetDefinition> moduleOutputTargetDefs = targetCrud.retrieveTargetDefinitions(
                    targetTable, ccdModule, ccdOutput);

                Map<Integer, List<TargetDefinition>> targetDefsByKeplerId = new HashMap<Integer, List<TargetDefinition>>();
                if (moduleOutputTargetDefs != null) {
                    for (TargetDefinition targetDef : moduleOutputTargetDefs) {
                        List<TargetDefinition> targetDefs = targetDefsByKeplerId.get(targetDef.getKeplerId());
                        if (targetDefs == null) {
                            targetDefs = new ArrayList<TargetDefinition>();
                            targetDefsByKeplerId.put(targetDef.getKeplerId(),
                                targetDefs);
                        }
                        targetDefs.add(targetDef);
                        if (trace && log.isTraceEnabled()) {
                            List<Offset> offsets = targetDef.getMask()
                                .getOffsets();
                            if (offsets != null && !offsets.isEmpty()) {
                                int referenceRow = targetDef.getReferenceRow();
                                int referenceColumn = targetDef.getReferenceColumn();
                                for (Offset offset : offsets) {
                                    log.trace("target pixel: keplerId="
                                        + targetDef.getKeplerId()
                                        + "; row="
                                        + (referenceRow + offset.getRow())
                                        + "; col="
                                        + (referenceColumn + offset.getColumn()));
                                }
                            }
                        }
                    }

                    int channelNumber = FcConstants.getChannelNumber(ccdModule,
                        ccdOutput);
                    getModuleOutputDefinitions().put(channelNumber,
                        moduleOutputTargetDefs);
                    if (!moduleOutputTargetDefs.isEmpty()) {
                        getModuleOutputsWithTargets().add(channelNumber);
                        allTargetDefs.addAll(moduleOutputTargetDefs);
                        DatabaseServiceFactory.getInstance()
                            .evictAll(moduleOutputTargetDefs);
                    }
                }

                List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
                    targetTable, ccdModule, ccdOutput);
                if (observedTargets != null && !observedTargets.isEmpty()) {
                    log.info("module/output: " + ccdModule + "/" + ccdOutput
                        + ": processing observed targets: "
                        + observedTargets.size());
                    for (ObservedTarget observedTarget : observedTargets) {
                        if (observedTarget.containsLabel(PlannedTarget.TargetLabel.PDQ_BACKGROUND)) {
                            PdqTarget target = new PdqTarget(ccdModule,
                                ccdOutput, observedTarget);
                            backgroundPdqTargets.add(target);
                        } else if (observedTarget.containsLabel(PlannedTarget.TargetLabel.PDQ_BLACK_COLLATERAL)
                            || observedTarget.containsLabel(PlannedTarget.TargetLabel.PDQ_SMEAR_COLLATERAL)) {
                            PdqTarget target = new PdqTarget(ccdModule,
                                ccdOutput, observedTarget);
                            collateralPdqTargets.add(target);
                        } else {
                            CelestialObjectParameters celestialObjectParameters = getCelestialObjectOperations().retrieveCelestialObjectParameters(
                                observedTarget.getKeplerId());
                            if (celestialObjectParameters != null) {
                                List<TargetDefinition> targetDefs = targetDefsByKeplerId.get(observedTarget.getKeplerId());
                                PdqStellarTarget target = new PdqStellarTarget(
                                    ccdModule, ccdOutput, observedTarget,
                                    targetDefs, celestialObjectParameters);
                                stellarPdqTargets.add(target);
                            }
                        }
                    }
                    DatabaseServiceFactory.getInstance()
                        .evictAll(observedTargets);
                }
            }
        }
        return allTargetDefs;
    }

    /**
     * Traverses all previously created lists of targets updating their
     * associated pixels with the values in the given time series buffer.
     * 
     * @param targetTableId
     * @param data
     */
    private void setTimeSeries(final int targetTableId,
        final TimeSeriesBuffer data) {
        log.info("populate background targets with reference pixel data");
        for (PdqTarget target : backgroundPdqTargets) {
            target.setTimeSeries(targetTableId, data);
        }
        log.info("populate collateral targets with reference pixel data");
        for (PdqTarget target : collateralPdqTargets) {
            target.setTimeSeries(targetTableId, data);
        }
        log.info("populate stellar targets with reference pixel data");
        for (PdqTarget target : stellarPdqTargets) {
            target.setTimeSeries(targetTableId, data);
        }
    }

    /**
     * Summary report of statistics for a given target list. This is used only
     * for logging purposes.
     * 
     */
    private static final class TargetListReport {

        private final String name;
        private final List<PdqTarget> targets;
        private int targetCount = 0;
        private int pixelCount = 0;
        private int optimalAperturePixelCount = 0;
        private int gapCount = 0;
        private int minRow = 0;
        private int minCol = 0;
        private int maxRow = 0;
        private int maxCol = 0;

        public TargetListReport(final String name, final List<PdqTarget> targets) {
            this.name = name;
            this.targets = targets;
            update();
        }

        public int getGapCount() {
            return gapCount;
        }

        public int getOptimalAperturePixelCount() {
            return optimalAperturePixelCount;
        }

        public int getPixelCount() {
            return pixelCount;
        }

        public int getTargetCount() {
            return targetCount;
        }

        private void update() {

            for (PdqTarget target : targets) {
                targetCount++;
                for (PdqPixelTimeSeries pixel : target.getReferencePixels()) {
                    pixelCount++;
                    if (pixel.isInOptimalAperture()) {
                        optimalAperturePixelCount++;
                    }
                    if (pixel.getRow() < minRow) {
                        minRow = pixel.getRow();
                    }
                    if (pixel.getColumn() < minCol) {
                        minCol = pixel.getColumn();
                    }
                    if (pixel.getRow() > maxRow) {
                        maxRow = pixel.getRow();
                    }
                    if (pixel.getColumn() > maxCol) {
                        maxCol = pixel.getColumn();
                    }
                    boolean[] gapIndicators = pixel.getGapIndicators();
                    if (gapIndicators != null) {
                        for (boolean gap : gapIndicators) {
                            if (gap) {
                                gapCount++;
                            }
                        }
                    }
                }
            }
        }

        @Override
        public String toString() {

            StringBuilder builder = new StringBuilder();
            builder.append(name + " target list report: ")
                .append("\n");
            builder.append(name + " target count: " + targetCount)
                .append("\n");
            builder.append(name + " pixel count: " + pixelCount)
                .append("\n");
            builder.append(
                name + " optimal aperture pixel count: "
                    + optimalAperturePixelCount)
                .append("\n");
            builder.append(name + " gap count: " + gapCount)
                .append("\n");
            builder.append(name + " min row: " + minRow)
                .append("\n");
            builder.append(name + " max row: " + maxRow)
                .append("\n");
            builder.append(name + " min col: " + minCol)
                .append("\n");
            builder.append(name + " max col: " + maxCol)
                .append("\n");
            return builder.toString();
        }
    }

    /**
     * Logs messages containing summary statistics for all target lists.
     * 
     */
    private void logTargetListReports() {

        TargetListReport backgroundReport = new TargetListReport("background",
            backgroundPdqTargets);
        TargetListReport collateralReport = new TargetListReport("collateral",
            collateralPdqTargets);
        List<PdqTarget> stellarTargets = new ArrayList<PdqTarget>(
            stellarPdqTargets.size());
        stellarTargets.addAll(stellarPdqTargets);
        TargetListReport stellarReport = new TargetListReport("stellar",
            stellarTargets);

        StringBuilder report = new StringBuilder();
        report.append(stellarReport);
        report.append(collateralReport);
        report.append(backgroundReport);
        report.append("\ntotal target count: "
            + (backgroundReport.getTargetCount()
                + collateralReport.getTargetCount() + stellarReport.getTargetCount()));
        report.append("\ntotal pixel count: "
            + (backgroundReport.getPixelCount()
                + collateralReport.getPixelCount() + stellarReport.getPixelCount()));
        report.append("\ntotal optimal aperture pixel count: "
            + (backgroundReport.getOptimalAperturePixelCount()
                + collateralReport.getOptimalAperturePixelCount() + stellarReport.getOptimalAperturePixelCount()));
        report.append("\ntotal gap count: "
            + (backgroundReport.getGapCount() + collateralReport.getGapCount() + stellarReport.getGapCount()));

        log.info(report.toString());
    }

    // getters and setters

    public PdqInputs getInputs() {
        return inputs;
    }

    public void setInputs(final PdqInputs inputs) {
        this.inputs = inputs;
    }

    public Map<Integer, List<TargetDefinition>> getModuleOutputDefinitions() {
        return moduleOutputDefinitions;
    }

    public void setModuleOutputDefinitions(
        final Map<Integer, List<TargetDefinition>> moduleOutputDefinitions) {
        this.moduleOutputDefinitions = moduleOutputDefinitions;
    }

    public Set<Integer> getModuleOutputsWithTargets() {
        return moduleOutputsWithTargets;
    }

    public void setModuleOutputsWithTargets(
        final Set<Integer> moduleOutputsWithTargets) {
        this.moduleOutputsWithTargets = moduleOutputsWithTargets;
    }

    public PdqOutputs getOutputs() {
        return outputs;
    }

    public void setOutputs(final PdqOutputs outputs) {
        this.outputs = outputs;
    }

    public PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public void setPipelineTask(final PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    // setters used for mocking

    /**
     * Only used for mocking.
     */
    public void setCompressionCrud(final CompressionCrud compressionCrud) {
        this.compressionCrud = compressionCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setConfigMapOperations(
        final ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setDaCrud(final DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setFlatFieldOperations(
        final FlatFieldOperations flatFieldOperations) {
        this.flatFieldOperations = flatFieldOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setGainOperations(final GainOperations gainOperations) {
        this.gainOperations = gainOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setGenericReportOperations(
        final GenericReportOperations genericReportOperations) {
        this.genericReportOperations = genericReportOperations;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            boolean customTargetProcessingEnabled = false;
            // Replace the statement above with the following if PDQ supports
            // custom targets.
            // boolean customTargetProcessingEnabled =
            // pipelineTask.getParameters(
            // CustomTargetParameters.class)
            // .isProcessingEnabled();
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !customTargetProcessingEnabled);
        }

        return celestialObjectOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setCelestialObjectOperations(
        final CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setLogCrud(final LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setPdqCrud(final PdqCrud pdqCrud) {
        this.pdqCrud = pdqCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setPdqDoubleDbTimeSeriesCrud(
        final PdqDbTimeSeriesCrud pdqDbTimeSeriesCrud) {
        this.pdqDbTimeSeriesCrud = pdqDbTimeSeriesCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setPipelineInstance(final PipelineInstance pipelineInstance) {
        this.pipelineInstance = pipelineInstance;
    }

    public void setPrfOperations(final PrfOperations prfOperations) {
        this.prfOperations = prfOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setReadNoiseOperations(
        final ReadNoiseOperations readNoiseOperations) {
        this.readNoiseOperations = readNoiseOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setRaDec2PixOperations(
        final RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setTargetCrud(final TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setTwoDBlackOperations(
        final TwoDBlackOperations twoDBlackOperations) {
        this.twoDBlackOperations = twoDBlackOperations;
    }

    /**
     * Only used for mocking.
     */
    public void setUndershootOperations(
        final UndershootOperations undershootOperations) {
        this.undershootOperations = undershootOperations;
    }

    protected File getMatlabWorkingDir() {
        if (matlabWorkingDir == null) {
            matlabWorkingDir = allocateWorkingDir(pipelineTask);
        }

        return matlabWorkingDir;
    }

    /**
     * Only used for testing.
     */
    protected void setMatlabWorkingDir(File workingDir) {
        matlabWorkingDir = workingDir;
    }
    
    public PdqModuleParameters getPdqModuleParameters() {
        return pdqModuleParameters;
    }
}
