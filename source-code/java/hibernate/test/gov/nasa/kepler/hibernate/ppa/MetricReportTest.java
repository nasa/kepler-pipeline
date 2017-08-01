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

package gov.nasa.kepler.hibernate.ppa;

import static gov.nasa.kepler.hibernate.ppa.PadMetricReport.ReportType.DELTA_DEC;
import static gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType.ACHIEVED_COMPRESSION_EFFICIENCY;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.mc.BoundsReport;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.EnergyDistribution;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.LinkedHashSet;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the MetricReport class.
 * 
 * @author Forrest Girouard
 */
public class MetricReportTest {

    private static final TargetTable TARGET_TABLE = new TargetTable(
        TargetTable.TargetType.LONG_CADENCE);
    private static final int EXTERNAL_TABLE_ID = 3;
    private static final long TASK_ID = 124356;
    private static final PipelineInstance PIPELINE_INSTANCE = new PipelineInstance();
    private static final PipelineTask PIPELINE_TASK = createPipelineTask(PIPELINE_INSTANCE);
    private static final int START_CADENCE = 1234;
    private static final int END_CADENCE = START_CADENCE + 1439;
    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;

    private static final float ADAPTIVE_BOUNDS_X_FACTOR = 42.0F;
    private static final BoundsReport BOUNDS_REPORT = new BoundsReport();
    private static final float MEAN_VALUE = 43.0F;
    private static final double TIME = 44.0F;
    private static final int TRACK_ALERT_LEVEL = 45;
    private static final int TREND_ALERT_LEVEL = 46;
    private static final TrendReport TREND_REPORT = new TrendReport();
    private static final float UNCERTAINTY = 47.0F;
    private static final float VALUE = 48.0F;

    private static final gov.nasa.kepler.hibernate.ppa.PmdMetricReport.ReportType PMD_REPORT_TYPE = ACHIEVED_COMPRESSION_EFFICIENCY;
    private static final CdppMagnitude CDPP_MAGNITUDE = CdppMagnitude.MAG10;
    private static final CdppDuration CDPP_DURATION = CdppDuration.SIX_HOUR;
    private static final EnergyDistribution ENERGY_DISTRIBUTION = EnergyDistribution.ENERGY_KURTOSIS;

    private static final gov.nasa.kepler.hibernate.ppa.PadMetricReport.ReportType PAD_REPORT_TYPE = DELTA_DEC;

    private PmdMetricReport pmdMetricReport;
    private PadMetricReport padMetricReport;

    @Before
    public void createMetricReport() {
        PIPELINE_TASK.setId(TASK_ID);
        TARGET_TABLE.setExternalId(EXTERNAL_TABLE_ID);
        pmdMetricReport = createPmdMetricReport(START_CADENCE, END_CADENCE);
        padMetricReport = createPadMetricReport(START_CADENCE, END_CADENCE);
    }

    private static PipelineTask createPipelineTask(
        PipelineInstance pipelineInstance) {

        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setPipelineInstance(pipelineInstance);

        return pipelineTask;
    }

