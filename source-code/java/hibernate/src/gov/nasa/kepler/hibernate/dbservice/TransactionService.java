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

package gov.nasa.kepler.hibernate.dbservice;

import gov.nasa.spiffy.common.pi.PipelineException;

import javax.transaction.HeuristicCommitException;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.RollbackException;
import javax.transaction.TransactionManager;

/**
 * Abstracts transaction demarcation.
 * 
 * @author Sean McCauliff
 *
 */
public interface TransactionService {

    /**
     * Associates a transaction with the current thread.  Enlists all known
     * XAServices: jms, db, file store.
     *
     */
    void beginTransaction() throws PipelineException;
    
    /**
     * Associates a transaction with the current thread.  Enlists only specified
     * XAServices.
     * @param db Enlist the db service with the calling thread's transaction.
     * @param jms Enlist the messaging service with the calling thread's transaction.
     * @param fs Enlist the file store with the with the calling thread's transaction.
     */
    void beginTransaction(boolean db, boolean jms, boolean fs) throws PipelineException;
    
    /**
     * Rollsback the transaction associated with the current thread.
     *
     */
    void rollbackTransaction() throws PipelineException; 
    
    /**
     * Rollsback the transaction associated with the current thread if one is 
     * active.
     *
     */
    void rollbackTransactionIfActive() throws PipelineException; 
    
    /**
     * Commits the transaction associated with the current thread.
     * @throws RollbackException 
     * @throws HeuristicCommitException 
     * @throws HeuristicMixedException 
     * @throws HeuristicRollbackException 
     *
     */
    void commitTransaction() throws 
        HeuristicRollbackException, HeuristicMixedException,
        HeuristicCommitException, RollbackException;
    
   
    /**
     * @return  This will return null for non-XA transactions, otherwise
     * returns the TransactionManager.
     */
    TransactionManager transactionManager();
    
    /**
     * 
     * @return This will return null for non-XA transactions otherwise this will
     *  return the JNDI name of the java.transaction.UserTransaction object.
     */
    String userTransactionName();
    
    /**
     * @return true if the calling thread is participating in a transaction else
     * this returns false.
     */
    boolean transactionIsActive();
    
}
