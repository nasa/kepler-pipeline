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

package gov.nasa.kepler.dv;

import static com.google.common.base.Preconditions.checkNotNull;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.DETRENDED;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.INITIAL;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.TRAPEZOIDAL_MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.WHITENED_MODEL_LIGHT_CURVE;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.io.DvBinaryDiscriminationResults;
import gov.nasa.kepler.dv.io.DvBootstrapHistogram;
import gov.nasa.kepler.dv.io.DvCentroidMotionResults;
import gov.nasa.kepler.dv.io.DvCentroidResults;
import gov.nasa.kepler.dv.io.DvComparisonTests;
import gov.nasa.kepler.dv.io.DvDifferenceImageMotionResults;
import gov.nasa.kepler.dv.io.DvDifferenceImagePixelData;
import gov.nasa.kepler.dv.io.DvDifferenceImageResults;
import gov.nasa.kepler.dv.io.DvDoubleQuantity;
import gov.nasa.kepler.dv.io.DvDoubleQuantityWithProvenance;
import gov.nasa.kepler.dv.io.DvLimbDarkeningModel;
import gov.nasa.kepler.dv.io.DvModelParameter;
import gov.nasa.kepler.dv.io.DvMqCentroidOffsets;
import gov.nasa.kepler.dv.io.DvMqImageCentroid;
import gov.nasa.kepler.dv.io.DvOutputs;
import gov.nasa.kepler.dv.io.DvPixelCorrelationMotionResults;
import gov.nasa.kepler.dv.io.DvPixelCorrelationResults;
import gov.nasa.kepler.dv.io.DvPixelStatistic;
import gov.nasa.kepler.dv.io.DvPlanetCandidate;
import gov.nasa.kepler.dv.io.DvPlanetModelFit;
import gov.nasa.kepler.dv.io.DvPlanetParameters;
import gov.nasa.kepler.dv.io.DvPlanetResults;
import gov.nasa.kepler.dv.io.DvPlanetStatistic;
import gov.nasa.kepler.dv.io.DvQuantity;
import gov.nasa.kepler.dv.io.DvQuantityWithProvenance;
import gov.nasa.kepler.dv.io.DvRollingBandContaminationHistogram;
import gov.nasa.kepler.dv.io.DvSingleEventStatistics;
import gov.nasa.kepler.dv.io.DvStatistic;
import gov.nasa.kepler.dv.io.DvSummaryOverlapMetric;
import gov.nasa.kepler.dv.io.DvSummaryQualityMetric;
import gov.nasa.kepler.dv.io.DvTargetResults;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription;
import gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.mr.GenericReportOperations;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Store DV pipeline module outputs.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvOutputsStorer {

    private static final Log log = LogFactory.getLog(DvOutputsStorer.class);

    public static final String MODULE_NAME = "dv";

    private static final String IMPACT_PARAMETER = "impactParameter";

    // Variables set by pipeline infrastructure.
    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;
    private int skyGroupId;
    private int startKeplerId;
    private int endKeplerId;
    private int startCadence;
    private int endCadence;
    private FluxType fluxType;
    private File matlabWorkingDir;
    private File taskWorkingDir;

    // CRUD.
    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();
    private LogCrud logCrud = new LogCrud();
    private DvCrud dvCrud = new DvCrud();
    private GenericReportOperations genericReportOperations = new GenericReportOperations();
    private AlertService alertService = AlertServiceFactory.getInstance();
    private ProducerTaskIdsStream producerTaskIdsStream = new ProducerTaskIdsStream();

    private String externalTceModelDescription;
    private String transitNameModelDescription;
    private String transitParameterModelDescription;

    public void storeOutputs(PipelineTask pipelineTask,
        Iterator<AlgorithmResults> outputs) throws PipelineException {

        initializeTask(pipelineTask);

        int successfulSubtaskCount = 0;

        while (outputs.hasNext()) {
            AlgorithmResults algorithmResults = outputs.next();

            if (!algorithmResults.successful()) {
                log.warn("Skipping failed sub-task due to MATLAB error for sub-task "
                    + algorithmResults.getResultsDir());
                continue;
            }

            successfulSubtaskCount++;
            DvOutputs dvOutputs = (DvOutputs) algorithmResults.getOutputs();
            setTaskWorkingDir(algorithmResults.getTaskDir());
            setMatlabWorkingDir(algorithmResults.getResultsDir());
            storeOutputsInternal(dvOutputs);
        }

        if (successfulSubtaskCount == 0) {
            throw new ModuleFatalProcessingException(
                "MATLAB did not return results for *any* sub-task, aborting this task.");
        }

        DvExternalTceModelDescription dvExternalTceModelDescription = new DvExternalTceModelDescription(
            pipelineTask, externalTceModelDescription);
        log.info("externalTceModelDescription: " + externalTceModelDescription);
        dvCrud.create(dvExternalTceModelDescription);

        if ((transitNameModelDescription != null && transitNameModelDescription.length() > 0)
            || (transitParameterModelDescription != null && transitParameterModelDescription.length() > 0)) {
            DvTransitModelDescriptions dvTransitModelDescriptions = new DvTransitModelDescriptions(
                pipelineTask, transitNameModelDescription,
                transitParameterModelDescription);
            log.info("dvTransitModelDescriptions: "
                + dvTransitModelDescriptions);
            dvCrud.create(dvTransitModelDescriptions);
        }

        Set<Long> producerTaskIds = producerTaskIdsStream.read(getTaskWorkingDir());
        daCrud.create(pipelineTask, producerTaskIds);
    }

    private void initializeTask(PipelineTask pipelineTask) {

        pipelineInstance = pipelineTask.getPipelineInstance();
        this.pipelineTask = pipelineTask;

        PlanetaryCandidatesChunkUowTask task = pipelineTask.uowTaskInstance();
        log.debug("uow=" + task);

        skyGroupId = task.getSkyGroupId();
        startKeplerId = task.getStartKeplerId();
        endKeplerId = task.getEndKeplerId();

        CadenceRangeParameters cadenceRangeParameters = pipelineTask.getParameters(CadenceRangeParameters.class);
        startCadence = cadenceRangeParameters.getStartCadence();
        endCadence = cadenceRangeParameters.getEndCadence();
        if (startCadence == 0 || endCadence == 0) {
            Pair<Integer, Integer> firstAndLastCadences = logCrud.retrieveFirstAndLastCadences(Cadence.CADENCE_LONG);
            startCadence = startCadence > 0 ? startCadence
                : firstAndLastCadences.left;
            endCadence = endCadence > 0 ? endCadence
                : firstAndLastCadences.right;
        }

        fluxType = FluxType.valueOf(retrieveFluxTypeParameters().getFluxType());

        log.debug("skyGroupId: " + skyGroupId);
        log.debug("startKeplerId: " + startKeplerId);
        log.debug("endKeplerId: " + endKeplerId);
        log.debug("startCadence: " + startCadence);
        log.debug("endCadence: " + endCadence);
        log.debug("fluxType: " + fluxType);
        log.debug("pipelineInstance: " + pipelineInstance.getId());
        log.debug("pipelineTask: " + pipelineTask.getId());
    }

    private FluxTypeParameters retrieveFluxTypeParameters() {
        FluxTypeParameters fluxTypeParameters = pipelineTask.getParameters(FluxTypeParameters.class);

        return fluxTypeParameters;
    }

    protected void storeOutputsInternal(DvOutputs dvOutputs) {

        List<gov.nasa.kepler.hibernate.dv.DvPlanetResults> planetResults = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPlanetResults>();
        List<gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel> limbDarkeningModels = new ArrayList<gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel>();
        List<gov.nasa.kepler.hibernate.dv.DvTargetResults> targetResults = new ArrayList<gov.nasa.kepler.hibernate.dv.DvTargetResults>();
        List<TimeSeries> timeSeriesList = new ArrayList<TimeSeries>();
        DvModuleParameters dvModuleParameters = pipelineTask.getParameters(DvModuleParameters.class);

        for (DvTargetResults dvTargetResults : dvOutputs.getTargetResults()) {

            // Persist the DV report.
            storeMissionReport(Integer.toString(dvTargetResults.getKeplerId()),
                getMatlabWorkingDir(), dvTargetResults.getReportFilename());

            // Persist the limb darkening models.
            for (DvLimbDarkeningModel dvLimbDarkeningModel : dvTargetResults.getLimbDarkeningModels()) {
                limbDarkeningModels.add(createLimbDarkeningModel(dvLimbDarkeningModel));
            }

            // Persist the target specific DB outputs.
            targetResults.add(createTargetResults(dvTargetResults));

            // Persist the planet results.
            for (DvPlanetResults dvPlanetResults : dvTargetResults.getPlanetResults()) {

                // Persist the DV report summary.
                storeMissionReport(String.format("%09d-%02d",
                    dvTargetResults.getKeplerId(),
                    dvPlanetResults.getPlanetNumber()), getMatlabWorkingDir(),
                    dvPlanetResults.getReportFilename());

                planetResults.add(createPlanetResults(
                    dvTargetResults.getKeplerId(), dvPlanetResults));

                timeSeriesList.addAll(createCorrectedFluxTimeSeries(INITIAL,
                    dvTargetResults.getKeplerId(),
                    dvPlanetResults.getPlanetCandidate()
                        .getInitialFluxTimeSeries(),
                    dvPlanetResults.getPlanetNumber()));

                timeSeriesList.add(createFoldedPhaseTimeSeries(
                    dvTargetResults.getKeplerId(),
                    dvPlanetResults.getFoldedPhase(),
                    dvPlanetResults.getPlanetNumber()));

                timeSeriesList.add(createLightCurveTimeSeries(
                    MODEL_LIGHT_CURVE, dvTargetResults.getKeplerId(),
                    dvPlanetResults.getModelLightCurve(),
                    dvPlanetResults.getPlanetNumber()));

                timeSeriesList.add(createLightCurveTimeSeries(
                    WHITENED_MODEL_LIGHT_CURVE, dvTargetResults.getKeplerId(),
                    dvPlanetResults.getWhitenedModelLightCurve(),
                    dvPlanetResults.getPlanetNumber()));

                timeSeriesList.add(createLightCurveTimeSeries(
                    TRAPEZOIDAL_MODEL_LIGHT_CURVE,
                    dvTargetResults.getKeplerId(),
                    dvPlanetResults.getTrapezoidalModelLightCurve(),
                    dvPlanetResults.getPlanetNumber()));

                timeSeriesList.add(createFluxTimeSeries(
                    dvTargetResults.getKeplerId(),
                    dvPlanetResults.getWhitenedFluxTimeSeries(),
                    dvPlanetResults.getPlanetNumber()));

                timeSeriesList.addAll(createCorrectedFluxTimeSeries(DETRENDED,
                    dvTargetResults.getKeplerId(),
                    dvPlanetResults.getDetrendedFluxTimeSeries(),
                    dvPlanetResults.getPlanetNumber()));

                if (dvModuleParameters.isStoreRobustWeightsEnabled()) {
                    timeSeriesList.add(createRobustWeights(
                        dvTargetResults.getKeplerId(),
                        dvPlanetResults.getPlanetNumber(),
                        PlanetModelFitType.ALL,
                        dvPlanetResults.getAllTransitsFit()
                            .getRobustWeights()));
                    timeSeriesList.add(createRobustWeights(
                        dvTargetResults.getKeplerId(),
                        dvPlanetResults.getPlanetNumber(),
                        PlanetModelFitType.EVEN,
                        dvPlanetResults.getEvenTransitsFit()
                            .getRobustWeights()));
                    timeSeriesList.add(createRobustWeights(
                        dvTargetResults.getKeplerId(),
                        dvPlanetResults.getPlanetNumber(),
                        PlanetModelFitType.ODD,
                        dvPlanetResults.getOddTransitsFit()
                            .getRobustWeights()));
                    timeSeriesList.add(createRobustWeights(
                        dvTargetResults.getKeplerId(),
                        dvPlanetResults.getPlanetNumber(),
                        PlanetModelFitType.TRAPEZOIDAL,
                        dvPlanetResults.getTrapezoidalFit()
                            .getRobustWeights()));
                    for (int i = 0; i < dvPlanetResults.getReducedParameterFits()
                        .size(); i++) {
                        DvPlanetModelFit planetModelFit = dvPlanetResults.getReducedParameterFits()
                            .get(i);
                        Double parameterValue = retrieveModelParameterValue(
                            planetModelFit, IMPACT_PARAMETER);
                        if (parameterValue == null) {
                            log.warn(String.format(
                                "Model parameters for keplerId %d, planet %d missing expected %s",
                                dvTargetResults.getKeplerId(),
                                dvPlanetResults.getPlanetNumber(),
                                IMPACT_PARAMETER));
                            continue;
                        }
                        timeSeriesList.add(createReducedParameterRobustWeights(
                            dvTargetResults.getKeplerId(),
                            dvPlanetResults.getPlanetNumber(),
                            IMPACT_PARAMETER, parameterValue,
                            planetModelFit.getRobustWeights()));
                    }
                }
            }

            // Persist the target specific time series.
            timeSeriesList.addAll(createResidualFluxTimeSeries(
                dvTargetResults.getKeplerId(),
                dvTargetResults.getResidualFluxTimeSeries()));
            timeSeriesList.addAll(createSingleEventStatisticsTimeSeries(
                dvTargetResults.getKeplerId(),
                dvTargetResults.getSingleEventStatistics()));

            timeSeriesList.add(createBarycentricCorrectedTimestampsTimeSeries(
                dvTargetResults.getKeplerId(),
                dvTargetResults.getBarycentricCorrectedTimestamps()));
        }

        dvCrud.createPlanetResultsCollection(planetResults);
        dvCrud.createLimbDarkeningModelsCollection(limbDarkeningModels);
        dvCrud.createTargetResultsCollection(targetResults);

        log.debug("dvOutputs.getExternalTceModelDescription(): "
            + dvOutputs.getExternalTceModelDescription());
        if (externalTceModelDescription == null) {
            externalTceModelDescription = dvOutputs.getExternalTceModelDescription();
        } else if (!externalTceModelDescription.equals(dvOutputs.getExternalTceModelDescription())) {
            throw new ModuleFatalProcessingException(String.format(
                "External TCE model descriptions vary, "
                    + "was \"%s\" but now is \"%s\"",
                externalTceModelDescription,
                dvOutputs.getExternalTceModelDescription()));
        }

        log.debug("dvOutputs.getTransitNameModelDescription(): "
            + dvOutputs.getTransitNameModelDescription());
        if (transitNameModelDescription == null) {
            transitNameModelDescription = dvOutputs.getTransitNameModelDescription();
        } else if (!transitNameModelDescription.equals(dvOutputs.getTransitNameModelDescription())) {
            throw new ModuleFatalProcessingException(String.format(
                "Transit name model descriptions vary, "
                    + "was \"%s\" but now is \"%s\"",
                transitNameModelDescription,
                dvOutputs.getTransitNameModelDescription()));
        }

        log.debug("dvOutputs.getTransitParameterModelDescription(): "
            + dvOutputs.getTransitParameterModelDescription());
        if (transitParameterModelDescription == null) {
            transitParameterModelDescription = dvOutputs.getTransitParameterModelDescription();
        } else if (!transitParameterModelDescription.equals(dvOutputs.getTransitParameterModelDescription())) {
            throw new ModuleFatalProcessingException(String.format(
                "Transit parameter model descriptions vary, "
                    + "was \"%s\" but now is \"%s\"",
                transitParameterModelDescription,
                dvOutputs.getTransitParameterModelDescription()));
        }

        FileStoreClientFactory.getInstance()
            .writeTimeSeries(timeSeriesList.toArray(new TimeSeries[0]));

        if (dvOutputs.getAlerts()
            .size() > 0) {
            for (ModuleAlert alert : dvOutputs.getAlerts()) {
                alertService.generateAlert(MODULE_NAME, pipelineTask.getId(),
                    Severity.valueOf(alert.getSeverity()), alert.getMessage()
                        + ": time=" + alert.getTime());
            }
        }
    }

    private gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel createLimbDarkeningModel(
        DvLimbDarkeningModel dvLimbDarkeningModel) {

        return new gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel.Builder(
            dvLimbDarkeningModel.getTargetTableId(), fluxType,
            dvLimbDarkeningModel.getKeplerId(), pipelineTask).ccdModule(
            dvLimbDarkeningModel.getCcdModule())
            .ccdOutput(dvLimbDarkeningModel.getCcdOutput())
            .startCadence(dvLimbDarkeningModel.getStartCadence())
            .endCadence(dvLimbDarkeningModel.getEndCadence())
            .quarter(dvLimbDarkeningModel.getQuarter())
            .modelName(dvLimbDarkeningModel.getModelName())
            .coefficient1(dvLimbDarkeningModel.getCoefficient1())
            .coefficient2(dvLimbDarkeningModel.getCoefficient2())
            .coefficient3(dvLimbDarkeningModel.getCoefficient3())
            .coefficient4(dvLimbDarkeningModel.getCoefficient4())
            .build();
    }

    private gov.nasa.kepler.hibernate.dv.DvTargetResults createTargetResults(
        DvTargetResults dvTargetResults) {
        return new gov.nasa.kepler.hibernate.dv.DvTargetResults.Builder(
            fluxType, startCadence, endCadence, dvTargetResults.getKeplerId(),
            pipelineTask).planetCandidateCount(
            dvTargetResults.getPlanetResults()
                .size())
            .quartersObserved(dvTargetResults.getQuartersObserved())
            .radius(createDvQuantityWithProvenance(dvTargetResults.getRadius()))
            .effectiveTemp(
                createDvQuantityWithProvenance(dvTargetResults.getEffectiveTemp()))
            .log10SurfaceGravity(
                createDvQuantityWithProvenance(dvTargetResults.getLog10SurfaceGravity()))
            .log10Metallicity(
                createDvQuantityWithProvenance(dvTargetResults.getLog10Metallicity()))
            .decDegrees(
                createDvDoubleQuantityWithProvenance(dvTargetResults.getDecDegrees()))
            .keplerMag(
                createDvQuantityWithProvenance(dvTargetResults.getKeplerMag()))
            .raHours(
                createDvDoubleQuantityWithProvenance(dvTargetResults.getRaHours()))
            .koiId(dvTargetResults.getKoiId())
            .keplerName(dvTargetResults.getKeplerName())
            .matchedKoiIds(Arrays.asList(dvTargetResults.getMatchedKoiIds()))
            .unmatchedKoiIds(
                Arrays.asList(dvTargetResults.getUnmatchedKoiIds()))
            .build();
    }

    private gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenance createDvQuantityWithProvenance(
        DvQuantityWithProvenance dvQuantityWithProvenance) {
        return new gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenance(
            dvQuantityWithProvenance.getValue(),
            dvQuantityWithProvenance.getUncertainty(),
            dvQuantityWithProvenance.getProvenance());
    }

    private gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenance createDvDoubleQuantityWithProvenance(
        DvDoubleQuantityWithProvenance dvDoubleQuantityWithProvenance) {
        return new gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenance(
            dvDoubleQuantityWithProvenance.getValue(),
            dvDoubleQuantityWithProvenance.getUncertainty(),
            dvDoubleQuantityWithProvenance.getProvenance());
    }

    private void storeMissionReport(String identifier, File workingDir,
        String reportFilename) {

        if (reportFilename.length() == 0) {
            log.warn("Report filename not given (yet) so mission report not saved");
            return;
        }

        log.info("storing mission report: " + reportFilename);

        File file = new File(workingDir, reportFilename);
        genericReportOperations.createReport(pipelineTask, identifier, file);
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetResults createPlanetResults(
        int keplerId, DvPlanetResults dvPlanetResults) {

        gov.nasa.kepler.hibernate.dv.DvPlanetModelFit allTransitsFit = createPlanetModelFit(
            keplerId, dvPlanetResults.getPlanetNumber(),
            PlanetModelFitType.ALL, dvPlanetResults.getAllTransitsFit());
        gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults binaryDiscriminationResults = createBinaryDiscriminationResults(
            keplerId, dvPlanetResults.getPlanetNumber(),
            dvPlanetResults.getBinaryDiscriminationResults());
        gov.nasa.kepler.hibernate.dv.DvCentroidResults centroidResults = createCentroidResults(
            keplerId, dvPlanetResults.getPlanetNumber(),
            dvPlanetResults.getCentroidResults());
        List<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults> differenceImageResults = createDifferenceImageResults(dvPlanetResults.getDifferenceImageResults());
        gov.nasa.kepler.hibernate.dv.DvPlanetModelFit evenTransitsFit = createPlanetModelFit(
            keplerId, dvPlanetResults.getPlanetNumber(),
            PlanetModelFitType.EVEN, dvPlanetResults.getEvenTransitsFit());
        gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults ghostDiagnosticResults = createGhostDiagnosticResults(dvPlanetResults.getGhostDiagnosticResults());
        gov.nasa.kepler.hibernate.dv.DvPlanetModelFit oddTransitsFit = createPlanetModelFit(
            keplerId, dvPlanetResults.getPlanetNumber(),
            PlanetModelFitType.ODD, dvPlanetResults.getOddTransitsFit());
        List<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults> pixelCorrelationResults = createPixelCorrelationResults(
            keplerId, dvPlanetResults.getPixelCorrelationResults());
        gov.nasa.kepler.hibernate.dv.DvPlanetCandidate planetCandidate = createPlanetCandidate(
            keplerId, dvPlanetResults.getPlanetNumber(),
            dvPlanetResults.getPlanetCandidate());
        List<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit> reducedParameterFits = createPlanetModelFits(
            keplerId, dvPlanetResults.getPlanetNumber(),
            PlanetModelFitType.REDUCED_PARAMETER,
            dvPlanetResults.getReducedParameterFits());
        gov.nasa.kepler.hibernate.dv.DvPlanetModelFit trapezoidalFit = createPlanetModelFit(
            keplerId, dvPlanetResults.getPlanetNumber(),
            PlanetModelFitType.TRAPEZOIDAL, dvPlanetResults.getTrapezoidalFit());
        gov.nasa.kepler.hibernate.dv.DvSecondaryEventResults secondaryEventResults = createSecondaryEventResults(dvPlanetResults.getSecondaryEventResults());
        gov.nasa.kepler.hibernate.dv.DvImageArtifactResults imageArtifactResults = createImageArtifactResults(dvPlanetResults.getImageArtifactResults());

        return new gov.nasa.kepler.hibernate.dv.DvPlanetResults.Builder(
            startCadence, endCadence, keplerId,
            dvPlanetResults.getPlanetNumber(), pipelineTask).allTransitsFit(
            allTransitsFit)
            .binaryDiscriminationResults(binaryDiscriminationResults)
            .centroidResults(centroidResults)
            .detrendFilterLength(dvPlanetResults.getDetrendFilterLength())
            .differenceImageResults(differenceImageResults)
            .evenTransitsFit(evenTransitsFit)
            .ghostDiagnosticResults(ghostDiagnosticResults)
            .fluxType(fluxType)
            .imageArtifactResults(imageArtifactResults)
            .keplerName(dvPlanetResults.getKeplerName())
            .koiCorrelation(dvPlanetResults.getKoiCorrelation())
            .koiId(dvPlanetResults.getKoiId())
            .oddTransitsFit(oddTransitsFit)
            .pixelCorrelationResults(pixelCorrelationResults)
            .planetCandidate(planetCandidate)
            .reducedParameterFits(reducedParameterFits)
            .secondaryEventResults(secondaryEventResults)
            .trapezoidalFit(trapezoidalFit)
            .build();
    }

    private List<TimeSeries> createCorrectedFluxTimeSeries(
        DvCorrectedFluxType lightCurveType, int keplerId,
        CorrectedFluxTimeSeries initialFluxTimeSeries, int planetNumber) {

        FsId valuesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, lightCurveType, DvTimeSeriesType.FLUX,
            pipelineInstance.getId(), keplerId, planetNumber);
        FsId uncertaintiesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, lightCurveType, DvTimeSeriesType.UNCERTAINTIES,
            pipelineInstance.getId(), keplerId, planetNumber);
        FsId filledIndicesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, lightCurveType, DvTimeSeriesType.FILLED_INDICES,
            pipelineInstance.getId(), keplerId, planetNumber);

        return initialFluxTimeSeries.toTimeSeries(valuesFsId,
            uncertaintiesFsId, filledIndicesFsId, startCadence, endCadence,
            pipelineTask.getId());
    }

    private TimeSeries createFoldedPhaseTimeSeries(int keplerId,
        float[] foldedPhase, int planetNumber) {

        return new FloatTimeSeries(DvFsIdFactory.getFoldedPhaseTimeSeriesFsId(
            fluxType, pipelineInstance.getId(), keplerId, planetNumber),
            foldedPhase, startCadence, endCadence,
            new boolean[foldedPhase.length], pipelineTask.getId());
    }

    private FloatTimeSeries createLightCurveTimeSeries(
        DvLightCurveType lightCurveType, int keplerId,
        SimpleFloatTimeSeries modelLightCurve, int planetNumber) {

        return SimpleTimeSeries.toFloatTimeSeries(modelLightCurve,
            DvFsIdFactory.getLightCurveTimeSeriesFsId(fluxType, lightCurveType,
                pipelineInstance.getId(), keplerId, planetNumber),
            startCadence, endCadence, pipelineTask.getId());
    }

    private FloatTimeSeries createFluxTimeSeries(int keplerId,
        SimpleFloatTimeSeries flux, int planetNumber) {

        return SimpleTimeSeries.toFloatTimeSeries(flux,
            DvFsIdFactory.getFluxTimeSeriesFsId(fluxType, "WhitenedFlux",
                pipelineInstance.getId(), keplerId, planetNumber),
            startCadence, endCadence, pipelineTask.getId());
    }

    private TimeSeries createRobustWeights(int keplerId, int planetNumber,
        PlanetModelFitType type, float[] robustWeights) {

        return new FloatTimeSeries(
            DvFsIdFactory.getRobustWeightsTimeSeriesFsId(fluxType, type,
                pipelineInstance.getId(), keplerId, planetNumber),
            robustWeights, startCadence, endCadence,
            new boolean[robustWeights.length], pipelineTask.getId());
    }

    private TimeSeries createReducedParameterRobustWeights(int keplerId,
        int planetNumber, String parameterName, double parameterValue,
        float[] robustWeights) {

        return new FloatTimeSeries(
            DvFsIdFactory.getReducedParameterRobustWeightsTimeSeriesFsId(
                fluxType, pipelineInstance.getId(), keplerId, planetNumber,
                parameterName, parameterValue), robustWeights, startCadence,
            endCadence, new boolean[robustWeights.length], pipelineTask.getId());
    }

    private Double retrieveModelParameterValue(DvPlanetModelFit planetModelFit,
        String parameterName) {

        Double parameterValue = null;
        for (DvModelParameter modelParameter : planetModelFit.getModelParameters()) {
            if (modelParameter.getName()
                .equals(parameterName)) {
                parameterValue = modelParameter.getValue();
                break;
            }
        }

        return parameterValue;
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetModelFit createPlanetModelFit(
        int keplerId, int planetNumber, PlanetModelFitType type,
        DvPlanetModelFit planetModelFit) {

        float[] covariance = planetModelFit.getModelParameterCovariance();
        List<Float> modelParameterCovariance = new ArrayList<Float>(
            covariance.length);
        for (float value : covariance) {
            modelParameterCovariance.add(value);
        }

        List<DvModelParameter> parameters = planetModelFit.getModelParameters();
        List<gov.nasa.kepler.hibernate.dv.DvModelParameter> modelParameters = new ArrayList<gov.nasa.kepler.hibernate.dv.DvModelParameter>();
        for (DvModelParameter parameter : parameters) {
            modelParameters.add(new gov.nasa.kepler.hibernate.dv.DvModelParameter(
                parameter.getName(), parameter.getValue(),
                parameter.getUncertainty(), parameter.isFitted()));
        }

        return new gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.Builder(
            keplerId, planetNumber, pipelineTask).fullConvergence(
            planetModelFit.isFullConvergence())
            .limbDarkeningModelName(planetModelFit.getLimbDarkeningModelName())
            .modelChiSquare(planetModelFit.getModelChiSquare())
            .modelDegreesOfFreedom(planetModelFit.getModelDegreesOfFreedom())
            .modelFitSnr(planetModelFit.getModelFitSnr())
            .modelParameterCovariance(modelParameterCovariance)
            .modelParameters(modelParameters)
            .transitModelName(planetModelFit.getTransitModelName())
            .type(type)
            .build();
    }

    private List<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit> createPlanetModelFits(
        int keplerId, int planetNumber, PlanetModelFitType type,
        List<DvPlanetModelFit> srcPlanetModelFits) {

        List<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit> destPlanetModelFits = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPlanetModelFit>(
            srcPlanetModelFits.size());
        for (DvPlanetModelFit planetModelFit : srcPlanetModelFits) {
            destPlanetModelFits.add(createPlanetModelFit(keplerId,
                planetNumber, type, planetModelFit));
        }

        return destPlanetModelFits;
    }

    private gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults createBinaryDiscriminationResults(
        int keplerId, int planetNumber,
        DvBinaryDiscriminationResults binaryDiscriminationResults) {

        DvPlanetStatistic planetStatistic = binaryDiscriminationResults.getShorterPeriodComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvPlanetStatistic shorterPeriod = new gov.nasa.kepler.hibernate.dv.DvPlanetStatistic(
            planetStatistic.getPlanetNumber(), planetStatistic.getValue(),
            planetStatistic.getSignificance());

        planetStatistic = binaryDiscriminationResults.getLongerPeriodComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvPlanetStatistic longerPeriod = new gov.nasa.kepler.hibernate.dv.DvPlanetStatistic(
            planetStatistic.getPlanetNumber(), planetStatistic.getValue(),
            planetStatistic.getSignificance());

        DvStatistic statistic = binaryDiscriminationResults.getOddEvenTransitEpochComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic oddEvenTransitEpoch = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        statistic = binaryDiscriminationResults.getOddEvenTransitDepthComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic oddEvenTransitDepth = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        statistic = binaryDiscriminationResults.getSingleTransitDepthComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic singleTransitDepth = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        statistic = binaryDiscriminationResults.getSingleTransitDurationComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic singleTransitDuration = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        statistic = binaryDiscriminationResults.getSingleTransitEpochComparisonStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic singleTransitEpoch = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        return new gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults(
            shorterPeriod, longerPeriod, oddEvenTransitEpoch,
            oddEvenTransitDepth, singleTransitDepth, singleTransitDuration,
            singleTransitEpoch);
    }

    private gov.nasa.kepler.hibernate.dv.DvCentroidResults createCentroidResults(
        int keplerId, int planetNumber, DvCentroidResults centroidResults) {

        gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults fluxWeighted = createCentroidMotionResults(centroidResults.getFluxWeightedMotionResults());
        gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults prf = createCentroidMotionResults(centroidResults.getPrfMotionResults());
        gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults differenceImage = createDifferenceImageMotionResults(centroidResults.getDifferenceImageMotionResults());
        gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults pixelCorrelation = createPixelCorrelationMotionResults(centroidResults.getPixelCorrelationMotionResults());

        return new gov.nasa.kepler.hibernate.dv.DvCentroidResults(fluxWeighted,
            prf, differenceImage, pixelCorrelation);
    }

    private gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults createCentroidMotionResults(
        DvCentroidMotionResults centroidMotionResults) {

        DvDoubleQuantity doubleQuantity = centroidMotionResults.getSourceRaHours();
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity sourceRaHours = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        doubleQuantity = centroidMotionResults.getSourceDecDegrees();
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity sourceDecDegrees = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        doubleQuantity = centroidMotionResults.getOutOfTransitCentroidRaHours();
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity outOfTransitCentroidRaHours = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        doubleQuantity = centroidMotionResults.getOutOfTransitCentroidDecDegrees();
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity outOfTransitCentroidDecDegrees = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        DvQuantity quantity = centroidMotionResults.getSourceRaOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity sourceRaOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = centroidMotionResults.getSourceDecOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity sourceDecOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = centroidMotionResults.getSourceOffsetArcSec();
        gov.nasa.kepler.hibernate.dv.DvQuantity sourceOffsetArcSec = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = centroidMotionResults.getPeakRaOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity peakRaOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = centroidMotionResults.getPeakDecOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity peakDecOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = centroidMotionResults.getPeakOffsetArcSec();
        gov.nasa.kepler.hibernate.dv.DvQuantity peakOffsetArcSec = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        DvStatistic statistic = centroidMotionResults.getMotionDetectionStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic motionDetectionStatistic = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        return new gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults(
            sourceRaHours, sourceDecDegrees, outOfTransitCentroidRaHours,
            outOfTransitCentroidDecDegrees, sourceRaOffset, sourceDecOffset,
            sourceOffsetArcSec, peakRaOffset, peakDecOffset, peakOffsetArcSec,
            motionDetectionStatistic);
    }

    private gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric createSummaryQualityMetric(
        DvSummaryQualityMetric summaryQualityMetric) {

        return new gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric(
            summaryQualityMetric.getFractionOfGoodMetrics(),
            summaryQualityMetric.getNumberOfAttempts(),
            summaryQualityMetric.getNumberOfGoodMetrics(),
            summaryQualityMetric.getNumberOfMetrics(),
            summaryQualityMetric.getQualityThreshold());
    }

    private gov.nasa.kepler.hibernate.dv.DvSummaryOverlapMetric createSummaryOverlapMetric(
        DvSummaryOverlapMetric summaryOverlapMetric) {

        return new gov.nasa.kepler.hibernate.dv.DvSummaryOverlapMetric(
            summaryOverlapMetric.getImageCount(),
            summaryOverlapMetric.getImageCountNoOverlap(),
            summaryOverlapMetric.getImageCountFractionNoOverlap());
    }

    private gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults createPixelCorrelationMotionResults(
        DvPixelCorrelationMotionResults pixelCorrelationMotionResults) {

        gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets mqControlCentroidOffsets = createMqCentroidOffsets(pixelCorrelationMotionResults.getMqControlCentroidOffsets());
        gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets mqKicCentroidOffsets = createMqCentroidOffsets(pixelCorrelationMotionResults.getMqKicCentroidOffsets());
        gov.nasa.kepler.hibernate.dv.DvMqImageCentroid mqControlImageCentroid = createMqImageCentroid(pixelCorrelationMotionResults.getMqControlImageCentroid());
        gov.nasa.kepler.hibernate.dv.DvMqImageCentroid mqCorrelationImageCentroid = createMqImageCentroid(pixelCorrelationMotionResults.getMqCorrelationImageCentroid());

        return new gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults(
            mqControlCentroidOffsets, mqKicCentroidOffsets,
            mqControlImageCentroid, mqCorrelationImageCentroid);
    }

    private gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets createMqCentroidOffsets(
        DvMqCentroidOffsets mqCentroidOffsets) {

        DvQuantity quantity = mqCentroidOffsets.getMeanDecOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity meanDecOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = mqCentroidOffsets.getMeanRaOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity meanRaOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = mqCentroidOffsets.getMeanSkyOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity meanSkyOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = mqCentroidOffsets.getSingleFitDecOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity singleFitDecOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = mqCentroidOffsets.getSingleFitRaOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity singleFitRaOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        quantity = mqCentroidOffsets.getSingleFitSkyOffset();
        gov.nasa.kepler.hibernate.dv.DvQuantity singleFitSkyOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            quantity.getValue(), quantity.getUncertainty());

        return new gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets(
            meanDecOffset, meanRaOffset, meanSkyOffset, singleFitDecOffset,
            singleFitRaOffset, singleFitSkyOffset);
    }

    private gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults createDifferenceImageMotionResults(
        DvDifferenceImageMotionResults differenceImageMotionResults) {

        gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets mqControlCentroidOffsets = createMqCentroidOffsets(differenceImageMotionResults.getMqControlCentroidOffsets());
        gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets mqKicCentroidOffsets = createMqCentroidOffsets(differenceImageMotionResults.getMqKicCentroidOffsets());
        gov.nasa.kepler.hibernate.dv.DvMqImageCentroid mqControlImageCentroid = createMqImageCentroid(differenceImageMotionResults.getMqControlImageCentroid());
        gov.nasa.kepler.hibernate.dv.DvMqImageCentroid mqDifferenceImageCentroid = createMqImageCentroid(differenceImageMotionResults.getMqDifferenceImageCentroid());
        gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric qualitySummaryMetric = createSummaryQualityMetric(differenceImageMotionResults.getSummaryQualityMetric());
        gov.nasa.kepler.hibernate.dv.DvSummaryOverlapMetric overlapSummaryMetric = createSummaryOverlapMetric(differenceImageMotionResults.getSummaryOverlapMetric());

        return new gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults(
            mqControlCentroidOffsets, mqKicCentroidOffsets,
            mqControlImageCentroid, mqDifferenceImageCentroid,
            qualitySummaryMetric, overlapSummaryMetric);
    }

    private gov.nasa.kepler.hibernate.dv.DvMqImageCentroid createMqImageCentroid(
        DvMqImageCentroid mqImageCentroid) {

        DvDoubleQuantity doubleQuantity = mqImageCentroid.getDecDegrees();
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity decDegrees = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        doubleQuantity = mqImageCentroid.getRaHours();
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity raHours = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            doubleQuantity.getValue(), doubleQuantity.getUncertainty());

        return new gov.nasa.kepler.hibernate.dv.DvMqImageCentroid(decDegrees,
            raHours);
    }

    private List<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults> createDifferenceImageResults(
        List<DvDifferenceImageResults> srcDifferenceImageResultsList) {

        List<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults> destDifferenceImageResultsList = new ArrayList<gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults>(
            srcDifferenceImageResultsList.size());

        for (DvDifferenceImageResults srcDifferenceImageResults : srcDifferenceImageResultsList) {
            gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults destDifferenceImageResults = new gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults.Builder(
                srcDifferenceImageResults.getTargetTableId()).ccdModule(
                srcDifferenceImageResults.getCcdModule())
                .ccdOutput(srcDifferenceImageResults.getCcdOutput())
                .startCadence(srcDifferenceImageResults.getStartCadence())
                .endCadence(srcDifferenceImageResults.getEndCadence())
                .quarter(srcDifferenceImageResults.getQuarter())
                .controlCentroidOffsets(
                    createCentroidOffsets(srcDifferenceImageResults.getControlCentroidOffsets()))
                .controlImageCentroid(
                    createImageCentroid(srcDifferenceImageResults.getControlImageCentroid()))
                .differenceImageCentroid(
                    createImageCentroid(srcDifferenceImageResults.getDifferenceImageCentroid()))
                .kicCentroidOffsets(
                    createCentroidOffsets(srcDifferenceImageResults.getKicCentroidOffsets()))
                .kicReferenceCentroid(
                    createImageCentroid(srcDifferenceImageResults.getKicReferenceCentroid()))
                .numberOfTransits(
                    srcDifferenceImageResults.getNumberOfTransits())
                .numberOfCadencesInTransit(
                    srcDifferenceImageResults.getNumberOfCadencesInTransit())
                .numberOfCadenceGapsInTransit(
                    srcDifferenceImageResults.getNumberOfCadenceGapsInTransit())
                .numberOfCadencesOutOfTransit(
                    srcDifferenceImageResults.getNumberOfCadencesOutOfTransit())
                .numberOfCadenceGapsOutOfTransit(
                    srcDifferenceImageResults.getNumberOfCadenceGapsOutOfTransit())
                .qualityMetric(
                    createQualityMetric(srcDifferenceImageResults.getQualityMetric()))
                .overlappedTransits(
                    srcDifferenceImageResults.isOverlappedTransits())
                .differenceImagePixelData(
                    createDifferenceImagePixelData(srcDifferenceImageResults.getDifferenceImagePixelData()))
                .build();
            destDifferenceImageResultsList.add(destDifferenceImageResults);
        }

        return destDifferenceImageResultsList;
    }

    private gov.nasa.kepler.hibernate.dv.DvQualityMetric createQualityMetric(
        gov.nasa.kepler.dv.io.DvQualityMetric qualityMetric) {

        return new gov.nasa.kepler.hibernate.dv.DvQualityMetric(
            qualityMetric.isAttempted(), qualityMetric.isValid(),
            qualityMetric.getValue());
    }

    public static gov.nasa.kepler.hibernate.dv.DvCentroidOffsets createCentroidOffsets(
        gov.nasa.kepler.dv.io.DvCentroidOffsets srcCentroidOffsets) {

        gov.nasa.kepler.hibernate.dv.DvQuantity columnOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getColumnOffset()
                .getValue(), srcCentroidOffsets.getColumnOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity decOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getDecOffset()
                .getValue(), srcCentroidOffsets.getDecOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity focalPlaneOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getFocalPlaneOffset()
                .getValue(), srcCentroidOffsets.getFocalPlaneOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity raOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getRaOffset()
                .getValue(), srcCentroidOffsets.getRaOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity rowOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getRowOffset()
                .getValue(), srcCentroidOffsets.getRowOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity skyOffset = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcCentroidOffsets.getSkyOffset()
                .getValue(), srcCentroidOffsets.getSkyOffset()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvCentroidOffsets centroidOffsets = new gov.nasa.kepler.hibernate.dv.DvCentroidOffsets(
            columnOffset, decOffset, focalPlaneOffset, raOffset, rowOffset,
            skyOffset);

        return centroidOffsets;
    }

    public static gov.nasa.kepler.hibernate.dv.DvImageCentroid createImageCentroid(
        gov.nasa.kepler.dv.io.DvImageCentroid srcImageCentroid) {

        gov.nasa.kepler.hibernate.dv.DvQuantity column = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcImageCentroid.getColumn()
                .getValue(), srcImageCentroid.getColumn()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity decDegrees = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            srcImageCentroid.getDecDegrees()
                .getValue(), srcImageCentroid.getDecDegrees()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvDoubleQuantity raHours = new gov.nasa.kepler.hibernate.dv.DvDoubleQuantity(
            srcImageCentroid.getRaHours()
                .getValue(), srcImageCentroid.getRaHours()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity row = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            srcImageCentroid.getRow()
                .getValue(), srcImageCentroid.getRow()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvImageCentroid imageCentroid = new gov.nasa.kepler.hibernate.dv.DvImageCentroid(
            column, decDegrees, raHours, row);

        return imageCentroid;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData> createDifferenceImagePixelData(
        List<DvDifferenceImagePixelData> srcDifferenceImagePixelDataList) {

        List<gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData> destDifferenceImagePixelDataList = new ArrayList<gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData>(
            srcDifferenceImagePixelDataList.size());

        for (DvDifferenceImagePixelData srcDifferenceImagePixelData : srcDifferenceImagePixelDataList) {

            DvQuantity quantity = srcDifferenceImagePixelData.getMeanFluxInTransit();
            gov.nasa.kepler.hibernate.dv.DvQuantity meanFluxInTransit = new gov.nasa.kepler.hibernate.dv.DvQuantity(
                quantity.getValue(), quantity.getUncertainty());

            quantity = srcDifferenceImagePixelData.getMeanFluxOutOfTransit();
            gov.nasa.kepler.hibernate.dv.DvQuantity meanFluxOutOfTransit = new gov.nasa.kepler.hibernate.dv.DvQuantity(
                quantity.getValue(), quantity.getUncertainty());

            quantity = srcDifferenceImagePixelData.getMeanFluxDifference();
            gov.nasa.kepler.hibernate.dv.DvQuantity meanFluxDifference = new gov.nasa.kepler.hibernate.dv.DvQuantity(
                quantity.getValue(), quantity.getUncertainty());

            quantity = srcDifferenceImagePixelData.getMeanFluxForTargetTable();
            gov.nasa.kepler.hibernate.dv.DvQuantity meanFluxForTargetTable = new gov.nasa.kepler.hibernate.dv.DvQuantity(
                quantity.getValue(), quantity.getUncertainty());

            gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData destDifferenceImagePixelData = new gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData(
                srcDifferenceImagePixelData.getCcdRow(),
                srcDifferenceImagePixelData.getCcdColumn(), meanFluxInTransit,
                meanFluxOutOfTransit, meanFluxDifference,
                meanFluxForTargetTable);

            destDifferenceImagePixelDataList.add(destDifferenceImagePixelData);
        }

        return destDifferenceImagePixelDataList;
    }

    private DvGhostDiagnosticResults createGhostDiagnosticResults(
        gov.nasa.kepler.dv.io.DvGhostDiagnosticResults ghostDiagnosticResults) {

        DvStatistic statistic = ghostDiagnosticResults.getCoreApertureCorrelationStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic coreApertureCorrelationStatistic = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());
        statistic = ghostDiagnosticResults.getHaloApertureCorrelationStatistic();
        gov.nasa.kepler.hibernate.dv.DvStatistic haloApertureCorrelationStatistic = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            statistic.getValue(), statistic.getSignificance());

        return new gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults(
            coreApertureCorrelationStatistic, haloApertureCorrelationStatistic);
    }

    private List<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults> createPixelCorrelationResults(
        int keplerId,
        List<DvPixelCorrelationResults> dvPixelCorrelationResultsList) {

        List<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults> pixelCorrelationResultsList = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults>();
        for (DvPixelCorrelationResults dvPixelCorrelationResults : dvPixelCorrelationResultsList) {
            List<gov.nasa.kepler.hibernate.dv.DvPixelStatistic> pixelCorrelationStatistics = createPixelCorrelationStatistics(dvPixelCorrelationResults.getPixelCorrelationStatistics());
            gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults pixelCorrelationResults = new gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults.Builder(
                dvPixelCorrelationResults.getTargetTableId()).ccdModule(
                dvPixelCorrelationResults.getCcdModule())
                .ccdOutput(dvPixelCorrelationResults.getCcdOutput())
                .endCadence(dvPixelCorrelationResults.getEndCadence())
                .quarter(dvPixelCorrelationResults.getQuarter())
                .startCadence(dvPixelCorrelationResults.getStartCadence())
                .controlCentroidOffsets(
                    createCentroidOffsets(dvPixelCorrelationResults.getControlCentroidOffsets()))
                .controlImageCentroid(
                    createImageCentroid(dvPixelCorrelationResults.getControlImageCentroid()))
                .correlationImageCentroid(
                    createImageCentroid(dvPixelCorrelationResults.getCorrelationImageCentroid()))
                .kicCentroidOffsets(
                    createCentroidOffsets(dvPixelCorrelationResults.getKicCentroidOffsets()))
                .kicReferenceCentroid(
                    createImageCentroid(dvPixelCorrelationResults.getKicReferenceCentroid()))
                .pixelCorrelationStatistics(pixelCorrelationStatistics)
                .build();
            pixelCorrelationResultsList.add(pixelCorrelationResults);
        }

        return pixelCorrelationResultsList;
    }

    private List<gov.nasa.kepler.hibernate.dv.DvPixelStatistic> createPixelCorrelationStatistics(
        List<DvPixelStatistic> dvPixelCorrelationStatistics) {

        List<gov.nasa.kepler.hibernate.dv.DvPixelStatistic> pixelCorrelationStatistics = new ArrayList<gov.nasa.kepler.hibernate.dv.DvPixelStatistic>();
        for (DvPixelStatistic dvPixelStatistic : dvPixelCorrelationStatistics) {
            pixelCorrelationStatistics.add(new gov.nasa.kepler.hibernate.dv.DvPixelStatistic(
                dvPixelStatistic.getCcdRow(), dvPixelStatistic.getCcdColumn(),
                dvPixelStatistic.getValue(), dvPixelStatistic.getSignificance()));
        }

        return pixelCorrelationStatistics;
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetCandidate createPlanetCandidate(
        int keplerId, int planetNumber, DvPlanetCandidate planetCandidate) {

        checkNotNull(planetCandidate, "planetCandidate can't be null");

        DvBootstrapHistogram srcBootstrapHistogram = planetCandidate.getBootstrapHistogram();
        List<Float> statistics = new ArrayList<Float>(
            srcBootstrapHistogram.getStatistics().length);
        for (float value : srcBootstrapHistogram.getStatistics()) {
            statistics.add(value);
        }

        List<Float> probabilities = new ArrayList<Float>(
            srcBootstrapHistogram.getProbabilities().length);
        for (float value : srcBootstrapHistogram.getProbabilities()) {
            probabilities.add(value);
        }

        int finalSkipCount = srcBootstrapHistogram.getFinalSkipCount();

        gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram bootstrapHistogram = new gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram(
            statistics, probabilities, finalSkipCount);

        // Note that the mes and phaseInDays fields should not be persisted, as
        // that has already been done by TPS.
        WeakSecondary srcWeakSecondary = planetCandidate.getWeakSecondary();
        gov.nasa.kepler.hibernate.dv.DvWeakSecondary weakSecondary = new gov.nasa.kepler.hibernate.dv.DvWeakSecondary(
            srcWeakSecondary.maxMesPhaseInDays(), srcWeakSecondary.maxMes(),
            srcWeakSecondary.minMesPhaseInDays(), srcWeakSecondary.minMes(),
            srcWeakSecondary.mesMad(), srcWeakSecondary.depthPpm(),
            srcWeakSecondary.depthUncert(), srcWeakSecondary.medianMes(),
            srcWeakSecondary.nValidPhases(), srcWeakSecondary.robustStatistic());

        return new gov.nasa.kepler.hibernate.dv.DvPlanetCandidate.Builder(
            keplerId, pipelineTask).bootstrapHistogram(bootstrapHistogram)
            .bootstrapMesMean(planetCandidate.getBoostrapMesMean())
            .bootstrapMesStd(planetCandidate.getBootstrapMesStd())
            .bootstrapThresholdForDesiredPfa(
                planetCandidate.getBootstrapThresholdForDesiredPfa())
            .chiSquare1(planetCandidate.getChiSquare1())
            .chiSquare2(planetCandidate.getChiSquare2())
            .chiSquareDof1(planetCandidate.getChiSquareDof1())
            .chiSquareDof2(planetCandidate.getChiSquareDof2())
            .chiSquareGof(planetCandidate.getChiSquareGof())
            .chiSquareGofDof(planetCandidate.getChiSquareGofDof())
            .epochMjd(planetCandidate.getEpochMjd())
            .expectedTransitCount(planetCandidate.getExpectedTransitCount())
            .maxMultipleEventSigma(planetCandidate.getMaxMultipleEventSigma())
            .maxSesInMes(planetCandidate.getMaxSesInMes())
            .maxSingleEventSigma(planetCandidate.getMaxSingleEventSigma())
            .modelChiSquare2(planetCandidate.getModelChiSquare2())
            .modelChiSquareDof2(planetCandidate.getModelChiSquareDof2())
            .modelChiSquareGof(planetCandidate.getModelChiSquareGof())
            .modelChiSquareGofDof(planetCandidate.getModelChiSquareGofDof())
            .observedTransitCount(planetCandidate.getObservedTransitCount())
            .orbitalPeriod(planetCandidate.getOrbitalPeriod())
            .planetNumber(planetNumber)
            .robustStatistic(planetCandidate.getRobustStatistic())
            .significance(planetCandidate.getSignificance())
            .statisticRatioBelowThreshold(
                planetCandidate.isStatisticRatioBelowThreshold())
            .suspectedEclipsingBinary(
                planetCandidate.isSuspectedEclipsingBinary())
            .thresholdForDesiredPfa(planetCandidate.getThresholdForDesiredPfa())
            .trialTransitPulseDuration(
                planetCandidate.getTrialTransitPulseDuration())
            .weakSecondary(weakSecondary)
            .build();
    }

    private List<TimeSeries> createResidualFluxTimeSeries(int keplerId,
        CorrectedFluxTimeSeries residualFluxTimeSeries) {

        FsId valuesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(fluxType,
            DvTimeSeriesType.FLUX, pipelineInstance.getId(), keplerId);
        FsId uncertaintiesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            fluxType, DvTimeSeriesType.UNCERTAINTIES, pipelineInstance.getId(),
            keplerId);
        FsId filledIndicesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            fluxType, DvTimeSeriesType.FILLED_INDICES,
            pipelineInstance.getId(), keplerId);

        return residualFluxTimeSeries.toTimeSeries(valuesFsId,
            uncertaintiesFsId, filledIndicesFsId, startCadence, endCadence,
            pipelineTask.getId());
    }

    private List<TimeSeries> createSingleEventStatisticsTimeSeries(
        int keplerId, List<DvSingleEventStatistics> singleEventStatisticsList) {

        List<TimeSeries> timeSeries = new ArrayList<TimeSeries>();

        for (DvSingleEventStatistics singleEventStatistics : singleEventStatisticsList) {

            FsId fsId = DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
                DvSingleEventStatisticsType.NORMALIZATION,
                pipelineInstance.getId(), keplerId,
                singleEventStatistics.getTrialTransitPulseDuration());
            timeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
                singleEventStatistics.getNormalizationTimeSeries(), fsId,
                startCadence, endCadence, pipelineTask.getId()));

            fsId = DvFsIdFactory.getSingleEventStatisticsFsId(fluxType,
                DvSingleEventStatisticsType.CORRELATION,
                pipelineInstance.getId(), keplerId,
                singleEventStatistics.getTrialTransitPulseDuration());
            timeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
                singleEventStatistics.getCorrelationTimeSeries(), fsId,
                startCadence, endCadence, pipelineTask.getId()));
        }

        return timeSeries;
    }

    private TimeSeries createBarycentricCorrectedTimestampsTimeSeries(
        int keplerId, double[] barycentricCorrectedTimestamps) {

        FsId fsId = DvFsIdFactory.getBarycentricCorrectedTimestampsFsId(
            fluxType, pipelineInstance.getId(), keplerId);
        return new DoubleTimeSeries(fsId, barycentricCorrectedTimestamps,
            startCadence, endCadence,
            new boolean[barycentricCorrectedTimestamps.length],
            pipelineTask.getId());
    }

    private gov.nasa.kepler.hibernate.dv.DvSecondaryEventResults createSecondaryEventResults(
        gov.nasa.kepler.dv.io.DvSecondaryEventResults secondaryEventResults) {

        return new gov.nasa.kepler.hibernate.dv.DvSecondaryEventResults(
            createPlanetParameters(secondaryEventResults.getPlanetParameters()),
            createComparisonTests(secondaryEventResults.getComparisonTests()));
    }

    private gov.nasa.kepler.hibernate.dv.DvPlanetParameters createPlanetParameters(
        DvPlanetParameters planetParameters) {

        gov.nasa.kepler.hibernate.dv.DvQuantity geometricAlbedo = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            planetParameters.getGeometricAlbedo()
                .getValue(), planetParameters.getGeometricAlbedo()
                .getUncertainty());
        gov.nasa.kepler.hibernate.dv.DvQuantity planetEffectiveTemp = new gov.nasa.kepler.hibernate.dv.DvQuantity(
            planetParameters.getPlanetEffectiveTemp()
                .getValue(), planetParameters.getPlanetEffectiveTemp()
                .getUncertainty());
        return new gov.nasa.kepler.hibernate.dv.DvPlanetParameters(
            geometricAlbedo, planetEffectiveTemp);
    }

    private gov.nasa.kepler.hibernate.dv.DvComparisonTests createComparisonTests(
        DvComparisonTests comparisonTests) {

        gov.nasa.kepler.hibernate.dv.DvStatistic albedoComparisonStatistic = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            comparisonTests.getAlbedoComparisonStatistic()
                .getValue(), comparisonTests.getAlbedoComparisonStatistic()
                .getSignificance());
        gov.nasa.kepler.hibernate.dv.DvStatistic tempComparisonStatistic = new gov.nasa.kepler.hibernate.dv.DvStatistic(
            comparisonTests.getTempComparisonStatistic()
                .getValue(), comparisonTests.getTempComparisonStatistic()
                .getSignificance());
        return new gov.nasa.kepler.hibernate.dv.DvComparisonTests(
            albedoComparisonStatistic, tempComparisonStatistic);
    }

    private gov.nasa.kepler.hibernate.dv.DvImageArtifactResults createImageArtifactResults(
        gov.nasa.kepler.dv.io.DvImageArtifactResults imageArtifactResults) {

        return new gov.nasa.kepler.hibernate.dv.DvImageArtifactResults(
            createRollingBandContaminationHistogram(imageArtifactResults.getRollingBandContaminationHistogram()));
    }

    /**
     * Factory to return a Hibernate Rolling-Band Contamination object given a
     * corresponding DV object.
     */
    private gov.nasa.kepler.hibernate.dv.DvRollingBandContaminationHistogram createRollingBandContaminationHistogram(
        DvRollingBandContaminationHistogram rollingBandContaminationHistogram) {

        int testPulseDurationLc = rollingBandContaminationHistogram.getTestPulseDurationLc();
        List<Float> severityLevels = Arrays.asList(ArrayUtils.toObject(rollingBandContaminationHistogram.getSeverityLevels()));
        List<Integer> transitCounts = Arrays.asList(ArrayUtils.toObject(rollingBandContaminationHistogram.getTransitCounts()));
        List<Float> transitFractions = Arrays.asList(ArrayUtils.toObject(rollingBandContaminationHistogram.getTransitFractions()));

        return new gov.nasa.kepler.hibernate.dv.DvRollingBandContaminationHistogram(
            testPulseDurationLc, severityLevels, transitCounts, transitFractions);
    }

    protected File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    /**
     * Only used for testing.
     */
    protected void setMatlabWorkingDir(File workingDir) {
        matlabWorkingDir = workingDir;
    }

    /**
     * Only used for testing.
     */
    void setLogCrud(LogCrud logCrud) {
        this.logCrud = logCrud;
    }

    /**
     * Only used for testing.
     */
    void setAlertService(AlertService alertService) {
        this.alertService = alertService;
    }

    /**
     * Only used for testing.
     */
    void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    /**
     * Only used for testing.
     */
    void setDvCrud(DvCrud dvCrud) {
        this.dvCrud = dvCrud;
    }

    /**
     * Only used for testing.
     */
    void setGenericReportOperations(
        GenericReportOperations genericReportOperations) {
        this.genericReportOperations = genericReportOperations;
    }

    protected File getTaskWorkingDir() {
        return taskWorkingDir;
    }

    protected void setTaskWorkingDir(File taskWorkingDir) {
        this.taskWorkingDir = taskWorkingDir;
    }
}
