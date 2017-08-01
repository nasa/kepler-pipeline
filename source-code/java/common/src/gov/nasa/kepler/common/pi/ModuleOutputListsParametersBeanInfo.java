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
 * @author Bill Wohler
 */
public class ModuleOutputListsParametersBeanInfo extends BaseBeanInfo {

    public ModuleOutputListsParametersBeanInfo() {
        super(ModuleOutputListsParameters.class);

        ExtendedPropertyDescriptor desc;

        desc = addProperty("channelGroupsEnabled");
        desc.setDisplayName("channelGroupsEnabled");
        desc.setShortDescription("If true, the channelGroups property is used in task generation.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("channelGroups");
        desc.setDisplayName("channelGroups");
        desc.setShortDescription("A semi-colon-delimited string containing groups of comma-separated channels to include in task generation. Only consulted if channelGroupsEnabled is true.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("channelIncludeArray");
        desc.setDisplayName("channelIncludeArray");
        desc.setShortDescription("The array of channels to include in task generation. An empty array means all channels are included.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("channelExcludeArray");
        desc.setDisplayName("channelExcludeArray");
        desc.setShortDescription("The array of channels to exclude from task generation. An empty array means no channels are excluded. "
            + "channelExcludeArray trumps channelIncludeArray.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("channelsPerTask");
        desc.setDisplayName("channelsPerTask");
        desc.setShortDescription("Number of channels to place in each task. A value of 0 is the same as 1.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("deadChannelArray");
        desc.setDisplayName("deadChannelArray");
        desc.setShortDescription("The array of dead channels. Tasks will be removed or adjusted based on the cadenceOfDeath. "
            + "Parallel array of cadenceOfDeathArray.");
        desc.setCategory(getClass().getSimpleName());

        desc = addProperty("cadenceOfDeathArray");
        desc.setDisplayName("cadenceOfDeathArray");
        desc.setShortDescription("The array of the cadence of death for each dead channel. Parallel array of deadChannelArray.");
        desc.setCategory(getClass().getSimpleName());
        
        desc = addProperty("channelForStoringNonChannelSpecificData");
        desc.setDisplayName("channelForStoringNonChannelSpecificData");
        desc.setShortDescription("The channel whose pipeline task will store non-channel specific data, like reaction "
            + "wheel zero crossings and thruster firings.");
        desc.setCategory(getClass().getSimpleName());
    }
}
