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

package gov.nasa.kepler.common.persistable;

import gov.nasa.spiffy.common.persistable.TestContainer;
import gov.nasa.spiffy.common.persistable.TestTimeSeries;
import gov.nasa.spiffy.common.persistable.TestTimeSeriesContainer;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.Ignore;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

public class SdfPersistableOutputStreamTest {
    private static final File TEST_DIR = new File("build/test/SdfPersistableOutputStreamTest");

    public static void writeSdfFile(Object object, File file) throws IOException {
        try {
            FileOutputStream fos = new FileOutputStream(file);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            DataOutputStream dos = new DataOutputStream(bos);;
            SdfPersistableOutputStream sdf = new SdfPersistableOutputStream(dos);
            sdf.save(object);
            dos.close();
        } catch (Exception e) {
            throw new IOException("failed to serialize/write file[" + file + "], e = " + e, e);
        }
    }

    @Test
    public void testBasicWrite() throws Exception{
        TestTimeSeries ts = new TestTimeSeries(1,true);

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test1.sdf");
        
        writeSdfFile(ts, f);
    }

    @Test
    public void testFullContainerWrite() throws Exception{
        TestContainer testContainer1 = TestContainer.populatedTestContainerFactory(); 

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test2.sdf");
        
        writeSdfFile(testContainer1, f);
    }

    @Test
    public void testTimeSeriesContainerWrite() throws Exception{
        TestTimeSeries ts1 = new TestTimeSeries(10, false);
        TestTimeSeries ts2 = new TestTimeSeries(20, true);
        List<TestTimeSeries> tsl1 = new LinkedList<TestTimeSeries>();
        tsl1.add(ts1);
        tsl1.add(ts2);
        TestTimeSeriesContainer tsc1 = new TestTimeSeriesContainer(tsl1, 100, 500);

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test3.sdf");
        
        writeSdfFile(tsc1, f);
    }

    @Test
    public void testSimpleContainerWrite() throws Exception{
        TestSimpleSdfContainer t = new TestSimpleSdfContainer(); 

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test4.sdf");
        
        writeSdfFile(t, f);
    }

    @Test
    public void testBlobFileSeries() throws Exception{
        TestBlobFileSeriesList t = new TestBlobFileSeriesList(); 

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test5.sdf");
        
        writeSdfFile(t, f);
    }

    @Test
    public void testPairContainer() throws Exception{
        TestPairContainer t = new TestPairContainer(ImmutableList.of(new TestPair("name", "value")), 1, 2); 

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test6.sdf");
        
        writeSdfFile(t, f);
    }

    @Ignore
    public void testEmpties() throws Exception{
        TestEmpties t = new TestEmpties();

        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test7.sdf");
        
        writeSdfFile(t, f);
    }

}
