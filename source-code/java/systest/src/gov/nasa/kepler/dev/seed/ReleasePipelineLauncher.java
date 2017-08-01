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

package gov.nasa.kepler.dev.seed;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class ReleasePipelineLauncher {

    private static final Log log = LogFactory.getLog(ReleasePipelineLauncher.class);

    private void launch() throws Exception {
        fireTrigger(CommonPipelineSeedData.DEV_SETUP_PIPELINE_NAME);
    }

    private void fireTrigger(final String triggerName) throws Exception {
        log.info("Launching " + triggerName);

        MessagingServiceFactory.setUseXa(false);
        DatabaseServiceFactory.setUseXa(false);

        TransactionService transactionService = TransactionServiceFactory.getInstance(false);

        try {
            transactionService.beginTransaction(true, true, false);

            TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud(
                DatabaseServiceFactory.getInstance());
            TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(triggerName);
            PipelineOperations pipelineOperations = new PipelineOperations();
            pipelineOperations.fireTrigger(triggerDefinition,
                triggerDefinition.getPipelineDefinitionName()
                    .toString());

            transactionService.commitTransaction();
        } catch (Exception e) {
            log.error("Unable to fire trigger.", e);
            System.exit(1);
        } finally {
            transactionService.rollbackTransactionIfActive();
        }

        log.info("Done launching " + triggerName);
    }

    public static void main(String[] args) throws Exception {
        ReleasePipelineLauncher launcher = new ReleasePipelineLauncher();
        launcher.launch();
        System.exit(0);
    }

}
