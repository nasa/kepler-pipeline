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

public class DebugUowTaskGeneratorBeanInfo extends BaseBeanInfo {
    public DebugUowTaskGeneratorBeanInfo() {
        super(DebugUowTaskGenerator.class);

        ExtendedPropertyDescriptor desc;

        desc = addProperty("binByCadence");
//        desc.setCategory("Cadence Binning");
        desc.setCategory("Parameters used by Debug Module");
        desc.setDisplayName("Bin by cadence");
        desc.setShortDescription("Subdivide the specified cadence range into bins?");
        
        desc = addProperty("cadenceBinSize");
//        desc.setCategory("Cadence Binning");
        desc.setCategory("Parameters used by Debug Module");
        desc.setDisplayName("Cadence bin size");
        desc.setShortDescription("Maximum number of cadences for each UOW.");
        
        desc = addProperty("binByModuleOutput");
//        desc.setCategory("Module/Output Binning");
        desc.setCategory("Parameters used by Debug Module");
        desc.setDisplayName("Bin by module/output");
        desc.setShortDescription("Subdivide by CCD Module/Output?");

        desc = addProperty("startCadence");
        desc.setDisplayName("Start cadence");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("endCadence");
        desc.setDisplayName("End cadence");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("maxTaskCount");
        desc.setDisplayName("Max. task count");
        desc.setShortDescription("The maximum number of tasks "
            + "that will be generated.  Zero means no cap.");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("callMatlab");
        desc.setDisplayName("Call MATLAB code");
        desc.setShortDescription("Whether the MATLAB component "
            + "of the debug module should be called");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("generateMatlabError");
        desc.setDisplayName("Generate MATLAB error");
        desc.setShortDescription("Generate an error in the MATLAB component "
            + "of the debug module");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("sleepTimeJavaSecs");
        desc.setDisplayName("Java Sleep time (in secs.)");
        desc.setShortDescription("How long the module should sleep "
            + "in the Java code for each task to simulate processing time "
            + "(this is in addition to the MATLAB call, if any)");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("sleepTimeMatlabSecs");
        desc.setDisplayName("MATLAB Sleep time (in secs.)");
        desc.setShortDescription("How long the module should sleep "
            + "in the MATLAB for each task to simulate processing time "
            + "(this is in addition to the RaDec2Pix processing time)");
        desc.setCategory("Parameters used by Debug Module");

        desc = addProperty("observingSeason");
        desc.setDisplayName("Observing season");
        desc.setPropertyEditorClass(ObservingSeasonEditor.class);
        desc.setCategory("Example parameters (not used by Debug Module)");

        desc = addProperty("targetTableId");
        desc.setDisplayName("Target table ID");
        desc.setPropertyEditorClass(TargetTableIdEditor.class);
        desc.setCategory("Example parameters (not used by Debug Module)");

//        desc = addProperty("when");
//        desc.setDisplayName("Launch date");
//        desc.setPropertyEditorClass(JCalendarDatePropertyEditor.class);
//        desc.setCategory("Example parameters (not used by Debug Module)");

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
