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

package gov.nasa.kepler.pdc;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.PdcBand;
import gov.nasa.kepler.mc.PdcProcessingCharacteristics;
import gov.nasa.kepler.mc.Transit;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * PDC unit tests.
 * 
 * @author Forrest Girouard
 */
public class PdcInputsRetrieverTest extends AbstractPdcPipelineModuleTest {

    private static final Log log = LogFactory.getLog(PdcInputsRetrieverTest.class);

    private static final double DEFAULT_RA = 17.13;
    private static final double DEFAULT_DEC = 31.71;
    private static final float DEFAULT_MAG = 12.0F;
    private static final String PRIOR_FIT_TYPE = "prior";
    private static final String REGULAR_METHOD = "regularMap";

    @Before
    public void setUp() throws Exception {

        FileUtils.forceMkdir(MATLAB_WORKING_DIR);
    }

    @After
    public void tearDown() throws Exception {
        FileUtils.cleanDirectory(MATLAB_WORKING_DIR);
    }

    @Test
    public void pdcProcessingCharacteristics() {
        List<PdcBand> bands = new ArrayList<PdcBand>();
        bands.add(new PdcBand(PRIOR_FIT_TYPE, 1.0F, 2.0F));
        PdcProcessingCharacteristics pdcProcessingCharacteristics = new PdcProcessingCharacteristics(
            REGULAR_METHOD, 3, 2, true, true, 1.0F, bands);
        assertEquals(REGULAR_METHOD,
            pdcProcessingCharacteristics.getPdcMethod());
        assertEquals(3,
            pdcProcessingCharacteristics.getNumDiscontinuitiesDetected());
        assertEquals(true, pdcProcessingCharacteristics.isHarmonicsFitted());
        assertEquals(true, pdcProcessingCharacteristics.isHarmonicsRestored());
        assertEquals(1.0F, pdcProcessingCharacteristics.getTargetVariability(),
            0.00001F);
        assertEquals(bands, pdcProcessingCharacteristics.getBands());
    }

    @Test
    public void pdcTarget() {
        CelestialObject celestialObject = new Kic.Builder(123456789,
            DEFAULT_RA, DEFAULT_DEC).keplerMag(DEFAULT_MAG)
            .build();
        PdcTarget target = new PdcTarget(123456789, 11.5F, 0.98F, 0.01F,
            new String[] { "BG_APERTURE" }, new CompoundFloatTimeSeries(),
            new CelestialObjectParameters.Builder(celestialObject).build(),
            new ArrayList<Transit>());
        assertNotNull(target.toString());

        List<FsId> fluxFloatTimeSeriesFsIds = PdcTarget.getFluxFloatTimeSeriesFsIds(
            FluxType.SAP, CadenceType.LONG, 123456789);
        assertNotNull(fluxFloatTimeSeriesFsIds);
        assertEquals(2, fluxFloatTimeSeriesFsIds.size());
    }

    @Test
    public void pdcTargetOutputData() {

        PdcTargetOutputData targetOutputData = new PdcTargetOutputData(
            123456789, new CorrectedFluxTimeSeries(), new OutliersTimeSeries(),
            new CorrectedFluxTimeSeries(), new OutliersTimeSeries(),
            new int[] { 42 }, new PdcProcessingCharacteristics(),
            new PdcGoodnessMetric());
        assertNotNull(targetOutputData.toString());

        int[] iseries = new int[150];
        boolean[] gaps = new boolean[150];
        Arrays.fill(gaps, true);
        gaps[42] = false;
        iseries[42] = 1;
        IntTimeSeries discontinuities = new IntTimeSeries(new FsId("/path/id"),
            iseries, 1, 150, gaps, 123L);
        assertEquals(123456789, targetOutputData.getKeplerId());

        int[] indices = targetOutputData.getDiscontinuityIndices();
        assertTrue(Arrays.equals(new int[] { 42 }, indices));

        assertEquals(discontinuities,
            targetOutputData.toDiscontinuitiesTimeSeries(new FsId("/path/id"),
                1, 150, 123L));
    }

    @Test
    public void pdcOutputs() {
        PdcOutputs outputs = new PdcOutputs();
        PdcOutputChannelData pdcOutputChannelData = new PdcOutputChannelData();
        pdcOutputChannelData.setCcdModule(7);
        pdcOutputChannelData.setCcdOutput(3);
        outputs.getChannelData().add(pdcOutputChannelData);
        outputs.setCadenceType(CadenceType.SHORT.toString());
        outputs.setStartCadence(1439);
        outputs.setEndCadence(1588);
        List<PdcTargetOutputData> targets = newArrayList();
        targets.add(new PdcTargetOutputData());
        outputs.setTargetResultsStruct(targets);
        assertNotNull(outputs.toString());
    }

    @Test
    public void pdcPipelineModule() {
        PdcPipelineModule module = new PdcPipelineModule();
        assertTrue(module.requiredParameters()
            .size() > 0);
        assertTrue(module.requiredParameters()
            .contains(PdcModuleParameters.class));
    }

    /**
     * Test the serialization of an empty {@code DvInputs} object.
     * 
     * @throws IllegalAccessException if the comparison fails
     */
    @Test
    public void serializeEmptyInputs() throws IllegalAccessException {
        serializeInputs(new PdcInputs());
    }

    /**
     * Test the serialization of a populated {@code PdcInputs} object.
     * 
     * @throws IllegalAccessException if the comparison fails
     */
    @Test
    public void serializePopulatedInputs() throws IllegalAccessException {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setSerializeInputs(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveLongCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setValidateInputs(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveLongCadenceInputsMapEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setMapEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveShortCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveShortCadenceInputsMapEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setMapEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrievePseudoTargetListEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setPseudoTargetListEnabled(true);
        unitTestDescriptor.setMapEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveUseBasisVectorsFromBlobEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setUseBasisVectorsFromBlob(new boolean[] { false,
            true });
        unitTestDescriptor.setMapEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void generateAlert() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();

        unitTestDescriptor.setGenerateAlerts(true);
        unitTestDescriptor.setValidateOutputs(true);
        processTask(unitTestDescriptor);
    }

    private void processTask(UnitTestDescriptor unitTestDescriptor) {

        setUnitTestDescriptor(unitTestDescriptor);
        populateObjects();
        createInputs();

        log.info("Running pdc...");
        try {
            PdcInputs pdcInputs = getPdcInputsRetriever().retrieveInputs(
                getPipelineTask(),
                getMatlabWorkingDir(),
                new int[] { FcConstants.getChannelNumber(CCD_MODULE, CCD_OUTPUT) });
            if (isValidateInputs()) {
                validate(pdcInputs);
            }
            if (isSerializeInputs()) {
                serializeInputs(pdcInputs);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to retrieve inputs.", e);
        }

        log.info("Done");
    }
}
