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

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;

import gov.nasa.kepler.ar.DirectorySplitter;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import org.apache.commons.cli.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Command line interface for splitting the files into a directory  into 
 * many subdirectories.
 * 
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("serial")
public class DirectorySplitterCli {

    private static final Log log = LogFactory.getLog(DirectorySplitterCli.class);
    
    private static final Option srcOption = new Option("s", "src", true,
        "Source directory.") {
        {
            setRequired(true);
        }
    };
    
    private static final Option destOption = new Option("d","dest", true,
        "Destination directory.") {
        {
            setRequired(true);
        }
    };
    
    private static final String maxFilesPerDirDefault = Integer.toString(4000);
    private static final Option maxFilesPerDirOption = new Option("x", "max-files", true,
        "Maximum number of files per directory.") {
        {
            setRequired(false);
        }
    };
    
    private static final Options options = new Options() {
        {
            addOption(srcOption);
            addOption(destOption);
            addOption(maxFilesPerDirOption);
        }
    };
    
    private final SystemProvider system;
    private File destDir;
    private File srcDir;
    private int maxFilesPerDir;
    
    public DirectorySplitterCli(SystemProvider system) {
        this.system = system;
    }
    
    public void parseOptions(String[] argv) throws ParseException {
        if (argv.length == 0) {
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("Need options.");
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(options, argv);
        String destDirStr = commandLine.getOptionValue(destOption.getOpt()).trim();
        destDir = new File(destDirStr);
        
        String srcDirStr = commandLine.getOptionValue(srcOption.getOpt()).trim();
        srcDir = new File(srcDirStr);
        
        String maxFilesPerDirStr = commandLine.getOptionValue(maxFilesPerDirOption.getOpt(), maxFilesPerDirDefault).trim();
        maxFilesPerDir = Integer.parseInt(maxFilesPerDirStr);
    }
    
    private void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        PrintWriter printWriter = new PrintWriter(system.out());
        helpFormatter.printHelp(printWriter, 80,
            "java -cp ... gov.nasa.kepler.ar.cli.DirectorySplitterCli",
            "", options, 2, 2, "", true);
        printWriter.append("The default for -x is " + maxFilesPerDirDefault);
        printWriter.flush();
    }
    
    public void execute() throws IOException {
        DirectorySplitter splitter = new DirectorySplitter();
      
        splitter.split(maxFilesPerDir, srcDir, destDir);
        
        log.info("Split complete.");
    }
    
    /**
     * @param argv
     */
    public static void main(String[] argv) throws Exception  {
        DirectorySplitterCli cli = new DirectorySplitterCli(new DefaultSystemProvider());
        cli.parseOptions(argv);
        cli.execute();
    }

}
