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

package gov.nasa.kepler.ppa.pad;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Unit tests for the PAD wrapper classes. This class directly tests
 * {@link PadPipelineModule#retrieveInputs(gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.hibernate.tad.TargetTable)}
 * , and
 * {@link PadPipelineModule#storeOutputs(gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.hibernate.tad.TargetTable)}
 * .
 * 
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 */
public class PadPipelineModuleTest extends AbstractPadPipelineModuleTest {

    private static final Log log = LogFactory.getLog(PadPipelineModuleTest.class);

    @Test
    public void taskType() {
        assertEquals("unit of work", CadenceUowTask.class,
            getPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void testRequiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = getPipelineModule().requiredParameters();
        assertEquals(1, requiredParameters.size());
        assertEquals(PadModuleParameters.class, requiredParameters.get(0));
    }

    @Test
    public void testPadModuleParametersToString() {
        PadModuleParameters padModuleParameters = new PadModuleParameters();
        assertTrue(padModuleParameters.toString()
            .contains(
                String.format("plottingEnabled=%s",
                    padModuleParameters.isPlottingEnabled())));
    }

    @Test
    public void retrieveInputs() {
        super.createAndRetrieveInputs();
    }

    @Test
    public void storeOutputs() {
        super.createAndStoreOutputs();
    }

    public void processTask(boolean validate) {
        populateObjects();
        createInputs(true);

        log.info("Running pad...");
        getPipelineModule().processTask(createPipelineInstance(),
            getPipelineTask());

        if (validate) {
            log.info("Validating pad...");
            validate((PadInputs) getPipelineModule().getInputs());
            validate((PadOutputs) getPipelineModule().getOutputs());
        }

        log.info("Completed pad test.");
    }

    @Test
    public void processTask() {
        try {
            processTask(true);
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            fail("unexpected exception: " + e + ": " + e.getMessage());
        }
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void forceFatalException() {
        setForceFatalException(true);
        try {
            processTask(false);
            fail("expected fatal processing exception");
        } catch (ModuleFatalProcessingException mfpe) {
            assertNotNull("exception message null", mfpe.getMessage());
            throw mfpe;
        }
    }

    @Test
    public void forceAlert() {
        setForceAlert(true);
        processTask(false);
    }

    @Test
    public void serializeInputs() throws Exception {
        super.createAndSerializeInputs();
    }

    @Test
    public void serializeOutputs() throws Exception {
        super.createAndSerializeOutputs();
    }
}
