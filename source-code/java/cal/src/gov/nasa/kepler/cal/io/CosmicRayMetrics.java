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

package gov.nasa.kepler.cal.io;

import static gov.nasa.kepler.mc.fs.CalFsIdFactory.getCosmicRayMetricFsId;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.ENERGY_KURTOSIS;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.ENERGY_SKEWNESS;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.ENERGY_VARIANCE;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.HIT_RATES;
import static gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.MEAN_ENERGY;

import java.util.Arrays;

import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import org.apache.commons.lang.ArrayUtils;

/**
 * Various statistics produced for each region of the CCD about which cosmic
 * rays where detected.
 * 
 * @author Sean McCauliff
 *
 */
public class CosmicRayMetrics implements Persistable {

    /** When true the fields of this class are valid else they are undefined. */
    private boolean exists;
    /** When hitRateGapIndicators [i] is true then the value of hitRates[i] is
     *  undefined.  The length of this array is equal to the number of cadences 
     *  in the unit of work.
     */
    private boolean[] hitRateGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    /** Number of cosmic rays hits detected in the masked smear region.  The 
     * length of this array is equal to the number of cadences in the 
     * unit of work.
     */
    private float[] hitRates = ArrayUtils.EMPTY_FLOAT_ARRAY;
    /** When meanEnergyGapIndicators [i] is true then the value of other arrays
     *  in this output are undefined.   The length of this array is equal to the
     *   number of cadences in the unit of work.
     */
    private boolean[] meanEnergyGapIndicators =ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    /** Mean of detected cosmic ray energy.  The length of this array is equal 
     * to the number of cadences in the unit of work.
     */
    private float[] meanEnergy = ArrayUtils.EMPTY_FLOAT_ARRAY;
    /** When energyVariancesGapIndicators [i] is true then the value of 
     * energyVariances[i] is undefined.  The length of this array is equal to 
     * the number of cadences in the unit of work.
     */
    private boolean[] energyVarianceGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    /**
     * Variance of detected cosmic ray energy.  The length of this array is 
     * equal to the number of cadences in the unit of work.
     */
    private float[] energyVariance = ArrayUtils.EMPTY_FLOAT_ARRAY;
    /** When energySkewnessGapIndicators [i] is true then the value of
     *  energySkewness[i] is undefined.   The length of this array is equal to 
     *  the number of cadences in the unit of work.
     */
    private boolean[] energySkewnessGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    /** Skewness of detected cosmic ray energy.  The length of this array is 
     * equal to the number of cadences in the unit of work.
     */
    private float[] energySkewness =ArrayUtils.EMPTY_FLOAT_ARRAY;
    /**
     * When energyKurtosisGapIndicators [i] is true then the value of 
     * energyKurtosis[i] is undefined.   The length of this array is equal to 
     * the number of cadences in the unit of work.
     */
    private boolean[] energyKurtosisGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    
    /** Kurtosis of detected cosmic ray energy.  The length of this array is 
     * equal to the number of cadences in the unit of work.
     */
    private float[] energyKurtosis = ArrayUtils.EMPTY_FLOAT_ARRAY;
    
    public CosmicRayMetrics() {
    }
    
    public CosmicRayMetrics(boolean exists) {
        this.exists = exists;
    }
          
