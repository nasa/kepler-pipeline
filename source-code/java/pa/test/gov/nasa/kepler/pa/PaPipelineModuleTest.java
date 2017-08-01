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

package gov.nasa.kepler.pa;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import junit.framework.JUnit4TestAdapter;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public class PaPipelineModuleTest extends AbstractPaPipelineModuleTest {

    public static junit.framework.Test suite() {
        return new JUnit4TestAdapter(PaPipelineModuleTest.class);
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

    @Test
    public void paBadPixel() {
        PaBadPixel pixel = new PaBadPixel(123, 456, PixelType.DEAD.name(),
            55500.0, 55500.5, 1.0F);
        assertEquals(123, pixel.getCcdRow());
        assertEquals(456, pixel.getCcdColumn());
        assertEquals("DEAD", pixel.getType());
        assertEquals(55500.0, pixel.getStartMjd(), 1e-10);
        assertEquals(55500.5, pixel.getEndMjd(), 1e-10);
        assertEquals(1.0F, pixel.getValue(), 1e-10);

        assertNotNull(pixel.toString());

        assertTrue(pixel.equals(pixel));
        assertFalse(pixel.equals(null));
        assertFalse(pixel.equals(new Object()));

        PaBadPixel otherPixel = new PaBadPixel(123, 456, PixelType.DEAD.name(),
            55500.0, 55500.5, 1.0F);
        assertTrue(pixel.equals(otherPixel));
        assertEquals(pixel.hashCode(), otherPixel.hashCode());
    }

    @Test
    public void paPixelTimeSeries() {
        PaPixelTimeSeries series = new PaPixelTimeSeries(123, 456, true);
        assertEquals(123, series.getCcdRow());
        assertEquals(456, series.getCcdColumn());
        assertTrue(series.isInOptimalAperture());
        series.setValues(new float[] { 1.0F });
        assertTrue(Arrays.equals(new float[] { 1.0F }, series.getValues()));
        series.setUncertainties(new float[] { 2.0F });
        assertTrue(Arrays.equals(new float[] { 2.0F },
            series.getUncertainties()));
        series.setGapIndicators(new boolean[] { true });
        assertTrue(Arrays.equals(new boolean[] { true },
            series.getGapIndicators()));

        assertNotNull(series.toString());

        assertTrue(series.equals(series));
        assertFalse(series.equals(null));
        assertFalse(series.equals(new Object()));

        PaPixelTimeSeries otherSeries = new PaPixelTimeSeries(123, 456, true);
        otherSeries.setValues(new float[] { 1.0F });
        otherSeries.setUncertainties(new float[] { 2.0F });
        otherSeries.setGapIndicators(new boolean[] { true });
        assertTrue(series.equals(otherSeries));
        assertEquals(series.hashCode(), otherSeries.hashCode());
    }

    @Test
    public void paFluxTarget() {
        PaFluxTarget target = new PaFluxTarget(123456789, 1.0, 2.0, 123, 456);
        assertEquals(123456789, target.getKeplerId());
        assertEquals(1.0, target.getRaHours(), 1e-10);
        assertEquals(2.0, target.getDecDegrees(), 1e-10);
        assertEquals(123, target.getReferenceRow());
        assertEquals(456, target.getReferenceColumn());

        assertNotNull(target.toString());

        assertTrue(target.equals(target));
        assertFalse(target.equals(null));
        assertFalse(target.equals(new Object()));

        PaFluxTarget otherTarget = new PaFluxTarget(123456789, 1.0, 2.0, 123,
            456);
        assertTrue(target.equals(otherTarget));
        assertEquals(target.hashCode(), otherTarget.hashCode());
    }

    @Test
    public void paTarget() {
        Set<Pixel> pixels = new HashSet<Pixel>();
        pixels.add(new Pixel(123, 456, true));
        PaTarget target = new PaTarget(123456789, 123, 456,
            new String[] { "LABEL" }, 4.0F, 4.0F, 4.0F, 4.0F, 3,
            TargetType.LONG_CADENCE, pixels);
        target.setKeplerMag(1.0F);
        target.setRaHours(2.0F);
        target.setDecDegrees(3.0F);
        assertEquals(123456789, target.getKeplerId());
        assertEquals(1.0F, target.getKeplerMag(), 1e-10);
        assertEquals(2.0, target.getRaHours(), 1e-10);
        assertEquals(3.0, target.getDecDegrees(), 1e-10);
        assertEquals(123, target.getReferenceRow());
        assertEquals(456, target.getReferenceColumn());
        assertEquals(4.0F, target.getFluxFractionInAperture(), 1e-10);
        assertTrue(Arrays.equals(new String[] { "LABEL" }, target.getLabels()));

        assertNotNull(target.toString());

        assertTrue(target.equals(target));
        assertFalse(target.equals(null));
        assertFalse(target.equals(new Object()));

        Set<Pixel> otherPixels = new HashSet<Pixel>();
        otherPixels.add(new Pixel(123, 456, true));
        PaTarget otherTarget = new PaTarget(123456789, 123, 456,
            new String[] { "LABEL" }, 4.0F, 4.0F, 4.0F, 4.0F, 3,
            TargetType.LONG_CADENCE, otherPixels);
        otherTarget.setKeplerMag(1.0F);
        otherTarget.setRaHours(2.0F);
        otherTarget.setDecDegrees(3.0F);
        assertTrue(target.equals(otherTarget));
        assertEquals(target.hashCode(), otherTarget.hashCode());
    }

    @Test
    public void paInputs() {
        TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(this, null,
            CadenceType.LONG, 100, 149);
        PrfModel prfModel = MockUtils.mockPrfModel(this, null,
            cadenceTimes.startMjd(), 7, 3);
        List<ConfigMap> configMaps = MockUtils.mockConfigMaps(this, null, 1,
            cadenceTimes.startMjd(), cadenceTimes.endMjd());
        RaDec2PixModel raDec2PixModel = MockUtils.mockRaDec2PixModel(this,
            null, cadenceTimes.startMjd(), cadenceTimes.endMjd());
        ReadNoiseModel readNoiseModel = MockUtils.mockReadNoiseModel(this,
            null, cadenceTimes.startMjd(), cadenceTimes.endMjd());
        GainModel gainModel = MockUtils.mockGainModel(this, null,
            cadenceTimes.startMjd(), cadenceTimes.endMjd());
        LinearityModel linearityModel = MockUtils.mockLinearityModel(this,
            null, 7, 3, cadenceTimes.startMjd(), cadenceTimes.endMjd());

        PaInputs inputs = new PaInputs(7, 3, CadenceType.LONG.getName(), 100,
            149, cadenceTimes, configMaps, prfModel, raDec2PixModel,
            readNoiseModel, gainModel, linearityModel, "", true,
            new AncillaryDesignMatrixParameters(),
            new AncillaryPipelineParameters(), new ApertureModelParameters(),
            new ArgabrighteningModuleParameters(),
            new BackgroundModuleParameters(), new PaCosmicRayParameters(),
            new EncircledEnergyModuleParameters(),
            new GapFillModuleParameters(), new MotionModuleParameters(),
            new OapAncillaryEngineeringParameters(),
            new PaCoaModuleParameters(),
            new PaHarmonicsIdentificationParameters(),
            new PaModuleParameters(), new PouModuleParameters(),
            new ReactionWheelAncillaryEngineeringParameters(),
            new SaturationSegmentModuleParameters(),
            new ThrusterDataAncillaryEngineeringParameters(), cadenceTimes);
        assertEquals(7, inputs.getCcdModule());
        assertEquals(3, inputs.getCcdOutput());
        assertEquals(CadenceType.LONG.getName(), inputs.getCadenceType());
        assertEquals(100, inputs.getStartCadence());
        assertEquals(149, inputs.getEndCadence());
        assertEquals(true, inputs.isFirstCall());
        assertEquals(cadenceTimes, inputs.getCadenceTimes());

        assertNotNull(inputs.toString());

        assertTrue(inputs.equals(inputs));
        assertFalse(inputs.equals(null));
        assertFalse(inputs.equals(new Object()));
    }

    @Test
    public void paPixelCosmicRay() {
        PaPixelCosmicRay ray = new PaPixelCosmicRay(123, 456, 55500.5, 1.0F);
        assertEquals(123, ray.getCcdRow());
        assertEquals(456, ray.getCcdColumn());
        assertEquals(55500.5, ray.getMjd(), 1e-10);
        assertEquals(1.0F, ray.getDelta(), 1e-10);

        assertNotNull(ray.toString());

        assertTrue(ray.equals(ray));
        assertFalse(ray.equals(null));
        assertFalse(ray.equals(new Object()));

        PaPixelCosmicRay otherRay = new PaPixelCosmicRay(123, 456, 55500.5,
            1.0F);
        assertTrue(ray.equals(otherRay));
        assertEquals(ray.hashCode(), otherRay.hashCode());

    }

    /**
     * Test the serialization of an empty {@code PaInputs} object.
     * 
     * @throws IllegalAccessException
     */
    @Test
    public void serializeEmptyInputs() throws IllegalAccessException {
        serializeInputs(new PaInputs());
    }

    /**
     * Test the serialization of an empty {@code PaOutputs} object.
     * 
     * @throws IllegalAccessException
     */
    @Test
    public void serializeEmptyOutputs() throws IllegalAccessException {
        serializeOutputs(new PaOutputs());
    }

    /**
     * Test the retrieval of long cadence inputs. Note that this test will call
     * the {@code validate} method twice for a single execution of the test
     * ensuring that the first call and last call cases are validated.
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
        unitTestDescriptor.setAttitudeAvailable(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the serialization of long cadence populated {@code PaInputs}
     * objects. Note that this test will call the {@code validate} method twice
     * for a single execution of the test ensuring that the first call and last
     * call cases are validated.
     */
    @Test
    public void serializeLongCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setSerializeInputs(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the serialization of short cadence populated {@code PaInputs}
     * objects.
     */
    @Test
    public void serializeShortCadenceInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setSerializeInputs(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the persistence of long cadence outputs. Note that this test will
     * call the {@code storeOutputs} method twice for a single execution of the
     * test ensuring that the first call and last call cases are validated.
     */
    @Test
    public void storeLongCadenceOutputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateOutputs(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the persistence of short cadence outputs.
     */
    @Test
    public void storeShortCadenceOutputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setValidateOutputs(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval long cadence inputs and persistence of long cadence
     * outputs when {@code oapEnabled} is {@code true}. Note that this test will
     * call the {@code storeOutputs} method twice for a single execution of the
     * test ensuring that the first call and last call cases are validated.
     * 
     */
    @Test
    public void longCadenceOapEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setOapEnabled(true);
        unitTestDescriptor.setAttitudeAvailable(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval short cadence inputs and persistence of short cadence
     * outputs when {@code oapEnabled} is {@code true}.
     * 
     */
    @Test
    public void shortCadenceOapEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setOapEnabled(true);
        unitTestDescriptor.setAttitudeAvailable(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval long cadence inputs and persistence of long cadence
     * outputs when {code cleanCosmicRays} is {@code false}. Note that this test
     * will call the {@code storeOutputs} method twice for a single execution of
     * the test ensuring that the first call and last call cases are validated.
     * 
     */
    @Test
    public void longCadenceCleanCosmicRaysDisabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setCleanCosmicRays(false);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval short cadence inputs and persistence of short cadence
     * outputs when {@code cleanCosmicRays} is {@code false}.
     * 
     */
    @Test
    public void shortCadenceCleanCosmicRaysDisabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setCleanCosmicRays(false);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval of long cadence inputs and persistence of long cadence
     * outputs when {@code pouEnabled} is {@code true}.
     * 
     */
    @Test
    public void longCadencePouEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setPouEnabled(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval of short cadence inputs and persistence of short
     * cadence outputs when {@code pouEnabled} is {@code true}.
     * 
     */
    @Test
    public void shortCadencePouEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setPouEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void longCadencePseudoTargetListEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setPseudoTargetListEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void longCadenceSimulatedTransitsEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setSimulatedTransitsEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void shortCadenceSimulatedTransitsEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.SHORT);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setSimulatedTransitsEnabled(true);
        unitTestDescriptor.setError(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void onlyProcessPpaTargetsEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setOnlyProcessPpaTargetsEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void motionBlobsInputEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setMotionBlobsInputEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void paCoaEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setValidateOutputs(true);
        unitTestDescriptor.setPaCoaEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void motionBlobsInputEnabledError() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setError(true);
        unitTestDescriptor.setMotionBlobsInputEnabled(true);
        unitTestDescriptor.setOnlyProcessPpaTargetsEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void simulatedTransitsEnabledError() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setCadenceType(CadenceType.LONG);
        unitTestDescriptor.setError(true);
        unitTestDescriptor.setSimulatedTransitsEnabled(true);
        unitTestDescriptor.setOnlyProcessPpaTargetsEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void generateAlert() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setGenerateAlerts(true);
        unitTestDescriptor.setValidateOutputs(true);
        processTask(unitTestDescriptor);
    }

    public void processTask(final UnitTestDescriptor unitTestDescriptor) {
        setUnitTestDescriptor(unitTestDescriptor);
        populateObjects();
        createInputs();

        PaInputs paInputs = paInputsRetriever.retrieveInputs(MATLAB_WORKING_DIR);

        while (paInputs != null) {
            PaOutputs paOutputs = new PaOutputs();
            executeAlgorithm(pipelineTask, paInputs, paOutputs);
            storeOutputs(paOutputs);

            paInputs = paInputsRetriever.retrieveInputs(MATLAB_WORKING_DIR);
        }
    }

    private void executeAlgorithm(final PipelineTask pipelineTask,
        final Persistable inputs, final Persistable outputs) {
        PaInputs paInputs = (PaInputs) inputs;
        PaOutputs paOutputs = (PaOutputs) outputs;
        try {
            if (isValidateInputs()) {
                validate(paInputs);
            }
            if (isSerializeInputs()) {
                serializeInputs(paInputs);
            }
            if (isValidateOutputs()) {
                createOutputs(paInputs, paOutputs);
            }
        } catch (Exception e) {
            throw new PipelineException(e);
        }
    }

    private void storeOutputs(final PaOutputs paOutputs) {
        if (isValidateOutputs()) {
            paOutputsStorer.storeOutputs(MATLAB_WORKING_DIR, paOutputs);
        }
        if (isSerializeOutputs()) {
            try {
                serializeOutputs(paOutputs);
            } catch (Exception e) {
                throw new PipelineException(e);
            }
        }
    }

}
