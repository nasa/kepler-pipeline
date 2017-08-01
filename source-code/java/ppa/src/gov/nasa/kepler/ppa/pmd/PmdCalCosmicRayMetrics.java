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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.EnergyDistributionMetrics;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Cal-specific cosmic ray metrics.
 * 
 * @author Bill Wohler
 */
public class PmdCalCosmicRayMetrics extends EnergyDistributionMetrics {

    public PmdCalCosmicRayMetrics() {
    }

    public static List<FsId> getFsIds(CollateralType collateralType,
        int ccdModule, int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();

        fsIds.add(getHitRateFsId(collateralType, ccdModule, ccdOutput));
        fsIds.add(getMeanEnergyFsId(collateralType, ccdModule, ccdOutput));
        fsIds.add(getEnergyVarianceFsId(collateralType, ccdModule, ccdOutput));
        fsIds.add(getEnergySkewnessFsId(collateralType, ccdModule, ccdOutput));
        fsIds.add(getEnergyKurtosisFsId(collateralType, ccdModule, ccdOutput));

        return fsIds;
    }

    public void setTimeSeries(CollateralType collateralType, int ccdModule,
        int ccdOutput, Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        setHitRate(SimpleTimeSeries.getFloatInstance(
            getHitRateFsId(collateralType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setMeanEnergy(SimpleTimeSeries.getFloatInstance(
            getMeanEnergyFsId(collateralType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEnergyVariance(SimpleTimeSeries.getFloatInstance(
            getEnergyVarianceFsId(collateralType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEnergySkewness(SimpleTimeSeries.getFloatInstance(
            getEnergySkewnessFsId(collateralType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEnergyKurtosis(SimpleTimeSeries.getFloatInstance(
            getEnergyKurtosisFsId(collateralType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEmpty(false);
    }

    private static FsId getHitRateFsId(CollateralType collateralType,
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getCosmicRayMetricFsId(CadenceType.LONG,
            collateralType, CosmicRayMetricType.HIT_RATES, ccdModule, ccdOutput);
    }

    private static FsId getMeanEnergyFsId(CollateralType collateralType,
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getCosmicRayMetricFsId(CadenceType.LONG,
            collateralType, CosmicRayMetricType.MEAN_ENERGY, ccdModule,
            ccdOutput);
    }

    private static FsId getEnergyVarianceFsId(CollateralType collateralType,
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getCosmicRayMetricFsId(CadenceType.LONG,
            collateralType, CosmicRayMetricType.ENERGY_VARIANCE, ccdModule,
            ccdOutput);
    }

    private static FsId getEnergySkewnessFsId(CollateralType collateralType,
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getCosmicRayMetricFsId(CadenceType.LONG,
            collateralType, CosmicRayMetricType.ENERGY_SKEWNESS, ccdModule,
            ccdOutput);
    }

    private static FsId getEnergyKurtosisFsId(CollateralType collateralType,
        int ccdModule, int ccdOutput) {
        return CalFsIdFactory.getCosmicRayMetricFsId(CadenceType.LONG,
            collateralType, CosmicRayMetricType.ENERGY_KURTOSIS, ccdModule,
            ccdOutput);
    }
}
