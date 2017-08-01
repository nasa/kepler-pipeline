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

package gov.nasa.spiffy.common.io;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class FindFileTest {

    private File rootDir;
    private List<File> allCreated = new ArrayList<File>();

    @Before
    public void setUp() throws Exception {

        rootDir = new File(Filenames.BUILD_TMP, "FileFindTest.test");
        rootDir.mkdir();
        allCreated.add(rootDir);

        File aDir = new File(rootDir, "a");
        aDir.mkdir();
        allCreated.add(aDir);
        File bDir = new File(aDir, "b");
        bDir.mkdir();
        allCreated.add(bDir);
        for (int i = 0; i <= 10; i++) {
            File f = new File(bDir, Integer.toString(i));
            f.createNewFile();
            allCreated.add(f);
        }
    }

    @After
    public void tearDown() throws Exception {

        FileUtil.removeAll(rootDir);
    }

    @Test
    public void testListAll() throws Exception {

        List<File> l = FileUtil.find(".*", rootDir);
        for (File c : allCreated) {
            assertTrue("File must exist." + c, l.contains(c));
        }
    }

    @Test
    public void testEmptyDir() throws Exception {

        FileUtil.removeAll(rootDir);
        rootDir.mkdir();
        assertEquals(1, FileUtil.find(".*", rootDir)
            .size());
    }

    @Test
    public void testFindSome() throws Exception {

        List<File> l = FileUtil.find("1.*", rootDir);
        assertEquals(2, l.size());
        Set<String> names = new HashSet<String>();
        for (File f : l) {
            names.add(f.getName());
        }
        assertTrue("contains 1", names.contains("1"));
        assertTrue("contains 10", names.contains("10"));
    }

    @Test
    public void testHardlink() throws IOException {

        File src = new File(rootDir, "linkSrc");
        FileWriter writer = new FileWriter(src);
        writer.append("Blah");
        writer.close();

        File dest = new File(rootDir, "linkDest");
        FileUtil.hardlink(src, dest);
        assertTrue(src.delete());
        FileReader reader = new FileReader(dest);
        char[] buf = new char[4];
        assertEquals(buf.length, reader.read(buf));
        reader.close();
        assertEquals("Blah", new String(buf));
    }
    
    @Test
    public void testFindFilter() throws IOException {

        FileFilter filter = new RegexFileFilter(
            new String[] { ".*/1[^/]*", ".*/b/2" });
        List<File> l = FileUtil.find(filter, rootDir);
        Set<String> names = new HashSet<String>();
        for (File f : l) {
            names.add(f.getName());
        }
        assertTrue("contains 1", names.contains("1"));
        assertTrue("contains 10", names.contains("10"));
        assertTrue("contains 2", names.contains("2"));
        assertEquals("matched more than expected", 3, names.size());
    }
}
