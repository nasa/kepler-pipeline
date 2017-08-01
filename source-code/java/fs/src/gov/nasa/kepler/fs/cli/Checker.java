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

package gov.nasa.kepler.fs.cli;

import static gov.nasa.kepler.fs.FileStoreConstants.BLOB_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.MJD_TIME_SERIES_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.SERVER_LOCK_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.TIME_SERIES_DIR_NAME;
import static gov.nasa.kepler.fs.FileStoreConstants.TRANSACTION_LOG_DIR_NAME;
import gov.nasa.kepler.fs.server.xfiles.*;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.concurrent.ServerLock;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Checks the file system integrity.
 * 
 * @author Sean McCauliff
 *
 */
public class Checker {
    
    private static final Log log = LogFactory.getLog(Checker.class);
    
    private final SystemProvider system;
    private boolean performRecovery = false;
    private boolean performDirCheck = false;
    private boolean fake = false;
    private File fsDataDir;
    
    Checker(SystemProvider system) {
        this.system = system;
    }
    
    private void printUsage() {
        system.out().println("java -cp ... gov.nasa.kepler.fs.cli.Checker [-f]  <check type>+ <directory>");
        system.out().println("\t-f Don't make any changes.");
        system.out().println("check type is one or more of:");
        system.out().println("\t-r Run transation recovery.");
        system.out().println("\t-s Check directory structure.");
    }
    
    void parse(String[] argv) {
        for (int i=0; i < argv.length; i++) {
            if (argv[i].equals("-f")) {
                fake = true;
            } else if (argv[i].equals("-r")) {
                performRecovery = true;
            } else if (argv[i].equals("-s")) {
                performDirCheck = true;
            } else if (i == (argv.length -1)) {
                fsDataDir = new File(argv[i]);
            } else {
                system.err().println("Bad parameter \"" + argv[i] + "\".");
                printUsage();
                system.exit(1);
                throw new IllegalArgumentException("Bad command line" +
                    " parameter \"" + argv[i] + "\".");
            }
        }
        
        if (fsDataDir == null) {
            system.err().println("The root of the file store data directory must " +
                    "be specified.");
            printUsage();
            system.exit(1);
            throw new IllegalArgumentException("Need root dir.");
        }
        
        if (fake && performRecovery) {
            system.err().println("Currently faked recovery is not supported.");
            system.exit(1);
            throw new IllegalArgumentException("Faked recovery is not supported.");
        }
    }
    
    void execute() throws Exception {
        File lockFile = new File(fsDataDir, SERVER_LOCK_NAME);
        ServerLock sLock = new ServerLock(lockFile);
        sLock.tryLock("checker cli");
        
        try {
            if (performRecovery) {
                File fileSysteConfig = new File(fsDataDir, FileTransactionManager.FILE_SYSTEM_ROOT_CONF_FILE_NAME);
                UserConfigurableFsIdFileSystemLocator fileSystemLocator = 
                    new UserConfigurableFsIdFileSystemLocator(fileSysteConfig, fsDataDir.getCanonicalPath());
                File transactionLogDir = new File(fsDataDir, TRANSACTION_LOG_DIR_NAME);
                
                DirectoryHashFactory dirHashFactory =
                    new DirectoryHashFactory(fileSystemLocator, new File(BLOB_DIR_NAME));
                DirectoryHashFactory forTimeSeries = 
                    new DirectoryHashFactory(fileSystemLocator, new File(TIME_SERIES_DIR_NAME));
                RandomAccessAllocatorFactory tsDirHashFactory = 
                    new RandomAccessAllocatorFactory(forTimeSeries);
                DirectoryHashFactory forCosmicRay =
                    new DirectoryHashFactory(fileSystemLocator, new File(MJD_TIME_SERIES_DIR_NAME));
                MjdTimeSeriesStorageAllocatorFactory crAllocatorFactory =
                    new MjdTimeSeriesStorageAllocatorFactory(forCosmicRay);
                
                RecoveryStartup recoveryStartup =
                    new RecoveryStartup(transactionLogDir, dirHashFactory, 
                                                        tsDirHashFactory, crAllocatorFactory);
                recoveryStartup.recover();
                if (!fake) {
                    recoveryStartup.forgetAllXa();
                }
            }
            
            if (performDirCheck) {
                XFilesChecker xChecker = new XFilesChecker(fsDataDir);
                xChecker.checkDirectoryHashes(fake);
                xChecker.checkStreamFileConsistency(fake);
            }
            
        } finally {
            sLock.releaseLock();
        }
        log.info("Checking complete.");
    }
    
    /**
     * @param args
     * @throws Exception 
     */
    public static void main(String[] argv) throws Exception {
        Checker checker = new Checker(new DefaultSystemProvider());
        checker.parse(argv);
        checker.execute();
    }

}
