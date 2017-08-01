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

package gov.nasa.kepler.systest.ops;

import gov.nasa.kepler.common.UsageException;

import java.io.PrintWriter;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

/**
 * Trigger validator.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class TriggerValidator {

    private static boolean debug;

    @SuppressWarnings("static-access")
    public static void main(String[] args) throws Exception {

        Options commandLineOptions = new Options();
        commandLineOptions.addOption(OptionBuilder.withLongOpt("debug")
            .hasArg(false)
            .withDescription("Debugging (for example, display stack traces)")
            .create("g"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("trigger-name")
            .hasArg(true)
            .withDescription("The name of the trigger to valiidate (required)")
            .create("t"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("k2-enabled")
            .hasArg(false)
            .withDescription("Enable if this is a K2 trigger.")
            .create("k"));

        try {
            CommandLine cmds = new PosixParser().parse(commandLineOptions, args);

            TriggerValidatorOptions options = retrieveOptions(cmds);

            if (!validateArgList(cmds.getArgList())) {
                usage(commandLineOptions);
            }
            options.setXmlFiles(cmds.getArgs());

            new SciencePipelineTriggerValidator(options).validateTrigger();

        } catch (ParseException e) {
            System.err.println(e.getMessage());
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
        }
    }

    private static TriggerValidatorOptions retrieveOptions(CommandLine cmds) {

        TriggerValidatorOptions options = new TriggerValidatorOptions();
        if (cmds.hasOption("debug")) {
            debug = true;
        }
        if (cmds.hasOption("trigger-name")) {
            options.setTriggerName(cmds.getOptionValue("trigger-name"));
        }
        options.setXmlFiles(cmds.getArgs());
        if (cmds.hasOption("k2-enabled")) {
            options.setK2Enabled(true);
        }

        return options;
    }

    @SuppressWarnings("rawtypes")
    private static boolean validateArgList(List argList) {

        if (argList.size() < 1) {
            System.err.println("Missing path(s) to XML parameter library file(s)");
            return false;
        }
        return true;
    }

    private static void usage(Options options) {

        HelpFormatter formatter = new HelpFormatter();
        System.err.println("");
        formatter.printHelp(new PrintWriter(System.err, true), 80,
            "TriggerValidator [options] xml-parameter-library ...", null,
            options, 2, 4, "");
        System.exit(1);
    }
}
