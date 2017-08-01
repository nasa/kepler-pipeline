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

package gov.nasa.kepler.aft.dv;

import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.dv.DvPipelineModule;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class provides the basis for tests of the DV pipeline modules.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public abstract class AbstractDvFeatureTest extends AutomatedFeatureTest {

    private static final Log log = LogFactory.getLog(AbstractDvFeatureTest.class);

    protected static final String DV_TRIGGER_NAME = "DV";

    private int runPipelineCount;

    /**
     * Creates an {@link AbstractDvFeatureTest} and runs one pipeline.
     * 
     * @param testName the name of the test
     */
    public AbstractDvFeatureTest(String testName) {
        this(testName, 1);
    }

    /**
     * Creates an {@link AbstractDvFeatureTest} and runs the pipeline {@code
     * runPipelineCount} times.
     * 
     * @param testName the name of the test
     * @param runPipelineCount the number of times to run the pipeline
     */
    public AbstractDvFeatureTest(String testName, int runPipelineCount) {
        super(DvPipelineModule.MODULE_NAME, testName);

        this.runPipelineCount = runPipelineCount;
    }

    @Override
    protected void createDatabaseContents() throws Exception {

        log.info(getLogName() + ": Importing pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + DvPipelineModule.MODULE_NAME + ".xml"));
    }

    @Override
    protected void process() throws Exception {
        for (int i = 0; i < runPipelineCount; i++) {
            log.info(String.format("%s: Running pipeline %d of %d",
                getLogName(), i + 1, runPipelineCount));
            runPipeline(DV_TRIGGER_NAME);
        }
    }
}
