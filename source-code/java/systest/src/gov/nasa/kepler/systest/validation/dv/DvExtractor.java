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

package gov.nasa.kepler.systest.validation.dv;

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.DvPipelineModule;
import gov.nasa.kepler.dv.io.DvLimbDarkeningModel;
import gov.nasa.kepler.dv.io.DvOutputs;
import gov.nasa.kepler.dv.io.DvPlanetCandidate;
import gov.nasa.kepler.dv.io.DvPlanetResults;
import gov.nasa.kepler.dv.io.DvSingleEventStatistics;
import gov.nasa.kepler.dv.io.DvTargetResults;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.systest.validation.PersistableVisitor;
import gov.nasa.kepler.systest.validation.TaskFileType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts the residual and initial flux time series from the DV outputs.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvExtractor {

    private static final Log log = LogFactory.getLog(DvExtractor.class);

    private long pipelineInstanceId;
    private File tasksRootDirectory;

    private File binFile;
    private PipelineTask pipelineTask;

    public DvExtractor(long pipelineInstanceId, File tasksRootDirectory) {

        if (tasksRootDirectory == null) {
            throw new NullPointerException("tasksRootDirectory can't be null");
        }

        this.pipelineInstanceId = pipelineInstanceId;
        this.tasksRootDirectory = tasksRootDirectory;
    }

    private void process(PersistableVisitor visitor) {

        List<Pair<String, PipelineTask>> dirNamesAndTasks = ValidationUtils.taskDirNamesAndPipelineTasks(
            pipelineInstanceId, DvPipelineModule.MODULE_NAME);

        for (Pair<String, PipelineTask> dirNameAndTask : dirNamesAndTasks) {
            File dir = new File(tasksRootDirectory, dirNameAndTask.left);
            if (!ValidationUtils.directoryReadable(dir, "DV working directory")) {
                continue;
            }

            List<File> binFileList = ValidationUtils.getBinFiles(dir, "dv",
                TaskFileType.OUTPUTS);
            if (binFileList.size() == 0) {
                log.warn(dir.getPath() + ": no outputs .bin files");
                continue;
            }

            pipelineTask = dirNameAndTask.right;

            for (File binFile : binFileList) {
                if (!ValidationUtils.fileReadable(binFile, "DV bin file")) {
                    continue;
                }

                DvOutputs dvOutputs = new DvOutputs();
                PersistableUtils.readBinFile(dvOutputs, binFile);

                this.binFile = binFile;
                visitor.visit(dvOutputs);

                log.debug("Successfully processed " + binFile.getPath());
            }
        }
    }

    public void extractTimeSeries(
        Map<Integer, Map<FsId, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId,
        Map<Integer, Map<FsId, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId) {

        if (simpleTimeSeriesByKeplerId == null) {
            throw new NullPointerException(
                "simpleTimeSeriesByKeplerId can't be null");
        }
        if (compoundTimeSeriesByKeplerId == null) {
            throw new NullPointerException(
                "compoundTimeSeriesByKeplerId can't be null");
        }

        process(new FluxVisitor(simpleTimeSeriesByKeplerId,
            compoundTimeSeriesByKeplerId));
    }

    public Map<Integer, Pair<PipelineTask, DvTargetResults>> extractTargetResults() {

        Map<Integer, Pair<PipelineTask, DvTargetResults>> targetResultsByKeplerId = new HashMap<Integer, Pair<PipelineTask, DvTargetResults>>();
        process(new TargetResultsVisitor(targetResultsByKeplerId));

        if (targetResultsByKeplerId.size() == 0) {
            log.warn("No target results found in dv task directories in "
                + tasksRootDirectory);
        }

        return targetResultsByKeplerId;
    }

    public Map<Pair<Integer, Integer>, Pair<PipelineTask, DvPlanetResults>> extractPlanetResults() {

        Map<Pair<Integer, Integer>, Pair<PipelineTask, DvPlanetResults>> planetResultsByKeplerIdAndPlanetNumber = new HashMap<Pair<Integer, Integer>, Pair<PipelineTask, DvPlanetResults>>();
        process(new PlanetResultsVisitor(planetResultsByKeplerIdAndPlanetNumber));

        if (planetResultsByKeplerIdAndPlanetNumber.size() == 0) {
            log.warn("No planet results found in dv task directories in "
                + tasksRootDirectory);
        }

        return planetResultsByKeplerIdAndPlanetNumber;
    }

    public Map<Pair<Integer, Integer>, Pair<PipelineTask, DvLimbDarkeningModel>> extractLimbDarkeningModels() {

        Map<Pair<Integer, Integer>, Pair<PipelineTask, DvLimbDarkeningModel>> limbDarkeningModelByKeplerIdAndTargetTableId = new HashMap<Pair<Integer, Integer>, Pair<PipelineTask, DvLimbDarkeningModel>>();
        process(new LimbDarkeningModelsVisitor(
            limbDarkeningModelByKeplerIdAndTargetTableId));

        if (limbDarkeningModelByKeplerIdAndTargetTableId.size() == 0) {
            log.warn("No limb darkening models foudn in dv task directories in "
                + tasksRootDirectory);
        }
        return limbDarkeningModelByKeplerIdAndTargetTableId;
    }

    public List<File> extractReportFilenames() {

        List<File> pdfFiles = new ArrayList<File>();
        process(new ReportsVisitor(pdfFiles));

        if (pdfFiles.size() == 0) {
            log.warn("No PDF files found in dv task directories in "
                + tasksRootDirectory);
        }

        return pdfFiles;
    }

    public List<String> extractExternalTceModelDescriptions() {

        List<String> modelDescriptions = new ArrayList<String>();
        process(new ExternalTceModelDescriptionVisitor(modelDescriptions));

        return modelDescriptions;
    }

    public List<String> extractTransitNameModelDescription() {

        List<String> modelDescriptions = new ArrayList<String>();
        process(new TransitNameModelDescriptionVisitor(modelDescriptions));

        return modelDescriptions;
    }

    public List<String> extractTransitParameterModelDescription() {

        List<String> modelDescriptions = new ArrayList<String>();
        process(new TransitParameterModelDescriptionVisitor(modelDescriptions));

        return modelDescriptions;
    }

    private static class FluxVisitor implements PersistableVisitor {

        private Map<Integer, Map<FsId, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId;
        private Map<Integer, Map<FsId, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId;

        public FluxVisitor(
            Map<Integer, Map<FsId, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId,
            Map<Integer, Map<FsId, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId) {

            this.simpleTimeSeriesByKeplerId = simpleTimeSeriesByKeplerId;
            this.compoundTimeSeriesByKeplerId = compoundTimeSeriesByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            for (DvTargetResults target : dvOutputs.getTargetResults()) {
                Map<FsId, CompoundFloatTimeSeries> compoundTimeSeriesByFsId = compoundTimeSeriesByKeplerId.get(target.getKeplerId());
                if (compoundTimeSeriesByFsId == null) {
                    compoundTimeSeriesByFsId = new HashMap<FsId, CompoundFloatTimeSeries>();
                    compoundTimeSeriesByKeplerId.put(target.getKeplerId(),
                        compoundTimeSeriesByFsId);
                }

                for (DvPlanetResults planetResults : target.getPlanetResults()) {
                    DvPlanetCandidate planetCandidate = planetResults.getPlanetCandidate();
                    CompoundFloatTimeSeries initialFlux = ValidationUtils.convertCorrectedTimeSeries(
                        planetCandidate.getInitialFluxTimeSeries(),
                        new OutliersTimeSeries());
                    compoundTimeSeriesByFsId.put(
                        DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
                            FluxType.SAP, DvCorrectedFluxType.INITIAL,
                            DvTimeSeriesType.FLUX, 0L, target.getKeplerId(),
                            planetResults.getPlanetNumber()), initialFlux);
                }

                CompoundFloatTimeSeries residualFlux = ValidationUtils.convertCorrectedTimeSeries(
                    target.getResidualFluxTimeSeries(),
                    new OutliersTimeSeries());
                compoundTimeSeriesByFsId.put(
                    DvFsIdFactory.getResidualTimeSeriesFsId(FluxType.SAP,
                        DvTimeSeriesType.FLUX, 0L, target.getKeplerId()),
                    residualFlux);

                Map<FsId, SimpleFloatTimeSeries> simpleTimeSeriesByFsId = simpleTimeSeriesByKeplerId.get(target.getKeplerId());
                if (simpleTimeSeriesByFsId == null) {
                    simpleTimeSeriesByFsId = new HashMap<FsId, SimpleFloatTimeSeries>();
                    simpleTimeSeriesByKeplerId.put(target.getKeplerId(),
                        simpleTimeSeriesByFsId);
                }
                for (DvSingleEventStatistics singleEventStatistics : target.getSingleEventStatistics()) {
                    simpleTimeSeriesByFsId.put(
                        DvFsIdFactory.getSingleEventStatisticsFsId(
                            FluxType.SAP,
                            DvSingleEventStatisticsType.CORRELATION,
                            0L,
                            target.getKeplerId(),
                            singleEventStatistics.getTrialTransitPulseDuration()),
                        singleEventStatistics.getCorrelationTimeSeries());
                    simpleTimeSeriesByFsId.put(
                        DvFsIdFactory.getSingleEventStatisticsFsId(
                            FluxType.SAP,
                            DvSingleEventStatisticsType.NORMALIZATION,
                            0L,
                            target.getKeplerId(),
                            singleEventStatistics.getTrialTransitPulseDuration()),
                        singleEventStatistics.getNormalizationTimeSeries());
                }
            }
        }
    }

    private class TargetResultsVisitor implements PersistableVisitor {

        private Map<Integer, Pair<PipelineTask, DvTargetResults>> targetResultsByKeplerId;

        public TargetResultsVisitor(
            Map<Integer, Pair<PipelineTask, DvTargetResults>> targetResultsByKeplerId) {
            this.targetResultsByKeplerId = targetResultsByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            for (DvTargetResults target : dvOutputs.getTargetResults()) {
                targetResultsByKeplerId.put(target.getKeplerId(),
                    Pair.of(pipelineTask, target));
            }
        }
    }

    private class PlanetResultsVisitor implements PersistableVisitor {

        private Map<Pair<Integer, Integer>, Pair<PipelineTask, DvPlanetResults>> planetResultsByKeplerIdAndPlanetNumber;

        public PlanetResultsVisitor(
            Map<Pair<Integer, Integer>, Pair<PipelineTask, DvPlanetResults>> planetResultsByKeplerIdAndPlanetNumber) {
            this.planetResultsByKeplerIdAndPlanetNumber = planetResultsByKeplerIdAndPlanetNumber;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            for (DvTargetResults target : dvOutputs.getTargetResults()) {
                for (DvPlanetResults planetResults : target.getPlanetResults()) {
                    planetResultsByKeplerIdAndPlanetNumber.put(
                        Pair.of(planetResults.getKeplerId(),
                            planetResults.getPlanetNumber()),
                        Pair.of(pipelineTask, planetResults));
                }
            }
        }
    }

    private class LimbDarkeningModelsVisitor implements PersistableVisitor {

        private Map<Pair<Integer, Integer>, Pair<PipelineTask, DvLimbDarkeningModel>> limbDarkeningModelByKeplerIdAndTargetTableId;

        public LimbDarkeningModelsVisitor(
            Map<Pair<Integer, Integer>, Pair<PipelineTask, DvLimbDarkeningModel>> limbDarkeningModelByKeplerIdAndTargetTableId) {
            this.limbDarkeningModelByKeplerIdAndTargetTableId = limbDarkeningModelByKeplerIdAndTargetTableId;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            for (DvTargetResults target : dvOutputs.getTargetResults()) {
                for (DvLimbDarkeningModel limbDarkeningModel : target.getLimbDarkeningModels()) {
                    limbDarkeningModelByKeplerIdAndTargetTableId.put(Pair.of(
                        limbDarkeningModel.getKeplerId(),
                        limbDarkeningModel.getTargetTableId()), Pair.of(
                        pipelineTask, limbDarkeningModel));
                }
            }
        }
    }

    private class ReportsVisitor implements PersistableVisitor {

        private List<File> pdfFiles;

        public ReportsVisitor(List<File> pdfFiles) {
            this.pdfFiles = pdfFiles;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            for (DvTargetResults target : dvOutputs.getTargetResults()) {
                pdfFiles.add(new File(binFile.getParentFile(),
                    target.getReportFilename()));
            }
        }
    }

    private class ExternalTceModelDescriptionVisitor implements
        PersistableVisitor {

        private List<String> descriptions;

        public ExternalTceModelDescriptionVisitor(List<String> descriptions) {
            this.descriptions = descriptions;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            descriptions.add(dvOutputs.getExternalTceModelDescription());
        }
    }

    private class TransitNameModelDescriptionVisitor implements
        PersistableVisitor {

        private List<String> descriptions;

        public TransitNameModelDescriptionVisitor(List<String> descriptions) {
            this.descriptions = descriptions;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            descriptions.add(dvOutputs.getTransitNameModelDescription());
        }
    }

    private class TransitParameterModelDescriptionVisitor implements
        PersistableVisitor {

        private List<String> descriptions;

        public TransitParameterModelDescriptionVisitor(List<String> descriptions) {
            this.descriptions = descriptions;
        }

        @Override
        public void visit(Persistable outputs) {
            DvOutputs dvOutputs = (DvOutputs) outputs;

            descriptions.add(dvOutputs.getTransitParameterModelDescription());
        }
    }
}
