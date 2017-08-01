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

package gov.nasa.kepler.fs.server.xfiles;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;


@RunWith(JMock.class)
public class DirectoryHashFactoryTest {

    private static final File rootDir = 
        new File(Filenames.BUILD_TEST,  "DirectoryHashFactoryTest");
    private static final File typeDir = new File(rootDir, "typeDir");
    
    private FsIdFileSystemLocator pathLocator;
    private Mockery mockery;

    @Before
    public void setUp() throws Exception {
        rootDir.mkdirs();
        
        mockery = new Mockery() {{
            setImposteriser(ClassImposteriser.INSTANCE);
        }};
        pathLocator = mockery.mock(FsIdFileSystemLocator.class);
        mockery.checking(new Expectations() {{
            allowing(pathLocator).directoryForFsIdPath(with(aNonNull(FsId.class)));
            will(returnValue(rootDir.getCanonicalFile()));
            allowing(pathLocator).fileSystemRoots();
            will(returnValue(Collections.singleton(rootDir.getCanonicalFile())));
        }});
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
    }

    @Test
    public void testWithPlainDirHash() throws Exception {
        testDirectoryHashFactory(DirectoryHash.class);
    }

    //TODO:  Actually make this test a different kind of factory.
    private void testDirectoryHashFactory(Class<?> dirHashType) throws Exception {
        DirectoryHashFactory dirHashFactory = 
            new DirectoryHashFactory(pathLocator, typeDir, 200, 32);
        FsId id = new FsId("/blahdir/blah");
        DirectoryHash dirHash = dirHashFactory.findDirHash(id,  true, true);
        File blahFile = dirHash.idToFile(id.name());
        assertTrue(!blahFile.exists());
        assertTrue(blahFile.createNewFile());

        DirectoryHash cachedHash = dirHashFactory.findDirHash(id, true, true);
        assertTrue(dirHash == cachedHash);

        dirHashFactory.clear();
        DirectoryHash recoveredHash = dirHashFactory.findDirHash(id, true, true);
        assertTrue(recoveredHash != cachedHash);
        assertTrue(recoveredHash.idToFile(id.name()).exists());

    }

    @Test
    public void testDirectoryHashFactoryWithTimeSeriesDirHash()
        throws Exception {
        testDirectoryHashFactory(RandomAccessAllocator.class);
    }

    /**
     * The file used to reconstitute the directory hash algorithm has been
     * corrupted.
     * 
     * @throws Exception
     */
    @Test
    public void recoverDirHashFactoryFromBadMetaData() throws Exception {
        DirectoryHashFactory factory = 
            new DirectoryHashFactory(pathLocator, typeDir, 200, 32);
        FsId id = new FsId("/blahdir/blah");
        DirectoryHash dirHash = factory.findDirHash(id,  true, true);
        File blahFile = dirHash.idToFile(id.name());
        blahFile.createNewFile();

        File propertiesFile = 
            new File(new File(typeDir, "blahdir"), "hash.properties");
        assertTrue(propertiesFile.exists());
        propertiesFile.delete();
        propertiesFile.createNewFile();

        factory.clear();

        DirectoryHash recoveredHash = factory.findDirHash(id,  true, true);
        assertTrue(recoveredHash.idToFile(id.name()).exists());
    }

    /**
     * Some of the directories in the directory hash are missing.
     */
    @Test
    public void missingDirectories() throws Exception {
        DirectoryHashFactory factory = 
            new DirectoryHashFactory(pathLocator, typeDir, 200, 32);
        FsId id = new FsId("/blahdir/blah");
        DirectoryHash dirHash = factory.findDirHash(id, true, true);
        File blahFile = dirHash.idToFile(id.name());
        blahFile.createNewFile();

        File corruptMe = new File(new File(typeDir, "blahdir"), "hd-4");
        corruptMe.delete();

        factory.clear();
        dirHash = factory.findDirHash(id,  true, true);
        assertTrue(blahFile.exists());
        assertTrue(corruptMe.exists());
    }

    /**
     * Check that hashes can be deleted.
     */
    @Test
    public void deleteDirectoryHash() throws Exception {
        DirectoryHashFactory factory =
            new DirectoryHashFactory(pathLocator, typeDir, 200, 32);
        FsId id = new FsId("/blahdir/blah");
        FsId nestedId = new FsId("/blahdir/subdir/someid");
        DirectoryHash dirHash = factory.findDirHash(id, true, true);
        DirectoryHash nestedDirHash = 
            factory.findDirHash(nestedId, true, true);

        File blahFile = dirHash.idToFile(id.name());
        blahFile.createNewFile();

        File nestedFile = nestedDirHash.idToFile(nestedId.name());
        nestedFile.createNewFile();

        factory.deleteDirectoryHash(dirHash);

        assertFalse(blahFile.exists());
        assertTrue("Nested file \"" + nestedFile + "\" should still exist.",
            nestedFile.exists());

    }

    /**
     * Check if we can find directory hash files.
     */
    @Test
    public void findDirHashes() throws Exception {
        DirectoryHashFactory makeDirs = 
            new DirectoryHashFactory(pathLocator, typeDir, 10000, 10);
        FsId id0 = new FsId("/test-level0/0");
        FsId id1 = new FsId("/test-other/1");
        FsId id2 = new FsId("/test-level0/test-level1/test-level2/2");

        Set<FsId> allIds = new HashSet<FsId>();
        allIds.add(id0);
        allIds.add(id1);
        allIds.add(id2);

        DirectoryHash dirHash = makeDirs.findDirHash(id0, true, true);
        File idfile = dirHash.idToFile(id0.name());
        createFile(idfile);
        dirHash = makeDirs.findDirHash(id1,  true, true);
        idfile = dirHash.idToFile(id1.name());
        createFile(idfile);
        dirHash = makeDirs.findDirHash(id2, true, true);
        idfile = dirHash.idToFile(id2.name());
        createFile(idfile);

        DirectoryHashFactory readDirs = 
            new DirectoryHashFactory(pathLocator, typeDir);

        assertEquals(allIds, readDirs.find(null, true));
    }

    private void createFile(File f) throws IOException {
        FileOutputStream fout = new FileOutputStream(f);
        fout.close();
    }
}
