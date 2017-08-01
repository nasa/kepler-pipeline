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

package gov.nasa.kepler.fs.server.scheduler;

import gov.nasa.kepler.fs.api.FsId;

/**
 * The start of an FsIds location by file and offset.
 * @author Sean McCauliff
 *
 */
public final class  FsIdLocation  implements FsIdOrder {

    private final int fileLocation;
    private final long offset;
    private final FsId id;
    private final boolean exists;
    private final int originalOrder;
    
    
    public FsIdLocation(int fileLocation, long offset, FsId id, int originalOrder) {
        this.fileLocation = fileLocation;
        this.offset = offset;
        this.id = id;
        this.exists = true;
        this.originalOrder = originalOrder;
    }
    
    /** non-existent id. */
    public FsIdLocation(FsId id, int originalOrder) {
        this.fileLocation = -1;
        this.offset = -1;
        this.id = id;
        this.exists = false;
        this.originalOrder = originalOrder;
    }

    /** Undefined if exists() == true. */
    public int fileLocation() {
        return fileLocation;
    }
    
    /** Undefined if exists() == true. */
    public long offsetInFile() {
        return offset;
    }
    
    /** Undefined if exists() == true. */
    public FsId id() {
        return id;
    }

    public boolean exists() {
        return exists;
    }
    
    public int originalOrder() {
        return originalOrder;
    }

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append("FsIdLocation [exists=")
            .append(exists)
            .append(", fileLocation=")
            .append(fileLocation)
            .append(", id=")
            .append(id)
            .append(", offset=")
            .append(offset)
            .append(", originalOrder=")
            .append(originalOrder)
            .append("]");
        return builder.toString();
    }
    
    
}
