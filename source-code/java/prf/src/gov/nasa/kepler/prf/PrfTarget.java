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
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * 
 * @author Forrest Girouard
 * 
 */
public class PrfTarget implements Persistable {

    /**
     * The Kepler ID for this centroid's target (directly from the KIC).
     */
    int keplerId;

    /**
     * The magnitude of this target (directly from the KIC)
     */
    float keplerMag;

    /**
     * The right ascension for this target in hours (directly from the KIC).
     */
    private double ra;

    /**
     * The declination of this target in degrees (directly from the KIC).
     */
    private double dec;

    /**
     * The row relative to which the pixels in the target are located, typically
     * the row of the target centroid.
     */
    private int referenceRow;

    /**
     * The column relative to which the pixels in the target are located,
     * typically the column of the target centroid.
     */
    private int referenceColumn;

    /**
     * The index of pixels in the target for which no data is available.
     */
    private int[] gapIndices;
    
    private float tadCrowdingMetric;
    
    private float fluxFractionInAperture;
    

    /**
     * List containing one time series per pixel in target.
     */
    private List<PrfPixelTimeSeries> pixelTimeSeriesStruct;

    public PrfTarget() {
    }

    public PrfTarget(int keplerId, float keplerMag, double ra, double dec,
        int referenceRow, int referenceColumn, float tadCrowdingMetirc, 
        float fluxFractionInAperture) {
        this.keplerId = keplerId;
        this.keplerMag = keplerMag;
        this.ra = ra;
        this.dec = dec;
        this.referenceRow = referenceRow;
        this.referenceColumn = referenceColumn;
        this.fluxFractionInAperture = fluxFractionInAperture;
        this.tadCrowdingMetric = tadCrowdingMetirc;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + keplerId;
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
        final PrfTarget other = (PrfTarget) obj;
        if (keplerId != other.keplerId)
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("keplerId", keplerId)
            .append("keplerMag", keplerMag)
            .append("ra", ra)
            .append("dec", dec)
            .append("referenceRow", referenceRow)
            .append("referenceColumn", referenceColumn)
            .append("pixelTimesSeriesStruct.size",
                pixelTimeSeriesStruct.size())
            .append("gapIndices.length", gapIndices.length)
            .toString();
    }

    public List<FsId> getAllTimeSeriesFsIds(int ccdModule, int ccdOutput) {

        List<FsId> fsIds = new ArrayList<FsId>();

        for (PrfPixelTimeSeries pixel : getPrfPixelTimeSeries()) {
            fsIds.addAll(pixel.getAllTimeSeriesFsIds(ccdModule, ccdOutput));
        }
        return fsIds;
    }

    public void setAllTimeSeries(int ccdModule, int ccdOutput, int startCadence, int endCadence, 
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        for (PrfPixelTimeSeries pixel : getPrfPixelTimeSeries()) {
            pixel.setAllTimeSeries(ccdModule, ccdOutput, timeSeriesByFsId);
        }
        
        setGapIndices(startCadence, endCadence);
    }

    // accessors

    public double getDec() {
        return dec;
    }

    public int[] getGapIndices() {
        return gapIndices;
    }

    private void setGapIndices(int[] gapIndices) {
        this.gapIndices = gapIndices;
    }

    public List<PrfPixelTimeSeries> getPrfPixelTimeSeries() {
        return pixelTimeSeriesStruct;
    }

    public void setPrfPixelTimeSeries(
        List<PrfPixelTimeSeries> prfPixelTimeSeries) {

        this.pixelTimeSeriesStruct = prfPixelTimeSeries;
    }
    
    private void setGapIndices(int startCadence, int endCadence) {
        
        int[] pixelGaps = new int[endCadence - startCadence + 1];
        int targetGaps = 0;
        for (PrfPixelTimeSeries pixel : getPrfPixelTimeSeries()) {
            if (pixel.getGapIndices() != null
                && pixel.getGapIndices().length > 0) {
                for (int gapIndex : pixel.getGapIndices()) {
                    pixelGaps[gapIndex]++;
                    if (pixelGaps[gapIndex] == getPrfPixelTimeSeries().size()) {
                        targetGaps++;
                    }
                }
            }
        }
        int[] gapIndices = new int[targetGaps];
        int gap = 0;
        for (int gapIndex = 0; gapIndex < pixelGaps.length; gapIndex++) {
            if (pixelGaps[gapIndex] == getPrfPixelTimeSeries().size()) {
                gapIndices[gap++] = gapIndex;
            }
        }
        setGapIndices(gapIndices);
    }

    public int getKeplerId() {
        return keplerId;
    }

    public float getKeplerMag() {
        return keplerMag;
    }

    public double getRa() {
        return ra;
    }

    public int getReferenceColumn() {
        return referenceColumn;
    }

    public int getReferenceRow() {
        return referenceRow;
    }
}
