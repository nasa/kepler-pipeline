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

package gov.nasa.kepler.pi;

import gov.nasa.kepler.pi.dacct.DataAccountabilityReportTest;
import gov.nasa.kepler.pi.models.ModelMetadataOperationsTest;
import gov.nasa.kepler.pi.models.ModelOperationsTest;
import gov.nasa.kepler.pi.module.InputsHandlerTest;
import gov.nasa.kepler.pi.module.io.MatlabProxyGeneratorTest;
import gov.nasa.kepler.pi.notification.PipelineEventNotifierTest;
import gov.nasa.kepler.pi.parameters.ParametersOperationsTest;
import gov.nasa.kepler.pi.pipeline.PipelineExecutorFeatureTest;
import gov.nasa.kepler.pi.pipeline.TaskBinFileDirOperationsTest;
import gov.nasa.kepler.pi.transaction.TransactionServiceTest;
import gov.nasa.kepler.pi.transaction.XATransactionRecoveryTest;
import gov.nasa.kepler.pi.worker.TaskLogTest;
import gov.nasa.kepler.pi.worker.TaskWorkingDirTest;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirRequestTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class AutoTestSuite {

    public static Test suite() {
        TestSuite suite = new TestSuite("Tests for gov.nasa.kepler.pi");

        // gov.nasa.kepler.pi.module
        suite.addTest(new JUnit4TestAdapter(InputsHandlerTest.class));
        
        // gov.nasa.kepler.pi.module.io
        suite.addTest(new JUnit4TestAdapter(MatlabProxyGeneratorTest.class));

        // gov.nasa.kepler.pi.notification
        suite.addTest(new JUnit4TestAdapter(PipelineEventNotifierTest.class));

        // gov.nasa.kepler.pi.parameters
        suite.addTest(new JUnit4TestAdapter(ParametersOperationsTest.class));

        // gov.nasa.kepler.pi.pipeline
        suite.addTest(new JUnit4TestAdapter(PipelineExecutorFeatureTest.class));
        suite.addTest(new JUnit4TestAdapter(DataAccountabilityReportTest.class));
        suite.addTest(new JUnit4TestAdapter(TaskBinFileDirOperationsTest.class));

        // gov.nasa.kepler.pi.worker
        suite.addTest(new JUnit4TestAdapter(TaskLogTest.class));
        suite.addTest(new JUnit4TestAdapter(TaskWorkingDirTest.class));
        suite.addTest(new JUnit4TestAdapter(
            WorkerTaskWorkingDirRequestTest.class));

        // transactions
        suite.addTest(new JUnit4TestAdapter(TransactionServiceTest.class));
        suite.addTest(new JUnit4TestAdapter(XATransactionRecoveryTest.class));

        // model registry
        suite.addTest(new JUnit4TestAdapter(ModelMetadataOperationsTest.class));
        suite.addTest(new JUnit4TestAdapter(ModelOperationsTest.class));

        return suite;
    }

}
