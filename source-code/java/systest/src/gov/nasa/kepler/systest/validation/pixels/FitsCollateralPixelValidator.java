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

import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_COLLATERAL_PIXELS;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FluxConverter;
import gov.nasa.kepler.systest.validation.PaExtractor;
import gov.nasa.kepler.systest.validation.SimpleDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.SimpleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.kepler.systest.validation.pixels.FitsCollateralPixelExtractor.CollateralBinaryTable;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * FITS collateral pixel validator.
 * 
 * @author Forrest Girouard
 */
public class FitsCollateralPixelValidator {

    private static final int HEARTBEAT_CADENCE_COUNT = 500;

    private static final Log log = LogFactory.getLog(FitsCollateralPixelValidator.class);

    // Indices into Number list that appear in returned maps.
    public static final int ORIGINAL_VALUE = 0;
    public static final int CALIBRATED_VALUE = 1;
    public static final int CALIBRATED_UNCERTAINTY = 2;
    public static final int COSMIC_RAY = 3;

    private FitsValidationOptions options;
    private File pmrfDirectory;
    private File pixelsInputDirectory;
    private File tasksRootDirectory;
    private File collateralPixelsOutputDirectory;

    public FitsCollateralPixelValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();

        FitsCollateralPixelExtractor.clear();
    }

    private void validateOptions() {
        if (options.getCommand() != VALIDATE_COLLATERAL_PIXELS) {
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

        if (options.getCollateralPixelsDirectory() == null) {
            throw new UsageException("Collateral pixels directory not set");
        }
        collateralPixelsOutputDirectory = new File(
            options.getCollateralPixelsDirectory());
        if (!ValidationUtils.directoryReadable(collateralPixelsOutputDirectory,
            "Collateral pixels output directory")) {
            throw new UsageException(
                "Can't read collateral pixels output directory "
                    + collateralPixelsOutputDirectory);
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

        CalExtractor calExtractor = new CalExtractor(options.getCalId(),
            ccdModule, ccdOutput, tasksRootDirectory, options.isCacheEnabled());

        PaExtractor paExtractor = new PaExtractor(options.getPaId(), ccdModule,
            ccdOutput, tasksRootDirectory, options.isCacheEnabled());
        paExtractor.extractTimeSeries(null, null, null);

        FitsCollateralPixelExtractor collateralPixelExtractor = new FitsCollateralPixelExtractor(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, collateralPixelsOutputDirectory);

        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> fitsSimpleTimeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
        Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> fitsSimpleDoubleTimeSeriesByType = new HashMap<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries>();
        if (!collateralPixelExtractor.extractTimeSeries(
            fitsSimpleTimeSeriesByType, fitsSimpleDoubleTimeSeriesByType)) {
            return false;
        }
        SimpleDoubleTimeSeries fitsTimeTimeSeries = fitsSimpleDoubleTimeSeriesByType.get(SimpleDoubleTimeSeriesType.TIME);

        FitsCollateralPixelExtractor blackCollateralPixelExtractor = new FitsCollateralPixelExtractor(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, collateralPixelsOutputDirectory);
        blackCollateralPixelExtractor.extractCollateralValues(CollateralBinaryTable.BLACK);

        FitsCollateralPixelExtractor virtualSmearCollateralPixelExtractor = new FitsCollateralPixelExtractor(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, collateralPixelsOutputDirectory);
        virtualSmearCollateralPixelExtractor.extractCollateralValues(CollateralBinaryTable.VIRTUAL_SMEAR);

        FitsCollateralPixelExtractor maskedSmearCollateralPixelExtractor = new FitsCollateralPixelExtractor(
            ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, collateralPixelsOutputDirectory);
        maskedSmearCollateralPixelExtractor.extractCollateralValues(CollateralBinaryTable.MASKED_SMEAR);

        FitsCollateralPixelExtractor blackMaskedCollateralPixelExtractor = null;
        FitsCollateralPixelExtractor blackVirtualCollateralPixelExtractor = null;
        if (cadenceType == CadenceType.SHORT) {
            blackMaskedCollateralPixelExtractor = new FitsCollateralPixelExtractor(
                ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
                cadenceTimes, collateralPixelsOutputDirectory);
            blackMaskedCollateralPixelExtractor.extractCollateralValues(CollateralBinaryTable.BLACK_MASKED);

            blackVirtualCollateralPixelExtractor = new FitsCollateralPixelExtractor(
                ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
                cadenceTimes, collateralPixelsOutputDirectory);
            blackVirtualCollateralPixelExtractor.extractCollateralValues(CollateralBinaryTable.BLACK_VIRTUAL);
        }

        boolean equals = true;

        if (!validateTimes(options.getMaxErrorsDisplayed(), startCadence,
            endCadence, paExtractor.getCadenceRange(), cadenceTimes,
            fitsTimeTimeSeries)) {
            equals = false;
        }
        int count = 0;

        for (int cadence = startCadence; cadence <= endCadence; cadence += options.getSkipCount() + 1) {
            log.debug(String.format("Validating %s cadence %d in range %d-%d",
                cadenceType.toString()
                    .toLowerCase(), cadence, startCadence, endCadence));

            boolean gapped = false;
            if (cadenceTimes.gapIndicators[cadence - startCadence]) {
                log.info(String.format(
                    "Detected gapped %s cadence %d in range %d-%d",
                    cadenceType.toString()
                        .toLowerCase(), cadence, startCadence, endCadence));
                gapped = true;
            }

            Map<Pair<Integer, Integer>, List<Number>> taskPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<CollateralType, Integer>, List<Number>> taskPixelValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            if (!calExtractor.extractInputPixels(cadence,
                taskPixelValuesByRowColumn,
                taskPixelValuesByCollateralTypeOffset)) {
                continue;
            }
            if (gapped) {
                for (List<Number> values : taskPixelValuesByRowColumn.values()) {
                    if (values.get(ORIGINAL_VALUE)
                        .intValue() != ValidationUtils.MISSING_PIXEL_VALUE) {
                        log.error(String.format(
                            "Task file has values for gapped %s cadence %d in range %d-%d",
                            cadenceType.toString()
                                .toLowerCase(), cadence, startCadence,
                            endCadence));
                        equals = false;
                    }
                }
            }
            Map<Pair<Integer, Integer>, List<Number>> taskOutPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<CollateralType, Integer>, List<Number>> taskOutPixelValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            if (!calExtractor.extractOutputPixels(cadence,
                taskOutPixelValuesByRowColumn,
                taskOutPixelValuesByCollateralTypeOffset)) {
                continue;
            }
            if (gapped) {
                for (List<Number> values : taskOutPixelValuesByRowColumn.values()) {
                    if (values.get(CALIBRATED_VALUE)
                        .floatValue() != ValidationUtils.MISSING_CAL_PIXEL_VALUE) {
                        log.error(String.format(
                            "Task file has values for gapped %s cadence %d in range %d-%d",
                            cadenceType.toString()
                                .toLowerCase(), cadence, startCadence,
                            endCadence));
                        equals = false;
                    }
                }
            }

            Map<Pair<CollateralType, Integer>, List<Number>> taskCollateralValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            mergeCollateralValues(fluxConverter,
                taskPixelValuesByCollateralTypeOffset,
                taskOutPixelValuesByCollateralTypeOffset,
                taskCollateralValuesByCollateralTypeOffset);

            Map<Pair<CollateralType, Integer>, List<Number>> fitsPixelValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            blackCollateralPixelExtractor.extractCadenceSlice(cadence,
                fitsPixelValuesByCollateralTypeOffset);
            virtualSmearCollateralPixelExtractor.extractCadenceSlice(cadence,
                fitsPixelValuesByCollateralTypeOffset);
            maskedSmearCollateralPixelExtractor.extractCadenceSlice(cadence,
                fitsPixelValuesByCollateralTypeOffset);
            if (blackMaskedCollateralPixelExtractor != null) {
                blackMaskedCollateralPixelExtractor.extractCadenceSlice(
                    cadence, fitsPixelValuesByCollateralTypeOffset);
            }
            if (blackVirtualCollateralPixelExtractor != null) {
                blackVirtualCollateralPixelExtractor.extractCadenceSlice(
                    cadence, fitsPixelValuesByCollateralTypeOffset);
            }

            Map<Pair<CollateralType, Integer>, Float> taskCosmicRayByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, Float>();
            if (!gapped
                && !calExtractor.extractCosmicRays(cadence,
                    cadenceTimes.midTimestamps[cadence - startCadence],
                    taskCosmicRayByCollateralTypeOffset)) {
                continue;
            }

            Map<Pair<CollateralType, Integer>, Float> fitsCosmicRayByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, Float>();
            extractCosmicRays(fitsPixelValuesByCollateralTypeOffset,
                fitsCosmicRayByCollateralTypeOffset);

            if (!gapped) {
                if (!diffCollateralData("Collateral pixels", cadence,
                    taskCollateralValuesByCollateralTypeOffset,
                    fitsPixelValuesByCollateralTypeOffset)) {
                    equals = false;
                }

                if (!diffCollateralCosmicRays("Collateral cosmic rays",
                    cadence, fluxConverter,
                    taskCosmicRayByCollateralTypeOffset,
                    fitsCosmicRayByCollateralTypeOffset)) {
                    equals = false;
                }
            }

            if (++count % HEARTBEAT_CADENCE_COUNT == 0) {
                log.info(String.format("Processed %d cadences", count));
            }
        }
        log.info(String.format(
            "%s %d cadences in range %d-%d for module/output %d/%d",
            equals ? "Validated" : "Processed", count, startCadence,
            endCadence, ccdModule, ccdOutput));

        return equals;
    }

    private boolean validateTimes(int maxErrorsDisplayed, int startCadence,
        int endCadence, Pair<Integer, Integer> paCadenceRange,
        TimestampSeries cadenceTimes, SimpleDoubleTimeSeries fitsTimeTimeSeries) {

        SimpleDoubleTimeSeries times = convertTimes(cadenceTimes);
        SimpleDoubleTimeSeries fitsTimes = ValidationUtils.resizeSimpleDoubleTimeSeries(
            startCadence, endCadence, paCadenceRange, fitsTimeTimeSeries);

        if (!ValidationUtils.diffSimpleDoubleTimeSeries(maxErrorsDisplayed,
            SimpleDoubleTimeSeriesType.TIME.toString(), -1, times, fitsTimes)) {
            return false;
        }

        return true;
    }

    private SimpleDoubleTimeSeries convertTimes(TimestampSeries cadenceTimes) {

        double[] times = new double[cadenceTimes.midTimestamps.length];
        System.arraycopy(cadenceTimes.midTimestamps, 0, times, 0, times.length);
        boolean[] gaps = new boolean[cadenceTimes.gapIndicators.length];
        System.arraycopy(cadenceTimes.gapIndicators, 0, gaps, 0, gaps.length);

        return new SimpleDoubleTimeSeries(times, gaps);
    }

    private void extractCosmicRays(
        Map<Pair<CollateralType, Integer>, List<Number>> fitsPixelValuesByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, Float> fitsCosmicRayByCollateralTypeOffset) {

        for (Pair<CollateralType, Integer> collateralTypeOffset : fitsPixelValuesByCollateralTypeOffset.keySet()) {
            Float cosmicRay = (Float) fitsPixelValuesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(COSMIC_RAY);
            if (!Float.isNaN(cosmicRay)) {
                fitsCosmicRayByCollateralTypeOffset.put(collateralTypeOffset,
                    cosmicRay);
            }
        }
    }

    private void mergeCollateralValues(
        FluxConverter fluxConverter,
        Map<Pair<CollateralType, Integer>, List<Number>> taskPixelValuesByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, List<Number>> taskOutPixelValuesByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, List<Number>> taskCollateralValuesByCollateralTypeOffset) {

        for (Pair<CollateralType, Integer> collateralTypeOffset : taskPixelValuesByCollateralTypeOffset.keySet()) {
            List<Number> mergedValues = new ArrayList<Number>();
            mergedValues.add(taskPixelValuesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(ORIGINAL_VALUE));
            mergedValues.add(fluxConverter.fluxPerCadenceToFluxPerSecond((Float) taskOutPixelValuesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(CALIBRATED_VALUE)));
            mergedValues.add(fluxConverter.fluxPerCadenceToFluxPerSecond((Float) taskOutPixelValuesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(CALIBRATED_UNCERTAINTY)));

            // KSOC-2921: FITS now uses NaN for gapped values.
            if ((Float) mergedValues.get(1) == Float.NEGATIVE_INFINITY) {
                List<Number> updatedValues = new ArrayList<Number>();
                updatedValues.add(mergedValues.get(0));
                updatedValues.add(Float.NaN);
                updatedValues.add(Float.NaN);
                mergedValues = updatedValues;
            }

            taskCollateralValuesByCollateralTypeOffset.put(
                collateralTypeOffset, mergedValues);
        }
    }

    private boolean diffCollateralData(
        String type,
        int cadence,
        Map<Pair<CollateralType, Integer>, List<Number>> taskPixelValuesByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, List<Number>> fitsPixelValuesByCollateralTypeOffset) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nGapped uncertainties are -Infinity by convention, not ICD");
        output.append("\nType,Offset\tTask file (orig, value, unc)\tFITS file (orig, value, unc)\n");

        int errorCount = 0;
        for (Pair<CollateralType, Integer> index : taskPixelValuesByCollateralTypeOffset.keySet()) {
            List<Number> taskValues = taskPixelValuesByCollateralTypeOffset.get(index);
            if (taskValues == null) {
                log.error(String.format(
                    "No collateral value in task files for type %s and offset %d",
                    index.left, index.right));
                equals = false;
                continue;
            }
            List<Number> fitsValues = fitsPixelValuesByCollateralTypeOffset.get(index);
            if (fitsValues == null) {
                log.error(String.format(
                    "No collateral value in FITS files for type %s and offset %d",
                    index.left, index.right));
                equals = false;
                continue;
            }
            if (!taskValues.get(ORIGINAL_VALUE)
                .equals(fitsValues.get(ORIGINAL_VALUE))
                || !taskValues.get(CALIBRATED_VALUE)
                    .equals(fitsValues.get(CALIBRATED_VALUE))
                || !taskValues.get(CALIBRATED_UNCERTAINTY)
                    .equals(fitsValues.get(CALIBRATED_UNCERTAINTY))) {

                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(index.left)
                    .append(",")
                    .append(index.right)
                    .append("\t");
                output.append(taskValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(taskValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(taskValues.get(CALIBRATED_UNCERTAINTY))
                    .append("\t");
                output.append(fitsValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_UNCERTAINTY))
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format(
                "%d error%s in %d values (%.2f%%)\n",
                errorCount,
                errorCount > 1 ? "s" : "",
                taskPixelValuesByCollateralTypeOffset.size(),
                (double) errorCount
                    / taskPixelValuesByCollateralTypeOffset.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskPixelValuesByCollateralTypeOffset.size(),
                type.toLowerCase()));
        }

        if (taskPixelValuesByCollateralTypeOffset.size() != fitsPixelValuesByCollateralTypeOffset.size()) {
            if (log.isDebugEnabled()) {
                dumpMapKeys(taskPixelValuesByCollateralTypeOffset,
                    fitsPixelValuesByCollateralTypeOffset);
            }
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskPixelValuesByCollateralTypeOffset.size(),
                type.toLowerCase(),
                fitsPixelValuesByCollateralTypeOffset.size()));
            equals = false;
        }

        return equals;
    }

    private void dumpMapKeys(
        Map<Pair<CollateralType, Integer>, List<Number>> taskPixelValuesByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, List<Number>> fitsPixelValuesByCollateralTypeOffset) {

        log.debug("Task and FITS collateral keys");
        Iterator<Pair<CollateralType, Integer>> taskIterator = taskPixelValuesByCollateralTypeOffset.keySet()
            .iterator();
        Iterator<Pair<CollateralType, Integer>> fitsIterator = fitsPixelValuesByCollateralTypeOffset.keySet()
            .iterator();
        while (taskIterator.hasNext()) {
            String taskString = "-";
            String fitsString = "-";
            taskString = taskIterator.next()
                .toString();
            if (fitsIterator.hasNext()) {
                fitsString = fitsIterator.next()
                    .toString();
            }
            log.debug(taskString + "\t" + fitsString);
        }
    }

    private boolean diffCollateralCosmicRays(
        String type,
        int cadence,
        FluxConverter fluxConverter,
        Map<Pair<CollateralType, Integer>, Float> taskCosmicRayByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, Float> fitsCosmicRayByCollateralTypeOffset) {

        boolean equals = true;
        if (taskCosmicRayByCollateralTypeOffset.isEmpty()
            && fitsCosmicRayByCollateralTypeOffset.isEmpty()) {
            return equals;
        }
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nType,Offset\tTask file (value)\tFITS file (value)\n");

        int errorCount = 0;
        for (Pair<CollateralType, Integer> index : taskCosmicRayByCollateralTypeOffset.keySet()) {
            Float taskValue = fluxConverter.fluxPerCadenceToFluxPerSecond(taskCosmicRayByCollateralTypeOffset.get(index));
            Float fitsValue = fitsCosmicRayByCollateralTypeOffset.get(index);
            if (!taskValue.equals(fitsValue)) {
                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(index.left)
                    .append(",")
                    .append(index.right)
                    .append("\t");
                output.append(taskValue)
                    .append("\t");
                output.append(fitsValue)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                taskCosmicRayByCollateralTypeOffset.size(), (double) errorCount
                    / taskCosmicRayByCollateralTypeOffset.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskCosmicRayByCollateralTypeOffset.size(), type.toLowerCase()));
        }

        if (taskCosmicRayByCollateralTypeOffset.size() != fitsCosmicRayByCollateralTypeOffset.size()) {
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskCosmicRayByCollateralTypeOffset.size(),
                type.toLowerCase(), fitsCosmicRayByCollateralTypeOffset.size()));
            equals = false;
        }

        return equals;
    }
}
