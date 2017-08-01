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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.fs.api.FsId;

import java.util.HashSet;
import java.util.Set;

public class CalibratedPixel extends Pixel {

    private final FsId cosmicRayEventsFsId;
    private final FsId uncertaintiesFsId;

    public CalibratedPixel(final int referenceRow, final int referenceColumn,
        final FsId fsId, final FsId uncertaintiesFsId,
        final FsId cosmicRayEventsFsId, final boolean inOptimalAperture) {

        super(referenceRow, referenceColumn, fsId, inOptimalAperture);
        this.uncertaintiesFsId = uncertaintiesFsId;
        this.cosmicRayEventsFsId = cosmicRayEventsFsId;
    }

    public FsId getCosmicRayEventsFsId() {
        return cosmicRayEventsFsId;
    }

    public FsId getUncertaintiesFsId() {
        return uncertaintiesFsId;
    }

    @Override
    public Set<FsId> getFsIds() {
        Set<FsId> fsIds = new HashSet<FsId>();
        fsIds.add(getFsId());
        fsIds.add(getUncertaintiesFsId());
        return fsIds;
    }

    @Override
    public Set<FsId> getMjdFsIds() {
        Set<FsId> fsIds = new HashSet<FsId>();
        fsIds.add(getCosmicRayEventsFsId());
        return fsIds;
    }

    // Careful! Modified copy of pixel.hashCode.
    @Override
    public int hashCode() {
        return getRow() ^ Integer.rotateLeft(getColumn(), 16);
    }

    // Careful! Modified copy of pixel.equals.
    // Also, we're using instanceof Pixel so that a CalibratedPixel can be
    // found in a set of Pixels.
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Pixel)) {
            return false;
        }
        Pixel other = (Pixel) obj;
        if (other.getRow() != getRow()) {
            return false;
        }
        return other.getColumn() == getColumn();
    }
}
