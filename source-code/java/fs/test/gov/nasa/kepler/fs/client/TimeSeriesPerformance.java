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

import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.util.Arrays;
import java.util.Random;

/**
 * @author Sean McCauliff
 *
 */
public class TimeSeriesPerformance {

    private static final double READ_BATCH_SIZE =4000.0;

    private static void printUsage() {
        System.out.println("-id <id>");
        System.out.println("-nt <number of threads>");
        System.out.println("-ns <number of series> - one int and one float will be generated");
        System.out.println("-nd <number of data points per series>");
        System.out.println("-sc <start cadence number> - The cadence of the first time series. Optional.");
        System.out.println("-pgap <probablity of gap as a rational number> - like 1/30, optional");
        System.out.println("-r read");
        System.out.println("-w write");
        System.out.println("-m write with merging data instead of overwrite.");
    }
    
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {

        String id = "";
        int nthreads = 0;
        int nseries = 0;
        int seriesSize = 0;
        int startCadence = 0;
        boolean doRead = true;
        boolean doWrite = true;
        boolean mergeWrite = false;
        int gapNumerator = -1;
        int gapDenominator = -1;
        
        for (int i=0; i < argv.length; i++) {
            String option = argv[i];
            if (option.equals("-id")) {
                id = argv[++i];
            } else if (option.equals("-nt")) {
                nthreads = Integer.parseInt(argv[++i]);
            } else if (option.equals("-ns")) {
                nseries = Integer.parseInt(argv[++i]);
            } else if (option.equals("-nd")) {
                seriesSize = Integer.parseInt(argv[++i]);
            } else if (option.equals("-sc")) {
                startCadence = Integer.parseInt(argv[++i]);
            } else if (option.equals("-r")) {
                doWrite = false;
            } else if (option.equals("-w")) {
                doRead = false;
            } else if (option.equals("-m")) {
                doWrite = true;
                mergeWrite = true;
            } else if (option.equals("-pgap")) {
                String[] parts = argv[++i].split("/");
                gapNumerator = Integer.parseInt(parts[0]);
                gapDenominator = Integer.parseInt(parts[1]);
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
        
        if (nseries <= 0) {
            System.err.println("number of time series must be assigned");
            printUsage();
            System.exit(1);
        }
        
        if (seriesSize <= 0) {
            System.err.println("number of data points per series must be assigned");
            printUsage();
            System.exit(1);
        }

        if (!(doWrite || doRead)) {
            System.err.println("Can not have both read and write options.");
            printUsage();
            System.exit(1);
        }
        
        String fileStoreUrl = ConfigurationServiceFactory.getInstance().getString(FileStoreConstants.FS_FSTP_URL);
        System.out.println("Using file store \"" + fileStoreUrl + "\".");
        boolean[] gaps = new boolean[seriesSize];
        if (gapNumerator != -1) {
            Random rand = new Random(456);
            for (int i=0; i < gaps.length; i++) {
                if (gapNumerator >= ( rand.nextInt(gapDenominator) + 1)) {
                    gaps[i] = true;
                }
            }
        }
        System.out.println("Gaps: " + Arrays.toString(gaps));
        
        Thread[] workers = new Thread[nthreads];
        for (int i=0; i < nthreads;  i++) {
            String taskId = id + i;
            Runnable r = new RunTimeSeries(taskId, nseries, seriesSize, doRead, doWrite, startCadence, gaps, mergeWrite);
            workers[i] = new Thread(r, taskId);
        }
        for (Thread t : workers) {
            t.start();
        }
        for (Thread t : workers) {
            t.join();
        }
        
        System.exit(0);
    }

    /** Repacks ids into a chunks that can be read without reaching oom.
     * 
     * @param series
     * @return
     */
    private static FsId[][] collectIds(TimeSeries[] series) {
        FsId[][] ids = new FsId[(int)Math.ceil(series.length /READ_BATCH_SIZE)][];
        int idsRemaining = series.length;
        for (int batchi=0; batchi < ids.length; batchi++) {
            ids[batchi] = new FsId[Math.min((int) READ_BATCH_SIZE, idsRemaining)];
            for (int i=0; i < ids[batchi].length; i++, idsRemaining--) {
                ids[batchi][i]= series[idsRemaining - 1].id();
            }
        }
        return ids;
    }

    private static class RunTimeSeries implements Runnable {

        private final String taskId;
        private final int nseries;
        private final int seriesSize;
        private final boolean doRead;
        private final boolean doWrite;
        private final int startCadence;
        private final boolean[] gaps;
        private final boolean mergeWrites;
        
        
        public RunTimeSeries(String taskId, int nseries, int seriesSize,
                                            boolean doRead, boolean doWrite,
                                            int startCadence, boolean[] gaps,
                                            boolean mergeWrites) {
            this.taskId = taskId;
            this.nseries = nseries;
            this.seriesSize = seriesSize;
            this.doRead = doRead;
            this.doWrite = doWrite;
            this.startCadence = startCadence;
            this.gaps = gaps;
            this.mergeWrites = mergeWrites;
        }

        public void run() {
            try {
                FileStoreClient fsClient = FileStoreClientFactory.getInstance();

                int[] idata = new int[seriesSize];
                Arrays.fill(idata, 4223);
                float[] fdata = new float[seriesSize];
                Arrays.fill(fdata, (float)Math.PI);

                int endCadence  = startCadence + seriesSize - 1;

                IntTimeSeries[] its = new IntTimeSeries[nseries];
                FloatTimeSeries[] fts = new FloatTimeSeries[nseries];
                for (int i=0; i < nseries; i++) {
                    FsId id = new FsId("/perf/test-int/"+ taskId +":" +i);
                    its[i] = new IntTimeSeries(id, idata, startCadence, endCadence, gaps, 666);
                    id = new FsId("/perf/test-float/"+taskId+":"+i);
                    fts[i] =  new FloatTimeSeries(id, fdata, startCadence, endCadence, gaps, 666);
                }


                if (doWrite) {
                    long startTime = System.currentTimeMillis();
                    try {
                        fsClient.beginLocalFsTransaction();
                        fsClient.writeTimeSeries(its,!mergeWrites);
                        fsClient.writeTimeSeries(fts, !mergeWrites);
                        fsClient.commitLocalFsTransaction();
                    } finally {
                        fsClient.rollbackLocalFsTransactionIfActive();
                        // ((FileStoreTestInterface) fsClient).cleanFileStore();
                    }
    
                    long endTime = System.currentTimeMillis();
                    double durationSecs = ((double)endTime - startTime)/1000.0;
                    System.out.println("Write time "+taskId + " "+durationSecs+"s");
                }
                
                if (doRead) {
                    FsId[][] intIds = collectIds(its);
                    FsId[][] floatIds = collectIds(fts);
                    
                    long startTime = System.currentTimeMillis();
                    for (FsId[] ids : intIds) {
                        fsClient.readTimeSeriesAsInt(ids, startCadence, endCadence);
                    }
                    for (FsId[] ids : floatIds) {
                        fsClient.readTimeSeriesAsFloat(ids, startCadence, endCadence);
                    }
                    long endTime = System.currentTimeMillis();
                    
                    double durationSecs = ((double)endTime - startTime)/1000.0;
                    System.out.println("Read time "+taskId+" " +durationSecs+"s");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
    }
    
}
