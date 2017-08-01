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

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;

import java.util.Arrays;
import java.util.Random;

/**
 * @author Sean McCauliff
 *
 */
public class MjdTimeSeriesTest {
    
    
    private static int nSeriesPerMonth = 64000;
    private static final Random rand = new Random(0L);
    private static final int POINTS_PER_MONTH =  1 /* corrections per day */ * 30;
    
    /**
     * @param args
     */
    public static void main(String[] argv) throws Exception {
        
        String id = argv[0];
        final double startTime = Double.parseDouble(argv[1]);
        nSeriesPerMonth = Integer.parseInt(argv[2]);
        
        Thread[] workers = new Thread[8];
        for (int i=0; i < workers.length; i++) {
            Thread t = new Thread(new RayRunner(id, i, startTime), id + i);
            t.setDaemon(true);
            t.start();
            workers[i] = t;
        }
        
        for (Thread t : workers) {
            t.join();
        }
        
        System.exit(0);
    }
    
    private static class RayRunner implements Runnable {
        private final String processName;
        private final int wokerId;
        private final double mjdStartTime;
        
       RayRunner(String processName, int workerId, double startTime) {
           this.processName = processName;
           this.wokerId = workerId;
           this.mjdStartTime = startTime;
       }
       
       public void run() {
           try {
              //  DatabaseService dbService = DatabaseServiceFactory.getInstance();
                //CosmicRayStore crStore = new OracleCosmicRayStore(dbService);
                FileStoreClient crStore = FileStoreClientFactory.getInstance();
                crStore.beginLocalFsTransaction();
                
                FloatMjdTimeSeries[] series_a = new FloatMjdTimeSeries[nSeriesPerMonth];
                String crPrefix = processName + ":" + wokerId + ":";
                for (int i=0; i < nSeriesPerMonth; i++) {
                    FsId id = new FsId("/cosmic-ray/" + crPrefix + i);
                    double[] mjd = new double[POINTS_PER_MONTH];
                    //double timeStart = rand.nextDouble();
                    for (int t=0; t < POINTS_PER_MONTH; t++) {
                        mjd[t] = mjdStartTime + (double)t;
                    }
                    float[] corrections = new float[POINTS_PER_MONTH];
                    float valueStart = rand.nextFloat();
                    for (int v=0; v < corrections.length; v++) {
                        corrections[v] = valueStart + (float) v;
                    }
                    
                    long[] originators = new long[POINTS_PER_MONTH];
                    long originStart = rand.nextLong();
                    for (int o=0; o < originators.length; o++) {
                        originators[o] = originStart + o;
                    }
                  
                    series_a[i] = new FloatMjdTimeSeries(id, -Double.MIN_VALUE, Double.MAX_VALUE, mjd, corrections, originators, true);
                }
         
                long startTime = System.currentTimeMillis();
                crStore.writeMjdTimeSeries(series_a);
                long endTime = System.currentTimeMillis();
                
                crStore.commitLocalFsTransaction();
                
                double totalTime = ((double) (endTime - startTime) ) / (1000.0 * 60.0);
                System.out.println(processName + wokerId + " Write time: " + totalTime);
                
                FsId[] ids = new FsId[series_a.length];
                for (int i=0; i < ids.length; i++) {
                    ids[i] =series_a[i].id();
                }
                
                startTime = System.currentTimeMillis();
                
                crStore.beginLocalFsTransaction();
                FloatMjdTimeSeries[] readSeries_a = 
                    crStore.readMjdTimeSeries(ids, -Double.MIN_VALUE, Double.MAX_VALUE);
                crStore.rollbackLocalFsTransaction();
                endTime = System.currentTimeMillis();
                
                totalTime =  ((double) (endTime - startTime) ) / (1000.0 * 60.0);
                System.out.println(processName + wokerId + " Read time: " + totalTime);
                
                if (!Arrays.deepEquals(readSeries_a, series_a)) {
                    throw new Exception("Bad array compare.");
                }
           } catch (Throwable t) {
               t.printStackTrace();
           }
       }
    }


}
