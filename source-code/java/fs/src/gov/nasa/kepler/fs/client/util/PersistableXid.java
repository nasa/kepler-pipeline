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

package gov.nasa.kepler.fs.client.util;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.Serializable;
import java.util.Arrays;

import javax.transaction.xa.Xid;

/**
 * A transaction id that can be sent across the network. 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public class PersistableXid implements Xid, Persistable, Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = -7449576932600868807L;
    
    private byte[] branchQualifier;
    private byte[] globalTransactionId;
    private int formatId;
    private boolean nullTransaction;
    private String xactionThreadName = "";
    
    public PersistableXid(Xid orig) {
        if (orig instanceof PersistableXid) {
            PersistableXid origPersistable = (PersistableXid) orig;
            this.nullTransaction = origPersistable.nullTransaction;
            this.xactionThreadName = origPersistable.xactionThreadName;
        } else {
            this.nullTransaction = false;
        }
        byte[] origBranchQualifier = orig.getBranchQualifier();
        this.branchQualifier = Arrays.copyOf(origBranchQualifier, origBranchQualifier.length);
        byte[] origGlobalTransactionId = orig.getGlobalTransactionId();
        this.globalTransactionId = 
            Arrays.copyOf(origGlobalTransactionId, origGlobalTransactionId.length);
        this.formatId = orig.getFormatId();

    }
    
    protected PersistableXid(int global, int branch, int format) {
        this.globalTransactionId = new byte[4];
        globalTransactionId[0] = (byte) (0xFF & global);
        globalTransactionId[1] = (byte) (0xFF & (global >> 8));
        globalTransactionId[2] = (byte) (0xFF & (global >> 16));
        globalTransactionId[3] = (byte) (0xFF & (global >> 24));
        
        this.branchQualifier = new byte[4];
        branchQualifier[0] = (byte) (0xFF & branch);
        branchQualifier[1] = (byte) (0xFF & (branch >> 8));
        branchQualifier[2] = (byte) (0xFF & (branch >> 16));
        branchQualifier[3] = (byte) (0xFF & (branch >> 24));
        
        this.formatId = format;
        xactionThreadName = Thread.currentThread().getName();
    }
    
    public PersistableXid(byte[] global, byte[] branch, int format) {
        this.branchQualifier = branch;
        this.globalTransactionId = global;
        this.formatId = format;
        xactionThreadName = Thread.currentThread().getName();
    }
    
    /**
     * This must be public in order to support the Persistable interface.
     * Do not use this constructor.
     */
    public PersistableXid() {
        this.nullTransaction = true;
        this.branchQualifier = new byte[0];
        this.globalTransactionId = this.branchQualifier;
        this.formatId = -1;
        xactionThreadName = Thread.currentThread().getName();
    }
    
    public static PersistableXid newNullTransaction() {
        return new PersistableXid();
    }
    
    /**
     * @see javax.transaction.xa.Xid#getBranchQualifier()
     */
    public byte[] getBranchQualifier() {
        return branchQualifier;
    }

    /**
     * @see javax.transaction.xa.Xid#getFormatId()
     */
    public int getFormatId() {  
        return this.formatId;
    }

    /**
     * @see javax.transaction.xa.Xid#getGlobalTransactionId()
     */
    public byte[] getGlobalTransactionId() {
        return this.globalTransactionId;
    }
    
    @Override
    public String toString() {
       return  Util.xidToString(this);
    }
    
  
    
    /**
     * Checks if this Xid represents an empty transaction.  That is the client
     * has not yet started a transaction.
     * 
     * @return true if this is the null transaction, else false.
     */
    public boolean isNullTransaction() {
        return nullTransaction;
    }
    
    /**
     * Returns the name of the thread which started this transaction.
     * @return
     */
    public String getXactionThreadName() {
        return xactionThreadName;
    }
    
    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        
        if (!(o instanceof PersistableXid)) {
            return false;
        }
        
        PersistableXid other = (PersistableXid) o;
        if (other.nullTransaction != this.nullTransaction) return false;
        if (!Arrays.equals(other.branchQualifier, this.branchQualifier)) return false;
        if (!Arrays.equals(other.globalTransactionId, this.globalTransactionId)) return false;
        if (other.formatId != this.formatId) return false;
        
        return true;
    }
    
    
    @Override
    public int hashCode() {
        final int PRIME = 31;
        int hash = PRIME;
        
        hash *= (nullTransaction) ? PRIME : 1;
        hash ^= Arrays.hashCode(globalTransactionId);
        hash ^= Arrays.hashCode(branchQualifier);
        hash ^= PRIME * formatId;
        
        return hash;
    }

}
