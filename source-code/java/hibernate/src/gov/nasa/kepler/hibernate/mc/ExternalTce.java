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

package gov.nasa.kepler.hibernate.mc;

import gov.nasa.kepler.hibernate.cm.Kic;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Index;

/**
 * Contains an external TCE. This class is immutable.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "MC_EXTERNAL_TCE")
public class ExternalTce {

    private static final int TOKEN_COUNT = 7;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_TP_SEQ")
    @Column(nullable = false)
    private long id;

    @Index(name = "MC_ET_KEPLER_ID_IDX")
    private int keplerId;

    @Column(nullable = false)
    private int planetNumber;

    @Column(nullable = false)
    private float transitDurationHours;

    @Column(nullable = false)
    private double epochMjd;

    @Column(nullable = false)
    private float orbitalPeriodDays;

    @Column(nullable = false)
    private float maxSingleEventSigma;

    @Column(nullable = false)
    private float maxMultipleEventSigma;

    /**
     * Only used by Hibernate.
     */
    ExternalTce() {
    }

    public ExternalTce(int keplerId, int planetNumber,
        float transitDurationHours, double epochMjd, float orbitalPeriodDays,
        float maxSingleEventSigma, float maxMultipleEvenSigma) {

        this.keplerId = keplerId;
        this.planetNumber = planetNumber;
        this.transitDurationHours = transitDurationHours;
        this.epochMjd = epochMjd;
        this.orbitalPeriodDays = orbitalPeriodDays;
        this.maxSingleEventSigma = maxSingleEventSigma;
        maxMultipleEventSigma = maxMultipleEvenSigma;
    }

    public long getId() {
        return id;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public float getTransitDurationHours() {
        return transitDurationHours;
    }

    public double getEpochMjd() {
        return epochMjd;
    }

    public float getOrbitalPeriodDays() {
        return orbitalPeriodDays;
    }

    public float getMaxSingleEventSigma() {
        return maxSingleEventSigma;
    }

    public float getMaxMultipleEventSigma() {
        return maxMultipleEventSigma;
    }

    public static ExternalTce valueOf(String s) {

        String[] fields = s.split("\\" + Kic.SCP_DELIMITER, TOKEN_COUNT + 1);

        if (fields.length < TOKEN_COUNT) {
            return null;
        }

        int keplerId = Integer.parseInt(fields[0].trim());
        int planetNumber = Integer.parseInt(fields[1].trim());
        float transitDurationHours = Float.parseFloat(fields[2].trim());
        double epochMjd = Double.parseDouble(fields[3].trim());
        float orbitalPeriodDays = Float.parseFloat(fields[4].trim());
        float maxSingleEventSigma = Float.parseFloat(fields[5].trim());
        float maxMultipleEventSigma = Float.parseFloat(fields[6].trim());

        return new ExternalTce(keplerId, planetNumber, transitDurationHours,
            epochMjd, orbitalPeriodDays, maxSingleEventSigma,
            maxMultipleEventSigma);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(epochMjd);
        result = prime * result + (int) (temp ^ temp >>> 32);
        result = prime * result + keplerId;
        result = prime * result + Float.floatToIntBits(maxMultipleEventSigma);
        result = prime * result + Float.floatToIntBits(maxSingleEventSigma);
        result = prime * result + Float.floatToIntBits(orbitalPeriodDays);
        result = prime * result + planetNumber;
        result = prime * result + Float.floatToIntBits(transitDurationHours);
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
        if (!(obj instanceof ExternalTce)) {
            return false;
        }
        ExternalTce other = (ExternalTce) obj;
        if (Double.doubleToLongBits(epochMjd) != Double.doubleToLongBits(other.epochMjd)) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (Float.floatToIntBits(maxMultipleEventSigma) != Float.floatToIntBits(other.maxMultipleEventSigma)) {
            return false;
        }
        if (Float.floatToIntBits(maxSingleEventSigma) != Float.floatToIntBits(other.maxSingleEventSigma)) {
            return false;
        }
        if (Float.floatToIntBits(orbitalPeriodDays) != Float.floatToIntBits(other.orbitalPeriodDays)) {
            return false;
        }
        if (planetNumber != other.planetNumber) {
            return false;
        }
        if (Float.floatToIntBits(transitDurationHours) != Float.floatToIntBits(other.transitDurationHours)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        s.append(keplerId);
        s.append(Kic.SCP_DELIMITER);
        s.append(planetNumber);
        s.append(Kic.SCP_DELIMITER);
        s.append(transitDurationHours);
        s.append(Kic.SCP_DELIMITER);
        s.append(epochMjd);
        s.append(Kic.SCP_DELIMITER);
        s.append(orbitalPeriodDays);
        s.append(Kic.SCP_DELIMITER);
        s.append(maxSingleEventSigma);
        s.append(Kic.SCP_DELIMITER);
        s.append(maxMultipleEventSigma);

        return s.toString();
    }

}
