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

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

@Entity
@Table(name = "FC_PIXEL")
public class Pixel {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "FC_PIXEL_SEQ")
    private long id;

    private int ccdModule;
    private int ccdOutput;
    private int ccdRow;
    private int ccdColumn;
    private PixelType type;
    private double startTime;
    private double endTime;
    private double pixelValue;
    
    @SuppressWarnings("unused")
    private Pixel() {
    }

    public Pixel(PixelType type) {
        // Note that we're using Float.MAX_VALUE since Double.MAX_VALUE is too
        // large for Oracle.
        this(0, 0, -1, -1, type, 0, Float.MAX_VALUE, 0.0);
    }

    /**
     * Copy constructor:
     * 
     * @param in
     */
    public Pixel(Pixel in) {
        this(in.getCcdModule(), in.getCcdOutput(), in.getCcdRow(),
            in.getCcdColumn(), in.getType(), in.getStartTime(),
            in.getEndTime(), in.getPixelValue());
    }

    /**
     * The values String array must contain:
     * 
     * MJD MODULE OUTPUT ROW COLUMN TYPE VALUE
     * 
     * where MJD and value are doubles, type is a string, and module, output,
     * row, and column are integers.
     */
    public Pixel(String[] values) {
        if (values.length != 7 && values.length != 8) {
            throw new IllegalArgumentException("Wrong number of fields");
        }

        int i = 0;
        setStartTime(Double.parseDouble(values[i++]));
        if (values.length == 7) {
            setEndTime(Float.MAX_VALUE);
        } else {
            setEndTime(Double.parseDouble(values[i++]));
        }
        setCcdModule(Integer.parseInt(values[i++]));
        setCcdOutput(Integer.parseInt(values[i++]));
        setCcdRow(Integer.parseInt(values[i++]));
        setCcdColumn(Integer.parseInt(values[i++]));
        setType(PixelType.valueOf(values[i++].toUpperCase()));
        setPixelValue(Double.parseDouble(values[i++]));
    }

    public Pixel(PixelType type, double startTime) {
        this(0, 0, -1, -1, type, startTime, Float.MAX_VALUE, 0.0);
    }

    public Pixel(PixelType type, double startTime, double endTime) {
        this(0, 0, -1, -1, type, startTime, endTime, 0.0);
    }

    public Pixel(int ccdRow, int ccdColumn, PixelType type) {
        this(0, 0, ccdRow, ccdColumn, type, 0, Float.MAX_VALUE, 0.0);
    }

    public Pixel(int ccdModule, int ccdOutput, int ccdRow, int ccdColumn,
        PixelType type) {
        this(ccdModule, ccdOutput, ccdRow, ccdColumn, type, 0, Float.MAX_VALUE,
            0.0);
    }

    public Pixel(int ccdModule, int ccdOutput, int ccdRow, int ccdColumn,
        PixelType type, double startTime, double endTime) {
        this(ccdModule, ccdOutput, ccdRow, ccdColumn, type, startTime, endTime,
            0.0);
    }

    /**
     * Pixel constructor requiring specification of each element.
     * 
     * @param ccdModule The pixel's ccdModule (2-24, excluding 5 and 21).
     * @param ccdOutput The pixel's ccdOutput (1-4).
     * @param ccdRow The pixel's ccdRow.
     * @param ccdColumn The pixel's ccdColumn.
     * @param type Type type of pixel. See above.
     * @param startTime A java.util.Date defining the start time.
     * @param endTime A java.util.Date defining the stop time.
     * @param pixelValue The pixelValue of the pixel.
     */
    public Pixel(int ccdModule, int ccdOutput, int ccdRow, int ccdColumn,
        PixelType type, double startTime, double endTime, double pixelValue) {

        setCcdModule(ccdModule);
        setCcdOutput(ccdOutput);
        setCcdRow(ccdRow);
        setCcdColumn(ccdColumn);
        setType(type);
        setStartTime(startTime);
        setEndTime(endTime);
        setPixelValue(pixelValue);
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

    public int getCcdRow() {
        return ccdRow;
    }

    public void setCcdRow(int ccdRow) {
        this.ccdRow = ccdRow;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public void setCcdColumn(int ccdColumn) {
        this.ccdColumn = ccdColumn;
    }

    public PixelType getType() {
        return type;
    }

    public void setType(PixelType type) {
        this.type = type;
    }

    public double getStartTime() {
        return startTime;
    }

    public void setStartTime(double startTime) {
        this.startTime = startTime;
    }

    public double getEndTime() {
        return endTime;
    }

    public void setEndTime(double endTime) {
        this.endTime = endTime;
    }

    public double getPixelValue() {
        return pixelValue;
    }

    public void setPixelValue(double pixelValue) {
        this.pixelValue = pixelValue;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdColumn;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + ccdRow;
        result = PRIME * result + (int) startTime;
        result = PRIME * result + (int) endTime;
        result = PRIME * result + (type == null ? 0 : type.hashCode());
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
        final Pixel other = (Pixel) obj;
        if (ccdColumn != other.ccdColumn) {
            return false;
        }
        if (ccdModule != other.ccdModule) {
            return false;
        }
        if (ccdOutput != other.ccdOutput) {
            return false;
        }
        if (ccdRow != other.ccdRow) {
            return false;
        }
        if (startTime != other.startTime) {
            return false;
        }
        if (endTime != other.endTime) {
            return false;
        }
        if (type == null) {
            if (other.type != null) {
                return false;
            }
        } else if (!type.equals(other.type)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    // public String regionString(String pointType) {
    // return regionString(pointType, getType());
    // }
    //
    // public String regionString(String pointType, String group) {
    // String color = PixelType2Color.get(getType());
    // String region = "box(" + getCcdRow() + "," + getCcdColumn() + ",1,1)"
    // + " # point=" + pointType + " width=3 color=" + color + " tag={"
    // + group + "}";
    // return region;
    // }

    /**
     * Generates a region string for a pixel in a group.
     * 
     * @param pointType
     * @param group
     * @param bSkipOr
     * @return a non-{@code null} string.
     */
    public String regionCompositeString(String pointType, String group,
        boolean bSkipOr) {
        String reg = "box(" + getCcdRow() + "," + getCcdColumn() + ",1,1)"
            + (bSkipOr ? "" : " || ");
        return reg;
    }

}
