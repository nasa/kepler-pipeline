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

package gov.nasa.kepler.common.file;

import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.ParallelDirectoryWalker;
import gov.nasa.spiffy.common.io.ParallelFileVisitor;
import gov.nasa.spiffy.common.os.ProcessUtils;
import gov.nasa.spiffy.common.os.ProcessUtils.ProcessOutput;

import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.io.*;

import org.apache.commons.cli.*;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Copy a bunch of files, preserving sparseness.  There is some hackery in here
 * while I test this out.  This is here to make a copy of the file store.
 * 
 * @author Sean McCauliff
 *
 */
public final class ParallelCopyCli {

    private static final Log log = LogFactory.getLog(ParallelCopyCli.class);
    
    
    @SuppressWarnings("static-access")
    private static final Option jobsOption =  OptionBuilder.hasArg()
        .withArgName("n")
        .withDescription("The number of threads to use for copying files.  Default is 2 * ncores.")
        .withLongOpt("jobs")
        .create("j");
    
    @SuppressWarnings("static-access")
    private static final Option srcOption = OptionBuilder.hasArg()
        .isRequired()
        .withArgName("src-dir")
        .withDescription("The source directory.")
        .withLongOpt("src")
        .create("s");
    
    @SuppressWarnings("static-access")
    private static final Option destOption = OptionBuilder.hasArg()
        .isRequired()
        .withArgName("dest-dir")
        .withLongOpt("dest")
        .withDescription("The destination directory.  This will be created if it does not exist.")
        .create("d");
    
    @SuppressWarnings("static-access")
    private static final Option chownOption = OptionBuilder.hasArg()
        .withArgName("user-name")
        .withDescription("Perform a chown option on the destination.")
        .withLongOpt("user-name")
        .create("u");
    
    private static final Options cliOptions = 
        new Options().addOption(jobsOption).addOption(srcOption).addOption(destOption).addOption(chownOption);
    
    private static void printHelp() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp(80, "./runjava pcp ", "", cliOptions, "", true);
    }
    
    /**
     * 
     * @param destDir assumes canonical file
     * @param srcDir assumes canonical file
     * @param visitedFile assumes canonical file
     * @return
     */
    private static File destFile(File destDir, File srcDir, File visitedFile) {
        String subPath = visitedFile.toString().substring(srcDir.toString().length());
        String newPrefix = destDir.toString();
        if (!newPrefix.endsWith("/")) {
            newPrefix += "/";
        }
        return new File(newPrefix + subPath);
    }

    public static void main(String[] argv) throws Exception {

        GnuParser gnuParser = new GnuParser();
        CommandLine cmdLine = null;
        try {
            cmdLine = gnuParser.parse(cliOptions, argv);
        } catch (MissingOptionException mis) {
            printHelp();
            throw mis;
        }
        
        
        final File srcDir = new File(cmdLine.getOptionValue(srcOption.getOpt())).getCanonicalFile();
        final File destDir = new File(cmdLine.getOptionValue(destOption.getOpt())).getCanonicalFile();
        if (!srcDir.exists()) {
            printHelp();
            throw new Exception("Src dir \"" + srcDir + "\" does not exist.");
        }
        
        String defaultThreadsStr= Integer.toString(Runtime.getRuntime() .availableProcessors() * 2);
        int nThreads = 0;
        try {
            nThreads = Integer.parseInt(cmdLine.getOptionValue(jobsOption.getOpt(), defaultThreadsStr));
        } catch (NumberFormatException nfe) {
            printHelp();
            throw nfe;
        }

        final String destOwner = cmdLine.getOptionValue(chownOption.getOpt());
        if (destOwner != null) {
            log.info("Destination files will be owned by user \"" + destOwner + "\".");
        }
        FileUtil.mkdirs(destDir);

        final AtomicLong visitedCount = new AtomicLong(0);
        
        final SparseFileUtil sparseFileUtil = new SparseFileUtil();
        ParallelFileVisitor lister = new ParallelFileVisitor() {

            @Override
            public boolean visit(File f) throws IOException {
                long currentFileCount = visitedCount.incrementAndGet();
                if (currentFileCount % 10000 == 0) {
                    log.info("Visiting " + currentFileCount + "th file : \"" + f + "\".");
                }
                boolean pruned = false;
                f = f.getCanonicalFile();
                File destFile = destFile(destDir, srcDir, f);
                if (f.isDirectory()) {
                    //Prune empty directories
                    if (f.list().length != 0) {
                        FileUtil.mkdirs(destFile);
                    } else {
                        pruned = true;
                    }
                } else {
                    //I know everything in the blob dir is not a sparse file.
                    //Index files are sparse, but do not need to be sparse.
                    if (f.toString().contains("blob") || f.getName().contains("index")) {
                        FileUtils.copyFile(f, destFile);
                    } else {
                        sparseFileUtil.copySparseFile(f, destFile);
                    }
                }
                if (!pruned && destOwner != null) {
                    try {
                        String chownCmd = "chown " + destOwner + " " + destFile;
                        ProcessOutput chownOut = 
                            ProcessUtils.grabOutput(chownCmd);
                        if (chownOut.returnCode() != 0) {
                            throw new IOException(chownCmd + "\n" + chownOut.err());
                        }
                    } catch (InterruptedException e) {
                        throw new IOException(e);
                    }
                    
                }
                return pruned;
            }
        };

        final AtomicInteger threadId = new AtomicInteger();
        final ExecutorService exeService = Executors.newFixedThreadPool(nThreads,
            new ThreadFactory() {
            public Thread newThread(Runnable r) {
                Thread t = new Thread(r);
                t.setDaemon(true);
                t.setName("CopierThread " + threadId.getAndIncrement());
                return t;
            }
        });

        ParallelDirectoryWalker pWalker = 
            new ParallelDirectoryWalker(exeService, srcDir, lister);
        pWalker.traverse();
        exeService.shutdown();
    }
}
