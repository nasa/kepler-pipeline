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

package gov.nasa.kepler.mc.pa;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.util.Map;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * PA pixel time series.
 * 
 * @author Forrest Girouard
 * 
 */
public class PaPixelTimeSeries extends CompoundFloatTimeSeries {

    /**
     * Row of this pixel in CCD coordinates.
     */
    private int ccdRow;

    /**
     * Column of this pixel in CCD coordinates.
     */
    private int ccdColumn;

    /**
     * True when pixel is in optimal aperture.
     */
    private boolean inOptimalAperture;

    public PaPixelTimeSeries() {
        super();
    }

    public PaPixelTimeSeries(final int row, final int column,
        final boolean inOptimalAperture) {
        super();
        ccdRow = row;
        ccdColumn = column;
        this.inOptimalAperture = inOptimalAperture;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + ccdColumn;
        result = prime * result + ccdRow;
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        PaPixelTimeSeries other = (PaPixelTimeSeries) obj;
        if (ccdColumn != other.ccdColumn) {
            return false;
        }
        if (ccdRow != other.ccdRow) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("ccdRow", ccdRow)
            .append("ccdColumn", ccdColumn)
            .append("isInOptimalAperture", inOptimalAperture)
            .appendSuper(super.toString())
            .toString();
    }

    public void setAllTimeSeries(final TargetType type, final int ccdModule,
        final int ccdOutput, final Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        FsId fsId = CalFsIdFactory.getTimeSeriesFsId(
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, type, ccdModule,
            ccdOutput, getCcdRow(), getCcdColumn());

        FloatTimeSeries timeSeries = timeSeriesByFsId.get(fsId);
        if (timeSeries != null) {
            setValues(timeSeries.fseries());
            setGapIndicators(timeSeries.getGapIndicators());

            // If this pixel is in the optimal aperture, then it can remain in
            // the optimal aperture as long as its timeseries exists.
            if (inOptimalAperture) {
                inOptimalAperture = timeSeries.exists();
            }

            fsId = CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, type,
                ccdModule, ccdOutput, getCcdRow(), getCcdColumn());
            timeSeries = timeSeriesByFsId.get(fsId);
            if (timeSeries != null) {
                setUncertainties(timeSeries.fseries());
            }
        }
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public boolean isInOptimalAperture() {
        return inOptimalAperture;
    }

    public int getCcdRow() {
        return ccdRow;
    }
}
