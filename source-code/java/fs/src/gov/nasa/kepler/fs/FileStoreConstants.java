/**
 * $Source$
 * $Date: 2017-07-27 10:04:13 -0700 (Thu, 27 Jul 2017) $
 * 
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
package gov.nasa.kepler.fs;

import gov.nasa.kepler.common.os.IOChecker;
import gov.nasa.spiffy.common.io.Filenames;

/**
 * @author Jason Brittain jbrittain@mail.arc.nasa.gov
 * @author Sean McCauliff
 */
public interface FileStoreConstants {
    
	public enum ConnectionType {
		ram,fstp,local,disk;
	}
	
    static final String CSCI_NAME = "FileStore";

    static final String FS_METRICS_PREFIX = "fs";
    
    static final byte FLOAT_TYPE = 1;
    static final byte INT_TYPE = 2;
    static final byte DOUBLE_TYPE = 3;
    static final byte BYTE_TYPE = 4;
    
    static final String TIME_SERIES_DIR_NAME = "ts";
    
    static final String BLOB_DIR_NAME = "blob";
    
    static final String MJD_TIME_SERIES_DIR_NAME = "mts";
    
    static final String TRANSACTION_LOG_DIR_NAME = "transactionLog";
    
    static final String SERVER_LOCK_NAME = "lock";
    
    // Configuration variable names.
    static final String FS_PROP_PREFIX = "fs.";
    
    static final String FS_SERVER_PREFIX = "fs.server.";
    static final String FS_CLIENT_PREFIX = "fs.client.";
    
    static final String FS_DRIVER_NAME_PROPERTY = 
        FS_PROP_PREFIX + "driver.name";

    static final String FS_DATA_DIR_PROPERTY = 
        FS_PROP_PREFIX + "data.dir";
    static final String FS_DATA_DIR_DEFAULT = 
        Filenames.BUILD_TMP + "/fsdata";

    static final String FS_ALLOW_CLEANUP = 
        FS_PROP_PREFIX + "allow-cleanup";
    
    static final boolean FS_ALLOW_CLEANUP_DEFAULT = false;
    
    static final String FS_FSTP_URL_DEFAULT = "fstp://hsot:port";
        
    static final String FS_FSTP_URL=FS_PROP_PREFIX + "fstp";
    static final String FS_LISTEN_PORT = FS_PROP_PREFIX + "listen-port";
    
    static final String DEFAULT_DISK_FILE_STORE_ROOT = Filenames.BUILD_TEST + "/fs";
    
    /**
     * The directory the DiskFileStoreClient will use as its read root.
     */
    static final String DISK_FILE_STORE_READ_ROOT_PROPERTY = "fs.disk-fs.read-root";
    static final String DISK_FILE_STORE_READ_ROOT_DEFAULT = 
    	DEFAULT_DISK_FILE_STORE_ROOT;
    
    /** The directory the DiskFileStoreClient will use as its write root. */
    static final String DISK_FILE_STORE_WRITE_ROOT_PROPERTY = "fs.disk-fs.write-root";
    static final String DISK_FILE_STORE_WRITE_ROOT_DEFAULT =
    	DEFAULT_DISK_FILE_STORE_ROOT;
    	
        
    
    /**
     *  The number of seconds before a transaction is automatically rolledback
     *  by the server.
     */
    static final String FS_XACTION_AUTOROLLBACK_SEC_PROPERTY = 
        FS_PROP_PREFIX + "auto-rollback-seconds";
    static final int FS_XACTION_AUTOROLLBACK_SEC_DEFAULT =
        60*60*2;
    
    /** This value is based on a 6 year mission for pixel data assuming
     * there is one ts file per pixel file.  This is the maximum expected number
     * of files for a path name root.  This is not a hard limit,
     */
    final static int FILES_PER_STORE_DEFAULT = 200000;
    final static String FILES_PER_STORE_PROPERTY =
        FS_PROP_PREFIX + "files-per-store";
    
    /**
     * The file store will attempt to create a directory tree where there are
     * no more than the specified number of files per directory.
     */
    final int MAX_FILES_PER_DIR_DEFAULT = 1000;
    final static String MAX_FILES_PER_DIR_PROPERTY = 
        FS_PROP_PREFIX + "max-files-per-dir";
    
    /** When set to true this will generate an out of memory error in the
     * server process.
     */
    static final String FS_TEST_GENERATE_OOM = 
        FS_SERVER_PREFIX + "test.generate-oom";
   
