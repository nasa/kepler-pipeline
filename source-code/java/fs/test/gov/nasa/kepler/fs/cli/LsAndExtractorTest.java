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

package gov.nasa.kepler.fs.cli;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.io.DataInputStream;

import static gov.nasa.kepler.fs.FileStoreConstants.BLOB_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.MJD_TIME_SERIES_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_DATA_DIR_DEFAULT;
import static gov.nasa.kepler.fs.FileStoreConstants.FS_DATA_DIR_PROPERTY;
import static gov.nasa.kepler.fs.FileStoreConstants.TIME_SERIES_DIR_NAME;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.StringReader;
import java.util.Arrays;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class LsAndExtractorTest {

    private final FsId blobId = new FsId("/beware/of/the/blob");
    private final FsId tsId1 = new FsId("/test/1");
    private final FsId tsId2 = new FsId("/different-test/2");
    private final FsId cosmicRayId = new FsId("/cr-id/1");
    
    private final File testRoot = 
        new File(Filenames.BUILD_TEST, "LsTest.test");
    
    private final long originator = 7;
    final IntTimeSeries intTimeSeries = new IntTimeSeries(tsId1,
        new int[] { Integer.MAX_VALUE }, 0, 0, new int[] {}, originator);
    private final FloatTimeSeries floatTimeSeries = new FloatTimeSeries(tsId2,
        new float[] { Float.MAX_VALUE }, 0, 0, new int[] {}, originator);
 
    private FloatMjdTimeSeries crs;

    private final byte[] blobData = new byte[] { (byte) 42 };

    private String fsDataDir;
    private TestSystemProvider testSystem;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testRoot.mkdirs();
        
        double[] mjd = new double[] { 8.5, 9.5};
        float[] values = new float[] {5.0f, 10.0f};
        long[] originators = new long[] { 666L, 888L};
        
        crs = new FloatMjdTimeSeries(cosmicRayId, mjd[0], mjd[mjd.length -1], mjd, values, originators, true);
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.beginLocalFsTransaction();
        fsClient.writeBlob(blobId, originator, blobData);
        fsClient.writeTimeSeries(new TimeSeries[] { intTimeSeries,
            floatTimeSeries });
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { crs });

        fsClient.commitLocalFsTransaction();
        Configuration config = ConfigurationServiceFactory.getInstance();
        fsDataDir = config.getString(FS_DATA_DIR_PROPERTY, FS_DATA_DIR_DEFAULT);
        testSystem = new TestSystemProvider(testRoot);
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileStoreTestInterface testInterface = (FileStoreTestInterface) FileStoreClientFactory.getInstance();
        testInterface.cleanFileStore();

        FileUtil.removeAll(testRoot);
    }

    @Test
    public void lsTest() throws Exception {
        Ls ls = new Ls(testSystem);
        ls.parse(("-d " + fsDataDir + " " + fsDataDir).split("\\s+"));
        ls.execute();
        String stdout = testSystem.stdout();
        String[] parts = stdout.split("\n");
        Arrays.sort(parts);
        String[] truth = new String[] { blobId.toString(), tsId2.toString(), tsId1.toString(), cosmicRayId.toString()}; 
        Arrays.sort(truth);
        
        assertTrue(Arrays.equals(truth, parts));
        assertEquals(0, testSystem.returnCode());
    }

    @Test
    public void lsNothing() throws Exception {
        Ls ls = new Ls(testSystem);
        File blobDir = new File(testRoot, BLOB_DIR_NAME);
        File tsDir = new File(testRoot, TIME_SERIES_DIR_NAME);
        File crDir = new File(testRoot, MJD_TIME_SERIES_DIR_NAME);
        
        blobDir.mkdirs();
        tsDir.mkdirs();
        crDir.mkdirs();

        ls.parse(("-d " + testRoot + " " + testRoot).split("\\s+"));
        ls.execute();

        assertEquals("", testSystem.stdout());
        assertEquals(0, testSystem.returnCode());
    }

    @Test
    public void extractTimeSeries() throws Exception {
        Extractor extractor = new Extractor(testSystem);
        extractor.parse(("-f " + fsDataDir + " -t " + tsId1 + " " + tsId2).split("\\s+"));
        extractor.execute();

        assertEquals(0, testSystem.returnCode());
        StringReader sReader = new StringReader(testSystem.stdout());
        BufferedReader bReader = new BufferedReader(sReader);
        assertEquals(intTimeSeries,
            TimeSeries.fromPipeString(bReader.readLine()));
        assertEquals(floatTimeSeries,
            TimeSeries.fromPipeString(bReader.readLine()));
        assertEquals(null, bReader.readLine());
    }

    @Test
    public void extractCosmicRaySeries() throws Exception {
        Extractor extractor = new Extractor(testSystem);
        extractor.parse(("-f " + fsDataDir + " -c "+ cosmicRayId).split("\\s+"));
        extractor.execute();
        
        assertEquals(0, testSystem.returnCode());
        
        StringReader sReader = new StringReader(testSystem.stdout());
        BufferedReader breader = new BufferedReader(sReader);
        FloatMjdTimeSeries expected = 
            new FloatMjdTimeSeries(crs.id(), -Double.MAX_VALUE, Double.MAX_VALUE, 
                crs.mjd(), crs.values(), crs.originators(), true);
        assertEquals(expected, FloatMjdTimeSeries.fromPipeString(breader.readLine()));
        
        assertEquals(null, breader.readLine());
    }
    
    @Test
    public void extractBlob() throws Exception {
        Extractor extractor = new Extractor(testSystem);
        extractor.parse(("-f " + fsDataDir + " -o " + testRoot + " -b " + blobId).split("\\s+"));
        extractor.execute();

        assertEquals(0, testSystem.returnCode());
        String[] stdoutParts = testSystem.stdout().split("\\s+");
        assertEquals(2, stdoutParts.length);
        FsId readId = new FsId(stdoutParts[0]);
        assertEquals(blobId, readId);
        assertEquals(originator, Long.parseLong(stdoutParts[1]));
        File outputFile = new File(testRoot, blobId.toString().substring(1));
        assertTrue(outputFile.exists());
        assertEquals((long) blobData.length, outputFile.length());
        DataInputStream fin = new DataInputStream(new FileInputStream(
            outputFile));
        byte[] buf = new byte[blobData.length];
        fin.readFully(buf);
        fin.close();
        assertTrue(Arrays.equals(buf, blobData));

    }
    
   

}
