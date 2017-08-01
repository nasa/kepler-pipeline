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

import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.SQLException;
import java.util.Formatter;
import java.util.HashSet;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Routines for ingesting SCP (Stellar Classification Program) data into the KIC
 * (Kepler Information Catalog).
 * 
 * @author Bill Wohler
 */
public class KicIngester {

    /** Name of KIC manifest file. */
    public static final String MANIFEST = "Manifest";

    /** Command used to verify manifest file. */
    public static final String MD5SUM_COMMAND = "md5sum --check ";

    private static final int TRACE_PERIOD = 1000;
    private static final int TRACE_DELAY = 100;
    private static final int MAX_DISPLAYED_ERRORS_PER_FILE = 5;
    private static final Log log = LogFactory.getLog(KicIngester.class);

    /**
     * Ingests KIC data from files.
     * <p>
     * This method treats each file as a single atomic unit. If there are any
     * errors while reading a file, they are logged, but this method still tries
     * to load the rest of the rows in the file as well as the rest of the
     * matching files in the directory. If an error was encountered while
     * loading a file, any other rows in that file that had been loaded are
     * rolled back and after reading all files, an IngestScpException is thrown.
     * 
     * @param files the files to ingest
     * @throws PipelineException if the directory does not exist or if there
     * aren't any data files
     * @throws IngestScpException if there were any errors loading the data
     */
    public static void ingestScpFiles(File[] files) {
        ingestScpFiles(files, new IngestScpState());
    }

    /**
     * Ingests KIC data from files.
     * <p>
     * This method treats each file as a single atomic unit. If there are any
     * errors while reading a file, they are logged, but this method still tries
     * to load the rest of the rows in the file as well as the rest of the
     * matching files in the directory. If an error was encountered while
     * loading a file, any other rows in that file that had been loaded are
     * rolled back and after reading all files, an IngestScpException is thrown.
     * <p>
     * The progress can be monitored by inspecting the content of the state
     * parameter periodically.
     * 
     * @param files the files to ingest
     * @param state the current state of the ingest process
     * @throws PipelineException if the directory does not exist or if there
     * aren't any data files
     * @throws IngestScpException if there were any errors loading the data
     */
    public static void ingestScpFiles(File[] files, IngestScpState state) {
        state.setTotalFileCount(files.length);
        state.setTotalCharCount(sumFileSizes(files));

        long startTime = System.currentTimeMillis();
        int fileCount = 0;
        int errorCount = 0;
        DatabaseService dbs = DatabaseServiceFactory.getInstance();
        KicCrud kicCrud = new KicCrud();
        for (int i = 0; i < files.length; i++) {
            boolean success = false;
            dbs.beginTransaction();
            try {
                state.setName(files[i].getName());
                state.setFileCount(i + 1);
                ingestScpFile(files[i], kicCrud, state);
                dbs.commitTransaction();
                success = true;
            } catch (IngestScpException e) {
                log.error(files[i] + " had " + e.getErrorCount() + " errors");
                fileCount++;
                errorCount += e.getErrorCount();
            } finally {
                dbs.rollbackTransactionIfActive();
                if (!success) {
                    log.error("Rolling back rest of entries in \"" + files[i]
                        + "\".");

                }
            }
        }

        log.debug("Ingested " + files[0].getParent()
            + (errorCount > 0 ? " un" : " ") + "successfully in "
            + (System.currentTimeMillis() - startTime) + " ms");

        if (errorCount > 0) {
            throw new IngestScpException(errorCount, fileCount);
        }
    }

    /**
     * Returns the total file size of the given files.
     * 
     * @param files the files to sum
     * @return the total size, in bytes
     */
    private static long sumFileSizes(File[] files) {
        long sum = 0;
        for (File file : files) {
            sum += file.length();
        }

        return sum;
    }

