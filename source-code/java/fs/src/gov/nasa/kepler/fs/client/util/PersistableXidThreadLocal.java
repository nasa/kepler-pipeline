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

import gov.nasa.kepler.fs.api.FileStoreTestInterface;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * If the thread local was not explicitly set then this initializes the
 * thread local variable with a special empty id. 
 * 
 * This thread local is inheritable.  Unlike normal inheritable locals this
 * always points to an atomic reference.  This reference never changes,
 * only the thing it refers to changes.  In this way all child thread locals
 * will be updated.
 * 
 * @author Sean McCauliff
 *
 */
public class PersistableXidThreadLocal  {
    
    private final static Log log = 
        LogFactory.getLog(PersistableXidThreadLocal.class);
    
    private final static AtomicInteger idSequence = new AtomicInteger(0);
    
    private final InheritableThreadLocal<AtomicReference<XidInfo>>
        threadLocal;
    
    
    public PersistableXidThreadLocal() {
        threadLocal = new InheritableThreadLocal<AtomicReference<XidInfo>>() {
            @Override
            protected AtomicReference<XidInfo> initialValue() {
                XidInfo xidInfo = new XidInfo();
                AtomicReference<XidInfo> newRef = 
                    new AtomicReference<XidInfo>(xidInfo);
                return newRef;
            }
            @Override
            protected AtomicReference<XidInfo> childValue(AtomicReference<XidInfo> parentValue) {
                return super.childValue(parentValue);
            }
        };
        //This is needed to correctly initialize the Thread's TLS map.
        threadLocal.get();
    }
    
    public PersistableXid xid() {
        return threadLocal.get().get().xid;
    }
    
    public void setXid(PersistableXid xid) {
        threadLocal.get().get().xid = xid;
    }
    
    public void remove() {
        threadLocal.get().get().xid = PersistableXid.newNullTransaction();
    }
    
    public void setState(FileStoreTestInterface.TransactionState newXState) {
        threadLocal.get().get().xState = newXState;
    }
    
    public FileStoreTestInterface.TransactionState xState() {
        return threadLocal.get().get().xState;
    }
    
    /**
     * Breaks the association of the current thread with it's parents.  Once
     * this has been done there is no going back.
     */
    public void disassociate() {
        XidInfo xidInfo = new XidInfo();
        threadLocal.set(new AtomicReference<XidInfo>(xidInfo));
    }
    
    private static final class XidInfo {
        PersistableXid xid;
        FileStoreTestInterface.TransactionState xState;
        
        XidInfo() {
            xid = PersistableXid.newNullTransaction();
            xState = FileStoreTestInterface.TransactionState.INITIAL;
        }
    }
   
}
