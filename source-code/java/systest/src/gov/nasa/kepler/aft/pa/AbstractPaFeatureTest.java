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

package gov.nasa.kepler.aft.pa;

import gov.nasa.kepler.aft.AutomatedFeatureTest;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;

import org.apache.log4j.Logger;

/**
 * Base class for all the PA pipeline module AFTs.
 * 
 * @author Forrest Girouard
 */
public abstract class AbstractPaFeatureTest extends AutomatedFeatureTest {

    @SuppressWarnings("unused")
    private static final Logger log = Logger.getLogger(AbstractPaFeatureTest.class);

    protected static final String PA_LC_TRIGGER_NAME = "PA_LC";
    protected static final String PA_SC_TRIGGER_NAME = "PA_SC";

    public AbstractPaFeatureTest(String testName) {
        super(PaPipelineModule.MODULE_NAME, testName);
    }

    public void updatePaModuleParameters() {

        ParameterSet paParametersSet = retrieveParameterSet(PaPipelineModule.MODULE_NAME);
        if (paParametersSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", PaPipelineModule.MODULE_NAME));
        }
        PaModuleParameters paModuleParameters = paParametersSet.parametersInstance();

        int maxReadFsIds = 3000;
        int maxPixelSamples = getCadenceCount() * 2000;
        paModuleParameters.setMaxReadFsIds(maxReadFsIds);
        paModuleParameters.setMaxPixelSamples(maxPixelSamples);

        // This needs to be explicitly disabled now that the default is true
        paModuleParameters.setPaCoaEnabled(false);

        new PipelineOperations().updateParameterSet(paParametersSet,
            paModuleParameters, false);
    }
}
