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

package gov.nasa.kepler.debug.uow;

import gov.nasa.kepler.common.ui.ArrayPropertyEditor;

import com.l2fprod.common.beans.BaseBeanInfo;
import com.l2fprod.common.beans.ExtendedPropertyDescriptor;
import com.l2fprod.common.beans.editor.ComboBoxPropertyEditor;

public class DebugMatlabPipelineParametersBeanInfo extends BaseBeanInfo {
    public DebugMatlabPipelineParametersBeanInfo() {
        super(DebugMatlabPipelineParameters.class);

        ExtendedPropertyDescriptor desc;

        desc = addProperty("callMatlab");
        desc.setDisplayName("Call MATLAB code");
        desc.setShortDescription("Whether the MATLAB component "
            + "of the debug module should be called");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("includeFilestore");
        desc.setDisplayName("Read/write FileStore");
        desc.setShortDescription("Whether the FileStore will be called");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("numTimeseries");
        desc.setDisplayName("Number of timeseries");
        desc.setShortDescription("Number of timeseries to read from the file store");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("useOldRaDec2Pix");
        desc.setDisplayName("Call old RaDec2Pix code");
        desc.setShortDescription("Whether the MATLAB component "
            + "of the debug module should use the old RaDec2Pix (non-model) API");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("sleepTimeJavaSecs");
        desc.setDisplayName("Java Sleep time (in secs.)");
        desc.setShortDescription("How long the module should sleep "
            + "in the Java code for each task to simulate processing time "
            + "(this is in addition to the MATLAB call, if any)");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("startCadence");
        desc.setDisplayName("start cadence");
        desc.setShortDescription("startCadence");
        desc.setCategory("Unit of Work");

        desc = addProperty("endCadence");
        desc.setDisplayName("end cadence");
        desc.setShortDescription("endCadence");
        desc.setCategory("Unit of Work");

        desc = addProperty("cadenceBinSize");
        desc.setDisplayName("cadence bin size");
        desc.setShortDescription("cadenceBinSize");
        desc.setCategory("Unit of Work");

        desc = addProperty("binByModuleOutput");
        desc.setDisplayName("bin by module/output");
        desc.setShortDescription("binByModuleOutput");
        desc.setCategory("Unit of Work");

        desc = addProperty("channelIncludeArray");
        desc.setDisplayName("channel include array");
        desc.setShortDescription("Which channel numbers should be included.  If empty, all are included");
        desc.setCategory("Unit of Work");
        desc.setPropertyEditorClass(ArrayPropertyEditor.class);

        desc = addProperty("channelExcludeArray");
        desc.setDisplayName("channel exclude array");
        desc.setShortDescription("Which channel numbers should be excluded.  If empty, none are excluded");
        desc.setCategory("Unit of Work");

        desc = addProperty("maxTaskCount");
        desc.setDisplayName("max task count");
        desc.setShortDescription("Generated task list will be capped at this size.  Zero means no cap");
        desc.setCategory("Unit of Work");

        desc = addProperty("observingSeason");
        desc.setDisplayName("Observing season");
        desc.setPropertyEditorClass(ObservingSeasonEditor.class);
        desc.setCategory("Example parameters (not used by Debug Module)");

        desc = addProperty("targetTableId");
        desc.setDisplayName("Target table ID");
        desc.setPropertyEditorClass(TargetTableIdEditor.class);
        desc.setCategory("Example parameters (not used by Debug Module)");

        desc = addProperty("intArray");
        desc.setPropertyEditorClass(ArrayPropertyEditor.class);
        desc.setCategory("Example parameters (not used by Debug Module)");
    }

    public static class ObservingSeasonEditor extends ComboBoxPropertyEditor {
        public ObservingSeasonEditor() {
            setAvailableValues(new String[] { "Spring", "Summer", "Fall",
                "Winter", });
        }
    }

    public static class TargetTableIdEditor extends ComboBoxPropertyEditor {
        public TargetTableIdEditor() {
            /*
             * A more realistic implementation would fetch the available id's
             * from the database
             */
            setAvailableValues(new String[] { "1", "2", "3" });
        }
    }
}
