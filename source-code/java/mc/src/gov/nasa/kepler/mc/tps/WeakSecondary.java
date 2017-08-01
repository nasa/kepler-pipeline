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

package gov.nasa.kepler.mc.tps;

import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tps.WeakSecondaryDb;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableList;

import static gov.nasa.kepler.mc.fs.TpsFsIdFactory.*;

/**
 * Persistable weak secondary information.
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public final class WeakSecondary implements Persistable {
    private static final Log log = LogFactory.getLog(WeakSecondary.class);
    
    public static final class Depth implements Persistable {
        public Depth() {}
        
        public float value;
        public float uncertainty;
        
        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + Float.floatToIntBits(uncertainty);
            result = prime * result + Float.floatToIntBits(value);
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
            Depth other = (Depth) obj;
            if (Float.floatToIntBits(uncertainty) != Float.floatToIntBits(other.uncertainty))
                return false;
            if (Float.floatToIntBits(value) != Float.floatToIntBits(other.value))
                return false;
            return true;
        }
        
    }
    
    private float[] mes = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float[] phaseInDays = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private float maxMesPhaseInDays;
    private float maxMes;
    private float minMesPhaseInDays;
    private float minMes;
    private float mesMad;
    private Depth depthPpm = new Depth();
    private float medianMes;
    private int nValidPhases;
    private float robustStatistic;

    public WeakSecondary() {
    
    }
    

    public WeakSecondary(float[] mes, float[] phaseInDays,
            float maxMesPhaseInDays, float maxMes,
            float minMesPhaseInDays, float minMes, float mesMad,
            float depthPpm, float depthUncert,
            float medianMes, int nValidPhases, float robustStatistic) {
    
        if (phaseInDays == null) {
            throw new NullPointerException("phaseInDays");
        }
        
        if (mes == null) {
            throw new NullPointerException("mes");
        }
        
        this.mes = mes;
        this.phaseInDays = phaseInDays;
        this.maxMesPhaseInDays = maxMesPhaseInDays;
        this.maxMes = maxMes;
        this.minMesPhaseInDays = minMesPhaseInDays;
        this.minMes = minMes;
        this.mesMad = mesMad;
        this.depthPpm.value = depthPpm;
        this.depthPpm.uncertainty = depthUncert;
        this.nValidPhases = nValidPhases;
        this.medianMes = medianMes;
        this.robustStatistic = robustStatistic;
    }

    private static <T> T getOrElse(T v, T alternative) {
        if (v != null) {
            return v;
        } else {
            return alternative;
        }
    }
    
    
    public WeakSecondary(WeakSecondaryDb weakSecondaryDb) {
        if (weakSecondaryDb == null) {
            this.maxMes = Float.NaN;
            this.maxMesPhaseInDays = Float.NaN;
            this.minMes = Float.NaN;
            this.minMesPhaseInDays = Float.NaN;
            this.mesMad = Float.NaN;
            this.mes = ArrayUtils.EMPTY_FLOAT_ARRAY;
            this.phaseInDays = ArrayUtils.EMPTY_FLOAT_ARRAY;
            this.medianMes = Float.NaN;
            this.nValidPhases = -1;
            this.robustStatistic = Float.NaN;
        } else {
            mes = weakSecondaryDb.getMes();
            phaseInDays = weakSecondaryDb.getPhaseInDays();
            maxMes = weakSecondaryDb.getMaxMes();
            maxMesPhaseInDays = weakSecondaryDb.getMaxMesPhaseInDays();
            minMes = weakSecondaryDb.getMinMes();
            minMesPhaseInDays = weakSecondaryDb.getMinMesPhaseInDays();
            mesMad = weakSecondaryDb.getMesMad();
            depthPpm.value = weakSecondaryDb.getDepthPpm();
            depthPpm.uncertainty = weakSecondaryDb.getDepthUncertainity();
            medianMes = getOrElse(weakSecondaryDb.getMedianMes(), Float.NaN);
            nValidPhases = getOrElse(weakSecondaryDb.getnValidPhases(), -1);
            robustStatistic = getOrElse(weakSecondaryDb.getRobustStatistic(), Float.NaN);
        }
    }
    
    public float[] mes() {
        return mes;
    }
    
    public float[] phaseInDays() {
        return phaseInDays;
    }
    
    public float maxMesPhaseInDays() {
        return maxMesPhaseInDays;
    }
    
    public float maxMes() {
        return maxMes;
    }
    
    public float minMesPhaseInDays() {
        return minMesPhaseInDays;
    }
    
    public float minMes() {
        return minMes;
    }
    
    public float mesMad() {
        return mesMad;
    }
    
    public float depthPpm() {
        return depthPpm.value;
    }
    public float depthUncert() {
        return depthPpm.uncertainty;
    }
    
    public float medianMes() {
        return medianMes;
    }
    
    public int nValidPhases() {
        return nValidPhases;
    }
    
    public float robustStatistic() {
       return robustStatistic;
    }
    
    public void putArrays(long pipelineInstanceId, Collection<FloatTimeSeries> targetCollection,
            int keplerId, float resultTrialTransitPulse,
            PipelineTask pipelineTask) {
    
        if (mes.length == 0) {
           return;
        }
        
        FsId mesId = getWeakSecondaryMesId(pipelineInstanceId, keplerId, resultTrialTransitPulse);
        FsId phaseId = getWeakSecondaryPhaseId(pipelineInstanceId, keplerId, resultTrialTransitPulse);
        SimpleInterval valid = new SimpleInterval(0, mes.length-1);
        List<SimpleInterval> validList = ImmutableList.of(valid);
        TaggedInterval origin = new TaggedInterval(0, mes.length-1, pipelineTask.getId());
        List<TaggedInterval> originList = ImmutableList.of(origin);
        FloatTimeSeries mesArray = 
            new FloatTimeSeries(mesId, mes, 0, mes.length-1, validList, originList);
        FloatTimeSeries phaseArray = 
            new FloatTimeSeries(phaseId, phaseInDays, 0, mes.length -1, validList, originList);
        targetCollection.add(mesArray);
        targetCollection.add(phaseArray);
    }
    
    public WeakSecondaryDb toDb() {
        if (this.mes.length == 0) {
            return null;
        }
        if (mes.length != phaseInDays.length) {
            throw new IllegalStateException("mes.length(" + mes.length +
                    ") != phaseInDays.length(" + phaseInDays.length + ")");
        }
        if (Float.isNaN(maxMes) || Float.isInfinite(maxMes)) {
            log.warn("maxMes is NaN or infinite.");
        }
        if (Float.isNaN(maxMesPhaseInDays) || Float.isInfinite(maxMesPhaseInDays)) {
            log.warn("maxMesPhaseInDays is NaN or infinite.");
        }
        if (Float.isNaN(minMes) || Float.isInfinite(minMes)) {
            log.warn("minMes is NaN or infinite");
        }
        if (Float.isNaN(mesMad) || Float.isInfinite(mesMad)) {
            log.warn("mesMad is NaN or infinite");
        }
        if (Float.isNaN(minMesPhaseInDays) || Float.isInfinite(minMesPhaseInDays)) {
            log.warn("minMesPhaseInDays is NaN or infinite");
        }
        if (Float.isNaN(depthPpm.value) || Float.isInfinite(depthPpm.value)) {
            log.warn("depthPpm.value is NaN or infinite");
        }
        if (Float.isNaN(depthPpm.uncertainty) || Float.isInfinite(depthPpm.uncertainty)) {
            log.warn("depthPpm.uncertainty is NaN or infinite");
        }
        if (Float.isNaN(medianMes) || Float.isInfinite(medianMes)) {
            log.warn("medianMes is NaN or infinite");
        }
        if (Float.isNaN(robustStatistic) || Float.isInfinite(robustStatistic)) {
            log.warn("robustStatistic is NaN or infinite");
        }
        WeakSecondaryDb rv = 
            new WeakSecondaryDb(maxMesPhaseInDays, maxMes, mes, phaseInDays,
                minMesPhaseInDays, minMes, mesMad, depthPpm.value,
                depthPpm.uncertainty, medianMes, nValidPhases, robustStatistic);
        return rv;
    }


    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
                + ((depthPpm == null) ? 0 : depthPpm.hashCode());
        result = prime * result + Float.floatToIntBits(maxMes);
        result = prime * result + Float.floatToIntBits(maxMesPhaseInDays);
        result = prime * result + Float.floatToIntBits(medianMes);
        result = prime * result + Arrays.hashCode(mes);
        result = prime * result + Float.floatToIntBits(mesMad);
        result = prime * result + Float.floatToIntBits(minMes);
        result = prime * result + Float.floatToIntBits(minMesPhaseInDays);
        result = prime * result + nValidPhases;
        result = prime * result + Arrays.hashCode(phaseInDays);
        result = prime * result + Float.floatToIntBits(robustStatistic);
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
        WeakSecondary other = (WeakSecondary) obj;
        if (depthPpm == null) {
            if (other.depthPpm != null)
                return false;
        } else if (!depthPpm.equals(other.depthPpm))
            return false;
        if (Float.floatToIntBits(maxMes) != Float.floatToIntBits(other.maxMes))
            return false;
        if (Float.floatToIntBits(maxMesPhaseInDays) != Float
                .floatToIntBits(other.maxMesPhaseInDays))
            return false;
        if (Float.floatToIntBits(medianMes) != Float
                .floatToIntBits(other.medianMes))
            return false;
        if (!Arrays.equals(mes, other.mes))
            return false;
        if (Float.floatToIntBits(mesMad) != Float.floatToIntBits(other.mesMad))
            return false;
        if (Float.floatToIntBits(minMes) != Float.floatToIntBits(other.minMes))
            return false;
        if (Float.floatToIntBits(minMesPhaseInDays) != Float
                .floatToIntBits(other.minMesPhaseInDays))
            return false;
        if (nValidPhases != other.nValidPhases)
            return false;
        if (!Arrays.equals(phaseInDays, other.phaseInDays))
            return false;
        if (Float.floatToIntBits(robustStatistic) != Float
                .floatToIntBits(other.robustStatistic))
            return false;
        return true;
    }

}
