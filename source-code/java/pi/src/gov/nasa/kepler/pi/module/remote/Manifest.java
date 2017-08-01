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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Store a list of files in a directory tree in a manifest file
 * and provide a method to delete all files in the tree that do
 * not exist in the manifest file (reset the directory tree to
 * a previous state).
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class Manifest {
    private static final Log log = LogFactory.getLog(Manifest.class);
    
    private static final String MANIFEST_FILE_NAME = ".manifest";
    
    private File root = null;
    private File manifestFile = null;
    
    public Manifest(File rootDirectory) {
        this.root = rootDirectory;
        this.manifestFile = new File(rootDirectory, MANIFEST_FILE_NAME);
    }
    
    public boolean exists(){
        return manifestFile.exists();
    }
    
    /**
     * Create a manifest file containing the contents
     * of the specified directory tree
     * 
     * @return
     * @throws IOException 
     */
    public void create() throws IOException{
        LinkedList<String> files = new LinkedList<String>();
        addDirectoryToList(root, root, files);
        
        write(files);
    }
    
    /**
     * Delete all files in the specified directory tree that do
     * not exist in the manifest file
     * @throws IOException 
     */
    public void deleteNonManifestFiles() throws IOException{
        List<String> manifestFiles = contents();
        LinkedList<String> currentFiles = new LinkedList<String>();
        addDirectoryToList(root, root, currentFiles);
        
        for (String path : currentFiles) {
            File file = new File(root, path);
            if(!file.equals(manifestFile) && !manifestFiles.contains(path)){
                // non-manifest file, delete it
                log.info("Deleting non-manifest file: " + file);
                FileUtils.deleteQuietly(file);
            }
        }
    }
    
    private void addDirectoryToList(File root, File directory, List<String> list){
        File[] files = directory.listFiles();
        
        if(files == null){
            log.warn(directory.getAbsolutePath() + " is not a directory");
        }else{
            for (File file : files) {
                if(!file.getName().equals(".svn")){
                    list.add(relativePath(root, file));
                    if(file.isDirectory()){
                        addDirectoryToList(root, file, list);
                    }
                }
            }
        }
    }

    List<String> contents() throws IOException{
        FileInputStream fis = new FileInputStream(manifestFile);
        List<String> contents = IOUtils.readLines(fis);
        
        return contents;
    }
    
    private void write(List<String> list) throws IOException{
        FileOutputStream fos = new FileOutputStream(manifestFile);
        IOUtils.writeLines(list, IOUtils.LINE_SEPARATOR_UNIX, fos);
        fos.close();
    }

    private String relativePath(File root, File path){
        return path.getAbsolutePath().substring(root.getAbsolutePath().length() + 1); // +1 to chop off the leading "/"
    }
    
    public File getRootDirectory() {
        return root;
    }

    public File getManifestFile() {
        return manifestFile;
    }
}
