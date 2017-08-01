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

import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_TARGET_PIXELS;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.CALIBRATED_UNCERTAINTY;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.CALIBRATED_VALUE;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.ORIGINAL_VALUE;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.AperturePixel;
import gov.nasa.kepler.systest.validation.ArExtractor;
import gov.nasa.kepler.systest.validation.FitsAperture;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FluxConverter;
import gov.nasa.kepler.systest.validation.PaExtractor;
import gov.nasa.kepler.systest.validation.PdcExtractor;
import gov.nasa.kepler.systest.validation.SimpleDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.SimpleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * FITS target pixels validator.
 * 
 * @author Forrest Girouard
 */
public class FitsTargetPixelValidator {

    private static final int HEARTBEAT_CADENCE_COUNT = 500;

    private static final Log log = LogFactory.getLog(FitsTargetPixelValidator.class);
    private static final int BACKGROUND_VALUE = 3;
    private static final int BACKGROUND_UNCERTAINTY = 4;

    private FitsValidationOptions options;
    private File pixelsInputDirectory;
    private File pmrfDirectory;
    private File targetPixelsOutputDirectory;
    private File tasksRootDirectory;

    public FitsTargetPixelValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        if (options.getCommand() != VALIDATE_TARGET_PIXELS) {
            throw new IllegalStateException("Unexpected command "
                + options.getCommand()
                    .getName());
        }

        if (options.getArId() == -1) {
            throw new UsageException("AR pipeline instance ID not set");
        }
        if (options.getCalId() == -1) {
            throw new UsageException("CAL pipeline instance ID not set");
        }
        if (options.getPaId() == -1) {
            throw new UsageException("PA pipeline instance ID not set");
        }
        if (options.getPdcId() == -1) {
            throw new UsageException("PDC pipeline instance ID not set");
        }
        if (options.getCadenceRange() == null) {
            throw new UsageException("Cadence range not set");
        }
        if (options.getCcdModule() == -1 ^ options.getCcdOutput() == -1) {
            if (options.getCcdModule() == -1) {
                throw new UsageException("CCD module not set");
            }
            if (options.getCcdOutput() == -1) {
                throw new UsageException("CCD output not set");
            }
        }

        if (options.getPixelsInputDirectory() == null) {
            throw new UsageException("Pixels input directory not set");
        }
        pixelsInputDirectory = new File(options.getPixelsInputDirectory());
        if (!ValidationUtils.directoryReadable(pixelsInputDirectory,
            "Pixels input directory")) {
            throw new UsageException("Can't read pixels input directory "
                + pixelsInputDirectory);
        }

        if (options.getPmrfDirectory() == null) {
            throw new UsageException("PMRF directory not set");
        }
        pmrfDirectory = new File(options.getPmrfDirectory());
        if (!ValidationUtils.directoryReadable(pmrfDirectory, "PMRF directory")) {
            throw new UsageException("Can't read PMRF directory "
                + pmrfDirectory);
        }

        if (options.getTargetPixelsDirectory() == null) {
            throw new UsageException("Target pixels directory not set");
        }
        targetPixelsOutputDirectory = new File(
            options.getTargetPixelsDirectory());
        if (!ValidationUtils.directoryReadable(targetPixelsOutputDirectory,
            "Target pixels output directory")) {
            throw new UsageException(
                "Can't read target pixels output directory "
                    + targetPixelsOutputDirectory);
        }

        if (options.getTasksRootDirectory() == null) {
            throw new UsageException("Tasks root directory not set");
        }
        tasksRootDirectory = new File(options.getTasksRootDirectory());
        if (!ValidationUtils.directoryReadable(tasksRootDirectory,
            "Tasks root directory")) {
            throw new UsageException("Can't read tasksRootDirectory directory "
                + tasksRootDirectory);
        }

