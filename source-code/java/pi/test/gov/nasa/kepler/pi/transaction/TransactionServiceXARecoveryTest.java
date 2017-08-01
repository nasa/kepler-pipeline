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

package gov.nasa.kepler.pi.transaction;

import java.io.Serializable;

import javax.transaction.TransactionManager;
import javax.transaction.xa.XAException;
import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;

/**
 * @author Sean McCauliff
 *
 */
public class TransactionServiceXARecoveryTest {

    private static final Log log = 
        LogFactory.getLog(TransactionServiceXARecoveryTest.class);
    
    public static void main(String[] argv) throws Exception {
        TransactionService xService = TransactionServiceFactory.getInstance(true);
        TransactionManager xManager = xService.transactionManager();
        xManager.begin();
        xManager.getTransaction().enlistResource(new TestXAResource(0, argv[0].equals("die")));
        xManager.getTransaction().enlistResource(new TestXAResource(1, false));
        xManager.commit();
    }
    
    public static class TestXAResource implements XAResource, Serializable {
        private static final long serialVersionUID = -2683412342464407542L;
        private Xid xid;
        private int transactionTimeOut = -1;
        @SuppressWarnings("unused")
        private int resourceId;
        private transient boolean die = false;
        
        public TestXAResource(int resourceId, boolean die) {
            this.resourceId = resourceId;
            this.die = die;
        }
        
        @Override
        public void commit(Xid xid, boolean singlePhase) throws XAException {
            checkXid(xid);
            log.info("Committed transaction.");
            if (die) {
                log.info("Die");
                System.exit(23);
            }
        }

        @Override
        public void end(Xid xid, int flags) throws XAException {
            checkXid(xid);
            log.info("Transaction end.");
        }

        @Override
        public void forget(Xid xid) throws XAException {
            checkXid(xid);
            log.info("Transaction forgotten.");
            xid = null;
        }

        @Override
        public int getTransactionTimeout() throws XAException {
            log.info("getTransactionTimeout()");
            return transactionTimeOut;
        }

        @Override
        public boolean isSameRM(XAResource xaResource) throws XAException {
            log.info("isSameRM");
            return xaResource == this;
        }

        @Override
        public int prepare(Xid xid) throws XAException {
            checkXid(xid);
            log.info("Prepare called.");
            return XA_OK;
        }

        @Override
        public Xid[] recover(int flags) throws XAException {
            log.info("recover flags: " + flags);
            
            switch (flags) {
                case TMSTARTRSCAN:
                    if (xid != null) {
                        return new Xid[] { xid };
                    } else {
                        return new Xid[0];
                    }
                case TMENDRSCAN:
                    return new Xid[0];
                default:
                    throw new IllegalArgumentException("Bad scan flag " + flags);
            }

        }

        @Override
        public void rollback(Xid xid) throws XAException {
            log.info("rollback");
            checkXid(xid);
            this.xid = null;
        }

        @Override
        public boolean setTransactionTimeout(int newValue) throws XAException {
            log.info("setTransactionTimeout");
            this.transactionTimeOut  = newValue;
            return true;
        }

        @Override
        public void start(Xid xid, int flags) throws XAException {
            log.info("Transaction start.");
            if (this.xid != null && !this.xid.equals(xid)) {
                throw new IllegalStateException("transaction already bound");
            }
            this.xid = xid;
        }
        
        private void checkXid(Xid xid) {
            if (!xid.equals(this.xid)) {
                throw new IllegalStateException("Bad xid.");
            }
        }
    }
} 
