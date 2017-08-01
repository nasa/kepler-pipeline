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
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * Models a gap of a pixel.
 * 
 * Pixel gaps are only reported for partial targets, if the whole target is
 * missing, there will only be a GapTarget record.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@Entity
@Table(name = "DR_GAP_PIXEL")
public class GapPixel /* extends GapTarget */{

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_GAP_PIXEL_SEQ")
    private long id;

    private int cadenceNumber;
    private CadenceType cadenceType;
    private int ccdModule;
    private int ccdOutput;
    private TargetType targetTableType;
    private int targetIndex;
    private int keplerId;
    private int ccdRow;
    private int ccdColumn;

    GapPixel() {
    }

    public GapPixel(int cadenceNumber, CadenceType cadenceType, int ccdModule,
        int ccdOutput, TargetType targetTableType, int keplerId,
        int targetIndex, int ccdRow, int ccdColumn) {
        super();
        this.cadenceNumber = cadenceNumber;
        this.cadenceType = cadenceType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.targetTableType = targetTableType;
        this.keplerId = keplerId;
        this.targetIndex = targetIndex;
        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
    }

    /**
     * @return the cadenceNumber
     */
    public int getCadenceNumber() {
        return cadenceNumber;
    }

    /**
     * @param cadenceNumber the cadenceNumber to set
     */
    public void setCadenceNumber(int cadenceNumber) {
        this.cadenceNumber = cadenceNumber;
    }

    /**
     * @return the cadenceType
     */
    public CadenceType getCadenceType() {
        return cadenceType;
    }

    /**
     * @param cadenceType the cadenceType to set
     */
    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType;
    }

    /**
     * @return the ccdModule
     */
    public int getCcdModule() {
        return ccdModule;
    }

    /**
     * @param ccdModule the ccdModule to set
     */
    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    /**
     * @return the ccdOutput
     */
    public int getCcdOutput() {
        return ccdOutput;
    }

    /**
     * @param ccdOutput the ccdOutput to set
     */
    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public TargetType getTargetTableType() {
        return targetTableType;
    }

    public void setTargetTableType(TargetType targetTableType) {
        this.targetTableType = targetTableType;
    }

    /**
     * @return the targetIndex
     */
    public int getTargetIndex() {
        return targetIndex;
    }

    /**
     * @param targetIndex the targetIndex to set
     */
    public void setTargetIndex(int targetIndex) {
        this.targetIndex = targetIndex;
    }

    public int getKeplerId() {
        return keplerId;
    }

    /**
     * @return the ccdColumn
     */
    public int getCcdColumn() {
        return ccdColumn;
    }

    /**
     * @param ccdColumn the ccdColumn to set
     */
    public void setCcdColumn(int ccdColumn) {
        this.ccdColumn = ccdColumn;
    }

    /**
     * @return the ccdRow
     */
    public int getCcdRow() {
        return ccdRow;
    }

    /**
     * @param ccdRow the ccdRow to set
     */
    public void setCcdRow(int ccdRow) {
        this.ccdRow = ccdRow;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + cadenceNumber;
        result = PRIME * result + cadenceType.ordinal();
        result = PRIME * result + ccdColumn;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + ccdRow;
        result = PRIME * result + targetIndex;
        result = PRIME * result
            + ((targetTableType == null) ? 0 : targetTableType.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (getClass() != obj.getClass())
            return false;
        final GapPixel other = (GapPixel) obj;
        if (cadenceNumber != other.cadenceNumber)
            return false;
        if (cadenceType != other.cadenceType)
            return false;
        if (ccdColumn != other.ccdColumn)
            return false;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (ccdRow != other.ccdRow)
            return false;
        if (targetIndex != other.targetIndex)
            return false;
        if (targetTableType == null) {
            if (other.targetTableType != null)
                return false;
        } else if (!targetTableType.equals(other.targetTableType))
            return false;
        return true;
    }
}
