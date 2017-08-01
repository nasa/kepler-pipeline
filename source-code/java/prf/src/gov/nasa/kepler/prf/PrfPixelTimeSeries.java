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

package gov.nasa.kepler.prf;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Per pixel time series.
 * 
 * @author Forrest Girouard
 * 
 */
public class PrfPixelTimeSeries extends PrfTimeSeries implements Persistable {

    /**
     * Row of this pixel in CCD coordinates.
     */
    private int row;

    /**
     * Column of this pixel in CCD coordinates.
     */
    private int column;

    /**
     * True when pixel is in optimal aperture.
     */
    private boolean isInOptimalAperture;

    public PrfPixelTimeSeries() {
    }

    public PrfPixelTimeSeries(int row, int column, boolean isInOptimalAperture) {
        
        this.row = row;
        this.column = column;
        this.isInOptimalAperture = isInOptimalAperture;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + column;
        result = PRIME * result + row;
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
        final PrfPixelTimeSeries other = (PrfPixelTimeSeries) obj;
        if (column != other.column)
            return false;
        if (row != other.row)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("row", row)
            .append("column", column)
            .append("isInOptimalAperture", isInOptimalAperture)
            .toString();
    }

    public List<FsId> getAllTimeSeriesFsIds(int ccdModule,
        int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();
        fsIds.add(CalFsIdFactory.getTimeSeriesFsId(
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, TargetType.LONG_CADENCE, ccdModule,
            ccdOutput, getRow(), getColumn()));
        fsIds.add(CalFsIdFactory.getTimeSeriesFsId(
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, TargetType.LONG_CADENCE,
            ccdModule, ccdOutput, getRow(), getColumn()));
        return fsIds;
    }

    public void setAllTimeSeries(int ccdModule, int ccdOutput,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = CalFsIdFactory.getTimeSeriesFsId(
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, TargetType.LONG_CADENCE, ccdModule,
            ccdOutput, getRow(), getColumn());

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            fsId = CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, TargetType.LONG_CADENCE,
                ccdModule, ccdOutput, getRow(), getColumn());
            FloatTimeSeries uncertainties = timeSeriesByFsId.get(fsId);
            setAll(timeSeries.fseries(),
                uncertainties != null ? uncertainties.fseries()
                    : new float[timeSeries.fseries().length],
                timeSeries.getGapIndices());
        }
    }

    public int getColumn() {
        return column;
    }

    public void setColumn(int column) {
        this.column = column;
    }

    public boolean isInOptimalAperture() {
        return isInOptimalAperture;
    }

    public void setInOptimalAperture(boolean isInOptimalAperture) {
        this.isInOptimalAperture = isInOptimalAperture;
    }

    public int getRow() {
        return row;
    }

    public void setRow(int row) {
        this.row = row;
    }
}
