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

package gov.nasa.kepler.dr.pmrf;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.dr.fits.FitsColumn;

import java.util.List;

/**
 * Contains a collateral pmrf mod/out.
 * 
 * @author Miles Cote
 * 
 */
public final class CollateralPmrfModOut {

    static final int MAX_COLLATERAL_PIXELS_PER_CHANNEL = FcConstants.CCD_ROWS
        + (FcConstants.nColsImaging * 2);

    private final List<CollateralPmrfEntry> collateralPmrfEntries;

    @Override
    public String toString() {
        return "CollateralPmrfModOut [collateralPmrfEntries="
            + collateralPmrfEntries + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + collateralPmrfEntries.hashCode();
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
        CollateralPmrfModOut other = (CollateralPmrfModOut) obj;
        if (!collateralPmrfEntries.equals(other.collateralPmrfEntries))
            return false;
        return true;
    }

    public static final CollateralPmrfModOut ofFitsColumns(
        List<FitsColumn> fitsColumns) {
        checkNotNull(fitsColumns);

        List<Number> collateralTypes = fitsColumns.get(0)
            .getValues();
        List<Number> ccdRowOrColumns = fitsColumns.get(1)
            .getValues();

        List<CollateralPmrfEntry> collateralPmrfEntries = newArrayList();
        for (int index = 0; index < collateralTypes.size(); index++) {
            collateralPmrfEntries.add(new CollateralPmrfEntry(
                CollateralType.valueOf(collateralTypes.get(index)
                    .byteValue()), ccdRowOrColumns.get(index)
                    .shortValue()));
        }

        return CollateralPmrfModOut.ofEntries(collateralPmrfEntries);
    }

    public static final CollateralPmrfModOut ofEntries(
        List<CollateralPmrfEntry> collateralPmrfEntries) {
        checkNotNull(collateralPmrfEntries);

        return new CollateralPmrfModOut(collateralPmrfEntries);
    }

    private CollateralPmrfModOut(List<CollateralPmrfEntry> collateralPmrfEntries) {
        this.collateralPmrfEntries = collateralPmrfEntries;

        validate();
    }

    private void validate() {
        int pixelCount = collateralPmrfEntries.size();
        if (pixelCount > MAX_COLLATERAL_PIXELS_PER_CHANNEL) {
            throw new IllegalArgumentException("There cannot be more than "
                + MAX_COLLATERAL_PIXELS_PER_CHANNEL
                + " collateral pixels per channel." + "\n  pixelCount: "
                + pixelCount);
        }
    }

    public List<FitsColumn> toFitsColumns() {
        List<Number> collateralTypes = newArrayList();
        List<Number> ccdRowOrColumns = newArrayList();
        for (CollateralPmrfEntry collateralPmrfEntry : collateralPmrfEntries) {
            collateralTypes.add(collateralPmrfEntry.getCollateralType()
                .byteValue());
            ccdRowOrColumns.add(collateralPmrfEntry.getCcdRowOrColumn());
        }

        List<FitsColumn> fitsColumns = newArrayList();
        fitsColumns.add(new FitsColumn(collateralTypes));
        fitsColumns.add(new FitsColumn(ccdRowOrColumns));

        return fitsColumns;
    }

    public List<CollateralPmrfEntry> getCollateralPmrfEntries() {
        return collateralPmrfEntries;
    }

}
