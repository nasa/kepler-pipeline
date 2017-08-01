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

package gov.nasa.kepler.ar.archive;

import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * This is the per target WCS coordinates.  These outputs do not address
 * physical WCS coordinates.  These are calculated by the exporter.
 * 
 * @author Sean McCauliff
 *
 */
public class TargetWcs implements Persistable {

    private int keplerId;
    /** CRPIX1 */
    private WcsModelParameter subimageCoordinateSystemReferenceColumn;
    /** CRPIX2 */
    private WcsModelParameter subimageCoordinateSystemReferenceRow;
    /** CRVAL1 */
    private WcsModelParameter subimageReferenceRightAscension;
    /** CRVAL2 */
    private WcsModelParameter subimageReferenceDeclination;
    /** CDELT1 */
    private WcsModelParameter unitMatrixDegreesPerPixelColumn;
    /** CDELT2 */
    private WcsModelParameter unitMatrixDegreesPerPixelRow;
    /** PC1_1 */
    private WcsModelParameter unitMatrixRotationMatrix11;
    /** PC1_2 */
    private WcsModelParameter unitMatrixRotationMatrix12;
    /** PC2_1 */
    private WcsModelParameter unitMatrixRotationMatrix21;
    /** PC2_2 */
    private WcsModelParameter unitMatrixRotationMatrix22;
    
    
    public TargetWcs(int keplerId,
        WcsModelParameter subimageCoordinateSystemReferenceColumn,
        WcsModelParameter subimageCoordinateSystemReferenceRow,
        WcsModelParameter subimageReferenceRightAscension,
        WcsModelParameter subimageReferenceDeclination,
        WcsModelParameter unitMatrixDegreesPerPixelColumn,
        WcsModelParameter unitMatrixDegreesPerPixelRow,
        WcsModelParameter unitMatrixRotationMatrix11,
        WcsModelParameter unitMatrixRotationMatrix12,
        WcsModelParameter unitMatrixRotationMatrix21,
        WcsModelParameter unitMatrixRotationMatrix22) {
        super();
        this.keplerId = keplerId;
        this.subimageCoordinateSystemReferenceColumn = subimageCoordinateSystemReferenceColumn;
        this.subimageCoordinateSystemReferenceRow = subimageCoordinateSystemReferenceRow;
        this.subimageReferenceRightAscension = subimageReferenceRightAscension;
        this.subimageReferenceDeclination = subimageReferenceDeclination;
        this.unitMatrixDegreesPerPixelColumn = unitMatrixDegreesPerPixelColumn;
        this.unitMatrixDegreesPerPixelRow = unitMatrixDegreesPerPixelRow;
        this.unitMatrixRotationMatrix11 = unitMatrixRotationMatrix11;
        this.unitMatrixRotationMatrix12 = unitMatrixRotationMatrix12;
        this.unitMatrixRotationMatrix21 = unitMatrixRotationMatrix21;
        this.unitMatrixRotationMatrix22 = unitMatrixRotationMatrix22;
    }
    
    /**
     * Required by the Persistable interface.
     */
    public TargetWcs() {
        
    }
    
    public int getKeplerId() {
        return keplerId;
    }
    public WcsModelParameter getSubimageCoordinateSystemReferenceColumn() {
        return subimageCoordinateSystemReferenceColumn;
    }
    public WcsModelParameter getSubimageCoordinateSystemReferenceRow() {
        return subimageCoordinateSystemReferenceRow;
    }
    public WcsModelParameter getSubimageReferenceRightAscension() {
        return subimageReferenceRightAscension;
    }
    public WcsModelParameter getSubimageReferenceDeclination() {
        return subimageReferenceDeclination;
    }
    public WcsModelParameter getUnitMatrixDegreesPerPixelColumn() {
        return unitMatrixDegreesPerPixelColumn;
    }
    public WcsModelParameter getUnitMatrixDegreesPerPixelRow() {
        return unitMatrixDegreesPerPixelRow;
    }
    public WcsModelParameter getUnitMatrixRotationMatrix11() {
        return unitMatrixRotationMatrix11;
    }
    public WcsModelParameter getUnitMatrixRotationMatrix12() {
        return unitMatrixRotationMatrix12;
    }
    public WcsModelParameter getUnitMatrixRotationMatrix21() {
        return unitMatrixRotationMatrix21;
    }
    public WcsModelParameter getUnitMatrixRotationMatrix22() {
        return unitMatrixRotationMatrix22;
    }
    
    
}
