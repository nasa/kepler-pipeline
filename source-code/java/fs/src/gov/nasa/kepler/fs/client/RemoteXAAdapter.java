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

package gov.nasa.kepler.fs.client;

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

import gov.nasa.kepler.fs.api.RemoteXAResource;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.spiffy.common.io.FileUtil;

import javax.transaction.xa.XAException;
import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import com.arjuna.ats.jta.resources.StartXAResource;

/**
 * Implements the XAResource methods and forwards them to the remote 
 * resource.
 * 
 * StartXAResource is a proprietary interface that causes prepare() and
 * commit() to be executed first on this resource before other resources.
 * 
 * @author Sean McCauliff
 *
 */
class RemoteXAAdapter implements XAResource, StartXAResource, Serializable {

    private static final long serialVersionUID = -8827660303165249771L;

    private static final int DEFAULT_TIMEOUT_SECS = 60*60;
    private static final long UNINIT_SERVER_ID = -1L;
    
    private RemoteXAResource remote;
    private int timeOutSecs = DEFAULT_TIMEOUT_SECS;
    private transient boolean agressiveClose = false;
    private volatile long serverId;

    
    RemoteXAAdapter(RemoteXAResource remote) {
        this.remote = remote;
        serverId = UNINIT_SERVER_ID;
    }
    
    /** Part of serialization. */
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
    }
    /** Part of serialization. */
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        try {
            if (serverId != remote.getServerId()) {
                throw new IllegalStateException("Not connected to the same " +
                    "server after deserialization.");
            }
        } catch (XAException xe) {
            throw new IllegalStateException("Can't get server id.", xe);
        } finally {
            FileUtil.close(remote);
        }
        agressiveClose = true;
    }
    
    RemoteXAResource remoteResource() {
        return remote;
    }
    
    /**
     * @see javax.transaction.xa.XAResource#commit(javax.transaction.xa.Xid, boolean)
     */
    public void commit(Xid xid, boolean onePhase) throws XAException {
        try {
            remote.commit(new PersistableXid(xid), onePhase);
        } catch (RuntimeException rte) {
            throwXaErrorFromRuntimeException(rte);
            throw new XAException("Should not have reached here.");
        } finally {
            performClose();
        }
    }

    /**
     * @see javax.transaction.xa.XAResource#end(javax.transaction.xa.Xid, int)
     */
    public void end(Xid xid, int flags) throws XAException {
        try {
            remote.end(new PersistableXid(xid), flags);
        } finally {
            performClose();
        }
    }

    /**
     * @see javax.transaction.xa.XAResource#forget(javax.transaction.xa.Xid)
     */
    public void forget(Xid xid) throws XAException {
        try {
            remote.forget(new PersistableXid(xid));
        } finally {
            performClose();
        }
    }

    /**
     * @see javax.transaction.xa.XAResource#getTransactionTimeout()
     */
    public int getTransactionTimeout() throws XAException {
        return timeOutSecs;
    }

    /**
     * @see javax.transaction.xa.XAResource#isSameRM(javax.transaction.xa.XAResource)
     */
    public boolean isSameRM(XAResource other) throws XAException {
        if (this == other) {
            return true;
        }
        if (!(other instanceof RemoteXAAdapter)) {
            return false;
        }
        
        if (this.serverId == UNINIT_SERVER_ID) {
            try {
                this.serverId = this.remote.getServerId();
            } finally {
                performClose();
            }
        }
        RemoteXAAdapter otherRemote = (RemoteXAAdapter) other;
        return otherRemote.remote.getServerId() == this.serverId;
    }

    /**
     * @see javax.transaction.xa.XAResource#prepare(javax.transaction.xa.Xid)
     */
    public int prepare(Xid xid) throws XAException {
        try {
            return remote.prepare(new PersistableXid(xid));
        } catch (RuntimeException rte) {
            throwXaErrorFromRuntimeException(rte);
            throw new XAException("Should not have reached here.");
        } finally {
            performClose();
        }
    }

    /**
     * This implementation will not forward the flags used.  Instead it
     * will track if more are needed.
     * @see javax.transaction.xa.XAResource#recover(int)
     */
    public Xid[] recover(int flags) throws XAException {
        try {
            switch (flags) {
                case XAResource.TMSTARTRSCAN:
                    return remote.recover(flags);
                case XAResource.TMNOFLAGS:
                case XAResource.TMENDRSCAN:
                    return new Xid[0];
                default:
                    throw new XAException("Bad flags :" + flags);
            }
        } finally {
            performClose();
        }
    }

    /**
     * @see javax.transaction.xa.XAResource#rollback(javax.transaction.xa.Xid)
     */
    public void rollback(Xid xid) throws XAException {
        try {
            remote.rollback(new PersistableXid(xid));
        } catch (RuntimeException rte) {
            throwXaErrorFromRuntimeException(rte);
            throw new XAException("Should not have reached here.");
        } finally {
            performClose();
        }
    }

    /**
     * The specification of this method is vague.  When a new transaction
     * is created on the resource with start() it will use the currently set
     * transaction timeout.  If transactions that have already been started
     * are not changed by a call to setTransactionTimeout.
     * 
     * @see javax.transaction.xa.XAResource#setTransactionTimeout(int)
     */
    public boolean setTransactionTimeout(int seconds) throws XAException {
        if (seconds < 0) {
            return false;
        }
        if (seconds == 0) {
            timeOutSecs = DEFAULT_TIMEOUT_SECS;
        } else {
            timeOutSecs = seconds;
        }
        return true;
        
    }

    /**
     * @see javax.transaction.xa.XAResource#start(javax.transaction.xa.Xid, int)
     */
    public void start(Xid xid, int flags) throws XAException {
        if (flags != XAResource.TMRESUME && flags != XAResource.TMNOFLAGS && flags != XAResource.TMJOIN) {
            throw new XAException(XAException.XAER_RMERR);
        }
        
        try {
            if (serverId == UNINIT_SERVER_ID) {
                serverId = remote.getServerId();
            }
            
            remote.start(new PersistableXid(xid), timeOutSecs);
        } finally {
            performClose();
        }
    }

    private void performClose() {
        if (agressiveClose) {
            FileUtil.close(remote);
        }
    }
    
    private void throwXaErrorFromRuntimeException(RuntimeException rte) throws XAException {
        XAException xaException = new XAException("Unhandled runtime exception.");
        xaException.initCause(rte);
        xaException.errorCode = XAException.XA_RBPROTO;
        throw xaException;
    }
}
