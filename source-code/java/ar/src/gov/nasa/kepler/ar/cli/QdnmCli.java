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

import gov.nasa.kepler.ar.exporter.FileNameFormatter;
import gov.nasa.kepler.ar.exporter.Qdnm;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileFind;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.cli.*;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 *
 */
public class QdnmCli {

	private static final Log log = LogFactory.getLog(QdnmCli.class);
	
	private static final File DONE = new File("/dev/null");
	
    private final SystemProvider system;
    private FileSourceSink fileSourceSink;
    private boolean sparse;
    private String[] files;
    private boolean parallelFind;
    private int nThreads;
    private List<Thread> allThreads;
    
    @SuppressWarnings("static-access")
    private final Option nThreadsOption = 
        OptionBuilder.withArgName("n threads")
                     .hasArg()
                     .isRequired(false)
                     .withDescription("Number of computational threads.  Defaults to number of processors.")
                     .withLongOpt("n-threads")
                     .create("n");
    
    @SuppressWarnings("static-access")
    private final Option parallelFindOption = 
        OptionBuilder.hasArg(false)
                     .isRequired(false)
                     .withDescription("Allows for processing files while finding them.  This means file names will no longer appear in sorted order.")
                     .withLongOpt("parallel-find")
                     .create("p");
    
    @SuppressWarnings("static-access")
    private final Option sparseFileOption =
        OptionBuilder.hasArg(false)
                     .isRequired(false)
                     .withDescription("Handles sparse files efficiently, but changes the MD5 signature as zeros are not read from holes.")
                     .withLongOpt("sparse")
                     .create("s");
    
    private final Options cliOptions;
    
    QdnmCli(SystemProvider system) {
        this.system = system;
        cliOptions = new Options();
        cliOptions.addOption(sparseFileOption);
        cliOptions.addOption(parallelFindOption);
        cliOptions.addOption(nThreadsOption);
    }
    
    void parse(String[] argv) throws Exception {
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = gnuParser.parse(cliOptions, argv);
        
        files = commandLine.getArgs();
        if (files.length == 0) {
            system.err().println("You must specify the files/directories to include in the manifest.");
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("You must specify the files/directories to include in the manifest.");
        }
        log.info("Command line specifies " + files.length + " files.");
        

        if (commandLine.hasOption(sparseFileOption.getOpt())) {
            sparse = true;
        }
        log.info("Sparse files is " + sparse);
        
        nThreads = Runtime.getRuntime().availableProcessors();
        if (commandLine.hasOption(nThreadsOption.getOpt())) {
            nThreads = Integer.parseInt(commandLine.getOptionValue(nThreadsOption.getOpt()));
        }
        log.info("Number of MD5 threads " + nThreads);
        
        fileSourceSink = 
          commandLine.hasOption(parallelFindOption.getOpt()) ?
              new BlockingQueueWrapper() : new TreeSetWrapper();
        parallelFind = commandLine.hasOption(parallelFindOption.getOpt());
        log.info("Parallel find is " + parallelFind);
    }
    
    void generate() throws Exception {
        FileNameFormatter fnameFormatter = new FileNameFormatter();
        String qdnmFname = fnameFormatter.qdnmFileName(new Date());
        allThreads = new ArrayList<Thread>();
        final Qdnm qdnm = new Qdnm();
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        
        if (parallelFind) {
            Thread findThread = new Thread(new FileSearcher(error), "File Searcher");
            findThread.setDaemon(true);
            findThread.start();
            allThreads.add(findThread);
            log.info("Started parallel find.");
        } else {
            FileSearcher searchFilesNow = new FileSearcher(error);
            searchFilesNow.run();
            if (error.get() != null) {
                log.fatal("", error.get());
                system.exit(-1);
                throw new Exception(error.get());
            }
        }
        
        for (int i=0; i < nThreads; i++) {
            Thread t = new Thread(new QdnmGenerator(error, qdnm), "MD5 Calculator - " + i);
            t.setDaemon(true);
            t.start();
            allThreads.add(t);
        }
        
        log.info("Started MD5 threads.");
        for (Thread t: allThreads) {
            t.join();
        }
        
        if (error.get() != null) {
            log.fatal("", error.get());
            system.exit(-1);
            throw new IOException("", error.get());
        }
        log.info("Generating file.");
        File qdnmFile = new File(qdnmFname);
        qdnm.export(qdnmFile);
        log.info("Generated QDNM file \"" + qdnmFile + "\".");
        log.info("Done.");
    }
    
