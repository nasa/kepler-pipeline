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

package gov.nasa.kepler.pdq;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.utils.SerializationTest;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import junit.framework.Assert;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for the PDQ wrapper classes. This class directly tests
 * {@link #PdqPipelineModule.createAndPopulateInputs()}, and
 * {@link #PdqPipelineModule.storeOutputs()}.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PdqPipelineModuleTest extends AbstractPdqPipelineModuleTest {

    private static final Log log = LogFactory.getLog(PdqPipelineModuleTest.class);

    public PdqPipelineModuleTest() {
    }

    @Before
    public void setUp() throws Exception {
        FileUtils.forceMkdir(MATLAB_WORKING_DIR);
    }

    @After
    public void tearDown() throws Exception {
        FileUtils.cleanDirectory(MATLAB_WORKING_DIR);
    }

    @Test
    public void pdqTarget() {
        PdqTarget target = new PdqTarget();
        target.setCcdModule(12);
        assertEquals(12, target.getCcdModule());
        target.setCcdOutput(3);
        assertEquals(3, target.getCcdOutput());
        List<PdqPixelTimeSeries> referencePixels = new ArrayList<PdqPixelTimeSeries>();
        PdqPixelTimeSeries referencePixel = new PdqPixelTimeSeries(234, 567,
            true);
        assertEquals(234, referencePixel.getRow());
        assertEquals(567, referencePixel.getColumn());
        assertTrue(referencePixel.isInOptimalAperture());
        referencePixels.add(referencePixel);
        target.setReferencePixels(referencePixels);
        assertEquals(referencePixels, target.getReferencePixels());

        assertNotNull(target.toString());

        assertTrue(target.equals(target));
        assertFalse(target.equals(null));
        assertFalse(target.equals(referencePixels));
        PdqTarget otherTarget = new PdqTarget();
        otherTarget.setCcdModule(12);
        otherTarget.setCcdOutput(3);
        otherTarget.setReferencePixels(referencePixels);
        assertTrue(target.equals(otherTarget));
        assertEquals(target.hashCode(), otherTarget.hashCode());
        otherTarget.setCcdOutput(4);
        assertFalse(target.equals(otherTarget));
        assertTrue(target.hashCode() != otherTarget.hashCode());
    }

    @Test
    public void pdqStellarTarget() {
        PdqStellarTarget stellarTarget = new PdqStellarTarget();
        stellarTarget.setCcdModule(12);
        assertEquals(12, stellarTarget.getCcdModule());
        stellarTarget.setCcdOutput(3);
        assertEquals(3, stellarTarget.getCcdOutput());
        stellarTarget.setDecDegrees(75.0);
        assertEquals(75.0, stellarTarget.getDecDegrees(), 1e-10);
        stellarTarget.setRaHours(12.0);
        assertEquals(12.0, stellarTarget.getRaHours(), 1e-10);
        stellarTarget.setFluxFractionInAperture(0.9);
        assertEquals(0.9, stellarTarget.getFluxFractionInAperture(), 1e-10);
        stellarTarget.setKeplerId(4200);
        assertEquals(4200, stellarTarget.getKeplerId());
        stellarTarget.setKeplerMag(10.5F);
        assertEquals(10.5F, stellarTarget.getKeplerMag(), 1e-10);

        assertNotNull(stellarTarget.toString());

        assertTrue(stellarTarget.equals(stellarTarget));
        assertFalse(stellarTarget.equals(null));
        assertFalse(stellarTarget.equals(new Object()));

        PdqStellarTarget otherStellarTarget = createPdqStellarTarget();
        assertTrue(stellarTarget.equals(otherStellarTarget));

        assertEquals(stellarTarget.hashCode(), otherStellarTarget.hashCode());
    }

    private PdqStellarTarget createPdqStellarTarget() {

        PdqStellarTarget stellarTarget = new PdqStellarTarget();
        stellarTarget.setCcdModule(12);
        stellarTarget.setCcdOutput(3);
        stellarTarget.setDecDegrees(75.0);
        stellarTarget.setRaHours(12.0);
        stellarTarget.setFluxFractionInAperture(0.9);
        stellarTarget.setKeplerId(4200);
        stellarTarget.setKeplerMag(10.5F);

        return stellarTarget;
    }

    @Test
    public void pdqMetricReport() {
        PdqMetricReport report = new PdqMetricReport();
        report.setValue(1.0F);
        assertEquals(1.0F, report.getValue(), 1e-10);
        report.setUncertainty(0.0001F);
        assertEquals(0.0001F, report.getUncertainty(), 1e-10);
        report.setTime(55000.5);
        assertEquals(55000.5, report.getTime(), 1e-10);

        assertNotNull(report.toString());

        assertFalse(report.hasAlerts());
        assertTrue(report.equals(report));
        assertFalse(report.equals(null));
        assertFalse(report.equals(new Object()));

        PdqMetricReport otherMetricReport = new PdqMetricReport(1.0F, 0.0001F,
            55000.5);
        assertTrue(report.equals(otherMetricReport));
        assertEquals(report.hashCode(), otherMetricReport.hashCode());
    }

    @Test
    public void pdqFocalPlaneReport() {
        PdqFocalPlaneReport report = new PdqFocalPlaneReport();
        report.setDeltaAttitudeDec(new PdqMetricReport(1.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(1.0F, 0.01F, 55000.5),
            report.getDeltaAttitudeDec());
        report.setDeltaAttitudeRa(new PdqMetricReport(2.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(2.0F, 0.01F, 55000.5),
            report.getDeltaAttitudeRa());
        report.setDeltaAttitudeRoll(new PdqMetricReport(3.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(3.0F, 0.01F, 55000.5),
            report.getDeltaAttitudeRoll());
        report.setMaxAttitudeResidualInPixels(new PdqMetricReport(4.0F, 0.01F,
            55000.5));
        assertEquals(new PdqMetricReport(4.0F, 0.01F, 55000.5),
            report.getMaxAttitudeResidualInPixels());

        assertNotNull(report.toString());

        assertTrue(report.equals(report));
        assertFalse(report.equals(null));
        assertFalse(report.equals(new PdqMetricReport()));

        PdqFocalPlaneReport otherReport = new PdqFocalPlaneReport(
            new PdqMetricReport(4.0F, 0.01F, 55000.5), new PdqMetricReport(
                1.0F, 0.01F, 55000.5),
            new PdqMetricReport(2.0F, 0.01F, 55000.5), new PdqMetricReport(
                3.0F, 0.01F, 55000.5));
        assertTrue(report.equals(otherReport));
        assertEquals(report.hashCode(), otherReport.hashCode());
    }

    @Test
    public void pdqModuleOutputReport() {
        PdqModuleOutputReport report = new PdqModuleOutputReport();
        report.setCcdModule(12);
        assertEquals(12, report.getCcdModule());
        report.setCcdOutput(3);
        assertEquals(3, report.getCcdOutput());
        report.setBackgroundLevel(new PdqMetricReport(1.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(1.0F, 0.01F, 55000.5),
            report.getBackgroundLevel());
        report.setBlackLevel(new PdqMetricReport(2.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(2.0F, 0.01F, 55000.5),
            report.getBlackLevel());
        report.setCentroidsMeanCol(new PdqMetricReport(3.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(3.0F, 0.01F, 55000.5),
            report.getCentroidsMeanCol());
        report.setCentroidsMeanRow(new PdqMetricReport(4.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(4.0F, 0.01F, 55000.5),
            report.getCentroidsMeanRow());
        report.setDarkCurrent(new PdqMetricReport(5.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(5.0F, 0.01F, 55000.5),
            report.getDarkCurrent());
        report.setDynamicRange(new PdqMetricReport(6.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(6.0F, 0.01F, 55000.5),
            report.getDynamicRange());
        report.setEncircledEnergy(new PdqMetricReport(7.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(7.0F, 0.01F, 55000.5),
            report.getEncircledEnergy());
        report.setMeanFlux(new PdqMetricReport(8.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(8.0F, 0.01F, 55000.5),
            report.getMeanFlux());
        report.setPlateScale(new PdqMetricReport(9.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(9.0F, 0.01F, 55000.5),
            report.getPlateScale());
        report.setSmearLevel(new PdqMetricReport(10.0F, 0.01F, 55000.5));
        assertEquals(new PdqMetricReport(10.0F, 0.01F, 55000.5),
            report.getSmearLevel());

        assertNotNull(report.toString());

        assertTrue(report.equals(report));
        assertFalse(report.equals(null));
        assertFalse(report.equals(new PdqMetricReport()));

        PdqModuleOutputReport otherReport = new PdqModuleOutputReport(12, 3,
            new PdqMetricReport(1.0F, 0.01F, 55000.5), new PdqMetricReport(
                2.0F, 0.01F, 55000.5),
            new PdqMetricReport(3.0F, 0.01F, 55000.5), new PdqMetricReport(
                4.0F, 0.01F, 55000.5),
            new PdqMetricReport(5.0F, 0.01F, 55000.5), new PdqMetricReport(
                6.0F, 0.01F, 55000.5),
            new PdqMetricReport(7.0F, 0.01F, 55000.5), new PdqMetricReport(
                8.0F, 0.01F, 55000.5),
            new PdqMetricReport(9.0F, 0.01F, 55000.5), new PdqMetricReport(
                10.0F, 0.01F, 55000.5));
        assertTrue(report.equals(otherReport));
        assertEquals(report.hashCode(), otherReport.hashCode());
    }

    @Test
    public void pdqAttitudeAdjustment() {
        PdqAttitudeAdjustment adjustment = new PdqAttitudeAdjustment();
        adjustment.setW(1.0);
        assertEquals(1.0, adjustment.getW(), 1e-10);
        adjustment.setX(2.0);
        assertEquals(2.0F, adjustment.getX(), 1e-10);
        adjustment.setY(3.0);
        assertEquals(3.0, adjustment.getY(), 1e-10);
        adjustment.setZ(4.0);
        assertEquals(4.0, adjustment.getZ(), 1e-10);

        assertNotNull(adjustment.toString());

        assertTrue(adjustment.equals(adjustment));
        assertFalse(adjustment.equals(null));
        assertFalse(adjustment.equals(new PdqMetricReport()));

        double[] quaternion = new double[] { 2.0, 3.0, 4.0, 1.0 };
        PdqAttitudeAdjustment otherAdjustment = new PdqAttitudeAdjustment();
        otherAdjustment.setQuaternion(quaternion);

        assertTrue(adjustment.equals(otherAdjustment));
        assertEquals(adjustment.hashCode(), otherAdjustment.hashCode());
    }

    @Test
    public void pdqPixelTimeSeries() {
        PdqPixelTimeSeries timeSeries = new PdqPixelTimeSeries();
        timeSeries.setColumn(234);
        assertEquals(234, timeSeries.getColumn());
        timeSeries.setRow(567);
        assertEquals(567, timeSeries.getRow());
        timeSeries.setInOptimalAperture(true);
        assertTrue(timeSeries.isInOptimalAperture());
        timeSeries.setGapIndicators(new boolean[] { false, false, true, false,
            false });
        assertTrue(Arrays.equals(new boolean[] { false, false, true, false,
            false }, timeSeries.getGapIndicators()));

        assertNotNull(timeSeries.toString());

        PdqPixelTimeSeries otherTimeSeries = new PdqPixelTimeSeries(567, 234,
            true);
        otherTimeSeries.setGapIndicators(new boolean[] { false, false, true,
            false, false });
        assertTrue(timeSeries.equals(otherTimeSeries));
        assertEquals(timeSeries.hashCode(), otherTimeSeries.hashCode());
    }

    @Test
    public void pdqTsData() {
        PdqTsData tsData = new PdqTsData();
        double[] values = new double[] { 1.0 };
        tsData.setAttitudeSolutionDec(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getAttitudeSolutionDec());
        values = new double[] { 2.0 };
        tsData.setAttitudeSolutionRa(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getAttitudeSolutionRa());
        values = new double[] { 3.0 };
        tsData.setAttitudeSolutionRoll(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getAttitudeSolutionRoll());
        values = new double[] { 4.0 };
        tsData.setDeltaAttitudeDec(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getDeltaAttitudeDec());
        values = new double[] { 5.0 };
        tsData.setDeltaAttitudeRa(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getDeltaAttitudeRa());
        values = new double[] { 6.0 };
        tsData.setDeltaAttitudeRoll(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getDeltaAttitudeRoll());
        values = new double[] { 7.0 };
        tsData.setDesiredAttitudeDec(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getDesiredAttitudeDec());
        values = new double[] { 8.0 };
        tsData.setDesiredAttitudeRa(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getDesiredAttitudeRa());
        values = new double[] { 9.0 };
        tsData.setDesiredAttitudeRoll(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        assertEquals(new PdqDoubleTimeSeries(values, new double[1],
            new boolean[1]), tsData.getDesiredAttitudeRoll());
        float[] residual = new float[] { 10.0F };
        tsData.setMaxAttitudeResidualInPixels(new CompoundFloatTimeSeries(
            residual, new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(residual, new float[1],
            new boolean[1]), tsData.getMaxAttitudeResidualInPixels());

        assertNotNull(tsData.toString());

        assertTrue(tsData.equals(tsData));
        assertFalse(tsData.equals(null));
        assertFalse(tsData.equals(new Object()));

        PdqTsData otherTsData = createPdqTsData();
        assertTrue(tsData.equals(otherTsData));
        assertEquals(tsData.hashCode(), otherTsData.hashCode());
    }

    private PdqTsData createPdqTsData() {

        PdqTsData tsData = new PdqTsData();
        double[] values = new double[] { 1.0 };
        tsData.setAttitudeSolutionDec(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 2.0 };
        tsData.setAttitudeSolutionRa(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 3.0 };
        tsData.setAttitudeSolutionRoll(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 4.0 };
        tsData.setDeltaAttitudeDec(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 5.0 };
        tsData.setDeltaAttitudeRa(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 6.0 };
        tsData.setDeltaAttitudeRoll(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 7.0 };
        tsData.setDesiredAttitudeDec(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 8.0 };
        tsData.setDesiredAttitudeRa(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        values = new double[] { 9.0 };
        tsData.setDesiredAttitudeRoll(new PdqDoubleTimeSeries(values,
            new double[1], new boolean[1]));
        float[] residual = new float[] { 10.0F };
        tsData.setMaxAttitudeResidualInPixels(new CompoundFloatTimeSeries(
            residual, new float[1], new boolean[1]));

        return tsData;
    }

    @Test
    public void pdqModuleOutputTsData() {
        PdqModuleOutputTsData tsData = new PdqModuleOutputTsData();
        tsData.setCcdModule(12);
        assertEquals(12, tsData.getCcdModule());
        tsData.setCcdOutput(3);
        assertEquals(3, tsData.getCcdOutput());
        float[] values = new float[] { 1.0F };
        tsData.setBackgroundLevels(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getBackgroundLevels());
        values = new float[] { 2.0F };
        tsData.setBlackLevels(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getBlackLevels());
        values = new float[] { 3.0F };
        tsData.setCentroidsMeanCols(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getCentroidsMeanCols());
        values = new float[] { 4.0F };
        tsData.setCentroidsMeanRows(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getCentroidsMeanRows());
        values = new float[] { 5.0F };
        tsData.setDarkCurrents(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getDarkCurrents());
        values = new float[] { 6.0F };
        tsData.setDynamicRanges(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getDynamicRanges());
        values = new float[] { 7.0F };
        tsData.setEncircledEnergies(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getEncircledEnergies());
        values = new float[] { 8.0F };
        tsData.setMeanFluxes(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getMeanFluxes());
        values = new float[] { 9.0F };
        tsData.setPlateScales(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getPlateScales());
        values = new float[] { 10.0F };
        tsData.setSmearLevels(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        assertEquals(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]), tsData.getSmearLevels());

        assertNotNull(tsData.toString());

        assertTrue(tsData.equals(tsData));
        assertFalse(tsData.equals(null));
        assertFalse(tsData.equals(new Object()));

        PdqModuleOutputTsData otherTsData = createPdqModuleOutputTsData();

        assertTrue(tsData.equals(otherTsData));
        assertEquals(tsData.hashCode(), otherTsData.hashCode());
    }

    private PdqModuleOutputTsData createPdqModuleOutputTsData() {

        PdqModuleOutputTsData tsData = new PdqModuleOutputTsData();
        tsData.setCcdModule(12);
        tsData.setCcdOutput(3);
        float[] values = new float[] { 1.0F };
        tsData.setBackgroundLevels(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        values = new float[] { 2.0F };
        tsData.setBlackLevels(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        values = new float[] { 3.0F };
        tsData.setCentroidsMeanCols(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        values = new float[] { 4.0F };
        tsData.setCentroidsMeanRows(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        values = new float[] { 5.0F };
        tsData.setDarkCurrents(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        values = new float[] { 6.0F };
        tsData.setDynamicRanges(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        values = new float[] { 7.0F };
        tsData.setEncircledEnergies(new CompoundFloatTimeSeries(values,
            new float[1], new boolean[1]));
        values = new float[] { 8.0F };
        tsData.setMeanFluxes(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        values = new float[] { 9.0F };
        tsData.setPlateScales(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));
        values = new float[] { 10.0F };
        tsData.setSmearLevels(new CompoundFloatTimeSeries(values, new float[1],
            new boolean[1]));

        return tsData;
    }

    @Test
    public void pdqDoubleTimeSeries() {
        double[] values = new double[] { 1.0 };
        double[] uncertainties = new double[] { 0.01 };
        PdqDoubleTimeSeries timeSeries = new PdqDoubleTimeSeries(values,
            uncertainties, new boolean[1]);
        assertTrue(Arrays.equals(values, timeSeries.getValues()));
        assertTrue(Arrays.equals(uncertainties, timeSeries.getUncertainties()));
        assertTrue(Arrays.equals(new boolean[1], timeSeries.getGapIndicators()));

        assertNotNull(timeSeries.toString());

        assertTrue(timeSeries.equals(timeSeries));
        assertFalse(timeSeries.equals(null));
        assertFalse(timeSeries.equals(new Object()));

        values = new double[] { 1.0 };
        uncertainties = new double[] { 0.01 };
        PdqDoubleTimeSeries otherTimeSeries = new PdqDoubleTimeSeries(values,
            uncertainties, new boolean[1]);
        assertTrue(timeSeries.equals(otherTimeSeries));
        assertEquals(timeSeries.hashCode(), otherTimeSeries.hashCode());
    }

    // SOC_REQ 252.PDQ.2 J.taskType
    @Test
    public void taskType() {
        assertEquals("unit of work", SingleUowTask.class,
            getPipelineModule().unitOfWorkTaskType());
    }

    @Test
    public void retrieveInputs() {

        setUnitTestDescriptor(new UnitTestDescriptor());
        createAndRetrieveInputs();
    }

    @Test
    public void storeOutputs() {

        setUnitTestDescriptor(new UnitTestDescriptor());
        createAndStoreOutputs();
    }

    @Test
    public void initialProcessTask() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        unitTestDescriptor.setNumOldRefLogs(0);
        processTask(unitTestDescriptor);
    }

    @Test
    public void processTask() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void oneModuleOutput() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        List<Integer> moduleOutputs = new ArrayList<Integer>();
        moduleOutputs.add(42);
        unitTestDescriptor.setModuleOutputs(moduleOutputs);
        processTask(unitTestDescriptor);
    }

    @Test
    public void allButOneModuleOutput() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        List<Integer> moduleOutputs = new ArrayList<Integer>();
        for (int i = 1; i <= FcConstants.MODULE_OUTPUTS; i++) {
            if (i != 42) {
                moduleOutputs.add(i);
            }
        }
        unitTestDescriptor.setModuleOutputs(moduleOutputs);
        processTask(unitTestDescriptor);
    }

    @Test
    public void forceUpdates() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        unitTestDescriptor.setForceUpdates(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void forceReprocessing() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        unitTestDescriptor.setForceReprocessing(true);
        processTask(unitTestDescriptor);
    }

    // SOC_REQ PI2: J.forceFatalException
    @Test(expected = ModuleFatalProcessingException.class)
    public void forceFatalException() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(false);
        unitTestDescriptor.setForceFatalException(true);
        try {
            processTask(unitTestDescriptor);
            fail("expected fatal processing exception");
        } catch (ModuleFatalProcessingException mfpe) {
            assertNotNull("exception message null", mfpe.getMessage());
            throw mfpe;
        }
    }

    // SOC_REQ 262.PDQ.2 J.forceAlert
    @Test
    public void forceAlert() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(false);
        unitTestDescriptor.setForceAlert(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void reportDisabled() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setReportEnabled(false);
        processTask(unitTestDescriptor);
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void excludeInvalidCadence() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 10 });
        unitTestDescriptor.setValidate(false);
        unitTestDescriptor.setOutputExpectations(false);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeNewUnprocessedCadence() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 5 });
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeOldProcessedCadence() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 1 });
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeOldUnprocessedCadences() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 1 });
        unitTestDescriptor.setOldExcludedCadencesProcessed(false);
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeNewAndOldUnprocessedCadences() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 1, 5 });
        unitTestDescriptor.setOldExcludedCadencesProcessed(false);
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeAllOldProcessedCadences() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 0, 1, 2, 3 });
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeMostOldProcessedCadences() throws Exception {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExcludeCadences(new int[] { 0, 1, 2 });
        unitTestDescriptor.setValidate(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void excludeAndForceReprocessing() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setValidate(true);
        unitTestDescriptor.setExcludeCadences(new int[] { 5 });
        unitTestDescriptor.setForceReprocessing(true);
        processTask(unitTestDescriptor);
    }

    @Test
    public void executeAlgorithmDisabled() {

        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setExecuteAlgorithmEnabled(false);
        processTask(unitTestDescriptor);
    }

    @Test
    public void serializeEmptyInputs() throws Exception {
        SerializationTest.testSerialization(getPipelineModule().createInputs(),
            getPipelineModule().createInputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-inputs.bin"));
    }

    @Test
    public void serializeEmptyOutputs() throws Exception {
        SerializationTest.testSerialization(
            getPipelineModule().createOutputs(),
            getPipelineModule().createOutputs(), new File(Filenames.BUILD_TMP,
                getClass().getSimpleName() + "-outputs.bin"));
    }

    @Test
    public void serializePopulatedInputs() throws Exception {

        setUnitTestDescriptor(new UnitTestDescriptor());
        createAndSerializeInputs();
    }

    @Test
    public void serializePopulatedOutputs() throws Exception {

        setUnitTestDescriptor(new UnitTestDescriptor());
        createAndSerializeOutputs();
    }

    private void processTask(UnitTestDescriptor unitTestDescriptor) {

        setUnitTestDescriptor(unitTestDescriptor);
        populateObjects();
        createInputs();

        log.info("Running pdq...");
        getPipelineModule().processTask(
            getPipelineModule().getPipelineInstance(),
            getPipelineModule().getPipelineTask());

        if (unitTestDescriptor.isValidate()) {
            log.info("Validating pdq...");
            validate(getPipelineModule().getInputs());
            if (getPipelineModule().getPdqModuleParameters()
                .isExecuteAlgorithmEnabled()) {
                validate(getPipelineModule().getOutputs());
            }
        }

        log.info("Completed pdq test.");
    }

    @Test
    public void testRemoveNonPdqLabels() {
        ObservedTarget observedTarget = new ObservedTarget(0);
        observedTarget.addLabel(TargetLabel.PDQ_STELLAR);
        observedTarget.addLabel(TargetLabel.PLANETARY);

        List<TargetDefinition> targetDefs = new ArrayList<TargetDefinition>();

        PdqTarget pdqTarget = new PdqTarget(0, 0, observedTarget, targetDefs);

        String[] expectedLabels = new String[] { TargetLabel.PDQ_STELLAR.toString() };

        Assert.assertTrue(Arrays.equals(expectedLabels, pdqTarget.getLabels()));
    }

}
