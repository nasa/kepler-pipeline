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

import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_ARP_PIXELS;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_BACKGROUND_PIXELS;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_COLLATERAL_PIXELS;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_DV;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_FLUX;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_GAPS;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_PIXELS_IN;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_PIXELS_OUT;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_TARGET_PIXELS;
import static gov.nasa.kepler.systest.validation.FitsValidationOptions.Command.VALIDATE_TPS;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.systest.validation.dv.DvValidator;
import gov.nasa.kepler.systest.validation.flux.FitsFluxValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsArpPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsBackgroundPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsCollateralPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.FitsTargetPixelValidator;
import gov.nasa.kepler.systest.validation.pixels.GapValidator;
import gov.nasa.kepler.systest.validation.tps.TpsValidator;

import java.io.IOException;
import java.io.PrintWriter;

import javax.xml.bind.JAXBException;

import nom.tam.fits.FitsException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.xml.sax.SAXException;

/**
 * FITS validator.
 * <p>
 * Exits with the following status:
 * <ul>
 * <li>0 if the FITS files match the MATLAB .bin files.
 * <li>1 if there were problems in running the program.
 * <li>2 if the FITS files do not match the MATLAB .bin files.
 * </ul>
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class FitsValidator {

    private static boolean debug;

    public static void main(String[] args) {

        Options commandLineOptions = new Options();
        commandLineOptions.addOption(
            "a",
            "ar-id",
            true,
            "AR pipeline instance ID (validate-flux, validate-background-pixels, validate-target-pixels)");
        commandLineOptions.addOption(
            "c",
            "cadence-range",
            true,
            "Cadence range, startCadence-endCadence (validate-flux, validate-pixels-*, validate-gaps, validate-background-pixels, validate-target-pixels)");
        commandLineOptions.addOption("d", "pdc-id", true,
            "PDC pipeline instance ID (validate-flux, validate-arp-pixels, validate-target-pixels)");
        commandLineOptions.addOption(
            "e",
            "max-errors-displayed",
            true,
            String.format(
                "Maximum number of errors to display, default %d, use 0 to display all errors (all)",
                FitsValidationOptions.MAX_ERRORS_DISPLAYED_DEFAULT));
        commandLineOptions.addOption("g", "debug", false,
            "Debugging (for example, display stack traces)");
        commandLineOptions.addOption("i", "kepler-id", true,
            "Kepler ID (validate-target-pixels)");
        commandLineOptions.addOption(
            "k",
            "chunk-size",
            true,
            "Chunk size in cadences (validate-pixels-*, validate-*-pixels)");
        commandLineOptions.addOption(
            "l",
            "cal-id",
            true,
            "CAL pipeline instance ID (validate-pixels-*, validate-*-pixels)");
        commandLineOptions.addOption("m", "ccd-module", true,
            "CCD module number (all, except validate-dv, validate-tps)");
        commandLineOptions.addOption("n", "tps-id", true,
            "TPS pipeline instance ID (validate-tps)");
        commandLineOptions.addOption("o", "ccd-output", true,
            "CCD output number (all, except validate-dv, validate-tps)");
        commandLineOptions.addOption(
            "p",
            "pa-id",
            true,
            "PA pipeline instance ID (validate-flux, validate-pixels-out, validate-*-pixels)");
        commandLineOptions.addOption(
            "r",
            "pmrf-directory",
            true,
            "PMRF directory (validate-pixels-*, validate-*-pixels)");
        commandLineOptions.addOption(
            "s",
            "skip-count",
            true,
            "Cadences to skip when validating a large range, default 0 (validate-pixels-*, validate-*-pixels)");
        commandLineOptions.addOption("t", "tasks-root-directory", true,
            "Pipeline tasks root directory (all)");
        commandLineOptions.addOption("u", "time-limit", true,
            "Processing time limit in minutes (validate-pixels-*, validate-target-pixels)");
        commandLineOptions.addOption("v", "dv-id", true,
            "DV pipeline instance ID (validate-dv)");

        commandLineOptions.addOption(null, "arp-pixels-directory", true,
            "ARP pixels directory (validate-arp-pixels)");
        commandLineOptions.addOption(null, "background-pixels-directory", true,
            "Background pixels directory (validate-background-pixels)");
        commandLineOptions.addOption(null, "collateral-pixels-directory", true,
            "Collateral pixels directory (validate-collateral-pixels)");
        commandLineOptions.addOption(
            null,
            "cache-enabled",
            false,
            "Enable caching (validate-flux, validate-pixels-out, validate-background-pixels, validate-target-pixels)");
        commandLineOptions.addOption(null, "cadence-type", true,
            "Cadence type (validate-gaps)");
        commandLineOptions.addOption(null, "dv-fits-directory", true,
            "DV FITS directory (validate-dv)");
        commandLineOptions.addOption(null, "dv-xml-directory", true,
            "DV XML directory (validate-dv)");
        commandLineOptions.addOption(null, "flux-directory", true,
            "Flux directory (validate-flux)");
        commandLineOptions.addOption(
            null,
            "pixels-input-directory",
            true,
            "Pixels input directory (validate-pixels-*, validate-gaps, validate-*-pixels)");
        commandLineOptions.addOption(null, "pixels-output-directory", true,
            "Pixels output directory (validate-pixels-out, validate-gaps)");
        commandLineOptions.addOption(null, "target-pixels-directory", true,
            "Target pixels directory (validate-target-pixels)");
        commandLineOptions.addOption(null, "target-skip-count", true,
            "Targets to skip, default 100 (validate-flux, validate-*-pixels)");
        commandLineOptions.addOption(null, "tps-cdpp-directory", true,
            "TPS CDPP directory (validate-tps)");

        try {
            CommandLine cmds = new PosixParser().parse(commandLineOptions, args);

            FitsValidationOptions options = retrieveOptions(cmds);

            if (cmds.getArgList()
                .size() != 1) {
                usage(commandLineOptions);
            }
            options.setCommand(cmds.getArgs()[0]);

            new FitsValidator().validate(options);

        } catch (ParseException e) {
            System.err.println(e.getMessage());
            usage(commandLineOptions);
        } catch (NumberFormatException e) {
            System.err.println("Bad number in argument: " + e.getMessage());
            usage(commandLineOptions);
        } catch (UsageException e) {
            System.err.println(e.getMessage());
            usage(commandLineOptions);
        } catch (IllegalArgumentException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (IllegalStateException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (FitsException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (JAXBException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (SAXException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (IOException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (ValidationException e) {
            System.err.println(e.getMessage());
            System.exit(2);
        }
    }

    private static FitsValidationOptions retrieveOptions(CommandLine cmds) {

        FitsValidationOptions options = new FitsValidationOptions();
        if (cmds.hasOption("ar-id")) {
            options.setArId(Long.parseLong(cmds.getOptionValue("ar-id")));
        }
        if (cmds.hasOption("arp-pixels-directory")) {
            options.setArpPixelsDirectory(cmds.getOptionValue("arp-pixels-directory"));
        }
        if (cmds.hasOption("background-pixels-directory")) {
            options.setBackgroundPixelsDirectory(cmds.getOptionValue("background-pixels-directory"));
        }
        if (cmds.hasOption("collateral-pixels-directory")) {
            options.setCollateralPixelsDirectory(cmds.getOptionValue("collateral-pixels-directory"));
        }
        if (cmds.hasOption("cadence-range")) {
            options.setCadenceRange(cmds.getOptionValue("cadence-range"));
        }
        if (cmds.hasOption("cadence-type")) {
            options.setCadenceType(CadenceType.valueOf(cmds.getOptionValue(
                "cadence-type")
                .toUpperCase()));
        }
        if (cmds.hasOption("cal-id")) {
            options.setCalId(Long.parseLong(cmds.getOptionValue("cal-id")));
        }
        if (cmds.hasOption("ccd-module")) {
            options.setCcdModule(Integer.parseInt(cmds.getOptionValue("ccd-module")));
        }
        if (cmds.hasOption("ccd-output")) {
            options.setCcdOutput(Integer.parseInt(cmds.getOptionValue("ccd-output")));
        }
        if (cmds.hasOption("chunk-size")) {
            options.setChunkSize(Integer.parseInt(cmds.getOptionValue("chunk-size")));
        }
        if (cmds.hasOption("dv-id")) {
            options.setDvId(Long.parseLong(cmds.getOptionValue("dv-id")));
        }
        if (cmds.hasOption("dv-fits-directory")) {
            options.setDvFitsDirectory(cmds.getOptionValue("dv-fits-directory"));
        }
        if (cmds.hasOption("dv-xml-directory")) {
            options.setDvXmlDirectory(cmds.getOptionValue("dv-xml-directory"));
        }
        if (cmds.hasOption("flux-directory")) {
            options.setFluxDirectory(cmds.getOptionValue("flux-directory"));
        }
        if (cmds.hasOption("kepler-id")) {
            options.setKeplerId(Integer.parseInt(cmds.getOptionValue("kepler-id")));
        }
        if (cmds.hasOption("max-errors-displayed")) {
            options.setMaxErrorsDisplayed(Integer.parseInt(cmds.getOptionValue("max-errors-displayed")));
        }
        if (cmds.hasOption("pa-id")) {
            options.setPaId(Long.parseLong(cmds.getOptionValue("pa-id")));
        }
        if (cmds.hasOption("pdc-id")) {
            options.setPdcId(Long.parseLong(cmds.getOptionValue("pdc-id")));
        }
        if (cmds.hasOption("pixels-input-directory")) {
            options.setPixelsInputDirectory(cmds.getOptionValue("pixels-input-directory"));
        }
        if (cmds.hasOption("pixels-output-directory")) {
            options.setPixelsOutputDirectory(cmds.getOptionValue("pixels-output-directory"));
        }
        if (cmds.hasOption("pmrf-directory")) {
            options.setPmrfDirectory(cmds.getOptionValue("pmrf-directory"));
        }
        if (cmds.hasOption("skip-count")) {
            options.setSkipCount(Integer.parseInt(cmds.getOptionValue("skip-count")));
        }
        if (cmds.hasOption("target-pixels-directory")) {
            options.setTargetPixelsDirectory(cmds.getOptionValue("target-pixels-directory"));
        }
        if (cmds.hasOption("target-skip-count")) {
            options.setTargetSkipCount(Integer.parseInt(cmds.getOptionValue("target-skip-count")));
        }
        if (cmds.hasOption("tasks-root-directory")) {
            options.setTasksRootDirectory(cmds.getOptionValue("tasks-root-directory"));
        }
        if (cmds.hasOption("time-limit")) {
            options.setTimeLimit(Integer.parseInt(cmds.getOptionValue("time-limit")));
        }
        if (cmds.hasOption("tps-cdpp-directory")) {
            options.setTpsCdppDirectory(cmds.getOptionValue("tps-cdpp-directory"));
        }
        if (cmds.hasOption("tps-id")) {
            options.setTpsId(Long.parseLong(cmds.getOptionValue("tps-id")));
        }
        if (cmds.hasOption("tps-text-directory")) {
            options.setTpsTextDirectory(cmds.getOptionValue("tps-text-directory"));
        }

        if (cmds.hasOption("cache-enabled")) {
            options.setCacheEnabled(true);
        }
        if (cmds.hasOption("debug")) {
            debug = true;
        }

        return options;
    }

    private static void usage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        System.err.println("");
        formatter.printHelp(
            new PrintWriter(System.err, true),
            80,
            String.format(
                "FitsValidator [options] [%s|%s|%s|%s|%s|%s|%s|%s|%s|%s]",
                VALIDATE_ARP_PIXELS.getName(),
                VALIDATE_BACKGROUND_PIXELS.getName(),
                VALIDATE_COLLATERAL_PIXELS.getName(), VALIDATE_DV.getName(),
                VALIDATE_FLUX.getName(), VALIDATE_GAPS.getName(),
                VALIDATE_PIXELS_IN.getName(), VALIDATE_PIXELS_OUT.getName(),
                VALIDATE_TARGET_PIXELS.getName(), VALIDATE_TPS.getName()),
            "Note: Each option lists in parenthesis the commands that require it.\n",
            options, 2, 4, "");
        System.exit(1);
    }

    private void validate(FitsValidationOptions options) throws FitsException,
        IOException, ValidationException, JAXBException, SAXException {

        switch (options.getCommand()) {
            case VALIDATE_ARP_PIXELS:
                new FitsArpPixelValidator(options).validate();
                break;
            case VALIDATE_BACKGROUND_PIXELS:
                new FitsBackgroundPixelValidator(options).validate();
                break;
            case VALIDATE_COLLATERAL_PIXELS:
                new FitsCollateralPixelValidator(options).validate();
                break;
            case VALIDATE_DV:
                new DvValidator(options).validate();
                break;
            case VALIDATE_FLUX:
                new FitsFluxValidator(options).validate();
                break;
            case VALIDATE_GAPS:
                new GapValidator(options).validate();
                break;
            case VALIDATE_PIXELS_IN:
            case VALIDATE_PIXELS_OUT:
                new FitsPixelValidator(options).validate();
                break;
            case VALIDATE_TARGET_PIXELS:
                new FitsTargetPixelValidator(options).validate();
                break;
            case VALIDATE_TPS:
                new TpsValidator(options).validate();
                break;
            default:
                throw new UsageException("Missing required command arg");
        }
    }
}
