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

import gov.nasa.kepler.ar.exporter.cal.CalibratedPixelExporter;
import gov.nasa.kepler.ar.exporter.cal.CalibratedPixelExporter.CadenceOption;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 * 
 */
@SuppressWarnings("serial")
public class CalibratedPixelExportCli {

    private static final Log log = LogFactory.getLog(KtcExportCli.class);
    private static final int BIG_CADENCE_CHUNK_SIZE_DEFAULT = 2 * 1024;
    private static final int N_THREADS_DEFAULT = 1;

    private final Option startOption = new Option("b", "begin", true,
        "The start long cadence number.  Even when using -s") {
        {
            setRequired(true);
        }
    };

    private final Option endOption = new Option("e", "end", true,
        "The end long cadence number.  Even when using -s.") {
        {
            setRequired(true);
        }
    };

    private final Option outputDirOption = new Option("o", "output",
        true, "The output directory, defaults to '.'.") {
        {
            setRequired(false);
        }
    };

    private final Option nThreadOption = new Option("t", "nthreads",
        true, "Number of threads to use when exporting.  Default is "
            + N_THREADS_DEFAULT + ".") {
        {
            setRequired(false);
        }
    };

    private final Option chunkSizeOption = new Option("c", "chunk-size",
        true, "Number of cadences to process at a time.  Default is "
            + BIG_CADENCE_CHUNK_SIZE_DEFAULT + ".") {
        {
            setRequired(false);
        }
    };
    
    private final Option shortCadenceOnlyOption = new Option("s", 
        "short-cadence-only", false, "Only export short cadnece.  Start and end " +
        		"cadences are still expressed in long cadence.") {
        {
            setRequired(false);
        }
    };
    
    private final Option longCadenceOnlyOption = new Option("l", 
        "long-cadence-only", false, "Only export long cadnece.") {
        {
            setRequired(false);
        }
    };


    private final Options options = new Options() {
        {
            addOption(startOption);
            addOption(endOption);
            addOption(outputDirOption);
            addOption(nThreadOption);
            addOption(chunkSizeOption);
            addOption(shortCadenceOnlyOption);
            addOption(longCadenceOnlyOption);
        }
    };

    private int startLongCadenceNumber;
    private int endLongCadenceNumber;
    private File outputDir;
    private int nThreads;
    private int cadenceChunkSize;
    private CadenceOption cadenceOption = CadenceOption.ALL;

    private final SystemProvider system;

    public CalibratedPixelExportCli(SystemProvider system) {
        this.system = system;
    }

    public void execute(String[] argv)
        throws org.apache.commons.cli.ParseException, IOException {

        if (!parseArgs(argv)) {
            return;
        }

        FileUtil.mkdirs(outputDir);
        
        File testNFS = new File(outputDir, "test.NFS");
        testNFS.createNewFile();
        File testNFSDest = new File(outputDir, "test.NFS.hardlink");
        try {
            FileUtil.hardlink(testNFS, testNFSDest);
        } catch (IOException ioe) {
            throw new IOException("Destination directory is NFS directory." +
                    "  This will result in bad performance.  Will not export.");
        } finally {
            testNFSDest.delete();
            testNFS.delete();
        }

        int bigCadenceChunkSize = endLongCadenceNumber - startLongCadenceNumber
            + 1;
        bigCadenceChunkSize = (int) Math.ceil((double) bigCadenceChunkSize
            / cadenceChunkSize);

        log.info("big cadence chunk size " + bigCadenceChunkSize);
        for (int memCadenceStart = startLongCadenceNumber; 
                memCadenceStart <= endLongCadenceNumber; 
                memCadenceStart += cadenceChunkSize) {

            int memCadenceEnd = Math.min(
                memCadenceStart + cadenceChunkSize - 1, endLongCadenceNumber);
            int workerChunkSize = (memCadenceEnd - memCadenceStart + 1)
                / nThreads;
            workerChunkSize = workerChunkSize == 0 ? 1 : workerChunkSize;

            log.info("workerChunkSize " + workerChunkSize + " mem cadences ["
                + memCadenceStart + "," + memCadenceEnd + "]");
            List<Thread> workerThreads = new ArrayList<Thread>();
            for (int workerCadenceStart = memCadenceStart; 
                   workerCadenceStart <= memCadenceEnd; 
                   workerCadenceStart += workerChunkSize) {

                int workerCadenceEnd = Math.min(workerCadenceStart
                    + workerChunkSize - 1, memCadenceEnd);
                Runnable exportRunner = new ExportRunner(outputDir,
                    workerCadenceStart, workerCadenceEnd, cadenceOption);
                Thread t = new Thread(exportRunner, "Export Runner ["
                    + workerCadenceStart + "," + workerCadenceEnd + "]");
                t.setDaemon(true);
                t.start();
                workerThreads.add(t);

            }

            for (Thread t : workerThreads) {
                try {
                    t.join();
                } catch (InterruptedException e) {
                    log.fatal("Interrupted.  Exiting.", e);
                    system.exit(-10);
                }
            }
        }

        log.info("Export complete.");

    }

