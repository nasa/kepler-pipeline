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

package gov.nasa.kepler.hibernate.tps;


import java.util.Arrays;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

/**
 * Store information on weak secondaries.  The mes and phase information for
 * weak secondaries are stored in the file store.
 * 
 * @author Sean McCauliff
 *
 */
@Entity
@Table(name = "TPS_WEAK_SECONDARY")
public class WeakSecondaryDb {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "tps")
    @SequenceGenerator(name = "tps", sequenceName = "TPS_SEQ")
    @Column(nullable = false)
    private long id;
    private float maxMesPhaseInDays;
    private float maxMes;
    private float minMesPhaseInDays;
    private float minMes;
    private float mesMad;
    private float depthPpm;
    private float depthUncert;
    
    @Transient
    private transient float[] mes;
    
    @Transient
    private transient float[] phaseInDays;
    
    private Float medianMes;
    private Integer nValidPhases;
    private Float robustStatistic; 
  
    public WeakSecondaryDb() {}
    
    public WeakSecondaryDb(float maxMesPhaseInDays, float maxMes, float[] mes,
            float[] phaseInDays, float minMesPhaseInDays, float minMes,
            float mesMad, float depthPpm, float depthUncert,
            float medianMes, int nValidPhases, float robustStatistic) {
        super();
        this.maxMesPhaseInDays = maxMesPhaseInDays;
        this.maxMes = maxMes;
        this.mes = mes;
        this.phaseInDays = phaseInDays;
        this.minMesPhaseInDays = minMesPhaseInDays;
        this.minMes = minMes;
        this.mesMad = mesMad;
        this.depthPpm = depthPpm;
        this.depthUncert = depthUncert;
        this.medianMes = medianMes;
        this.nValidPhases = nValidPhases;
        this.robustStatistic = robustStatistic;
    }
    
    public float getMaxMesPhaseInDays() {
        return maxMesPhaseInDays;
    }
    public void setMaxMesPhaseInDays(float bestPhaseInDays) {
        this.maxMesPhaseInDays = bestPhaseInDays;
    }
    public float getMaxMes() {
        return maxMes;
    }
    public void setMaxMes(float maxMes) {
        this.maxMes = maxMes;
    }
    
    public long getId() {
        return id;
    }
    public void setId(long id) {
        this.id = id;
    }
    public float[] getMes() {
        return mes;
    }
    public void setMes(float[] mes) {
        this.mes = mes;
    }
    public float[] getPhaseInDays() {
        return phaseInDays;
    }
    public void setPhaseInDays(float[] phaseInDays) {
        this.phaseInDays = phaseInDays;
    }

    public float getMinMesPhaseInDays() {
        return minMesPhaseInDays;
    }

    public void setMinMesPhaseInDays(float minMesPhaseInDays) {
        this.minMesPhaseInDays = minMesPhaseInDays;
    }

    public float getMinMes() {
        return minMes;
    }

    public void setMinMes(float minMes) {
        this.minMes = minMes;
    }

    public float getMesMad() {
        return mesMad;
    }

    public void setMesMad(float mesMad) {
        this.mesMad = mesMad;
    }

    public float getDepthPpm() {
        return depthPpm;
    }

    public void setDepthPpm(float depthPpm) {
        this.depthPpm = depthPpm;
    }

    public float getDepthUncertainity() {
        return depthUncert;
    }

    public void setDepthUncertainity(float depthUncert) {
        this.depthUncert = depthUncert;
    }

    public Float getMedianMes() {
        return medianMes;
    }

    public void setMedianMes(float medianMes) {
        this.medianMes = medianMes;
    }

    public Integer getnValidPhases() {
        return nValidPhases;
    }

    public void setnValidPhases(int nValidPhases) {
        this.nValidPhases = nValidPhases;
    }

    public Float getRobustStatistic() {
        return robustStatistic;
    }

    public void setRobustStatistic(float robustStatistic) {
        this.robustStatistic = robustStatistic;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Float.floatToIntBits(depthPpm);
        result = prime * result + Float.floatToIntBits(depthUncert);
        result = prime * result + (int) (id ^ (id >>> 32));
        result = prime * result + Float.floatToIntBits(maxMes);
        result = prime * result + Float.floatToIntBits(maxMesPhaseInDays);
        result = prime * result
                + ((medianMes == null) ? 0 : medianMes.hashCode());
        result = prime * result + Float.floatToIntBits(mesMad);
        result = prime * result + Float.floatToIntBits(minMes);
        result = prime * result + Float.floatToIntBits(minMesPhaseInDays);
        result = prime * result
                + ((nValidPhases == null) ? 0 : nValidPhases.hashCode());
        result = prime * result
                + ((robustStatistic == null) ? 0 : robustStatistic.hashCode());
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
        WeakSecondaryDb other = (WeakSecondaryDb) obj;
        if (Float.floatToIntBits(depthPpm) != Float
                .floatToIntBits(other.depthPpm))
            return false;
        if (Float.floatToIntBits(depthUncert) != Float
                .floatToIntBits(other.depthUncert))
            return false;
        if (id != other.id)
            return false;
        if (Float.floatToIntBits(maxMes) != Float.floatToIntBits(other.maxMes))
            return false;
        if (Float.floatToIntBits(maxMesPhaseInDays) != Float
                .floatToIntBits(other.maxMesPhaseInDays))
            return false;
        if (medianMes == null) {
            if (other.medianMes != null)
                return false;
        } else if (!medianMes.equals(other.medianMes))
            return false;
        if (Float.floatToIntBits(mesMad) != Float.floatToIntBits(other.mesMad))
            return false;
        if (Float.floatToIntBits(minMes) != Float.floatToIntBits(other.minMes))
            return false;
        if (Float.floatToIntBits(minMesPhaseInDays) != Float
                .floatToIntBits(other.minMesPhaseInDays))
            return false;
        if (nValidPhases == null) {
            if (other.nValidPhases != null)
                return false;
        } else if (!nValidPhases.equals(other.nValidPhases))
            return false;
        if (robustStatistic == null) {
            if (other.robustStatistic != null)
                return false;
        } else if (!robustStatistic.equals(other.robustStatistic))
            return false;
        return true;
    }

    @Override
    public String toString() {
        final int maxLen = 8;
        StringBuilder builder = new StringBuilder();
        builder.append("WeakSecondaryDb [id=");
        builder.append(id);
        builder.append(", maxMesPhaseInDays=");
        builder.append(maxMesPhaseInDays);
        builder.append(", maxMes=");
        builder.append(maxMes);
        builder.append(", minMesPhaseInDays=");
        builder.append(minMesPhaseInDays);
        builder.append(", minMes=");
        builder.append(minMes);
        builder.append(", mesMad=");
        builder.append(mesMad);
        builder.append(", depthPpm=");
        builder.append(depthPpm);
        builder.append(", depthUncert=");
        builder.append(depthUncert);
        builder.append(", mes=");
        builder.append(mes != null ? Arrays.toString(Arrays.copyOf(mes,
                Math.min(mes.length, maxLen))) : null);
        builder.append(", phaseInDays=");
        builder.append(phaseInDays != null ? Arrays.toString(Arrays.copyOf(
                phaseInDays, Math.min(phaseInDays.length, maxLen))) : null);
        builder.append(", medianMes=");
        builder.append(medianMes);
        builder.append(", nValidPhases=");
        builder.append(nValidPhases);
        builder.append(", robustStatistic=");
        builder.append(robustStatistic);
        builder.append("]");
        return builder.toString();
    }

    

}
