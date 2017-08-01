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

package gov.nasa.kepler.hibernate.pdq;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.mc.BoundsReport;
import gov.nasa.kepler.hibernate.pdq.FocalPlaneMetricReport.MetricType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests for the PDQ focal plane metric report class.
 * 
 * @author Forrest Girouard
 * 
 */
public class FocalPlaneMetricReportTest {

    private static final MetricType METRIC_TYPE = MetricType.DELTA_ATTITUDE_RA;
    private static final TargetTable TARGET_TABLE = new TargetTable(
        TargetType.REFERENCE_PIXEL);
    private static final PipelineTask PIPELINE_TASK = new PipelineTask();
    private static final double TIME = 55473.0;
    private static final float METRIC_VALUE = 43.1F;
    private static final float METRIC_UNCERTAINTY = 44.0F;
    private static final BoundsReport ADAPTIVE_BOUNDS_REPORT = new BoundsReport();
    private static final BoundsReport FIXED_BOUNDS_REPORT = new BoundsReport();

    private FocalPlaneMetricReport mr;

    @Before
    public void createFocalPlaneMetricReport() {
        TARGET_TABLE.setExternalId(1);
        ADAPTIVE_BOUNDS_REPORT.setOutOfLowerBound(true);
        FIXED_BOUNDS_REPORT.setOutOfLowerBound(true);
        mr = new FocalPlaneMetricReport.Builder(PIPELINE_TASK, TARGET_TABLE).type(
            METRIC_TYPE)
            .time(TIME)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .adaptiveBoundsReport(ADAPTIVE_BOUNDS_REPORT)
            .fixedBoundsReport(FIXED_BOUNDS_REPORT)
            .build();
    }

    @Test
    public void testConstructor() {

        assertEquals(METRIC_TYPE, mr.getType());
        assertEquals(TARGET_TABLE, mr.getTargetTable());
        assertEquals(PIPELINE_TASK, mr.getPipelineTask());
        assertEquals(TIME, mr.getTime(), 0);
        assertEquals(METRIC_VALUE, mr.getValue(), 0);
        assertEquals(METRIC_UNCERTAINTY, mr.getUncertainty(), 0);
        assertEquals(ADAPTIVE_BOUNDS_REPORT, mr.getAdaptiveBoundsReport());
        assertEquals(FIXED_BOUNDS_REPORT, mr.getFixedBoundsReport());
    }

    @Test
    public void testEqualsObject() {

        FocalPlaneMetricReport mr1 = new FocalPlaneMetricReport.Builder(
            PIPELINE_TASK, TARGET_TABLE).type(METRIC_TYPE)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .time(TIME)
            .build();
        assertEquals(mr.hashCode(), mr1.hashCode());
        FocalPlaneMetricReport mr2 = new FocalPlaneMetricReport.Builder(
            PIPELINE_TASK, TARGET_TABLE).type(METRIC_TYPE)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .time(TIME)
            .build();
        assertEquals(mr1.hashCode(), mr2.hashCode());

        assertTrue(mr1.equals(mr2));

        FocalPlaneMetricReport mr3 = new FocalPlaneMetricReport.Builder(
            PIPELINE_TASK, TARGET_TABLE).type(MetricType.DELTA_ATTITUDE_DEC)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .time(TIME)
            .build();
        assertFalse(mr1.equals(mr3));
    }

    @Test
    public void testHashCode() {

        FocalPlaneMetricReport mr1 = new FocalPlaneMetricReport.Builder(
            PIPELINE_TASK, TARGET_TABLE).type(METRIC_TYPE)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .time(TIME)
            .build();
        assertEquals(mr.hashCode(), mr1.hashCode());
        FocalPlaneMetricReport mr2 = new FocalPlaneMetricReport.Builder(
            PIPELINE_TASK, TARGET_TABLE).type(METRIC_TYPE)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .time(TIME)
            .build();
        assertEquals(mr1.hashCode(), mr2.hashCode());

        FocalPlaneMetricReport mr3 = new FocalPlaneMetricReport.Builder(
            PIPELINE_TASK, TARGET_TABLE).type(MetricType.DELTA_ATTITUDE_DEC)
            .value(METRIC_VALUE)
            .uncertainty(METRIC_UNCERTAINTY)
            .time(TIME)
            .build();
        assertTrue(mr1.hashCode() != mr3.hashCode());
    }

}
