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

package gov.nasa.kepler.pi.parameters;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class ParameterLibraryImportExportCli {

    public static String IMPORT_OPT = "import";
    public static String EXPORT_OPT = "export";
    public static String DRYRUN_OPT = "dryrun";

    private boolean importLib;
    private String[] filenames;
    private boolean dryrun;

    public ParameterLibraryImportExportCli(boolean importLib, String[] filenames, boolean dryrun) {
        this.importLib = importLib;
        this.filenames = filenames;
        this.dryrun = dryrun;
    }

    public void go() throws Exception {
        ParametersOperations paramOps = new ParametersOperations();
        List<ParameterSetDescriptor> results = null;

        for (String filename : filenames) {
            System.out.println("Importing: " + filename);
            if (importLib) {
                results = paramOps.importParameterLibrary(filename, null, dryrun);
            } else {
                // export
                results = paramOps.exportParameterLibrary(filename, null, dryrun);
            }

            if (dryrun) {
                System.out.println("*** DRYRUN MODE - reporting only, no changes or file generated ***");
            }

            for (ParameterSetDescriptor parameterSetDescriptor : results) {
                System.out.println(parameterSetDescriptor.toString());
            }
        }
    }

    private static void usageAndExit(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("pl-[import|export] [-dryrun] FILE", options);
        System.exit(-1);
    }

    public static void main(String[] args) {
        Options options = new Options();
        options.addOption(IMPORT_OPT, false, "import parameter library from xml file");
        options.addOption(EXPORT_OPT, false, "export parameter library to xml file");
        options.addOption(DRYRUN_OPT, false,
            "report only, library will not be changed or XML file will not be generated");

        CommandLineParser parser = new GnuParser();
        CommandLine cmdLine = null;
        try {
            cmdLine = parser.parse(options, args);
        } catch (ParseException e) {
            System.err.println("Illegal argument: " + e.getMessage());
            usageAndExit(options);
        }

        boolean importLib = cmdLine.hasOption(IMPORT_OPT);
        boolean exportLib = cmdLine.hasOption(EXPORT_OPT);
        boolean dryrun = cmdLine.hasOption(DRYRUN_OPT);

        if (importLib && exportLib) {
            System.err.println("ERROR: -import and -export are mutually exclusive");
            usageAndExit(options);
        }

        if (!importLib && !exportLib) {
            System.err.println("ERROR: -import or -export must be specified");
            usageAndExit(options);
        }

        String[] filenames = cmdLine.getArgs();

        if (filenames == null || filenames.length == 0) {
            System.err.println("ERROR: no file(s) specified");
            usageAndExit(options);
        }

        ParameterLibraryImportExportCli cli = new ParameterLibraryImportExportCli(importLib, filenames, dryrun);
        DatabaseService ds = DatabaseServiceFactory.getInstance();
        int exitCode = -2;
        try {
            ds.beginTransaction();
            cli.go();
            ds.commitTransaction();
            exitCode = 0;
        } catch (Throwable e) {
            System.err.println("ERROR: " + e);
            e.printStackTrace();
        } finally {
            ds.rollbackTransactionIfActive();
            System.exit(exitCode);
        }
        
    }

}
