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

package gov.nasa.kepler.fs.api;

import java.io.Closeable;
import java.io.Serializable;

import gov.nasa.kepler.fs.api.gen.IgnoreClientGeneration;
import gov.nasa.kepler.fs.api.gen.IgnoreServerGeneration;
import gov.nasa.kepler.fs.api.gen.ImplicitParameter;
import gov.nasa.kepler.fs.client.util.PersistableXid;

import javax.transaction.xa.XAException;

/**
 * These are all the same methods as XAResource except that it uses
 * PersistableXid instead of Xid in order to make the the Xid easily
 * transmittable.
 * 
 * @author Sean McCauliff
 *
 */
public interface RemoteXAResource extends Serializable, Closeable {

    /**
     * @see javax.transaction.xa.XAResource#commit(javax.transaction.xa.PersistableXid, boolean)
     */
    public void commit(PersistableXid xid, boolean onePhase) throws XAException;

    /**
     * This changes the thread association state of the transaction which
     * exists purely in the resource manager and not on the server.
     * 
     * @see javax.transaction.xa.XAResource#end(javax.transaction.xa.PersistableXid, int)
     */
    @IgnoreClientGeneration
    @IgnoreServerGeneration
    public void end(PersistableXid xid, int flags) throws XAException;

    /**
     * @see javax.transaction.xa.XAResource#forget(javax.transaction.xa.PersistableXid)
     */
    public void forget(PersistableXid xid) throws XAException ;


    /**
     * @param xaResource This is actually different from the XAResource API.
     *   Here it is a String.  
     * @see javax.transaction.xa.XAResource#isSameRM(javax.transaction.xa.XAResource)
     */
    public long getServerId() throws XAException;

    /**
     * @see javax.transaction.xa.XAResource#prepare(javax.transaction.xa.PersistableXid)
     */
    public int prepare(PersistableXid xid) throws XAException;

    /**
     * @see javax.transaction.xa.XAResource#recover(int)
     */
    public PersistableXid[] recover(int flag) throws XAException;

    /**
     * @see javax.transaction.xa.XAResource#rollback(javax.transaction.xa.PersistableXid)
     */
    public void rollback(PersistableXid xid) throws XAException;


    /**
     * @see javax.transaction.xa.XAResource#start(javax.transaction.xa.PersistableXid, int)
     */
    public void start(PersistableXid xid, int timeOut) throws XAException;
    
    @ImplicitParameter(name="xid",type=PersistableXid.class)
    public boolean setTransactionTimeout( int timeOut) throws XAException;
}
