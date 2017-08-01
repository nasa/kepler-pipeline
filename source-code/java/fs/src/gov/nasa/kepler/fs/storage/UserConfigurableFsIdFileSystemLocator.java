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

import gov.nasa.kepler.fs.api.FsId;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.*;
import java.util.concurrent.*;

import javax.xml.XMLConstants;
import javax.xml.bind.*;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableSet;

/**
 * Reads a configuration file in order to determine the location of FsId paths.
 * 
 * @author Sean McCauliff
 *
 */
public final class UserConfigurableFsIdFileSystemLocator implements FsIdFileSystemLocator {

    static final String FS_ROOTS_XSD = "/fsidpathmap.xsd";
    
    private static final Log log = LogFactory.getLog(UserConfigurableFsIdFileSystemLocator.class);
    
    private final ConcurrentNavigableMap<String,File> fsIdPathToRoot = 
        new ConcurrentSkipListMap<String, File>();
    
    private final File defaultRoot;
    
    private final Set<File> roots;
    
    
    
    public UserConfigurableFsIdFileSystemLocator(File configFile, String fsDataDir) throws Exception {
        JAXBContext jaxbContext = JAXBContext.newInstance(FsDataPlacementConfiguration.class);
        SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        URL schemaDocumentUrl = UserConfigurableFsIdFileSystemLocator.class.getResource(FS_ROOTS_XSD);
        if (schemaDocumentUrl == null) {
            throw new IllegalStateException("Can't find schema document url.");
        }
        Schema schema = schemaFactory.newSchema(schemaDocumentUrl);
        
        if (!configFile.exists()) {
            log.warn("Missing fs id locator file \"" + fsDataDir + "\".  Creating default file.");
            //Generate default
            Marshaller marshaller = jaxbContext.createMarshaller();
            FsDataPlacementConfiguration xmlConfig = new FsDataPlacementConfiguration();
            xmlConfig.setDefaultDirectory(".");
            marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
            marshaller.setSchema(schema);
            marshaller.marshal(xmlConfig, configFile);
        }
        
        Source xmlSource = new StreamSource(configFile);
        javax.xml.validation.Validator validator = schema.newValidator();
        validator.validate(xmlSource);
        
        Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
        unmarshaller.setSchema(schema);
        FsDataPlacementConfiguration dataPlacement = (FsDataPlacementConfiguration) unmarshaller.unmarshal(xmlSource);
        defaultRoot = replaceRelativeRootNames(dataPlacement.getDefaultDirectory(), fsDataDir);
        checkDirectory(defaultRoot);
        log.info("Default data root is located at \"" + defaultRoot + "\".");
        roots = load(dataPlacement, fsDataDir, fsIdPathToRoot, defaultRoot);
        //load complete.
    }
    
    
    
    @Override
    public File directoryForFsIdPath(FsId id) throws IOException {
        String path = id.path();
        File pathRoot = fsIdPathToRoot.get(path);
        if (pathRoot != null) {
            return pathRoot;
        }
        
        String subPath = path;
        while (pathRoot == null && subPath.indexOf("/") != -1) {
            int lastSlashIndex = subPath.lastIndexOf("/");
            subPath = subPath.substring(0, lastSlashIndex);
            pathRoot = fsIdPathToRoot.get(subPath + "/"); //FsId.path() puts a "/" at the end of the path
        }
        if (pathRoot == null) {
            pathRoot = defaultRoot;
        }
        fsIdPathToRoot.putIfAbsent(path + "/", pathRoot);

        return pathRoot;
        
    }
    
    
    @Override
    public Set<File> fileSystemRoots() {
        return roots;
    }
    
    /**
     * This is static so we can call it from the constructor and not need to
     * worry about which variables are uninitialized.
     * 
     * @return the set of file system roots.
     * @throws IOException 
     */
    private static Set<File> load(FsDataPlacementConfiguration dataPlacement,
        String fsDataDir, Map<String, File> fsIdPathToRoot, File defaultRoot) throws IOException {
        Set<File> rootsSeen = new HashSet<File>();
        for (FileSystem dataRoot : dataPlacement.getFileSystems()) {
            File rootDir = replaceRelativeRootNames(dataRoot.getDirectory(), fsDataDir);
            
            log.info("The canonical version of file system root \"" + 
                     dataRoot.getDirectory() + "\" is \"" + rootDir.getCanonicalFile() + "\".");
            
            if (rootsSeen.contains(rootDir)) {
                throw new IllegalStateException("Duplicate data root \"" + rootDir + "\".");
            }
            
            checkDirectory(rootDir);
            
            log.info("Generating FsId mapping for data root\"" + rootDir + "\".");
            for (String fsIdPath : dataRoot.getFsIdPath()) {
                FsId testId = new FsId(fsIdPath, "_");
                String path = testId.path();
                if (fsIdPathToRoot.containsKey(path)) {
                    throw new IllegalStateException("Duplicate FsId path \"" + path + "\"");
                }
                fsIdPathToRoot.put(path, rootDir);
            }
        }
        //Allow the default root to also be used as a file system
        rootsSeen.add(defaultRoot);
        return ImmutableSet.copyOf(rootsSeen);
    }
    
    /**
     * Verify that the specified file exists, is writable and is actually a
     * directory.  This does not create a directory since the intention of this
     * class is to allow for the file store to use multiple file systems it
     * these directories should already configured by the system administrator.
     * @param d A non-null file.
     */
    private static void checkDirectory(File d) {
        if (!d.exists()) {
            throw new IllegalArgumentException("Directory \"" + d + "\" does not exist.");
        }
        if (!d.isDirectory()) {
            throw new IllegalArgumentException("Directory \"" + d + "\" is not a directory.");
        }
        if (!d.canWrite()) {
            throw new IllegalArgumentException("Directory \"" + d + "\" is not readable.");
        }
    }
    
    /**
     * Make the rootName relative to replacement rather than the present working
     * directory which may not be the directory you where looking for.
     * 
     * @param rootName
     * @param replacement
     * @return non-null; the canonical representation of the File.
     * @throws IOException 
     */
    private static File replaceRelativeRootNames(String rootName, String replacement) throws IOException {
        rootName = rootName.trim();
        
        if (StringUtils.isBlank(rootName)) {
            throw new IllegalStateException("File name may not be empty.");
        }
        
        if (rootName.startsWith("./")) {
            rootName = replacement + rootName.substring(1);
        }
        if (rootName.startsWith("../")) {
            rootName = replacement + "/" + rootName;
        }
        if (!rootName.startsWith("/")) {
            rootName = replacement + "/" + rootName;
        }
        return new File(rootName).getCanonicalFile();
    }

}
