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

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Arrays;
import java.util.Random;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.cli.TimeSeriesXmlExporter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class MjdSeriesStressTest {

    private static final Log log = LogFactory.getLog(MjdSeriesStressTest.class);
    
    private final Random rand = new Random(552342342); //234255);
    
    
    @Test
    public void mjdTimeSeriesStressTest() throws Exception {
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        
        ((FileStoreTestInterface)fsClient).cleanFileStore();
        
        FsId[] fsId = new FsId[64];
        for (int i=0; i < fsId.length; i++) {
            fsId[i] = new FsId("/mjd/stress/test/" + i);
        }
        for (int iiter=0; iiter < 22; iiter++) {
            log.info("Iteration " + iiter);
            FloatMjdTimeSeries[] series = new FloatMjdTimeSeries[fsId.length];
            for (int i=0; i < series.length; i++) {
                series[i] = generateSeries(fsId[i], iiter);
            }
            int rollbackRoll = rand.nextInt(10);
            if (iiter < 15) {
                continue;
            }
            if (iiter == 21) {
                for (int i=0; i < series.length; i++) {
                    if (i == 41) {
                        log.info("Dumped time series.");
                        TimeSeriesXmlExporter xmlExporter = new TimeSeriesXmlExporter();
                        FloatMjdTimeSeries[] before = fsClient.readAllMjdTimeSeries(new FsId[] { series[i].id()});
                        BufferedWriter bwriter = new BufferedWriter(new FileWriter("/tmp/err.txt"));
                        xmlExporter.export(bwriter, before);
                        bwriter.write('\n');
                        xmlExporter.export(bwriter, new FloatMjdTimeSeries[] { series[i]} );
                        bwriter.write('\n');
                        bwriter.close();
                    }
                    
                    fsClient.beginLocalFsTransaction();
                    log.info("Writing single time series for id " + series[i].id());
                    fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { series[i] });
                    fsClient.commitLocalFsTransaction();
                    fsClient.readAllMjdTimeSeries(fsId);
                }
            } else {
                fsClient.beginLocalFsTransaction();
                fsClient.writeMjdTimeSeries(series);
                if (rollbackRoll == 0) {
                    log.info("Rolling back.");
                    fsClient.rollbackLocalFsTransaction();
                } else {
                    fsClient.commitLocalFsTransaction();
                }
                fsClient.readAllMjdTimeSeries(fsId);
            }
            log.info("Iteration " + iiter + " complete.");
        }
    }
    
    private FloatMjdTimeSeries generateSeries(FsId id, long originator) {
        int npoints = rand.nextInt(1024*4);
        double[] mjd = new double[npoints];
        int startMjd = rand.nextInt(1024);
        for (int i=0; i < mjd.length; i++) {
            mjd[i] = startMjd + (i * 0.5);
        }
        
        double endMjd = (mjd.length > 0) ? mjd[mjd.length - 1] : startMjd + 1024;
        float[] values = new float[npoints];
        Arrays.fill(values, (float) originator);
     
        return new FloatMjdTimeSeries(id, startMjd, endMjd, mjd, values, originator);
    }
}
