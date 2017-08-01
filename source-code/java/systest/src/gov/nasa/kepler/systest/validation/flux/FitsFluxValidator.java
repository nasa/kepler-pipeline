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

package gov.nasa.kepler.systest.validation.flux;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.PdcBand;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.uow.ModOutBinner;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pdc.PdcGoodnessComponent;
import gov.nasa.kepler.pdc.PdcGoodnessMetric;
import gov.nasa.kepler.systest.validation.ArExtractor;
import gov.nasa.kepler.systest.validation.CompoundDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.CompoundTimeSeriesType;
import gov.nasa.kepler.systest.validation.FitsAperture;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FitsValidationOptions.Command;
import gov.nasa.kepler.systest.validation.FluxConverter;
import gov.nasa.kepler.systest.validation.PaExtractor;
import gov.nasa.kepler.systest.validation.PdcExtractor;
import gov.nasa.kepler.systest.validation.SimpleIntTimeSeriesType;
import gov.nasa.kepler.systest.validation.SimpleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.kepler.systest.validation.pixels.CalExtractor;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.TreeSet;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * FITS flux validator.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class FitsFluxValidator {

    private static final int RANDOM_SEED = 1843960572;

    private static final Log log = LogFactory.getLog(FitsFluxValidator.class);

    private static final String NUMBAND_KEYWORD = "NUMBAND";
    private static final String NSPSDDET_KEYWORD = "NSPSDDET";
    private static final String NSPSDCOR_KEYWORD = "NSPSDCOR";
    private static final String PDCMETHD_KEYWORD = "PDCMETHD";
    private static final String PDCVAR_KEYWORD = "PDCVAR";
    private static final String FITTYPE = "FITTYPE%d";
    private static final String PR_WGHT = "PR_WGHT%d";
    private static final String PR_GOOD = "PR_GOOD%d";
    private static final List<String> PDC_PROCESSING_INT_KEYWORDS = Arrays.asList(
        NSPSDDET_KEYWORD, NSPSDCOR_KEYWORD, NUMBAND_KEYWORD);
    private static final List<String> PDC_PROCESSING_STRING_KEYWORDS = Arrays.asList(PDCMETHD_KEYWORD);
    private static final List<String> PDC_PROCESSING_FLOAT_KEYWORDS = Arrays.asList(PDCVAR_KEYWORD);

    private static final String PDC_COR_KEYWORD = "PDC_COR";
    private static final String PDC_CORP_KEYWORD = "PDC_CORP";
    private static final String PDC_VAR_KEYWORD = "PDC_VAR";
    private static final String PDC_VARP_KEYWORD = "PDC_VARP";
    private static final String PDC_EPT_KEYWORD = "PDC_EPT";
    private static final String PDC_EPTP_KEYWORD = "PDC_EPTP";
    private static final String PDC_NOI_KEYWORD = "PDC_NOI";
    private static final String PDC_NOIP_KEYWORD = "PDC_NOIP";
    private static final String PDC_TOT_KEYWORD = "PDC_TOT";
    private static final String PDC_TOTP_KEYWORD = "PDC_TOTP";
    private static final List<String> PDC_GOODNESS_FLOAT_KEYWORDS = Arrays.asList(
        PDC_COR_KEYWORD, PDC_CORP_KEYWORD, PDC_VAR_KEYWORD, PDC_VARP_KEYWORD,
        PDC_EPT_KEYWORD, PDC_EPTP_KEYWORD, PDC_NOI_KEYWORD, PDC_NOIP_KEYWORD,
        PDC_TOT_KEYWORD, PDC_TOTP_KEYWORD);

    private static final int PSEUDO_TARGET_KEPLER_ID_START = 500000000;

    private FitsValidationOptions options;
    private File fluxDirectory;
    private File tasksRootDirectory;

    public FitsFluxValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        if (options.getCommand() != Command.VALIDATE_FLUX) {
            throw new IllegalStateException("Unexpected command "
                + options.getCommand()
                    .getName());
        }
        if (options.getArId() == -1) {
            throw new UsageException("AR pipeline instance ID not set");
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

        if (options.getFluxDirectory() == null) {
            throw new UsageException("Flux directory not set");
        }
        fluxDirectory = new File(options.getFluxDirectory());
        if (!ValidationUtils.directoryReadable(fluxDirectory, "Flux directory")) {
            throw new UsageException("Can't read flux directory "
                + fluxDirectory);
        }

        if (options.getTasksRootDirectory() == null) {
            throw new UsageException("Tasks root directory not set");
        }
        tasksRootDirectory = new File(options.getTasksRootDirectory());
        if (!ValidationUtils.directoryReadable(tasksRootDirectory,
            "tasks root directory")) {
            throw new UsageException("Can't read tasks root directory "
                + tasksRootDirectory);
        }

        if (options.getTargetSkipCount() < 0) {
            throw new UsageException("Target skip count can't be negative");
        }

        if (options.getMaxErrorsDisplayed() < 0) {
            throw new UsageException("Max errors displayed can't be negative");
        }
    }

    public void validate() throws FitsException, IOException,
        ValidationException {

        int startCadence = options.getCadenceRange().left;
        int endCadence = options.getCadenceRange().right;
        CadenceType cadenceType = ValidationUtils.getCadenceType(options.getPaId());
        MjdToCadence mjdToCadence = new MjdToCadence(cadenceType,
            new ModelMetadataRetrieverLatest());
        TimestampSeries cadenceTimes = mjdToCadence.cadenceTimes(startCadence,
            endCadence);

        List<ConfigMap> configMaps = new ConfigMapOperations().retrieveConfigMaps(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());
        FluxConverter fluxConverter = new FluxConverter(configMaps, cadenceType);

        Set<FluxUowTask> fluxUowTasks = createTasks(options.getCcdModule(),
            options.getCcdOutput());

        boolean failed = false;
        for (FluxUowTask fluxUowTask : fluxUowTasks) {
            Map<Integer, Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries>> simpleIntTimeSeriesByKeplerId = new HashMap<Integer, Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries>>();
            Map<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>> simpleTimeSeriesByKeplerId = new HashMap<Integer, Map<SimpleTimeSeriesType, SimpleFloatTimeSeries>>();
            Map<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>> compoundTimeSeriesByKeplerId = new HashMap<Integer, Map<CompoundTimeSeriesType, CompoundFloatTimeSeries>>();
            Map<Integer, Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>> doubleTimeSeriesByKeplerId = new HashMap<Integer, Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>>();

            FitsFluxExtractor fitsFluxExtractor = new FitsFluxExtractor(
                cadenceType, fluxUowTask.getCcdModule(),
                fluxUowTask.getCcdOutput(), fluxDirectory);

            CalExtractor calExtractor = new CalExtractor(options.getCalId(),
                fluxUowTask.getCcdModule(), fluxUowTask.getCcdOutput(),
                tasksRootDirectory, options.isCacheEnabled());

            PdcExtractor pdcExtractor = new PdcExtractor(options.getPdcId(),
                fluxUowTask.getCcdModule(), fluxUowTask.getCcdOutput(),
                tasksRootDirectory);
            pdcExtractor.extractTimeSeries(compoundTimeSeriesByKeplerId);

            PaExtractor paExtractor = new PaExtractor(options.getPaId(),
                fluxUowTask.getCcdModule(), fluxUowTask.getCcdOutput(),
                tasksRootDirectory, options.isCacheEnabled());
            paExtractor.extractTimeSeries(simpleTimeSeriesByKeplerId,
                compoundTimeSeriesByKeplerId, doubleTimeSeriesByKeplerId);

            int offset = fitsFluxExtractor.extractCadenceOffset(startCadence,
                compoundTimeSeriesByKeplerId.keySet()
                    .iterator()
                    .next());

            List<Integer> argabrighteningIndices = new ArrayList<Integer>();
            paExtractor.extractArgabrighteningIndices(offset,
                argabrighteningIndices);

            List<Integer> reactionWheelZeroCrossingIndices = new ArrayList<Integer>();
            paExtractor.extractReactionWheelZeroCrossingIndices(offset,
                reactionWheelZeroCrossingIndices);

            Map<Integer, Set<Pair<Integer, Integer>>> pixelsInPrfCentroidApertureByKeplerId = new HashMap<Integer, Set<Pair<Integer, Integer>>>();
            Map<Integer, Set<Pair<Integer, Integer>>> pixelsInFluxWeightedCentroidApertureByKeplerId = new HashMap<Integer, Set<Pair<Integer, Integer>>>();
            paExtractor.extractPixelsInCentroidAperture(
                pixelsInPrfCentroidApertureByKeplerId,
                pixelsInFluxWeightedCentroidApertureByKeplerId);

            Map<Integer, PdcProcessingCharacteristics> pdcProcessingCharacteristicsByKeplerId = new HashMap<Integer, PdcProcessingCharacteristics>();
            pdcExtractor.extractProcessingCharacteristics(pdcProcessingCharacteristicsByKeplerId);

            Map<Integer, PdcGoodnessMetric> pdcGoodnessMetricByKeplerId = new HashMap<Integer, PdcGoodnessMetric>();
            pdcExtractor.extractGoodnessMetric(pdcGoodnessMetricByKeplerId);

            ArExtractor arExtractor = new ArExtractor(options.getArId(),
                fluxUowTask.getCcdModule(), fluxUowTask.getCcdOutput(),
                tasksRootDirectory, "fluxExporter2");
            arExtractor.extractDvaMotion(simpleTimeSeriesByKeplerId);
            arExtractor.extractTimeCorrection(simpleTimeSeriesByKeplerId);

            log.debug(String.format(
                "Extracted %s cadence time series for %d targets",
                cadenceType.toString()
                    .toLowerCase(), compoundTimeSeriesByKeplerId.size()));

            TargetTable targetTable = ValidationUtils.getTargetTable(
                cadenceType, startCadence, endCadence);

            int count = 0;

            Integer[] keySet = compoundTimeSeriesByKeplerId.keySet()
                .toArray(new Integer[0]);
            for (int i = 0; i < keySet.length; i += options.getTargetSkipCount() + 1) {
                int keplerId = keySet[i];
                // TODO Remove once pseudo targets are exported.
                if (keplerId >= PSEUDO_TARGET_KEPLER_ID_START) {
                    log.debug("skipping pseudo target with keplerId "
                        + keplerId);
                    i -= options.getTargetSkipCount();
                    continue;
                } else if (TargetManagementConstants.isCustomTarget(keplerId)
                    && fitsFluxExtractor.getFitsFile(keplerId) == null) {
                    log.warn("skipping custom target, keplerId " + keplerId
                        + ", with no light curve");
                    i -= options.getTargetSkipCount();
                    continue;
                }

                FitsAperture fitsAperture = new FitsAperture();
                if (!extractAperture(keplerId, targetTable, fitsFluxExtractor,
                    pixelsInPrfCentroidApertureByKeplerId,
                    pixelsInFluxWeightedCentroidApertureByKeplerId,
                    fitsAperture)) {
                    failed = true;
                }

                Set<Integer> apertureRowProjection = new HashSet<Integer>();
                Set<Integer> apertureColumnProjection = new HashSet<Integer>();
                ValidationUtils.extractOptimalApertureProjections(fitsAperture,
                    apertureRowProjection, apertureColumnProjection);

                ValidationUtils.validateTimes(
                    options.getMaxErrorsDisplayed(),
                    keplerId,
                    startCadence,
                    endCadence,
                    cadenceTimes,
                    paExtractor.getCadenceRange(),
                    simpleTimeSeriesByKeplerId.get(keplerId),
                    fitsFluxExtractor.extractTimeCorrection(keplerId),
                    fitsFluxExtractor.extractTimeSimpleDoubleTimeSeries(keplerId));

                PdcProcessingCharacteristics fitsPdcProcessingCharacteristics = extractPdcProcessingCharacteristics(
                    keplerId, fitsFluxExtractor);

                PdcGoodnessMetric fitsPdcGoodnessMetric = extractPdcGoodnessMetric(
                    keplerId, fitsFluxExtractor);

                Map<PdcExtractor.PdcFlag, SimpleFloatTimeSeries> timeSeriesByPdcFlagType = new HashMap<PdcExtractor.PdcFlag, SimpleFloatTimeSeries>();
                pdcExtractor.extractDiscontinuityOutlier(offset, endCadence
                    - startCadence + 1, keplerId, timeSeriesByPdcFlagType);

                Map<Pair<Integer, Integer>, List<Double>> cosmicRaysByRowColumn = new HashMap<Pair<Integer, Integer>, List<Double>>();
                paExtractor.extractCosmicRays(fitsAperture,
                    cosmicRaysByRowColumn);

                Set<Integer> cadencesWithCosmicRays = new HashSet<Integer>();
                for (List<Double> cosmicRayMjds : cosmicRaysByRowColumn.values()) {
                    for (Double mjd : cosmicRayMjds) {
                        cadencesWithCosmicRays.add(mjdToCadence.mjdToCadence(mjd));
                    }
                }

                Map<Pair<CollateralType, Integer>, List<Double>> collateralCosmicRaysByTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Double>>();
                calExtractor.extractCosmicRayMjds(startCadence,
                    apertureRowProjection, apertureColumnProjection,
                    collateralCosmicRaysByTypeOffset);

                Set<Integer> cadencesWithCollateralCosmicRays = new HashSet<Integer>();
                for (List<Double> cosmicRayMjds : collateralCosmicRaysByTypeOffset.values()) {
                    for (Double mjd : cosmicRayMjds) {
                        cadencesWithCollateralCosmicRays.add(mjdToCadence.mjdToCadence(mjd));
                    }
                }

                int[] qualityValues = new int[cadenceTimes.cadenceNumbers.length];
                for (int cadence = startCadence; cadence <= endCadence; cadence++) {
                    qualityValues[cadence - startCadence] = ValidationUtils.assembleQualityFlags(
                        startCadence, cadence, cadenceTimes, null,
                        cadencesWithCosmicRays,
                        cadencesWithCollateralCosmicRays,
                        argabrighteningIndices, timeSeriesByPdcFlagType,
                        reactionWheelZeroCrossingIndices);
                }

                SimpleIntTimeSeries quality = new SimpleIntTimeSeries(
                    qualityValues,
                    new boolean[cadenceTimes.cadenceNumbers.length]);
                Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries> simpleIntTimeSeriesByType = new HashMap<SimpleIntTimeSeriesType, SimpleIntTimeSeries>();
                simpleIntTimeSeriesByType.put(
                    SimpleIntTimeSeriesType.SAP_QUALITY, quality);
                simpleIntTimeSeriesByKeplerId.put(keplerId,
                    simpleIntTimeSeriesByType);

                if (!diffPdcProcessingCharacteristics(keplerId,
                    pdcProcessingCharacteristicsByKeplerId.get(keplerId),
                    fitsPdcProcessingCharacteristics)) {
                    failed = true;
                }
                if (!diffPdcGoodnessMetric(
                    keplerId,
                    ValidationUtils.massageNaNs(
                        pdcGoodnessMetricByKeplerId.get(keplerId), 0.0F),
                    fitsPdcGoodnessMetric)) {
                    failed = true;
                }
                if (validateSimpleIntTimeSeries(keplerId, startCadence,
                    endCadence, paExtractor.getCadenceRange(),
                    simpleIntTimeSeriesByKeplerId.get(keplerId),
                    fitsFluxExtractor.extractSimpleIntTimeSeries(keplerId))) {
                    failed = true;
                }
                if (validateSimpleTimeSeries(keplerId, startCadence,
                    endCadence, paExtractor.getCadenceRange(),
                    simpleTimeSeriesByKeplerId.get(keplerId),
                    fitsFluxExtractor.extractSimpleTimeSeries(keplerId))) {
                    failed = true;
                }
                if (validateCompoundTimeSeries(fluxConverter, keplerId,
                    startCadence, endCadence, paExtractor.getCadenceRange(),
                    compoundTimeSeriesByKeplerId.get(keplerId),
                    fitsFluxExtractor.extractCompoundTimeSeries(keplerId))) {
                    failed = true;
                }
                if (validateCompoundDoubleTimeSeries(keplerId, startCadence,
                    endCadence, paExtractor.getCadenceRange(),
                    doubleTimeSeriesByKeplerId.get(keplerId),
                    fitsFluxExtractor.extractDoubleTimeSeries(keplerId))) {
                    failed = true;
                }
                if (++count % 1000 == 0) {
                    log.info(String.format("Processed %d targets", count));
                }
            }
            log.info(String.format("%s %d targets for module/output %d/%d",
                failed ? "Processed" : "Validated", count,
                fluxUowTask.getCcdModule(), fluxUowTask.getCcdOutput()));
        }

        if (failed) {
            throw new ValidationException("Task and FITS files differ; see log");
        }
    }

    private boolean extractAperture(
        int keplerId,
        TargetTable targetTable,
        FitsFluxExtractor fluxExtractor,
        Map<Integer, Set<Pair<Integer, Integer>>> pixelsInPrfCentroidApertureByKeplerId,
        Map<Integer, Set<Pair<Integer, Integer>>> pixelsInFluxWeightedCentroidApertureByKeplerId,
        FitsAperture fitsAperture) throws FitsException, IOException {

        if (!fluxExtractor.extractAperture(keplerId, fitsAperture)) {
            log.error(String.format(
                "Failed to extract flux aperture for keplerId %d", keplerId));
            return false;
        }

        FitsAperture observedTargetAperture = new FitsAperture();
        if (!ValidationUtils.getObservedTargetAperture(keplerId, targetTable,
            pixelsInPrfCentroidApertureByKeplerId,
            pixelsInFluxWeightedCentroidApertureByKeplerId,
            observedTargetAperture)) {
            log.error(String.format(
                "Failed to acquire observed target aperture for keplerId %d",
                keplerId));
            return false;
        }

        if (!fitsAperture.equals(observedTargetAperture)) {
            log.error(String.format(
                "Flux aperture differs from TAD aperture for keplerId %d",
                keplerId));
            return false;
        }

        return true;
    }

    private PdcProcessingCharacteristics extractPdcProcessingCharacteristics(
        int keplerId, FitsFluxExtractor fitsFluxExtractor)
        throws FitsException, IOException {

        Map<String, Integer> intValueByKeyword = new HashMap<String, Integer>();
        Set<String> intKeywords = new HashSet<String>(
            PDC_PROCESSING_INT_KEYWORDS);
        fitsFluxExtractor.extractIntKeywords(keplerId, intKeywords,
            intValueByKeyword);

        Map<String, String> stringValueByKeyword = new HashMap<String, String>();
        Set<String> stringKeywords = new HashSet<String>(
            PDC_PROCESSING_STRING_KEYWORDS);
        Map<String, Float> floatValueByKeyword = new HashMap<String, Float>();
        Set<String> floatKeywords = new HashSet<String>(
            PDC_PROCESSING_FLOAT_KEYWORDS);
        int numBand = intValueByKeyword.get(NUMBAND_KEYWORD);
        for (int band = 1; band <= numBand; band++) {
            stringKeywords.add(String.format(FITTYPE, band));
            floatKeywords.add(String.format(PR_GOOD, band));
            floatKeywords.add(String.format(PR_WGHT, band));
        }
        fitsFluxExtractor.extractStringKeywords(keplerId, stringKeywords,
            stringValueByKeyword);
        fitsFluxExtractor.extractFloatKeywords(keplerId, floatKeywords,
            floatValueByKeyword);

        List<PdcBand> bands = new ArrayList<PdcBand>();
        for (int band = 1; band <= numBand; band++) {
            bands.add(new PdcBand(stringValueByKeyword.get(String.format(
                FITTYPE, band)), floatValueByKeyword.get(
                String.format(PR_WGHT, band))
                .floatValue(), floatValueByKeyword.get(
                String.format(PR_GOOD, band))
                .floatValue()));
        }
        return new PdcProcessingCharacteristics(
            stringValueByKeyword.get(PDCMETHD_KEYWORD), intValueByKeyword.get(
                NSPSDDET_KEYWORD)
                .intValue(), intValueByKeyword.get(NSPSDCOR_KEYWORD)
                .intValue(), false, false, floatValueByKeyword.get(
                PDCVAR_KEYWORD)
                .floatValue(), bands);
    }

    private boolean diffPdcProcessingCharacteristics(int keplerId,
        PdcProcessingCharacteristics taskCharacteristics,
        PdcProcessingCharacteristics fitsCharacteristics) {

        boolean equals = true;
        if (taskCharacteristics == null) {
            log.error(String.format(
                "Missing task PdcProcessingCharecteristics for keplerId %d",
                keplerId));
            return false;
        }
        if (fitsCharacteristics == null) {
            log.error(String.format(
                "Missing FITS PdcProcessingCharecteristics for keplerId %d",
                keplerId));
            return false;
        }

        if (!diffString("PDC method", keplerId,
            taskCharacteristics.getPdcMethod(),
            fitsCharacteristics.getPdcMethod())) {
            equals = false;
        }
        if (!diffInt("number discontinuties detected", keplerId,
            taskCharacteristics.getNumDiscontinuitiesDetected(),
            fitsCharacteristics.getNumDiscontinuitiesDetected())) {
            equals = false;
        }
        if (!diffInt("number discontinuties removed", keplerId,
            taskCharacteristics.getNumDiscontinuitiesRemoved(),
            fitsCharacteristics.getNumDiscontinuitiesRemoved())) {
            equals = false;
        }
        if (!diffBoolean("harmonics fitted", keplerId,
            taskCharacteristics.isHarmonicsFitted(),
            fitsCharacteristics.isHarmonicsFitted())) {
            equals = false;
        }
        if (!diffBoolean("harmonics restored", keplerId,
            taskCharacteristics.isHarmonicsRestored(),
            fitsCharacteristics.isHarmonicsRestored())) {
            equals = false;
        }
        if (!diffFloat("target variability", keplerId,
            taskCharacteristics.getTargetVariability(),
            fitsCharacteristics.getTargetVariability())) {
            equals = false;
        }

        if (!diffInt("number of bands", keplerId,
            taskCharacteristics.getBands()
                .size(), fitsCharacteristics.getBands()
                .size())) {

        }
        for (int band = 0; band < taskCharacteristics.getBands()
            .size(); band++) {
            if (!diffString("band " + band + " fit type", keplerId,
                taskCharacteristics.getBands()
                    .get(band)
                    .getFitType(), fitsCharacteristics.getBands()
                    .get(band)
                    .getFitType())) {
                equals = false;
            }
            if (!diffFloat("band " + band + " prior goodness", keplerId,
                taskCharacteristics.getBands()
                    .get(band)
                    .getPriorGoodness(), fitsCharacteristics.getBands()
                    .get(band)
                    .getPriorGoodness())) {
                equals = false;
            }
            if (!diffFloat("band " + band + " prior weight", keplerId,
                taskCharacteristics.getBands()
                    .get(band)
                    .getPriorWeight(), fitsCharacteristics.getBands()
                    .get(band)
                    .getPriorWeight())) {
                equals = false;
            }
        }

        return equals;
    }

    private PdcGoodnessMetric extractPdcGoodnessMetric(int keplerId,
        FitsFluxExtractor fitsFluxExtractor) throws FitsException, IOException {

        Map<String, Float> floatValueByKeyword = new HashMap<String, Float>();
        Set<String> floatKeywords = new HashSet<String>(
            PDC_GOODNESS_FLOAT_KEYWORDS);
        fitsFluxExtractor.extractFloatKeywords(keplerId, floatKeywords,
            floatValueByKeyword);

        PdcGoodnessComponent correlation = new PdcGoodnessComponent(
            floatValueByKeyword.get(PDC_COR_KEYWORD),
            floatValueByKeyword.get(PDC_CORP_KEYWORD));
        PdcGoodnessComponent deltaVariability = new PdcGoodnessComponent(
            floatValueByKeyword.get(PDC_VAR_KEYWORD),
            floatValueByKeyword.get(PDC_VARP_KEYWORD));
        PdcGoodnessComponent earthPointRemoval = new PdcGoodnessComponent(
            floatValueByKeyword.get(PDC_EPT_KEYWORD),
            floatValueByKeyword.get(PDC_EPTP_KEYWORD));
        PdcGoodnessComponent introducedNoise = new PdcGoodnessComponent(
            floatValueByKeyword.get(PDC_NOI_KEYWORD),
            floatValueByKeyword.get(PDC_NOIP_KEYWORD));
        PdcGoodnessComponent total = new PdcGoodnessComponent(
            floatValueByKeyword.get(PDC_TOT_KEYWORD),
            floatValueByKeyword.get(PDC_TOTP_KEYWORD));

        return new PdcGoodnessMetric(correlation, deltaVariability,
            earthPointRemoval, introducedNoise, total);
    }

    private boolean diffPdcGoodnessMetric(int keplerId,
        PdcGoodnessMetric taskMetric, PdcGoodnessMetric fitsMetric) {

        boolean equals = true;
        if (taskMetric == null) {
            log.error(String.format(
                "Missing task PdcGoodnessMetric for keplerId %d", keplerId));
            return false;
        }
        if (fitsMetric == null) {
            log.error(String.format(
                "Missing FITS PdcGoodnessMetric for keplerId %d", keplerId));
            return false;
        }

        if (!diffFloat("target correlation goodness metric", keplerId,
            taskMetric.getCorrelation()
                .getValue(), fitsMetric.getCorrelation()
                .getValue())) {
            equals = false;
        }
        if (!diffFloat("target correlation percentile goodness metric",
            keplerId, taskMetric.getCorrelation()
                .getPercentile(), fitsMetric.getCorrelation()
                .getPercentile())) {
            equals = false;
        }
        if (!diffFloat("target delta variability goodness metric", keplerId,
            taskMetric.getDeltaVariability()
                .getValue(), fitsMetric.getDeltaVariability()
                .getValue())) {
            equals = false;
        }
        if (!diffFloat("target delta variability percentile goodness metric",
            keplerId, taskMetric.getDeltaVariability()
                .getPercentile(), fitsMetric.getDeltaVariability()
                .getPercentile())) {
            equals = false;
        }
        if (!diffFloat("target earth point removal goodness metric", keplerId,
            taskMetric.getEarthPointRemoval()
                .getValue(), fitsMetric.getEarthPointRemoval()
                .getValue())) {
            equals = false;
        }
        if (!diffFloat("target earth point removal percentile goodness metric",
            keplerId, taskMetric.getEarthPointRemoval()
                .getPercentile(), fitsMetric.getEarthPointRemoval()
                .getPercentile())) {
            equals = false;
        }
        if (!diffFloat("target introduced noise goodness metric", keplerId,
            taskMetric.getIntroducedNoise()
                .getValue(), fitsMetric.getIntroducedNoise()
                .getValue())) {
            equals = false;
        }
        if (!diffFloat("target introduced noise percentile goodness metric",
            keplerId, taskMetric.getIntroducedNoise()
                .getPercentile(), fitsMetric.getIntroducedNoise()
                .getPercentile())) {
            equals = false;
        }
        if (!diffFloat("target total goodness metric", keplerId,
            taskMetric.getTotal()
                .getValue(), fitsMetric.getTotal()
                .getValue())) {
            equals = false;
        }
        if (!diffFloat("target total percentile goodness metric", keplerId,
            taskMetric.getTotal()
                .getPercentile(), fitsMetric.getTotal()
                .getPercentile())) {
            equals = false;
        }

        return equals;
    }

    private boolean diffString(String type, int keplerId, String taskValue,
        String fitsValue) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ", type));
        output.append("\nKeplerId\tTask file (value)\tFITS file (value)\n");

        if (!taskValue.equals(fitsValue)) {
            equals = false;

            output.append(keplerId)
                .append("\t");
            output.append(taskValue)
                .append("\t");
            output.append(fitsValue)
                .append("\n");
        }

        if (!equals) {
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated 1 %s", type.toLowerCase()));
        }

        return equals;
    }

    private boolean diffBoolean(String type, int keplerId, boolean taskValue,
        boolean fitsValue) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ", type));
        output.append("\nKeplerId\tTask file (value)\tFITS file (value)\n");

        if (taskValue != fitsValue) {
            equals = false;

            output.append(keplerId)
                .append("\t");
            output.append(taskValue)
                .append("\t");
            output.append(fitsValue)
                .append("\n");
        }

        if (!equals) {
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated 1 %s", type.toLowerCase()));
        }

        return equals;
    }

    private boolean diffFloat(String type, int keplerId, float taskValue,
        float fitsValue) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ", type));
        output.append("\nKeplerId\tTask file (value)\tFITS file (value)\n");

        if (!ValidationUtils.floatsEqual(taskValue, fitsValue, 0.000001F)) {
            equals = false;

            output.append(keplerId)
                .append("\t");
            output.append(taskValue)
                .append("\t");
            output.append(fitsValue)
                .append("\n");
        }

        if (!equals) {
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated 1 %s", type.toLowerCase()));
        }

        return equals;
    }

    private boolean diffInt(String type, int keplerId, int taskValue,
        int fitsValue) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ", type));
        output.append("\nKeplerId\tTask file (value)\tFITS file (value)\n");

        if (taskValue != fitsValue) {
            equals = false;

            output.append(keplerId)
                .append("\t");
            output.append(taskValue)
                .append("\t");
            output.append(fitsValue)
                .append("\n");
        }

        if (!equals) {
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated 1 %s", type.toLowerCase()));
        }

        return equals;
    }

    private boolean validateSimpleIntTimeSeries(int keplerId, int startCadence,
        int endCadence, Pair<Integer, Integer> paCadenceRange,
        Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries> taskTimeSeriesByType,
        Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries> fitsTimeSeriesByType) {

        boolean failed = false;

        for (SimpleIntTimeSeriesType type : SimpleIntTimeSeriesType.values()) {
            SimpleIntTimeSeries taskTimeSeries = taskTimeSeriesByType.get(type);
            if (taskTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in task files for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            taskTimeSeries = ValidationUtils.resizeSimpleIntTimeSeries(
                startCadence, endCadence, paCadenceRange, taskTimeSeries);
            SimpleIntTimeSeries fitsTimeSeries = fitsTimeSeriesByType.get(type);
            if (fitsTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in FITS file for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            fitsTimeSeries = ValidationUtils.resizeSimpleIntTimeSeries(
                startCadence, endCadence, paCadenceRange, fitsTimeSeries);
            if (taskTimeSeries.getValues().length != fitsTimeSeries.getValues().length) {
                log.error(String.format(
                    "Time series of type %s for Kepler ID %d "
                        + "has %d values in task file "
                        + "and %d values in FITS file", type, keplerId,
                    taskTimeSeries.getValues().length,
                    fitsTimeSeries.getValues().length));
                failed = true;
            }
            if (!ValidationUtils.diffSimpleIntTimeSeries(
                options.getMaxErrorsDisplayed(), type.toString(), keplerId,
                taskTimeSeries, fitsTimeSeries)) {
                failed = true;
            }
        }

        return failed;
    }

    private boolean validateSimpleTimeSeries(int keplerId, int startCadence,
        int endCadence, Pair<Integer, Integer> paCadenceRange,
        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> taskTimeSeriesByType,
        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> fitsTimeSeriesByType) {

        boolean failed = false;

        for (SimpleTimeSeriesType type : SimpleTimeSeriesType.values()) {
            if (type == SimpleTimeSeriesType.TIME_CORRECTION) {
                // Handled separately.
                continue;
            }

            SimpleFloatTimeSeries taskTimeSeries = taskTimeSeriesByType.get(type);
            if (taskTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in task files for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            taskTimeSeries = ValidationUtils.resizeSimpleTimeSeries(
                startCadence, endCadence, paCadenceRange, taskTimeSeries);

            SimpleFloatTimeSeries fitsTimeSeries = fitsTimeSeriesByType.get(type);
            if (fitsTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in FITS file for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            fitsTimeSeries = ValidationUtils.resizeSimpleTimeSeries(
                startCadence, endCadence, paCadenceRange, fitsTimeSeries);
            if (taskTimeSeries.getValues().length != fitsTimeSeries.getValues().length) {
                log.error(String.format(
                    "Time series of type %s for Kepler ID %d "
                        + "has %d values in task file "
                        + "and %d values in FITS file", type, keplerId,
                    taskTimeSeries.getValues().length,
                    fitsTimeSeries.getValues().length));
                failed = true;
            }

            if (!ValidationUtils.diffSimpleTimeSeries(
                options.getMaxErrorsDisplayed(), type.toString(), keplerId,
                taskTimeSeries, fitsTimeSeries)) {
                failed = true;
            }
        }

        return failed;
    }

    private boolean validateCompoundTimeSeries(
        FluxConverter fluxConverter,
        int keplerId,
        int startCadence,
        int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        Map<CompoundTimeSeriesType, CompoundFloatTimeSeries> taskTimeSeriesByType,
        Map<CompoundTimeSeriesType, CompoundFloatTimeSeries> fitsTimeSeriesByType) {

        boolean failed = false;

        for (CompoundTimeSeriesType type : CompoundTimeSeriesType.values()) {
            CompoundFloatTimeSeries taskTimeSeries = taskTimeSeriesByType.get(type);
            if (taskTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in task files for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            taskTimeSeries = ValidationUtils.resizeCompoundTimeSeries(
                startCadence, endCadence, paCadenceRange, taskTimeSeries);

            CompoundFloatTimeSeries fitsTimeSeries = fitsTimeSeriesByType.get(type);
            if (fitsTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in FITS file for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            fitsTimeSeries = ValidationUtils.resizeCompoundTimeSeries(
                startCadence, endCadence, paCadenceRange, fitsTimeSeries);
            if (taskTimeSeries.getValues().length != fitsTimeSeries.getValues().length) {
                log.error(String.format(
                    "Time series of type %s for Kepler ID %d "
                        + "has %d values in task file "
                        + "and %d values in FITS file", type, keplerId,
                    taskTimeSeries.getValues().length,
                    fitsTimeSeries.getValues().length));
                failed = true;
            }

            taskTimeSeries = convertCompoundTimeSeries(fluxConverter,
                taskTimeSeries);

            if (!ValidationUtils.diffCompoundTimeSeries(
                options.getMaxErrorsDisplayed(), type.toString(), keplerId,
                taskTimeSeries, fitsTimeSeries)) {
                failed = true;
            }
        }

        return failed;
    }

    private CompoundFloatTimeSeries convertCompoundTimeSeries(
        FluxConverter fluxConverter, CompoundFloatTimeSeries taskTimeSeries) {

        float[] newValues = new float[taskTimeSeries.size()];
        float[] newUncertainties = new float[taskTimeSeries.size()];
        for (int i = 0; i < taskTimeSeries.size(); i++) {
            newValues[i] = fluxConverter.fluxPerCadenceToFluxPerSecond(taskTimeSeries.getValues()[i]);
            newUncertainties[i] = fluxConverter.fluxPerCadenceToFluxPerSecond(taskTimeSeries.getUncertainties()[i]);
        }

        return new CompoundFloatTimeSeries(newValues, newUncertainties,
            taskTimeSeries.getGapIndicators());
    }

    private boolean validateCompoundDoubleTimeSeries(
        int keplerId,
        int startCadence,
        int endCadence,
        Pair<Integer, Integer> paCadenceRange,
        Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries> taskTimeSeriesByType,
        Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries> fitsTimeSeriesByType) {

        boolean failed = false;

        for (CompoundDoubleTimeSeriesType type : CompoundDoubleTimeSeriesType.values()) {
            CompoundDoubleTimeSeries taskTimeSeries = taskTimeSeriesByType.get(type);
            if (taskTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in task files for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            taskTimeSeries = ValidationUtils.resizeCompoundDoubleTimeSeries(
                startCadence, endCadence, paCadenceRange, taskTimeSeries);

            CompoundDoubleTimeSeries fitsTimeSeries = fitsTimeSeriesByType.get(type);
            if (fitsTimeSeries == null) {
                log.warn(String.format(
                    "No time series of type %s in FITS file for Kepler ID %d",
                    type, keplerId));
                continue;
            }
            fitsTimeSeries = ValidationUtils.resizeCompoundDoubleTimeSeries(
                startCadence, endCadence, paCadenceRange, fitsTimeSeries);

            if (taskTimeSeries.getValues().length != fitsTimeSeries.getValues().length) {
                log.error(String.format(
                    "Time series of type %s for Kepler ID %d "
                        + "has %d values in task file "
                        + "and %d values in FITS file", type, keplerId,
                    taskTimeSeries.getValues().length,
                    fitsTimeSeries.getValues().length));
                failed = true;
            }

            if (!ValidationUtils.diffCompoundDoubleTimeSeries(
                options.getMaxErrorsDisplayed(), type.toString(), keplerId,
                taskTimeSeries, fitsTimeSeries)) {
                failed = true;
            }
        }

        return failed;
    }

    private static Set<FluxUowTask> createTasks(int ccdModule, int ccdOutput) {

        ModuleOutputListsParameters modOutLists = new ModuleOutputListsParameters();
        if (ccdModule > 0 && ccdOutput > 0) {
            modOutLists.setChannelIncludeArray(new int[] { FcConstants.getHdu(
                ccdModule, ccdOutput) });
        }

        // Set the initial task to an arbitrary valid mod/out. This is
        // acceptable because this task is only used as a template task from
        // which to create other tasks. So, this mod/out is never actually read.
        return new TreeSet<FluxUowTask>(ModOutBinner.subDivide(
            Arrays.asList(new FluxUowTask(2, 1)), modOutLists));
    }

    private static final class FluxUowTask extends ModOutUowTask implements
        Comparable<FluxUowTask> {

        private static final Random RANDOM = new Random(RANDOM_SEED);

        private Integer key;

        public FluxUowTask(int ccdModule, int ccdOutput) {
            super(ccdModule, ccdOutput);
            key = RANDOM.nextInt();
        }

        @Override
        public int compareTo(FluxUowTask other) {

            return key.compareTo(other.key);
        }

        @Override
        public FluxUowTask makeCopy() {

            return new FluxUowTask(getCcdModule(), getCcdOutput());
        }
    }
}
