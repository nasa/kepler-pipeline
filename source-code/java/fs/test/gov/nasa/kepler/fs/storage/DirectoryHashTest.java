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

package gov.nasa.kepler.fs.storage;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DirectoryHashTest {

    @Before
    public void setUp() throws Exception {

    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(new File(getOutputDirName()));
    }

    private String getOutputDirName() {
        return Filenames.BUILD_TEST + "/DirectoryHashTest.test";
    }

    @Test
    public void simpleSetupAndInit() throws Exception {
        String testId = "ts:324234:343;343";
        DirectoryHash dirHash = new DirectoryHash(64, 4, new File(
            getOutputDirName()));
        int nBins = dirHash.getNumberBins();
        int nLevels = dirHash.getNumberLevels();
        File hashedFile = dirHash.idToFile(testId);
        hashedFile.createNewFile();
        String s = dirHash.fileToId(hashedFile);
        assertEquals(testId, s);

        DirectoryHash dirHash2 = new DirectoryHash(
            new File(getOutputDirName()), nBins, nLevels, 4);
        File hashedFile2 = dirHash2.idToFile(testId);
        assertTrue(hashedFile2.exists());
        assertEquals(17, dirHash.getNumberBins());
        assertEquals(4, (new File(getOutputDirName())).list().length);
        assertEquals(5,
            (new File(new File(getOutputDirName()), "hd-0")).list().length);

        DirectoryHash.Performance perf = dirHash.collisionPerformance();
        boolean found = false;
        for (int count : perf.filesPerDir) {
            if (count == 1) {
                found = true;
                break;
            }
        }
        assertTrue(
            "Performance must have found at least one directory with one file in it.",
            found);
    }

    @Test
    public void testFindingIds() throws IOException {
        DirectoryHash dirHash = new DirectoryHash(64, 4, new File(
            getOutputDirName()));
        assertEquals(0, dirHash.findAllIds().size());
        File f1 = dirHash.idToFile("blah");
        f1.createNewFile();
        File f2 = dirHash.idToFile("123");
        f2.createNewFile();
        File bogusFile = new File(f2.getParentFile(), "bogus");
        bogusFile.createNewFile();
        Set<String> ids = dirHash.findAllIds();
        assertEquals(2, ids.size());
        assertTrue("must have id", ids.contains("blah"));
        assertTrue("must have id", ids.contains("123"));

    }

}
