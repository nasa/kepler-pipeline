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
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

/**
 * Java representation of the cotrending basis vectors produced by PDC.
 * 
 * @author Sean McCauliff
 *
 */
public class CotrendingBasisVectors implements Persistable {

    private boolean[] additionalGaps;
    
    private float[][] nobandVectors;
    
    private int mapOrder;
    
    @ProxyIgnore
    private long originator = -1;
    
    /** Required by persistable. */
    public CotrendingBasisVectors() {
        
    }
    
    public CotrendingBasisVectors(float[][] nobandVectors, int mapOrder, long originator, boolean[] additionalGaps) {
        this.nobandVectors = nobandVectors;
        this.mapOrder = mapOrder;
        this.originator = originator;
        this.additionalGaps = additionalGaps;
    }
    
    public Integer mapOrder() {
        if (nobandVectors.length == 0) {
            return null;
        }
        return mapOrder;
    }
    
    /**
     * The basis vectors that are generated without respect to time scale.
     * That is MAP, but not MS-MAP.
     * @return 
     */
    public float[][] nobandVectors() {
        return nobandVectors;
    }
    
    /**
     * The pipeline task id that generated these cotrending basis vectors.
     * @return
     */
    public long originator() {
        return originator;
    }
    
    public boolean exists() {
        return nobandVectors.length != 0;
    }
    
    public void setOriginator(long originator) {
        this.originator = originator;
    }
    
    /**
     * Additional gaps that are introduced if the basis vectors do not cover the
     * entire cadence interval.
     * 
     * @return this should be the same length as nobandvectors[0].length
     */
    public boolean[] additionalGaps() {
        return additionalGaps;
    }
}
