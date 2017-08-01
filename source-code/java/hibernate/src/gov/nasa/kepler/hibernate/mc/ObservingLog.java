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

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;


/**
 * This database table contains information about the observing
 * intervals of the mission, including quarterly, monthly, and target table 
 * boundaries with their associated cadence and mjd boundaries.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
@Entity
@Table(name = "MC_OBS_LOG")
public class ObservingLog {
    
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_OBSLOG_SEQ")
    private long id;

    private int quarter = -1;
    private int month = -1;
    private int season = -1;
    
    private int cadenceType = -1;

    private int cadenceStart = -1;
    private int cadenceEnd = -1;
    
    private double mjdStart = -1.0;
    private double mjdEnd = -1.0;

    private int targetTableId = -1;
    
    public ObservingLog() {
    }

    public ObservingLog(int cadenceType, int cadenceStart, int cadenceEnd, double mjdStart, double mjdEnd,
        int quarter, int month, int season, int targetTableId) {
        this.cadenceType = cadenceType;
        this.cadenceStart = cadenceStart;
        this.cadenceEnd = cadenceEnd;
        this.mjdStart = mjdStart;
        this.mjdEnd = mjdEnd;
        this.quarter = quarter;
        this.month = month;
        this.season = season;
        this.targetTableId = targetTableId;
    }

    public boolean matches(int cadenceType, int cadenceStart, int cadenceEnd){
        return((this.cadenceType == cadenceType) 
            && (cadenceStart >= this.cadenceStart 
                && cadenceStart <= this.cadenceEnd 
                || cadenceEnd >= this.cadenceStart 
                && cadenceEnd <= this.cadenceEnd));
    }
    
    public int getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(int cadenceType) {
        this.cadenceType = cadenceType;
    }

    public int getCadenceStart() {
        return cadenceStart;
    }

    public void setCadenceStart(int cadenceStart) {
        this.cadenceStart = cadenceStart;
    }

    public int getCadenceEnd() {
        return cadenceEnd;
    }

    public void setCadenceEnd(int cadenceEnd) {
        this.cadenceEnd = cadenceEnd;
    }

    public double getMjdStart() {
        return mjdStart;
    }

    public void setMjdStart(double mjdStart) {
        this.mjdStart = mjdStart;
    }

    public double getMjdEnd() {
        return mjdEnd;
    }

    public void setMjdEnd(double mjdEnd) {
        this.mjdEnd = mjdEnd;
    }

    public int getQuarter() {
        return quarter;
    }

    public void setQuarter(int quarter) {
        this.quarter = quarter;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    public long getId() {
        return id;
    }

    public int getSeason() {
        return season;
    }

    public void setSeason(int season) {
        this.season = season;
    }

    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "ObservingLog [id=" + id + ", cadenceType=" + cadenceType + ", cadenceStart=" + cadenceStart
            + ", cadenceEnd=" + cadenceEnd + ", mjdStart=" + mjdStart + ", mjdEnd=" + mjdEnd + ", quarter=" + quarter
            + ", month=" + month + ", season=" + season + ", targetTableId=" + targetTableId + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + cadenceEnd;
        result = prime * result + cadenceStart;
        result = prime * result + cadenceType;
        long temp;
        temp = Double.doubleToLongBits(mjdEnd);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(mjdStart);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + month;
        result = prime * result + quarter;
        result = prime * result + season;
        result = prime * result + targetTableId;
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
        ObservingLog other = (ObservingLog) obj;
        if (cadenceEnd != other.cadenceEnd)
            return false;
        if (cadenceStart != other.cadenceStart)
            return false;
        if (cadenceType != other.cadenceType)
            return false;
        if (Double.doubleToLongBits(mjdEnd) != Double.doubleToLongBits(other.mjdEnd))
            return false;
        if (Double.doubleToLongBits(mjdStart) != Double.doubleToLongBits(other.mjdStart))
            return false;
        if (month != other.month)
            return false;
        if (quarter != other.quarter)
            return false;
        if (season != other.season)
            return false;
        if (targetTableId != other.targetTableId)
            return false;
        return true;
    }
}
