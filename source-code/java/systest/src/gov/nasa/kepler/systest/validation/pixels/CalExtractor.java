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

package gov.nasa.kepler.systest.validation.pixels;

import gov.nasa.kepler.cal.CalPipelineModule;
import gov.nasa.kepler.cal.io.BlackResidualTimeSeries;
import gov.nasa.kepler.cal.io.BlackTimeSeries;
import gov.nasa.kepler.cal.io.CalCollateralCosmicRay;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.cal.io.CalInputs;
import gov.nasa.kepler.cal.io.CalOutputPixelTimeSeries;
import gov.nasa.kepler.cal.io.CalOutputs;
import gov.nasa.kepler.cal.io.CalibratedCollateralPixels;
import gov.nasa.kepler.cal.io.CalibratedSmearTimeSeries;
import gov.nasa.kepler.cal.io.CosmicRayEvents;
import gov.nasa.kepler.cal.io.SingleBlackTimeSeries;
import gov.nasa.kepler.cal.io.SingleResidualBlackTimeSeries;
import gov.nasa.kepler.cal.io.SmearTimeSeries;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.systest.validation.PersistableVisitor;
import gov.nasa.kepler.systest.validation.TaskFileType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.PersistableUtils;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts the calibrated collateral and pixels from the CAL outputs.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class CalExtractor {

    private static final Log log = LogFactory.getLog(CalExtractor.class);

    // Virtual and masked black collateral values are only generated in short
    // cadence. There is only one value for each type, so use an
    // offset of 0 to match what is written to the FITS file.
    private static final int SINGLE_COLLATERAL_SUMMED_OFFSET_REPLACEMENT = 0;

    // Older versions of cal populated entire vectors for collateral even though
    // for short cadence, the vectors could be sparse. In this case, cal would
    // fill the holes with an offset of -1. Post 6.1 versions of cal create
    // sparse vectors, so a warning should be generated if these collateral
    // elements are seen.
    private static final int PLACEHOLDER_OFFSET = -1;

    private long pipelineInstanceId;
    private int startCadence;
    private int ccdModule;
    private int ccdOutput;
    private File tasksRootDirectory;

    private Map<File, Persistable> persistableCache = null;

    public CalExtractor(long pipelineInstanceId, int ccdModule, int ccdOutput,
        File tasksRootDirectory, boolean cacheEnabled) {

        if (tasksRootDirectory == null) {
            throw new NullPointerException("tasksRootDirectory can't be null");
        }

        this.pipelineInstanceId = pipelineInstanceId;

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.tasksRootDirectory = tasksRootDirectory;

        if (cacheEnabled) {
            persistableCache = new HashMap<File, Persistable>();
        }
    }

    private boolean process(int cadence, TaskFileType type,
        PersistableVisitor visitor) {

        Pair<String, Integer> dirNameAndStartCadence = ValidationUtils.taskDirNameAndStartCadence(
            pipelineInstanceId, CalPipelineModule.MODULE_NAME, cadence,
            ccdModule, ccdOutput);
        log.debug(String.format("Task files in %s start at cadence %d",
            dirNameAndStartCadence.left, dirNameAndStartCadence.right));
        File dir = new File(tasksRootDirectory, dirNameAndStartCadence.left);
        startCadence = dirNameAndStartCadence.right;

        if (!ValidationUtils.directoryReadable(dir, "CAL working directory")) {
            return false;
        }

        List<File> binFileList = ValidationUtils.getBinFiles(dir, "cal", type);
        if (binFileList.size() == 0) {
            log.warn(dir.getPath() + ": no " + type.toString()
                .toLowerCase() + " .bin files");
            return false;
        }

        for (File binFile : binFileList) {
            if (!ValidationUtils.fileReadable(binFile, "CAL bin file")) {
                continue;
            }

            Persistable persistable = persistableCache != null ? persistableCache.get(binFile)
                : null;
            if (persistable == null) {
                switch (type) {
                    case OUTPUTS:
                        persistable = new CalOutputs();
                        break;
                    case INPUTS:
                        persistable = new CalInputs();
                        break;
                }

                PersistableUtils.readBinFile(persistable, binFile);
                if (persistableCache != null) {
                    persistableCache.put(binFile, persistable);
                }
            }

            visitor.visit(persistable);

            log.debug("Successfully processed " + binFile.getPath());
        }

        return true;
    }

    public boolean extractInputPixels(
        int cadence,
        Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn,
        Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

        if (pixelValuesByRowColumn == null) {
            throw new NullPointerException(
                "pixelValuesByRowColumn can't be null");
        }

        return process(cadence, TaskFileType.INPUTS, new PixelVisitor(cadence,
            pixelValuesByRowColumn, pixelValuesByCollateralTypeOffset));
    }

    public boolean extractOutputPixels(
        int cadence,
        Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn,
        Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

        if (pixelValuesByRowColumn == null) {
            throw new NullPointerException(
                "pixelValuesByRowColumn can't be null");
        }

        return process(cadence, TaskFileType.OUTPUTS,
            new CalibratedPixelVisitor(cadence, pixelValuesByRowColumn,
                pixelValuesByCollateralTypeOffset));
    }

    /**
     * Extract the cosmic rays from the cal task files. The cadence must not be
     * gapped.
     * 
     * @param cadence the cadence of interest
     * @param cadenceMjd the mid-MJD of the cadence of interest
     * @param taskCosmicRaysByCollateralTypeOffset the return map
     * @return {@code true}, if the extraction proceeded normally; otherwise,
     * {@code false}
     */
    public boolean extractCosmicRays(
        int cadence,
        double cadenceMjd,
        Map<Pair<CollateralType, Integer>, Float> taskCosmicRaysByCollateralTypeOffset) {

        if (taskCosmicRaysByCollateralTypeOffset == null) {
            throw new NullPointerException(
                "taskCosmicRaysByCollateralTypeOffset can't be null");
        }

        return process(cadence, TaskFileType.OUTPUTS, new CosmicRayVisitor(
            cadenceMjd, taskCosmicRaysByCollateralTypeOffset));
    }

    /**
     * Extract the cosmic ray mjds from the cal task files.
     * 
     * @param taskCosmicRayMjdsByCollateralTypeOffset the return map
     * @return {@code true}, if the extraction proceeded normally; otherwise,
     * {@code false}
     */
    public boolean extractCosmicRayMjds(
        int cadence,
        Set<Integer> rowProjection,
        Set<Integer> columnProjection,
        Map<Pair<CollateralType, Integer>, List<Double>> taskCosmicRayMjdsByCollateralTypeOffset) {

        if (taskCosmicRayMjdsByCollateralTypeOffset == null) {
            throw new NullPointerException(
                "taskCosmicRaysByCollateralTypeOffset can't be null");
        }

        return process(cadence, TaskFileType.OUTPUTS, new CosmicRayMjdVisitor(
            rowProjection, columnProjection,
            taskCosmicRayMjdsByCollateralTypeOffset));
    }

    private class PixelVisitor implements PersistableVisitor {

        private int cadence;
        private Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn;
        private Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset;

        public PixelVisitor(
            int cadence,
            Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            this.cadence = cadence;
            this.pixelValuesByRowColumn = pixelValuesByRowColumn;
            this.pixelValuesByCollateralTypeOffset = pixelValuesByCollateralTypeOffset;
        }

        @Override
        public void visit(Persistable inputs) {
            CalInputs calInputs = (CalInputs) inputs;

            int index = cadence - startCadence;

            if (pixelValuesByCollateralTypeOffset != null) {
                extractBlackPixelsCadenceSlice(CollateralType.BLACK_LEVEL,
                    calInputs.getBlackPixels(), index,
                    pixelValuesByCollateralTypeOffset);
                extractSingleBlackPixelsCadenceSlice(
                    CollateralType.BLACK_MASKED,
                    calInputs.getMaskedBlackPixels(), index,
                    pixelValuesByCollateralTypeOffset);
                extractSingleBlackPixelsCadenceSlice(
                    CollateralType.BLACK_VIRTUAL,
                    calInputs.getVirtualBlackPixels(), index,
                    pixelValuesByCollateralTypeOffset);
                extractSmearTimeSeriesCadenceSlice(CollateralType.MASKED_SMEAR,
                    calInputs.getMaskedSmearPixels(), index,
                    pixelValuesByCollateralTypeOffset);
                extractSmearTimeSeriesCadenceSlice(
                    CollateralType.VIRTUAL_SMEAR,
                    calInputs.getVirtualSmearPixels(), index,
                    pixelValuesByCollateralTypeOffset);
            }

            for (CalInputPixelTimeSeries pixelTimeSeries : calInputs.getTargetAndBkgPixels()) {
                pixelValuesByRowColumn.put(
                    Pair.of(pixelTimeSeries.getRow(),
                        pixelTimeSeries.getColumn()),
                    Arrays.asList(new Number[] {
                        pixelTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_PIXEL_VALUE
                            : pixelTimeSeries.getValues()[index],
                        ValidationUtils.FITS_FILL_VALUE,
                        ValidationUtils.FITS_FILL_VALUE }));
            }
        }

        private void extractBlackPixelsCadenceSlice(
            CollateralType collateralType,
            List<BlackTimeSeries> blackTimeSeriesList,
            int index,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            for (BlackTimeSeries blackTimeSeries : blackTimeSeriesList) {
                pixelValuesByCollateralTypeOffset.put(
                    Pair.of(collateralType, blackTimeSeries.getRow()),
                    Arrays.asList(new Number[] {
                        blackTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_PIXEL_VALUE
                            : blackTimeSeries.getValues()[index],
                        ValidationUtils.FITS_FILL_VALUE,
                        ValidationUtils.FITS_FILL_VALUE }));
            }
        }

        private void extractSingleBlackPixelsCadenceSlice(
            CollateralType collateralType,
            List<SingleBlackTimeSeries> singleBlackTimeSeriesList,
            int index,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            for (SingleBlackTimeSeries singleBlackTimeSeries : singleBlackTimeSeriesList) {
                pixelValuesByCollateralTypeOffset.put(
                    Pair.of(collateralType,
                        SINGLE_COLLATERAL_SUMMED_OFFSET_REPLACEMENT),
                    Arrays.asList(new Number[] {
                        singleBlackTimeSeries.gapIndicators()[index] ? ValidationUtils.MISSING_PIXEL_VALUE
                            : singleBlackTimeSeries.values()[index],
                        ValidationUtils.FITS_FILL_VALUE,
                        ValidationUtils.FITS_FILL_VALUE }));
            }
        }

        private void extractSmearTimeSeriesCadenceSlice(
            CollateralType collateralType,
            List<SmearTimeSeries> smearTimeSeriesList,
            int index,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            for (SmearTimeSeries smearTimeSeries : smearTimeSeriesList) {
                pixelValuesByCollateralTypeOffset.put(
                    Pair.of(collateralType, smearTimeSeries.getColumn()),
                    Arrays.asList(new Number[] {
                        smearTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_PIXEL_VALUE
                            : smearTimeSeries.getValues()[index],
                        ValidationUtils.FITS_FILL_VALUE,
                        ValidationUtils.FITS_FILL_VALUE }));
            }
        }
    }

    private class CalibratedPixelVisitor implements PersistableVisitor {

        private int cadence;
        private Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn;
        private Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset;

        public CalibratedPixelVisitor(
            int cadence,
            Map<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            this.cadence = cadence;
            this.pixelValuesByRowColumn = pixelValuesByRowColumn;
            this.pixelValuesByCollateralTypeOffset = pixelValuesByCollateralTypeOffset;
        }

        @Override
        public void visit(Persistable outputs) {
            CalOutputs calOutputs = (CalOutputs) outputs;

            int index = cadence - startCadence;

            CalibratedCollateralPixels pixels = calOutputs.getCalibratedCollateralPixels();

            if (pixelValuesByCollateralTypeOffset != null) {
                extractBlackResidualCadenceSlice(CollateralType.BLACK_LEVEL,
                    pixels.getBlackResidual(), index,
                    pixelValuesByCollateralTypeOffset);
                extractSingleResidualCadenceSlice(CollateralType.BLACK_MASKED,
                    pixels.getMaskedBlackResidual(), index,
                    pixelValuesByCollateralTypeOffset);
                extractSingleResidualCadenceSlice(CollateralType.BLACK_VIRTUAL,
                    pixels.getVirtualBlackResidual(), index,
                    pixelValuesByCollateralTypeOffset);
                extractCalibratedSmearCadenceSlice(CollateralType.MASKED_SMEAR,
                    pixels.getMaskedSmear(), index,
                    pixelValuesByCollateralTypeOffset);
                extractCalibratedSmearCadenceSlice(
                    CollateralType.VIRTUAL_SMEAR, pixels.getVirtualSmear(),
                    index, pixelValuesByCollateralTypeOffset);
            }

            if (pixelValuesByRowColumn != null) {
                for (CalOutputPixelTimeSeries pixelTimeSeries : calOutputs.getTargetAndBackgroundPixels()) {
                    pixelValuesByRowColumn.put(
                        Pair.of(pixelTimeSeries.getRow(),
                            pixelTimeSeries.getColumn()),
                        Arrays.asList(new Number[] {
                            ValidationUtils.FITS_FILL_VALUE,
                            pixelTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                                : pixelTimeSeries.getValues()[index],
                            pixelTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                                : pixelTimeSeries.getUncertainties()[index] }));
                }
            }
        }

        private void extractBlackResidualCadenceSlice(
            CollateralType collateralType,
            List<BlackResidualTimeSeries> blackResidualTimeSeriesList,
            int index,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            for (BlackResidualTimeSeries blackResidualTimeSeries : blackResidualTimeSeriesList) {
                if (blackResidualTimeSeries.getRow() == PLACEHOLDER_OFFSET) {
                    continue;
                }
                pixelValuesByCollateralTypeOffset.put(
                    Pair.of(collateralType, blackResidualTimeSeries.getRow()),
                    Arrays.asList(new Number[] {
                        ValidationUtils.FITS_FILL_VALUE,
                        blackResidualTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                            : blackResidualTimeSeries.getValues()[index],
                        blackResidualTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                            : blackResidualTimeSeries.getUncertainties()[index] }));
            }
        }

        private void extractSingleResidualCadenceSlice(
            CollateralType collateralType,
            SingleResidualBlackTimeSeries singleResidualBlackTimeSeries,
            int index,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            if (singleResidualBlackTimeSeries.exists()) {
                pixelValuesByCollateralTypeOffset.put(
                    Pair.of(collateralType,
                        SINGLE_COLLATERAL_SUMMED_OFFSET_REPLACEMENT),
                    Arrays.asList(new Number[] {
                        ValidationUtils.FITS_FILL_VALUE,
                        singleResidualBlackTimeSeries.gapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                            : singleResidualBlackTimeSeries.values()[index],
                        singleResidualBlackTimeSeries.gapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                            : singleResidualBlackTimeSeries.uncertainties()[index] }));
            }
        }

        private void extractCalibratedSmearCadenceSlice(
            CollateralType collateralType,
            List<CalibratedSmearTimeSeries> calibratedSmearTimeSeriesList,
            int index,
            Map<Pair<CollateralType, Integer>, List<Number>> pixelValuesByCollateralTypeOffset) {

            for (CalibratedSmearTimeSeries calibratedSmearTimeSeries : calibratedSmearTimeSeriesList) {
                if (calibratedSmearTimeSeries.getColumn() == PLACEHOLDER_OFFSET) {
                    continue;
                }
                pixelValuesByCollateralTypeOffset.put(
                    Pair.of(collateralType,
                        calibratedSmearTimeSeries.getColumn()),
                    Arrays.asList(new Number[] {
                        ValidationUtils.FITS_FILL_VALUE,
                        calibratedSmearTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                            : calibratedSmearTimeSeries.getValues()[index],
                        calibratedSmearTimeSeries.getGapIndicators()[index] ? ValidationUtils.MISSING_CAL_PIXEL_VALUE
                            : calibratedSmearTimeSeries.getUncertainties()[index] }));
            }
        }
    }

    public class CosmicRayVisitor implements PersistableVisitor {

        private Map<Pair<CollateralType, Integer>, Float> taskCosmicRaysByCollateralTypeOffset;
        private double cadenceMjd;

        public CosmicRayVisitor(
            double cadenceMjd,
            Map<Pair<CollateralType, Integer>, Float> taskCosmicRaysByCollateralTypeOffset) {

            this.taskCosmicRaysByCollateralTypeOffset = taskCosmicRaysByCollateralTypeOffset;
            this.cadenceMjd = cadenceMjd;
        }

        @Override
        public void visit(Persistable outputs) {
            CalOutputs calOutputs = (CalOutputs) outputs;

            CosmicRayEvents cosmicRayEvents = calOutputs.getCosmicRayEvents();
            extractCosmicRays(CollateralType.BLACK_LEVEL,
                cosmicRayEvents.getBlack());
            extractCosmicRays(CollateralType.BLACK_MASKED,
                cosmicRayEvents.getMaskedBlack());
            extractCosmicRays(CollateralType.BLACK_VIRTUAL,
                cosmicRayEvents.getVirtualBlack());
            extractCosmicRays(CollateralType.MASKED_SMEAR,
                cosmicRayEvents.getMaskedSmear());
            extractCosmicRays(CollateralType.VIRTUAL_SMEAR,
                cosmicRayEvents.getVirtualSmear());
        }

        private void extractCosmicRays(CollateralType type,
            List<CalCollateralCosmicRay> cosmicRays) {
            for (CalCollateralCosmicRay cosmicRay : cosmicRays) {
                if (cosmicRay.getMjd() == cadenceMjd) {
                    taskCosmicRaysByCollateralTypeOffset.put(
                        Pair.of(type, cosmicRay.getRowOrColumn()),
                        cosmicRay.getDelta());
                }
            }
        }
    }

    public class CosmicRayMjdVisitor implements PersistableVisitor {

        private Set<Integer> rowProjection;
        private Set<Integer> columnProjection;
        private Map<Pair<CollateralType, Integer>, List<Double>> taskCosmicRayMjdsByCollateralTypeOffset;

        public CosmicRayMjdVisitor(
            Set<Integer> rowProjection,
            Set<Integer> columnProjection,
            Map<Pair<CollateralType, Integer>, List<Double>> taskCosmicRayMjdsByCollateralTypeOffset) {

            this.rowProjection = rowProjection;
            this.columnProjection = columnProjection;
            this.taskCosmicRayMjdsByCollateralTypeOffset = taskCosmicRayMjdsByCollateralTypeOffset;
        }

        @Override
        public void visit(Persistable outputs) {
            CalOutputs calOutputs = (CalOutputs) outputs;

            CosmicRayEvents cosmicRayEvents = calOutputs.getCosmicRayEvents();
            extractCosmicRays(CollateralType.BLACK_LEVEL,
                cosmicRayEvents.getBlack());
            extractCosmicRays(CollateralType.BLACK_MASKED,
                cosmicRayEvents.getMaskedBlack());
            extractCosmicRays(CollateralType.BLACK_VIRTUAL,
                cosmicRayEvents.getVirtualBlack());
            extractCosmicRays(CollateralType.MASKED_SMEAR,
                cosmicRayEvents.getMaskedSmear());
            extractCosmicRays(CollateralType.VIRTUAL_SMEAR,
                cosmicRayEvents.getVirtualSmear());
        }

        private void extractCosmicRays(CollateralType type,
            List<CalCollateralCosmicRay> cosmicRays) {
            for (CalCollateralCosmicRay cosmicRay : cosmicRays) {
                switch (type) {
                    case MASKED_SMEAR:
                    case VIRTUAL_SMEAR:
                        if (columnProjection == null
                            || columnProjection.contains(cosmicRay.getRowOrColumn())) {
                            Pair<CollateralType, Integer> key = Pair.of(type,
                                cosmicRay.getRowOrColumn());
                            List<Double> cosmicRayMjds = taskCosmicRayMjdsByCollateralTypeOffset.get(key);
                            if (cosmicRayMjds == null) {
                                cosmicRayMjds = new ArrayList<Double>();
                                taskCosmicRayMjdsByCollateralTypeOffset.put(
                                    key, cosmicRayMjds);
                            }
                            cosmicRayMjds.add(cosmicRay.getMjd());
                        }
                        break;
                    case BLACK_LEVEL:
                    case BLACK_MASKED:
                    case BLACK_VIRTUAL:
                        if (rowProjection == null
                            || rowProjection.contains(cosmicRay.getRowOrColumn())) {
                            Pair<CollateralType, Integer> key = Pair.of(type,
                                cosmicRay.getRowOrColumn());
                            List<Double> cosmicRayMjds = taskCosmicRayMjdsByCollateralTypeOffset.get(key);
                            if (cosmicRayMjds == null) {
                                cosmicRayMjds = new ArrayList<Double>();
                                taskCosmicRayMjdsByCollateralTypeOffset.put(
                                    key, cosmicRayMjds);
                            }
                            cosmicRayMjds.add(cosmicRay.getMjd());
                        }
                        break;
                }
            }
        }
    }
}
