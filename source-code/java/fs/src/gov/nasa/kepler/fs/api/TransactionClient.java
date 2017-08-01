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
package gov.nasa.kepler.fs.api;

import gov.nasa.kepler.fs.api.gen.IgnoreClientGeneration;
import gov.nasa.kepler.fs.api.gen.IgnoreServerGeneration;
import gov.nasa.kepler.fs.api.gen.ImplicitParameter;
import gov.nasa.kepler.fs.client.util.PersistableXid;

import javax.transaction.xa.Xid;

/**
 * This is the transaction interface for local transactions, that is transactions
 * that are only known between the file store the client thread calling
 * beginLocalFSTransaction().  Note this does not start a distributed transaction.
 * 
 * These methods have different names from LocalTransactionalService so 
 * that the return types may differ.
 * 
 * @author Jason Brittain jbrittain@mail.arc.nasa.gov
 * @author Sean McCauliff
 */
public interface TransactionClient {

    /**
     * Tests connectivity.
     */
    void ping();
    
    /**
     * Client begins a File Store transaction.
     * @return The current transaction id.  This may be useful for logging,
     * otherwise it can safely be ignored.
     */
    Xid beginLocalFsTransaction();
    
    /**
     * Client commits all File Store writes that are part of the transaction.
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    void commitLocalFsTransaction();

    /**
     * Client rolls back all File Store writes that are part of the transaction.
     */
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    void rollbackLocalFsTransaction();
    
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    void rollbackLocalFsTransactionIfActive();
    
    /**
     * Disassocates the calling thread from any current and future transactions
     * it might be involved with other existing threads. If this is the only
     * thread in a transaction then the transaction will be lost and rolledback
     * when the autorollback time has been reached.
     */
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    void disassociateThread();

}
