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

//package gov.nasa.kepler.etem2;
//
//import gov.nasa.kepler.common.ui.ArrayPropertyEditor;
//import gov.nasa.kepler.tad.operations.TargetListSetEditor;
//import gov.nasa.kepler.tad.operations.TargetListSetEditorRp;
//
//import com.l2fprod.common.beans.BaseBeanInfo;
//import com.l2fprod.common.beans.ExtendedPropertyDescriptor;
//
//public class Etem2PipelineParametersBeanInfo extends BaseBeanInfo {
//    public Etem2PipelineParametersBeanInfo() {
//        super(Etem2PipelineParameters.class);
//
//        ExtendedPropertyDescriptor desc;
//
//        desc = addProperty("startCadence");
//        desc = addProperty("endCadence");
//        desc = addProperty("cadenceBinSize");
//
//        desc = addProperty("startDate");
//
//        desc = addProperty("etemOutputDir");
//        desc = addProperty("pmrfDir");
//        desc = addProperty("rpDir");
//        desc = addProperty("pixelFitsDir");
//
//        desc = addProperty("etemInputsFile");
//
//        desc = addProperty("targetListSetName");
//        desc.setDisplayName("Target List Set Name");
//        desc.setShortDescription("This is the Target List Set on which to run etem.");
//        desc.setPropertyEditorClass(TargetListSetEditor.class);
//        desc.setCategory("Parameters used by etem.");
//
//        desc = addProperty("refPixTargetListSetName");
//        desc.setDisplayName("Optional Reference Pixel Target List Set Name");
//        desc.setShortDescription("This field is only used when running on long cadence.");
//        desc.setPropertyEditorClass(TargetListSetEditorRp.class);
//        desc.setCategory("Parameters used by etem.");
//
//        desc = addProperty("requantExternalId");
//        desc.setDisplayName("requantExternalId");
//        desc.setShortDescription("requantExternalId");
//        desc.setPropertyEditorClass(RequantTableEditor.class);
//        desc.setCategory("Parameters used by etem.");
//
//        desc = addProperty("configMapId");
//        desc.setDisplayName("configMapId");
//        desc.setShortDescription("configMapId");
//        desc.setPropertyEditorClass(ConfigMapEditor.class);
//        desc.setCategory("Parameters used by etem.");
//
//        desc = addProperty("channelIncludeArray");
//        desc.setDisplayName("Channel Include List");
//        desc.setShortDescription("If this is null, etem will run on all mod/outs.  If this has values, etem will only run on those mod/outs.");
//        desc.setPropertyEditorClass(ArrayPropertyEditor.class);
//        desc.setCategory("Parameters used by etem.");
//
//        desc = addProperty("channelExcludeArray");
//        desc.setDisplayName("Channel Exclude List");
//        desc.setShortDescription("If this is null, etem will not exclude any mod/outs.  If this has values, etem will exclude those mod/outs.");
//        desc.setPropertyEditorClass(ArrayPropertyEditor.class);
//        desc.setCategory("Parameters used by etem.");
//    }
//
//}
