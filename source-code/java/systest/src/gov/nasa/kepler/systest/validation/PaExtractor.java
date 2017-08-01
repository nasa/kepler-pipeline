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

import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.pa.PaCentroidPixel;
import gov.nasa.kepler.pa.PaFluxTarget;
import gov.nasa.kepler.pa.PaInputs;
import gov.nasa.kepler.pa.PaOutputs;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.pa.PaPixelCosmicRay;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts the flux and centroid time series from the PA outputs.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class PaExtractor {

    private static final Log log = LogFactory.getLog(PaExtractor.class);

    private static final String ARTIFACT_REMOVAL_LABEL = "ARTIFACT_REMOVAL";

    private long pipelineInstanceId;
    private int ccdModule;
    private int ccdOutput;
    private File tasksRootDirectory;

    private int startCadence = -1;
    private int endCadence = -1;

    private Map<File, Persistable> persistableCache = new HashMap<File, Persistable>();

    public PaExtractor(long pipelineInstanceId, int ccdModule, int ccdOutput,
        File tasksRootDirectory, boolean cacheEnabled) {

        if (tasksRootDirectory == null) {
            throw new NullPointerException("tasksRootDirectory can't be null");
        }

        this.pipelineInstanceId = pipelineInstanceId;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.tasksRootDirectory = tasksRootDirectory;
    }

    private void process(int cadence, TaskFileType type,
        PersistableVisitor visitor) {

        List<String> dirNames = ValidationUtils.taskDirNames(
            pipelineInstanceId, PaPipelineModule.MODULE_NAME, cadence,
            ccdModule, ccdOutput);

        for (String dirName : dirNames) {
            File dir = new File(tasksRootDirectory, dirName);
            if (!ValidationUtils.directoryReadable(dir, "PA working directory")) {
                continue;
            }
            File[] subTaskDirs = dir.listFiles(new ValidationUtils.StDirectoryFilter());
            if (subTaskDirs.length == 0) {
                File[] groupDirs = dir.listFiles(new ValidationUtils.GDirectoryFilter());
                List<File> subTaskDirsList = new ArrayList<File>();
                for (File groupDir : groupDirs) {
                    subTaskDirs = groupDir.listFiles(new ValidationUtils.StDirectoryFilter());
                    for (File subTaskDir : subTaskDirs) {
                        subTaskDirsList.add(subTaskDir);
                    }
                }
                subTaskDirs = subTaskDirsList.toArray(new File[subTaskDirsList.size()]);
            }
            for (File subTaskDir : subTaskDirs) {
                if (!ValidationUtils.directoryReadable(subTaskDir,
                    "PA subtask directory")) {
                    continue;
                }

                FilenameFilter filter = type == TaskFileType.INPUTS ? new BinInputFilter()
                    : new BinOutputFilter();
                File[] binFiles = subTaskDir.listFiles(filter);
                if (binFiles.length == 0) {
                    log.warn(subTaskDir.getPath() + ": no outputs .bin files");
                    continue;
                }

                for (File binFile : binFiles) {
                    if (!ValidationUtils.fileReadable(binFile, "PA bin file")) {
                        throw new IllegalStateException("Can't read bin file "
                            + binFile);
                    }

                    Persistable persistable = persistableCache != null ? persistableCache.get(binFile)
                        : null;
                    if (persistable == null) {
                        if (type == TaskFileType.INPUTS) {
                            persistable = new PaInputs();
                        } else {
                            persistable = new PaOutputs();
                        }
                        PersistableUtils.readBinFile(persistable, binFile);

                        if (persistableCache != null) {
                            persistableCache.put(binFile, persistable);
                        }
                    }

                    visitor.visit(persistable);

                    log.debug("Successfully processed " + binFile.getPath());
                }
            }
        }
    }

    public Pair<Integer, Integer> getCadenceRange() {
        return Pair.of(startCadence, endCadence);
    }

    public void setCadenceRange(PaOutputs paOutputs) {

        if (startCadence < 0 || paOutputs.getStartCadence() < startCadence) {
            startCadence = paOutputs.getStartCadence();
        }
        if (endCadence < 0 || paOutputs.getEndCadence() > endCadence) {
            endCadence = paOutputs.getEndCadence();
        }
    }

    public void extractTimeSeries(
        Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId,
        Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId,
        Map<Integer, Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>> doubleTimeSeriesByKeplerId) {

        process(ValidationUtils.ALL_CADENCES, TaskFileType.OUTPUTS,
            new FluxVisitor(simpleTimeSeriesByKeplerId,
                compoundTimeSeriesByKeplerId, doubleTimeSeriesByKeplerId));
    }

    public void extractCosmicRays(int cadence, double cadenceMjd,
        Map<Pair<Integer, Integer>, Float> taskTargetCosmicRaysByRowColumn,
        Map<Pair<Integer, Integer>, Float> taskBackgroundCosmicRaysByRowColumn) {

        if (taskTargetCosmicRaysByRowColumn == null) {
            throw new NullPointerException(
                "taskTargetCosmicRaysByRowColumn can't be null");
        }

        if (taskBackgroundCosmicRaysByRowColumn == null) {
            throw new NullPointerException(
                "taskBackgroundCosmicRaysByRowColumn can't be null");
        }

        process(cadence, TaskFileType.OUTPUTS, new CosmicRayVisitor(cadenceMjd,
            taskTargetCosmicRaysByRowColumn,
            taskBackgroundCosmicRaysByRowColumn));
    }

    public void extractCosmicRays(FitsAperture aperture,
        Map<Pair<Integer, Integer>, List<Double>> cosmicRaysByRowColumn) {

        if (cosmicRaysByRowColumn == null) {
            throw new NullPointerException(
                "cosmicRaysByRowColumn can't be null");
        }

        process(ValidationUtils.ALL_CADENCES, TaskFileType.OUTPUTS,
            new CosmicRayMjdVisitor(aperture, cosmicRaysByRowColumn));
    }

    public void extractArgabrighteningIndices(int offset,
        List<Integer> argabrighteningIndices) {

        if (argabrighteningIndices == null) {
            throw new NullPointerException(
                "argabrighteningIndices can't be null");
        }

        process(ValidationUtils.ALL_CADENCES, TaskFileType.OUTPUTS,
            new ArgabrighteningVisitor(offset, argabrighteningIndices));
    }

    public void extractReactionWheelZeroCrossingIndices(int offset,
        List<Integer> reactionWheelZeroCrossingIndices) {

        if (reactionWheelZeroCrossingIndices == null) {
            throw new NullPointerException(
                "reactionWheelZeroCrossingIndices can't be null");
        }

        process(ValidationUtils.ALL_CADENCES, TaskFileType.OUTPUTS,
            new ReactionWheelZeroCrossingVisitor(offset,
                reactionWheelZeroCrossingIndices));
    }

    public void extractPixelsInCentroidAperture(
        Map<Integer, Set<Pair<Integer, Integer>>> pixelsInPrfCentroidApertureByKeplerId,
        Map<Integer, Set<Pair<Integer, Integer>>> pixelsInFluxWeightedCentroidApertureByKeplerId) {

        if (pixelsInPrfCentroidApertureByKeplerId == null) {
            throw new NullPointerException(
                "pixelsInPrfCentroidApertureByKeplerId can't be null");
        }
        if (pixelsInFluxWeightedCentroidApertureByKeplerId == null) {
            throw new NullPointerException(
                "pixelsInFluxWeightedCentroidApertureByKeplerId can't be null");
        }

        process(ValidationUtils.ALL_CADENCES, TaskFileType.OUTPUTS,
            new PixelsInCentroidApertureVisitor(
                pixelsInPrfCentroidApertureByKeplerId,
                pixelsInFluxWeightedCentroidApertureByKeplerId));
    }

    public void extractArpTargetPixels(Set<Pixel> arpPixels) {
        if (arpPixels == null) {
            throw new NullPointerException("arpPixels can't be null");
        }

        process(ValidationUtils.ALL_CADENCES, TaskFileType.INPUTS,
            new ArpTargetVisitor(arpPixels));
    }

    private class FluxVisitor implements PersistableVisitor {

        private Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId;
        private Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId;
        private Map<Integer, Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>> doubleTimeSeriesByKeplerId;

        public FluxVisitor(
            Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId,
            Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId,
            Map<Integer, Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>> doubleTimeSeriesByKeplerId) {

            this.simpleTimeSeriesByKeplerId = simpleTimeSeriesByKeplerId;
            this.compoundTimeSeriesByKeplerId = compoundTimeSeriesByKeplerId;
            this.doubleTimeSeriesByKeplerId = doubleTimeSeriesByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            PaOutputs paOutputs = (PaOutputs) outputs;

            setCadenceRange(paOutputs);

            for (PaFluxTarget target : paOutputs.getFluxTargets()) {
                if (simpleTimeSeriesByKeplerId != null) {
                    Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> simpleTimeSeriesByType = simpleTimeSeriesByKeplerId.get(target.getKeplerId());
                    if (simpleTimeSeriesByType == null) {
                        simpleTimeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
                        simpleTimeSeriesByKeplerId.put(target.getKeplerId(),
                            simpleTimeSeriesByType);
                    }

                    simpleTimeSeriesByType.put(
                        SimpleTimeSeriesType.TIME_CORRECTION,
                        ValidationUtils.mergeSimple(
                            simpleTimeSeriesByType.get(SimpleTimeSeriesType.TIME_CORRECTION),
                            target.getBarycentricTimeOffset()));
                }

                if (compoundTimeSeriesByKeplerId != null) {
                    Map<CompoundTimeSeriesType, CompoundFloatTimeSeries> compoundTimeSeriesByType = compoundTimeSeriesByKeplerId.get(target.getKeplerId());
                    if (compoundTimeSeriesByType == null) {
                        compoundTimeSeriesByType = new HashMap<CompoundTimeSeriesType, CompoundFloatTimeSeries>();
                        compoundTimeSeriesByKeplerId.put(target.getKeplerId(),
                            compoundTimeSeriesByType);
                    }

                    compoundTimeSeriesByType.put(
                        CompoundTimeSeriesType.SAP_RAW_FLUX,
                        ValidationUtils.mergeCompound(
                            compoundTimeSeriesByType.get(CompoundTimeSeriesType.SAP_RAW_FLUX),
                            target.getFluxTimeSeries()));
                    compoundTimeSeriesByType.put(
                        CompoundTimeSeriesType.SAP_BACKGROUND,
                        ValidationUtils.mergeCompound(
                            compoundTimeSeriesByType.get(CompoundTimeSeriesType.SAP_BACKGROUND),
                            target.getBackgroundFluxTimeSeries()));
                }

                if (doubleTimeSeriesByKeplerId != null) {
                    Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries> doubleTimeSeriesByType = doubleTimeSeriesByKeplerId.get(target.getKeplerId());
                    if (doubleTimeSeriesByType == null) {
                        doubleTimeSeriesByType = new HashMap<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>();
                        doubleTimeSeriesByKeplerId.put(target.getKeplerId(),
                            doubleTimeSeriesByType);
                    }
                    doubleTimeSeriesByType.put(
                        CompoundDoubleTimeSeriesType.PSF_CENTROID_ROW,
                        ValidationUtils.mergeDouble(
                            doubleTimeSeriesByType.get(CompoundDoubleTimeSeriesType.PSF_CENTROID_ROW),
                            target.getPrfCentroids()
                                .getRowTimeSeries()));
                    doubleTimeSeriesByType.put(
                        CompoundDoubleTimeSeriesType.PSF_CENTROID_COL,
                        ValidationUtils.mergeDouble(
                            doubleTimeSeriesByType.get(CompoundDoubleTimeSeriesType.PSF_CENTROID_COL),
                            target.getPrfCentroids()
                                .getColumnTimeSeries()));
                    doubleTimeSeriesByType.put(
                        CompoundDoubleTimeSeriesType.CENTROID_ROW,
                        ValidationUtils.mergeDouble(
                            doubleTimeSeriesByType.get(CompoundDoubleTimeSeriesType.CENTROID_ROW),
                            target.getFluxWeightedCentroids()
                                .getRowTimeSeries()));
                    doubleTimeSeriesByType.put(
                        CompoundDoubleTimeSeriesType.CENTROID_COL,
                        ValidationUtils.mergeDouble(
                            doubleTimeSeriesByType.get(CompoundDoubleTimeSeriesType.CENTROID_COL),
                            target.getFluxWeightedCentroids()
                                .getColumnTimeSeries()));
                }
            }
        }
    }

    private static class CosmicRayVisitor implements PersistableVisitor {

        private Map<Pair<Integer, Integer>, Float> taskTargetCosmicRaysByRowColumn;
        private Map<Pair<Integer, Integer>, Float> taskBackgroundCosmicRaysByRowColumn;
        private double cadenceMjd;

        public CosmicRayVisitor(
            double cadenceMjd,
            Map<Pair<Integer, Integer>, Float> taskTargetCosmicRaysByRowColumn,
            Map<Pair<Integer, Integer>, Float> taskBackgroundCosmicRaysByRowColumn) {

            this.taskTargetCosmicRaysByRowColumn = taskTargetCosmicRaysByRowColumn;
            this.taskBackgroundCosmicRaysByRowColumn = taskBackgroundCosmicRaysByRowColumn;
            this.cadenceMjd = cadenceMjd;
        }

        @Override
        public void visit(Persistable outputs) {
            PaOutputs paOutputs = (PaOutputs) outputs;

            for (PaPixelCosmicRay cosmicRay : paOutputs.getBackgroundCosmicRayEvents()) {
                if (cosmicRay.getMjd() == cadenceMjd) {
                    taskBackgroundCosmicRaysByRowColumn.put(
                        Pair.of(cosmicRay.getCcdRow(), cosmicRay.getCcdColumn()),
                        cosmicRay.getDelta());
                }
            }

            for (PaPixelCosmicRay cosmicRay : paOutputs.getTargetStarCosmicRayEvents()) {
                if (cosmicRay.getMjd() == cadenceMjd) {
                    taskTargetCosmicRaysByRowColumn.put(
                        Pair.of(cosmicRay.getCcdRow(), cosmicRay.getCcdColumn()),
                        cosmicRay.getDelta());
                }
            }
        }
    }

    private static class CosmicRayMjdVisitor implements PersistableVisitor {

        private Map<Pair<Integer, Integer>, List<Double>> cosmicRaysByRowColumn;
        private FitsAperture aperture;

        public CosmicRayMjdVisitor(FitsAperture aperture,
            Map<Pair<Integer, Integer>, List<Double>> cosmicRaysByRowColumn) {

            this.cosmicRaysByRowColumn = cosmicRaysByRowColumn;
            this.aperture = aperture;
        }

        @Override
        public void visit(Persistable outputs) {
            PaOutputs paOutputs = (PaOutputs) outputs;

            Set<Pixel> optimalAperturePixels = new HashSet<Pixel>();
            for (AperturePixel pixel : aperture.getPixels()) {
                if (pixel.isInOptimalAperture()) {
                    optimalAperturePixels.add(new Pixel(pixel.getRow(),
                        pixel.getColumn(), true));
                }
            }

            for (PaPixelCosmicRay cosmicRay : paOutputs.getTargetStarCosmicRayEvents()) {
                Pixel pixel = new Pixel(cosmicRay.getCcdRow(),
                    cosmicRay.getCcdColumn());
                if (optimalAperturePixels.contains(pixel)) {
                    Pair<Integer, Integer> key = Pair.of(pixel.getRow(),
                        pixel.getColumn());
                    List<Double> cosmicRayMjds = cosmicRaysByRowColumn.get(key);
                    if (cosmicRayMjds == null) {
                        cosmicRayMjds = new ArrayList<Double>();
                        cosmicRaysByRowColumn.put(key, cosmicRayMjds);
                    }
                    cosmicRayMjds.add(cosmicRay.getMjd());
                }
            }
        }
    }

    private static class PixelsInCentroidApertureVisitor implements
        PersistableVisitor {

        private Map<Integer, Set<Pair<Integer, Integer>>> pixelsInPrfCentroidApertureByKeplerId;
        private Map<Integer, Set<Pair<Integer, Integer>>> pixelsInFluxWeightedCentroidApertureByKeplerId;

        public PixelsInCentroidApertureVisitor(
            Map<Integer, Set<Pair<Integer, Integer>>> pixelsInPrfCentroidApertureByKeplerId,
            Map<Integer, Set<Pair<Integer, Integer>>> pixelsInFluxWeightedCentroidApertureByKeplerId) {
            this.pixelsInPrfCentroidApertureByKeplerId = pixelsInPrfCentroidApertureByKeplerId;
            this.pixelsInFluxWeightedCentroidApertureByKeplerId = pixelsInFluxWeightedCentroidApertureByKeplerId;
        }

        @Override
        public void visit(Persistable outputs) {
            PaOutputs paOutputs = (PaOutputs) outputs;

            for (PaFluxTarget target : paOutputs.getFluxTargets()) {
                for (PaCentroidPixel pixel : target.getPixelAperture()) {
                    if (pixel.isInPrfCentroidAperture()) {
                        Set<Pair<Integer, Integer>> pixelsInPrfCentroidAperture = pixelsInPrfCentroidApertureByKeplerId.get(target.getKeplerId());
                        if (pixelsInPrfCentroidAperture == null) {
                            pixelsInPrfCentroidAperture = new HashSet<Pair<Integer, Integer>>();
                            pixelsInPrfCentroidApertureByKeplerId.put(
                                target.getKeplerId(),
                                pixelsInPrfCentroidAperture);
                        }
                        pixelsInPrfCentroidAperture.add(Pair.of(
                            pixel.getCcdRow(), pixel.getCcdColumn()));
                    }
                    if (pixel.isInFluxWeightedCentroidAperture()) {
                        Set<Pair<Integer, Integer>> pixelsInFluxWeightedCentroidAperture = pixelsInFluxWeightedCentroidApertureByKeplerId.get(target.getKeplerId());
                        if (pixelsInFluxWeightedCentroidAperture == null) {
                            pixelsInFluxWeightedCentroidAperture = new HashSet<Pair<Integer, Integer>>();
                            pixelsInFluxWeightedCentroidApertureByKeplerId.put(
                                target.getKeplerId(),
                                pixelsInFluxWeightedCentroidAperture);
                        }
                        pixelsInFluxWeightedCentroidAperture.add(Pair.of(
                            pixel.getCcdRow(), pixel.getCcdColumn()));
                    }
                }
            }
        }
    }

    private static class ArgabrighteningVisitor implements PersistableVisitor {

        private List<Integer> argabrighteningIndices;
        int offset;

        public ArgabrighteningVisitor(int offset,
            List<Integer> argabrighteningIndices) {

            this.offset = offset;
            this.argabrighteningIndices = argabrighteningIndices;
        }

        @Override
        public void visit(Persistable outputs) {
            PaOutputs paOutputs = (PaOutputs) outputs;

            for (int index : paOutputs.getArgabrighteningIndices()) {
                if (index - offset < 0) {
                    continue;
                }
                argabrighteningIndices.add(index - offset);
            }
        }
    }

    private static class ReactionWheelZeroCrossingVisitor implements
        PersistableVisitor {

        private List<Integer> reactionWheelZeroCrossingIndices;
        int offset;

        public ReactionWheelZeroCrossingVisitor(int offset,
            List<Integer> reactionWheelZeroCrossingIndices) {

            this.offset = offset;
            this.reactionWheelZeroCrossingIndices = reactionWheelZeroCrossingIndices;
        }

        @Override
        public void visit(Persistable outputs) {
            PaOutputs paOutputs = (PaOutputs) outputs;

            for (int index : paOutputs.getReactionWheelZeroCrossingIndices()) {
                if (index - offset < 0) {
                    continue;
                }
                reactionWheelZeroCrossingIndices.add(index - offset);
            }
        }
    }

    private static class ArpTargetVisitor implements PersistableVisitor {

        private Set<Pixel> arpPixels;

        public ArpTargetVisitor(Set<Pixel> arpPixels) {

            this.arpPixels = arpPixels;
        }

        @Override
        public void visit(Persistable inputs) {
            PaInputs paInputs = (PaInputs) inputs;

            for (PaTarget target : paInputs.getTargets()) {
                if (Arrays.asList(target.getLabels())
                    .contains(ARTIFACT_REMOVAL_LABEL)) {
                    if (!arpPixels.isEmpty()) {
                        throw new IllegalStateException("too many ARP targets");
                    }
                    for (PaPixelTimeSeries paTimeSeries : target.getPaPixelTimeSeries()) {
                        Pixel pixel = new Pixel(paTimeSeries.getCcdRow(),
                            paTimeSeries.getCcdColumn(),
                            paTimeSeries.isInOptimalAperture());
                        arpPixels.add(pixel);
                    }
                }
            }
        }
    }

    private static class BinInputFilter implements FilenameFilter {
        @Override
        public boolean accept(File dir, String name) {
            if (name.startsWith("pa-inputs-") && name.endsWith(".bin")) {
                return true;
            }
            return false;
        }
    }

    private static class BinOutputFilter implements FilenameFilter {
        @Override
        public boolean accept(File dir, String name) {
            if (name.startsWith("pa-outputs-") && name.endsWith(".bin")) {
                return true;
            }
            return false;
        }
    }
}
