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

import static gov.nasa.kepler.fs.FileStoreConstants.BLOB_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.MJD_TIME_SERIES_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.TIME_SERIES_DIR_NAME;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.Collection;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

/**
 * Looks for errors in the file store data directories.
 * @author Sean McCauliff
 *
 */
public class XFilesChecker {
   
    private static final Log log = LogFactory.getLog(XFilesChecker.class);
    private final FsIdFileSystemLocator pathLocator;
    private final List<String> typeNames = ImmutableList.of(TIME_SERIES_DIR_NAME, BLOB_DIR_NAME, MJD_TIME_SERIES_DIR_NAME);
    
    public XFilesChecker(File dataDir) throws Exception {
        File fileSystemRootConfig = new File(dataDir, FileTransactionManager.FILE_SYSTEM_ROOT_CONF_FILE_NAME);
        pathLocator = new UserConfigurableFsIdFileSystemLocator(fileSystemRootConfig, dataDir.getCanonicalPath());
        
        for (File fileSystemRoot : pathLocator.fileSystemRoots()) {
            for (String dataType : typeNames) {
                File dataTypeDir = new File(fileSystemRoot, dataType);
                if (!dataTypeDir.exists()) {
                    throw new IllegalStateException("Missing data directory \"" + dataTypeDir + "\".");
                }
                if (!dataTypeDir.isDirectory()) {
                    throw new IllegalStateException("Data directory \"" + dataTypeDir + "\" is not a directory.");
                }
                if (!dataTypeDir.canRead()) {
                    throw new IllegalStateException("Can't read from data directory \"" + dataTypeDir + "\".");
                }
                if (!dataTypeDir.canWrite()) {
                    throw new IllegalStateException("Data directory \"" + dataTypeDir + "\" is not writable.");
                }
            }
        }
    }
    
    /**
     * 
     * @param fake When true this only checks and does not make any 
     * repairs to the file store on-disk data structures.
     * @throws IOException 
     * @throws PipelineException 
     */
    public void checkDirectoryHashes(final boolean fake) throws IOException {

        log.info("Checking directory hash structure.");

        for (String dataType : typeNames) {
            final DirectoryHashFactory dirHashFactory = new DirectoryHashFactory(pathLocator, new File(dataType));
            
            DirectoryHashFactory.FoundFsIdPath checkDirectoryHash = new DirectoryHashFactory.FoundFsIdPath() {
                
                @Override
                public void foundDirectoryWithHash(FsId pathId, File dir, Collection<FsId> found)
                    throws IOException, FileStoreException, InterruptedException {
                    DirectoryHash dirHash =
                        dirHashFactory.findDirHash(pathId, !fake);

                    DirectoryHash.Performance perf = 
                        dirHash.collisionPerformance();
                    
                    if (perf.totalCount == 0) {
                        log.error("Empty directory hash rooted at \"" + dir +
                            "\" removing directory hash.");
                        if (!fake) {
                            dirHashFactory.deleteDirectoryHash(dirHash);
                        }
                    } else {
                        log.info("Collision performance of directory has rooted at \"" 
                            + dir + "\".");
                        log.info(perf.message);
                    }
                }
            };
            
            dirHashFactory.find(null, !fake, checkDirectoryHash);
        }
        
    }
    
    

    /**
     * 
     */
    public void checkStreamFileConsistency(final boolean fake) 
        throws IOException {
        
        log.info("Checking blob consistency.");
        final DirectoryHashFactory dirHashFactory = new DirectoryHashFactory(pathLocator, new File(BLOB_DIR_NAME));

        
        DirectoryHashFactory.FoundFsIdPath checkBlobConsistency = new DirectoryHashFactory.FoundFsIdPath() {
            
            @Override
            public void foundDirectoryWithHash(FsId pathId, File dir, Collection<FsId> found)
                throws IOException, FileStoreException, InterruptedException {
                
                DirectoryHash dirHash = dirHashFactory.findDirHash(pathId, !fake);
                
                Set<String> ids = dirHash.findAllIds();
                for (String id : ids) {
                    File f = dirHash.idToFile(id);
                    FsId streamId = new FsId(pathId.path(), id);
                    
                    @SuppressWarnings("unused")
                    TransactionalStreamFile sfile = TransactionalStreamFile.loadFile(f, streamId);
                }
            }
        };
        
        dirHashFactory.find(null, !fake, checkBlobConsistency);
    }
    
}
