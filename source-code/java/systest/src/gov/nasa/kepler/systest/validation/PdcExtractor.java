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

import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.pdc.PdcGoodnessMetric;
import gov.nasa.kepler.pdc.PdcOutputs;
import gov.nasa.kepler.pdc.PdcPipelineModule;
import gov.nasa.kepler.pdc.PdcTargetOutputData;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts and massages time series from MATLAB .bin files.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class PdcExtractor {

    private static final Log log = LogFactory.getLog(PdcExtractor.class);

    public enum PdcFlag {
        DISCONTINUITIES, OUTLIERS;
    }

    private long pipelineInstanceId;
    private int ccdModule;
    private int ccdOutput;
    private File tasksRootDirectory;

    public PdcExtractor(long pipelineInstanceId, int ccdModule, int ccdOutput,
        File tasksRootDirectory) {

        if (tasksRootDirectory == null) {
            throw new NullPointerException("tasksRootDirectory can't be null");
        }

        this.pipelineInstanceId = pipelineInstanceId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.tasksRootDirectory = tasksRootDirectory;
    }

    private void process(PersistableVisitor visitor) {
        List<String> dirNames = ValidationUtils.taskDirNames(
            pipelineInstanceId, PdcPipelineModule.MODULE_NAME, ccdModule,
            ccdOutput);

        for (String dirName : dirNames) {
            File dir = new File(tasksRootDirectory, dirName);
            if (!ValidationUtils.directoryReadable(dir, "PDC working directory")) {
                continue;
            }

            List<File> binFileList = ValidationUtils.getBinFiles(dir, "pdc",
                TaskFileType.OUTPUTS);
            for (File binFile : binFileList) {
                if (!ValidationUtils.fileReadable(binFile, "PDC bin file")) {
                    continue;
                }

                PdcOutputs pdcOutputs = new PdcOutputs();
                PersistableUtils.readBinFile(pdcOutputs, binFile);

                visitor.visit(pdcOutputs);

                log.debug("Successfully processed " + binFile.getPath());
            }
        }
    }

    public void extractTimeSeries(
        Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> timeSeriesMapByKeplerId) {

        if (timeSeriesMapByKeplerId == null) {
            throw new NullPointerException(
                "timeSeriesMapByKeplerId can't be null");
        }

        process(new FluxVisitor(timeSeriesMapByKeplerId));
    }

    public void extractDiscontinuityOutlier(int offset, int length,
        int keplerId, Map<PdcFlag, SimpleFloatTimeSeries> timeSeriesByType) {

        if (timeSeriesByType == null) {
            throw new NullPointerException("timeSeriesByType can't be null");
        }

        process(new DiscontinuityOutlierVisitor(offset, length, keplerId,
            timeSeriesByType));
    }

    public void extractProcessingCharacteristics(
        Map<Integer, PdcProcessingCharacteristics> processingCharacteristicsByKeplerId) {

        if (processingCharacteristicsByKeplerId == null) {
            throw new NullPointerException(
                "processingCharacteristicsByKeplerId can't be null");
        }

        process(new ProcessingCharacteristicsVisitor(
            processingCharacteristicsByKeplerId));
    }

    public void extractGoodnessMetric(
        Map<Integer, PdcGoodnessMetric> pdcGoodnessMetricByKeplerId) {

        if (pdcGoodnessMetricByKeplerId == null) {
            throw new NullPointerException(
                "pdcGoodnessMetricByKeplerId can't be null");
        }

        process(new GoodnessMetricVisitor(pdcGoodnessMetricByKeplerId));
    }

    private static class FluxVisitor implements PersistableVisitor {

        private Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> timeSeriesByKeplerId;

        public FluxVisitor(
            Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> timeSeriesByKeplerId) {

            this.timeSeriesByKeplerId = timeSeriesByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            PdcOutputs pdcOutputs = (PdcOutputs) outputs;

            for (PdcTargetOutputData target : pdcOutputs.getTargetResultsStruct()) {
                Map<CompoundTimeSeriesType, CompoundFloatTimeSeries> timeSeriesByType = timeSeriesByKeplerId.get(target.getKeplerId());
                if (timeSeriesByType == null) {
                    timeSeriesByType = new HashMap<CompoundTimeSeriesType, CompoundFloatTimeSeries>();
                    timeSeriesByKeplerId.put(target.getKeplerId(),
                        timeSeriesByType);
                }
                CompoundFloatTimeSeries correctedTimeSeries = ValidationUtils.convertCorrectedTimeSeries(
                    target.getCorrectedFluxTimeSeries(), target.getOutliers());
                timeSeriesByType.put(
                    CompoundTimeSeriesType.SAP_CORRECTED_FLUX,
                    ValidationUtils.mergeCompound(
                        timeSeriesByType.get(CompoundTimeSeriesType.SAP_CORRECTED_FLUX),
                        correctedTimeSeries));
            }
        }
    }

    private static class ProcessingCharacteristicsVisitor implements
        PersistableVisitor {

        private Map<Integer, PdcProcessingCharacteristics> processingCharacteristicsByKeplerId;

        public ProcessingCharacteristicsVisitor(
            Map<Integer, PdcProcessingCharacteristics> processingCharacteristicsByKeplerId) {

            this.processingCharacteristicsByKeplerId = processingCharacteristicsByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            PdcOutputs pdcOutputs = (PdcOutputs) outputs;

            for (PdcTargetOutputData target : pdcOutputs.getTargetResultsStruct()) {
                processingCharacteristicsByKeplerId.put(target.getKeplerId(),
                    target.getPdcProcessingCharacteristics());
            }
        }
    }

    private static class GoodnessMetricVisitor implements PersistableVisitor {

        private Map<Integer, PdcGoodnessMetric> goodnessMetricByKeplerId;

        public GoodnessMetricVisitor(
            Map<Integer, PdcGoodnessMetric> goodnessMetricByKeplerId) {

            this.goodnessMetricByKeplerId = goodnessMetricByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            PdcOutputs pdcOutputs = (PdcOutputs) outputs;

            for (PdcTargetOutputData target : pdcOutputs.getTargetResultsStruct()) {
                goodnessMetricByKeplerId.put(target.getKeplerId(),
                    target.getPdcGoodnessMetric());
            }
        }
    }

    private static class DiscontinuityOutlierVisitor implements
        PersistableVisitor {

        private Map<PdcFlag, SimpleFloatTimeSeries> timeSeriesByType;
        private int offset;
        private int length;
        private int keplerId;

        public DiscontinuityOutlierVisitor(int offset, int length,
            int keplerId, Map<PdcFlag, SimpleFloatTimeSeries> timeSeriesByType) {

            this.offset = offset;
            this.length = length;
            this.keplerId = keplerId;
            this.timeSeriesByType = timeSeriesByType;
        }

        @Override
        public void visit(Persistable outputs) {
            PdcOutputs pdcOutputs = (PdcOutputs) outputs;

            for (PdcTargetOutputData target : pdcOutputs.getTargetResultsStruct()) {
                if (target.getKeplerId() != keplerId) {
                    continue;
                }
                if (target.getDiscontinuityIndices() != null
                    && target.getDiscontinuityIndices().length > 0) {
                    timeSeriesByType.put(
                        PdcFlag.DISCONTINUITIES,
                        indicesToTimeSeries(offset, length,
                            target.getDiscontinuityIndices()));
                }
                if (target.getOutliers() != null && target.getOutliers()
                    .getIndices() != null && target.getOutliers()
                    .getIndices().length > 0) {
                    timeSeriesByType.put(
                        PdcFlag.OUTLIERS,
                        indicesToTimeSeries(offset, length,
                            target.getOutliers()
                                .getIndices()));
                }
                break;
            }
        }

        private SimpleFloatTimeSeries indicesToTimeSeries(int offset,
            int length, int[] indices) {

            float[] values = new float[length];
            boolean[] gaps = new boolean[length];
            Arrays.fill(gaps, true);
            for (int index : indices) {
                if (index < offset) {
                    continue;
                }
                if (index - offset >= length) {
                    break;
                }
                gaps[index - offset] = false;
            }

            return new SimpleFloatTimeSeries(values, gaps);
        }
    }
}
