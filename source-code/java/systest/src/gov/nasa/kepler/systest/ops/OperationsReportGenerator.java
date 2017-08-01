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

import static gov.nasa.kepler.systest.ops.ReportGenerationOptions.Command.DATA_PROCESSING_REPORT;
import static gov.nasa.kepler.systest.ops.ReportGenerationOptions.Command.DATA_PROCESSING_SUMMARY;
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
 * OPS report generator.
 * <p>
 * Exits with the following status:
 * <ul>
 * <li>0 if the requested reports were generated without error.
 * <li>1 if there were problems in running the program.
 * </ul>
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class OperationsReportGenerator {

    private static boolean debug;

    @SuppressWarnings("static-access")
    public static void main(String[] args) {

        Options commandLineOptions = new Options();
        commandLineOptions.addOption(OptionBuilder.withLongOpt("add-field")
            .hasArg(true)
            .withDescription(
                "Add output field, fieldLabel=fieldValue (data-processing-report, data-processing-summary)")
            .create("a"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("cluster-name")
            .hasArg(true)
            .withDescription(
                "Cluster name, for example, SPQ (data-processing-report, data-processing-summary)")
            .create("c"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("data-name")
            .hasArg(true)
            .withDescription(
                "Data name, for example, Q0 LC (data-processing-report, data-processing-summary)")
            .create("d"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("debug")
            .hasArg(false)
            .withDescription("Debugging (for example, display stack traces)")
            .create("g"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("jira-ticket")
            .hasArg(true)
            .withDescription(
                "Jira ticket, for example, KSOP-42 (data-processing-report, data-processing-summary)")
            .create("j"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("mediawiki")
            .hasArg(false)
            .withDescription(
                "Render output in MediaWiki format (data-processing-report, data-processing-summary)")
            .create("w"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt(
            "pipeline-instance-id")
            .hasArg(true)
            .withDescription(
                "Pipeline instance ID (data-processing-report, data-processing-summary)")
            .create("i"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt(
            "release-to-public")
            .hasArg(true)
            .withDescription(
                "Date of release to public (data-processing-report, data-processing-summary)")
            .create());
        commandLineOptions.addOption(OptionBuilder.withLongOpt("release-to-st")
            .hasArg(true)
            .withDescription(
                "Date of release to ST (data-processing-report, data-processing-summary)")
            .create());

        try {
            CommandLine cmds = new PosixParser().parse(commandLineOptions, args);

            ReportGenerationOptions options = retrieveOptions(cmds);

            if (!validateArgList(cmds.getArgList())) {
                usage(commandLineOptions);
            }
            options.setCommand(cmds.getArgs()[0]);

            new OperationsReportGenerator().generateReport(options);

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

    private static ReportGenerationOptions retrieveOptions(CommandLine cmds) {

        ReportGenerationOptions options = new ReportGenerationOptions();
        if (cmds.hasOption("add-field")) {
            options.addFields(cmds.getOptionValues("add-field"));
        }
        if (cmds.hasOption("cluster-name")) {
            options.setClusterName(cmds.getOptionValue("cluster-name"));
        }
        if (cmds.hasOption("data-name")) {
            options.setDataName(cmds.getOptionValue("data-name"));
        }
        if (cmds.hasOption("debug")) {
            debug = true;
        }
        if (cmds.hasOption("jira-ticket")) {
            options.setJiraTicket(cmds.getOptionValue("jira-ticket"));
        }
        if (cmds.hasOption("mediawiki")) {
            options.setMediaWikiTextRenderer();
        }
        if (cmds.hasOption("pipeline-instance-id")) {
            options.addPipelineInstanceIds(cmds.getOptionValues("pipeline-instance-id"));
        }
        if (cmds.hasOption("release-to-public")) {
            options.setReleaseToPublic(cmds.getOptionValue("release-to-public"));
        }
        if (cmds.hasOption("release-to-st")) {
            options.setReleaseToSt(cmds.getOptionValue("release-to-st"));
        }

        return options;
    }

    @SuppressWarnings({ "rawtypes", "unchecked" })
    private static boolean validateArgList(List argList) {
        if (argList.size() < 1) {
            System.err.println("Missing required arg: data-processsing-report or data-processing-summary");
            return false;
        } else if (argList.size() > 1) {
            System.err.println(String.format("Too many args: %s",
                (List<String>) argList));
            return false;
        }
        return true;
    }

    private static void usage(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        System.err.println("");
        formatter.printHelp(
            new PrintWriter(System.err, true),
            85,
            String.format("OperationsReportGenerator [options] [%s|%s]",
                DATA_PROCESSING_REPORT.getName(),
                DATA_PROCESSING_SUMMARY.getName()),
            "Note: Each option lists in parenthesis the commands that require it.\n",
            options, 2, 4, "");
        System.exit(1);
    }

    private void generateReport(ReportGenerationOptions options) {

        switch (options.getCommand()) {
            case DATA_PROCESSING_REPORT:
                new DataProcessor(options).generateReport();
                break;
            case DATA_PROCESSING_SUMMARY:
                new DataProcessor(options).generateSummary();
                break;
        }
    }
}