    @SuppressWarnings("serial")
    @Test
    public void testConstructor() {
        assertNotNull("targetTable", pmdMetricReport.getTargetTable());
        assertNotNull("pipelineTask", pmdMetricReport.getPipelineTask());
        assertEquals("pipelineTaskId", TASK_ID,
            pmdMetricReport.getPipelineTask()
                .getId());
        assertEquals("ccdModule", CCD_MODULE, pmdMetricReport.getCcdModule());
        assertEquals("ccdOutput", CCD_OUTPUT, pmdMetricReport.getCcdOutput());
        assertEquals("startCadence", START_CADENCE,
            pmdMetricReport.getStartCadence());
        assertEquals("endCadence", END_CADENCE, pmdMetricReport.getEndCadence());

        assertEquals("adaptiveBoundsReport", BOUNDS_REPORT,
            pmdMetricReport.getAdaptiveBoundsReport());
        assertEquals("adaptiveBoundsXFactor", ADAPTIVE_BOUNDS_X_FACTOR,
            pmdMetricReport.getAdaptiveBoundsXFactor(), 0);
        assertEquals("fixedBoundsReport", BOUNDS_REPORT,
            pmdMetricReport.getFixedBoundsReport());
        assertEquals("meanValue", MEAN_VALUE, pmdMetricReport.getMeanValue(), 0);
        assertEquals("pipelineInstance", PIPELINE_INSTANCE,
            pmdMetricReport.getPipelineInstance());
        assertEquals("subtype", new LinkedHashSet<String>() {
            {
                add(CDPP_MAGNITUDE.toString());
                add(CDPP_DURATION.toString());
                add(ENERGY_DISTRIBUTION.toString());
            }
        }, pmdMetricReport.getSubTypes());
        assertEquals("time", TIME, pmdMetricReport.getTime(), 0);
        assertEquals("trackAlertLevel", TRACK_ALERT_LEVEL,
            pmdMetricReport.getTrackAlertLevel());
        assertEquals("trendAlertLevel", TREND_ALERT_LEVEL,
            pmdMetricReport.getTrendAlertLevel());
        assertEquals("trendReport", TREND_REPORT,
            pmdMetricReport.getTrendReport());
        assertEquals("type", PMD_REPORT_TYPE, pmdMetricReport.getType());
        assertEquals("uncertainty", UNCERTAINTY,
            pmdMetricReport.getUncertainty(), 0);
        assertEquals("value", VALUE, pmdMetricReport.getValue(), 0);

        assertNotNull("targetTable", padMetricReport.getTargetTable());
        assertNotNull("pipelineTask", padMetricReport.getPipelineTask());
        assertEquals("pipelineTaskId", TASK_ID,
            padMetricReport.getPipelineTask()
                .getId());
        assertEquals("startCadence", START_CADENCE,
            padMetricReport.getStartCadence());
        assertEquals("endCadence", END_CADENCE, padMetricReport.getEndCadence());

        assertEquals("adaptiveBoundsReport", BOUNDS_REPORT,
            padMetricReport.getAdaptiveBoundsReport());
        assertEquals("adaptiveBoundsXFactor", ADAPTIVE_BOUNDS_X_FACTOR,
            padMetricReport.getAdaptiveBoundsXFactor(), 0);
        assertEquals("fixedBoundsReport", BOUNDS_REPORT,
            padMetricReport.getFixedBoundsReport());
        assertEquals("meanValue", MEAN_VALUE, padMetricReport.getMeanValue(), 0);
        assertEquals("time", TIME, padMetricReport.getTime(), 0);
        assertEquals("trackAlertLevel", TRACK_ALERT_LEVEL,
            padMetricReport.getTrackAlertLevel());
        assertEquals("trendAlertLevel", TREND_ALERT_LEVEL,
            padMetricReport.getTrendAlertLevel());
        assertEquals("trendReport", TREND_REPORT,
            padMetricReport.getTrendReport());
        assertEquals("type", PAD_REPORT_TYPE, padMetricReport.getType());
        assertEquals("uncertainty", UNCERTAINTY,
            padMetricReport.getUncertainty(), 0);
        assertEquals("value", VALUE, padMetricReport.getValue(), 0);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testBadCadencesConstructor() {
        pmdMetricReport = new PmdMetricReport.Builder(PIPELINE_TASK,
            TARGET_TABLE, CCD_MODULE, CCD_OUTPUT, END_CADENCE, START_CADENCE).build();
        padMetricReport = new PadMetricReport.Builder(PIPELINE_TASK,
            TARGET_TABLE, END_CADENCE, START_CADENCE).build();
    }

    @Test
    public void testEquals() {
        MetricReport ar1 = createPmdMetricReport(START_CADENCE, END_CADENCE);
        assertEquals("equals", pmdMetricReport, ar1);

        MetricReport ar2 = createPmdMetricReport(END_CADENCE + 1, END_CADENCE
            + START_CADENCE);
        assertFalse("equals", pmdMetricReport.equals(ar2));

        ar1 = createPadMetricReport(START_CADENCE, END_CADENCE);
        assertEquals("equals", padMetricReport, ar1);

        ar2 = createPadMetricReport(END_CADENCE + 1, END_CADENCE
            + START_CADENCE);
        assertFalse("equals", padMetricReport.equals(ar2));
    }

    @Test
    public void testHashCode() {
        MetricReport ar1 = createPmdMetricReport(START_CADENCE, END_CADENCE);
        assertEquals("hashCode", pmdMetricReport.hashCode(), ar1.hashCode());

        MetricReport ar2 = createPmdMetricReport(END_CADENCE + 1, END_CADENCE
            + START_CADENCE);
        assertTrue("hashCode", pmdMetricReport.hashCode() != ar2.hashCode());

        ar1 = createPadMetricReport(START_CADENCE, END_CADENCE);
        assertEquals("hashCode", padMetricReport.hashCode(), ar1.hashCode());

        ar2 = createPadMetricReport(END_CADENCE + 1, END_CADENCE
            + START_CADENCE);
        assertTrue("hashCode", padMetricReport.hashCode() != ar2.hashCode());
    }

    private PmdMetricReport createPmdMetricReport(int startCadence,
        int endCadence) {
        return new PmdMetricReport.Builder(PIPELINE_TASK, TARGET_TABLE,
            CCD_MODULE, CCD_OUTPUT, startCadence, endCadence).adaptiveBoundsReport(
            BOUNDS_REPORT)
            .adaptiveBoundsXFactor(ADAPTIVE_BOUNDS_X_FACTOR)
            .fixedBoundsReport(BOUNDS_REPORT)
            .meanValue(MEAN_VALUE)
            .subtype(CDPP_MAGNITUDE)
            .subtype(CDPP_DURATION)
            .subtype(ENERGY_DISTRIBUTION)
            .time(TIME)
            .trackAlertLevel(TRACK_ALERT_LEVEL)
            .trendAlertLevel(TREND_ALERT_LEVEL)
            .trendReport(TREND_REPORT)
            .type(PMD_REPORT_TYPE)
            .uncertainty(UNCERTAINTY)
            .value(VALUE)
            .build();
    }

    private PadMetricReport createPadMetricReport(int startCadence,
        int endCadence) {
        return new PadMetricReport.Builder(PIPELINE_TASK, TARGET_TABLE,
            startCadence, endCadence).adaptiveBoundsReport(BOUNDS_REPORT)
            .adaptiveBoundsXFactor(ADAPTIVE_BOUNDS_X_FACTOR)
            .fixedBoundsReport(BOUNDS_REPORT)
            .meanValue(MEAN_VALUE)
            .time(TIME)
            .trackAlertLevel(TRACK_ALERT_LEVEL)
            .trendAlertLevel(TREND_ALERT_LEVEL)
            .trendReport(TREND_REPORT)
            .type(PAD_REPORT_TYPE)
            .uncertainty(UNCERTAINTY)
            .value(VALUE)
            .build();
    }
}
