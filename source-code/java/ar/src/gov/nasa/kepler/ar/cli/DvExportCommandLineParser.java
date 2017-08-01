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

package gov.nasa.kepler.ar.cli;

import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collections;
import java.util.List;

import org.apache.commons.cli.*;

import com.google.common.collect.Lists;

/**
 * Parse command line options for DV exporters.
 * 
 * @author Sean McCauliff
 */
@SuppressWarnings("serial")
public class DvExportCommandLineParser {

    @SuppressWarnings("static-access")
	private final Option destOption = OptionBuilder
        .withDescription("Destination directory")
        .withLongOpt("dest")
        .hasArg()
        .withArgName("destination dir")
        .isRequired(true)
        .create('d');
    
    @SuppressWarnings("static-access")
	private final Option pipelineIdOption = OptionBuilder
        .withDescription("The pipelne instance id.")
        .withLongOpt("instance")
        .hasArg()
        .withArgName("instance id")
        .isRequired(true)
        .create('i');
    
    @SuppressWarnings("static-access")
	private final Option keplerIdsOption = OptionBuilder
        .withDescription("comma separated list of kepler ids")
        .withValueSeparator(',')
        .withLongOpt("kepler-ids")
        .withArgName("keplerIds")
        .hasArgs()
        .isRequired(false)
        .create('k');

    private final Options options = new Options() {
        {
            addOption(destOption);
            addOption(pipelineIdOption);
            addOption(keplerIdsOption);
        }
    };
    

    private final SystemProvider system;
    private File outputDir;
    private long pipelineInstanceId = -1L;;
    private List<Integer> keplerIds = Collections.emptyList();

    DvExportCommandLineParser(SystemProvider system) {
        this.system = system;
    }
    
    void printUsage(Class<?> cliClass) {
        HelpFormatter helpFormatter = new HelpFormatter();
        PrintWriter printWriter = new PrintWriter(system.out());
        helpFormatter.printHelp(printWriter, 80,
            "java -cp soc-classpath.jar " + cliClass.getName(), "",
            options, 2, 2, "", true);
        printWriter.flush();
    }

    void parse(String[] argv, Class<?> cliClass) throws IOException, ParseException {
        if (argv.length == 0) {
            printUsage(cliClass);
            system.exit(-1);
            return;
        }
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(options, argv);
        
        pipelineInstanceId = Long.parseLong(commandLine.getOptionValue(
            pipelineIdOption.getOpt()).trim());

        String outputDirStr = commandLine.getOptionValue(destOption.getOpt())
            .trim();

        outputDir = new File(outputDirStr);
        if (!outputDir.exists()) {
            FileUtil.mkdirs(outputDir);
        }

        if (!outputDir.isDirectory()) {
            system.err()
                .println(
                    "Output directory \"" + outputDir
                        + "\" is not a directory.");
            system.exit(-1);
            return;
        }

        if (!outputDir.canWrite()) {
            system.err()
                .println(
                    "Output directory \"" + outputDir + "\" is not writable.");
            system.exit(-1);
            return;
        }
        
        if (commandLine.hasOption(keplerIdsOption.getOpt())) {
            String[] keplerIdStrs = commandLine.getOptionValues(keplerIdsOption.getOpt());
            keplerIds = Lists.newArrayList();
            for (String keplerIdStr : keplerIdStrs) {
                keplerIds.add(Integer.parseInt(keplerIdStr));
            }
        }

    }
    
    public long pipelineInstanceId() {
        return pipelineInstanceId;
    }
    
    public File outputDir() {
        return outputDir;
    }
    
    public List<Integer> keplerIds() {
        if (keplerIds.isEmpty()) {
            keplerIds = dvCrud().retrieveTargetResultsKeplerIdsByPipelineInstanceId(pipelineInstanceId);
        }
        return keplerIds;
    }
    
    protected DvCrud dvCrud() {
        return new DvCrud();
    }
}
