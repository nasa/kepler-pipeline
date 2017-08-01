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

import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.CALIBRATED_UNCERTAINTY;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.CALIBRATED_VALUE;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.ORIGINAL_VALUE;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.PaExtractor;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Map.Entry;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * FITS pixel validator.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class FitsPixelValidator {

    private static final int HEARTBEAT_CADENCE_COUNT = 500;

    private static final Log log = LogFactory.getLog(FitsPixelValidator.class);

    private FitsValidationOptions options;
    private File pmrfDirectory;
    private File pixelsInputDirectory;
    private File pixelsOutputDirectory;
    private File tasksRootDirectory;

    public FitsPixelValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        switch (options.getCommand()) {
            case VALIDATE_PIXELS_IN:
                // Nothing special.
                break;
            case VALIDATE_PIXELS_OUT:
                if (options.getPaId() == -1) {
                    throw new UsageException("PA pipeline instance ID not set");
                }
                if (options.getPixelsOutputDirectory() == null) {
                    throw new UsageException("Pixels output directory not set");
                }
                pixelsOutputDirectory = new File(
                    options.getPixelsOutputDirectory());
                if (!ValidationUtils.directoryReadable(pixelsOutputDirectory,
                    "Pixels output directory")) {
                    throw new UsageException(
                        "Can't read pixels output directory "
                            + pixelsOutputDirectory);
                }
                break;
            default:
                throw new IllegalStateException("Unexpected command "
                    + options.getCommand()
                        .getName());
        }

        if (options.getCalId() == -1) {
            throw new UsageException("CAL pipeline instance ID not set");
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

        if (options.getPmrfDirectory() == null) {
            throw new UsageException("PMRF directory not set");
        }
        pmrfDirectory = new File(options.getPmrfDirectory());
        if (!ValidationUtils.directoryReadable(pmrfDirectory, "PMRF directory")) {
            throw new UsageException("Can't read PMRF directory "
                + pmrfDirectory);
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

        if (options.getTasksRootDirectory() == null) {
            throw new UsageException("Tasks root directory not set");
        }
        tasksRootDirectory = new File(options.getTasksRootDirectory());
        if (!ValidationUtils.directoryReadable(tasksRootDirectory,
            "tasks root directory")) {
            throw new UsageException("Can't read tasks root directory"
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

    public void validate() throws FitsException, IOException,
        ValidationException {

        boolean failed = false;

        Set<PixelUowTask> pixelUowTasks = PixelUowTask.createTasks(
            options.getCcdModule(), options.getCcdOutput(),
            options.getCadenceRange(), options.getChunkSize());
        long startTime = System.currentTimeMillis() / 1000;

        for (PixelUowTask pixelUowTask : pixelUowTasks) {
            switch (options.getCommand()) {
                case VALIDATE_PIXELS_IN:
                    if (!validateIn(pixelUowTask.getCcdModule(),
                        pixelUowTask.getCcdOutput(),
                        pixelUowTask.getStartCadence(),
                        pixelUowTask.getEndCadence())) {
                        failed = true;
                    }
                    break;
                case VALIDATE_PIXELS_OUT:
                    if (!validateOut(pixelUowTask.getCcdModule(),
                        pixelUowTask.getCcdOutput(),
                        pixelUowTask.getStartCadence(),
                        pixelUowTask.getEndCadence())) {
                        failed = true;
                    }
                    break;
                default:
                    throw new IllegalStateException("Unexpected command "
                        + options.getCommand()
                            .getName());
            }
            if (options.getTimeLimit() > 0
                && System.currentTimeMillis() / 1000 - startTime > options.getTimeLimit() * 60) {
                log.info(String.format("%d minute time limit exceeded",
                    options.getTimeLimit()));
                break;
            }
        }

        if (failed) {
            throw new ValidationException("Task and FITS files differ; see log");
        }
    }

    public boolean validateIn(int ccdModule, int ccdOutput, int startCadence,
        int endCadence) throws FitsException, IOException {

        CadenceType cadenceType = ValidationUtils.getCadenceType(options.getCalId());
        TimestampSeries cadenceTimes = new MjdToCadence(cadenceType,
            new ModelMetadataRetrieverLatest()).cadenceTimes(startCadence,
            endCadence);

        CalExtractor calExtractor = new CalExtractor(options.getCalId(),
            ccdModule, ccdOutput, tasksRootDirectory, options.isCacheEnabled());
        FitsPixelExtractor fitsPixelExtractor = new FitsPixelExtractor(
            cadenceTimes, startCadence, cadenceType, ccdModule, ccdOutput,
            pmrfDirectory, pixelsInputDirectory);

        boolean equals = true;
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

            Map<Pair<Integer, Integer>, List<Number>> fitsTargetPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<Integer, Integer>, List<Number>> fitsBackgroundPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<CollateralType, Integer>, List<Number>> fitsPixelValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            if (!fitsPixelExtractor.extractPixels(cadence,
                fitsTargetPixelValuesByRowColumn,
                fitsBackgroundPixelValuesByRowColumn,
                fitsPixelValuesByCollateralTypeOffset)) {
                equals = false;
            }

            Map<Pair<Integer, Integer>, List<Number>> taskTargetPixelValuesByRowColumn = extractTaskPixelValuesByFitsRowColumn(
                taskPixelValuesByRowColumn, fitsTargetPixelValuesByRowColumn);
            Map<Pair<Integer, Integer>, List<Number>> taskBackgroundPixelValuesByRowColumn = extractTaskPixelValuesByFitsRowColumn(
                taskPixelValuesByRowColumn,
                fitsBackgroundPixelValuesByRowColumn);

            if (!gapped) {
                if (!diffData("Target pixels", cadence,
                    taskTargetPixelValuesByRowColumn,
                    fitsTargetPixelValuesByRowColumn)) {
                    equals = false;
                }
                if (!diffData("Background pixels", cadence,
                    taskBackgroundPixelValuesByRowColumn,
                    fitsBackgroundPixelValuesByRowColumn)) {
                    equals = false;
                }
                if (!diffCollateralData("Collateral pixels", cadence,
                    taskPixelValuesByCollateralTypeOffset,
                    fitsPixelValuesByCollateralTypeOffset)) {
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

    public boolean validateOut(int ccdModule, int ccdOutput, int startCadence,
        int endCadence) throws FitsException, IOException {

        CadenceType cadenceType = ValidationUtils.getCadenceType(options.getCalId());
        TimestampSeries cadenceTimes = new MjdToCadence(cadenceType,
            new ModelMetadataRetrieverLatest()).cadenceTimes(startCadence,
            endCadence);

        CalExtractor calExtractor = new CalExtractor(options.getCalId(),
            ccdModule, ccdOutput, tasksRootDirectory, options.isCacheEnabled());
        PaExtractor paExtractor = new PaExtractor(options.getPaId(), ccdModule,
            ccdOutput, tasksRootDirectory, options.isCacheEnabled());
        FitsPixelExtractor fitsInPixelExtractor = new FitsPixelExtractor(
            cadenceTimes, startCadence, cadenceType, ccdModule, ccdOutput,
            pmrfDirectory, pixelsInputDirectory);
        FitsPixelExtractor fitsOutPixelExtractor = new FitsPixelExtractor(
            cadenceTimes, startCadence, cadenceType, ccdModule, ccdOutput,
            pmrfDirectory, pixelsOutputDirectory);

        boolean equals = true;
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
            if (!calExtractor.extractOutputPixels(cadence,
                taskPixelValuesByRowColumn,
                taskPixelValuesByCollateralTypeOffset)) {
                continue;
            }
            if (gapped) {
                for (List<Number> values : taskPixelValuesByRowColumn.values()) {
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

            Map<Pair<CollateralType, Integer>, Float> taskCosmicRayByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, Float>();
            if (!gapped
                && !calExtractor.extractCosmicRays(cadence,
                    cadenceTimes.midTimestamps[cadence - startCadence],
                    taskCosmicRayByCollateralTypeOffset)) {
                continue;
            }

            Map<Pair<Integer, Integer>, Float> taskTargetCosmicRayByRowColumn = new HashMap<Pair<Integer, Integer>, Float>();
            Map<Pair<Integer, Integer>, Float> taskBackgroundCosmicRayByRowColumn = new HashMap<Pair<Integer, Integer>, Float>();
            paExtractor.extractCosmicRays(cadence,
                cadenceTimes.midTimestamps[cadence - startCadence],
                taskTargetCosmicRayByRowColumn,
                taskBackgroundCosmicRayByRowColumn);

            Map<Pair<Integer, Integer>, List<Number>> fitsInTargetPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<Integer, Integer>, List<Number>> fitsInBackgroundPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<CollateralType, Integer>, List<Number>> fitsInPixelValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            if (!fitsInPixelExtractor.extractPixels(cadence,
                fitsInTargetPixelValuesByRowColumn,
                fitsInBackgroundPixelValuesByRowColumn,
                fitsInPixelValuesByCollateralTypeOffset)) {
                equals = false;
            }

            Map<Pair<Integer, Integer>, List<Number>> taskTargetPixelValuesByRowColumn = extractTaskPixelValuesByFitsRowColumn(
                taskPixelValuesByRowColumn, fitsInTargetPixelValuesByRowColumn);
            Map<Pair<Integer, Integer>, List<Number>> taskBackgroundPixelValuesByRowColumn = extractTaskPixelValuesByFitsRowColumn(
                taskPixelValuesByRowColumn,
                fitsInBackgroundPixelValuesByRowColumn);

            applyCosmicRaysToPixelValues(taskTargetPixelValuesByRowColumn,
                taskTargetCosmicRayByRowColumn);
            applyCosmicRaysToPixelValues(taskBackgroundPixelValuesByRowColumn,
                taskBackgroundCosmicRayByRowColumn);

            Map<Pair<Integer, Integer>, List<Number>> fitsOutTargetPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<Integer, Integer>, List<Number>> fitsOutBackgroundPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
            Map<Pair<CollateralType, Integer>, List<Number>> fitsOutPixelValuesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Number>>();
            if (!fitsOutPixelExtractor.extractPixels(cadence,
                fitsOutTargetPixelValuesByRowColumn,
                fitsOutBackgroundPixelValuesByRowColumn,
                fitsOutPixelValuesByCollateralTypeOffset)) {
                equals = false;
            }

            Map<Pair<Integer, Integer>, Float> fitsTargetCosmicRayByRowColumn = new HashMap<Pair<Integer, Integer>, Float>();
            Map<Pair<Integer, Integer>, Float> fitsBackgroundCosmicRayByRowColumn = new HashMap<Pair<Integer, Integer>, Float>();
            Map<Pair<CollateralType, Integer>, Float> fitsCosmicRayByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, Float>();
            fitsOutPixelExtractor.extractCosmicRays(cadence,
                fitsTargetCosmicRayByRowColumn,
                fitsBackgroundCosmicRayByRowColumn,
                fitsCosmicRayByCollateralTypeOffset);

            if (!diffOriginalData("Original target pixels", cadence,
                fitsInTargetPixelValuesByRowColumn,
                fitsOutTargetPixelValuesByRowColumn)) {
                equals = false;
            }
            if (!diffOriginalData("Original background pixels", cadence,
                fitsInBackgroundPixelValuesByRowColumn,
                fitsOutBackgroundPixelValuesByRowColumn)) {
                equals = false;
            }
            if (!diffOriginalCollateralData("Original collateral pixels",
                cadence, fitsInPixelValuesByCollateralTypeOffset,
                fitsOutPixelValuesByCollateralTypeOffset)) {
                equals = false;
            }

            if (!gapped) {
                fillOriginalValues(fitsOutTargetPixelValuesByRowColumn.values());
                fillOriginalValues(fitsOutBackgroundPixelValuesByRowColumn.values());
                fillOriginalValues(fitsOutPixelValuesByCollateralTypeOffset.values());
                if (!diffData("Calibrated target pixels", cadence,
                    taskTargetPixelValuesByRowColumn,
                    fitsOutTargetPixelValuesByRowColumn)) {
                    equals = false;
                }
                if (!diffData("Calibrated background pixels", cadence,
                    taskBackgroundPixelValuesByRowColumn,
                    fitsOutBackgroundPixelValuesByRowColumn)) {
                    equals = false;
                }
                if (!diffCollateralData("Calibrated collateral pixels",
                    cadence, taskPixelValuesByCollateralTypeOffset,
                    fitsOutPixelValuesByCollateralTypeOffset)) {
                    equals = false;
                }

                if (!diffCosmicRays("Target cosmic ray events", cadence,
                    taskTargetCosmicRayByRowColumn,
                    fitsTargetCosmicRayByRowColumn)) {
                    equals = false;
                }
                if (!diffCosmicRays("Background cosmic ray events", cadence,
                    taskBackgroundCosmicRayByRowColumn,
                    fitsBackgroundCosmicRayByRowColumn)) {
                    equals = false;
                }
                if (!diffCollateralCosmicRays("Collateral cosmic ray events",
                    cadence, taskCosmicRayByCollateralTypeOffset,
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

    /**
     * Extract pixel values from {@code taskPixelValuesByRowColumn} if pixel
     * exists in {@code fitsPixelValuesbyRowColumn}.
     * 
     * @param taskPixelValuesByRowColumn background and target pixel values
     * @param fitsPixelValuesByRowColumn background or target pixel values
     * @return homogeneous set of pixels, all background or all target
     */
    private Map<Pair<Integer, Integer>, List<Number>> extractTaskPixelValuesByFitsRowColumn(
        Map<Pair<Integer, Integer>, List<Number>> taskPixelValuesByRowColumn,
        Map<Pair<Integer, Integer>, List<Number>> fitsPixelValuesByRowColumn) {

        HashMap<Pair<Integer, Integer>, List<Number>> pixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>(
            fitsPixelValuesByRowColumn.size());

        for (Entry<Pair<Integer, Integer>, List<Number>> entry : taskPixelValuesByRowColumn.entrySet()) {
            if (fitsPixelValuesByRowColumn.get(entry.getKey()) != null) {
                pixelValuesByRowColumn.put(entry.getKey(),
                    new ArrayList<Number>(entry.getValue()));
            }
        }
        return pixelValuesByRowColumn;
    }

    private void applyCosmicRaysToPixelValues(
        Map<Pair<Integer, Integer>, List<Number>> taskPixelValuesByRowColumn,
        Map<Pair<Integer, Integer>, Float> taskCosmicRaysByRowColumn) {

        for (Entry<Pair<Integer, Integer>, Float> entry : taskCosmicRaysByRowColumn.entrySet()) {
            List<Number> values = taskPixelValuesByRowColumn.get(entry.getKey());
            if (values != null) {
                values.set(CALIBRATED_VALUE,
                    (Float) values.get(CALIBRATED_VALUE) - entry.getValue());
            }
        }
    }

    private void fillOriginalValues(Collection<List<Number>> numberLists) {

        for (List<Number> numbers : numberLists) {
            numbers.set(ORIGINAL_VALUE, ValidationUtils.FITS_FILL_VALUE);
        }
    }

    private boolean diffOriginalData(String type, int cadence,
        Map<Pair<Integer, Integer>, List<Number>> fitsInPixelValuesByRowColumn,
        Map<Pair<Integer, Integer>, List<Number>> fitsOutPixelValuesByRowColumn) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nRow,Column\tFITS file in\tFITS file out\n");

        int errorCount = 0;
        for (Pair<Integer, Integer> index : fitsInPixelValuesByRowColumn.keySet()) {
            List<Number> fitsInValues = fitsInPixelValuesByRowColumn.get(index);
            List<Number> fitsOutValues = fitsOutPixelValuesByRowColumn.get(index);
            if (!fitsInValues.get(ORIGINAL_VALUE)
                .equals(fitsOutValues.get(ORIGINAL_VALUE))) {

                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(index.left)
                    .append(",")
                    .append(index.right)
                    .append("\t");
                output.append(fitsInValues.get(ORIGINAL_VALUE))
                    .append("\t");
                output.append(fitsOutValues.get(ORIGINAL_VALUE))
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                fitsInPixelValuesByRowColumn.size(), (double) errorCount
                    / fitsInPixelValuesByRowColumn.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                fitsInPixelValuesByRowColumn.size(), type.toLowerCase()));
        }

        if (fitsInPixelValuesByRowColumn.size() != fitsOutPixelValuesByRowColumn.size()) {
            log.debug(String.format(
                "Input %s contain %d time series while the output %s contain %d time series",
                type.toLowerCase(), fitsInPixelValuesByRowColumn.size(),
                type.toLowerCase(), fitsOutPixelValuesByRowColumn.size()));
            equals = false;
        }

        return equals;
    }

    private boolean diffOriginalCollateralData(
        String type,
        int cadence,
        Map<Pair<CollateralType, Integer>, List<Number>> fitsInPixelValuesByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, List<Number>> fitsOutPixelValuesByCollateralTypeOffset) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nType,Offset\tFITS file in\tFITS file out\n");

        int errorCount = 0;
        for (Pair<CollateralType, Integer> index : fitsInPixelValuesByCollateralTypeOffset.keySet()) {
            List<Number> fitsInValues = fitsInPixelValuesByCollateralTypeOffset.get(index);
            List<Number> fitsOutValues = fitsOutPixelValuesByCollateralTypeOffset.get(index);
            if (!fitsInValues.get(ORIGINAL_VALUE)
                .equals(fitsOutValues.get(ORIGINAL_VALUE))) {

                equals = false;
                if (errorCount++ >= options.getMaxErrorsDisplayed()) {
                    continue;
                }

                output.append(index.left)
                    .append(",")
                    .append(index.right)
                    .append("\t");
                output.append(fitsInValues.get(ORIGINAL_VALUE))
                    .append("\t");
                output.append(fitsOutValues.get(ORIGINAL_VALUE))
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                fitsInPixelValuesByCollateralTypeOffset.size(),
                (double) errorCount
                    / fitsInPixelValuesByCollateralTypeOffset.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                fitsInPixelValuesByCollateralTypeOffset.size(),
                type.toLowerCase()));
        }

        if (fitsInPixelValuesByCollateralTypeOffset.size() != fitsOutPixelValuesByCollateralTypeOffset.size()) {
            log.debug(String.format(
                "Input %s contain %d time series while the output %s contain %d time series",
                type.toLowerCase(),
                fitsInPixelValuesByCollateralTypeOffset.size(),
                type.toLowerCase(),
                fitsOutPixelValuesByCollateralTypeOffset.size()));
            equals = false;
        }

        return equals;
    }

    private boolean diffData(String type, int cadence,
        Map<Pair<Integer, Integer>, List<Number>> taskPixelValuesByRowColumn,
        Map<Pair<Integer, Integer>, List<Number>> fitsPixelValuesByRowColumn) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nGapped uncertainties are -Infinity by convention, not ICD");
        output.append("\nRow,Column\tTask file (orig, value, unc)\tFITS file (orig, value, unc)\n");

        int errorCount = 0;
        for (Pair<Integer, Integer> index : taskPixelValuesByRowColumn.keySet()) {
            List<Number> taskValues = taskPixelValuesByRowColumn.get(index);
            List<Number> fitsValues = fitsPixelValuesByRowColumn.get(index);
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
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                taskPixelValuesByRowColumn.size(), (double) errorCount
                    / taskPixelValuesByRowColumn.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskPixelValuesByRowColumn.size(), type.toLowerCase()));
        }

        if (taskPixelValuesByRowColumn.size() != fitsPixelValuesByRowColumn.size()) {
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskPixelValuesByRowColumn.size(), type.toLowerCase(),
                fitsPixelValuesByRowColumn.size()));
            equals = false;
        }

        return equals;
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
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
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

    private boolean diffCosmicRays(String type, int cadence,
        Map<Pair<Integer, Integer>, Float> taskCosmicRayByRowColumn,
        Map<Pair<Integer, Integer>, Float> fitsCosmicRayByRowColumn) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nRow,Column\tTask file (value)\tFITS file (value)\n");

        int errorCount = 0;
        for (Pair<Integer, Integer> index : taskCosmicRayByRowColumn.keySet()) {
            Float taskValue = taskCosmicRayByRowColumn.get(index);
            Float fitsValue = fitsCosmicRayByRowColumn.get(index);
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
                taskCosmicRayByRowColumn.size(), (double) errorCount
                    / taskCosmicRayByRowColumn.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskCosmicRayByRowColumn.size(), type.toLowerCase()));
        }

        if (taskCosmicRayByRowColumn.size() != fitsCosmicRayByRowColumn.size()) {
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskCosmicRayByRowColumn.size(), type.toLowerCase(),
                fitsCosmicRayByRowColumn.size()));
            equals = false;
        }

        return equals;
    }

    private boolean diffCollateralCosmicRays(
        String type,
        int cadence,
        Map<Pair<CollateralType, Integer>, Float> taskCosmicRayByCollateralTypeOffset,
        Map<Pair<CollateralType, Integer>, Float> fitsCosmicRayByCollateralTypeOffset) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nType,Offset\tTask file (value)\tFITS file (value)\n");

        int errorCount = 0;
        for (Pair<CollateralType, Integer> index : taskCosmicRayByCollateralTypeOffset.keySet()) {
            Float taskValue = taskCosmicRayByCollateralTypeOffset.get(index);
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

    public static void main(String[] args) {
        Pair<CollateralType, Integer> key = Pair.of(CollateralType.BLACK_LEVEL,
            42);

        System.out.println(key);
    }
}
