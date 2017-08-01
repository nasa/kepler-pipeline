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

import static org.junit.Assert.*;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.net.URL;

import javax.xml.XMLConstants;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Sean McCauliff
 *
 */
public class FsIdPathLocatorTest {

    private final File outputDir = new File(Filenames.BUILD_TEST, "FsIdPathLocatorTest");
    private final File configFile = new File(outputDir, "conf.xml");
    
    @Before
    public void setup() throws Exception {
        FileUtil.mkdirs(outputDir);
        
    }
    
    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(outputDir);
    }
    
    @Test
    public void missingConfigTest() throws Exception {
        UserConfigurableFsIdFileSystemLocator locator = 
            new UserConfigurableFsIdFileSystemLocator(configFile, outputDir.getAbsolutePath());
        assertEquals(outputDir.getCanonicalFile(), locator.directoryForFsIdPath(new FsId("/0/0")).getCanonicalFile());
        assertTrue(configFile.exists());
    }
    
    private void writeConfig(FsDataPlacementConfiguration config) throws Exception {
        JAXBContext context = JAXBContext.newInstance(FsDataPlacementConfiguration.class);
        Marshaller marshaller = context.createMarshaller();
        SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        URL schemaDocumentUrl = UserConfigurableFsIdFileSystemLocator.class.getResource(UserConfigurableFsIdFileSystemLocator.FS_ROOTS_XSD);
        Schema schema = schemaFactory.newSchema(schemaDocumentUrl);
        marshaller.setSchema(schema);
        marshaller.marshal(config, configFile);
        System.out.println(FileUtils.readFileToString(configFile));
    }
    
    @Test
    public void twoLocations() throws Exception {
        File defaultDir = new File(outputDir, "default");
        defaultDir.mkdirs();
        File rootOne = new File(outputDir, "rootOne");
        rootOne.mkdirs();
        File rootTwo = new File(outputDir, "rootTwo");
        rootTwo.mkdirs();
        FileSystem fileSystemOne = new FileSystem(rootOne.getName());
        fileSystemOne.setFsIdPath(ImmutableList.of("/cal", "/1/one/uno/"));
        FileSystem fileSystemTwo = new FileSystem(rootTwo.getName());
        fileSystemTwo.setFsIdPath(ImmutableList.of("/cal/2", "/2/two/dos"));
        
        FsDataPlacementConfiguration config = new FsDataPlacementConfiguration();
        config.setDefaultDirectory(defaultDir.getName());
        config.setFileSystems(ImmutableList.of(fileSystemOne, fileSystemTwo));

        writeConfig(config);
        
        UserConfigurableFsIdFileSystemLocator pathLocator =
            new UserConfigurableFsIdFileSystemLocator(configFile, outputDir.getAbsolutePath());
        assertEquals(rootOne.getCanonicalFile(), 
                     pathLocator.directoryForFsIdPath(new FsId("/cal/testid-0")).getCanonicalFile());
        assertEquals(rootTwo.getCanonicalFile(),
                     pathLocator.directoryForFsIdPath(new FsId("/cal/2/1/testid-1")).getCanonicalFile());
        assertEquals(defaultDir.getCanonicalFile(),
                     pathLocator.directoryForFsIdPath(new FsId("/blah/blah")));
    }
    
    /**
     * More than one maps FsId path "/cal"
     * @throws Exception
     */
    @Test(expected=IllegalStateException.class)
    public void errorAmbiguousMapping() throws Exception {
        File defaultDir = new File(outputDir, "default");
        defaultDir.mkdirs();
        File rootOne = new File(outputDir, "rootOne");
        rootOne.mkdirs();
        File rootTwo = new File(outputDir, "rootTwo");
        rootTwo.mkdirs();
        FileSystem fileSystemOne = new FileSystem(rootOne.getName());
        fileSystemOne.setFsIdPath(ImmutableList.of("/cal", "/1/one/uno/"));
        FileSystem fileSystemTwo = new FileSystem(rootTwo.getName());
        fileSystemTwo.setFsIdPath(ImmutableList.of("/cal", "/2/two/dos"));
        
        FsDataPlacementConfiguration config = new FsDataPlacementConfiguration();
        config.setDefaultDirectory(defaultDir.getName());
        config.setFileSystems(ImmutableList.of(fileSystemOne, fileSystemTwo));
        writeConfig(config);
        
        UserConfigurableFsIdFileSystemLocator pathLocator =
            new UserConfigurableFsIdFileSystemLocator(configFile, outputDir.getAbsolutePath());
        
    }
}
