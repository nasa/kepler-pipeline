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

package gov.nasa.kepler.systest.validation;

import gov.nasa.spiffy.common.collect.Pair;

import java.util.*;

/**
 * Target aperture.
 * 
 * @author Forrest Girouard
 */
public class FitsAperture {

    private Map<Pair<Integer, Integer>, AperturePixel> pixelsByOffset = new HashMap<Pair<Integer, Integer>, AperturePixel>();

    public FitsAperture() {
    }

    public void addPixel(Pair<Integer, Integer> offset, AperturePixel pixel) {
        pixelsByOffset.put(offset, pixel);
    }

    public AperturePixel getPixel(Pair<Integer, Integer> offset) {
        return pixelsByOffset.get(offset);
    }

    public Set<AperturePixel> getPixels() {
        Set<AperturePixel> pixels = new HashSet<AperturePixel>();
        pixels.addAll(pixelsByOffset.values());
        return pixels;
    }

    
    /**
     * 
     * @param other non-null
     * @return A list of differences.  If none are found then this returns an
     * empty list.
     */
    public List<String> diff(FitsAperture other) {
        List<String> d = new ArrayList<String>();
        
        for (Map.Entry<Pair<Integer, Integer>, AperturePixel> pixel : pixelsByOffset.entrySet()) {
            Pair<Integer, Integer> pixelCoordinate = pixel.getKey();
            AperturePixel otherAperturePixel = other.pixelsByOffset.get(pixelCoordinate);
            if (otherAperturePixel == null) {
                d.add("This has pixel " + pixelCoordinate + ", but other FitsAperture does not.");
            } else {
                d.addAll(pixel.getValue().diff(otherAperturePixel));
            }
        }
        
        for (Pair<Integer, Integer> otherPixelCoordinate : other.pixelsByOffset.keySet()) {
            if (!this.pixelsByOffset.containsKey(otherPixelCoordinate)) {
                d.add("This is missing pixel " + otherPixelCoordinate);
            }
        }
        
        return d;
    }
    
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (pixelsByOffset == null ? 0 : getPixels().hashCode());
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
        if (!(obj instanceof FitsAperture)) {
            return false;
        }
        FitsAperture other = (FitsAperture) obj;
        if (pixelsByOffset == null) {
            if (other.pixelsByOffset != null) {
                return false;
            }
        } else if (!getPixels().equals(other.getPixels())) {
            return false;
        }
        return true;
    }

	@Override
	public String toString() {
		return "FitsAperture [pixelsByOffset=" + pixelsByOffset + "]";
	}
}