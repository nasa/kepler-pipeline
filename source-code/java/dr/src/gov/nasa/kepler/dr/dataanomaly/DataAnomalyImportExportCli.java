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

package gov.nasa.kepler.dr.dataanomaly;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomalyModel;
import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.File;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class DataAnomalyImportExportCli {
    private static final Log log = LogFactory.getLog(DataAnomalyImportExportCli.class);

    private static String IMPORT_OPT = "import";
    private static String EXPORT_OPT = "export";
    private static String PIPELINE_INSTANCE_OPT = "pi";
    private static String NO_REVISION_OPT = "norevisions";

    private boolean importFile;
    private String filename;
    private boolean includeRevision;

    public DataAnomalyImportExportCli(boolean importFile, String filename,
        boolean includeRevision) {
        this.importFile = importFile;
        this.filename = filename;
        this.includeRevision = includeRevision;
    }

    public void go(long pipelineInstanceId) throws Exception {
        File file = new File(filename);

        ModelOperations<DataAnomalyModel> modelOperations = ModelOperationsFactory.getDataAnomalyInstance(new ModelMetadataRetrieverLatest());

        if (importFile) {
            DataAnomalyImporter importer = new DataAnomalyImporter();
            List<DataAnomaly> importedAnomalies = importer.importFile(file);
            DataAnomalyModel dataAnomalyModel = new DataAnomalyModel(
                Model.NULL_REVISION, importedAnomalies);
            modelOperations.replaceExistingModel(dataAnomalyModel,
                DataAnomalyModel.DEFAULT_DESCRIPTION);
        } else {
            // export
            DataAnomalyExporter exporter = new DataAnomalyExporter();

            if (pipelineInstanceId != -1) {
                log.info("Only exporting data anomaly flags for pipeline instance ID = "
                    + pipelineInstanceId);

                ModelOperations<DataAnomalyModel> modelOperationsPipelineInstance = ModelOperationsFactory.getDataAnomalyInstance(new ModelMetadataRetrieverPipelineInstance(
                    pipelineInstanceId));

                List<DataAnomaly> anomaliesToExport = modelOperationsPipelineInstance.retrieveModel()
                    .getDataAnomalies();
                exporter.export(anomaliesToExport, file, pipelineInstanceId,
                    includeRevision);
            } else {
                List<DataAnomaly> anomaliesToExport = modelOperations.retrieveModel()
                    .getDataAnomalies();
                exporter.export(anomaliesToExport, file, includeRevision);
            }
        }
    }

    private static void usageAndExit(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp(
            "da-[import|export] [-pi PIPELINE_INSTANCE_ID] [-nometadata] FILE",
            options);
        System.exit(-1);
    }

    public static void main(String[] args) {
        Options options = new Options();
        options.addOption(IMPORT_OPT, false,
            "import data anomaly specifications from xml file");
        options.addOption(EXPORT_OPT, false,
            "export data anomaly specifications to xml file");
        options.addOption(PIPELINE_INSTANCE_OPT, true,
            "export for specified pipeline instance (export only)");
        options.addOption(
            NO_REVISION_OPT,
            false,
            "don't export metadata (useful for diffing XML files from different environments)");

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

        if (importLib && exportLib) {
            System.err.println("ERROR: -import and -export are mutually exclusive");
            usageAndExit(options);
        }

        if (!importLib && !exportLib) {
            System.err.println("ERROR: -import or -export must be specified");
            usageAndExit(options);
        }

        long pipelineInstanceId = -1;
        if (cmdLine.hasOption(PIPELINE_INSTANCE_OPT)) {
            String v = cmdLine.getOptionValue(PIPELINE_INSTANCE_OPT, "-1");
            try {
                pipelineInstanceId = Long.parseLong(v);
            } catch (NumberFormatException e) {
                System.err.println("ERROR: illegal value for pipeline instance id ("
                    + v + "), must be a number");
                usageAndExit(options);
            }
        }

        boolean includeRevision = !cmdLine.hasOption(NO_REVISION_OPT);

        String[] otherArgs = cmdLine.getArgs();

        if (otherArgs == null || otherArgs.length != 1) {
            System.err.println("ERROR: no file specified");
            usageAndExit(options);
        }

        String filename = otherArgs[0];

        DataAnomalyImportExportCli cli = new DataAnomalyImportExportCli(
            importLib, filename, includeRevision);
        DatabaseService ds = DatabaseServiceFactory.getInstance();
        try {
            ds.beginTransaction();
            cli.go(pipelineInstanceId);
            ds.commitTransaction();
        } catch (Exception e) {
            System.err.println("ERROR: " + e);
            e.printStackTrace();
        } finally {
            ds.rollbackTransactionIfActive();
        }
    }

}
