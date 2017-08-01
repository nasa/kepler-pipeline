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

package gov.nasa.kepler.pi.configuration;

import java.util.List;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class PipelineConfigImportExportCli {

    public static String IMPORT_OPT = "import";
    public static String EXPORT_OPT = "export";
    public static String DRYRUN_OPT = "dryrun";

    private boolean importLib;
    private String filename;
    private boolean dryrun;

    public PipelineConfigImportExportCli(boolean importLib, String filename, boolean dryrun) {
        this.importLib = importLib;
        this.filename = filename;
        this.dryrun = dryrun;
    }

    public void go() throws Exception {
        PipelineConfigurationOperations pipelineConfigOps = new PipelineConfigurationOperations();

        if (importLib) {
            //throw new PipelineException("ERROR: Import not yet implemented");
            pipelineConfigOps.importPipelineConfiguration(filename);
        } else {
            // export all triggers for now (maybe add an optional 'trigger name' option later
            TriggerDefinitionCrud crud = new TriggerDefinitionCrud();            
            List<TriggerDefinition> triggers = crud.retrieveAll();
            
            pipelineConfigOps.exportPipelineConfiguration(triggers, filename);
        }

        if (dryrun) {
            System.out.println("*** DRYRUN MODE - reporting only, no changes or file generated ***");
        }
    }

    private static void usageAndExit(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("pc-[import|export] [-dryrun] FILE", options);
        System.exit(-1);
    }

    public static void main(String[] args) {
        Options options = new Options();
        options.addOption(IMPORT_OPT, false, "import pipeline config from xml file");
        options.addOption(EXPORT_OPT, false, "export pipeline config to xml file");
        options.addOption(DRYRUN_OPT, false,
            "report only, configuration will not be changed or XML file will not be generated");

        CommandLineParser parser = new GnuParser();
        CommandLine cmdLine = null;
        try {
            cmdLine = parser.parse(options, args);
        } catch (ParseException e) {
            System.err.println("Illegal argument: " + e.getMessage());
            usageAndExit(options);
        }

        boolean importXml = cmdLine.hasOption(IMPORT_OPT);
        boolean exportXml = cmdLine.hasOption(EXPORT_OPT);
        boolean dryrun = cmdLine.hasOption(DRYRUN_OPT);

        if (importXml && exportXml) {
            System.err.println("ERROR: -import and -export are mutually exclusive");
            usageAndExit(options);
        }

        if (!importXml && !exportXml) {
            System.err.println("ERROR: -import or -export must be specified");
            usageAndExit(options);
        }

        String[] otherArgs = cmdLine.getArgs();

        if (otherArgs == null || otherArgs.length != 1) {
            System.err.println("ERROR: no file specified");
            usageAndExit(options);
        }

        String filename = otherArgs[0];

        PipelineConfigImportExportCli cli = new PipelineConfigImportExportCli(importXml, filename, dryrun);
        DatabaseService ds = DatabaseServiceFactory.getInstance();
        int exitCode = -2;
        try {
            ds.beginTransaction();
            cli.go();
            ds.commitTransaction();
            exitCode = 0;
        } catch (Exception e) {
            System.err.println("ERROR: " + e);
            e.printStackTrace();
        } finally {
            ds.rollbackTransactionIfActive();
            System.exit(exitCode);
        }
    }

}
