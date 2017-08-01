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

package gov.nasa.kepler.mc.pa;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.EnergyDistributionMetrics;
import gov.nasa.kepler.mc.SimpleTimeSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CosmicRayMetricType;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public class PaCosmicRayMetrics extends EnergyDistributionMetrics {

    public PaCosmicRayMetrics() {
    }

    public PaCosmicRayMetrics(SimpleFloatTimeSeries hitRate,
        SimpleFloatTimeSeries meanEnergy, SimpleFloatTimeSeries energyVariance,
        SimpleFloatTimeSeries energySkewness,
        SimpleFloatTimeSeries energyKurtosis) {

        super(hitRate, meanEnergy, energyVariance, energySkewness,
            energyKurtosis);
    }

    public static List<FsId> getFsIds(TargetType targetType, int ccdModule,
        int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();
        fsIds.add(getHitRateFsId(targetType, ccdModule, ccdOutput));
        fsIds.add(getMeanEnergyFsId(targetType, ccdModule, ccdOutput));
        fsIds.add(getEnergyVarianceFsId(targetType, ccdModule, ccdOutput));
        fsIds.add(getEnergySkewnessFsId(targetType, ccdModule, ccdOutput));
        fsIds.add(getEnergyKurtosisFsId(targetType, ccdModule, ccdOutput));

        return fsIds;
    }

    public List<FloatTimeSeries> toTimeSeries(TargetType targetType,
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        long producerTaskId) {

        List<FloatTimeSeries> floatTimeSeries = new ArrayList<FloatTimeSeries>();
        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(getHitRate(),
            getHitRateFsId(targetType, ccdModule, ccdOutput), startCadence,
            endCadence, producerTaskId));
        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(getMeanEnergy(),
            getMeanEnergyFsId(targetType, ccdModule, ccdOutput), startCadence,
            endCadence, producerTaskId));
        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
            getEnergyVariance(),
            getEnergyVarianceFsId(targetType, ccdModule, ccdOutput),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
            getEnergySkewness(),
            getEnergySkewnessFsId(targetType, ccdModule, ccdOutput),
            startCadence, endCadence, producerTaskId));
        floatTimeSeries.add(SimpleTimeSeries.toFloatTimeSeries(
            getEnergyKurtosis(),
            getEnergyKurtosisFsId(targetType, ccdModule, ccdOutput),
            startCadence, endCadence, producerTaskId));
        return floatTimeSeries;
    }

    public void setTimeSeries(TargetType targetType, int ccdModule,
        int ccdOutput, Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        setHitRate(SimpleTimeSeries.getFloatInstance(
            getHitRateFsId(targetType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setMeanEnergy(SimpleTimeSeries.getFloatInstance(
            getMeanEnergyFsId(targetType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEnergyVariance(SimpleTimeSeries.getFloatInstance(
            getEnergyVarianceFsId(targetType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEnergySkewness(SimpleTimeSeries.getFloatInstance(
            getEnergySkewnessFsId(targetType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEnergyKurtosis(SimpleTimeSeries.getFloatInstance(
            getEnergyKurtosisFsId(targetType, ccdModule, ccdOutput),
            floatTimeSeriesByFsId));
        setEmpty(false);
    }

    private static FsId getHitRateFsId(TargetType targetType, int ccdModule,
        int ccdOutput) {
        return PaFsIdFactory.getCosmicRayMetricFsId(
            CosmicRayMetricType.HIT_RATE, targetType, ccdModule, ccdOutput);
    }

    private static FsId getMeanEnergyFsId(TargetType targetType, int ccdModule,
        int ccdOutput) {
        return PaFsIdFactory.getCosmicRayMetricFsId(
            CosmicRayMetricType.MEAN_ENERGY, targetType, ccdModule, ccdOutput);
    }

    private static FsId getEnergyVarianceFsId(TargetType targetType,
        int ccdModule, int ccdOutput) {
        return PaFsIdFactory.getCosmicRayMetricFsId(
            CosmicRayMetricType.ENERGY_VARIANCE, targetType, ccdModule,
            ccdOutput);
    }

    private static FsId getEnergySkewnessFsId(TargetType targetType,
        int ccdModule, int ccdOutput) {
        return PaFsIdFactory.getCosmicRayMetricFsId(
            CosmicRayMetricType.ENERGY_SKEWNESS, targetType, ccdModule,
            ccdOutput);
    }

    private static FsId getEnergyKurtosisFsId(TargetType targetType,
        int ccdModule, int ccdOutput) {
        return PaFsIdFactory.getCosmicRayMetricFsId(
            CosmicRayMetricType.ENERGY_KURTOSIS, targetType, ccdModule,
            ccdOutput);
    }
}
