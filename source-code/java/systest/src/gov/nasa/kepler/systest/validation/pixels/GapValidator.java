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

import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.systest.validation.FitsValidationOptions;
import gov.nasa.kepler.systest.validation.FitsValidationOptions.Command;
import gov.nasa.kepler.systest.validation.ValidationException;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.FitsPixelType;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.Map.Entry;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Validates that there is a one to one correspondence between the input FITS
 * pixel files and the exported FITS pixel files.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class GapValidator {
    private static final Log log = LogFactory.getLog(GapValidator.class);
    private FitsValidationOptions options;
    private File pixelsOutputDirectory;
    private File pixelsInputDirectory;

    public GapValidator(FitsValidationOptions options) {
        if (options == null) {
            throw new NullPointerException("options can't be null");
        }

        this.options = options;
        validateOptions();
    }

    private void validateOptions() {
        if (options.getCommand() != Command.VALIDATE_GAPS) {
            throw new IllegalStateException("Unexpected command "
                + options.getCommand()
                    .getName());
        }

        if (options.getCadenceRange() == null) {
            throw new UsageException("Cadence range not set");
        }

        if (options.getCadenceType() == null) {
            throw new UsageException("Cadence type not set");
        }

        if (options.getMaxErrorsDisplayed() < 0) {
            throw new UsageException("Max errors displayed can't be negative");
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

        if (options.getPixelsOutputDirectory() == null) {
            throw new UsageException("Pixels output directory not set");
        }
        pixelsOutputDirectory = new File(options.getPixelsOutputDirectory());
        if (!ValidationUtils.directoryReadable(pixelsOutputDirectory,
            "Pixels output directory")) {
            throw new UsageException("Can't read pixels output directory "
                + pixelsOutputDirectory);
        }
    }

    public void validate() throws FitsException, IOException,
        ValidationException {

        log.info(String.format("Scanning FITS input files in %s",
            pixelsInputDirectory));
        FitsPixelExtractor fitsPixelExtractor = new FitsPixelExtractor(
            options.getCadenceRange().left, options.getCadenceRange().right,
            options.getCadenceType(), pixelsInputDirectory);
        Map<Pair<Integer, FitsPixelType>, String> inputFilenameByCadence = fitsPixelExtractor.findFitsFilesInCadenceRange();

        log.info(String.format("Scanning FITS output files in %s",
            pixelsOutputDirectory));
        fitsPixelExtractor = new FitsPixelExtractor(
            options.getCadenceRange().left, options.getCadenceRange().right,
            options.getCadenceType(), pixelsOutputDirectory);
        Map<Pair<Integer, FitsPixelType>, String> outputFilenameByCadence = fitsPixelExtractor.findFitsFilesInCadenceRange();

        // Pass 1: Find missing output files.
        boolean pass1Failed = false;
        int errorCount = 0;
        for (Entry<Pair<Integer, FitsPixelType>, String> inputEntry : inputFilenameByCadence.entrySet()) {
            String outputFilename = outputFilenameByCadence.get(inputEntry.getKey());
            if (outputFilename == null
                && errorCount++ < options.getMaxErrorsDisplayed()) {
                log.error(String.format(
                    "No output FITS pixel file for cadence %d (filename %s)",
                    inputEntry.getKey().left, inputEntry.getValue()));
                pass1Failed = true;
            }
        }
        if (pass1Failed) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                log.error("...\n");
            }
            log.error(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                inputFilenameByCadence.size(), (double) errorCount
                    / inputFilenameByCadence.size() * 100.0));
        }

        // Pass 2: Find errant output files.
        boolean pass2Failed = false;
        errorCount = 0;
        for (Entry<Pair<Integer, FitsPixelType>, String> outputEntry : outputFilenameByCadence.entrySet()) {
            String inputFilename = inputFilenameByCadence.get(outputEntry.getKey());
            if (inputFilename == null
                && errorCount++ < options.getMaxErrorsDisplayed()) {
                log.error(String.format(
                    "No input FITS pixel file for cadence %d (filename %s)",
                    outputEntry.getKey().left, outputEntry.getValue()));
                pass2Failed = true;
            }
        }
        if (pass2Failed) {
            if (errorCount >= options.getMaxErrorsDisplayed()) {
                log.error("...\n");
            }
            log.error(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                outputFilenameByCadence.size(), (double) errorCount
                    / outputFilenameByCadence.size() * 100.0));
        }

        log.info(String.format("%s %d pixel files",
            pass1Failed || pass2Failed ? "Processed" : "Validated",
            inputFilenameByCadence.size()));

        if (pass1Failed || pass2Failed) {
            throw new ValidationException(
                "Input and output pixel files do not have a one to one correspondence; see log");
        }
    }
}
