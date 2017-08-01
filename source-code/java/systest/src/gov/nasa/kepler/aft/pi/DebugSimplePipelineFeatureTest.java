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

package gov.nasa.kepler.aft.pi;

import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.debug.DebugSimplePipelineParameters;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.pi.worker.PipelineFailedException;

import java.io.File;

import javax.transaction.HeuristicCommitException;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.RollbackException;

import org.apache.log4j.Logger;

public class DebugSimplePipelineFeatureTest extends AutomatedFeatureTest {

    private static final String MODULE_OUTPUT_LISTS = "moduleOutputLists";

    private static final String DEBUG_SIMPLE_PARAMS = "debugSimpleParams";

    private static final Logger log = Logger.getLogger(DebugSimplePipelineFeatureTest.class);

    private static final String DEBUG_SIMPLE_TRIGGER_NAME = "DEBUG_SIMPLE";

    public DebugSimplePipelineFeatureTest() {
        super("pi", "DebugSimple");
        setImportFcModels(false);
    }

    @Override
    protected void process() throws Exception {

        updateModuleOutputLists(new int[] { 1, 2, 3, 4, 5 });

        log.info(getLogName() + ": Running the pipeline (instance 1)");
        runPipeline(DEBUG_SIMPLE_TRIGGER_NAME);

        // Modify the mod/out parameters and create a new version
        // to be used by the next pipeline instance.
        updateModuleOutputLists(new int[] { 10, 11 });

        log.info(getLogName() + ": Running the pipeline (instance 2)");
        runPipeline(DEBUG_SIMPLE_TRIGGER_NAME);

        updateDebugSimpleParams(true);

        log.info(getLogName() + ": Running the pipeline (instance 3)");
        try {
            runPipeline(DEBUG_SIMPLE_TRIGGER_NAME);
        } catch (PipelineFailedException e) {
            // This exception is expected for this pipeline since we set
            // FailChannel above...
            log.info(getLogName() + "Pipeline failed, as expected!");
        }
    }

    private void updateModuleOutputLists(int[] moduleOutputs)
        throws HeuristicRollbackException, HeuristicMixedException,
        HeuristicCommitException, RollbackException {

        TransactionService transactionService = TransactionServiceFactory.getInstance();
        PipelineOperations pipelineOps = new PipelineOperations();

        transactionService.beginTransaction(true, false, true);

        ParameterSet parameterSet = retrieveParameterSet(MODULE_OUTPUT_LISTS);
        if (parameterSet == null) {
            throw new NullPointerException(String.format(
                "%s parameter set is missing", MODULE_OUTPUT_LISTS));
        }
        ModuleOutputListsParameters moduleOutputLists = parameterSet.parametersInstance();
        moduleOutputLists.setChannelIncludeArray(moduleOutputs);
        pipelineOps.updateParameterSet(parameterSet.getName(),
            moduleOutputLists, false);

        transactionService.commitTransaction();
    }

    private void updateDebugSimpleParams(boolean fail)
        throws HeuristicRollbackException, HeuristicMixedException,
        HeuristicCommitException, RollbackException {

        TransactionService transactionService = TransactionServiceFactory.getInstance();
        PipelineOperations pipelineOps = new PipelineOperations();

        transactionService.beginTransaction(true, false, true);

        ParameterSet parameterSet = retrieveParameterSet(DEBUG_SIMPLE_PARAMS);
        if (parameterSet == null) {
            throw new NullPointerException(String.format(
                "%s parameter set is missing", DEBUG_SIMPLE_PARAMS));
        }
        DebugSimplePipelineParameters debugSimpleParams = parameterSet.parametersInstance();
        debugSimpleParams.setFail(fail);
        pipelineOps.updateParameterSet(parameterSet.getName(),
            debugSimpleParams, false);

        transactionService.commitTransaction();
    }

    @Override
    protected void createDatabaseContents() throws Exception {

        log.info(getLogName() + ": Importing pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + "debug-simple.xml"));
    }
}