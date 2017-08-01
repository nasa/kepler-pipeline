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

package gov.nasa.kepler.pa;

import gov.nasa.kepler.mc.CosmicRayParameters;

/**
 * Simple subclass to effectively enable passing through the module interface
 * multiple instances of the {@code CosmicRayParameters} class.
 * 
 * @see gov.nasa.kepler.pdc.CalCosmicRayParameters
 * 
 * @author Forrest Girouard
 */
public class PaCosmicRayParameters extends CosmicRayParameters {

    private boolean cleanZeroCrossingCadencesEnabled;
    private boolean k2BackgroundCleaningEnabled;
    private int     k2BackgroundThrusterFiringExcludeHalfWindow;
    private boolean k2TargetCleaningEnabled;
    private int     k2TargetThrusterFiringExcludeHalfWindow;

    public boolean isCleanZeroCrossingCadencesEnabled() {
        return cleanZeroCrossingCadencesEnabled;
    }

    public void setCleanZeroCrossingCadencesEnabled(
        boolean cleanZeroCrossingCadencesEnabled) {
        this.cleanZeroCrossingCadencesEnabled = cleanZeroCrossingCadencesEnabled;
    }
    
    public boolean isK2BackgroundCleaningEnabled() {
        return k2BackgroundCleaningEnabled;
    }
    
    public void setK2BackgroundCleaningEnabled(boolean k2BackgroundCleaningEnabled) {
        this.k2BackgroundCleaningEnabled = k2BackgroundCleaningEnabled;
    }
    
    public int getK2BackgroundThrusterFiringExcludeHalfWindow() {
        return k2BackgroundThrusterFiringExcludeHalfWindow;
    }
    
    public void setK2BackgroundThrusterFiringExcludeHalfWindow(
        int k2BackgroundThrusterFiringExcludeHalfWindow) {
        this.k2BackgroundThrusterFiringExcludeHalfWindow = 
            k2BackgroundThrusterFiringExcludeHalfWindow;
    }
    
    public boolean isK2TargetCleaningEnabled() {
        return k2TargetCleaningEnabled;
    }
    
    public void setK2TargetCleaningEnabled(boolean k2TargetCleaningEnabled) {
        this.k2TargetCleaningEnabled = k2TargetCleaningEnabled;
    }
    
    public int getK2TargetThrusterFiringExcludeHalfWindow() {
        return k2TargetThrusterFiringExcludeHalfWindow;
    }
    
    public void setK2TargetThrusterFiringExcludeHalfWindow(
        int k2TargetThrusterFiringExcludeHalfWindow) {
        this.k2TargetThrusterFiringExcludeHalfWindow = 
            k2TargetThrusterFiringExcludeHalfWindow;
    }

}
