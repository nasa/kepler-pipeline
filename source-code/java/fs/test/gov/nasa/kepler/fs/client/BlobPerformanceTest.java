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

package gov.nasa.kepler.fs.client;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.StreamedBlobResult;

import java.io.OutputStream;

/**
 * @author Sean McCauliff
 *
 */
public class BlobPerformanceTest {
    
    
    private static void printUsage() {
        System.out.println("-id <id>");
        System.out.println("-nt <number of threads>");
        System.out.println("-s <blob size in bytes>");
        System.out.println("-nb <number of blobs>");
        System.out.println("-r - read only");
        System.out.println("-w write only");
    }
    
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {

        int blobSize = -1;
        int nBlobs = 0;
        String id = "";
        boolean doRead = true;
        boolean doWrite = true;
        int nthreads = 0;
        
        for (int i=0; i < argv.length; i++) {
            String option = argv[i];
            if (option.equals("-id")) {
                id = argv[++i];
            } else if (option.equals("-nt")) {
                nthreads = Integer.parseInt(argv[++i]);
            } else if (option.equals("-s")) {
                blobSize = Integer.parseInt(argv[++i]);
            } else if (option.equals("-nb")) {
                nBlobs = Integer.parseInt(argv[++i]);
            } else if (option.equals("-r")) {
                doRead = false;
            } else if (option.equals("-w")) {
                doWrite = true;
            } else {
                System.err.println("Bad option \"" + option + "\".");
                printUsage();
                System.exit(1);
            }
        }
        
        if (id.equals("")) {
            System.err.println("id must be assigned.");
            printUsage();
            System.exit(1);
        }
        
        if (nthreads <= 0) {
            System.err.println("nthreads must be assigned");
            printUsage();
            System.exit(1);
        }
        
        if (nBlobs <= 0) {
            System.err.println("Number of blobs must be assigned");
            printUsage();
            System.exit(1);
        }
        
        if (blobSize < 0) {
            System.err.println("Numer of blobs must be assigned");
            printUsage();
            System.exit(1);
        }

        if (!(doWrite || doRead)) {
            System.err.println("Can not have both readOnly and writeOnly options.");
            printUsage();
            System.exit(1);
        }
        
        Thread[] workers = new Thread[nthreads];
        for (int i=0; i < nthreads;  i++) {
            String taskId = id + i;
            workers[i] = new Thread(new RunBlob(taskId, blobSize, nBlobs, doRead, doWrite));
        }
        for (Thread t : workers) {
            t.start();
        }
        for (Thread t : workers) {
            t.join();
        }

        System.exit(0);

    }
    
    
    private static class RunBlob implements Runnable {

        private final  String fsidPrefix;
        private final  int nBlobs;
        private final int blobSize;
        private final String taskId;
        private final boolean doRead;
        private final boolean doWrite;
        
        RunBlob(String taskId, int blobSize, int nBlobs, boolean doRead, boolean doWrite) {
            this.nBlobs = nBlobs;
            this.blobSize = blobSize;
            this.taskId = taskId;
            this.doRead = doRead;
            this.doWrite = doWrite;
            this.fsidPrefix = "/test/blob-performance/" + taskId;
            
        }
        public void run() {
            try {

                FileStoreClient fsClient = FileStoreClientFactory.getInstance();
                
                if (doWrite) {
                    long startTime = System.currentTimeMillis();
                    
                    fsClient.beginLocalFsTransaction();
                    
                    byte[] data = new byte[blobSize];
                    for (int i=0; i <nBlobs; i++) {
                        FsId id = new FsId(fsidPrefix+i);
                        OutputStream out = fsClient.writeBlob(id, 9090);
                        out.write(data);
                        out.close();
                    }
                
                    
                    fsClient.commitLocalFsTransaction();
                    long endTime = System.currentTimeMillis();
                    double  duration = ((double)endTime - startTime)/1000.0;
                    System.out.println("Write time "+ taskId + " " + duration+"s");
                }
                
                if (doRead) {
                    long startTime = System.currentTimeMillis();
                    fsClient.beginLocalFsTransaction();
              
                    byte[] data = new byte[blobSize];
                    for (int i=0; i < nBlobs; i++) {
                        FsId id = new FsId(fsidPrefix+i);
                        StreamedBlobResult sbResult = fsClient.readBlobAsStream(id);
                        DataInputStream in = new DataInputStream(sbResult.stream());
                        in.readFully(data);
                        sbResult.stream().close();
                    }
                    
                    fsClient.rollbackLocalFsTransaction();
                    long endTime = System.currentTimeMillis();
                    double duration = ((double) endTime - startTime) / 1000.0;
                    System.out.println("Read time "+ taskId + " " + duration + "s");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            
        }
        
    }

}