    /** When set to true this will generate a runtime exception in the middle
     * of the commit phase.
     */
    static final String FS_TEST_MID_COMMIT_ERROR =
        FS_SERVER_PREFIX + "test.mid-commit-error";
    
    /**
     * Concurrency throttleing.  The number of concurrent permits.
     */
    static final String FS_SERVER_MAX_CONCURRENT_READ_WRITE =
        FS_SERVER_PREFIX +  "max-concurrent-read-write";
    static final int FS_SERVER_MAX_CONCURRENT_READ_WRITE_DEFAULT = 8;
    
    /**
     * How many permits a "read" will consume.
     */
    static final String FS_SERVER_PERMITS_PER_READ = 
        FS_SERVER_PREFIX + "max-concurrent_read-write.read-cost";
    static final int FS_SERVER_PERMITS_PER_READ_DEFAULT = 1;
    
    /**
     * How many permits a "write" will consume.
     */
    static final String FS_SERVER_PERMITS_PER_WRITE =
        FS_SERVER_PREFIX + "max-concurrent-read-write.write-cost";
    static final int FS_SERVER_PERMITS_PER_WRITE_DEFAULT = 2;

    /**
     * The maximum number of worker threads.  The file store wont do anything
     * with the client request when this number has been reached.
     */
    static final String FS_SERVER_MAX_CLIENTS = 
        FS_SERVER_PREFIX + "max-client-threads";
    static final int FS_SERVER_MAX_CLIENTS_DEFAULT = 32;
    
    /**
     * This is the size of the queue the OS kernel will keep.  Doing an accept()
     * on the socket removes an incoming connection with this queue.  Since only
     * one accept can happen at a time and there is some setup for a client
     * connection it's possible for MAX_CLIENTS to try an connect all at once so
     * this needs to be set to something non-zero.  The default value the server
     * uses for this property is the value of FS_SERVER_MAX_CLIENTS.
     */
    static final String FS_SERVER_MAX_SOCKET_BACKLOG = 
        FS_SERVER_PREFIX + "max-socket-backlog";
    
    static final String FS_SERVER_MAX_BTREE_NODE_CACHE_PROPERTY =
        FS_SERVER_PREFIX + "btree-node-cache-size";
    static final int FS_SERVER_MAX_BTREE_NODE_CACHE_DEFAULT = 1024 * 8;
    
    /**
     * Call the underlying operating system's fsync() after the btree journal is
     * written.
     */
    static final String FS_SERVER_SYNC_BTREE_JOURNAL = 
        FS_SERVER_PREFIX + "sync-btree-journal";
    static final boolean FS_SERVER_SYNC_BTREE_JOURNAL_DEFAULT = true;
    
    /**
     * The number of transactional random access file metadata objects to cache
     * in memory.
     */
    static final String FS_SERVER_MAX_TRAF_METADATA_CACHE = FS_SERVER_PREFIX + 
                "traf.max-metadata-cache";
    
    static final int FS_SERVER_MAX_TRAF_METADATA_CACHE_DEFAULT = 1024*1024*10;
    
    /**
     * The number of transactional random access file operation objects to cache
     * in memory.
     */
    static final String FS_SERVER_MAX_TRAF_OPS_CACHE = FS_SERVER_PREFIX + 
                "traf.max-ops-cache";
    static final int FS_SERVER_MAX_TRAF_OPS_CACHE_DEFAULT = 
        FS_SERVER_MAX_TRAF_METADATA_CACHE_DEFAULT * 2;
    
    static final String FS_SERVER_FSID_LOCK_TIMEOUT_SEC = 
        FS_SERVER_PREFIX + "fsid.lock-time-out-sec";
    static final int FS_SERVER_FSID_LOCK_TIMEOUT_SEC_DEFAULT = 45;
    
    
    /**
     * Used by the transport protocol.
     */
    static final long NO_MORE_BLOB_TO_SEND = -1L;
    
    
    /**
     * This enables or disables the version check on the file store protocol.
     */
    static final String FS_PROTOCOL_VERSION_CHECK_PROP = FS_PROP_PREFIX + 
     "protocol.version-check";
    
    static final boolean FS_PROTOCOL_VERSION_CHECK_DEFAULT = true;
    
    /**
     * Stack dumper interval in seconds.
     */
    static final String FS_SERVER_STACK_DUMPER_POLL_INTERVAL = 
        FS_SERVER_PREFIX + "stack-dumper.interval-sec";
    static final int FS_SERVER_STACK_DUMPER_POLL_INTERVAL_DEFAULT = 60;
    