    /**
     * Ingests KIC data from the given file.
     * <p>
     * This method treats the file as a single atomic unit. If there are any
     * errors while reading a file, they are logged, but this method still tries
     * to load the rest of the rows in the file. If an error was encountered
     * while loading the file, any other rows that had been loaded are rolled
     * back and an IngestScpException is thrown.
     * 
     * @param file the file containing the SCP data
     * @param kicCrud the KIC operations object used to load the data
     * @param state the current state of the ingest process
     * @throws PipelineException if the file does not exist
     * @throws IngestScpException if there were any errors loading the data
     */
    private static void ingestScpFile(File file, KicCrud kicCrud,
        IngestScpState state) {

        int errorCount = 0;
        try {
            BufferedReader br = new BufferedReader(new FileReader(file));
            try {
                for (String s = br.readLine(); s != null; s = br.readLine()) {
                    try {
                        Kic kic = Kic.valueOf(s);
                        kicCrud.create(kic);
                        state.incrementRowCount();
                        state.incrementCharCount(s.length());
                    } catch (Exception e) {
                        if (errorCount < MAX_DISPLAYED_ERRORS_PER_FILE) {
                            log.error(e);
                        } else if (errorCount == MAX_DISPLAYED_ERRORS_PER_FILE) {
                            log.error("Suppressing rest of errors for " + file);
                        }
                        errorCount++;
                    }
                }
            } finally {
                br.close();
            }
        } catch (Exception e) {
            throw new PipelineException(e);
        }
        if (errorCount > 0) {
            throw new IngestScpException(errorCount);
        }
    }

    public static void main(String[] args) {
        if (args.length < 2 || args[0] == null || args[1] == null) {
            usage();
        }
        File directory = new File(args[0]);
        String pattern = args[1];

        IngestScpState state = new IngestScpState();
        TimerTask timerTask = new IngestScpStateDisplayer(state);
        try {
            File[] files = getScpFiles(directory, pattern);
            validateManifest(directory, MANIFEST, files);

            initializeDb();

            new Timer().scheduleAtFixedRate(timerTask, TRACE_DELAY,
                TRACE_PERIOD);
            ingestScpFiles(files, state);
            timerTask.cancel();
        } catch (PipelineException e) {
            System.out.println(e.getMessage() + "; see log for details");
        } catch (Exception e) {
            System.out.println(e + "; see log for details");
            e.printStackTrace();
        } finally {
            timerTask.cancel();
        }

        System.exit(0);
    }

    /**
     * Creates and initializes database.
     * 
     * @throws PipelineException
     * @throws SQLException
     * @throws ClassNotFoundException
     * @throws IOException
     */
    private static void initializeDb() throws SQLException,
        ClassNotFoundException, IOException {

        DatabaseServiceFactory.getInstance()
            .getDdlInitializer()
            .initDB();
    }

