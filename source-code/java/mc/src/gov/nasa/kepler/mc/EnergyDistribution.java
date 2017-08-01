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

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @deprecated
 * @see {@link EnergyDistributionMetrics}
 * 
 */
@Deprecated
public class EnergyDistribution implements Persistable, Cloneable {

    @ProxyIgnore
    private static final Log log = LogFactory.getLog(EnergyDistribution.class);

    private float[] hitRates = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] hitRatesGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] meanEnergy = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] meanEnergyGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] energyVariance = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] energyVarianceGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] energySkewness = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] energySkewnessGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private float[] energyKurtosis = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private boolean[] energyKurtosisGapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    protected FsId getHitRatesFsId() {
        throw new UnsupportedOperationException("method not implemented");
    }

    protected FsId getMeanEnergyFsId() {
        throw new UnsupportedOperationException("method not implemented");
    }

    protected FsId getEnergyVarianceFsId() {
        throw new UnsupportedOperationException("method not implemented");
    }

    protected FsId getEnergySkewnessFsId() {
        throw new UnsupportedOperationException("method not implemented");
    }

    protected FsId getEnergyKurtosisFsId() {
        throw new UnsupportedOperationException("method not implemented");
    }

    static FloatTimeSeries getFloatTimeSeries(FsId fsId, int startCadence,
        int endCadence, boolean[] gapIndicators, long pipelineTaskId,
        float[] values) {

        FloatTimeSeries timeSeries = null;
        if (fsId != null && values != null && values.length > 0) {
            timeSeries = new FloatTimeSeries(fsId, values, startCadence,
                endCadence, gapIndicators, pipelineTaskId);
        }
        return timeSeries;
    }

    public EnergyDistribution() {
    }

    public EnergyDistribution(EnergyDistribution energyDistribution) {

        energyKurtosis = Arrays.copyOf(energyDistribution.getEnergyKurtosis(),
            energyDistribution.getEnergyKurtosis().length);
        energyKurtosisGapIndicators = Arrays.copyOf(
            energyDistribution.getEnergyKurtosisGapIndicators(),
            energyDistribution.getEnergyKurtosisGapIndicators().length);
        energySkewness = Arrays.copyOf(energyDistribution.getEnergySkewness(),
            energyDistribution.getEnergySkewness().length);
        energySkewnessGapIndicators = Arrays.copyOf(
            energyDistribution.getEnergySkewnessGapIndicators(),
            energyDistribution.getEnergySkewnessGapIndicators().length);
        energyVariance = Arrays.copyOf(energyDistribution.getEnergyVariance(),
            energyDistribution.getEnergyVariance().length);
        energyVarianceGapIndicators = Arrays.copyOf(
            energyDistribution.getEnergyVarianceGapIndicators(),
            energyDistribution.getEnergyVarianceGapIndicators().length);
        hitRates = Arrays.copyOf(energyDistribution.getHitRates(),
            energyDistribution.getHitRates().length);
        hitRatesGapIndicators = Arrays.copyOf(
            energyDistribution.getHitRatesGapIndicators(),
            energyDistribution.getHitRatesGapIndicators().length);
        meanEnergy = Arrays.copyOf(energyDistribution.getMeanEnergy(),
            energyDistribution.getMeanEnergy().length);
        meanEnergyGapIndicators = Arrays.copyOf(
            energyDistribution.getMeanEnergyGapIndicators(),
            energyDistribution.getMeanEnergyGapIndicators().length);
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("energyKurtosis.length",
            energyKurtosis.length)
            .append("energySkewness.length", energySkewness.length)
            .append("energyVariance.length", energyVariance.length)
            .append("hitRates.length", hitRates.length)
            .append("meanEnergy.length", meanEnergy.length)
            .toString();
    }

    @Override
    public EnergyDistribution clone() {
        return new EnergyDistribution(this);
    }

    public EnergyDistribution getEnergyDistribution() {
        return clone();
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + Arrays.hashCode(energyKurtosis);
        result = PRIME * result + Arrays.hashCode(energyKurtosisGapIndicators);
        result = PRIME * result + Arrays.hashCode(energySkewness);
        result = PRIME * result + Arrays.hashCode(energySkewnessGapIndicators);
        result = PRIME * result + Arrays.hashCode(energyVariance);
        result = PRIME * result + Arrays.hashCode(energyVarianceGapIndicators);
        result = PRIME * result + Arrays.hashCode(hitRates);
        result = PRIME * result + Arrays.hashCode(hitRatesGapIndicators);
        result = PRIME * result + Arrays.hashCode(meanEnergy);
        result = PRIME * result + Arrays.hashCode(meanEnergyGapIndicators);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final EnergyDistribution other = (EnergyDistribution) obj;
        if (!Arrays.equals(energyKurtosis, other.energyKurtosis)) {
            return false;
        }
        if (!Arrays.equals(energyKurtosisGapIndicators,
            other.energyKurtosisGapIndicators)) {
            return false;
        }
        if (!Arrays.equals(energySkewness, other.energySkewness)) {
            return false;
        }
        if (!Arrays.equals(energySkewnessGapIndicators,
            other.energySkewnessGapIndicators)) {
            return false;
        }
        if (!Arrays.equals(energyVariance, other.energyVariance)) {
            return false;
        }
        if (!Arrays.equals(energyVarianceGapIndicators,
            other.energyVarianceGapIndicators)) {
            return false;
        }
        if (!Arrays.equals(hitRates, other.hitRates)) {
            return false;
        }
        if (!Arrays.equals(hitRatesGapIndicators, other.hitRatesGapIndicators)) {
            return false;
        }
        if (!Arrays.equals(meanEnergy, other.meanEnergy)) {
            return false;
        }
        if (!Arrays.equals(meanEnergyGapIndicators,
            other.meanEnergyGapIndicators)) {
            return false;
        }
        return true;
    }

    public List<FsId> getTimeSeriesFsIds() {

        List<FsId> fsIds = new ArrayList<FsId>();
        fsIds.add(getHitRatesFsId());
        fsIds.add(getMeanEnergyFsId());
        fsIds.add(getEnergyVarianceFsId());
        fsIds.add(getEnergySkewnessFsId());
        fsIds.add(getEnergyKurtosisFsId());
        return fsIds;
    }

    public void setAllTimeSeries(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        setEnergyKurtosis(timeSeriesByFsId);
        setEnergySkewness(timeSeriesByFsId);
        setEnergyVariance(timeSeriesByFsId);
        setHitRates(timeSeriesByFsId);
        setMeanEnergy(timeSeriesByFsId);
    }

    public List<FloatTimeSeries> getAllFloatTimeSeries(int startCadence,
        int endCadence, long pipelineTaskId) {

        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();
        FloatTimeSeries floatTimeSeries = null;
        floatTimeSeries = getHitRates(startCadence, endCadence, pipelineTaskId);
        if (floatTimeSeries != null) {
            timeSeries.add(floatTimeSeries);
        }
        floatTimeSeries = getMeanEnergy(startCadence, endCadence,
            pipelineTaskId);
        if (floatTimeSeries != null) {
            timeSeries.add(floatTimeSeries);
        }
        floatTimeSeries = getEnergyVariance(startCadence, endCadence,
            pipelineTaskId);
        if (floatTimeSeries != null) {
            timeSeries.add(floatTimeSeries);
        }
        floatTimeSeries = getEnergySkewness(startCadence, endCadence,
            pipelineTaskId);
        if (floatTimeSeries != null) {
            timeSeries.add(floatTimeSeries);
        }
        floatTimeSeries = getEnergyKurtosis(startCadence, endCadence,
            pipelineTaskId);
        if (floatTimeSeries != null) {
            timeSeries.add(floatTimeSeries);
        }

        return timeSeries;
    }

    public void writeTimeSeries(FileStoreClient fsClient, int startCadence,
        int endCadence, long pipelineTaskId) {

        List<FloatTimeSeries> timeSeries = getAllFloatTimeSeries(startCadence,
            endCadence, pipelineTaskId);
        if (timeSeries.size() > 0) {
            if (log.isDebugEnabled()) {
                log.debug("writeTimeSeries(): timeSeries[0].getId()="
                    + timeSeries.get(0)
                        .id() + "; timeSeries.size()=" + timeSeries.size()
                    + "; startCadence=" + startCadence + "; endCadence="
                    + endCadence);
            }
            fsClient.writeTimeSeries(timeSeries.toArray(new FloatTimeSeries[0]));
        }
    }

    public float[] getEnergyKurtosis() {
        return energyKurtosis;
    }

    protected FloatTimeSeries getEnergyKurtosis(int startCadence,
        int endCadence, long pipelineTaskId) {

        return EnergyDistribution.getFloatTimeSeries(getEnergyKurtosisFsId(),
            startCadence, endCadence, getEnergyKurtosisGapIndicators(),
            pipelineTaskId, getEnergyKurtosis());

    }

    public void setEnergyKurtosis(float[] energyKurtosis,
        boolean[] gapIndicators) {
        this.energyKurtosis = energyKurtosis;
        energyKurtosisGapIndicators = gapIndicators;
    }

    protected void setEnergyKurtosis(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(getEnergyKurtosisFsId());
        if (timeSeries != null) {
            setEnergyKurtosis(timeSeries.fseries(),
                timeSeries.getGapIndicators());
        }
    }

    public float[] getEnergySkewness() {
        return energySkewness;
    }

    protected FloatTimeSeries getEnergySkewness(int startCadence,
        int endCadence, long pipelineTaskId) {

        return EnergyDistribution.getFloatTimeSeries(getEnergySkewnessFsId(),
            startCadence, endCadence, getEnergySkewnessGapIndicators(),
            pipelineTaskId, getEnergySkewness());

    }

    public void setEnergySkewness(float[] values, boolean[] gapIndicators) {
        energySkewness = values;
        energySkewnessGapIndicators = gapIndicators;
    }

    protected void setEnergySkewness(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(getEnergySkewnessFsId());
        if (timeSeries != null) {
            setEnergySkewness(timeSeries.fseries(),
                timeSeries.getGapIndicators());
        }
    }

    public float[] getEnergyVariance() {
        return energyVariance;
    }

    protected FloatTimeSeries getEnergyVariance(int startCadence,
        int endCadence, long pipelineTaskId) {

        return EnergyDistribution.getFloatTimeSeries(getEnergyVarianceFsId(),
            startCadence, endCadence, getEnergyVarianceGapIndicators(),
            pipelineTaskId, getEnergyVariance());

    }

    public void setEnergyVariance(float[] values, boolean[] gapIndicators) {
        energyVariance = values;
        energyVarianceGapIndicators = gapIndicators;
    }

    protected void setEnergyVariance(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(getEnergyVarianceFsId());
        if (timeSeries != null) {
            setEnergyVariance(timeSeries.fseries(),
                timeSeries.getGapIndicators());
        }
    }

    public float[] getHitRates() {
        return hitRates;
    }

    protected FloatTimeSeries getHitRates(int startCadence, int endCadence,
        long pipelineTaskId) {

        return EnergyDistribution.getFloatTimeSeries(getHitRatesFsId(),
            startCadence, endCadence, getHitRatesGapIndicators(),
            pipelineTaskId, getHitRates());

    }

    public void setHitRates(float[] values, boolean[] gapIndicators) {
        hitRates = values;
        hitRatesGapIndicators = gapIndicators;
    }

    protected void setHitRates(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(getHitRatesFsId());
        if (timeSeries != null) {
            setHitRates(timeSeries.fseries(), timeSeries.getGapIndicators());
        }
    }

    public float[] getMeanEnergy() {
        return meanEnergy;
    }

    protected FloatTimeSeries getMeanEnergy(int startCadence, int endCadence,
        long pipelineTaskId) {

        return EnergyDistribution.getFloatTimeSeries(getMeanEnergyFsId(),
            startCadence, endCadence, getMeanEnergyGapIndicators(),
            pipelineTaskId, getMeanEnergy());

    }

    public void setMeanEnergy(float[] values, boolean[] gapIndicators) {
        meanEnergy = values;
        meanEnergyGapIndicators = gapIndicators;
    }

    protected void setMeanEnergy(Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(getMeanEnergyFsId());
        if (timeSeries != null) {
            setMeanEnergy(timeSeries.fseries(), timeSeries.getGapIndicators());
        }
    }

    public boolean[] getEnergyKurtosisGapIndicators() {
        return energyKurtosisGapIndicators;
    }

    public boolean[] getEnergySkewnessGapIndicators() {
        return energySkewnessGapIndicators;
    }

    public boolean[] getEnergyVarianceGapIndicators() {
        return energyVarianceGapIndicators;
    }

    public boolean[] getHitRatesGapIndicators() {
        return hitRatesGapIndicators;
    }

    public boolean[] getMeanEnergyGapIndicators() {
        return meanEnergyGapIndicators;
    }

}
