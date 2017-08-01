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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class Clitest {

    private File testRoot;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testRoot = new File(Filenames.BUILD_TEST, "CliTest");
        testRoot.mkdirs();

    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        // FileUtil.removeAll(testRoot);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        ((FileStoreTestInterface) fsClient).cleanFileStore();
    }

    @Test
    public void cliIntervals() throws Exception {
        FsId id = new FsId("/blah/gak");
        loadTimeSeries(id);

        TestSystemProvider testSystem = new TestSystemProvider(testRoot);
        Cli cli = new Cli(testSystem);

        String cmd = "-t local ls-ts-intervals /blah/gak";
        String[] argv = cmd.split("\\s+");
        cli.execute(argv);

        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        assertEquals("/blah/gak (10,12)\n", testSystem.stdout());
    }

    @Test
    public void cliListTimeSeries() throws Exception {
        FsId id = new FsId("/series-test/a/b");
        loadTimeSeries(id);

        TestSystemProvider testSystem = new TestSystemProvider(testRoot);
        Cli cli = new Cli(testSystem);

        String cmd = "-t local ls-ts " + new FsId("/series-test/a");
        String[] argv = cmd.split("\\s+");
        cli.execute(argv);

        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        assertEquals("/series-test/a/b\n", testSystem.stdout());
        
        cmd = "-t local ls-ts -p /*/*";
        argv = cmd.split("\\s+");
        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        assertEquals("/series-test/a/_\n", testSystem.stdout());
        
        cmd = "-t local ls-ts -q /[series-test,blah]/[a,x]/b";
        argv = cmd.split("\\s+");
        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        assertEquals("/series-test/a/b\n", testSystem.stdout());

    }

    @Test
    public void cliListCosmicRaySeries() throws Exception {
        FsId id = new FsId("/crs-test/blah");
        loadCosmicRaySeries(id);
        
        TestSystemProvider testSystem = new TestSystemProvider(testRoot);
        Cli cli = new Cli(testSystem);
   
        String[] argv = "-t local ls-mts /crs-test".split("\\s+");
        cli.execute(argv);
        
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        assertEquals("/crs-test/blah\n", testSystem.stdout());
    }
    
    @Test
    public void cliReadWriteCosmicRaySeries() throws Exception {
        TestSystemProvider testSystem = new TestSystemProvider(testRoot);
        Cli cli = new Cli(testSystem);
        FsId id = new FsId("/cosmic/thing");
        
        FloatMjdTimeSeries crs = newCosmicRaySeries(id);
        File testFile = new File(testRoot, "crs.in");
        FileWriter fout = new FileWriter(testFile);
        fout.write(crs.toPipeString());
        fout.write('\n');
        fout.close();
        
        
        String[] argv = ( "-t local add-mts " + testFile).split("\\s+");
        cli.execute(argv);
        assertEquals(0, testSystem.returnCode());
        
        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        File fromFileStore = new File(testRoot, "fromFileStore");
        
        argv = ("-t local get-mts 7.0 8.0 " + fromFileStore + " /cosmic/thing").split("\\s+");
        cli.execute(argv);
        assertEquals(0, testSystem.returnCode());
        
        checkMjdTimeSeries(crs, fromFileStore);
        
        argv = ("-t local get-mts -q 7.0 8.0 " + fromFileStore + " /cosmic/*").split("\\s+");
        cli.execute(argv);
        assertEquals(0, testSystem.returnCode());
        
        checkMjdTimeSeries(crs, fromFileStore);
        
    }

    private void checkMjdTimeSeries(FloatMjdTimeSeries crs, File fromFileStore)
        throws FileNotFoundException, IOException {
        BufferedReader breader = 
            new BufferedReader(new FileReader(fromFileStore));
        String line = breader.readLine();
        assertEquals(crs.toPipeString(), line);
        line = breader.readLine();
        assertEquals(null, line);
    }
    
    
    /**
     * 
     */
    @Test
    public void cliWriteReadListBlob() throws Exception {
        TestSystemProvider testSystem = new TestSystemProvider(testRoot);
        Cli cli = new Cli(testSystem);
        String testString = "This is a test.";
        File testFileDir = new File(testRoot.getAbsolutePath() + "/clitest/");
        FileUtil.mkdirs(testFileDir);
        File testFile = new File(testFileDir, "blah");
        FileWriter fout = new FileWriter(testFile);
        fout.write(testString);
        fout.close();

        String cmd = "-t local add-blob -c " + testRoot.getAbsolutePath() + 
                    " clitest/blah";
        String[] argv = cmd.split("\\s+");
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());

        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        cmd = "-t local get-blob /clitest/blah";
        argv = cmd.split("\\s+");
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        
        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        cmd = "-t local get-blob -q /clitest/*";
        argv = cmd.split("\\s");
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());

        compareBlob(testString);
        
        cmd = "ls-blob -q /clitest/[ack,blah]";
        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        cli.execute(cmd.split("\\s+"));
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        assertEquals("/clitest/blah\n", testSystem.stdout());

    }

    private void compareBlob(String testString) throws FileNotFoundException,
        IOException {
        File outputFile = new File(testRoot, "/clitest/blah");
        BufferedReader reader = new BufferedReader(new FileReader(outputFile));
        String blobline = reader.readLine();
        assertEquals(testString, blobline);
    }

    @Test
    public void cliWriteReadTimeSeries() throws Exception {
        TestSystemProvider testSystem = new TestSystemProvider(testRoot);
        Cli cli = new Cli(testSystem);
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        valid.add(new SimpleInterval(10, 12));
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        origin.add(new TaggedInterval(10, 12, 3));
        FsId id = new FsId("/gak/series1");
        TimeSeries ts = new IntTimeSeries(id, new int[] { 1, 2, 3 }, 10, 12,
            valid, origin);
        File testFile = new File(testRoot, "series");
        FileWriter fout = new FileWriter(testFile);
        fout.write(ts.toPipeString());
        fout.close();

        String cmd = "-t local add-ts  " + testFile.getAbsolutePath();
        String[] argv = cmd.split("\\s+");
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());

        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        File fromFileStore = new File(testRoot, "fromFileStore");
        cmd = "-t local get-ts -i 10 12  " + fromFileStore + " " + id;
        argv = cmd.split("\\s+");
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        checkTimeSeries(ts, fromFileStore);
        
        testSystem = new TestSystemProvider(testRoot);
        cli = new Cli(testSystem);
        cmd = "-t local get-ts -q -i 10 12  " + fromFileStore + " /gak/series[0,1]";
        argv = cmd.split("\\s+");
        cli.execute(argv);
        assertEquals(testSystem.errors(), 0, testSystem.returnCode());
        checkTimeSeries(ts, fromFileStore);
        
    }

    private void checkTimeSeries(TimeSeries ts, File fromFileStore)
        throws FileNotFoundException, IOException {
        BufferedReader reader = new BufferedReader(
            new FileReader(fromFileStore));
        String tsline = reader.readLine();
        assertEquals(ts, TimeSeries.fromPipeString(tsline));
    }

    private void loadTimeSeries(FsId id) throws Exception {
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        valid.add(new SimpleInterval(10, 12));
        List<TaggedInterval> origin = new ArrayList<TaggedInterval>();
        origin.add(new TaggedInterval(10, 12, 3));
        TimeSeries ts = new IntTimeSeries(id, new int[] { 1, 2, 3 }, 10, 12,
            valid, origin);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { ts });
        fsClient.commitLocalFsTransaction();

    }
    
    private void loadCosmicRaySeries(FsId id) throws Exception {
       
        FloatMjdTimeSeries crs = newCosmicRaySeries(id);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.beginLocalFsTransaction();
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { crs });
        fsClient.commitLocalFsTransaction();
    }
    
    private FloatMjdTimeSeries newCosmicRaySeries(FsId id) {
        double[] mjd = new double[]{7.0, 8.0};
        float[] values = new float[] { 6.0f, 5.0f};
        long[] originators = new long[] { 1L, 2L};
        
        return
            new FloatMjdTimeSeries(id, mjd[0], mjd[mjd.length - 1], mjd, values, originators, true);
    }
}
