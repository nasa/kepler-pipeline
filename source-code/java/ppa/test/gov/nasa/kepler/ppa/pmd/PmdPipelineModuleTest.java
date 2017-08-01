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

package gov.nasa.kepler.ppa.pmd;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.TpsTypeParameters;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * Unit tests for the PMD wrapper classes. This class directly tests
 * {@link PmdPipelineModule#retrieveInputs(gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.hibernate.tad.TargetTable)}
 * , and
 * {@link PmdPipelineModule#storeOutputs(gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.hibernate.tad.TargetTable)}
 * .
 * 
 * @author Bill Wohler
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 */
public class PmdPipelineModuleTest extends AbstractPmdPipelineModuleTest {

    private static final Log log = LogFactory.getLog(PmdPipelineModuleTest.class);

    @Test
    public void testPmdOutputs() {
        PmdOutputs pmdOutputs = new PmdOutputs();
        assertNotSame(42, pmdOutputs.getCcdModule());
        pmdOutputs.setCcdModule(42);
        assertEquals(42, pmdOutputs.getCcdModule());

        assertNotSame(42, pmdOutputs.getCcdOutput());
        pmdOutputs.setCcdOutput(42);
        assertEquals(42, pmdOutputs.getCcdOutput());

        PmdOutputTsData pmdOutputTsData = new PmdOutputTsData();
        assertNotSame(pmdOutputTsData, pmdOutputs.getOutputTsData());
        pmdOutputs.setOutputTsData(pmdOutputTsData);
        assertEquals(pmdOutputTsData, pmdOutputs.getOutputTsData());

        PmdReport pmdReport = new PmdReport();
        assertNotSame(pmdReport, pmdOutputs.getReport());
        pmdOutputs.setReport(pmdReport);
        assertEquals(pmdReport, pmdOutputs.getReport());

        assertNotSame("foo", pmdOutputs.getReportFilename());
        pmdOutputs.setReportFilename("foo");
        assertEquals("foo", pmdOutputs.getReportFilename());
    }

    @Test
    public void testPmdCdppTsData() {
        PmdCdppTsData pmdCdppTsData = new PmdCdppTsData(0, 0, 0, 0);

        assertNotSame(42.0, pmdCdppTsData.getEffectiveTemp());
        pmdCdppTsData.setEffectiveTemp(42.0F);
        assertEquals(42.0, pmdCdppTsData.getEffectiveTemp(), 0);

        assertNotSame(42, pmdCdppTsData.getKeplerId());
        pmdCdppTsData.setKeplerId(42);
        assertEquals(42, pmdCdppTsData.getKeplerId());

        assertNotSame(42.0, pmdCdppTsData.getKeplerMag());
        pmdCdppTsData.setKeplerMag(42.0F);
        assertEquals(42.0, pmdCdppTsData.getKeplerMag(), 0);

        assertNotSame(42.0, pmdCdppTsData.getLog10SurfaceGravity());
        pmdCdppTsData.setLog10SurfaceGravity(42.0F);
        assertEquals(42.0, pmdCdppTsData.getLog10SurfaceGravity(), 0);

        assertTrue(pmdCdppTsData.toString()
            .contains(String.format("keplerId=%d", pmdCdppTsData.getKeplerId())));
    }

    @Test
    public void taskType() {
        assertEquals(ModOutCadenceUowTask.class,
            getPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void testRequiredParameters() {
        assertEquals(ImmutableList.of(PmdModuleParameters.class,
            AncillaryEngineeringParameters.class,
            AncillaryPipelineParameters.class, FluxTypeParameters.class,
            TpsTypeParameters.class), getPipelineModule().requiredParameters());
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

        log.info("Running pmd...");
        getPipelineModule().processTask(createPipelineInstance(),
            getPipelineTask());

        if (validate) {
            log.info("Validating pmd...");
            validate((PmdInputs) getPipelineModule().getInputs());
            validate((PmdOutputs) getPipelineModule().getOutputs());
        }

        log.info("Done");
    }
}
