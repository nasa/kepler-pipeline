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

import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.storage.DirectoryHashFactory;
import gov.nasa.kepler.fs.storage.MjdTimeSeriesStorageAllocatorFactory;
import gov.nasa.kepler.fs.storage.RandomAccessAllocatorFactory;

import java.io.File;
import java.io.IOException;

import javax.transaction.xa.Xid;

class RecoveryBase {

    protected static final String LOG_FILE_SUFFIX_LOCAL = ".dirtylog";
    protected static final String LOG_FILE_SUFFIX_XA = ".dirtylogxa";
    protected static final String JOURNAL_SUFFIX = ".journal";
    protected static final String MJD_JOURNAL_SUFFIX = ".crjournal";
    protected static final String TYPE_RANDOM = "R";
    protected static final String TYPE_STREAM = "S";
    protected static final String TYPE_MJD = "C";
    protected static final String ORDER = "O";
    /** An order was not recovered from the transaction log file. */
    protected static final int BAD_ORDER = -1;

    /**
         * How far along this transaction was before recovery.  This gets written
         * into the header of the transactionLog file.
         *
         */
        protected enum XStateReached {
            /** Prepairing has started, but may have not completed. */
            PREPAIRING('p'),
            /** Commit has been reached, but may have not completed. */
            COMMITTING('x'),
            /** Transaction has been recovered, but we still need to keep it around
             * just incase we need to tell an XA transaction manager about it.
             */
            DEAD('d'),
            /** initial state. */
            CLEAN('c'),
            /** this state is not persisted. */
            ROLLBACK('r');
            
            private final char stateChar;
            
            XStateReached(char stateChar) {
                byte stateByte = (byte) stateChar;
                this.stateChar = stateChar;
                if (stateChar != stateByte) {
                    throw new IllegalArgumentException("stateChar too big");
                }
            }
            
            static XStateReached valueOf(char sb) {
                switch (sb) {
                    case 'p': return PREPAIRING;
                    case 'x': return COMMITTING;
                    case 'c':  return CLEAN;
                    case 'd': return DEAD;
                    default:
                        throw new IllegalArgumentException("Bad commit state \"" 
                            + sb + "\".");
                }
            }
            
            char toChar() {
                return stateChar;
            }
            
            byte toByte() {
                return (byte) stateChar;
            }
        }

    /**
     * The root of where to place log files and journals.
     */
    protected final File logDir;
    protected final RandomAccessAllocatorFactory randAllocatorFactory;
    protected final DirectoryHashFactory blobDirHashFactory;
    protected final MjdTimeSeriesStorageAllocatorFactory mjdAllocatorFactory;

    RecoveryBase(File logDir, 
                                       DirectoryHashFactory blobDirHashFactory,
                                       RandomAccessAllocatorFactory randAllocatorFactory,
                                       MjdTimeSeriesStorageAllocatorFactory crAllocatorFactory)
       throws IOException {
        
        this.logDir = logDir;
        this.randAllocatorFactory = randAllocatorFactory;
        this.blobDirHashFactory = blobDirHashFactory;
        this.mjdAllocatorFactory = crAllocatorFactory;
        
        if (!logDir.exists()) {
            
            if (!logDir.mkdirs()) {
                throw new IOException("Failed to create log directory \"" +
                    logDir + "\".");
            }
        }
    }
    
    
    protected Xid xidFromFile(File f) {
        String name = f.getName();
        String xidStr = name.substring(0, name.lastIndexOf('.'));
        Xid xid = Util.stringToXid(xidStr);
        return xid;
    }

}