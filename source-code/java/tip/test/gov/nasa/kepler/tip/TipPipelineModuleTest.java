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

package gov.nasa.kepler.tip;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;
import junit.framework.JUnit4TestAdapter;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for the TIP pipeline module.
 * 
 * @author Forrest Girouard
 */
public class TipPipelineModuleTest extends AbstractTipPipelineModuleTest {

    public static junit.framework.Test suite() {
        return new JUnit4TestAdapter(TipPipelineModuleTest.class);
    }

    @Before
    public void setUp() throws Exception {
        FileUtils.forceMkdir(MATLAB_WORKING_DIR);
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        FileUtils.cleanDirectory(MATLAB_WORKING_DIR);
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    /**
     * Test the serialization of an empty {@code PaInputs} object.
     * 
     * @throws IllegalAccessException
     */
    @Test
    public void serializeEmptyInputs() throws IllegalAccessException {
        serializeInputs(new TipInputs());
    }

    /**
     * Test the serialization of an empty {@code TipOutputs} object.
     * 
     * @throws IllegalAccessException
     */
    @Test
    public void serializeEmptyOutputs() throws IllegalAccessException {
        serializeOutputs(new TipOutputs());
    }

    /**
     * Test the retrieval of long cadence inputs.
     */
    @Test
    public void retrieveLongCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval of short cadence inputs when the
     * {@code executeAlgorithm} method is called only once.
     */
    @Test
    public void retrieveShortCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setValidateInputs(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void serializeLongCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setSerializeInputs(true);
        processTask(unitTestDescriptor);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void invalidTpsPipelineInstanceId() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setSerializeInputs(true);
        unitTestDescriptor.setTpsPipelineInstanceId(0);
        processTask(unitTestDescriptor);
    }

    public void processTask(final UnitTestDescriptor unitTestDescriptor) {
        setUnitTestDescriptor(unitTestDescriptor);
        populateObjects();
        createInputs();

        TipInputs tipInputs = tipInputsRetriever.retrieveInputs(MATLAB_WORKING_DIR);

        TipOutputs tipOutputs = new TipOutputs();
        executeAlgorithm(pipelineTask, tipInputs, tipOutputs);
        storeOutputs(tipOutputs);
    }

    private void executeAlgorithm(final PipelineTask pipelineTask,
        final Persistable inputs, final Persistable outputs) {
        TipInputs tipInputs = (TipInputs) inputs;
        TipOutputs tipOutputs = (TipOutputs) outputs;
        try {
            if (isValidateInputs()) {
                validate(tipInputs);
            }
            if (isSerializeInputs()) {
                serializeInputs(tipInputs);
            }
            if (isValidateOutputs()) {
                createOutputs(tipInputs, tipOutputs);
            }
        } catch (Exception e) {
            throw new PipelineException(e);
        }
    }

    private void storeOutputs(final TipOutputs tipOutputs) {
        if (isValidateOutputs()) {
            tipOutputsStorer.storeOutputs(MATLAB_WORKING_DIR, tipOutputs);
        }
        if (isSerializeOutputs()) {
            try {
                serializeOutputs(tipOutputs);
            } catch (Exception e) {
                throw new PipelineException(e);
            }
        }
    }
}
