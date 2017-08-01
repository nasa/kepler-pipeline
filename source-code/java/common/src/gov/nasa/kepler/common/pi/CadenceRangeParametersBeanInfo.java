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

package gov.nasa.kepler.common.pi;

import com.l2fprod.common.beans.BaseBeanInfo;
import com.l2fprod.common.beans.ExtendedPropertyDescriptor;

/**
 * @author Miles Cote
 * 
 */
public class CadenceRangeParametersBeanInfo extends BaseBeanInfo {

    public CadenceRangeParametersBeanInfo() {
        super(CadenceRangeParameters.class);

        ExtendedPropertyDescriptor desc;

        desc = addProperty("startCadence");
        desc.setDisplayName("startCadence");
        desc.setShortDescription("The cadence at which to start processing.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("endCadence");
        desc.setDisplayName("endCadence");
        desc.setShortDescription("The cadence at which to end processing.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("numberOfBins");
        desc.setDisplayName("numberOfBins");
        desc.setShortDescription("The desired number of bins. This can be overridden by minimumBinSize, if using numberOfBins would result in "
            + "a task smaller than minimumBinSize. If numberOfBins is 0, then cadence binning is disabled.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("minimumBinSize");
        desc.setDisplayName("minimumBinSize");
        desc.setShortDescription("The minimumBinSize for any task. Ensures that no task has fewer than minimumBinSize cadences. "
            + "If minimumBinSize is 0, then there will be no minimum bin size.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("binByTargetTable");
        desc.setDisplayName("binByTargetTable");
        desc.setShortDescription("The flag for deciding whether to break tasks on target-table boundaries.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("excludeCadences");
        desc.setDisplayName("excludeCadences");
        desc.setShortDescription("The global list of cadences that should be excluded from task generation. It's as if these pixelLogs never "
            + "existed.");
        desc.setCategory(getClass().getSimpleName());
    }

}