    /**
     * Stack dumper directory.  OR use the root of the data store if not
     * configured.
     */
    static final String FS_SERVER_STACK_DUMPER_DIR = 
        FS_SERVER_PREFIX + "stack-dumper.dump-dir";
    
    static final String FS_SERVER_FTM_CONTEXT_LOCK_TIMEOUT = 
        FS_SERVER_PREFIX + "ftm-context.lock-time-out-sec";
    
    static final int FS_SERVER_FTM_CONTEXT_LOCK_TIMEOUT_DEFAULT  = 30;
    
    static final String FS_PROTOCOL_VERSION = FS_PROP_PREFIX + "protocol-version";
    
    static final String FS_SERVER_CHECK_IO_SCHEDULERS = FS_SERVER_PREFIX + 
        "os.scheduler.do-check";
    static final boolean FS_SERVER_CHECK_IO_SCHEDULERS_DEFAULT = false;
    
    static final String FS_SERVER_IO_SCHEDULERS_INTERNAL_SCHEDULER = FS_SERVER_PREFIX + 
        "os.scheduler.internal-scheduler";
        
    static final String FS_SERVER_IO_SCHEDULERS_INTERNAL_SCHEDULER_DEFAULT = 
        IOChecker.EXPECTED_INTERAL_NODE_SCHEDULER_DEFAULT;
    
    static final String FS_SERVER_IO_SCHEDULERS_LEAF_SCHEDULER = FS_SERVER_PREFIX + 
        "os.scheduler.leaf-scheduler";
    
    static final String FS_SERVER_IO_SCHEDULERS_LEAF_SCHEDULER_DEFAULT = 
        IOChecker.EXPECTED_LEAF_NODE_SCHEDULER_DEFAULT;
    
    static final String FS_SERVER_IO_SCHEDULERS_INTERNAL_READ_AHEAD_KB = FS_SERVER_PREFIX +
    "os.scheduler.internal-read-ahead-kb";
    
    static final int FS_SERVER_IO_SCHEDULERS_INTERNAL_READ_AHEAD_KB_DEFAULT =
        IOChecker.EXPECTED_INTERNAL_NODE_READ_AHEAD_KB_DEFAULT;
    
    static final String FS_SERVER_IO_SCHEDULERS_LEAF_READ_AHEAD_KB = FS_SERVER_PREFIX +
    "os.scheduler.leaf-read-ahead-kb";
    
    static final int FS_SERVER_IO_SCHEDULERS_LEAF_READ_AHEAD_KB_DEFAULT = 
        IOChecker.EXPECTED_LEAF_NODE_READ_AHEAD_KB_DEFAULT;
    
    static final String FS_SERVER_SYNC_ON_COMMIT = 
        FS_SERVER_PREFIX + "sync-on-commit";
    
    static final boolean FS_SERVER_SYNC_ON_COMMIT_DEFAULT = false;
    
    /**
     * Reconfigure this at your own peril.  The data files used by the file
     * store server never store this file in any file that is written so this
     * can easily 
     */
    static final String FS_SERVER_STORAGE_BLOCK_SIZE = 
       FS_SERVER_PREFIX + "block-size";
    
    static final int FS_SERVER_STORAGE_BLOCK_SIZE_DEFAULT = 1024*8;
    
    /**
     * The maximum number of threads used to serve client socket requests.  
     * This is not the same as the maximum number of clients.
     */
    static final String FS_SERVER_MAX_CLIENT_CONNECTIONS = 
        FS_SERVER_PREFIX + "max-client-connections";
    
    static final int FS_SERVER_MAX_CLIENT_CONNECTIONS_DEFAULT = 1024;

    static final String FS_SERVER_SYNC_ON_RECOVERY = 
            FS_SERVER_PREFIX + "sync-on-recovery";
        
    static final boolean FS_SERVER_SYNC_ON_RECOVERY_DEFAULT = true;
    
    /**
     * Perform checks that there is a curently open input or output stream
     * associated with the file store client thread.
     */
    static final String FS_CLIENT_CHECK_STREAM_IN_USE =
        FS_CLIENT_PREFIX+ "check-stream-in-use";
    
    /**
     * This is false by default because the check is implemented in the
     * invocation handler, rather than in the client itself.  Even in the unit
     * tests the invocation handler is frequently wrapped around the mock 
     * objects and therefore lack the proper mocking for this check to work.
     */
    static final boolean FS_CLIENT_CHECK_STREAM_IN_USE_DEFAULT = false;
    
}
