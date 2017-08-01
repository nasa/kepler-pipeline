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

package gov.nasa.kepler.cm;

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.util.Collection;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
public class TargetListMergerCli {

    private static boolean debug;

    @SuppressWarnings("static-access")
    public static void main(String[] args) {

        Options commandLineOptions = new Options();
        commandLineOptions.addOption(OptionBuilder.withLongOpt("debug")
            .hasArg(false)
            .withDescription("Debugging (for example, display stack traces)")
            .create("g"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("category")
            .hasArg(true)
            .withDescription(
                String.format("Category (default: %s)",
                    TargetListMergerOptions.DEFAULT_CATEGORY))
            .create("c"));
        commandLineOptions.addOption(OptionBuilder.withLongOpt("output")
            .hasArg(true)
            .isRequired()
            .withArgName("file")
            .withDescription("Output file (required)")
            .create("o"));

        try {
            CommandLine cmds = new PosixParser().parse(commandLineOptions, args);

            new TargetListMerger(retrieveOptions(cmds)).mergeTargetLists();

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
        } catch (IOException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        } catch (java.text.ParseException e) {
            System.err.println(e.getMessage());
            if (debug) {
                e.printStackTrace();
            }
            System.exit(1);
        }
    }

    @SuppressWarnings("unchecked")
    private static TargetListMergerOptions retrieveOptions(CommandLine cmds) {

        TargetListMergerOptions options = new TargetListMergerOptions();
        if (cmds.hasOption("debug")) {
            debug = true;
        }
        if (cmds.hasOption("output")) {
            options.setOutputFilename(cmds.getOptionValue("output"));
        }

        options.setTargetListFilenames(cmds.getArgList());

        return options;
    }

    private static void usage(Options options) {

        HelpFormatter formatter = new HelpFormatter();
        System.err.println("");
        formatter.printHelp(new PrintWriter(System.err, true), 80,
            "TargetListMergerCli [options] target-list-name [...]", null,
            options, 2, 4, "");
        System.exit(1);
    }

    /**
     * Merges target lists.
     * <p>
     * This class is package private for testing purposes only. If this class is
     * needed elsewhere, please make it a top-level class.
     * 
     * @author Bill Wohler
     */
    static class TargetListMerger {
        private final TargetListMergerOptions options;

        public TargetListMerger(TargetListMergerOptions options) {
            this.options = options;
            validateOptions();
        }

        private void validateOptions() {
            if (options.getOutputFilename() == null
                || options.getOutputFilename()
                    .isEmpty()) {
                throw new UsageException("The --output option is required");
            }
            if (options.getTargetListFilenames() == null
                || options.getTargetListFilenames()
                    .size() < 2) {
                throw new UsageException(
                    "Specify at least two target list names");
            }
        }

        /**
         * Merges two or more more target list files.
         * 
         * @throws IOException if there were problems opening or reading the
         * file
         * @throws java.text.ParseException if there were problems parsing the
         * content of the files
         */
        public void mergeTargetLists() throws IOException,
            java.text.ParseException {

            Map<Integer, PlannedTarget> plannedTargetsByKeplerId = new LinkedHashMap<Integer, PlannedTarget>();
            for (String filename : options.getTargetListFilenames()) {
                TargetListImporter targetListImporter = new TargetListImporter(
                    new TargetList(new File(filename).getName()));
                targetListImporter.setImportingTargetList(false);
                List<PlannedTarget> plannedTargets = targetListImporter.ingestTargetFile(filename);
                for (PlannedTarget plannedTarget : plannedTargets) {
                    if (plannedTarget.getKeplerId() == TargetManagementConstants.INVALID_KEPLER_ID) {
                        throw new IllegalStateException(
                            String.format(
                                "%s contains a NEW custom target and must be imported prior to merging",
                                filename));
                    }
                }
                merge(plannedTargetsByKeplerId, plannedTargets);
            }

            writePlannedTargets(plannedTargetsByKeplerId.values());
        }

        private void merge(Map<Integer, PlannedTarget> targetByKeplerId,
            List<PlannedTarget> plannedTargets) {

            for (PlannedTarget plannedTarget : plannedTargets) {
                TargetSelectionOperations.merge(targetByKeplerId,
                    plannedTarget.getKeplerId(), plannedTarget);
            }
        }

        private void writePlannedTargets(
            Collection<PlannedTarget> plannedTargets) throws IOException {

            Writer w = new PrintWriter(System.out);
            if (options.getOutputFilename() != null
                && !options.getOutputFilename()
                    .equals("-")) {
                w = new FileWriter(new File(options.getOutputFilename()));
            }

            BufferedWriter bw = new BufferedWriter(w);
            bw.write(createComment());

            bw.write("Category: " + options.getCategory());
            bw.newLine();

            for (PlannedTarget plannedTarget : plannedTargets) {
                bw.write(plannedTarget.toString());
                bw.newLine();
            }

            bw.close();
        }

        private String createComment() {

            StringBuilder comment = new StringBuilder();
            comment.append(TargetListImporter.COMMENT_CHAR)
                .append(" Merged the following target lists on ")
                .append(Iso8601Formatter.dateFormatter()
                    .format(new Date()))
                .append(":\n");

            for (String filename : options.getTargetListFilenames()) {
                comment.append(TargetListImporter.COMMENT_CHAR)
                    .append(" ")
                    .append(new File(filename).getName())
                    .append("\n");
            }

            return comment.toString();
        }
    }

    /**
     * Options for target list merger.
     * <p>
     * This class is package private for testing purposes only. If this class is
     * needed elsewhere, please make it a top-level class.
     * 
     * @author Bill Wohler
     */
    static class TargetListMergerOptions {
        static final String DEFAULT_CATEGORY = "MERGED";

        private String category = DEFAULT_CATEGORY;
        private String outputFilename;
        private List<String> targetListFilenames;

        public String getCategory() {
            return category;
        }

        public void setCategory(String category) {
            this.category = category;
        }

        public String getOutputFilename() {
            return outputFilename;
        }

        public void setOutputFilename(String outputFilename) {
            this.outputFilename = outputFilename;
        }

        public List<String> getTargetListFilenames() {
            return targetListFilenames;
        }

        public void setTargetListFilenames(List<String> targetListFilenames) {
            this.targetListFilenames = targetListFilenames;
        }
    }
}
