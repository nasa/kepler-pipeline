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

package gov.nasa.kepler.dv;

import static gov.nasa.kepler.dv.DvTestUtils.createCentroidOffsets;
import static gov.nasa.kepler.dv.DvTestUtils.createImageCentroid;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.io.DvBootstrapHistogram;
import gov.nasa.kepler.dv.io.DvCentroidData;
import gov.nasa.kepler.dv.io.DvDifferenceImagePixelData;
import gov.nasa.kepler.dv.io.DvDifferenceImageResults;
import gov.nasa.kepler.dv.io.DvDoubleQuantity;
import gov.nasa.kepler.dv.io.DvInputs;
import gov.nasa.kepler.dv.io.DvPixelCorrelationResults;
import gov.nasa.kepler.dv.io.DvPixelData;
import gov.nasa.kepler.dv.io.DvPixelStatistic;
import gov.nasa.kepler.dv.io.DvPlanetCandidate;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.dv.io.DvThresholdCrossingEvent;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.cm.CelestialObjectParameter;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

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
 * Tests the {@link DvPipelineModule}.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class DvInputsRetrieverTest extends AbstractDvPipelineModuleTest {

    private static final Log log = LogFactory.getLog(DvInputsRetrieverTest.class);

    private static final String PROVENANCE = "TEST";

    @Before
    public void setUp() throws Exception {
        FileUtils.forceMkdir(MATLAB_WORKING_DIR);
    }

    @After
    public void tearDown() throws Exception {
        FileUtils.cleanDirectory(MATLAB_WORKING_DIR);
    }

    @Test
    public void dvPlanetCandidate() {
        DvPlanetCandidate candidate = new DvPlanetCandidate.Builder(123456789).bootstrapHistogram(
            new DvBootstrapHistogram())
            .epochMjd(55500.5)
            .expectedTransitCount(7)
            .initialFluxTimeSeries(new CorrectedFluxTimeSeries())
            .maxMultipleEventSigma(2.0F)
            .maxSingleEventSigma(3.0F)
            .modelChiSquare2(24.1F)
            .modelChiSquareDof2(24)
            .modelChiSquareGof(24.2F)
            .modelChiSquareGofDof(25)
            .observedTransitCount(6)
            .orbitalPeriod(4.0F)
            .planetNumber(1)
            .significance(5.0F)
            .statisticRatioBelowThreshold(true)
            .suspectedEclipsingBinary(true)
            .trialTransitPulseDuration(8.0F)
            .build();
        assertEquals(123456789, candidate.getKeplerId());
        assertEquals(55500.5, candidate.getEpochMjd(), 1e-10);
        assertEquals(7, candidate.getExpectedTransitCount());
        assertEquals(new CorrectedFluxTimeSeries(),
            candidate.getInitialFluxTimeSeries());
        assertEquals(2.0F, candidate.getMaxMultipleEventSigma(), 1e-10);
        assertEquals(3.0F, candidate.getMaxSingleEventSigma(), 1e-10);
        assertEquals(24.1F, candidate.getModelChiSquare2(), 1e-10);
        assertEquals(24, candidate.getModelChiSquareDof2());
        assertEquals(24.2F, candidate.getModelChiSquareGof(), 1e-10);
        assertEquals(25, candidate.getModelChiSquareGofDof());
        assertEquals(6, candidate.getObservedTransitCount());
        assertEquals(4.0F, candidate.getOrbitalPeriod(), 1e-10);
        assertEquals(1, candidate.getPlanetNumber());
        assertEquals(5.0F, candidate.getSignificance(), 1e-10);
        assertEquals(true, candidate.isStatisticRatioBelowThreshold());
        assertEquals(true, candidate.isSuspectedEclipsingBinary());
        assertEquals(8.0F, candidate.getTrialTransitPulseDuration(), 1e-10);
    }

    @Test
    public void dvDifferenceImageResults() {
        DvDifferenceImageResults results = new DvDifferenceImageResults.Builder(
            1).ccdModule(2)
            .ccdOutput(3)
            .startCadence(4)
            .endCadence(5)
            .quarter(6)
            .controlCentroidOffsets(createCentroidOffsets(0))
            .controlImageCentroid(createImageCentroid(6))
            .differenceImageCentroid(createImageCentroid(10))
            .kicCentroidOffsets(createCentroidOffsets(14))
            .kicReferenceCentroid(createImageCentroid(20))
            .overlappedTransits(true)
            .differenceImagePixels(new ArrayList<DvDifferenceImagePixelData>())
            .build();
        assertEquals(1, results.getTargetTableId());
        assertEquals(2, results.getCcdModule());
        assertEquals(3, results.getCcdOutput());
        assertEquals(4, results.getStartCadence());
        assertEquals(5, results.getEndCadence());
        assertEquals(6, results.getQuarter());
        assertEquals(3.0F, results.getControlCentroidOffsets()
            .getFocalPlaneOffset()
            .getValue(), 1e-10);
        assertEquals(7.0F, results.getControlImageCentroid()
            .getColumn()
            .getValue(), 1e-10);
        assertEquals(12.0, results.getDifferenceImageCentroid()
            .getDecDegrees()
            .getValue(), 1e-10);
        assertEquals(19.0F, results.getKicCentroidOffsets()
            .getRowOffset()
            .getValue(), 1e-10);
        assertEquals(24.0F, results.getKicReferenceCentroid()
            .getRow()
            .getValue(), 1e-10);
        assertEquals(new ArrayList<DvDifferenceImagePixelData>(),
            results.getDifferenceImagePixelData());
        assertEquals(true, results.isOverlappedTransits());

        DvPixelCorrelationResults otherResults = new DvPixelCorrelationResults();
        assertFalse(results.equals(otherResults));
    }

    @Test
    public void dvPixelCorrelationResults() {
        DvPixelCorrelationResults results = new DvPixelCorrelationResults.Builder(
            1).ccdModule(2)
            .ccdOutput(3)
            .startCadence(4)
            .endCadence(5)
            .quarter(6)
            .controlCentroidOffsets(createCentroidOffsets(0))
            .controlImageCentroid(createImageCentroid(6))
            .correlationImageCentroid(createImageCentroid(10))
            .kicCentroidOffsets(createCentroidOffsets(14))
            .kicReferenceCentroid(createImageCentroid(20))
            .pixelCorrelationStatistics(new ArrayList<DvPixelStatistic>())
            .build();
        assertEquals(1, results.getTargetTableId());
        assertEquals(2, results.getCcdModule());
        assertEquals(3, results.getCcdOutput());
        assertEquals(4, results.getStartCadence());
        assertEquals(5, results.getEndCadence());
        assertEquals(6, results.getQuarter());
        assertEquals(3.0F, results.getControlCentroidOffsets()
            .getFocalPlaneOffset()
            .getValue(), 1e-10);
        assertEquals(7.0F, results.getControlImageCentroid()
            .getColumn()
            .getValue(), 1e-10);
        assertEquals(12.0, results.getCorrelationImageCentroid()
            .getDecDegrees()
            .getValue(), 1e-10);
        assertEquals(19.0F, results.getKicCentroidOffsets()
            .getRowOffset()
            .getValue(), 1e-10);
        assertEquals(24.0F, results.getKicReferenceCentroid()
            .getRow()
            .getValue(), 1e-10);
        assertEquals(new ArrayList<DvPixelStatistic>(),
            results.getPixelCorrelationStatistics());

        DvPixelCorrelationResults otherResults = new DvPixelCorrelationResults();
        assertFalse(results.equals(otherResults));
    }

    @Test
    public void dvPixelStatistic() {
        DvPixelStatistic statistic = new DvPixelStatistic(1.0F, 2.0F, 3, 4);
        assertEquals(1.0F, statistic.getValue(), 1e-10);
        assertEquals(2.0F, statistic.getSignificance(), 1e-10);
        assertEquals(3, statistic.getCcdRow());
        assertEquals(4, statistic.getCcdColumn());
    }

    @Test
    public void dvPixelData() {
        DvPixelData data = new DvPixelData(1, 2, true, null, null);
        assertEquals(1, data.getCcdRow());
        assertEquals(2, data.getCcdColumn());
        assertEquals(true, data.isInOptimalAperture());

        assertNotNull(data.toString());

        assertTrue(data.equals(data));
        assertFalse(data.equals(null));
        assertFalse(data.equals(new Object()));

        DvPixelData otherData = new DvPixelData(1, 2, false, null, null);
        assertTrue(data.equals(otherData));
        assertEquals(data.hashCode(), otherData.hashCode());
    }

    @Test
    public void dvDoubleQuantity() {
        DvDoubleQuantity quantity = new DvDoubleQuantity(1.0, 2.0F);
        assertEquals(1.0, quantity.getValue(), 1e-10);
        assertEquals(2.0F, quantity.getUncertainty(), 1e-10);
    }

    @Test
    public void dvCentroidData() {
        CompoundDoubleTimeSeries fwRowTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 1.0 }, new float[] { 0.01F }, new boolean[1]);
        CompoundDoubleTimeSeries fwColumnTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 2.0 }, new float[] { 0.01F }, new boolean[1]);
        CentroidTimeSeries fluxWeightedCentroids = new CentroidTimeSeries(
            fwRowTimeSeries, fwColumnTimeSeries);
        CompoundDoubleTimeSeries pRowTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 3.0 }, new float[] { 0.01F }, new boolean[1]);
        CompoundDoubleTimeSeries pColumnTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 4.0 }, new float[] { 0.01F }, new boolean[1]);
        CentroidTimeSeries prfCentroids = new CentroidTimeSeries(
            pRowTimeSeries, pColumnTimeSeries);
        DvCentroidData data = new DvCentroidData(fluxWeightedCentroids,
            prfCentroids);
        assertEquals(fluxWeightedCentroids, data.getFluxWeightedCentroids());
        assertEquals(prfCentroids, data.getPrfCentroids());

        assertTrue(data.equals(data));
        assertFalse(data.equals(null));
        assertFalse(data.equals(new Object()));

        CompoundDoubleTimeSeries ptherFwRowTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 1.0 }, new float[] { 0.01F }, new boolean[1]);
        CompoundDoubleTimeSeries otherFwColumnTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 2.0 }, new float[] { 0.01F }, new boolean[1]);
        CentroidTimeSeries otherFluxWeightedCentroids = new CentroidTimeSeries(
            ptherFwRowTimeSeries, otherFwColumnTimeSeries);
        CompoundDoubleTimeSeries otherPRowTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 3.0 }, new float[] { 0.01F }, new boolean[1]);
        CompoundDoubleTimeSeries otherPColumnTimeSeries = new CompoundDoubleTimeSeries(
            new double[] { 4.0 }, new float[] { 0.01F }, new boolean[1]);
        CentroidTimeSeries otherPrfCentroids = new CentroidTimeSeries(
            otherPRowTimeSeries, otherPColumnTimeSeries);
        DvCentroidData otherData = new DvCentroidData(
            otherFluxWeightedCentroids, otherPrfCentroids);
        assertTrue(data.equals(otherData));
        assertEquals(data.hashCode(), otherData.hashCode());
    }

    @Test
    public void dvTarget() {
        DvCentroidData centroids = new DvCentroidData();
        CorrectedFluxTimeSeries correctedFluxTimeSeries = new CorrectedFluxTimeSeries();
        DvTarget target = new DvTarget.Builder(123456789, FluxType.SAP).centroids(
            centroids)
            .correctedFluxTimeSeries(correctedFluxTimeSeries)
            .decDegrees(new CelestialObjectParameter(PROVENANCE, 42.0, 0.01F))
            .discontinuityIndices(new int[] { 1 })
            .effectiveTemp(new CelestialObjectParameter(PROVENANCE, 1.0, 0.01F))
            .keplerMag(new CelestialObjectParameter(PROVENANCE, 10.0, 0.01F))
            .log10Metallicity(
                new CelestialObjectParameter(PROVENANCE, 2.0, 0.02F))
            .log10SurfaceGravity(
                new CelestialObjectParameter(PROVENANCE, 2.0, 0.01F))
            .outliers(new OutliersTimeSeries())
            .radius(new CelestialObjectParameter(PROVENANCE, 3.0, 0.01F))
            .raHours(new CelestialObjectParameter(PROVENANCE, 32.0, 0.01F))
            .rawFluxTimeSeries(correctedFluxTimeSeries)
            .thresholdCrossingEvent(
                Arrays.asList(new DvThresholdCrossingEvent.Builder(123456789).weakSecondary(
                    new WeakSecondary())
                    .build()))
            .ukirtImageFileName("ukirt-image.png")
            .build();
        assertEquals(new CelestialObjectParameter(PROVENANCE, 42.0, 0.01F),
            target.getDecDegrees());
        assertTrue(Arrays.equals(new int[] { 1 },
            target.getDiscontinuityIndices()));
        assertEquals(123456789, target.getKeplerId());
        assertEquals(new CelestialObjectParameter(PROVENANCE, 1.0, 0.01F),
            target.getEffectiveTemp());
        assertEquals(new CelestialObjectParameter(PROVENANCE, 10.0, 0.01F),
            target.getKeplerMag());
        assertEquals(new CelestialObjectParameter(PROVENANCE, 2.0, 0.02F),
            target.getLog10Metallicity());
        assertEquals(new CelestialObjectParameter(PROVENANCE, 2.0, 0.01F),
            target.getLog10SurfaceGravity());
        assertEquals(new CelestialObjectParameter(PROVENANCE, 3.0, 0.01F),
            target.getRadius());
        assertEquals(new CelestialObjectParameter(PROVENANCE, 32.0, 0.01F),
            target.getRaHours());
        assertEquals("ukirt-image.png", target.getUkirtImageFileName());

        target.clearTimeSeries();
        assertFalse(target.isPopulated());
        assertTrue(target.equals(target));
        assertEquals(1, target.getRequiredFsIdSets(0, 1)
            .size());
    }

    @Test
    public void taskType() {
        assertEquals("unit of work", PlanetaryCandidatesChunkUowTask.class,
            getPipelineModule().unitOfWorkTaskType());
    }

    /**
     * Test the serialization of an empty {@code DvInputs} object.
     * 
     * @throws IllegalAccessException if the comparison fails
     */
    @Test
    public void serializeEmptyInputs() throws IllegalAccessException {
        serializeInputs(new DvInputs());
    }

    /**
     * Test the serialization of a populated {@code DvInputs} object.
     * 
     * @throws IllegalAccessException if the comparison fails
     */
    @Test
    public void serializePopulatedInputs() throws IllegalAccessException {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setSerializeInputs(true);
        processTask(unitTestDescriptor);
    }

    /**
     * Test the retrieval of long cadence inputs. Note that this test will call
     * the {@code validate} method twice for a single execution of the test
     * ensuring that the first call and last call cases are validated.
     */
    @Test
    public void retrieveInputs() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidateInputs(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveInputsMultiTable() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setTargetTableCount(2);
        unitTestDescriptor.setTargetsPerTable(2);
        unitTestDescriptor.setAncillaryPipelineMnemonics(new String[] {
            "SOC_PA_ENCIRCLED_ENERGY", "SOC_PPA_BACKGROUND_LEVEL" });
        unitTestDescriptor.setValidateInputs(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveInputsNoPrfCentroids() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setPrfCentroidsEnabled(false);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveInputsSimulatedTransitsEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setSimulatedTransitsEnabled(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void retrieveInputsExternalTcesEnabled() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidateInputs(true);
        unitTestDescriptor.setExternalTcesEnabled(true);
        processTask(unitTestDescriptor);
    }

    private void processTask(final UnitTestDescriptor unitTestDescriptor) {

        setUnitTestDescriptor(unitTestDescriptor);
        setDvInputsRetriever(new DvInputsRetriever());
        populateObjects();
        createInputs();

        log.info("Running dv...");
        try {
            List<Persistable> dvInputsList = getDvInputsRetriever().retrieveInputs(
                getPipelineTask(), MATLAB_WORKING_DIR, getInputsHandler());
            for (Persistable dvInputs : dvInputsList) {
                if (isValidateInputs()) {
                    validate((DvInputs) dvInputs);
                }
                if (isSerializeInputs()) {
                    serializeInputs((DvInputs) dvInputs);
                }
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to retrieve inputs.", e);
        }

        log.info("Done");
    }
}
