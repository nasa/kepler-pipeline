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

package gov.nasa.kepler.systest.validation;

import gov.nasa.kepler.ar.archive.ArchiveOutputs;
import gov.nasa.kepler.ar.archive.BackgroundPixelValue;
import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.mc.uow.ObservedKeplerIdUowTask;
import gov.nasa.kepler.systest.validation.pixels.TargetPixelCompoundTimeSeriesType;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.ArrayUtils;
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
 * Extracts and massages AR data from MATLAB .bin files.
 * 
 * @author Forrest Girouard
 */
public class ArExtractor {

    private static final Log log = LogFactory.getLog(ArExtractor.class);

    private long pipelineInstanceId;
    private int ccdModule;
    private int ccdOutput;
    private File tasksRootDirectory;
    private String moduleDefinitionName;

    public ArExtractor(long pipelineInstanceId, int ccdModule, int ccdOutput,
        File tasksRootDirectory, String moduleDefinitionName) {

        if (tasksRootDirectory == null) {
            throw new NullPointerException("tasksRootDirectory can't be null");
        }

        this.pipelineInstanceId = pipelineInstanceId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.tasksRootDirectory = tasksRootDirectory;
        this.moduleDefinitionName = moduleDefinitionName;
    }

    private void process(PersistableVisitor visitor) {
        List<String> dirNames = taskDirNames(pipelineInstanceId, "ar",
            moduleDefinitionName, ccdModule, ccdOutput);

        for (String dirName : dirNames) {
            File dir = new File(tasksRootDirectory, dirName);
            if (!ValidationUtils.directoryReadable(dir, "AR working directory")) {
                continue;
            }

            File[] binFiles = dir.listFiles(new ValidationUtils.BinFilenameFilter(
                "ar", TaskFileType.OUTPUTS));
            if (binFiles.length == 0) {
                log.warn(String.format("%s: no %s .bin files", dir.getPath(),
                    TaskFileType.OUTPUTS.toString()
                        .toLowerCase()));
                continue;
            }

            for (File binFile : binFiles) {
                if (!ValidationUtils.fileReadable(binFile, "AR bin file")) {
                    continue;
                }

                ArchiveOutputs archiveOutputs = new ArchiveOutputs();
                PersistableUtils.readBinFile(archiveOutputs, binFile);

                visitor.visit(archiveOutputs);

                log.debug("Successfully processed " + binFile.getPath());
            }
        }
    }

    public void extractTimeSeries(
        Map<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>> timeSeriesByPixel) {

        if (timeSeriesByPixel == null) {
            throw new NullPointerException("timeSeriesByPixel can't be null");
        }

        process(new BackgroundFluxVisitor(timeSeriesByPixel));
    }

    public void extractDvaMotion(
        Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> timeSeriesByKeplerId) {

        if (timeSeriesByKeplerId == null) {
            throw new NullPointerException("timeSeriesByKeplerId can't be null");
        }

        process(new DvaMotionVisitor(timeSeriesByKeplerId));
    }

    public void extractTimeCorrection(
        Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> timeSeriesMapByKeplerId) {

        if (timeSeriesMapByKeplerId == null) {
            throw new NullPointerException(
                "timeSeriesMapByKeplerId can't be null");
        }

        process(new BarycentricCorrectionVisitor(timeSeriesMapByKeplerId));
    }

    private static class BackgroundFluxVisitor implements PersistableVisitor {

        private Map<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>> timeSeriesMapByPixel;

        public BackgroundFluxVisitor(
            Map<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>> timeSeriesMapByPixel) {

            this.timeSeriesMapByPixel = timeSeriesMapByPixel;
        }

        @Override
        public void visit(Persistable outputs) {
            ArchiveOutputs archiveOutputs = (ArchiveOutputs) outputs;

            for (BackgroundPixelValue backgroundPixelValue : archiveOutputs.getBackground()) {
                backgroundPixelValue.fillGaps(Float.NaN);
                Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries> timeSeriesByType = new HashMap<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>();
                timeSeriesByType.put(
                    TargetPixelCompoundTimeSeriesType.BACKGROUND_FLUX,
                    new CompoundDoubleTimeSeries(
                        backgroundPixelValue.getBackground(),
                        ArrayUtils.doubleToFloat(backgroundPixelValue.getBackgroundUncertainties()),
                        backgroundPixelValue.getBackgroundGaps()));
                timeSeriesMapByPixel.put(
                    new Pixel(backgroundPixelValue.getCcdRow(),
                        backgroundPixelValue.getCcdColumn()), timeSeriesByType);
            }
        }
    }

