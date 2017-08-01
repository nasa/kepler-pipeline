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

package gov.nasa.kepler.ar.exporter.ktc.verifier;

import gov.nasa.kepler.ar.cli.CliUtils;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.xmlbeans.XmlException;

/**
 * Command line class for the KtcVerifier.
 * 
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("serial")
public class KtcVerifierCli {

    private final static String DATA_REPO_DEFAULT = SocEnvVars.getLocalDataDir();
    
    private final Option startOption = 
        new Option("b", "begin", true, "The start time of KTC in ISO 8601 format, UTC.") {{
            setRequired(true);
        }};
        

    private final Option endOption =
        new Option("e", "end", true, "The end time of the KTC in ISO 8601 format, UTC.") {{
            setRequired(true);
        }};
        
    private final Option fileOption = 
        new Option("f", "ktc-file", true, "The KTC file to verify.") {
        {
            setRequired(true);
        }
    };
    
    private final Option dataRepoOption = 
        new Option("r", "data-repo", true, "The data repo directory.  Defaults to " + DATA_REPO_DEFAULT) {{
            setRequired(false);
        }};
        
    private final Option expectedFileOption = 
        new Option("x", "expected-info", true, "The XML file containging expected information.") {{
           setRequired(true); 
        }};
    
    private final Options options = new Options() { {
        addOption(startOption);
        addOption(endOption);
        addOption(dataRepoOption);
        addOption(expectedFileOption);
        addOption(fileOption);
    }};
    
    private Date startTime;
    private Date endTime;
    private File ktcFile;
    private File dataRepoDir;
    private File expectedInfoFile;
    private final SystemProvider system;
    
    private KtcVerifierCli(SystemProvider system) {
        this.system = system;
    }
    
    private void parseCommandLine(String[] argv) 
        throws org.apache.commons.cli.ParseException, 
               java.text.ParseException {
        if (argv.length == 0) {
            printUsage();
            system.exit(1);
            return;
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(options, argv);
        String startTimeStr = commandLine.getOptionValue(startOption.getOpt());
        String endTimeStr = commandLine.getOptionValue(endOption.getOpt());
        
        startTime = CliUtils.parseDate(startTimeStr);
        endTime = CliUtils.parseDate(endTimeStr);
        
        String ktcFileName = commandLine.getOptionValue(fileOption.getOpt());
        ktcFile = new File(ktcFileName);
        checkFile("KTC file ", ktcFile);
     
       
        String dataRepoDirName = 
            commandLine.getOptionValue(dataRepoOption.getOpt(), DATA_REPO_DEFAULT);
        dataRepoDir = new File(dataRepoDirName);
        checkFile("Data repo directory ", dataRepoDir);
        if (!dataRepoDir.isDirectory()) {
            system.err().println("Data repo directory \"" +
                dataRepoDir + "\" is not a directory.");
            system.exit(2);
            return;
        }
        
        String expectedInfoFileName = commandLine.getOptionValue(expectedFileOption.getOpt());
        expectedInfoFile = new File(expectedInfoFileName);
        checkFile("Expected info xml file ", expectedInfoFile);
    }
    
    private void checkFile(String errPrefix, File f) {
        if (!f.exists()) {
            system.err().println(errPrefix  + "\"" + f + "\" does not exist.");
            system.exit(2);
            return;
        }
        if (!f.canRead()) {
            system.err().println(errPrefix +"\""+ f + "\" is not readable.");
            system.exit(2);
            return;
        }
    }
    
    private void execute() throws XmlException, IOException {
        KtcVerifier ktcVerifier = 
            new KtcVerifier(ktcFile, dataRepoDir, expectedInfoFile);
        ktcVerifier.verify(startTime, endTime, dataRepoDir);
    }
    
    private void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp("java -cp ... gov.nasa.kepler.ar.exporter.ktc.verifier.KtcVerifierCli", options);
        PrintWriter printWriter = new PrintWriter(system.out());
        printWriter.println("KTC (Kepler Target Catalog) Verifier");
        helpFormatter.printHelp(printWriter, 80, "java -cp ... gov.nasa.kepler.ar.exporter.ktc.verifier.KtcVerifierCli",
            "", options, 4, 4, "");
    }
    
    public static void main(String[] argv) throws Exception {
        KtcVerifierCli cli = new KtcVerifierCli(new DefaultSystemProvider());
        
        cli.parseCommandLine(argv);
        cli.execute();
    }
}
