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

import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_BACKGROUND_PIXELS;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.ArExtractor;
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
 * FITS background pixel validator.
 * 
 * @author Forrest Girouard
 */
public class FitsBackgroundPixelValidator {

    private static final Log log = LogFactory.getLog(FitsBackgroundPixelValidator.class);

    private static final int HEARTBEAT_CADENCE_COUNT = 500;

    private FitsValidationOptions options;

    private File backgroundPixelsOutputDirectory;
    private File pixelsInputDirectory;
    private File pmrfDirectory;
    private File tasksRootDirectory;

    public FitsBackgroundPixelValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        if (options.getCommand() != VALIDATE_BACKGROUND_PIXELS) {
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

        if (options.getBackgroundPixelsDirectory() == null) {
            throw new UsageException("Background pixels directory not set");
        }
        backgroundPixelsOutputDirectory = new File(
            options.getBackgroundPixelsDirectory());
        if (!ValidationUtils.directoryReadable(backgroundPixelsOutputDirectory,
            "Background pixels output directory")) {
            throw new UsageException(
                "Can't read background pixels output directory "
                    + backgroundPixelsOutputDirectory);
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
    }

    public void validate() throws ValidationException, FitsException,
        IOException {

        boolean failed = false;

        Set<PixelUowTask> pixelUowTasks = PixelUowTask.createTasks(
            options.getCcdModule(), options.getCcdOutput(),
            options.getCadenceRange(), options.getChunkSize());
        long startTime = System.currentTimeMillis() / 1000;

        for (PixelUowTask pixelUowTask : pixelUowTasks) {
            if (!validate(pixelUowTask.getCcdModule(),
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

    public boolean validate(int ccdModule, int ccdOutput, int startCadence,
        int endCadence) throws FitsException, IOException {

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

        ArExtractor arExtractor = new ArExtractor(options.getArId(), ccdModule,
            ccdOutput, tasksRootDirectory, "backgroundPixelExporter");
        arExtractor.extractTimeCorrection(simpleTimeSeriesByKeplerId);

        FitsBackgroundPixelExtractor backgroundPixelsExtractor = new FitsBackgroundPixelExtractor(
            ccdModule, ccdOutput, startCadence, endCadence, cadenceTimes,
            backgroundPixelsOutputDirectory);

        int offset = backgroundPixelsExtractor.extractCadenceOffset();

        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> fitsSimpleTimeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
        Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> fitsSimpleDoubleTimeSeriesByType = new HashMap<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries>();
        if (!backgroundPixelsExtractor.extractTimeSeries(
            fitsSimpleTimeSeriesByType, fitsSimpleDoubleTimeSeriesByType)) {
            return false;
        }
        SimpleDoubleTimeSeries fitsTimeTimeSeries = fitsSimpleDoubleTimeSeriesByType.get(SimpleDoubleTimeSeriesType.TIME);

        Map<Integer, Pixel> pixelsByIndex = new HashMap<Integer, Pixel>();
        backgroundPixelsExtractor.extractPixelsByIndex(pixelsByIndex);

        Set<Integer> backgroundRowProjection = new HashSet<Integer>();
        Set<Integer> backgroundColumnProjection = new HashSet<Integer>();
        ValidationUtils.extractProjections(pixelsByIndex,
            backgroundRowProjection, backgroundColumnProjection);

        Map<Pair<CollateralType, Integer>, List<Double>> taskCollateralCosmicRaysByTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Double>>();
        calExtractor.extractCosmicRayMjds(startCadence,
            backgroundRowProjection, backgroundColumnProjection,
            taskCollateralCosmicRaysByTypeOffset);

        Set<Integer> cadencesWithCollateralCosmicRays = new HashSet<Integer>();
        for (List<Double> cosmicRayMjds : taskCollateralCosmicRaysByTypeOffset.values()) {
            for (Double mjd : cosmicRayMjds) {
                cadencesWithCollateralCosmicRays.add(mjdToCadence.mjdToCadence(mjd));
            }
        }

        Map<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>> timeSeriesMapByPixel = new HashMap<Pixel, Map<TargetPixelCompoundTimeSeriesType, CompoundDoubleTimeSeries>>();
        arExtractor.extractTimeSeries(timeSeriesMapByPixel);

        List<Integer> argabrighteningIndices = new ArrayList<Integer>();
        paExtractor.extractArgabrighteningIndices(offset,
            argabrighteningIndices);

        List<Integer> reactionWheelZeroCrossingIndices = new ArrayList<Integer>();
        paExtractor.extractReactionWheelZeroCrossingIndices(offset,
            reactionWheelZeroCrossingIndices);

        Set<SimpleIntTimeSeries> simpleIntTimeSeries = new HashSet<SimpleIntTimeSeries>();
        backgroundPixelsExtractor.extractQuality(simpleIntTimeSeries);
        SimpleIntTimeSeries qualityTimeSeries = simpleIntTimeSeries.iterator()
            .next();

        boolean equals = true;

        if (!PixelsValidationUtils.validateTimes(
            options.getMaxErrorsDisplayed(), startCadence, endCadence,
            paExtractor.getCadenceRange(), cadenceTimes, fitsTimeTimeSeries)) {
            equals = false;
        }

        int cadenceCount = 0;
        for (int cadence = startCadence; cadence <= endCadence; cadence += options.getSkipCount() + 1) {
            log.debug(String.format("Validating %s cadence %d in range %d-%d",
                cadenceType.toString()
                    .toLowerCase(), cadence, startCadence, endCadence));

            Map<Pixel, List<Number>> backgroundPixelValuesByPixel = new HashMap<Pixel, List<Number>>();
            backgroundPixelsExtractor.extractPixels(cadence, startCadence,
                pixelsByIndex, backgroundPixelValuesByPixel);

            Map<Pair<Integer, Integer>, List<Number>> backgroundPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            if (!fitsPixelExtractor.extractPixels(cadence, null,
                backgroundPixelValuesByRowColumn, null)) {
                equals = false;
            }

            Map<Pixel, List<Number>> taskPixelValuesByPixel = new HashMap<Pixel, List<Number>>();
            if (!PixelsValidationUtils.extractTaskPixelValuesByPixel(cadence,
                calExtractor, pixelsByIndex, backgroundPixelValuesByRowColumn,
                taskPixelValuesByPixel)) {
                continue;
            }

            Map<Pixel, Float> cosmicRaysByPixel = new HashMap<Pixel, Float>();
            if (!backgroundPixelsExtractor.extractCosmicRays(cadence,
                pixelsByIndex, cosmicRaysByPixel)) {
                equals = false;
            }

            Map<Pair<Integer, Integer>, Float> taskCosmicRaysByRowColumn = new HashMap<Pair<Integer, Integer>, Float>();
            paExtractor.extractCosmicRays(cadence,
                cadenceTimes.midTimestamps[cadence - startCadence],
                new HashMap<Pair<Integer, Integer>, Float>(),
                taskCosmicRaysByRowColumn);

            Map<Pixel, Float> taskCosmicRaysByPixel = PixelsValidationUtils.convertCosmicRaysByRowColumnToByPixel(
                pixelsByIndex, taskCosmicRaysByRowColumn);

            if (!PixelsValidationUtils.diffData(
                options.getMaxErrorsDisplayed(), "Background pixels", cadence,
                fluxConverter, taskCosmicRaysByPixel, taskPixelValuesByPixel,
                backgroundPixelValuesByPixel)) {
                equals = false;
            }

            if (!PixelsValidationUtils.diffCosmicRays(
                options.getMaxErrorsDisplayed(),
                "Background cosmic ray events", cadence, fluxConverter,
                taskCosmicRaysByPixel, cosmicRaysByPixel)) {
                equals = false;
            }

            int qualityFlags = ValidationUtils.assembleQualityFlags(
                startCadence, cadence, cadenceTimes, taskCosmicRaysByPixel,
                new HashSet<Integer>(), cadencesWithCollateralCosmicRays,
                argabrighteningIndices,
                new HashMap<PdcExtractor.PdcFlag, SimpleFloatTimeSeries>(),
                reactionWheelZeroCrossingIndices);

            if (!PixelsValidationUtils.diffQualityFlags("Quality flags",
                cadence, qualityFlags, qualityTimeSeries.getValues()[cadence
                    - startCadence])) {
                equals = false;
            }

            if (++cadenceCount % HEARTBEAT_CADENCE_COUNT == 0) {
                log.info(String.format("Processed %d cadences", cadenceCount));
            }
        }

        log.info(String.format(
            "%s %d cadences in range %d-%d on module/output %d/%d",
            equals ? "Validated" : "Processed", cadenceCount, startCadence,
            endCadence, ccdModule, ccdOutput));

        return equals;
    }
}
