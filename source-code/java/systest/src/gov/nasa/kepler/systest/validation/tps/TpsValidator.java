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

import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FitsValidationOptions.Command;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.kepler.tps.TpsResult;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * TPS results validator.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class TpsValidator {

    private static final Log log = LogFactory.getLog(TpsValidator.class);

    private static final Set<Float> FITS_CDPP_DURATIONS = new HashSet<Float>();
    static {
        FITS_CDPP_DURATIONS.add(3.0F);
        FITS_CDPP_DURATIONS.add(6.0F);
        FITS_CDPP_DURATIONS.add(12.0F);
    }

    private FitsValidationOptions options;
    private File cdppDirectory;
    private File tasksRootDirectory;

    public TpsValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        if (options.getCommand() != Command.VALIDATE_TPS) {
            throw new IllegalStateException("Unexpected command "
                + options.getCommand()
                    .getName());
        }
        if (options.getTpsId() == -1) {
            throw new UsageException("TPS pipeline instance ID not set");
        }

        if (options.getTpsCdppDirectory() == null) {
            throw new UsageException("TPS CDPP directory not set");
        }
        cdppDirectory = new File(options.getTpsCdppDirectory());
        if (!ValidationUtils.directoryReadable(cdppDirectory,
            "TPS CDPP directory")) {
            throw new UsageException("Can't read TPS CDPP directory"
                + cdppDirectory);
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

        if (options.getMaxErrorsDisplayed() < 0) {
            throw new UsageException("Max errors displayed can't be negative");
        }
    }

    public void validate() throws FitsException, IOException,
        ValidationException {

        Map<Pair<Integer, Float>, TpsResult> taskTpsResultsByKeplerIdAndPulse = new HashMap<Pair<Integer, Float>, TpsResult>();
        Map<Pair<Integer, Float>, SimpleFloatTimeSeries> taskCdppByKeplerIdAndPulse = new HashMap<Pair<Integer, Float>, SimpleFloatTimeSeries>();
        TpsExtractor tpsExtractor = new TpsExtractor(options.getTpsId(),
            tasksRootDirectory);
        tpsExtractor.extractTpsResults(taskTpsResultsByKeplerIdAndPulse,
            taskCdppByKeplerIdAndPulse);

        log.debug(String.format("Extracted %d task TPS results",
            taskTpsResultsByKeplerIdAndPulse.size()));

        Map<Pair<Integer, Float>, SimpleFloatTimeSeries> exportedCdppByKeplerIdAndPulse = new HashMap<Pair<Integer, Float>, SimpleFloatTimeSeries>();

        FitsCdppExtractor fitsCdppExtractor = new FitsCdppExtractor(
            cdppDirectory);

        boolean failed = false;

        for (TpsResult tpsResult : taskTpsResultsByKeplerIdAndPulse.values()) {
            Pair<Integer, Float> key = Pair.of(tpsResult.getKeplerId(),
                tpsResult.getTrialTransitPulseInHours());
            if (FITS_CDPP_DURATIONS.contains(tpsResult.getTrialTransitPulseInHours())) {
                if (exportedCdppByKeplerIdAndPulse.get(key) == null) {
                    Pair<Integer, Integer> cadenceRange = ValidationUtils.getCadenceRange(options.getTpsId());
                    exportedCdppByKeplerIdAndPulse.putAll(fitsCdppExtractor.extractTimeSeries(
                        tpsResult.getKeplerId(), cadenceRange.left,
                        cadenceRange.right));
                }
                if (diffCdppTimeSeries(tpsResult.getKeplerId(),
                    tpsResult.getTrialTransitPulseInHours(),
                    taskCdppByKeplerIdAndPulse.get(key),
                    exportedCdppByKeplerIdAndPulse.get(key))) {
                    failed = true;
                }
            }
        }
        log.info(String.format("%s %d TPS results", failed ? "Processed"
            : "Validated", taskTpsResultsByKeplerIdAndPulse.size()));

        if (failed) {
            throw new ValidationException(
                "Task and export files differ; see log");
        }
    }

    private boolean diffCdppTimeSeries(int keplerId, Float pulseDuration,
        SimpleFloatTimeSeries taskTimeSeries,
        SimpleFloatTimeSeries exportedTimeSeries) {

        boolean failed = false;

        if (taskTimeSeries == null) {
            log.warn(String.format(
                "No CDPP time series in task files for Kepler ID %d and pulse duration %f",
                keplerId, pulseDuration));
            return false;
        } else if (exportedTimeSeries == null) {
            log.error(String.format(
                "No CDPP time series in exported file for Kepler ID %d and pulse duration %f",
                keplerId, pulseDuration));
            return true;
        } else if (taskTimeSeries.getValues().length != exportedTimeSeries.getValues().length) {
            log.error(String.format(
                "CDPP time series for Kepler ID %d "
                    + "has %d values in task file but %d values were extracted from exported file",
                keplerId, taskTimeSeries.getValues().length,
                exportedTimeSeries.getValues().length));
            failed = true;
        }

        if (!ValidationUtils.diffSimpleTimeSeries(
            options.getMaxErrorsDisplayed(),
            String.format("CDPP (%.2f)", pulseDuration), keplerId,
            taskTimeSeries, exportedTimeSeries)) {
            failed = true;
        }

        return failed;
    }
}
