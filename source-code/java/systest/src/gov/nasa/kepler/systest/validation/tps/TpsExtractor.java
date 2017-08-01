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

package gov.nasa.kepler.systest.validation.tps;

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.systest.validation.PersistableVisitor;
import gov.nasa.kepler.systest.validation.TaskFileType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.kepler.tps.TpsOutputs;
import gov.nasa.kepler.tps.TpsPipelineModule;
import gov.nasa.kepler.tps.TpsResult;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;
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
public class TpsExtractor {

    private static final Log log = LogFactory.getLog(TpsExtractor.class);

    private long pipelineInstanceId;
    private File tasksRootDirectory;

    public TpsExtractor(long pipelineInstanceId, File tasksRootDirectory) {

        if (tasksRootDirectory == null) {
            throw new NullPointerException("tasksRootDirectory can't be null");
        }

        this.pipelineInstanceId = pipelineInstanceId;
        this.tasksRootDirectory = tasksRootDirectory;
    }

    private void process(PersistableVisitor visitor) {

        List<Pair<String, PipelineTask>> dirNamesAndTasks = ValidationUtils.taskDirNamesAndPipelineTasks(
            pipelineInstanceId, TpsPipelineModule.MODULE_NAME);

        for (Pair<String, PipelineTask> dirNameAndTask : dirNamesAndTasks) {
            File dir = new File(tasksRootDirectory, dirNameAndTask.left);
            if (!ValidationUtils.directoryReadable(dir, "TPS working directory")) {
                continue;
            }

            List<File> binFileList = ValidationUtils.getBinFiles(dir, "tps",
                TaskFileType.OUTPUTS);
            if (binFileList.size() == 0) {
                log.warn(dir.getPath() + ": no output .bin files");
                continue;
            }

            for (File binFile : binFileList) {
                if (!ValidationUtils.fileReadable(binFile, "TPS bin file")) {
                    throw new IllegalStateException("Can't read bin file "
                        + binFile);
                }

                TpsOutputs tpsOutputs = new TpsOutputs();
                PersistableUtils.readBinFile(tpsOutputs, binFile);

                visitor.visit(tpsOutputs);

                log.debug("Successfully processed " + binFile.getPath());
            }
        }
    }

    public void extractTpsResults(
        Map<Pair<Integer, Float>, TpsResult> tpsResultsByKeplerIdAndPulse,
        Map<Pair<Integer, Float>, SimpleFloatTimeSeries> cdppByKeplerIdAndPulse) {

        if (tpsResultsByKeplerIdAndPulse == null) {
            throw new NullPointerException(
                "tpsResultsByKeplerIdAndPulse can't be null");
        }
        if (cdppByKeplerIdAndPulse == null) {
            throw new NullPointerException(
                "cdppByKeplerIdAndPulse can't be null");
        }

        process(new TpsVisitor(tpsResultsByKeplerIdAndPulse,
            cdppByKeplerIdAndPulse));
    }

    private class TpsVisitor implements PersistableVisitor {

        private Map<Pair<Integer, Float>, TpsResult> tpsResultsByKeplerIdAndPulse;
        private Map<Pair<Integer, Float>, SimpleFloatTimeSeries> cdppByKeplerIdAndPulse;

        public TpsVisitor(
            Map<Pair<Integer, Float>, TpsResult> tpsResultsByKeplerIdAndPulse,
            Map<Pair<Integer, Float>, SimpleFloatTimeSeries> cdppByKeplerIdAndPulse) {

            this.tpsResultsByKeplerIdAndPulse = tpsResultsByKeplerIdAndPulse;
            this.cdppByKeplerIdAndPulse = cdppByKeplerIdAndPulse;
        }

        @Override
        public void visit(Persistable outputs) {
            TpsOutputs tpsOutputs = (TpsOutputs) outputs;

            for (TpsResult target : tpsOutputs.getTpsResults()) {
                tpsResultsByKeplerIdAndPulse.put(
                    Pair.of(target.getKeplerId(),
                        target.getTrialTransitPulseInHours()), target);
                cdppByKeplerIdAndPulse.put(
                    Pair.of(target.getKeplerId(),
                        target.getTrialTransitPulseInHours()),
                    cdppTimeSeries(target));
            }
        }

        private SimpleFloatTimeSeries cdppTimeSeries(TpsResult target) {
            float[] cdppTimeSeries = target.getCdppTimeSeries();
            boolean[] gapIndicators = new boolean[cdppTimeSeries.length];

            if (!target.isResultValid()) {
                for (int i = 0; i < cdppTimeSeries.length; i++) {
                    // Reproduce behavior of exporter so we can validate the
                    // exported values.
                    cdppTimeSeries[i] = Float.NaN;
                    gapIndicators[i] = true;
                }
            }

            return new SimpleFloatTimeSeries(cdppTimeSeries, gapIndicators);
        }
    }
}