        if (options.getMaxErrorsDisplayed() < 0) {
            throw new UsageException("Max errors displayed can't be negative");
        }
        if (options.getSkipCount() < 0) {
            throw new UsageException("Skip count can't be negative");
        }
        if (options.getChunkSize() < options.getSkipCount()) {
            throw new UsageException(
                "Chunk size must be greater than or equal to skip count");
        }
        if (options.getTargetSkipCount() < 0) {
            throw new UsageException("Target skip count can't be negative");
        }
    }

    public void validate() throws FitsException, IOException,
        ValidationException {

        boolean failed = false;

        Set<PixelUowTask> pixelUowTasks = PixelUowTask.createTasks(
            options.getCcdModule(), options.getCcdOutput(),
            options.getCadenceRange(), options.getChunkSize());
        long startTime = System.currentTimeMillis() / 1000;

        for (PixelUowTask pixelUowTask : pixelUowTasks) {
            if (!validate(options.getKeplerId(), pixelUowTask.getCcdModule(),
                pixelUowTask.getCcdOutput(), pixelUowTask.getStartCadence(),
                pixelUowTask.getEndCadence())) {
                failed = true;
            }
            if (options.getTimeLimit() > 0
                && System.currentTimeMillis() / 1000 - startTime > options.getTimeLimit() * 60) {
                log.info(String.format("%d minute time limit exceeded",
                    options.getTimeLimit()));
                break;
            }
        }

        if (failed) {
            throw new ValidationException("Files differ; see log");
        }
    }

    public boolean validate(int keplerIdOverride, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) throws FitsException, IOException {

        CadenceType cadenceType = ValidationUtils.getCadenceType(options.getCalId());
        MjdToCadence mjdToCadence = new MjdToCadence(cadenceType,
            new ModelMetadataRetrieverLatest());
        TimestampSeries cadenceTimes = mjdToCadence.cadenceTimes(startCadence,
            endCadence);

        List<ConfigMap> configMaps = new ConfigMapOperations().retrieveConfigMaps(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());
        FluxConverter fluxConverter = new FluxConverter(configMaps, cadenceType);

        FitsPixelExtractor fitsPixelExtractor = new FitsPixelExtractor(
            cadenceTimes, startCadence, cadenceType, ccdModule, ccdOutput,
            pmrfDirectory, pixelsInputDirectory);

        CalExtractor calExtractor = new CalExtractor(options.getCalId(),
            ccdModule, ccdOutput, tasksRootDirectory, options.isCacheEnabled());

        Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId = new HashMap<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>>();
        PaExtractor paExtractor = new PaExtractor(options.getPaId(), ccdModule,
            ccdOutput, tasksRootDirectory, options.isCacheEnabled());
        paExtractor.extractTimeSeries(simpleTimeSeriesByKeplerId, null, null);

        PdcExtractor pdcExtractor = new PdcExtractor(options.getPdcId(),
            ccdModule, ccdOutput, tasksRootDirectory);

        ArExtractor arExtractor = new ArExtractor(options.getArId(), ccdModule,
            ccdOutput, tasksRootDirectory, "targetPixelExporter");
        arExtractor.extractTimeCorrection(simpleTimeSeriesByKeplerId);

        FitsTargetPixelExtractor targetPixelsExtractor = new FitsTargetPixelExtractor(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, targetPixelsOutputDirectory);

        TargetTable targetTable = ValidationUtils.getTargetTable(cadenceType,
            startCadence, endCadence);

        List<Integer> keplerIds = new ArrayList<Integer>();
        if (keplerIdOverride != -1) {
            keplerIds.add(keplerIdOverride);
        } else {
            keplerIds = targetPixelsExtractor.extractKeplerIds();
        }

        Map<Integer, PdcProcessingCharacteristics> pdcProcessingCharacteristicsByKeplerId = new HashMap<Integer, PdcProcessingCharacteristics>();
        pdcExtractor.extractProcessingCharacteristics(pdcProcessingCharacteristicsByKeplerId);

        boolean equals = true;
        int targetCount = 0;
        int cadenceCount = 0;

        for (int i = 0; i < keplerIds.size(); i += options.getTargetSkipCount() + 1) {
            int keplerId = keplerIds.get(i);

            targetPixelsExtractor.setKeplerId(keplerId);

            int offset = targetPixelsExtractor.extractCadenceOffset();

            Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> fitsSimpleTimeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
            Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> fitsSimpleDoubleTimeSeriesByType = new HashMap<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries>();
            if (!targetPixelsExtractor.extractTimeSeries(
                fitsSimpleTimeSeriesByType, fitsSimpleDoubleTimeSeriesByType)) {
                return false;
            }
            SimpleFloatTimeSeries fitsTimeCorrectionTimeSeries = fitsSimpleTimeSeriesByType.get(SimpleTimeSeriesType.TIME_CORRECTION);
            SimpleDoubleTimeSeries fitsTimeTimeSeries = fitsSimpleDoubleTimeSeriesByType.get(SimpleDoubleTimeSeriesType.TIME);

            ValidationUtils.validateTimes(options.getMaxErrorsDisplayed(),
                keplerId, startCadence, endCadence, cadenceTimes,
                paExtractor.getCadenceRange(),
                simpleTimeSeriesByKeplerId.get(keplerId),
                fitsTimeCorrectionTimeSeries, fitsTimeTimeSeries);

            FitsAperture targetPixelsAperture = new FitsAperture();
            if (!extractAperture(keplerId, targetTable, targetPixelsExtractor,
                targetPixelsAperture)) {
                equals = false;
            }

            Set<Integer> apertureRowProjection = new HashSet<Integer>();
            Set<Integer> apertureColumnProjection = new HashSet<Integer>();
            ValidationUtils.extractOptimalApertureProjections(
                targetPixelsAperture, apertureRowProjection,
                apertureColumnProjection);

            Map<Pair<CollateralType, Integer>, List<Double>> taskCollateralCosmicRaysByTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Double>>();
            calExtractor.extractCosmicRayMjds(startCadence,
                apertureRowProjection, apertureColumnProjection,
                taskCollateralCosmicRaysByTypeOffset);

            Set<Integer> cadencesWithCollateralCosmicRays = new HashSet<Integer>();
            for (List<Double> cosmicRayMjds : taskCollateralCosmicRaysByTypeOffset.values()) {
                for (Double mjd : cosmicRayMjds) {
                    cadencesWithCollateralCosmicRays.add(mjdToCadence.mjdToCadence(mjd));
                }
            }

            Map<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>> timeSeriesMapByPixel = new HashMap<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>>();
            arExtractor.extractTimeSeries(timeSeriesMapByPixel);

            Map<PdcExtractor.PdcFlag, SimpleFloatTimeSeries> timeSeriesByPdcFlagType = new HashMap<PdcExtractor.PdcFlag, SimpleFloatTimeSeries>();
            pdcExtractor.extractDiscontinuityOutlier(offset, endCadence
                - startCadence + 1, keplerId, timeSeriesByPdcFlagType);

            List<Integer> argabrighteningIndices = new ArrayList<Integer>();
            paExtractor.extractArgabrighteningIndices(offset,
                argabrighteningIndices);

            List<Integer> reactionWheelZeroCrossingIndices = new ArrayList<Integer>();
            paExtractor.extractReactionWheelZeroCrossingIndices(offset,
                reactionWheelZeroCrossingIndices);

            Set<SimpleIntTimeSeries> simpleIntTimeSeries = new HashSet<SimpleIntTimeSeries>();
            targetPixelsExtractor.extractQuality(simpleIntTimeSeries);
            SimpleIntTimeSeries qualityTimeSeries = simpleIntTimeSeries.iterator()
                .next();

            cadenceCount = 0;
            for (int cadence = startCadence; cadence <= endCadence; cadence += options.getSkipCount() + 1) {
                log.debug(String.format(
                    "Validating %s cadence %d in range %d-%d",
                    cadenceType.toString()
                        .toLowerCase(), cadence, startCadence, endCadence));

                Map<Pixel, List<Number>> targetPixelValuesByPixel = new HashMap<Pixel, List<Number>>();
                targetPixelsExtractor.extractPixels(cadence, startCadence,
                    targetPixelsAperture, targetPixelValuesByPixel);

                int cadenceIndex = cadence - startCadence;
                if (cadenceTimes.gapIndicators[cadenceIndex]) {
                    log.info(String.format(
                        "Detected gapped %s cadence %d in range %d-%d",
                        cadenceType.toString()
                            .toLowerCase(), cadence, startCadence, endCadence));

                    if (!diffGap(cadence, targetPixelsAperture,
                        targetPixelValuesByPixel)) {
                        equals = false;
                    }
                    continue;
                }

                Map<Pair<Integer, Integer>, List<Number>> fitsInputPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
                if (!fitsPixelExtractor.extractPixels(cadence,
                    fitsInputPixelValuesByRowColumn, null, null)) {
                    equals = false;
                }

                Map<Pixel, List<Number>> taskPixelValuesByPixel = new HashMap<Pixel, List<Number>>();
                if (!extractTaskPixelValuesByPixel(cadence, calExtractor,
                    targetPixelsAperture, fitsInputPixelValuesByRowColumn,
                    taskPixelValuesByPixel)) {
                    continue;
                }

                Pair<Integer, Integer> fitsCadenceRange = targetPixelsExtractor.getFitsFileCadenceRange(cadence);
                updatePixelValuesByPixel(cadence - fitsCadenceRange.left,
                    taskPixelValuesByPixel, timeSeriesMapByPixel);

                Map<Pixel, Float> cosmicRaysByPixel = new HashMap<Pixel, Float>();
                if (!targetPixelsExtractor.extractCosmicRays(cadence,
                    targetPixelsAperture, cosmicRaysByPixel)) {
                    equals = false;
                }

                Map<Pair<Integer, Integer>, Float> taskCosmicRaysByRowColumn = new HashMap<Pair<Integer, Integer>, Float>();
                paExtractor.extractCosmicRays(cadence,
                    cadenceTimes.midTimestamps[cadence - startCadence],
                    taskCosmicRaysByRowColumn,
                    new HashMap<Pair<Integer, Integer>, Float>());

                Map<Pixel, Float> taskCosmicRaysByPixel = convertCosmicRaysByRowColumnToByPixel(
                    targetPixelsAperture, taskCosmicRaysByRowColumn);

                if (!diffData("Target pixels", cadence, keplerId,
                    fluxConverter, taskCosmicRaysByPixel,
                    taskPixelValuesByPixel, targetPixelValuesByPixel)) {
                    equals = false;
                }

                if (!PixelsValidationUtils.diffCosmicRays(
                    options.getMaxErrorsDisplayed(),
                    "Target cosmic ray events", cadence, fluxConverter,
                    taskCosmicRaysByPixel, cosmicRaysByPixel)) {
                    equals = false;
                }

                int qualityFlags = ValidationUtils.assembleQualityFlags(
                    startCadence, cadence, cadenceTimes, taskCosmicRaysByPixel,
                    new HashSet<Integer>(), cadencesWithCollateralCosmicRays,
                    argabrighteningIndices, timeSeriesByPdcFlagType,
                    reactionWheelZeroCrossingIndices);

                if (!PixelsValidationUtils.diffQualityFlags("Quality flags",
                    cadence, qualityFlags,
                    qualityTimeSeries.getValues()[cadence - startCadence])) {
                    equals = false;
                }

                if (++cadenceCount % HEARTBEAT_CADENCE_COUNT == 0) {
                    log.info(String.format("Processed %d cadences",
                        cadenceCount));
                }
            }
            targetCount++;
        }
        log.info(String.format(
            "%s %d cadences in range %d-%d for %d targets on module/output %d/%d",
            equals ? "Validated" : "Processed", cadenceCount, startCadence,
            endCadence, targetCount, ccdModule, ccdOutput));

        return equals;
    }

    private boolean extractAperture(int keplerId, TargetTable targetTable,
        FitsTargetPixelExtractor targetPixelsExtractor,
        FitsAperture targetPixelsAperture) throws FitsException, IOException {

        if (!targetPixelsExtractor.extractAperture(targetPixelsAperture)) {
            log.error(String.format(
                "Failed to extract target pixel aperture for keplerId %d",
                keplerId));
            return false;
        }

        FitsAperture observedTargetAperture = new FitsAperture();
        if (!ValidationUtils.getObservedTargetAperture(keplerId, targetTable,
            null, null, observedTargetAperture)) {
            log.error(String.format(
                "Failed to acquire observed target aperture for keplerId %d",
                keplerId));
            return false;
        }

        if (!targetPixelsAperture.equals(observedTargetAperture)) {
            log.error(String.format(
                "Target pixel aperture differs from TAD aperture for keplerId %d",
                keplerId));
            return false;
        }

        return true;
    }

    private boolean extractTaskPixelValuesByPixel(
        int cadence,
        CalExtractor calExtractor,
        FitsAperture targetPixelsAperture,
        Map<Pair<Integer, Integer>, List<Number>> fitsInputPixelValuesByRowColumn,
        Map<Pixel, List<Number>> taskPixelValuesByPixel) {

        Map<Pair<Integer, Integer>, List<Number>> allOutputTaskPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
        if (!calExtractor.extractOutputPixels(cadence,
            allOutputTaskPixelValuesByRowColumn, null)) {
            return false;
        }

        for (AperturePixel pixel : targetPixelsAperture.getPixels()) {
            List<Number> mergedValues = new ArrayList<Number>();
            Pair<Integer, Integer> rowColumn = Pair.of(pixel.getRow(),
                pixel.getColumn());
            mergedValues.add(fitsInputPixelValuesByRowColumn.get(rowColumn)
                .get(ORIGINAL_VALUE));
            mergedValues.add(allOutputTaskPixelValuesByRowColumn.get(rowColumn)
                .get(CALIBRATED_VALUE));
            mergedValues.add(allOutputTaskPixelValuesByRowColumn.get(rowColumn)
                .get(CALIBRATED_UNCERTAINTY));
            taskPixelValuesByPixel.put(
                new Pixel(pixel.getRow(), pixel.getColumn()), mergedValues);
        }

        return true;
    }

    private void updatePixelValuesByPixel(
        int index,
        Map<Pixel, List<Number>> taskPixelValuesByPixel,
        Map<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>> timeSeriesMapByPixel) {

        for (Pixel pixel : taskPixelValuesByPixel.keySet()) {
            Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries> timeSeriesMap = timeSeriesMapByPixel.get(pixel);
            CompoundDoubleTimeSeries timeSeries = timeSeriesMap.get(TargetPixelCompoundTimeSeriesType.BACKGROUND_FLUX);
            List<Number> values = taskPixelValuesByPixel.get(pixel);
            List<Number> updatedValues = new ArrayList<Number>(values);
            updatedValues.add(BACKGROUND_VALUE, timeSeries.getValues()[index]);
            updatedValues.add(BACKGROUND_UNCERTAINTY,
                timeSeries.getUncertainties()[index]);
            taskPixelValuesByPixel.put(pixel, updatedValues);
        }
    }

    private List<Number> convertValues(FluxConverter fluxConverter,
        Float cosmicRayValue, List<Number> values) {

        ArrayList<Number> updatedTaskValues = new ArrayList<Number>();
        updatedTaskValues.add(ORIGINAL_VALUE, values.get(ORIGINAL_VALUE));

        updatedTaskValues.add(
            CALIBRATED_VALUE,
            fluxConverter.fluxPerCadenceToFluxPerSecond((double) (Float) values.get(CALIBRATED_VALUE)
                - (Double) values.get(BACKGROUND_VALUE)
                - (cosmicRayValue != null && !Float.isNaN(cosmicRayValue) ? (double) cosmicRayValue
                    : 0.0)));

        updatedTaskValues.add(
            CALIBRATED_UNCERTAINTY,
            fluxConverter.fluxPerCadenceToFluxPerSecond(Math.sqrt((double) (Float) values.get(CALIBRATED_UNCERTAINTY)
                * (double) (Float) values.get(CALIBRATED_UNCERTAINTY)
                + (double) (Float) values.get(BACKGROUND_UNCERTAINTY)
                * (double) (Float) values.get(BACKGROUND_UNCERTAINTY))));

        updatedTaskValues.add(
            BACKGROUND_VALUE,
            fluxConverter.fluxPerCadenceToFluxPerSecond((Double) values.get(BACKGROUND_VALUE)));
        updatedTaskValues.add(
            BACKGROUND_UNCERTAINTY,
            fluxConverter.fluxPerCadenceToFluxPerSecond((Float) values.get(BACKGROUND_UNCERTAINTY)));

        return updatedTaskValues;
    }

    private Map<Pixel, Float> convertCosmicRaysByRowColumnToByPixel(
        FitsAperture targetPixelsAperture,
        Map<Pair<Integer, Integer>, Float> taskCosmicRaysByRowColumn) {

        Map<Pixel, Float> taskCosmicRaysByPixel = new HashMap<Pixel, Float>();
        for (AperturePixel aperturePixel : targetPixelsAperture.getPixels()) {
            Float value = taskCosmicRaysByRowColumn.get(Pair.of(
                aperturePixel.getRow(), aperturePixel.getColumn()));
            if (value != null && !Float.isNaN(value)) {
                Pixel pixel = new Pixel(aperturePixel.getRow(),
                    aperturePixel.getColumn(),
                    aperturePixel.isInOptimalAperture());
                taskCosmicRaysByPixel.put(pixel, value);
            }
        }

        return taskCosmicRaysByPixel;
    }

    private boolean diffGap(int cadence, FitsAperture targetPixelsAperture,
        Map<Pixel, List<Number>> fitsPixelValuesByPixel) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\nUnexpected gap value(s) for cadence %d",
            cadence));
        output.append("\nRow,Column\tFITS file (orig, value, unc, bkgd, bkgd unc)\n");

        int errorCount = 0;
        for (AperturePixel pixel : targetPixelsAperture.getPixels()) {
            List<Number> fitsValues = fitsPixelValuesByPixel.get(pixel);

            if ((Integer) fitsValues.get(ORIGINAL_VALUE) != -1
                || !Float.isNaN((Float) fitsValues.get(CALIBRATED_VALUE))
                || !Float.isNaN((Float) fitsValues.get(CALIBRATED_UNCERTAINTY))
                || !Float.isNaN((Float) fitsValues.get(BACKGROUND_VALUE))
                || !Float.isNaN((Float) fitsValues.get(BACKGROUND_UNCERTAINTY))) {

                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(pixel.getRow())
                    .append(",")
                    .append(pixel.getColumn())
                    .append("\t");
                output.append(fitsValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_UNCERTAINTY))
                    .append(" ")
                    .append(fitsValues.get(BACKGROUND_VALUE))
                    .append(" ")
                    .append(fitsValues.get(BACKGROUND_UNCERTAINTY))
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                targetPixelsAperture.getPixels()
                    .size(), (double) errorCount
                    / targetPixelsAperture.getPixels()
                        .size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d pixel gaps",
                targetPixelsAperture.getPixels()
                    .size()));
        }

        return equals;
    }

    private boolean diffData(String type, int cadence, int keplerId,
        FluxConverter fluxConverter, Map<Pixel, Float> taskCosmicRaysByPixel,
        Map<Pixel, List<Number>> taskPixelValuesByPixel,
        Map<Pixel, List<Number>> fitsPixelValuesByPixel) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format(
            "\n%s for Kepler ID %d differ for cadence %d", type, keplerId,
            cadence));
        output.append("\nRow,Column\tTask file (orig, flux, flux err, bkgd, bkgd err)\tFITS file (orig, flux, flux err, bkgd, bkgd err)\n");

        int errorCount = 0;
        for (Pixel pixel : taskPixelValuesByPixel.keySet()) {
            List<Number> taskValues = convertValues(fluxConverter,
                taskCosmicRaysByPixel.get(pixel),
                taskPixelValuesByPixel.get(pixel));
            List<Number> fitsValues = fitsPixelValuesByPixel.get(pixel);

            if (!taskValues.get(ORIGINAL_VALUE)
                .equals(fitsValues.get(ORIGINAL_VALUE))
                || !ValidationUtils.numbersEqual(
                    taskValues.get(CALIBRATED_VALUE),
                    fitsValues.get(CALIBRATED_VALUE), 0.000001)
                || !ValidationUtils.numbersEqual(
                    taskValues.get(CALIBRATED_UNCERTAINTY),
                    fitsValues.get(CALIBRATED_UNCERTAINTY), 0.000001)
                || !ValidationUtils.numbersEqual(
                    taskValues.get(BACKGROUND_VALUE),
                    fitsValues.get(BACKGROUND_VALUE), 0.000001)
                || !ValidationUtils.numbersEqual(
                    taskValues.get(BACKGROUND_UNCERTAINTY),
                    fitsValues.get(BACKGROUND_UNCERTAINTY), 0.000001)) {

                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(pixel.getRow())
                    .append(",")
                    .append(pixel.getColumn())
                    .append("\t");
                output.append(taskValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(taskValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(taskValues.get(CALIBRATED_UNCERTAINTY))
                    .append(" ")
                    .append(taskValues.get(BACKGROUND_VALUE))
                    .append(" ")
                    .append(taskValues.get(BACKGROUND_UNCERTAINTY))
                    .append("\t");
                output.append(fitsValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_UNCERTAINTY))
                    .append(" ")
                    .append(fitsValues.get(BACKGROUND_VALUE))
                    .append(" ")
                    .append(fitsValues.get(BACKGROUND_UNCERTAINTY))
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                taskPixelValuesByPixel.size(), (double) errorCount
                    / taskPixelValuesByPixel.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskPixelValuesByPixel.size(), type.toLowerCase()));
        }

        if (taskPixelValuesByPixel.size() != fitsPixelValuesByPixel.size()) {
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskPixelValuesByPixel.size(), type.toLowerCase(),
                fitsPixelValuesByPixel.size()));
            equals = false;
        }

        return equals;
    }
}
