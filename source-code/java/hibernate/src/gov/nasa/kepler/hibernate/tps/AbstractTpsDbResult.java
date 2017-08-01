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

import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import javax.persistence.*;

import org.hibernate.annotations.Index;

/**
 * The base class for the different tps results. Single event.
 * 
 * @author Sean McCauliff
 * 
 */

@Entity
@Table(name = "TPS_RESULT")
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(name = "resultType", discriminatorType = DiscriminatorType.STRING, length = 1)
@DiscriminatorValue("A")
public abstract class AbstractTpsDbResult {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "tps")
    @SequenceGenerator(name = "tps", sequenceName = "TPS_SEQ")
    // required by Hibernate
    private long id;

    @Index(name = "TPS_RESULT_IDX")
    private int keplerId;

    private FluxType fluxType;

    private float trialTransitPulseInHours;

    private Float maxSingleEventStatistic;

    private Float rmsCdpp;

    @Index(name = "TPS_RESULT_IDX")
    private int startCadence;

    @Index(name = "TPS_RESULT_IDX")
    private int endCadence;

    @ManyToOne(fetch=FetchType.LAZY)
    private PipelineTask originator;
    
    @Column(name="TPS_IS_ON_ECLIPSINGB_LIST", nullable=true)
    private Boolean isOnEclipsingBinaryList;

    protected AbstractTpsDbResult() {

    }

    public AbstractTpsDbResult(int keplerId, float trialTransitPulseInHours,
        Float maxSingleEventStatistic, Float rmsCdpp, int startCadence,
        int endCadence, FluxType fluxType, PipelineTask originator,
        Boolean isOnEclipsingBinaryList) {
        super();
        this.keplerId = keplerId;
        this.trialTransitPulseInHours = trialTransitPulseInHours;
        this.maxSingleEventStatistic = maxSingleEventStatistic;
        this.rmsCdpp = rmsCdpp;
        this.isOnEclipsingBinaryList = isOnEclipsingBinaryList;

        if (startCadence > endCadence) {
            throw new IllegalArgumentException("startCadence " + startCadence
                + " comes after endCadence " + endCadence);
        }
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        if (originator == null) {
            throw new NullPointerException("originator may not be null.");
        }
        this.originator = originator;
        if (fluxType == null) {
            throw new NullPointerException("fluxType may not be null");
        }
        this.fluxType = fluxType;
    }

    public long getId() {
        return id;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public FluxType getFluxType() {
        return fluxType;
    }

    public float getTrialTransitPulseInHours() {
        return trialTransitPulseInHours;
    }

    public Float getMaxSingleEventStatistic() {
        return maxSingleEventStatistic;
    }

    public Float getRmsCdpp() {
        return rmsCdpp;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public PipelineTask getOriginator() {
        return originator;
    }

    public boolean isOnEclipsingBinaryList() {
        return isOnEclipsingBinaryList;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + endCadence;
        result = prime * result
            + ((fluxType == null) ? 0 : fluxType.hashCode());
        result = prime * result + (int) (id ^ (id >>> 32));
        result = prime * result + (isOnEclipsingBinaryList ? 1231 : 1237);
        result = prime * result + keplerId;
        result = prime
            * result
            + ((maxSingleEventStatistic == null) ? 0
                : maxSingleEventStatistic.hashCode());
        result = prime * result
            + ((originator == null) ? 0 : originator.hashCode());
        result = prime * result + ((rmsCdpp == null) ? 0 : rmsCdpp.hashCode());
        result = prime * result + startCadence;
        result = prime * result
            + Float.floatToIntBits(trialTransitPulseInHours);
        return result;
    }

    /**
     * This has been modified from the automatically generated version.
     * Originator equality is checked by checking that the ids of the
     * originators agree.
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        AbstractTpsDbResult other = (AbstractTpsDbResult) obj;
        if (endCadence != other.endCadence)
            return false;
        if (fluxType != other.fluxType)
            return false;
        if (id != other.id)
            return false;
        if (isOnEclipsingBinaryList != other.isOnEclipsingBinaryList)
            return false;
        if (keplerId != other.keplerId)
            return false;
        if (maxSingleEventStatistic == null) {
            if (other.maxSingleEventStatistic != null)
                return false;
        } else if (!maxSingleEventStatistic.equals(other.maxSingleEventStatistic))
            return false;
        if (originator == null) {
            if (other.originator != null)
                return false;
        } else if (originator.getId() != other.originator.getId())
            return false;
        if (rmsCdpp == null) {
            if (other.rmsCdpp != null)
                return false;
        } else if (!rmsCdpp.equals(other.rmsCdpp))
            return false;
        if (startCadence != other.startCadence)
            return false;
        if (Float.floatToIntBits(trialTransitPulseInHours) != Float.floatToIntBits(other.trialTransitPulseInHours))
            return false;
        return true;
    }

 

}
