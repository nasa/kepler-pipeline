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

package gov.nasa.kepler.systest.sbt.data;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.systest.sbt.data.EnumMapFactory.EnumPairType;

import java.util.List;
import java.util.Map;

import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Miles Cote
 * 
 */
public class EnumMapFactoryTest {

    @Test
    public void testGetInstance() {
        List<TargetMetricsTimeSeriesType> types = ImmutableList.of(
            TargetMetricsTimeSeriesType.TWOD_BLACK,
            TargetMetricsTimeSeriesType.TWOD_BLACK_UNCERTAINTIES,
            TargetMetricsTimeSeriesType.UNDERSHOOT,
            TargetMetricsTimeSeriesType.UNDERSHOOT_UNCERTAINTIES);

        EnumMapFactory enumMapFactory = new EnumMapFactory();
        Map<TargetMetricsTimeSeriesType, TargetMetricsTimeSeriesType> actualMap = enumMapFactory.create(
            types, EnumPairType.UNCERTAINTIES);

        Map<TargetMetricsTimeSeriesType, TargetMetricsTimeSeriesType> expectedMap = ImmutableMap.of(
            TargetMetricsTimeSeriesType.TWOD_BLACK,
            TargetMetricsTimeSeriesType.TWOD_BLACK_UNCERTAINTIES,
            TargetMetricsTimeSeriesType.UNDERSHOOT,
            TargetMetricsTimeSeriesType.UNDERSHOOT_UNCERTAINTIES);

        assertEquals(expectedMap, actualMap);
    }

    @Test
    public void testGetOutliers() {
        List<PdcOutliersTimeSeriesType> types = ImmutableList.of(
            PdcOutliersTimeSeriesType.OUTLIERS,
            PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES,
            PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIERS,
            PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIER_UNCERTAINTIES);

        EnumMapFactory enumMapFactory = new EnumMapFactory();
        Map<PdcOutliersTimeSeriesType, PdcOutliersTimeSeriesType> actualMap = enumMapFactory.create(
            types, EnumPairType.UNCERTAINTIES);

        Map<PdcOutliersTimeSeriesType, PdcOutliersTimeSeriesType> expectedMap = ImmutableMap.of(
            PdcOutliersTimeSeriesType.OUTLIERS,
            PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES,
            PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIERS,
            PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIER_UNCERTAINTIES);

        assertEquals(expectedMap, actualMap);
    }

    @Test
    public void testActualUses() {
        EnumMapFactory enumMapFactory = new EnumMapFactory();
        enumMapFactory.create(
            ImmutableList.copyOf(TargetMetricsTimeSeriesType.values()),
            EnumPairType.UNCERTAINTIES);
        enumMapFactory.create(
            ImmutableList.copyOf(MetricsTimeSeriesType.values()),
            EnumPairType.UNCERTAINTIES);
        enumMapFactory.create(
            ImmutableList.copyOf(MetricsTimeSeriesType.values()),
            EnumPairType.COUNTS);
        enumMapFactory.create(
            ImmutableList.copyOf(MetricTimeSeriesType.values()),
            EnumPairType.UNCERTAINTIES);
        enumMapFactory.create(
            ImmutableList.copyOf(PdcOutliersTimeSeriesType.values()),
            EnumPairType.UNCERTAINTIES);
        enumMapFactory.create(
            ImmutableList.copyOf(PdcFluxTimeSeriesType.values()),
            EnumPairType.UNCERTAINTIES);
    }

}
