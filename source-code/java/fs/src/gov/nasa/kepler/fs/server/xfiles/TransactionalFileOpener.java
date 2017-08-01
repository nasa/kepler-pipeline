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

import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;

import java.io.IOException;
import java.util.Map;

import javax.transaction.xa.Xid;


/**
 * You have can openers, why not file openers?  This object encapsulates the
 * algorithm for opening files so that:
 * 1) There is only one instance of a TransactionalFile per FsId.
 * 2) The minimum number of locks are held to accomplish this.
 * 3) If a transactional file is being held for an extensive period of
 * time by a committing transaction then this will wait until that 
 * transaction has completed.
 * 
 * @author Sean McCauliff
 *
 */
abstract class TransactionalFileOpener<F extends TransactionalFile> {

    TransactionalFileOpener() {
        
    }
    
    protected abstract F loadFile(FsId id) 
        throws FileStoreTransactionTimeOut, IOException, InterruptedException;
    
    protected abstract Map<FsId, TransactionalFile> openFileMap(FsId id);
    
    protected abstract void beginTransaction(F xFile) 
        throws FileStoreTransactionTimeOut, IOException, InterruptedException;
    
    F openFile(Xid xid, FsId id, int lockTimeOutSeconds,
        Map<Xid, FTMContext> allTransactionContexts)
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
    
        Map<FsId, TransactionalFile> openFileMap = openFileMap(id);
        while (true) {
            F xFile = null;
            synchronized (openFileMap) {
                
                //New file case.
                xFile = (F) openFileMap.get(id);
                if (xFile == null) {
                    xFile = loadFile(id);
                    if (xFile == null) {
                        return null;
                    }
                    openFileMap.put(id, xFile);
                    beginTransaction(xFile);
                    return xFile;
                }
                
                //Not new, see if it is locked at the transaction level by
                //a committing thread.
                boolean acquiredReadLock = 
                    xFile.acquireReadLock(xid, lockTimeOutSeconds, false);
                if (acquiredReadLock) {
                    try {
                        //Noone is committing
                        beginTransaction(xFile);
                        return xFile;
                    } finally {
                        xFile.releaseReadLock(xid);
                    }
                }
            }
            //all locks unlocked at this point, waiting for other transaction to
            //complete. 
            while (!xFile.acquireReadLock(xid, lockTimeOutSeconds, false)) {
                //Wait for other transaction to complete.
            	Xid otherTransactionXid = xFile.transactionLockHolder();
            	if (otherTransactionXid == null) {
            		continue; // other transaction may have terminated
            	}
                FTMContext otherTransaction = 
                    allTransactionContexts.get(otherTransactionXid);
                if (otherTransaction == null) {
                    continue; //other transaction may have terminated.
                }
                otherTransaction.acclerateCommit();
            }

            try {
                if (xFile.hasTransactions()) {
                    beginTransaction(xFile);
                    return xFile;
                }
                //If we reached here then we have an xFile that might no longer be
                //unique because the transaction count has fallen to zero.  We need
                //to check open files map to see if its in there is a different
                //TransactionalFile object, but we are holding the read lock on
                //a transactional file without first holding the lock on the open
                //files map.  So we need to release the lock if we are going to do
                //that then we might as well just go back to the beginning.
            } finally {
                xFile.releaseReadLock(xid);
            }
            
        }
        
    }
}
