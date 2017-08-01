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

package gov.nasa.kepler.hibernate.fc;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * This class encapsulates the pointing information (ra, declination, and roll)
 * The pointing information is valid after the time 'mjd', and is sorted in the
 * database. See {@link FcCrud.retrievePointing} for query information.
 * <p>
 * The roll is relative to ra_dec_2_pix's nominal expected pointing.
 * 
 * @author Forrest Girouard
 * @author Kester
 * 
 */
@Entity
@Table(name = "FC_POINTING")
public class Pointing {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "FC_POINTING_SEQ")
    private long id;
    private double mjd;
    private double ra;
    private double declination;
    private double roll;
    private double segmentStartMjd;

    /*
     * No-op default constructor (package-level to avoid being run) for
     * Hibernate
     */
    Pointing() {
    }

    public Pointing(double mjd, double ra, double declination, double roll,
        double segment) {
        this.mjd = mjd;
        this.ra = ra;
        this.declination = declination;
        this.roll = roll;
        this.segmentStartMjd = segment;
    }

    @Override
    public String toString() {
        return "pointing at MJD: " + getMjd() + " is: (" + getRa() + ", "
            + getDeclination() + ", " + getRoll() + ", " + getSegmentStartMjd()
            + ")";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(declination);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(mjd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(ra);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(roll);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(segmentStartMjd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
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
        if (!(obj instanceof Pointing)) {
            return false;
        }
        Pointing other = (Pointing) obj;
        if (Double.doubleToLongBits(declination) != Double.doubleToLongBits(other.declination)) {
            return false;
        }
        if (Double.doubleToLongBits(mjd) != Double.doubleToLongBits(other.mjd)) {
            return false;
        }
        if (Double.doubleToLongBits(ra) != Double.doubleToLongBits(other.ra)) {
            return false;
        }
        if (Double.doubleToLongBits(roll) != Double.doubleToLongBits(other.roll)) {
            return false;
        }
        if (Double.doubleToLongBits(segmentStartMjd) != Double.doubleToLongBits(other.segmentStartMjd)) {
            return false;
        }
        return true;
    }

    public double getMjd() {
        return mjd;
    }

    public void setMjd(double mjd) {
        this.mjd = mjd;
    }

    public double getRa() {
        return ra;
    }

    public void setRa(double ra) {
        this.ra = ra;
    }

    public double getDeclination() {
        return declination;
    }

    public void setDeclination(double declination) {
        this.declination = declination;
    }

    public double getRoll() {
        return roll;
    }

    public void setRoll(double roll) {
        this.roll = roll;
    }

    public double getSegmentStartMjd() {
        return segmentStartMjd;
    }

    public void setSegmentStartMjd(double segmentStartMjd) {
        this.segmentStartMjd = segmentStartMjd;
    }
}
