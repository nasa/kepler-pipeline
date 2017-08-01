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

package gov.nasa.kepler.mc;

import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * 
 * @author Forrest Girouard
 *
 */
public class EnergyDistributionMetrics implements Persistable {

    private boolean empty = true;

    private SimpleFloatTimeSeries hitRate = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries meanEnergy = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries energyVariance = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries energySkewness = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries energyKurtosis = new SimpleFloatTimeSeries();

    public EnergyDistributionMetrics() {
    }

    public EnergyDistributionMetrics(SimpleFloatTimeSeries hitRate,
        SimpleFloatTimeSeries meanEnergy, SimpleFloatTimeSeries energyVariance,
        SimpleFloatTimeSeries energySkewness, SimpleFloatTimeSeries energyKurtosis) {

        this.empty = false;
        this.hitRate = hitRate;
        this.meanEnergy = meanEnergy;
        this.energyVariance = energyVariance;
        this.energySkewness = energySkewness;
        this.energyKurtosis = energyKurtosis;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result
            + ((energyKurtosis == null) ? 0 : energyKurtosis.hashCode());
        result = PRIME * result
            + ((energySkewness == null) ? 0 : energySkewness.hashCode());
        result = PRIME * result
            + ((energyVariance == null) ? 0 : energyVariance.hashCode());
        result = PRIME * result + (empty ? 1231 : 1237);
        result = PRIME * result + ((hitRate == null) ? 0 : hitRate.hashCode());
        result = PRIME * result
            + ((meanEnergy == null) ? 0 : meanEnergy.hashCode());
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
        final EnergyDistributionMetrics other = (EnergyDistributionMetrics) obj;
        if (energyKurtosis == null) {
            if (other.energyKurtosis != null)
                return false;
        } else if (!energyKurtosis.equals(other.energyKurtosis))
            return false;
        if (energySkewness == null) {
            if (other.energySkewness != null)
                return false;
        } else if (!energySkewness.equals(other.energySkewness))
            return false;
        if (energyVariance == null) {
            if (other.energyVariance != null)
                return false;
        } else if (!energyVariance.equals(other.energyVariance))
            return false;
        if (empty != other.empty)
            return false;
        if (hitRate == null) {
            if (other.hitRate != null)
                return false;
        } else if (!hitRate.equals(other.hitRate))
            return false;
        if (meanEnergy == null) {
            if (other.meanEnergy != null)
                return false;
        } else if (!meanEnergy.equals(other.meanEnergy))
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("empty", empty)
            .append("hitRate", hitRate)
            .append("meanEnergy", meanEnergy)
            .append("energyVariance", energyVariance)
            .append("energySkewness", energySkewness)
            .append("energyKurtosis", energyKurtosis)
            .toString();
    }

    public SimpleFloatTimeSeries getEnergyKurtosis() {
        return energyKurtosis;
    }

    public void setEnergyKurtosis(SimpleFloatTimeSeries energyKurtosis) {
        this.energyKurtosis = energyKurtosis;
    }

    public SimpleFloatTimeSeries getEnergySkewness() {
        return energySkewness;
    }

    public void setEnergySkewness(SimpleFloatTimeSeries energySkewness) {
        this.energySkewness = energySkewness;
    }

    public SimpleFloatTimeSeries getEnergyVariance() {
        return energyVariance;
    }

    public void setEnergyVariance(SimpleFloatTimeSeries energyVariance) {
        this.energyVariance = energyVariance;
    }

    public boolean isEmpty() {
        return empty;
    }

    public void setEmpty(boolean empty) {
        this.empty = empty;
    }

    public SimpleFloatTimeSeries getHitRate() {
        return hitRate;
    }

    public void setHitRate(SimpleFloatTimeSeries hitRate) {
        this.hitRate = hitRate;
    }

    public SimpleFloatTimeSeries getMeanEnergy() {
        return meanEnergy;
    }

    public void setMeanEnergy(SimpleFloatTimeSeries meanEnergy) {
        this.meanEnergy = meanEnergy;
    }

}
