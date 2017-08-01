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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.spiffy.common.persistable.Persistable;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Data for invalid (hot, dead, etc.) pixels identified by PA.
 * 
 * @author Forrest Girouard (fgirouard@arc.nasa.gov)
 * 
 */
public class BadPixel implements Persistable {

    private int ccdRow;
    private int ccdColumn;
    private double startMjd;
    private double endMjd;
    
    /**
     * See {@code PixelType}.
     */
    private String type = "";
    
    /**
     * See KADN-26176.
     */
    private double value;

    public BadPixel() {
    }

    public BadPixel(Pixel pixel) {
        this.ccdRow = pixel.getCcdRow();
        this.ccdColumn = pixel.getCcdColumn();
        this.type = pixel.getType().toString();
        this.startMjd = pixel.getStartTime();
        this.endMjd = pixel.getEndTime();
        this.value = pixel.getPixelValue();
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdColumn;
        result = PRIME * result + ccdRow;
        long temp;
        temp = Double.doubleToLongBits(value);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(startMjd);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(endMjd);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        result = PRIME * result + ((type == null) ? 0 : type.hashCode());
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
        final BadPixel other = (BadPixel) obj;
        if (ccdColumn != other.ccdColumn)
            return false;
        if (ccdRow != other.ccdRow)
            return false;
        if (Double.doubleToLongBits(value) != Double.doubleToLongBits(other.value))
            return false;
        if (Double.doubleToLongBits(startMjd) != Double.doubleToLongBits(other.startMjd))
            return false;
        if (Double.doubleToLongBits(endMjd) != Double.doubleToLongBits(other.endMjd))
            return false;
        if (type == null) {
            if (other.type != null)
                return false;
        } else if (!type.equals(other.type))
            return false;
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
    
    public Pixel getPixel() {
        Pixel pixel = new Pixel(ccdRow, ccdColumn, PixelType.valueOf(type));
        pixel.setStartTime(startMjd);
        pixel.setEndTime(endMjd);
        pixel.setPixelValue(value);
        return pixel;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public int getCcdRow() {
        return ccdRow;
    }

    public double getValue() {
        return value;
    }

    public double getStartMjd() {
        return startMjd;
    }

    public double getEndMjd() {
        return endMjd;
    }

    public String getType() {
        return type;
    }

    public void setCcdColumn(int ccdColumn) {
        this.ccdColumn = ccdColumn;
    }

    public void setCcdRow(int ccdRow) {
        this.ccdRow = ccdRow;
    }

    public void setValue(double pixelValue) {
        this.value = pixelValue;
    }

    public void setStartMjd(double startTime) {
        this.startMjd = startTime;
    }

    public void setEndMjd(double stopTime) {
        this.endMjd = stopTime;
    }

    public void setType(String type) {
        this.type = type;
    }

}
