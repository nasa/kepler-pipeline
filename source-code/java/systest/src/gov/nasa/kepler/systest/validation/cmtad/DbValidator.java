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

package gov.nasa.kepler.systest.validation.cmtad;

import static gov.nasa.kepler.systest.validation.cmtad.DbValidationParameters.Command.VALIDATE_CM_TAD;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.systest.validation.ValidationException;

import java.io.PrintWriter;
import java.net.URISyntaxException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

/**
 * Database validator.
 * <p>
 * Exits with the following status:
 * <ul>
 * <li>0 if the two databases are the same.
 * <li>1 if there were problems in running the program.
 * <li>2 if the two database are not the same.
 * </ul>
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DbValidator {

    private static boolean debug;

    @SuppressWarnings("static-access")
    public static void main(String[] args) {

        Options options = new Options();
        options.addOption("b", "ignore-backgroundTargetTableType", false,
            "Ignore background targets (validate-cm-tad)");
        options.addOption("d", "debug", false,
            "Debugging (for example, display stack traces)");
        options.addOption(
            "e",
            "max-errors-displayed",
            true,
            String.format(
                "Maximum number of errors to display, default %d, use 0 to display all errors (all)",
                DbValidationParameters.MAX_ERRORS_DISPLAYED_DEFAULT));
        options.addOption("i", "ignore-indexInModuleOutput", false,
            "Ignore TargetTable indexInModuleOutput column (validate-cm-tad)");
        options.addOption(OptionBuilder.withLongOpt("url")
            .hasArgs(2)
            .withArgName("url url")
            .withDescription("Database URLs (validate-cm-tad)")
            .create("u"));

        try {
            CommandLine cmds = new PosixParser().parse(options, args);

            DbValidationParameters parameters = retrieveParameters(cmds);

            if (cmds.getArgList()
                .size() < 1) {
                System.err.println("Missing required command");
                usage(options);
            }
            if (cmds.getArgList()
                .size() > 1) {
                System.err.println("Too many command-line arguments");
                usage(options);
            }
            parameters.setCommand(cmds.getArgs()[0]);

            new DbValidator().validate(parameters);

        } catch (ParseException e) {
            System.err.println(e.getMessage());
            usage(options);
        } catch (NumberFormatException e) {
            System.err.println("Bad number in argument: " + e.getMessage());
            usage(options);
        } catch (UsageException e) {
            System.err.println(e.getMessage());
            usage(options);
        } catch (URISyntaxException e) {
            System.err.println(e.getMessage());
            usage(options);
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
        } catch (ValidationException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        }
    }

    private static DbValidationParameters retrieveParameters(CommandLine cmds) {

        DbValidationParameters parameters = new DbValidationParameters();

        if (cmds.hasOption("debug")) {
            debug = true;
        }
        if (cmds.hasOption("ignore-backgroundTargetTableType")) {
            parameters.setIgnoreBackgroundTargetTableType(true);
        }

        if (cmds.hasOption("ignore-indexInModuleOutput")) {
            parameters.setIgnoreIndexInModuleOutput(true);
        }
        if (cmds.hasOption("max-errors-displayed")) {
            parameters.setMaxErrorsDisplayed(Integer.parseInt(cmds.getOptionValue("max-errors-displayed")));
        }
        if (cmds.hasOption("url")) {
            parameters.setUrls(cmds.getOptionValues("url"));
        }
        return parameters;
    }

    private static void usage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        System.err.println("");
        formatter.printHelp(
            new PrintWriter(System.err, true),
            80,
            String.format("DbValidator [options] [%s]",
                VALIDATE_CM_TAD.getName()),
            "Note: Each option lists in parenthesis the commands that require it.\n",
            options,
            2,
            4,
            "\nExample:\n"
                + "  runjava -Xmx4G db-validator \\\n"
                + "  --url jdbc:oracle:thin:userA/passwordA@hostA:1521:databaseA?targetListSetNameA \\\n"
                + "        jdbc:oracle:thin:userB/passwordB@hostB:1521:databaseB?targetListSetNameB \\\n"
                + "  validate-cm-tad");
        System.exit(1);
    }

    private void validate(DbValidationParameters parameters)
        throws URISyntaxException, ValidationException {

        switch (parameters.getCommand()) {
            case VALIDATE_CM_TAD:
                new CmTadValidator(parameters).validate();
                break;
        }
    }
}
