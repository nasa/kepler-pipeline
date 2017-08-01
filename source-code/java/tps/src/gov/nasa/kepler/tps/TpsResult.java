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

package gov.nasa.kepler.tps;

import java.util.Collections;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tps.AbstractTpsDbResult;
import gov.nasa.kepler.hibernate.tps.TpsLiteDbResult;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

/**
 * Potential transit events.
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public class TpsResult implements Persistable {
    
    private static final Log log = LogFactory.getLog(TpsResult.class);
    
    /** The Kepler ID of the target. */
    private int keplerId;
    
    /** The length of the transit window. */
    private float trialTransitPulseInHours;
    
    /** When false TPS-matlab has indicated it can not process this target
     * for the specified trial transit pulse.  The other fields will be 
     * undefined
     */
    private boolean isResultValid = true;
    
    /** The orbital period of the most significant potential planet. */
    @OracleDouble
    private double detectedOrbitalPeriodInDays;
    
    /** This event passed the detection threshold. */
    private boolean isPlanetACandidate;
    
    private float maxSingleEventStatistic;
    private float maxMultipleEventStatistic;
    private float timeToFirstTransitInDays;
    /** A single precision time series of the Combined Differential Photometric
     *  Precision (CDPP) for this combination of 
     *  (KeplerID, trialTransitPulseInDays)  this is either defined for all
     *  cadences or none of them.
     */
    private float[] cdppTimeSeries;
    
    /** The root mean squared CDPP. */
    private float rmsCdpp;
    
    @OracleDouble
    private double timeOfFirstTransitInMjd;

    private float minSingleEventStatistic;
    
    private float minMultipleEventStatistic;
    
    private float timeToFirstMicrolensInDays;
    
    @OracleDouble
    private double timeOfFirstMicrolensInMjd;
    
    private float detectedMicrolensOrbitalPeriodInDays;
    
    private boolean isOnEclipsingBinaryList;

    private float robustStatistic;
    
    private WeakSecondary weakSecondaryStruct;
    
    private float chiSquare1;
    private float chiSquare2;
    private int chiSquareDof1;
    private float chiSquareDof2;
    
    private float maxSesInMes;
    
    private float[] deemphasizedNormalizationTimeSeries;
    private float[] deemphasisWeight;
    
    private float chiSquareGof; 
    private int chiSquareGofDof; 
    private float sesProbability; 
    private int sesProbabilityDof;
    private float thresholdForDesiredPfa;
    
    /** If TPS finds some kind of problem then this gets set on the
     * results.
     */
    public boolean isResultValid() {
        return isResultValid;
    }
    public void setResultValid(boolean valid) {
        this.isResultValid = valid;
    }
    
    public int getKeplerId() {
        return keplerId;
    }
    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }
    
    public Boolean isOnEclipsingBinaryList() {
        if (!isResultValid()) {
            return null;
        }
        return isOnEclipsingBinaryList;
    }
    
    public void setShortPeriodEclipsingBinary(boolean newValue) {
        this.isOnEclipsingBinaryList = newValue;
    }
    
    public Double getDetectedOrbitalPeriodInDays() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(detectedOrbitalPeriodInDays, "DetectedOrbitalPeriodInDays");
        return detectedOrbitalPeriodInDays;
    }
    
    public void setDetectedOrbitalPeriodInDays(double detectedOrbitalPeriodInDays) {
        this.detectedOrbitalPeriodInDays = detectedOrbitalPeriodInDays;
    }
    
    public Boolean isPlanetACandidate() {
        if (!isResultValid()) {
            return null;
        }
        return isPlanetACandidate;
    }
    
    public void setPlanetACandidate(boolean isPlanetACandidate) {
        this.isPlanetACandidate = isPlanetACandidate;
    }
    public Float getMaxSingleEventStatistic() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(maxSingleEventStatistic, "MaxSingleEventStatistic");
        return maxSingleEventStatistic;
    }
    public void setMaxSingleEventStatistic(float maxSingleEventStatistic) {
        this.maxSingleEventStatistic = maxSingleEventStatistic;
    }
    public Float getMaxMultipleEventStatistic() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(maxMultipleEventStatistic, "MaxMultipleEventStatistic");
        return maxMultipleEventStatistic;
    }
    
    public void setMaxMultipleEventStatistic(float maxMultipleEventStatistic) {
        this.maxMultipleEventStatistic = maxMultipleEventStatistic;
    }
    
    public Float getTimeToFirstTransitInDays() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(timeToFirstTransitInDays, "TimeToFirstTransitInDays");
        return timeToFirstTransitInDays;
    }
    
    public void setTimeToFirstTransitInDays(float timeToFirstTransitInDays) {
        this.timeToFirstTransitInDays = timeToFirstTransitInDays;
    }
    public float[] getCdppTimeSeries() {
        return cdppTimeSeries;
    }
    
    public void setCdppTimeSeries(float[] cdppTimeSeries) {
        this.cdppTimeSeries = cdppTimeSeries;
    }
    public float getTrialTransitPulseInHours() {
        logNanInf(trialTransitPulseInHours, "TrialTransitPuseInHours");
        return trialTransitPulseInHours;
    }
    
    public void setTrialTransitPulseInHours(float trialTransitPulseInHours) {
        this.trialTransitPulseInHours = trialTransitPulseInHours;
    }
    
    public Float getRmsCdpp() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(rmsCdpp, "RmsCdpp");
        return rmsCdpp;
    }
    public void setRmsCdpp(float rmsCdpp) {
        this.rmsCdpp = rmsCdpp;
    }
    public Double getTimeOfFirstTransitInMjd() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(timeOfFirstTransitInMjd, "TimeOfFirstTransitInMjd");
        return timeOfFirstTransitInMjd;
    }
    public void setTimeOfFirstTransitInMjd(double timeOfFirstTransitInMjd) {
        this.timeOfFirstTransitInMjd = timeOfFirstTransitInMjd;
    }

    
    public Float getTimeToFirstMicrolensInDays() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(timeToFirstMicrolensInDays, "TimeToFirstMicrolensInDays");
        return timeToFirstMicrolensInDays;
    }
    
    public void setTimeToFirstMicrolensInDays(float timeToFirstMicrolensInDays) {
        this.timeToFirstMicrolensInDays = timeToFirstMicrolensInDays;
    }
    public Double getTimeOfFirstMicrolensInMjd() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(timeOfFirstMicrolensInMjd, "TimeOfFirstMicrolensInMjd");
        return timeOfFirstMicrolensInMjd;
    }
    
    public void setTimeOfFirstMicrolensInMjd(double timeOfFirstMicrolensInMjd) {
        this.timeOfFirstMicrolensInMjd = timeOfFirstMicrolensInMjd;
    }
    
    public Float getDetectedMicrolensOrbitalPeriodInDays() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(detectedMicrolensOrbitalPeriodInDays, "DetectedMicrolensOrbitalPeriodInDays");
        return detectedMicrolensOrbitalPeriodInDays;
    }
    
    public void setDetectedMicrolensOrbitalPeriodInDays(
        float detectedMicrolensOrbitalPeriodInDays) {
        this.detectedMicrolensOrbitalPeriodInDays = detectedMicrolensOrbitalPeriodInDays;
    }
    
    public Float getMinMultipleEventStatistic() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(minMultipleEventStatistic, "MinMultipleEventStatistic");
        return minMultipleEventStatistic;
    }
    
    public void setMinMultipleEventStatistic(float minMultipleEventStatistic) {
        this.minMultipleEventStatistic = minMultipleEventStatistic;
    }
    
    public Float getMinSingleEventStatistic() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(minSingleEventStatistic, "MinSingleEventStatistic");
        return minSingleEventStatistic;
    }
    
    public void setMinSingleEventStatistic(float minSingleEventStatistic) {
        this.minSingleEventStatistic = minSingleEventStatistic;
    }
    
    public Float getRobustStatistic() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(robustStatistic, "RobustStatistic");
        return robustStatistic;
    }
    
    public void setRobustStatistic(float robustStatistic) {
        this.robustStatistic = robustStatistic;
    }

    public WeakSecondary getWeakSecondary() {
        return weakSecondaryStruct;
    }
    
    public void setWeakSecondary(WeakSecondary weakSecondary) {
        this.weakSecondaryStruct = weakSecondary;
    }
    
    
    public Float getChiSquare1() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(chiSquare1, "chiSquare1");
        return chiSquare1;
    }
    
    public void setChiSquare1(float chi1) {
        this.chiSquare1 = chi1;
    }
    
    public Float getChiSquare2() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(chiSquare2, "chiSquare2");
        return chiSquare2;
    }
    
    public void setChiSquare2(float chi2) {
        this.chiSquare2 = chi2;
    }
    
    public Integer getChiSquareDof1() {
        if (!isResultValid()) {
            return null;
        }
        return chiSquareDof1;
    }
    
    public void setChiSquareDof1(int value) {
        this.chiSquareDof1 = value;
    }
    
    public Float getChiSquareDof2() {
        if (!isResultValid()) {
            return null;
        }
        return chiSquareDof2;
    }
    
    public void setChiSquareDof2(float value) {
        this.chiSquareDof2 = value;
    }
    
    public Float getMaxSesInMes() {
        if (!isResultValid()) {
            return null;
        }
        return maxSesInMes;
    }
    
    public void setMaxSesInMes(float maxSesInMes) {
        this.maxSesInMes = maxSesInMes;
    }
    
    public void setDeemphasizedNormalizationTimeSeries(float[] deemphasizedNormalizationTimeSeries) {
        this.deemphasizedNormalizationTimeSeries = deemphasizedNormalizationTimeSeries;
    }
    
    public Float getChiSquareGof() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(chiSquareGof, "ChiSquareGof");
        return chiSquareGof;
    }
    public void setChiSquareGof(float chiSquareGof) {
        this.chiSquareGof = chiSquareGof;
    }
    public Integer getChiSquareGofDof() {
        if (!isResultValid()) {
            return null;
        }
        return chiSquareGofDof;
    }
    public void setChiSquareGofDof(int chiSquareGofDof) {
        this.chiSquareGofDof = chiSquareGofDof;
    }
    public Float getSesProbability() {
        if (!isResultValid()) {
            return null;
        }
        logNanInf(sesProbability, "sesProbability");
        return sesProbability;
    }
    public void setSesProbability(float sesProbability) {
        this.sesProbability = sesProbability;
    }
    public Integer getSesProbabilityDof() {
        if (!isResultValid()) {
            return null;
        }
        return sesProbabilityDof;
    }
    public void setSesProbabilityDof(int sesProbabilityDof) {
        this.sesProbabilityDof = sesProbabilityDof;
    }
    
    
    public Float getThresholdForDesiredPfa() {
        if (!isResultValid()) {
            return null;
        }
        return thresholdForDesiredPfa;
    }
    
    public void setThresholdForDesiredPfa(float f) {
        this.thresholdForDesiredPfa = f;
    }
    
    
    public void setDeemphasisWeight(float[] deemphasisWeight) {
        this.deemphasisWeight = deemphasisWeight;
    }
    
    public AbstractTpsDbResult toDbResult(TpsType tpsType,
            int startCadence, int endCadence, PipelineTask pipelineTask) {
        
        if (tpsType == TpsType.TPS_LITE) {
            return new TpsLiteDbResult(
                getKeplerId(), getTrialTransitPulseInHours(),
                getMaxSingleEventStatistic(), getRmsCdpp(),
                startCadence, endCadence, FluxType.SAP, pipelineTask,
                isOnEclipsingBinaryList());
          

        } else {
            return new gov.nasa.kepler.hibernate.tps.TpsDbResult(
                getKeplerId(), getTrialTransitPulseInHours(),
                getMaxSingleEventStatistic(), getRmsCdpp(),
                startCadence, endCadence, FluxType.SAP, pipelineTask,
                getDetectedOrbitalPeriodInDays(),
                isPlanetACandidate(),
                getMaxMultipleEventStatistic(),
                getTimeToFirstTransitInDays(),
                getTimeOfFirstTransitInMjd(),
                getMinSingleEventStatistic(),
                getMinMultipleEventStatistic(),
                getTimeToFirstMicrolensInDays(),
                getTimeOfFirstMicrolensInMjd(),
                getDetectedMicrolensOrbitalPeriodInDays(),
                isOnEclipsingBinaryList(),
                getRobustStatistic(),
                weakSecondaryStruct.toDb(),
                getChiSquare1(), getChiSquare2(),
                getChiSquareDof1(), getChiSquareDof2(), getMaxSesInMes(),
                getChiSquareGof(), getChiSquareGofDof(), getThresholdForDesiredPfa()
                );
        }
    }
    
    public FloatTimeSeries cdppTimeSeries(TpsType tpsType,
        int startCadence, int endCadence, PipelineTask pipelineTask) {
        // When we get an invalid result gap the CDPP.  This differs from
        //previous versions where we would regap the time series with interquarter gaps.
        List<SimpleInterval> validCadences = null;
        List<TaggedInterval> originatorCadences = null;
        if (!isResultValid()) {
            validCadences = Collections.emptyList();
            originatorCadences = Collections.emptyList();
        } else {
            validCadences = 
                    ImmutableList.of(new SimpleInterval(startCadence, endCadence));
            originatorCadences = 
                    ImmutableList.of(new TaggedInterval(startCadence, endCadence, pipelineTask.getId()));
        }
        FsId fsId = TpsFsIdFactory.getCdppId(pipelineTask.getPipelineInstance().getId(), getKeplerId(),
            getTrialTransitPulseInHours(), tpsType, FluxType.SAP);
        return new FloatTimeSeries(fsId,
            getCdppTimeSeries(), startCadence, endCadence,
            validCadences, originatorCadences);
    }
    
    public FloatTimeSeries deemphasizedNormalizationTimeSeries(int startCadence, int endCadence, PipelineTask pipelineTask) {
        List<SimpleInterval> validCadences = Collections.emptyList();
        List<TaggedInterval> originatorCadences = Collections.emptyList();
        if (isResultValid()) {
            validCadences = 
                    ImmutableList.of(new SimpleInterval(startCadence, endCadence));
            originatorCadences = 
                    ImmutableList.of(new TaggedInterval(startCadence, endCadence, pipelineTask.getId()));
        }
        FsId fsId = TpsFsIdFactory.
            getDeemphasizedNormalizationTimeSeriesId(pipelineTask.getPipelineInstance().getId(), keplerId, trialTransitPulseInHours);
        return new FloatTimeSeries(fsId, deemphasizedNormalizationTimeSeries,
            startCadence, endCadence, validCadences, originatorCadences);
    }
    
    public FloatTimeSeries deemphasisWeight(int startCadence, int endCadence, PipelineTask pipelineTask) {
        List<SimpleInterval> validCadences = Collections.emptyList();
        List<TaggedInterval> originatorCadences = Collections.emptyList();
        if (isResultValid()) {
            validCadences = ImmutableList.of(new SimpleInterval(startCadence, endCadence));
            originatorCadences = ImmutableList.of(new TaggedInterval(startCadence, endCadence, pipelineTask.getId()));
        }
        FsId fsId = TpsFsIdFactory.getDeemphasisWeightsId(pipelineTask.getPipelineInstance().getId(),
            keplerId, trialTransitPulseInHours);
        return new FloatTimeSeries(fsId, deemphasisWeight, startCadence, endCadence, validCadences, originatorCadences);
    }
    
    private void logNanInf(float value, String field) {
        if (Float.isNaN(value)) {
            log.warn(field + " is NaN for target " + keplerId);
        }
        if (Float.isInfinite(value)) {
            log.warn(field + " is infinite for target " + keplerId);
        }
    }
    
    private void logNanInf(double value, String field) {
        if (Double.isNaN(value)) {
            log.warn(field + " is NaN for target " + keplerId);
        }
        if (Double.isInfinite(value)) {
            log.warn(field + " is infinite for target " + keplerId);
        }
    }
}