    private void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        PrintWriter printWriter = new PrintWriter(system.out());
        helpFormatter.printHelp(printWriter, 80,
            "java -cp ... gov.nasa.kepler.ar.exporter.CalibratedPixelExporter",
            "", options, 2, 2, "", true);
        printWriter.flush();
    }

    private boolean parseArgs(String[] argv)
        throws org.apache.commons.cli.ParseException {
        if (argv.length == 0) {
            printUsage();
            system.exit(1);
            return false;
        }

        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(options, argv);
        String startTimeStr = commandLine.getOptionValue(startOption.getOpt())
            .trim();
        String endTimeStr = commandLine.getOptionValue(endOption.getOpt())
            .trim();
        String nThreadsStr = commandLine.getOptionValue(nThreadOption.getOpt());
        if (nThreadsStr == null) {
            nThreadsStr = N_THREADS_DEFAULT + "";
        }
        String cadenceChunkSizeStr = commandLine.getOptionValue(chunkSizeOption.getOpt());
        if (cadenceChunkSizeStr == null) {
            cadenceChunkSizeStr = BIG_CADENCE_CHUNK_SIZE_DEFAULT + "";
        }

        startLongCadenceNumber = Integer.parseInt(startTimeStr);
        endLongCadenceNumber = Integer.parseInt(endTimeStr);
        outputDir = new File(commandLine.getOptionValue(
            outputDirOption.getOpt())
            .trim());
        cadenceChunkSize = Integer.parseInt(cadenceChunkSizeStr.trim());
        nThreads = Integer.parseInt(nThreadsStr.trim());

        if (cadenceChunkSize <= 0) {
            throw new IllegalArgumentException("Bad cadence chunk size "
                + cadenceChunkSizeStr);
        }
        if (nThreads <= 0) {
            throw new IllegalArgumentException("Bad nThreads " + nThreadsStr);
        }
        
        if (commandLine.hasOption(shortCadenceOnlyOption.getOpt())) {
            if (commandLine.hasOption(longCadenceOnlyOption.getOpt())) {
                throw new IllegalArgumentException("Must use short-only or long-only, but not both.");
            }
            cadenceOption = CadenceOption.SHORT_ONLY;
        }
        if (commandLine.hasOption(longCadenceOnlyOption.getOpt())) {
            cadenceOption = CadenceOption.LONG_ONLY;
        }

        return true;
    }

    public static void main(String[] argv) throws Exception {
        DefaultSystemProvider system = new DefaultSystemProvider();
        CalibratedPixelExportCli cli = new CalibratedPixelExportCli(system);
        cli.execute(argv);
    }

    private static class ExportRunner implements Runnable {
        private final int startLongCadenceNumber;
        private final int endLongCadenceNumber;
        private final File outputDir;
        private final CadenceOption cadenceOption;

        public ExportRunner(File outputDir, int startLongCadenceNumber,
            int endLongCadenceNumber,
            CadenceOption cadenceOption) {
            this.startLongCadenceNumber = startLongCadenceNumber;
            this.endLongCadenceNumber = endLongCadenceNumber;;
            this.outputDir = outputDir;
            this.cadenceOption = cadenceOption;
        }

        public void run() {
            log.info("Worker thread exporting pixels for cadences ["
                + startLongCadenceNumber + "," + endLongCadenceNumber + "]");
            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            fsClient.disassociateThread();

            DatabaseService dbService = DatabaseServiceFactory.getInstance();
            DataAccountabilityTrailCrud datCrud = new DataAccountabilityTrailCrud(
                dbService);
            PipelineTaskCrud taskCrud = new PipelineTaskCrud(dbService);

            AlertLogCrud alertLogCrud = new AlertLogCrud();
            
            FcCrud fcCrud = new FcCrud();
            CalibratedPixelExporter exporter = new CalibratedPixelExporter(
                fsClient, datCrud, taskCrud, alertLogCrud, fcCrud);
            try {
                exporter.export(startLongCadenceNumber, endLongCadenceNumber,
                    outputDir, cadenceOption);
                log.info("Worker thread exiting.");
            } catch (Exception e) {
                log.error("Export failed.", e);
                return;
            }

        }
    }
}
