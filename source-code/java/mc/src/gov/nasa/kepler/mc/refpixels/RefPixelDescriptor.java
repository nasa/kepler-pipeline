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

package gov.nasa.kepler.mc.refpixels;

import gov.nasa.kepler.mc.fs.DrFsIdFactory.TimeSeriesType;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Contains all the metadata necessary to uniquely identify a reference pixel.
 * 
 * @author Forrest Girouard
 * @author Todd Klaus
 * 
 */
public class RefPixelDescriptor {

    protected TimeSeriesType timeSeriesType;
    protected int ccdModule;
    protected int ccdOutput;
    protected int ccdRow;
    protected int ccdColumn;
    private int targetTableExternalId;

    /**
     * Basic constructor.
     * 
     * @param targetTableExternalId
     * @param ccdModule
     * @param ccdOutput
     * @param ccdRow
     * @param ccdColumn
     */
    public RefPixelDescriptor(int targetTableExternalId, int ccdModule,
        int ccdOutput, int ccdRow, int ccdColumn) {

        this.timeSeriesType = TimeSeriesType.REF_PIXEL;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.targetTableExternalId = targetTableExternalId;
    }

    /**
     * Copy constructor.
     * 
     * @param otherPixelDescriptor
     */
    public RefPixelDescriptor(RefPixelDescriptor otherPixelDescriptor) {
        this(otherPixelDescriptor.targetTableExternalId,
            otherPixelDescriptor.ccdModule, otherPixelDescriptor.ccdOutput,
            otherPixelDescriptor.ccdRow, otherPixelDescriptor.ccdColumn);
    }

    @Override
    public RefPixelDescriptor clone() {
        return new RefPixelDescriptor(this);
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public void setCcdColumn(int ccdColumn) {
        this.ccdColumn = ccdColumn;
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

    public int getTargetTableExternalId() {
        return targetTableExternalId;
    }

    public void setTargetTableExternalId(int targetTableExternalId) {
        this.targetTableExternalId = targetTableExternalId;
    }

    public TimeSeriesType getTimeSeriesType() {
        return timeSeriesType;
    }

    public void setTimeSeriesType(TimeSeriesType timeSeriesType) {
        this.timeSeriesType = timeSeriesType;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ccdColumn;
        result = PRIME * result + ccdModule;
        result = PRIME * result + ccdOutput;
        result = PRIME * result + ccdRow;
        result = PRIME * result + targetTableExternalId;
        result = PRIME * result
            + ((timeSeriesType == null) ? 0 : timeSeriesType.hashCode());
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
        final RefPixelDescriptor other = (RefPixelDescriptor) obj;
        if (ccdColumn != other.ccdColumn)
            return false;
        if (ccdModule != other.ccdModule)
            return false;
        if (ccdOutput != other.ccdOutput)
            return false;
        if (ccdRow != other.ccdRow)
            return false;
        if (targetTableExternalId != other.targetTableExternalId)
            return false;
        if (timeSeriesType == null) {
            if (other.timeSeriesType != null)
                return false;
        } else if (!timeSeriesType.equals(other.timeSeriesType))
            return false;
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
