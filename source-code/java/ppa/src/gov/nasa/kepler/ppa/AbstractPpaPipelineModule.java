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

package gov.nasa.kepler.ppa;

import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PpaCrud;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Abstract class for PPA pipeline.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public abstract class AbstractPpaPipelineModule extends MatlabPipelineModule {

    private static final Log log = LogFactory.getLog(AbstractPpaPipelineModule.class);

    protected PipelineTask pipelineTask;
    protected PipelineInstance pipelineInstance;

    protected int startCadence;
    protected int endCadence;

    private Persistable inputs;
    private Persistable outputs;

    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();
    private PpaCrud ppaCrud = new PpaCrud();
    private DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud = new DoubleDbTimeSeriesCrud();
    private MjdToCadence mjdToCadence;
    private TargetCrud targetCrud = new TargetCrud();
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private BlobOperations blobOperations = new BlobOperations();
    private AncillaryOperations ancillaryOperations = new AncillaryOperations();
    private GenericReportOperations genericReportOperations = new GenericReportOperations();
    private File matlabWorkingDir;

    private Set<Long> producerTaskIds = new HashSet<Long>();

    /**
     * Initialize instance variables. In particular, implementations
     * <bold>must</bold> initialize {@code startCadence} and {@code endCadence}
     * in this method.
     */
    protected abstract void initializeTask();

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;

        CadenceType cadenceType = CadenceType.valueOf(pipelineTask.getParameters(
            CadenceTypePipelineParameters.class)
            .getCadenceType());
        if (cadenceType != CadenceType.LONG) {
            throw new ModuleFatalProcessingException("Invalid cadence type "
                + cadenceType.toString() + "; only long cadence permitted");
        }

        getBlobOperations().setOutputDir(getMatlabWorkingDir());

        initializeTask();

        processTask(retrieveTargetTable());
    }

    private TargetTable retrieveTargetTable() {
        log.info("Retrieving target tables");
        List<TargetTableLog> targetTableLogs = getTargetCrud().retrieveTargetTableLogs(
            TargetType.LONG_CADENCE, startCadence, endCadence);
        getDatabaseService().evictAll(targetTableLogs);

        if (targetTableLogs.size() == 0) {
            throw new ModuleFatalProcessingException(
                "Could not find target table spanning long cadences "
                    + startCadence + " to " + endCadence);
        }

        if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException("There were "
                + targetTableLogs.size()
                + " target tables over the cadence range " + startCadence
                + " to " + endCadence + "; only one allowed");
        }

        TargetTable targetTable = targetTableLogs.get(0)
            .getTargetTable();
        log.info("Processing target table ID " + targetTable.getExternalId()
            + " from cadence " + startCadence + " to " + endCadence);

        return targetTable;
    }

    protected void processTask(TargetTable targetTable) {
        Persistable inputs = createInputs();

        IntervalMetricKey metricKey = IntervalMetric.start();

        try {
            retrieveInputs(inputs, targetTable);
        } catch (IllegalArgumentException e) {
            throw new ModuleFatalProcessingException(e.getMessage(), e);
        } catch (IllegalStateException e) {
            throw new ModuleFatalProcessingException(e.getMessage(), e);
        } finally {
            IntervalMetric.stop("ppa." + getModuleName() + ".retrieveInputs",
                metricKey);
        }

        Persistable outputs = createOutputs();
        executeAlgorithm(pipelineTask, inputs, outputs);
        metricKey = IntervalMetric.start();
        try {
            storeOutputs(outputs, targetTable);
        } catch (IllegalArgumentException iae) {
            throw new ModuleFatalProcessingException(iae.getMessage(), iae);
        } finally {
            IntervalMetric.stop("ppa." + getModuleName() + ".storeOutputs",
                metricKey);
        }
    }

    /**
     * Creates the module-specific input object tree. Sub-classes should
     * override this method and simply return a new instance of the
     * module-specific input class.
     */
    protected abstract Persistable createInputs();

    /**
     * Retrieves the inputs for this module/UOW. Sub-classes should override
     * this method and populate the object with data from the file store and/or
     * database.
     */
    protected abstract void retrieveInputs(Persistable inputs,
        TargetTable targetTable);

    /**
     * Creates the module-specific output object. Sub-classes should override
     * this method and simply return a new instance of the module-specific
     * output class (it is not necessary to initialize nested objects, this is
     * done when the output data is de-serialized).
     */
    protected abstract Persistable createOutputs();

    /**
     * Stores the outputs in the data store. Sub-classes should override this
     * method and store all outputs in the data store. Make sure all outputs are
     * associated with the pipeline task ID ({@code pipelineTask.getId()}).
     */
    protected abstract void storeOutputs(Persistable outputs,
        TargetTable targetTable);

    protected void addReportsToDataAccountability(
        List<gov.nasa.kepler.hibernate.ppa.PmdMetricReport> reports) {
        for (gov.nasa.kepler.hibernate.ppa.PmdMetricReport report : reports) {
            producerTaskIds.add(report.getPipelineTask()
                .getId());
        }
    }

    protected void storeMissionReport(String reportFilename) {
        if (reportFilename.length() == 0) {
            log.warn("Report filename not given (yet) so mission report not saved");
            return;
        }

        File file = new File(getMatlabWorkingDir(), reportFilename);
        getGenericReportOperations().createReport(pipelineTask, file);
    }

    protected void generateAlerts(String type, List<ModuleAlert> alerts) {
        if (alerts == null || alerts.size() == 0) {
            return;
        }

        for (ModuleAlert alert : alerts) {
            String message = String.format("%s (type=%s)", alert.getMessage(),
                type);
            generateAlert(alert, message);
        }
    }

    protected void generateAlerts(String type, int ccdModule, int ccdOutput,
        List<ModuleAlert> alerts) {

        if (alerts == null || alerts.size() == 0) {
            return;
        }

        for (ModuleAlert alert : alerts) {
            String message = String.format(
                "%s (ccdModule=%d, ccdOutput=%d, type=%s)", alert.getMessage(),
                ccdModule, ccdOutput, type);
            generateAlert(alert, message);
        }
    }

    private void generateAlert(ModuleAlert alert, String message) {
        AlertServiceFactory.getInstance()
            .generateAlert(getModuleName(), pipelineTask.getId(),
                Severity.valueOf(alert.getSeverity()), message);
    }

    /**
     * Saves the data accountability trail for this module after all outputs
     * have been successfully saved.
     */
    protected void updateDataAccountability() {
        log.info(String.format(
            "Updating data accountability: taskId=%d, producerTaskIds count=%d",
            pipelineTask.getId(), producerTaskIds.size()));
        daCrud.create(pipelineTask, producerTaskIds);
    }

    protected TimestampSeries retrieveCadenceTimes() {

        log.info(String.format("Retrieving cadence times from %d to %d...",
            startCadence, endCadence));

        TimestampSeries cadenceTimes = getMjdToCadence().cadenceTimes(
            startCadence, endCadence);

        return cadenceTimes;
    }

    protected RaDec2PixModel retrieveRaDec2PixModel(double startMjd,
        double endMjd) {

        return getRaDec2PixOperations().retrieveRaDec2PixModel(startMjd, endMjd);
    }

    protected Map<FsId, IntTimeSeries> retrieveIntTimeSeries(List<FsId> fsIds) {

        log.info(String.format(
            "Retrieving %d int time series from %d to %d...", fsIds.size(),
            startCadence, endCadence));

        IntTimeSeries[] timeSeriesArray = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsInt(fsIds.toArray(new FsId[0]), startCadence,
                endCadence, false);
        TimeSeriesOperations.addToDataAccountability(timeSeriesArray,
            producerTaskIds);
        log.info(String.format(
            "Retrieving %d int time series from %d to %d...done", fsIds.size(),
            startCadence, endCadence));

        return TimeSeriesOperations.getIntTimeSeriesByFsId(timeSeriesArray,
            true);
    }

    protected Map<FsId, FloatTimeSeries> retrieveFloatTimeSeries(
        List<FsId> fsIds) {

        log.info(String.format(
            "Retrieving %d float time series from %d to %d...", fsIds.size(),
            startCadence, endCadence));

        FloatTimeSeries[] timeSeriesArray = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsFloat(fsIds.toArray(new FsId[0]), startCadence,
                endCadence, false);
        TimeSeriesOperations.addToDataAccountability(timeSeriesArray,
            producerTaskIds);
        log.info(String.format(
            "Retrieving %d float time series from %d to %d...done",
            fsIds.size(), startCadence, endCadence));

        return TimeSeriesOperations.getFloatTimeSeriesByFsId(timeSeriesArray,
            true);
    }

    protected BlobFileSeries retrieveBackgroundBlobs(int ccdModule,
        int ccdOutput) {

        log.info(String.format("Retrieving background coeff blobs for %d/%d",
            ccdModule, ccdOutput));

        BlobSeries<String> blobSeries = getBlobOperations().retrieveBackgroundBlobFileSeries(
            ccdModule, ccdOutput, startCadence, endCadence);
        producerTaskIds.addAll(Arrays.asList(ArrayUtils.toObject(blobSeries.blobOriginators())));

        return new BlobFileSeries(blobSeries);
    }

    protected BlobFileSeries retrieveMotionBlobs(int ccdModule, int ccdOutput) {

        log.info(String.format("Retrieving motion poly blobs for %d/%d",
            ccdModule, ccdOutput));

        BlobSeries<String> blobSeries = getBlobOperations().retrieveMotionBlobFileSeries(
            ccdModule, ccdOutput, startCadence, endCadence);
        producerTaskIds.addAll(Arrays.asList(ArrayUtils.toObject(blobSeries.blobOriginators())));

        return new BlobFileSeries(blobSeries);
    }

    protected List<ConfigMap> retrieveConfigMaps(double startMjd, double endMjd) {
        List<ConfigMap> configMaps = configMapOperations.retrieveConfigMaps(
            startMjd, endMjd);
        if (configMaps == null || configMaps.size() == 0) {
            throw new ModuleFatalProcessingException(String.format(
                "Need at least one spacecraft config map between t=%.3f "
                    + "and t=%.3f, but found none", startMjd, endMjd));
        }

        return configMaps;
    }

    protected List<AncillaryEngineeringData> retrieveAncillaryEngineeringData(
        double startMjd, double endMjd, String[] mnemonics) {

        List<AncillaryEngineeringData> ancillaryEngineeringData = getAncillaryOperations().retrieveAncillaryEngineeringData(
            mnemonics, startMjd, endMjd);

        return ancillaryEngineeringData;
    }

    protected List<AncillaryPipelineData> retrieveAncillaryPipelineData(
        String[] mnemonics, TargetTable targetTable, int ccdModule,
        int ccdOutput, TimestampSeries cadenceTimes) {

        List<AncillaryPipelineData> ancillaryPipelineData = getAncillaryOperations().retrieveAncillaryPipelineData(
            mnemonics, targetTable, ccdModule, ccdOutput, cadenceTimes);
        producerTaskIds.addAll(ancillaryOperations.producerTaskIds());

        return ancillaryPipelineData;
    }

    public DatabaseService getDatabaseService() {
        return DatabaseServiceFactory.getInstance();
    }

    public Persistable getInputs() {
        return inputs;
    }

    public void setInputs(Persistable inputs) {
        this.inputs = inputs;
    }

    public Persistable getOutputs() {
        return outputs;
    }

    public void setOutputs(Persistable outputs) {
        this.outputs = outputs;
    }

    /**
     * Sets the {@link PipelineInstance} object during testing by unit tests
     * that aren't calling {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance
     */
    public void setPipelineInstance(PipelineInstance pipelineInstance) {
        this.pipelineInstance = pipelineInstance;
    }

    /**
     * Sets the {@link PipelineTask} object during testing by unit tests that
     * aren't calling {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineTask the pipeline task
     */
    @Override
    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    /**
     * Sets the {@link DataAccountabilityTrailCrud} object during testing.
     */
    public void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    public PpaCrud getPpaCrud() {
        return ppaCrud;
    }

    /**
     * Sets the {@link PaCrud} object during testing.
     */
    public void setPpaCrud(PpaCrud ppaCrud) {
        this.ppaCrud = ppaCrud;
    }

    public MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(CadenceType.LONG,
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }
        return mjdToCadence;
    }

    /**
     * Sets the {@link MjdToCadence} object during testing.
     */
    public void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    public TargetCrud getTargetCrud() {
        return targetCrud;
    }

    /**
     * Sets the {@link TargetCrud} object during testing.
     */
    public void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    public RaDec2PixOperations getRaDec2PixOperations() {
        return raDec2PixOperations;
    }

    /**
     * Sets the {@link RaDec2PixOperations} object during testing.
     */
    public void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    /**
     * Sets the {@link ConfigMapOperations} object during testing.
     */
    public void setConfigMapOperations(ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    public BlobOperations getBlobOperations() {
        return blobOperations;
    }

    /**
     * Sets the {@link BlobOperations} object during testing.
     */
    public void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    public DoubleDbTimeSeriesCrud getDoubleDbTimeSeriesCrud() {
        return doubleDbTimeSeriesCrud;
    }

    /**
     * Sets the {@link AncillaryOperations} object during testing.
     */
    public void setAncillaryOperations(AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    public AncillaryOperations getAncillaryOperations() {
        return ancillaryOperations;
    }

    /**
     * Sets the {@link DoubleDbTimeSeriesCrud} object during testing.
     */
    public void setDoubleDbTimeSeriesCrud(
        DoubleDbTimeSeriesCrud doubleDbTimeSeriesCrud) {
        this.doubleDbTimeSeriesCrud = doubleDbTimeSeriesCrud;
    }

    public GenericReportOperations getGenericReportOperations() {
        return genericReportOperations;
    }

    /**
     * Sets the {@link GenericReportOperations} object during testing.
     */
    public void setGenericReportOperations(
        GenericReportOperations genericReportOperations) {
        this.genericReportOperations = genericReportOperations;
    }

    public File getMatlabWorkingDir() {
        if (matlabWorkingDir == null) {
            matlabWorkingDir = allocateWorkingDir(pipelineTask);
        }

        return matlabWorkingDir;
    }

    /**
     * Sets the MATLAB working directory during testing.
     */
    public void setMatlabWorkingDir(File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
    }
}
