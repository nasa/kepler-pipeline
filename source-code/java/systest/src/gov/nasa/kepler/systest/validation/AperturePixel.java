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

import java.util.ArrayList;
import java.util.List;

/**
 * 
 * @author Forrest Girouard
 */
public class AperturePixel {

    private boolean inOptimalAperture;
    private boolean inFluxWeightedCentroidAperture;
    private boolean inPrfCentroidAperture;
    private final int row;
    private final int column;

    public AperturePixel(int row, int column) {
        this.row = row;
        this.column = column;
        inOptimalAperture = false;
        inFluxWeightedCentroidAperture = false;
        inPrfCentroidAperture = false;
    }

    public boolean isInOptimalAperture() {
        return inOptimalAperture;
    }

    public void setInOptimalAperture(boolean inOptimalAperture) {
        this.inOptimalAperture = inOptimalAperture;
    }

    public boolean isInFluxWeightedCentroidAperture() {
        return inFluxWeightedCentroidAperture;
    }

    public void setInFluxWeightedCentroidAperture(
        boolean inFluxWeightedCentroidAperture) {
        this.inFluxWeightedCentroidAperture = inFluxWeightedCentroidAperture;
    }

    public boolean isInPrfCentroidAperture() {
        return inPrfCentroidAperture;
    }

    public void setInPrfCentroidAperture(boolean inPrfCentroidAperture) {
        this.inPrfCentroidAperture = inPrfCentroidAperture;
    }

    public int getRow() {
        return row;
    }

    public int getColumn() {
        return column;
    }

    /**
     * 
     * @return A non-zero length, Human-readable strings if there is a difference.
     */
    public List<String> diff(AperturePixel other) {
        List<String> d = new ArrayList<String>();
        if ((this.row != other.row) && (this.column != other.column)) {
            d.add("row/column mismatch this.(" + this.row + "," + this.column + ")" +
                 "vs (" + other.row + "," + other.column + ").");
            return d;
        }
        
        
        if (this.inFluxWeightedCentroidAperture != other.inFluxWeightedCentroidAperture) {
            d.add("r/c " + row + "/" + column + " differs in inFluxWeightedCentroidAperture.");
        }
        if (this.inOptimalAperture != other.inOptimalAperture) {
            d.add("r/c " + row + "/" + column + " differs in inNominalAperture.");
        }
        if (this.inPrfCentroidAperture != other.inPrfCentroidAperture) {
            d.add("r/c" + row + "/" + column + " differs in inPrfCentroidAperture.");
        }
        
        return d;
    
    }
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + column;
        result = prime * result
            + (inFluxWeightedCentroidAperture ? 1231 : 1237);
        result = prime * result + (inOptimalAperture ? 1231 : 1237);
        result = prime * result + (inPrfCentroidAperture ? 1231 : 1237);
        result = prime * result + row;
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
        if (!(obj instanceof AperturePixel)) {
            return false;
        }
        AperturePixel other = (AperturePixel) obj;
        if (column != other.column) {
            return false;
        }
        if (inFluxWeightedCentroidAperture != other.inFluxWeightedCentroidAperture) {
            return false;
        }
        if (inOptimalAperture != other.inOptimalAperture) {
            return false;
        }
        if (inPrfCentroidAperture != other.inPrfCentroidAperture) {
            return false;
        }
        if (row != other.row) {
            return false;
        }
        return true;
    }

	@Override
	public String toString() {
		return "AperturePixel [inOptimalAperture=" + inOptimalAperture
				+ ", inFluxWeightedCentroidAperture="
				+ inFluxWeightedCentroidAperture + ", inPrfCentroidAperture="
				+ inPrfCentroidAperture + ", row=" + row + ", column=" + column
				+ "]";
	}

}
