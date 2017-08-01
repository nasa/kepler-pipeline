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

package gov.nasa.kepler.ui.ops.parameters;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Hold the ParameterSetName assigned for a specified type.
 * Used by the ParameterSetNamesTableModel.
 * 
 * @author tklaus
 *
 */
public class ParameterSetAssignment {

    private ClassWrapper<Parameters> type = null;
    private ParameterSetName assignedName = null;
    private boolean assignedAtPipelineLevel = false;
    private boolean assignedAtBothLevels = false;
    
    public ParameterSetAssignment(ClassWrapper<Parameters> type) {
        this.type = type;
    }

    public ParameterSetAssignment(ClassWrapper<Parameters> type, ParameterSetName assignedName,
        boolean assignedAtPipelineLevel, boolean assignedAtBothLevels) {
        this.type = type;
        this.assignedName = assignedName;
        this.assignedAtPipelineLevel = assignedAtPipelineLevel;
        this.assignedAtBothLevels = assignedAtBothLevels;
    }

//    public ParameterSetAssignment(ClassWrapper<Parameters> type, ParameterSetName assignedName,
//        boolean assignedAtPipelineLevel) {
//        this.type = type;
//        this.assignedName = assignedName;
//        this.assignedAtPipelineLevel = assignedAtPipelineLevel;
//    }

    public ClassWrapper<Parameters> getType() {
        return type;
    }
    
    public void setType(ClassWrapper<Parameters> type) {
        this.type = type;
    }
    
    public ParameterSetName getAssignedName() {
        return assignedName;
    }
    
    public void setAssignedName(ParameterSetName assignedName) {
        this.assignedName = assignedName;
    }
    
    public boolean isAssignedAtPipelineLevel() {
        return assignedAtPipelineLevel;
    }
    
    public void setAssignedAtPipelineLevel(boolean assignedAtPipelineLevel) {
        this.assignedAtPipelineLevel = assignedAtPipelineLevel;
    }

    public boolean isAssignedAtBothLevels() {
        return assignedAtBothLevels;
    }

    public void setAssignedAtBothLevels(boolean assignedAtBothLevels) {
        this.assignedAtBothLevels = assignedAtBothLevels;
    }
}
