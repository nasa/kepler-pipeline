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

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileVisitor;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableSortedSet;

/**
 * Creates directory hash objects atomically.  That is either the directory
 * hash is created successfully or it is not.  It can also recover correctly
 * from intermediate states.  This class is MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public final class DirectoryHashFactory {

    /** 
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(DirectoryHashFactory.class);
    
    static final String HASH_NBINS_PROP = "fs.ts.htable.nbins";
    static final String HASH_NLEVELS_PROP = "fs.ts.htable.nlevels";
    static final String HASH_MAX_FILES_PER_DIR_PROP = 
          "fs.ts.htable.maxFilesPerDir";
    static final String HASH_CONFIG_NAME = "hash.properties";
    
    private final FsIdFileSystemLocator fsIdLocator;
    
    private final File dataTypeRoot;

    private final Map<String, DirectoryHash> allDirHashes = 
        new ConcurrentHashMap<String, DirectoryHash>();
    protected final int maxFilesPerStore;
    protected final int maxFilesPerDir;
    protected final boolean readOnly;
     
    
    /**
     * Create a read-only version of this factory.  No new directory hashes
     * will be created.
     * @param fsIdLocator This is used to identify the file system the FsId
     * resides on.
     * @param dataTypeRoot This is suffixed to all the FsIds to in order to get
     * the directory in which the directory hash meta-data resides.  Usually 
     * this is some string like "ts" or "blob".  Only the name part is used.
     *
     */
    public DirectoryHashFactory(FsIdFileSystemLocator fsIdLocator, File dataTypeRoot) {
        this.dataTypeRoot = dataTypeRoot;
        this.fsIdLocator = fsIdLocator;
        readOnly = true;
        maxFilesPerStore = -1;
        maxFilesPerDir = -1;
    }
    
    /**
     *
     */
    public DirectoryHashFactory(FsIdFileSystemLocator fsIdLocator, File dataTypeRoot, int maxFilesPerStore, int maxFilesPerDir) {
        if (maxFilesPerStore < 1) {
            throw new IllegalArgumentException("maxFilesPerStore must be greater than 0.");
        }
        if (maxFilesPerDir < 2) {
            throw new IllegalArgumentException("maxFilesPerDir must be greater than 1.");
        }
        
        if (dataTypeRoot == null) {
            throw new NullPointerException("dataTypeRoot");
        }
        if (fsIdLocator == null) {
            throw new NullPointerException("fsIdLocator");
        }
        this.dataTypeRoot = dataTypeRoot;
        this.fsIdLocator = fsIdLocator;
        this.maxFilesPerStore = maxFilesPerStore;
        this.maxFilesPerDir = maxFilesPerDir;
        readOnly = false;
    }
    

    /**
     * create = false version of findDirHash
     * @param id
     * @return
     * @throws InterruptedException 
     * @throws IOException 
     */
    public DirectoryHash findDirHash(FsId id) throws FileStoreException, IOException {
        return findDirHash(id, false, true);
    }
    
    /**
     * create = false, with recovery option
     */
    public DirectoryHash findDirHash(FsId id, boolean recovery) throws FileStoreException, IOException {
        return findDirHash(id, false, recovery);
    }
    
    /**
     * Finds the current directory hashing algorithm in use for a particualr 
     * time series or blob.  If not currently in memory it will look for an existing
     * configuration on disk OR create a new directory tree if one does not
     * exist.
     * 
     * @param id The id of the time series.  This method only looks at the path
     * part to determine which hash should be used.
     * @param timeOutSeconds The number of seconds to wait for to obtain
     * the write lock.
     * @param create When true this creates the directory hash.
     * @param recover When true this attempts to recover the correct
     * tree structure of the directories.
     * @return The directory hash or null if it does not exist and create was false.
     * @throws IOException
     * @throws FileStoreException
     * @throws InterruptedException 
     * @throws IOException 
     */
    public synchronized DirectoryHash findDirHash(FsId id, boolean create, boolean recover) 
        throws FileStoreException,IOException {
     
        
        if (create && readOnly) {
            throw new IllegalArgumentException("This is a read-only directory hash factory.");
        }
        DirectoryHash hash = allDirHashes.get(id.path());
        if (hash != null) {
            return hash;
        } 
        
        File fileSystemRoot = fsIdLocator.directoryForFsIdPath(id);
        fileSystemRoot = new File(fileSystemRoot, this.dataTypeRoot.getName());
        File newFileStore = new File(fileSystemRoot, id.path());
        File hashConfig = new File(newFileStore,HASH_CONFIG_NAME);
        
        if (!hashConfig.exists() && !create) {
            return null;
        }
        
        boolean loadOldHash = false;
        Properties hashProperties = new Properties();
        if (hashConfig.exists()) {
            //Check if hash config was written correctly.
            try {
                FileInputStream fin = new FileInputStream(hashConfig);
                hashProperties.load(fin);
                fin.close();
                
                String OKprop =  hashProperties.getProperty("OK");
                loadOldHash = OKprop != null && OKprop.equals("true");
                
            } catch (IOException ioe) {
                String msg = "Unable to load directory hash config information from file " +
                             hashConfig + ".";
                log.error(msg, ioe);
                loadOldHash = false;
            }
        }
        
        if (!loadOldHash) {
            if (hashConfig.exists()) {
                log.warn("Found bad directory hash config for \"" + id + "\".  Rebuilding directory hash.");
            }
            
            //Create a new hash.
            DirectoryHash newHash = newDirectoryHash(newFileStore);
           
            hashProperties.put(HASH_NBINS_PROP, Integer.toString(newHash.getNumberBins()));
            hashProperties.put(HASH_NLEVELS_PROP, Integer.toString(newHash.getNumberLevels()));
            hashProperties.put(HASH_MAX_FILES_PER_DIR_PROP, Integer.toString(maxFilesPerDir));
            FileOutputStream propsOut = null;
            try {
                propsOut = new FileOutputStream(hashConfig);
                hashProperties.store(propsOut, "no comment");
                propsOut.flush();
                propsOut.write("OK=true\n".getBytes("UTF-8"));
            } catch (IOException ioe) {
                String msg = "Unable to save directory information for time series type " 
                    + id;
                log.error(msg, ioe);
                throw new FileStoreException(msg, ioe);
            } finally {
                if (propsOut != null) {
                    try {
                        propsOut.close();
                    } catch (IOException ioe) {
                        log.warn("Failed to close hash properties file \"" + hashConfig + "\".", ioe);
                    }
                }
            }
            allDirHashes.put(id.path(), newHash);
            return newHash;
            
        } else {
           
            try {
                int nbins = 
                    Integer.parseInt((String)hashProperties.get(HASH_NBINS_PROP));
                int nlevels = 
                    Integer.parseInt((String)hashProperties.get(HASH_NLEVELS_PROP));
                int maxFilesPerDir = 
                    Integer.parseInt((String)hashProperties.get(HASH_MAX_FILES_PER_DIR_PROP));
                
                DirectoryHash newHash =
                    loadDirectoryHash(newFileStore, nbins, nlevels, maxFilesPerDir);
                newHash.recover(!recover);
                allDirHashes.put(id.path(), newHash);
                return newHash;
            } catch (NumberFormatException nfe) {
                String msg = "Broken directory hash config for timeSeries type " +
                id + ".";
                log.error(msg, nfe);
                throw new FileStoreException(msg, nfe);
            } catch (IOException ioe) {
                String msg = "Unable to recover directory hash for time series type " + 
                              id + ".";
                log.error(msg, ioe);
                throw new FileStoreException(msg, ioe);
            }
        }
    }
    
    private DirectoryHash newDirectoryHash(File newFileStore) throws IOException {
        return new DirectoryHash(this.maxFilesPerStore, maxFilesPerDir, newFileStore);
    }
    
    private DirectoryHash loadDirectoryHash(File oldFileStore, int nbins,
                                                                            int nlevels, int maxFilesPerDir) 
        throws IllegalArgumentException, IOException {
        
        return new DirectoryHash(oldFileStore, nbins, nlevels, maxFilesPerDir);
    }

    public synchronized void deleteDirectoryHash(DirectoryHash removeMe) throws IOException {
        //Not efficient, but this will not happen very often.
        String key = null;
        for (Map.Entry<String, DirectoryHash> entry : allDirHashes.entrySet()) {
            if (entry.getValue().equals(removeMe)) {
                key = entry.getKey();
                break;
            }
        }
        
        if (key == null) {
            throw new IllegalArgumentException("DirectoryHash with rootDir \"" 
                + removeMe.rootDir() + "\" is not known to this directory hash.");
        }
        
        allDirHashes.remove(key);
        removeMe.delete();
        File hashRoot = removeMe.rootDir();
        File propertiesFile = new File(hashRoot, HASH_CONFIG_NAME);
        propertiesFile.delete();
        final AtomicBoolean hasFiles = new AtomicBoolean(false);
        
        removeMe.rootDir().list(new FilenameFilter() {

            public boolean accept(File dir, String name) {
                hasFiles.set(true);
                return false;
            }
        });
        if (!hasFiles.get()) {
            removeMe.rootDir().delete();
        }

    }
    
    /**
     * Removes all in-memory state.
     * This is useful for testing.
     *
     */
    public synchronized void clear() {
        allDirHashes.clear();
    }

    public SortedSet<FsId> findPath() throws FileStoreException, IOException {
        return findPath(null);
    }
    
    /**
     * Find FsId paths, but do not enumerate any of the paths under the fsids.
     * The name part of the returned FsIds are valid, but undefined.
     * 
     * @param qEval This may be null.
     * @return A non-null set of all the FsIds.   
     */
    public SortedSet<FsId> findPath(QueryEvaluator qEval) throws FileStoreException, IOException {
        FoundFsIdPath okGood = new FoundFsIdPath() {
            public void foundDirectoryWithHash(FsId pathId, File dir, Collection<FsId> found)
            throws IOException, FileStoreException, InterruptedException {
                found.add(pathId);
            }
        };
        
        return find(qEval, false, okGood);
    }
    
    public SortedSet<FsId> find() throws FileStoreException, IOException {
        return find(null);
    }
    
    public SortedSet<FsId> find(QueryEvaluator qEval) throws FileStoreException, IOException {
        return find(qEval,false);
    }
    
    
    public SortedSet<FsId> find(QueryEvaluator qEval, boolean recover) throws FileStoreException, IOException  {
        return find(qEval,recover, null);
    }
    
    
    /**
     * 
     * @param qEval this may be null in which case no filtering is performed.
     * @param foundFsIdPath this may be null in which case the original names
     * of the files are used as the name part of the FsId.
     * @param recover when true this may attempt repairs to the directory hash
     * structure.
     * @return A non-null sorted set of FsIds which match the criteria.
     * @throws IOException
     */
    public SortedSet<FsId> find(final QueryEvaluator qEval, final boolean recover, FoundFsIdPath foundFsIdPath)
        throws IOException, FileStoreException {
        
        FoundFsIdPath nameFsIdNamesAsFileNames = new FoundFsIdPath() {
            public void foundDirectoryWithHash(FsId pathId, File dir, Collection<FsId> found)
            throws IOException, FileStoreException, InterruptedException {
                DirectoryHash dirHash = findDirHash(pathId, recover);
            Set<String> strIds = dirHash.findAllIds();
            for (String s : strIds) {
                FsId id = new FsId(pathId.path(), s);
                if (qEval == null || qEval.match(id)) {
                    found.add(id);
                }
            }
            }
        };
        
        List<FsId> foundFsIds = new LinkedList<FsId>();
        
        for (File fileSystemRoot : this.fsIdLocator.fileSystemRoots()) {
            File stripFromDirNameToGetFsIdPath = new File(fileSystemRoot, this.dataTypeRoot.getName());
            DirectoryVisitor dirVisitor = 
                new DirectoryVisitor(foundFsIdPath != null ? foundFsIdPath : nameFsIdNamesAsFileNames,
                    stripFromDirNameToGetFsIdPath, foundFsIds, qEval);
            DirectoryWalker dirWalker = new DirectoryWalker(stripFromDirNameToGetFsIdPath);
            dirWalker.traverse(dirVisitor);
        }
                
        //Building an immutable sorted set will throw an exception
        //if there are duplicates in the initializing list.
        return ImmutableSortedSet.copyOf(foundFsIds);
    }
    
    
    /**
     * When we find a directory assume the names of the files are the names
     * of the FsIds.
     *
     */
    public interface FoundFsIdPath {
        
        /**
         * 
         * @param pathId
         * @param dir.
         * @throws IOException
         * @throws FileStoreException
         * @throws InterruptedException
         */
        public void foundDirectoryWithHash(FsId pathId, File dir, Collection<FsId> found)
            throws IOException, FileStoreException, InterruptedException;
    }
    
    
    /**
     * Compile a list of data file ids as FsIds.  
     *
     */
    private final class DirectoryVisitor implements FileVisitor {

        private boolean isPrune = false;
        private final Collection<FsId> found;
        private final File fsIdRoot;
        private final QueryEvaluator qEval;
        private final FoundFsIdPath foundFsIdPath;

        /**
         * @param fsIdRoot Remove this from the prefix of all the files
         * to derive the path part of the FsId.
         * @param found the collection to use to accumulate results
         * @param recover
         * @param query A query to satisfy.  This may be null.
         */
        public DirectoryVisitor(FoundFsIdPath foundFsIdPath, File fsIdRoot,
            Collection<FsId> found, QueryEvaluator qEval) {
            
            if (fsIdRoot == null) {
                throw new NullPointerException("fsIdRoot");
            }
            this.fsIdRoot = fsIdRoot;
            this.qEval = qEval;
            
            if (found == null) {
                throw new NullPointerException("found");
            }
            this.found = found;
            if (foundFsIdPath == null) {
                throw new NullPointerException("foundFsIdPath");
            }
            this.foundFsIdPath = foundFsIdPath;
        }
        
        public void enterDirectory(File newdir) throws IOException {
            if (newdir.getName().startsWith("hd-")) {
                isPrune = true;
                return;
            }
            
            if (qEval == null) {
                return;
            }
            
            String fsIdPath = fsIdPathPart(newdir);
            if (fsIdPath.equals("/")) {
                return;
            }
            
            FsId pathFsId = new FsId(fsIdPath, "_");
            qEval.match(pathFsId);
            if (qEval.completeMatch() || qEval.pathMatched() || qEval.pathPrefixMatched()) {
                return;
            } else {
                isPrune = true;
            }
        }

        public void exitDirectory(File exitdir) throws IOException {
            //This does nothing.
        }

        public boolean prune() {
            boolean rv = isPrune;
            isPrune = false;
            return rv;
        }

        public void visitFile(File dir, File f) throws IOException {
            if (!f.getName().equals(HASH_CONFIG_NAME)) {
                return;
            }
            
            String pathPart =  fsIdPathPart(dir);
            if (pathPart.equals("/")) {
                return;
            }
            
            FsId pathId = new FsId(pathPart, "_");
            
            if (qEval != null){
                qEval.match(pathId);
                if (!qEval.pathMatched()) {
                    return;
                }
            }


            try {
                foundFsIdPath.foundDirectoryWithHash(pathId, dir, found);
            } catch (FileStoreException e) {
                throw new IOException("Wrapped exception.", e);
            } catch (InterruptedException ie) {
                throw new IOException("Wrapped exception.", ie);
            }
            
        }

        
        private String fsIdPathPart(File dir) {
            String path = dir.getAbsolutePath().substring(fsIdRoot.getAbsolutePath().length());
            if (path.length() == 0 || path.charAt(0) != '/') {
                path = '/' + path;
            }
            return path;
        }
        
    }
    
}
