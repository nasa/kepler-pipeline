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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Random;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class QdnmTest {

    private File emptyFile;
    private File smallFile;
    private File biggerFile;
    private File sdnmFile;
    private File testDir = new File(Filenames.BUILD_TEST + "/QdnmTest");

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {

        testDir.mkdirs();
        emptyFile = new File(testDir, "emptyFile");
        generateRandomFile(emptyFile, 0);
        smallFile = new File(testDir, "smallFile");
        generateRandomFile(smallFile, 1024);
        biggerFile = new File(testDir, "biggerFile");
        generateRandomFile(biggerFile, 1024 * 1024 * 8);
        sdnmFile = new File(testDir, "blah.sdnm");
    }

    private void generateRandomFile(File f, int size) throws IOException {
        BufferedOutputStream bin = new BufferedOutputStream(
            new FileOutputStream(f));
        Random r = new Random(0);
        int chunkSize = 1024 * 1024;
        byte[] buf = new byte[1024 * 1024];
        for (int i = 0; i < size; i += chunkSize) {
            int nextSize = Math.min(size - i, chunkSize);
            r.nextBytes(buf);
            bin.write(buf, 0, nextSize);
        }
        bin.close();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testDir);
    }

    /**
     * 
     */
    @Test
    public void test() throws Exception {
        Qdnm qdnm = new Qdnm();

        qdnm.addDataProduct(emptyFile, false);
        qdnm.addDataProduct(smallFile, false);
        qdnm.addDataProduct(biggerFile, false);

        qdnm.export(sdnmFile);

        @SuppressWarnings("unused")
        Qdnm valid = new Qdnm(sdnmFile, false);
    }
}