    private static class DvaMotionVisitor implements PersistableVisitor {

        Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> timeSeriesMapByKeplerId = new HashMap<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>>();

        public DvaMotionVisitor(
            Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> timeSeriesMapByKeplerId) {

            this.timeSeriesMapByKeplerId = timeSeriesMapByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            ArchiveOutputs archiveOutputs = (ArchiveOutputs) outputs;

            for (TargetDva target : archiveOutputs.targetsDva()
                .values()) {
                Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> timeSeriesByType = timeSeriesMapByKeplerId.get(target.getKeplerId());
                if (timeSeriesByType == null) {
                    timeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
                    timeSeriesMapByKeplerId.put(target.getKeplerId(),
                        timeSeriesByType);
                }
                timeSeriesByType.put(
                    SimpleTimeSeriesType.ROW_POSITION_CORRECTION,
                    new SimpleFloatTimeSeries(target.getRowDva(),
                        target.getRowGapIndicator()));
                timeSeriesByType.put(
                    SimpleTimeSeriesType.COLUMN_POSITION_CORRECTION,
                    new SimpleFloatTimeSeries(target.getColumnDva(),
                        target.getColumnGapIndicator()));
                timeSeriesMapByKeplerId.put(target.getKeplerId(),
                    timeSeriesByType);
            }
        }
    }

    private static class BarycentricCorrectionVisitor implements
        PersistableVisitor {

        Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> timeSeriesMapByKeplerId = new HashMap<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>>();

        public BarycentricCorrectionVisitor(
            Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> timeSeriesMapByKeplerId) {

            this.timeSeriesMapByKeplerId = timeSeriesMapByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            ArchiveOutputs archiveOutputs = (ArchiveOutputs) outputs;

            for (BarycentricCorrection barycentricCorrection : archiveOutputs.barycentricCorrectionToMap()
                .values()) {
                Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> timeSeriesByType = timeSeriesMapByKeplerId.get(barycentricCorrection.getKeplerId());
                if (timeSeriesByType == null) {
                    timeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
                    timeSeriesMapByKeplerId.put(
                        barycentricCorrection.getKeplerId(), timeSeriesByType);
                }
                timeSeriesByType.put(
                    SimpleTimeSeriesType.TIME_CORRECTION,
                    new SimpleFloatTimeSeries(
                        barycentricCorrection.getCorrectionSeries(),
                        barycentricCorrection.getGaps()));
            }
        }
    }

    private static List<String> taskDirNames(long pipelineInstanceId,
        String csci, String moduleDefinitionName, int ccdModule, int ccdOutput) {

        PipelineInstance pipelineInstance = new PipelineInstanceCrud().retrieve(pipelineInstanceId);
        if (pipelineInstance == null) {
            throw new IllegalArgumentException(
                "Can not find pipeline instance " + pipelineInstanceId);
        }

        List<PipelineTask> pipelineTasks = new PipelineTaskCrud().retrieveAll(
            pipelineInstance, State.COMPLETED);
        List<String> taskDirNames = new ArrayList<String>();

        for (PipelineTask pipelineTask : pipelineTasks) {
            if (!pipelineTask.getPipelineInstanceNode()
                .getPipelineModuleDefinition()
                .getName()
                .toString()
                .equals(moduleDefinitionName)) {
                continue;
            }
            int taskCcdModule = 0;
            int taskCcdOutput = 0;
            if (pipelineTask.uowTaskInstance() instanceof ObservedKeplerIdUowTask) {
                ObservedKeplerIdUowTask uowTask = pipelineTask.uowTaskInstance();
                taskCcdModule = uowTask.getCcdModule();
                taskCcdOutput = uowTask.getCcdOutput();
            } else if (pipelineTask.uowTaskInstance() instanceof ModOutUowTask) {
                ModOutUowTask uowTask = pipelineTask.uowTaskInstance();
                taskCcdModule = uowTask.getCcdModule();
                taskCcdOutput = uowTask.getCcdOutput();
            } else {
                throw new IllegalStateException("Unexpected UOW task: "
                    + pipelineTask.uowTaskInstance());
            }
            if (ccdModule != taskCcdModule || ccdOutput != taskCcdOutput) {
                continue;
            }
            String taskDirName = ValidationUtils.taskDirName(
                pipelineInstanceId, csci, pipelineTask);
            taskDirNames.add(taskDirName);
        }

        if (taskDirNames.size() == 0) {
            throw new IllegalArgumentException(String.format(
                "Can't find any pipeline tasks for module %s, "
                    + "module/output %d/%d, in pipeline instance %d",
                moduleDefinitionName, ccdModule, ccdOutput, pipelineInstanceId));
        }

        return taskDirNames;
    }
}
