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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.common.Cadence.CadenceType;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * This class maps a {@link DataAnomalyType} to the cadence range that it
 * affects.
 * 
 * @author Miles Cote
 * 
 */
@Entity
@Table(name = "DR_DATA_ANOMALY")
public class DataAnomaly {

    public static enum DataAnomalyType {
        ATTITUDE_TWEAK,
        SAFE_MODE,
        COARSE_POINT,
        ARGABRIGHTENING,
        EXCLUDE,
        EARTH_POINT,
        PLANET_SEARCH_EXCLUDE;
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_DATA_ANOMALY_SEQ")
    private long id;

    private DataAnomalyType dataAnomalyType;
    private int cadenceType;
    private int startCadence;
    private int endCadence;

    private int revision = 0;

    DataAnomaly() {
    }

    public DataAnomaly(DataAnomalyType dataAnomalyType, int cadenceType,
        int startCadence, int endCadence) {
        this.dataAnomalyType = dataAnomalyType;
        this.cadenceType = cadenceType;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    /**
     * Copy Constructor
     * 
     * @param other
     */
    public DataAnomaly(DataAnomaly other) {
        this.dataAnomalyType = other.dataAnomalyType;
        this.cadenceType = other.cadenceType;
        this.startCadence = other.startCadence;
        this.endCadence = other.endCadence;
        this.revision = other.revision;
    }

    @Override
    public String toString() {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("[");
        stringBuilder.append(dataAnomalyType);
        stringBuilder.append(", ");
        stringBuilder.append(CadenceType.valueOf(cadenceType));
        stringBuilder.append(" CADENCE, ");
        stringBuilder.append("cadenceRange=");
        stringBuilder.append(startCadence);
        stringBuilder.append(":");
        stringBuilder.append(endCadence);
        stringBuilder.append(", r=");
        stringBuilder.append(revision);
        stringBuilder.append("]");

        return stringBuilder.toString();
    }

    public long getId() {
        return id;
    }

    public DataAnomalyType getDataAnomalyType() {
        return dataAnomalyType;
    }

    public void setDataAnomalyType(DataAnomalyType dataAnomalyType) {
        this.dataAnomalyType = dataAnomalyType;
    }

    public int getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(int cadenceType) {
        this.cadenceType = cadenceType;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public int getRevision() {
        return revision;
    }

    public void setRevision(int revision) {
        this.revision = revision;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#hashCode()
     */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + cadenceType;
        result = prime * result
            + ((dataAnomalyType == null) ? 0 : dataAnomalyType.hashCode());
        result = prime * result + endCadence;
        result = prime * result + revision;
        result = prime * result + startCadence;
        return result;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        DataAnomaly other = (DataAnomaly) obj;
        if (cadenceType != other.cadenceType)
            return false;
        if (dataAnomalyType == null) {
            if (other.dataAnomalyType != null)
                return false;
        } else if (!dataAnomalyType.equals(other.dataAnomalyType))
            return false;
        if (endCadence != other.endCadence)
            return false;
        if (revision != other.revision)
            return false;
        if (startCadence != other.startCadence)
            return false;
        return true;
    }
}
