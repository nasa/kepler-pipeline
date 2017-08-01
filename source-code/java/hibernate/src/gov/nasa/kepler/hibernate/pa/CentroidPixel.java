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

package gov.nasa.kepler.hibernate.pa;

import javax.persistence.Column;
import javax.persistence.Embeddable;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * 
 * @author Forrest Girouard
 */
@Embeddable
public class CentroidPixel {

    @Column(nullable = false)
    private int ccdRow;

    @Column(nullable = false)
    private int ccdColumn;

    @Column(name = "IN_FLUX_WEIGHTED_APERTURE")
    private boolean inFluxWeightedCentroidAperture;

    @Column(name = "IN_PRF_APERTURE")
    private boolean inPrfCentroidAperture;

    CentroidPixel() {
    }

    public CentroidPixel(int ccdRow, int ccdColumn,
        boolean inFluxWeightedCentroidAperture, boolean inPrfCentroidAperture) {
        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.inFluxWeightedCentroidAperture = inFluxWeightedCentroidAperture;
        this.inPrfCentroidAperture = inPrfCentroidAperture;
    }

    public int getCcdRow() {
        return ccdRow;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public boolean isInFluxWeightedCentroidAperture() {
        return inFluxWeightedCentroidAperture;
    }

    public boolean isInPrfCentroidAperture() {
        return inPrfCentroidAperture;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ccdColumn;
        result = prime * result
            + (inFluxWeightedCentroidAperture ? 1231 : 1237);
        result = prime * result + (inPrfCentroidAperture ? 1231 : 1237);
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
        if (!(obj instanceof CentroidPixel)) {
            return false;
        }
        CentroidPixel other = (CentroidPixel) obj;
        if (ccdColumn != other.ccdColumn) {
            return false;
        }
        if (inFluxWeightedCentroidAperture != other.inFluxWeightedCentroidAperture) {
            return false;
        }
        if (inPrfCentroidAperture != other.inPrfCentroidAperture) {
            return false;
        }
        if (ccdRow != other.ccdRow) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ReflectionToStringBuilder(this).toString();
    }
}
