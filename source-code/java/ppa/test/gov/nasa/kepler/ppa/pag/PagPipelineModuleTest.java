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

package gov.nasa.kepler.ppa.pag;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.mc.uow.CadenceUowTask;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * Unit tests for the PAG wrapper classes. This class directly tests
 * {@link PagPipelineModule#retrieveInputs(gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.hibernate.tad.TargetTable)}
 * , and
 * {@link PagPipelineModule#storeOutputs(gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.hibernate.tad.TargetTable)}
 * .
 * <p>
 * The call to {@code getMockery().assertIsSatisfied();} appears to be necessary
 * in the context of this class. If you think you've fixed this, remove this
 * call from a test, add an expectation to that test, and see if you get a "not
 * all expectations were met" exception.
 * 
 * @author Bill Wohler
 */
public class PagPipelineModuleTest extends AbstractPagPipelineModuleTest {

    private static final Log log = LogFactory.getLog(PagPipelineModuleTest.class);

    @Test
    public void testPagModuleParameters() {
        // Just toString, as it isn't otherwise covered by tests.
        PagModuleParameters pagModuleParameters = new PagModuleParameters();
        assertTrue(pagModuleParameters.toString()
            .contains(
                String.format("plottingEnabled=%s",
                    pagModuleParameters.isPlottingEnabled())));
    }

    @Test
    public void testPagOutputs() {
        PagOutputs pagOutputs = new PagOutputs();

        PagOutputTsData pagOutputTsData = new PagOutputTsData();
        assertNotSame(pagOutputTsData, pagOutputs.getOutputTsData());
        pagOutputs.setOutputTsData(pagOutputTsData);
        assertEquals(pagOutputTsData, pagOutputs.getOutputTsData());
    }

    @Test
    public void testPagCompressionTimeSeries() {
        PagCompressionTimeSeries pagCompressionTimeSeries1 = new PagCompressionTimeSeries();
        PagCompressionTimeSeries pagCompressionTimeSeries2 = new PagCompressionTimeSeries();
        int[] codeSymbolCounts = new int[] { 1, 2, 3 };

        pagCompressionTimeSeries1.setCodeSymbolCounts(codeSymbolCounts);
        assertNotSame(pagCompressionTimeSeries1, pagCompressionTimeSeries2);
        assertNotSame(pagCompressionTimeSeries1.hashCode(),
            pagCompressionTimeSeries2.hashCode());

        pagCompressionTimeSeries2.setCodeSymbolCounts(codeSymbolCounts);
        assertEquals(pagCompressionTimeSeries1, pagCompressionTimeSeries2);
        assertEquals(pagCompressionTimeSeries1.hashCode(),
            pagCompressionTimeSeries2.hashCode());
    }

    @Test
    public void testPagInputTsData() {
        PagInputTsData pagInputTsData = new PagInputTsData();

        assertNotSame(42, pagInputTsData.getCcdModule());
        pagInputTsData.setCcdModule(42);
        assertEquals(42, pagInputTsData.getCcdModule());

        assertNotSame(42, pagInputTsData.getCcdOutput());
        pagInputTsData.setCcdOutput(42);
        assertEquals(42, pagInputTsData.getCcdOutput());
    }

    @Test
    public void testRequiredParameters() {
        assertEquals(ImmutableList.of(PagModuleParameters.class),
            getPipelineModule().requiredParameters());
    }

    @Test
    public void taskType() {
        assertEquals(CadenceUowTask.class,
            getPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void retrieveInputs() {
        createAndRetrieveInputs();
    }

    @Test
    public void inputsSerializationTest() throws Exception {
        createAndSerializeInputs();
    }

    @Test
    public void outputsSerializationTest() throws Exception {
        createAndSerializeOutputs();
    }

    @Test
    public void storeOutputs() {
        createAndStoreOutputs();
    }

    @Test
    public void processTask() {
        processTask(true);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void forceFatalException() {
        setForceFatalException(true);
        processTask(false);
    }

    @Test
    public void forceAlert() {
        setForceAlert(true);
        processTask(false);
    }

    public void processTask(boolean validate) {
        populateObjects();
        createInputs(true);

        log.info("Running pag...");
        getPipelineModule().processTask(createPipelineInstance(),
            getPipelineTask());

        if (validate) {
            log.info("Validating pag inputs...");
            validate((PagInputs) getPipelineModule().getInputs());
            log.info("Validating pag outputs...");
            validate((PagOutputs) getPipelineModule().getOutputs());
        }

        log.info("Done");
    }
}
