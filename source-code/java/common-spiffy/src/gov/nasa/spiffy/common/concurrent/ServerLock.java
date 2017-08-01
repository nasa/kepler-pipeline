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

package gov.nasa.spiffy.common.concurrent;

import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Prevents more than one process from reading/modifying on-disk data
 * structures. The lock-holding process will write some identifying information
 * into the lock file.
 * 
 * @author Sean McCauliff
 * 
 */
public class ServerLock {
    private static final Log log = LogFactory.getLog(ServerLock.class);
    private static final Map<File, LockData> allLockData = new HashMap<File, LockData>();
    private final File lockFile;

    public ServerLock(File lockFile) {
        this.lockFile = lockFile;
    }

    /**
     * Attempt to acquire the lock on the lockFile. If this returns then the
     * lock has been acquired.
     * 
     * @param processInfo This gets written into the lock file for debugging purposes.
     * @throws IOException Something unexpected happened.
     * @throws FileStoreException The lock was not acquired.
     */
    public synchronized void tryLock(String processInfo) throws IOException {
        RandomAccessFile raf = null;
        FileChannel fChannel = null;
        boolean ok = false;
        try {
            LockData lockData = allLockData.get(lockFile);
            if (lockData != null) {
                log.info("File lock already held on file \"" + lockFile + "\".");
                lockData.acquireLock();
                return;
            }

            raf = new RandomAccessFile(lockFile, "rw");
            fChannel = raf.getChannel();
            FileLock fileLock = fChannel.tryLock();

            if (fileLock == null) {
                byte[] fileContents = new byte[(int) raf.length()];
                raf.readFully(fileContents);
                String lockHolderInfo = new String(fileContents);
                String msg = "Failed to acquire lock on server lock file \""
                    + lockFile
                    + "\". Lock is being held by \""
                    + lockHolderInfo
                    + "\".";
                throw new IllegalStateException(msg);
            }

            lockData = new LockData(fileLock, raf, fChannel);
            allLockData.put(lockFile, lockData);
            log.info("File lock on \"" + lockFile + "\" acquired.");
            ok = true;

        } finally {
            if (!ok) {
                FileUtil.close(raf);
                FileUtil.close(fChannel);
            }
        }
    }

    /**
     * The OS should make this happen automatically when the process exits, but
     * it would be better to call this before then. If the lock was not held
     * then nothing happens.
     * 
     * @throws IOException If something unexpected happens.
     * 
     */
    public synchronized void releaseLock() throws IOException {
        LockData lockData = allLockData.get(lockFile);
        if (lockData == null) {
            return;
        }

        lockData.releaseLock();
        if (lockData.lockCount() == 0) {
            allLockData.remove(lockFile);
        }

    }

    private static final class LockData {
        private int lockCount = 1;
        private final FileLock fileLock;
        /**
         * References to the open files are kept to avoid garbage collection
         * closing them.
         */
        private final RandomAccessFile raf;
        private final FileChannel fChannel;

        LockData(FileLock fileLock, RandomAccessFile raf, FileChannel fChannel) {
            this.fileLock = fileLock;
            this.raf = raf;
            this.fChannel = fChannel;
        }

        int lockCount() {
            return lockCount;
        }

        void acquireLock() {
            lockCount++;
        }

        void releaseLock() throws IOException {
            lockCount--;
            log.info("Current lock count " + lockCount);
            if (lockCount != 0) {
                return;
            }

            log.info("File lock released.");
            fileLock.release();
            FileUtil.close(fChannel);
            FileUtil.close(raf);
        }
    }
}
