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

import gov.nasa.kepler.ar.exporter.ReleaseTagger;
import static gov.nasa.kepler.common.FitsConstants.*;

import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.commons.cli.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Add release tags to SOC data products.
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("serial")
public class ReleaseTaggerCli {

    private static final Log log = LogFactory.getLog(ReleaseTaggerCli.class);
    
    /** The number of characters allowed by the ICD specification for
     * the QUARTER and DATA_REL keywords. 
     */
    private static final int MAX_SPEC_LENGTH = 16;
    
    private final Option forceOption = 
        new Option("f", "force", false, "When present this will overwrite " +
                "values that have been previously assigned with this tool.") {{
                    setRequired(false);
                }};
    
    private final Option releaseTagOption = 
        new Option("r", "data-rel", true, "The new value for the DATA_REL keyword.") {{
            setRequired(true);
        }};
    
    private final Option quarterTagOption = 
        new Option("q", "quarter", true, "The new value for the QUARTER keyword.") {{
            setRequired(true);
        }};
        
    private final Option rootDirOption = 
        new Option("d", "root-dir", true, "Where to start looking for files to" +
                " modify, defaults to '.'.") {{
            setRequired(false);
        }};
    
    
    private final Options options = new Options() { {
        addOption(rootDirOption);
        addOption(releaseTagOption);
        addOption(quarterTagOption);
        addOption(forceOption);
    }};
    
    private final SystemProvider system;
    private boolean force = false;
    private String quarter;
    private String dataRelease;
    private File rootDir;
    
    public ReleaseTaggerCli(SystemProvider system) {
        this.system = system;
    }
    
    private void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        String command = 
            "java -cp ... gov.nasa.kepler.ar.exporter.ReleaseTaggerCli";
        helpFormatter.printHelp(command, options);
        PrintWriter printWriter = new PrintWriter(system.out());
        printWriter.println("Release Tagger");
        helpFormatter.printHelp(printWriter, 80, command,
                            "", options, 4, 4, "");
    }
    
    public void parse(String[] argv) throws ParseException {
        if (argv.length == 0) {
            printUsage();
            system.exit(1);
            return;
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(options, argv);
        force = commandLine.hasOption(forceOption.getOpt());
        String rootDirStr = commandLine.getOptionValue(rootDirOption.getOpt(), ".");
        rootDir = new File(rootDirStr);
        if (!rootDir.exists()) {
            system.err().println("Root directory does not exist.");
            system.exit(1);
            throw new IllegalArgumentException("Root directory does not exist.");
        }
        if (!rootDir.canRead() || !rootDir.canExecute()) {
            system.err().println("Root directory is not readable.");
            system.exit(1);
            throw new IllegalArgumentException("Root directory is not readable.");
        }
        
        quarter = commandLine.getOptionValue(quarterTagOption.getOpt());
        checkKeywordLength(quarter, QUARTER_KW);
        
        dataRelease = commandLine.getOptionValue(releaseTagOption.getOpt());
        checkKeywordLength(dataRelease, DATA_REL_KW);
    }
    
    private void checkKeywordLength(String keywordValue, String keyword) {
        if (keywordValue.length() > MAX_KEYWORD_VALUE_LENGTH) {
            String msg = 
                "Maximum FITS keyword value length exceeded for " + keyword + " parameter.";
            system.err().println(msg);
            system.exit(1);
            throw new IllegalArgumentException(msg);
        }
        if (keywordValue.length() > MAX_SPEC_LENGTH) {
            String msg = keyword + " value " + keywordValue + " is longer than" +
            " the ICD specified length of " + MAX_SPEC_LENGTH + ".  Continuing anyway.";
            system.err().println(msg);
            log.warn(msg);
        }
    }
    
    public void execute() throws IOException, InterruptedException {
        ReleaseTagger releaseTagger = new ReleaseTagger(force, quarter, dataRelease);
        releaseTagger.tag(rootDir);
    }
    
    public static void main(String[] argv) throws Exception {
        ReleaseTaggerCli cli = new ReleaseTaggerCli(new DefaultSystemProvider());
        cli.parse(argv);
        cli.execute();
    }
}
