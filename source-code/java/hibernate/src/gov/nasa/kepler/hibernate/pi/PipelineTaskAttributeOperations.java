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

package gov.nasa.kepler.hibernate.pi;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PipelineTaskAttributeOperations {
    private static final Log log = LogFactory.getLog(PipelineTaskAttributeOperations.class);
    private static final ExecutorService updateExecutor = Executors.newSingleThreadExecutor();

    
    public PipelineTaskAttributeOperations() {
    }

    public void updateSubTaskCounts(final long taskId, final long instanceId,
        final int numSubTasksTotal, final int numSubTasksComplete, final int numSubTasksFailed){
        
        Future<?> result = updateExecutor.submit(new Runnable() {
            @Override
            public void run() {
                DatabaseService dbService = DatabaseServiceFactory.getInstance(false);
                try {
                    dbService.beginTransaction();
                    
                    PipelineTaskAttributes attrs = new PipelineTaskAttributes();
                    attrs.setNumSubTasksTotal(numSubTasksTotal);
                    attrs.setNumSubTasksComplete(numSubTasksComplete);
                    attrs.setNumSubTasksFailed(numSubTasksFailed);
                    
                    PipelineTaskAttributeCrud crud = new PipelineTaskAttributeCrud();
                    
                    crud.update(taskId, instanceId, attrs.getAttributeMap());

                    dbService.commitTransaction();
                } catch (RuntimeException e) {
                    log.error("Failed to update task counts", e);
                    dbService.rollbackTransactionIfActive();
                    throw e;
                }
            }
        });

        try {
            result.get();
        } catch (Exception e) {
            log.error("Failed to update sub-task counts, caught e=" + e, e);
        }
    }
    
    public void updateProcessingState(final long taskId, final long instanceId,
        final PipelineTaskAttributes.ProcessingState newState){
        
        Future<?> result = updateExecutor.submit(new Runnable() {
            @Override
            public void run() {
                DatabaseService dbService = DatabaseServiceFactory.getInstance(false);
                try {
                    dbService.beginTransaction();
                    
                    PipelineTaskAttributes attrs = new PipelineTaskAttributes();
                    attrs.setProcessingState(newState);
                    
                    PipelineTaskAttributeCrud crud = new PipelineTaskAttributeCrud();
                    crud.update(taskId, instanceId, attrs.getAttributeMap());

                    dbService.commitTransaction();
                } catch (RuntimeException e) {
                    log.error("Failed to update task counts", e);
                    dbService.rollbackTransactionIfActive();
                    throw e;
                }
            }
        });

        try {
            result.get();
        } catch (Exception e) {
            log.error("Failed to update sub-task counts, caught e=" + e, e);
        }
    }
}