    private void interruptThreads() {
        for (Thread t : allThreads) {
            if (t != Thread.currentThread()) {
                t.interrupt();
            }
        }
    }
    
    private void printUsage() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp(80, "QdnmCli [OPTIONS] <files+>", "", cliOptions, "", true);
    }
    
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
       QdnmCli cli = new QdnmCli(new DefaultSystemProvider());
       cli.parse(argv);
       cli.generate();
    }
    
    private final class QdnmGenerator implements Runnable {
        private final AtomicReference<Throwable> error;
        private final Qdnm qdnm;
        
        QdnmGenerator(AtomicReference<Throwable> error, Qdnm qdnm) {
            this.error = error;
            this.qdnm = qdnm;
        }
        
        @Override
        public void run() {
            try {
                while (true) {
                    if (error.get() != null) {
                        return;
                    }
                    File f = fileSourceSink.nextFile();
                    if (f == DONE) {
                        return;  //done
                    }
                    if (f.isDirectory()) {
                        continue;
                    }
                    qdnm.addDataProduct(f, sparse);
                }
            } catch (Throwable t) {
                error.compareAndSet(null, t);
                interruptThreads();
            }
        }
    }
    private final class FileSearcher implements Runnable {
        private final AtomicReference<Throwable> error;
        
        FileSearcher(AtomicReference<Throwable> error) {
            this.error = error;
        }
        
        @Override
        public void run() {
            try {
                for (String fname : files) {
                    File f = new File(fname);
                    if (!f.exists()) {
                        printUsage();
                        system.err().println("Failed to find file \"" + fname + "\".");
                        system.exit(1);
                        throw new IllegalArgumentException("Failed to find file \"" + fname + "\".");
                    }
        
                    if (!f.isDirectory()) {
                        fileSourceSink.addFile(f);
                        continue;
                    }
                    
                    FileFind fileFind = new FileFind(".*") {
                        public void visitFile(File dir, File f) throws IOException {
                            if (f.isDirectory()) {
                                return;
                            }
                            if (!f.canRead()) {
                                throw new IllegalArgumentException("File \"" + f + 
                                        "\" is not readable.");
                            }
                            if (error.get() != null) {
                                //Unfortunately there is no nice way to
                                //terminate the file find.
                                throw new IllegalStateException("Another thread had an exception.");
                            }
                            fileSourceSink.addFile(f);
                        }
                    };
                    
                    DirectoryWalker dWalker = new DirectoryWalker(f);
                    dWalker.traverse(fileFind);
        
                }
            } catch (Throwable t) {
                log.fatal("File find failed.", t);
                error.compareAndSet(null, t);
                interruptThreads();
            } finally {
                fileSourceSink.done();
            }
        }
    }
    
    private final class BlockingQueueWrapper implements FileSourceSink {
        private final LinkedBlockingQueue<File> queue =
            new LinkedBlockingQueue<File>(1024);
        
        @Override
        public void addFile(File f) {
            try {
                queue.put(f);
            } catch (InterruptedException e) {
                throw new IllegalStateException(e);
            }
        }

        @Override
        public File nextFile() {
            try {
                return queue.take();
            } catch (InterruptedException e) {
                throw new IllegalStateException(e);
            }
        }
        
        @Override
        public void done() {
            for (int i=0; i < nThreads; i++) {
                try {
                    queue.put(DONE);
                } catch (InterruptedException e) {
                    throw new IllegalStateException(e);
                }
            }
        }

    }
    
    /**
     * Assumes all the calls to add come before calls to nextFile()
     * @author Sean McCauliff
     *
     */
    private final class TreeSetWrapper implements FileSourceSink {

        private final SortedSet<File> packageFiles = 
            new TreeSet<File>(new Comparator<File>() {

            @Override
            public int compare(File o1, File o2) {
                return o1.getAbsolutePath().compareTo(o2.getAbsolutePath());
            }
            
        });
        

        @Override
        public synchronized void addFile(File f) {
            packageFiles.add(f);
        }

        @Override
        public synchronized File nextFile() {
            if (packageFiles.isEmpty()) {
                return DONE;
            }
            File f = packageFiles.first();
            packageFiles.remove(f);
            return f;
        }
        
        @Override
        public void done() {
            //This does nothing.
        }
    }

}
