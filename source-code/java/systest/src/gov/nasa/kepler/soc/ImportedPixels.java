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

package gov.nasa.kepler.soc;

import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.dr.PixelLog;

import java.util.Arrays;
import java.util.List;

/**
 * Contains pixels.
 * 
 * @author Miles Cote
 * 
 */
public final class ImportedPixels {

    private final PixelLog pixelLog;
    private final byte[] pixelFitsBlob;
    private final List<List<IntTimeSeries>> timeSeriesLists;

    public ImportedPixels(PixelLog pixelLog, byte[] pixelFitsBlob,
        List<List<IntTimeSeries>> timeSeriesLists) {
        this.pixelLog = pixelLog;
        this.pixelFitsBlob = pixelFitsBlob;
        this.timeSeriesLists = timeSeriesLists;
    }

    @Override
    public String toString() {
        return "ImportedPixels [pixelLog=" + pixelLog + ", pixelFitsBlob="
            + pixelFitsBlob + ", timeSeriesLists=" + timeSeriesLists + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(pixelFitsBlob);
        result = prime * result
            + ((pixelLog == null) ? 0 : pixelLog.hashCode());
        result = prime * result
            + ((timeSeriesLists == null) ? 0 : timeSeriesLists.hashCode());
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
        ImportedPixels other = (ImportedPixels) obj;
        if (!Arrays.equals(pixelFitsBlob, other.pixelFitsBlob))
            return false;
        if (pixelLog == null) {
            if (other.pixelLog != null)
                return false;
        } else if (!pixelLog.equals(other.pixelLog))
            return false;
        if (timeSeriesLists == null) {
            if (other.timeSeriesLists != null)
                return false;
        } else if (!timeSeriesLists.equals(other.timeSeriesLists))
            return false;
        return true;
    }

    public PixelLog getPixelLog() {
        return pixelLog;
    }

    public byte[] getPixelFitsBlob() {
        return pixelFitsBlob;
    }

    public List<List<IntTimeSeries>> getTimeSeriesLists() {
        return timeSeriesLists;
    }

}