    /**
     * Returns an array of File objects in directory that match pattern.
     * 
     * @param directory the directory containing the files
     * @param pattern a regexp that matches the filenames
     * @return an array of File objects
     * @throws PipelineException if the directory does not exist, or no files
     * match the pattern
     */
    static File[] getScpFiles(File directory, final String pattern) {

        if (!directory.exists()) {
            throw new PipelineException("Directory " + directory + " not found");
        }

        File[] files = directory.listFiles(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                return name.matches(pattern);
            }
        });
        if (files.length == 0) {
            throw new PipelineException("No SCP files matching " + pattern
                + " in " + directory);
        }

        return files;
    }

    /**
     * Validates the manifest in the given directory. Also ensures that all
     * files listed in the parameter are accounted for in the manifest.
     * 
     * @param directory the directory containing the files
     * @param manifest the name of the manifest file
     * @param files the files in the directory that are to be loaded
     * @throws PipelineException if the directory does not exist or there is a
     * problem running md5sum
     */
    static void validateManifest(File directory, String manifest, File[] files) {

        if (!directory.exists()) {
            throw new PipelineException("Directory " + directory + " not found");
        }

        try {
            BufferedReader stdout = null;
            BufferedReader stderr = null;

            try {
                Set<String> checkedFiles = fileSet(files);

                System.out.print("Checking manifest...");
                Process process = Runtime.getRuntime()
                    .exec(MD5SUM_COMMAND + manifest, null, directory);

                // Printed out "FAILED" messages so operator can have an
                // idea where to look.
                stdout = new BufferedReader(new InputStreamReader(
                    process.getInputStream()));
                String input;
                boolean seenError = false;
                while ((input = stdout.readLine()) != null) {
                    String[] fields = input.split(": ");
                    String file = fields[0];
                    String status = fields[1];
                    if (!status.matches("OK")) {
                        if (!seenError) {
                            // Add newline to initial message.
                            System.out.println();
                            seenError = true;
                        }
                        System.out.println(input);
                    }
                    if (checkedFiles.contains(file)) {
                        checkedFiles.remove(file);
                    }
                }

                // Grab stderr, if any.
                stderr = new BufferedReader(new InputStreamReader(
                    process.getErrorStream()));
                String error = null;
                while ((input = stderr.readLine()) != null) {
                    error = input; // save it
                }
                if (process.waitFor() != 0) {
                    throw new PipelineException(error);
                }

                if (checkedFiles.size() != 0) {
                    if (!seenError) {
                        // Add newline to initial message.
                        System.out.println();
                        seenError = true;
                    }
                    String s = "Manifest did not mention the following files: "
                        + checkedFiles;
                    throw new PipelineException(s);
                }
            } finally {
                if (stdout != null) {
                    stdout.close();
                }
                if (stderr != null) {
                    stderr.close();
                }
            }
        } catch (IOException e) {
            throw new PipelineException(e.getMessage());
        } catch (InterruptedException e) {
            throw new PipelineException(e.getMessage());
        }

        System.out.println("done");
    }

    /**
     * Create a set of filenames for the given files.
     * 
     * @param files the files in the directory that are to be loaded
     * @return a set of filenames for the given files
     */
    private static Set<String> fileSet(File[] files) {
        Set<String> fileSet = new HashSet<String>();
        for (File file : files) {
            fileSet.add(file.getName());
        }

        return fileSet;
    }

    /**
     * Displays the usage for this program.
     */
    private static void usage() {
        StringBuilder s = new StringBuilder();
        s.append("Usage: java KicIngester directory regexp\n");
        s.append("The regular expression regexp is used to select ");
        s.append("the files to read from the given directory.");
        System.out.println(s);
    }

    /**
     * A timer task that displays the progress of an ingest task.
     * 
     * @author Bill Wohler
     */
    public static class IngestScpStateDisplayer extends TimerTask {
        private IngestScpState state;
        private StringBuilder current = new StringBuilder();
        private StringBuilder rate = new StringBuilder();
        private long start = System.currentTimeMillis();

        /**
         * Creates an IngestScpStateDisplayer with the given state.
         * 
         * @param state the current ingest state
         */
        public IngestScpStateDisplayer(IngestScpState state) {
            this.state = state;
        }

        /**
         * Displays the current progress. The output will ultimately look like
         * this:
         * 
         * <pre>
         * 1/30 files 1% [d0000.mrg 0/16.8 kB 0%]            1207 rows/s 1:01:01
         * </pre>
         * 
         * This says that we're on file 1 of 30, or 1% of the number of files.
         * We're working on d0000.mrg and we've processed 0 out of 16.8 kB, or
         * 0% of the file. Finally, our rate is 1207 rows/s and it will take
         * approximately 1 hour, 1 minute and 1 second to complete the job.
         */
        @Override
        public void run() {
            if (state.getCharCount() == 0) {
                // We haven't started yet.
                return;
            }

            current.setLength(0);
            current.append(state.getFileCount())
                .append("/");
            current.append(state.getTotalFileCount())
                .append(" files ");
            current.append(100 * state.getFileCount()
                / Math.max(state.getTotalFileCount(), 1));
            current.append("% [")
                .append(state.getName())
                .append("]");

            long duration = Math.max(
                (System.currentTimeMillis() - start) / 1000, 1);
            rate.setLength(0);
            rate.append(state.getRowCount() / duration)
                .append(" rows/s ");

            long timeLeft = (state.getTotalCharCount() - state.getCharCount())
                * duration / state.getCharCount();
            rate.append(new Formatter().format("%d:%02d:%02d", timeLeft / 3600,
                timeLeft / 60 % 60, timeLeft % 60)
                .toString());

            System.out.printf("\r%-55s%24s", current.toString(),
                rate.toString());
        }

        /**
         * Cancels this timer task. In addition, it shows the final rate and
         * time taken and adds a newline.
         */
        @Override
        public boolean cancel() {
            if (state.getCharCount() == 0) {
                // We haven't started yet.
                return super.cancel();
            }
            current.setLength(0);
            current.append(state.getFileCount())
                .append("/");
            current.append(state.getTotalFileCount())
                .append(" files ");
            current.append(100 * state.getFileCount()
                / Math.max(state.getTotalFileCount(), 1));
            current.append("%");

            long duration = Math.max(
                (System.currentTimeMillis() - start) / 1000, 1);
            rate.setLength(0);
            rate.append(state.getRowCount() / duration)
                .append(" rows/s ");

            long timeLeft = (state.getTotalCharCount() - state.getCharCount())
                * duration / state.getCharCount();
            rate.append(new Formatter().format("%d:%02d:%02d", timeLeft / 3600,
                timeLeft / 60 % 60, timeLeft % 60)
                .toString());

            System.out.printf("\r%-55s%24s\n", current.toString(),
                rate.toString());

            return super.cancel();
        }
    }
}
