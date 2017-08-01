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

package gov.nasa.kepler.pi.module.remote;

import static org.junit.Assert.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ManifestTest {

    @Before
    public void setUp() throws Exception {
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void testClean() throws IOException {
        List<String> expectedCleanContents = new LinkedList<String>();
        expectedCleanContents.add("foo1.mat");
        expectedCleanContents.add("foo2.mat");
        expectedCleanContents.add("foo3.mat");
        expectedCleanContents.add("st-0");
        expectedCleanContents.add("st-0/cal-inputs-0.mat");
        expectedCleanContents.add("st-0/cal-inputs-1.mat");
        expectedCleanContents.add("st-1");
        expectedCleanContents.add("st-1/cal-inputs-0.mat");
        expectedCleanContents.add("st-1/cal-inputs-1.mat");
        expectedCleanContents.add("st-2");
        expectedCleanContents.add("st-2/cal-inputs-0.mat");
        expectedCleanContents.add("st-2/cal-inputs-1.mat");
        Collections.sort(expectedCleanContents);
        
        List<String> expectedDirtyContents = new LinkedList<String>();
        expectedDirtyContents.add("foo1.mat");
        expectedDirtyContents.add("foo2.mat");
        expectedDirtyContents.add("foo3.mat");
        expectedDirtyContents.add("st-0");
        expectedDirtyContents.add("st-0/cal-inputs-0.mat");
        expectedDirtyContents.add("st-0/cal-inputs-1.mat");
        expectedDirtyContents.add("st-0/cal-outputs-0.mat");
        expectedDirtyContents.add("st-0/cal-outputs-1.mat");
        expectedDirtyContents.add("st-1");
        expectedDirtyContents.add("st-1/cal-inputs-0.mat");
        expectedDirtyContents.add("st-1/cal-inputs-1.mat");
        expectedDirtyContents.add("st-1/cal-outputs-0.mat");
        expectedDirtyContents.add("st-1/cal-outputs-1.mat");
        expectedDirtyContents.add("st-2");
        expectedDirtyContents.add("st-2/cal-inputs-0.mat");
        expectedDirtyContents.add("st-2/cal-inputs-1.mat");
        expectedDirtyContents.add("st-2/cal-outputs-0.mat");
        expectedDirtyContents.add("st-2/cal-outputs-1.mat");
        Collections.sort(expectedDirtyContents);

        Manifest manifest = new Manifest(new File("testdata/Manifest"));
        
        assertTrue("Manifest exists", !manifest.exists());
        
        manifest.create();

        assertTrue("Manifest exists", manifest.exists());
        
        List<String> actualCleanContents = manifest.contents();
        Collections.sort(actualCleanContents);
        assertEquals("clean", expectedCleanContents, actualCleanContents);
        
        createEmpty(new File("testdata/Manifest/st-0/cal-outputs-0.mat"));
        createEmpty(new File("testdata/Manifest/st-0/cal-outputs-1.mat"));
        createEmpty(new File("testdata/Manifest/st-1/cal-outputs-0.mat"));
        createEmpty(new File("testdata/Manifest/st-1/cal-outputs-1.mat"));
        createEmpty(new File("testdata/Manifest/st-2/cal-outputs-0.mat"));
        createEmpty(new File("testdata/Manifest/st-2/cal-outputs-1.mat"));
        
        List<String> actualDirtyContents = readDir(new File("testdata/Manifest"));
        Collections.sort(actualDirtyContents);
        assertEquals("dirty", expectedDirtyContents, actualDirtyContents);

        manifest.deleteNonManifestFiles();

        assertTrue("Manifest exists", manifest.exists());
        
        actualCleanContents = manifest.contents();
        Collections.sort(actualCleanContents);
        assertEquals("post-reset", expectedCleanContents, actualCleanContents);
        
        FileUtils.deleteQuietly(manifest.getManifestFile());
    }

    private void createEmpty(File fileToCreate) throws IOException{
        FileOutputStream writer = new FileOutputStream(fileToCreate);
        writer.write(42);
        writer.close();
    }

    private List<String> readDir(File directory){
        LinkedList<String> files = new LinkedList<String>();
        addDirectoryToList(directory, directory, files);
        return files;
    }
    
    private String relativePath(File root, File path){
        return path.getAbsolutePath().substring(root.getAbsolutePath().length() + 1); // +1 to chop off the leading "/"
    }
    
    private void addDirectoryToList(File root, File directory, List<String> list){
        File[] files = directory.listFiles();
        
        for (File file : files) {
            if(!file.getName().equals(".manifest") && !file.getName().equals(".svn")){
                list.add(relativePath(root, file));
                if(file.isDirectory() ){
                    addDirectoryToList(root, file, list);
                }
            }
        }
    }    
}
