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

package gov.nasa.kepler.dv.io;

import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatMjdTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Data for a single pixel.
 * 
 * @author Forrest Girouard
 */
public class DvPixelData implements Persistable {

    private CompoundFloatTimeSeries calibratedTimeSeries = new CompoundFloatTimeSeries();
    private int ccdColumn;
    private int ccdRow;
    private SimpleFloatMjdTimeSeries cosmicRayEvents = new SimpleFloatMjdTimeSeries();
    private boolean inOptimalAperture;

    /**
     * Creates a {@link DvPixelData}. For use only by mock objects and
     * Hibernate.
     */
    public DvPixelData() {
    }

    /**
     * Creates a new {@link DvPixelData} object.
     */
    public DvPixelData(int ccdRow, int ccdColumn, boolean inOptimalAperture,
        CompoundFloatTimeSeries calibratedTimeSeries,
        SimpleFloatMjdTimeSeries cosmicRayEvents) {

        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.inOptimalAperture = inOptimalAperture;
        this.calibratedTimeSeries = calibratedTimeSeries;
        this.cosmicRayEvents = cosmicRayEvents;
    }

    public CompoundFloatTimeSeries getCalibratedTimeSeries() {
        return calibratedTimeSeries;
    }

    public SimpleFloatMjdTimeSeries getCosmicRayEvents() {
        return cosmicRayEvents;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public int getCcdRow() {
        return ccdRow;
    }

    public boolean isInOptimalAperture() {
        return inOptimalAperture;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ccdColumn;
        result = prime * result + ccdRow;
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
        if (!(obj instanceof DvPixelData)) {
            return false;
        }
        DvPixelData other = (DvPixelData) obj;
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
        return String.format("(%d,%d)", ccdRow, ccdColumn);
    }
}
