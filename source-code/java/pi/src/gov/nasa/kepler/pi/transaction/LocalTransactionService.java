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

import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.LocalTransactionalResource;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;

import java.util.ArrayList;

import javax.transaction.TransactionManager;

/**
 * When XA is disabled this manages the different local transactions of
 * the enlisted resources.  Note that using this makes it more likely that in
 * a failure different transactional sources will be inconsistent.
 * 
 * @author Sean McCauliff
 *
 */
class LocalTransactionService implements TransactionService {

    /**
     * Resources that are enlisted in the current transaction for the thread.
     */
    private ThreadLocal<ArrayList<LocalTransactionalResource>> 
        enlistedResources;
    
    LocalTransactionService() {
        enlistedResources = 
            new ThreadLocal<ArrayList<LocalTransactionalResource>>();
        
    } 
    

    @Override
    public void beginTransaction() {
        beginTransaction(true, true, true);
    }

    @Override
    public void commitTransaction() {
        for (LocalTransactionalResource lresource : enlistedResources.get()) {
            lresource.commitLocalTransaction();
        }
        enlistedResources.remove();
        DatabaseServiceFactory.clearNotUsingService(false);
        FileStoreClientFactory.clearNotUsingService();
        MessagingServiceFactory.clearNotUsingService(false);
    }

    @Override
    public void rollbackTransaction() {    
        for (LocalTransactionalResource lresource : enlistedResources.get()) {
            lresource.rollbackLocalTransactionIfActive();
        }
        enlistedResources.remove();
        
        DatabaseServiceFactory.clearNotUsingService(false);
        FileStoreClientFactory.clearNotUsingService();
        MessagingServiceFactory.clearNotUsingService(false);
    }

    @Override
    public void beginTransaction(boolean db, boolean jms, boolean fs) {
        
        enlistedResources.set(new ArrayList<LocalTransactionalResource>());
        
        
        if (fs) {
            LocalTransactionalResource ltr =
                (LocalTransactionalResource) FileStoreClientFactory.getInstance();
            enlistedResources.get().add(ltr);
        } else {
            FileStoreClientFactory.markNotUsingService();
        }
        
        if (db) {
            LocalTransactionalResource ltr = 
                (LocalTransactionalResource)DatabaseServiceFactory.getInstance(false);
            enlistedResources.get().add(ltr);
        } else {
            DatabaseServiceFactory.markNotUsingService(false /*xa*/);
        }
        
        if (jms) {
            LocalTransactionalResource ltr =
                (LocalTransactionalResource) MessagingServiceFactory.getInstance(false);
            enlistedResources.get().add(ltr);
        } else {
            MessagingServiceFactory.markNotUsingService(false);
        }
        
 
        
        for (LocalTransactionalResource ltr : enlistedResources.get()) {
            ltr.beginLocalTransaction();
        }
        
    }

    @Override
    public TransactionManager transactionManager() {
        return null;  //It's ok to do this.
    }

    @Override
    public String userTransactionName() {
        return null; //It's ok to do this.
    }


    @Override
    public void rollbackTransactionIfActive() {
        if (enlistedResources.get() == null) {
            return;
        }
        rollbackTransaction();
    }


    @Override
    public boolean transactionIsActive() {
        if (enlistedResources.get() == null) {
            return false;
        }
        for (LocalTransactionalResource resource : enlistedResources.get()) {
            if (resource.localTransactionIsActive()) {
                return true;
            }
        }
        return false;
    }

}
