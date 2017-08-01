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
import gov.nasa.kepler.common.CollateralType;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * Models a gap of a collateral pixel.
 * 
 * Pixel gaps are only reported for partial targets, if the whole target is
 * missing, there will only be a GapTarget record.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
@Entity
@Table(name = "DR_GAP_COL_PIXEL")
public class GapCollateralPixel /* extends GapTarget */{

    /**
     * This flag is used in the {@code ccdRowOrColumn} field to mean that all
     * collateral pixels of this type are missing.
     */
    public static final int ALL_PIXELS_FLAG = -1;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DR_GAP_COL_PIXEL_SEQ")
    private long id;

    private int cadenceNumber;
    private CadenceType cadenceType;
    private int ccdModule;
    private int ccdOutput;
    private CollateralType pixelType;
    private int ccdRowOrColumn; // see ALL_PIXELS_FLAG

    GapCollateralPixel() {
    }

    public GapCollateralPixel(int cadenceNumber, CadenceType cadenceType,
        int ccdModule, int ccdOutput, CollateralType pixelType,
        int ccdRowOrColumn) {
        super();
        this.cadenceNumber = cadenceNumber;
        this.cadenceType = cadenceType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.pixelType = pixelType;
        this.ccdRowOrColumn = ccdRowOrColumn;
    }

    public int getCadenceNumber() {
        return cadenceNumber;
    }

    public void setCadenceNumber(int cadenceNumber) {
        this.cadenceNumber = cadenceNumber;
    }

    public CadenceType getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public int getCcdRowOrColumn() {
        return ccdRowOrColumn;
    }

    public void setCcdRowOrColumn(int ccdRowOrColumn) {
        this.ccdRowOrColumn = ccdRowOrColumn;
    }

    public CollateralType getPixelType() {
        return pixelType;
    }

    public void setPixelType(CollateralType pixelType) {
        this.pixelType = pixelType;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + cadenceNumber;
        result = prime * result
            + (cadenceType == null ? 0 : cadenceType.hashCode());
        result = prime * result + ccdModule;
        result = prime * result + ccdOutput;
        result = prime * result + ccdRowOrColumn;
        result = prime * result
            + (pixelType == null ? 0 : pixelType.hashCode());
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
        final GapCollateralPixel other = (GapCollateralPixel) obj;
        if (cadenceNumber != other.cadenceNumber) {
            return false;
        }
        if (cadenceType == null) {
            if (other.cadenceType != null) {
                return false;
            }
        } else if (!cadenceType.equals(other.cadenceType)) {
            return false;
        }
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (ccdRowOrColumn != other.ccdRowOrColumn) {
            return false;
        }
        if (pixelType == null) {
            if (other.pixelType != null) {
                return false;
            }
        } else if (!pixelType.equals(other.pixelType)) {
            return false;
        }
        return true;
    }

}
