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

import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.io.ParallelDirectoryWalker;
import gov.nasa.spiffy.common.io.ParallelFileVisitor;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * A simple command like UNIX *find*.  This does not have all the complicated
 * features that *find* has, but it runs multiple find threads and can
 * accurately tell you the size of a sparse file to the nearest block.
 * 
 * @author Sean McCauliff
 *
 */
public class ParallelFindCli {

    public static void main(String[] argv) throws Exception {

        File rootDir = new File(argv[0]);
        if (!rootDir.exists()) {
            throw new Exception("Root dir \"" + rootDir + "\" does not exist.");
        }
        
        final boolean findSize = argv.length == 2 && argv[1].equals("--size");


        ParallelFileVisitor lister = new ParallelFileVisitor() {

            @Override
            public boolean visit(File f) throws IOException {
                StringBuilder bldr = new StringBuilder();
                if (f.isDirectory()) {
                    bldr.append(f);
                    if (findSize) {
                        bldr.append(" d");
                    }
                } else {
                    bldr.append(f);
                    if (findSize && f.getAbsolutePath().contains("blob")) {
                        bldr.append(" ").append(f.length());
                    } else if (findSize) {
                        SparseFileUtil sparseFileUtil = new SparseFileUtil();
                        List<SimpleInterval> extents = sparseFileUtil.extents(f);
                        long size = 0;
                        if (!extents.isEmpty()) {
                            for (SimpleInterval ext : extents) {
                                size += ext.end() - ext.start() + 1;
                            }
                        }
                        bldr.append(" ").append(size);
                    }
                }
                System.out.println(bldr);
                return false;
            }
        };

        
        ThreadFactory threadFactory = new ThreadFactory() {
            final AtomicInteger threadCount = new AtomicInteger();
            @Override
            public Thread newThread(Runnable r) {
                Thread t = new Thread(r, "FindThread "  + threadCount.getAndIncrement());
                t.setDaemon(true);
                return t;
            }
        };
        
        int maxThread = Runtime.getRuntime().availableProcessors() * 4; 
        ExecutorService exeService = Executors.newFixedThreadPool(maxThread, threadFactory);
                                                                  
        ParallelDirectoryWalker pWalker = 
            new ParallelDirectoryWalker(exeService, rootDir, lister);
        pWalker.traverse();
        exeService.shutdown();
    }
}