    public CosmicRayMetrics(boolean exists, 
            boolean[] hitRateGapIndicators, float[] hitRates, 
            boolean[] meanEnergyGapIndicators, float[] meanEnergy, 
            boolean[] energyVarianceGapIndicators, float[] energyVariance, 
            boolean[] energySkewnessGapIndicators, float[] energySkewness, 
            boolean[] energyKurtosisGapIndicators, float[] energyKurtosis) {
        
        this.exists = exists;
        this.hitRateGapIndicators = hitRateGapIndicators;
        this.hitRates = hitRates;
        this.meanEnergyGapIndicators = meanEnergyGapIndicators;
        this.meanEnergy = meanEnergy;
        this.energyVarianceGapIndicators = energyVarianceGapIndicators;
        this.energyVariance = energyVariance;
        this.energySkewnessGapIndicators = energySkewnessGapIndicators;
        this.energySkewness = energySkewness;
        this.energyKurtosisGapIndicators = energyKurtosisGapIndicators;
        this.energyKurtosis = energyKurtosis;
    }
    
    
    public TimeSeries[] toTimeSeries(CadenceType cadenceType,
                                                CollateralType collateralType, 
                                                int ccdModule, int ccdOutput, 
                                                int startCadence, int endCadence,
                                                long taskId) {
        if (!exists) {
            return new TimeSeries[0];
        }
        
        TimeSeries[] rv = new TimeSeries[5];
        FsId id = getCosmicRayMetricFsId(cadenceType,
            collateralType, HIT_RATES, ccdModule, ccdOutput);
        rv[0] = new FloatTimeSeries(id, hitRates, startCadence, endCadence, hitRateGapIndicators, taskId);
        
        id = getCosmicRayMetricFsId(cadenceType, collateralType,
            MEAN_ENERGY, ccdModule, ccdOutput);
        rv[1] = new FloatTimeSeries(id, meanEnergy, startCadence, endCadence, meanEnergyGapIndicators, taskId);

        id = getCosmicRayMetricFsId(cadenceType, collateralType,
            ENERGY_VARIANCE, ccdModule, ccdOutput);
        rv[2] = new FloatTimeSeries(id, energyVariance, startCadence, endCadence, energyVarianceGapIndicators, taskId);
        
        id = getCosmicRayMetricFsId(cadenceType, collateralType,
           ENERGY_SKEWNESS, ccdModule, ccdOutput);
        rv[3] = new FloatTimeSeries(id, energySkewness, startCadence, endCadence, energySkewnessGapIndicators, taskId);
        
        id = getCosmicRayMetricFsId(cadenceType, collateralType,
            ENERGY_KURTOSIS, ccdModule, ccdOutput);
        rv[4] = new FloatTimeSeries(id, energyKurtosis, startCadence, endCadence, energyKurtosisGapIndicators, taskId);
        
        return rv;
    }



    public float[] getEnergyKurtosis() {
        return energyKurtosis;
    }

    public float[] getEnergySkewness() {
        return energySkewness;
    }

    public float[] getEnergyVariance() {
        return energyVariance;
    }

    public boolean isExists() {
        return exists;
    }

    public float[] getHitRates() {
        return hitRates;
    }

    public float[] getMeanEnergy() {
        return meanEnergy;
    }

    public boolean[] getHitRateGapIndicators() {
        return hitRateGapIndicators;
    }

    public boolean[] getMeanEnergyGapIndicators() {
        return meanEnergyGapIndicators;
    }

    public boolean[] getEnergyVarianceGapIndicators() {
        return energyVarianceGapIndicators;
    }

    public boolean[] getEnergySkewnessGapIndicators() {
        return energySkewnessGapIndicators;
    }

    public boolean[] getEnergyKurtosisGapIndicators() {
        return energyKurtosisGapIndicators;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(energyKurtosis);
        result = prime * result + Arrays.hashCode(energyKurtosisGapIndicators);
        result = prime * result + Arrays.hashCode(energySkewness);
        result = prime * result + Arrays.hashCode(energySkewnessGapIndicators);
        result = prime * result + Arrays.hashCode(energyVariance);
        result = prime * result + Arrays.hashCode(energyVarianceGapIndicators);
        result = prime * result + (exists ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(hitRateGapIndicators);
        result = prime * result + Arrays.hashCode(hitRates);
        result = prime * result + Arrays.hashCode(meanEnergy);
        result = prime * result + Arrays.hashCode(meanEnergyGapIndicators);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        CosmicRayMetrics other = (CosmicRayMetrics) obj;
        if (!Arrays.equals(energyKurtosis, other.energyKurtosis))
            return false;
        if (!Arrays.equals(energyKurtosisGapIndicators,
            other.energyKurtosisGapIndicators))
            return false;
        if (!Arrays.equals(energySkewness, other.energySkewness))
            return false;
        if (!Arrays.equals(energySkewnessGapIndicators,
            other.energySkewnessGapIndicators))
            return false;
        if (!Arrays.equals(energyVariance, other.energyVariance))
            return false;
        if (!Arrays.equals(energyVarianceGapIndicators,
            other.energyVarianceGapIndicators))
            return false;
        if (exists != other.exists)
            return false;
        if (!Arrays.equals(hitRateGapIndicators, other.hitRateGapIndicators))
            return false;
        if (!Arrays.equals(hitRates, other.hitRates))
            return false;
        if (!Arrays.equals(meanEnergy, other.meanEnergy))
            return false;
        if (!Arrays.equals(meanEnergyGapIndicators,
            other.meanEnergyGapIndicators))
            return false;
        return true;
    }

    
}
