/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

package gov.nasa.kepler.tps;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesByFsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.mc.TransitOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.pi.NumberOfElementsPerSubTask;
import gov.nasa.kepler.mc.uow.TargetListChunkUowTask;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.FlushMode;

import com.google.common.collect.Iterators;
import com.google.common.collect.Lists;
import com.google.common.collect.PeekingIterator;

/**
 * Transiting planet search pipeline module.
 * 
 * @author Sean McCauliff
 * 
 */
public class TpsPipelineModule extends MatlabPipelineModule
    implements AsyncPipelineModule {
    private static final Log log = LogFactory.getLog(TpsPipelineModule.class);

    public static final String MODULE_NAME = "tps";
    public static final String ALERT_MESSAGE_FORMAT = "%s: time=%g";

    private static final String TPS_DAWG_EXE_NAME = "tps_dawg";
    private static final int TPS_DAWG_EXE_TIMEOUT_SECS = 2 * 60 * 60;// 2 hours
    
    private static final class PrivateInstances {
        private RollTimeOperations rolltimeOps;
        private MjdToCadence mjdToCadence;
        private TpsCrud tpsCrud;
        private LogCrud logCrud;
        private TargetCrud targetCrud;
        private PdcCrud pdcCrud;
        private DataAccountabilityTrailCrud daAcctCrud;
        private TargetSelectionCrud targetSelectionCrud;
        private CelestialObjectOperations celestialObjectOperations;
        private TransitOperations transitOps;
    }
    
    //This is here so I don't accidently refer to these instances in the code
    //that actually does something.  That is to enforce the use of accessor methods.
    private final PrivateInstances m = new PrivateInstances();


    public TpsPipelineModule() {
    }
    
    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return TargetListChunkUowTask.class;
    }

    @Override
    public Class<?> outputsClass() {
        return TpsOutputs.class;
    }
    

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(TargetListParameters.class);
        rv.add(TpsModuleParameters.class);
        rv.add(CadenceRangeParameters.class);
        rv.add(GapFillModuleParameters.class);
        rv.add(FluxTypeParameters.class);
        rv.add(TpsHarmonicsIdentificationParameters.class);
        rv.add(CustomTargetParameters.class);
        rv.add(RemoteExecutionParameters.class);
        rv.add(BootstrapModuleParameters.class);

        return rv;
    }
    
    @Override
    public void generateInputs(InputsHandler inputsHandler, final PipelineTask pipelineTask,
            final File workingDirectory) throws RuntimeException {

        try {
            DatabaseServiceFactory.getInstance()
                .getSession()
                .setFlushMode(FlushMode.COMMIT);

            PipelineInstance pipelineInstance = pipelineTask.getPipelineInstance();

            TpsModuleParameters tpsModuleParameters = pipelineTask.getParameters(TpsModuleParameters.class);

            TargetListChunkUowTask targetListChunk = pipelineTask.uowTaskInstance();

            TargetListParameters targetListParameters = pipelineTask.getParameters(TargetListParameters.class);

            GapFillModuleParameters gapFillParameters = pipelineTask.getParameters(GapFillModuleParameters.class);

            FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);

            TpsHarmonicsIdentificationParameters hIdent = pipelineTask.getParameters(TpsHarmonicsIdentificationParameters.class);

            BootstrapModuleParameters bootstrapParameters = pipelineTask.getParameters(BootstrapModuleParameters.class);
            
            RemoteExecutionParameters remoteExecutionParameters = pipelineTask.getParameters(RemoteExecutionParameters.class);
            
            final FluxType fluxType = FluxType.valueOf(fluxTypeParameters.getFluxType());
            if (!fluxType.equals(FluxType.SAP)) {
                // Changing the flux type to something else is mostly untested
                // and we will likely never implement this therefore throw an
                // error
                // if this is not SAP.
                throw new ModuleFatalProcessingException(
                    "Does not support non-SAP flux type.");
            }

            Pair<Integer, Integer> startEndCadence = computeCadenceInterval(pipelineTask);
            int startCadence = startEndCadence.left;
            int endCadence = startEndCadence.right;

            NumberOfElementsPerSubTask numElementsCalc = new NumberOfElementsPerSubTask() {
                @Override
                public int numberOfElementsPerSubTask(int totalNumberOfElements) {
                    return elementsPerSubTask(pipelineTask,
                        totalNumberOfElements);
                }
            };

            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            TpsInputRetreiver retriever = new TpsInputRetreiver();
            List<TpsInputs> tpsInputs = retriever.retrieveInputs(
                pipelineTask.getId(), startCadence, endCadence,
                targetListChunk.getStartKeplerId(),
                targetListChunk.getEndKeplerId(), getTargetCrud(),
                getPdcCrud(), getTargetSelectionCrud(),
                getMjdToCadence(pipelineInstance),
                targetListChunk.getSkyGroupId(), fsClient,
                getTransitOps(pipelineInstance), getRollTimeOps(),
                getCelestialObjectOperations(pipelineTask, pipelineInstance),
                tpsModuleParameters, hIdent, gapFillParameters,
                bootstrapParameters,
                targetListParameters.targetListNames(),
                targetListParameters.excludeTargetListNames(), numElementsCalc,
                pipelineTask.getPipelineInstanceNode()
                    .getPipelineModuleDefinition()
                    .getExeTimeoutSecs(), 
                remoteExecutionParameters.getTasksPerCore());

            createProducerTaskIdsStream().write(workingDirectory, retriever.originators());

            if (tpsInputs.isEmpty()) {
                return;
            } else {
                for (TpsInputs inputs : tpsInputs) {
                    inputsHandler.addSubTaskInputs(inputs);
                }
                return;
            }
        } finally {
            DatabaseServiceFactory.getInstance().getSession().setFlushMode(FlushMode.AUTO);
        }
    }
    
    protected ProducerTaskIdsStream createProducerTaskIdsStream() {
        return new ProducerTaskIdsStream();
    }

    private Pair<Integer, Integer> computeCadenceInterval(PipelineTask pipelineTask) {
        CadenceRangeParameters cadenceRangeParameters = 
                pipelineTask.getParameters(CadenceRangeParameters.class);

        int startCadence = cadenceRangeParameters.getStartCadence();
        int endCadence = cadenceRangeParameters.getEndCadence();
        if (startCadence == 0 || endCadence == 0) {
            Pair<Integer, Integer> startStopTimes = 
                    getLogCrud().retrieveFirstAndLastCadences(Cadence.CADENCE_LONG);
            if (startStopTimes == null) {
                throw new ModuleFatalProcessingException("No data available.");
            }

            if (startCadence == 0) {
                startCadence = startStopTimes.left;
            }
            if (endCadence == 0) {
                endCadence = startStopTimes.right;
            }
        }

        log.info("Start cadence " + startCadence + " end cadence " + endCadence + ".");
        return Pair.of(startCadence, endCadence);
    }
    
    private void executeTpsDawgScript(){
        File dir = getCurrentWorkingDir();
        if(dir != null){
            IntervalMetricKey key = IntervalMetric.start();
            try {
                log.info("Running tps_dawg script for dir: " + dir);

                List<String> commandLineArgs = new LinkedList<String>();
                commandLineArgs.add(dir.getAbsolutePath());

                executeMatlab(TPS_DAWG_EXE_NAME, commandLineArgs, dir,
                        TPS_DAWG_EXE_TIMEOUT_SECS);
            } finally {
                IntervalMetric.stop("tps.dawg.execTime", key);
            }
        }else{
            log.info("No working dir, not running tps_dawg script");
        }
    }

    @Override
    public void processOutputs(PipelineTask pipelineTask,
            Iterator<AlgorithmResults> allAlgorithmResults) throws RuntimeException {

        log.info("Saving new TPS Results.");

        PeekingIterator<AlgorithmResults> resultIt = 
            Iterators.peekingIterator(allAlgorithmResults);
        File taskDir = resultIt.peek().getTaskDir();
        
        Set<Long> originators = createProducerTaskIdsStream().read(taskDir);
        DataAccountabilityTrail trail = 
                new DataAccountabilityTrail(pipelineTask.getId(), originators);

        getDaAcctCrud().create(trail);
        
        TpsModuleParameters tpsModuleParameters = 
                pipelineTask.getParameters(TpsModuleParameters.class);
        
        Pair<Integer, Integer> startEndCadence = computeCadenceInterval(pipelineTask);
        int startCadence = startEndCadence.left;
        int endCadence = startEndCadence.right;
        
        int successfulSubtaskCount = 0;

        TpsType lastTpsType = null;
        while (resultIt.hasNext()) {
            AlgorithmResults algorithmResults = resultIt.next();

            if (!algorithmResults.successful()) {
                log.warn("Skipping failed sub-task due to MATLAB error for sub-task "
                        + algorithmResults.getResultsDir());
                continue;
            }
            
            successfulSubtaskCount++;
            TpsOutputs tpsOutputsChunk = (TpsOutputs) algorithmResults.getOutputs();
            TpsType tpsType = storeOutputs(tpsOutputsChunk, tpsModuleParameters,
                    pipelineTask, startCadence, endCadence);
            if (lastTpsType == null) {
                lastTpsType = tpsType;
            } else if (lastTpsType != tpsType) {
                throw new IllegalStateException("Mixed tps lite and tps full results.");
            }
        }
        
        if (successfulSubtaskCount == 0) {
            throw new ModuleFatalProcessingException(
                "MATLAB did not return results for *any* sub-task, aborting this task.");
        }
        
        log.info("Wrote " + successfulSubtaskCount + " CDPP time series to file store.");

        if (lastTpsType == TpsType.TPS_FULL){
            executeTpsDawgScript();
        }
        
        log.info("Storing TPS output is complete.");
        
    }
        
    private TpsType storeOutputs(TpsOutputs tpsOutputs, 
            TpsModuleParameters tpsModuleParameters, PipelineTask pipelineTask,
            int startCadence, int endCadence) {

        List<TpsResult> tpsResults = tpsOutputs.getTpsResults();
        List<FloatTimeSeries> allFullFluxTimeSeries = 
                Lists.newArrayListWithCapacity(tpsResults.size());
        List<FloatTimeSeries> allWeakSecondaryTimeSeries =
            Lists.newLinkedList();
        TpsType tpsType = tpsModuleParameters.tpsType();
        FluxType fluxType = FluxType.SAP;
        
        for (TpsResult result : tpsResults) {
            storeSingleResult(allFullFluxTimeSeries,
                allWeakSecondaryTimeSeries,
                tpsType, result, startCadence,
                endCadence, fluxType, pipelineTask);

        }
    
        //So the weak secondary arrays are not time series, but just arrays.
        //They all start at zero and have at least one element.
        allWeakSecondaryTimeSeries = 
            fixStartEnd(allWeakSecondaryTimeSeries);
        
        TimeSeries[] writeMe = 
            new TimeSeries[allWeakSecondaryTimeSeries.size() + allFullFluxTimeSeries.size()];
        
        Iterator<FloatTimeSeries> allTimeSeriesIt = 
            Iterators.concat(allFullFluxTimeSeries.iterator(), allWeakSecondaryTimeSeries.iterator());
        int desti=0;
        while (allTimeSeriesIt.hasNext()) {
            writeMe[desti++] = allTimeSeriesIt.next();
        }
        Arrays.sort(writeMe, TimeSeriesByFsId.INSTANCE);
        FileStoreClientFactory.getInstance().writeTimeSeries(writeMe);
    
        int alertCount = 0;
        for (ModuleAlert alert : tpsOutputs.getAlerts()) {
            alertCount++;
            String msg = String.format(ALERT_MESSAGE_FORMAT,
                alert.getMessage(), alert.getTime());
            AlertServiceFactory.getInstance()
                .generateAlert(MODULE_NAME, pipelineTask.getId(),
                    Severity.valueOf(alert.getSeverity()), msg);
        }

        
        log.info("Wrote " + alertCount + "  TPS alerts to the database.");
        
        return tpsType;
    }

    /**
     * Changes the end cadence for the time series object if the existing time
     * series is longer than the series being stored.
     * 
     * @param allWeakSecondaryTimeSeries
     * @return
     */
    private List<FloatTimeSeries> fixStartEnd(List<FloatTimeSeries> allWeakSecondaryTimeSeries) {
        List<FloatTimeSeries> rv = Lists.newArrayList(allWeakSecondaryTimeSeries);
        
        FsId[] ids = new FsId[rv.size()];
        for (int i=0; i < ids.length; i++) {
            ids[i] = rv.get(i).id();
        }
        
        List<Interval>[] existingIntervals =
            FileStoreClientFactory.getInstance().getCadenceIntervalsForId(ids);
        
        for (int i = 0; i < ids.length; i++) {
            if (existingIntervals[i].isEmpty()) {
                continue;
            }
            FloatTimeSeries fts = rv.get(i);
            int existingEndCadence = (int)existingIntervals[i].get(0).end();
            if (existingEndCadence <= fts.endCadence()) {
                continue;
            }
            //Replace time series bounds with new authoritative bounds.
            float[] paddedSeries = Arrays.copyOf(fts.fseries(), existingEndCadence + 1);
            fts = new FloatTimeSeries(fts.id(), paddedSeries, fts.startCadence(), 
                existingEndCadence, fts.validCadences(), fts.originators());
            rv.set(i, fts);
        }
        return rv;
    }
    
    /**
     * 
     * @param allFullFluxTimeSeries these are time series defined for the full start and end cadence
     * interval. Time series are added to this list.  Non-null.
     * @param allWeakSecondaryTimeSeries these time series are more like regular arrays and may not
     * start and end on the start and end cadence intervals.
     * @param tpsType non-null
     * @param result non-null
     * @param fluxType non-null
     * @param pipelineTask non-null
     */
    private void storeSingleResult(List<FloatTimeSeries> allFullFluxTimeSeries,
        List<FloatTimeSeries> allWeakSecondaryTimeSeries,
        TpsType tpsType, TpsResult result,
        int startCadence, int endCadence, FluxType fluxType,
        PipelineTask pipelineTask) {
    
        long pipelineInstanceId = pipelineTask.getPipelineInstance().getId();
        AbstractTpsDbResult abstractTpsDbResult =
            result.toDbResult(tpsType, startCadence, endCadence, pipelineTask);
        
        if (tpsType == TpsType.TPS_FULL) {
            result.getWeakSecondary().putArrays(pipelineInstanceId, allWeakSecondaryTimeSeries,
                    result.getKeplerId(), result.getTrialTransitPulseInHours(),
                    pipelineTask);
            allFullFluxTimeSeries.add(result.deemphasizedNormalizationTimeSeries(startCadence, endCadence, pipelineTask));
            if (result.isResultValid() && result.isPlanetACandidate()) {
                allFullFluxTimeSeries.add(result.deemphasisWeight(startCadence, endCadence, pipelineTask));
            }
        }
        
        getTpsCrud().create(abstractTpsDbResult);

        FloatTimeSeries cdppTimeSeries =
            result.cdppTimeSeries(tpsType, startCadence, endCadence, pipelineTask);
        allFullFluxTimeSeries.add(cdppTimeSeries);

    }

  
    private TransitOperations getTransitOps(PipelineInstance pipelineInstance) {
        if (m.transitOps == null) {
            m.transitOps = new TransitOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }
        return m.transitOps;
    }
    
    void setTransitOps(TransitOperations transitOps) {
        m.transitOps = transitOps;
    }

    private RollTimeOperations getRollTimeOps() {
        if (m.rolltimeOps == null) {
            m.rolltimeOps = new RollTimeOperations();
        }
        return m.rolltimeOps;
    }

    void setRollTimeOperations(RollTimeOperations rollTimeOps) {
        m.rolltimeOps = rollTimeOps;
    }

    private MjdToCadence getMjdToCadence(PipelineInstance pipelineInstance) {
        if (m.mjdToCadence == null) {
            m.mjdToCadence = new MjdToCadence(CadenceType.LONG,
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }
        return m.mjdToCadence;
    }

    void setMjdToCadence(MjdToCadence mjdToCadence) {
        this.m.mjdToCadence = mjdToCadence;
    }

    private TpsCrud getTpsCrud() {
        if (m.tpsCrud == null) {
            m.tpsCrud = new TpsCrud();
        }
        return m.tpsCrud;
    }

    void setTpsCrud(TpsCrud tpsCrud) {
        this.m.tpsCrud = tpsCrud;
    }

    private LogCrud getLogCrud() {
        if (m.logCrud == null) {
            m.logCrud = new LogCrud();
        }
        return m.logCrud;
    }

    void setLogCrud(LogCrud logCrud) {
        this.m.logCrud = logCrud;
    }

    private TargetSelectionCrud getTargetSelectionCrud() {
        if (m.targetSelectionCrud == null) {
            m.targetSelectionCrud = new TargetSelectionCrud();
        }
        return m.targetSelectionCrud;
    }

    void setTargetSelectionCrud(TargetSelectionCrud targetSelectionCrud) {
        this.m.targetSelectionCrud = targetSelectionCrud;
    }

    private CelestialObjectOperations getCelestialObjectOperations(PipelineTask pipelineTask, PipelineInstance pipelineInstance) {
        if (m.celestialObjectOperations == null) {
            m.celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }

        return m.celestialObjectOperations;
    }

    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.m.celestialObjectOperations = celestialObjectOperations;
    }

    DataAccountabilityTrailCrud getDaAcctCrud() {
        if (m.daAcctCrud == null) {
            m.daAcctCrud = new DataAccountabilityTrailCrud();
        }
        return m.daAcctCrud;
    }

    void setDaAcctCrud(DataAccountabilityTrailCrud daAcctCrud) {
        this.m.daAcctCrud = daAcctCrud;
    }

    private TargetCrud getTargetCrud() {
        if (m.targetCrud == null) {
            m.targetCrud = new TargetCrud();
        }
        return m.targetCrud;
    }

    void setTargetCrud(TargetCrud targetCrud) {
        this.m.targetCrud = targetCrud;
    }
    
    void setPdcCrud(PdcCrud pdcCrud) {
        m.pdcCrud = pdcCrud;
    }
    
    private PdcCrud getPdcCrud() {
       if (m.pdcCrud == null) {
           m.pdcCrud = new PdcCrud();
       }
       return m.pdcCrud;
    }

}
