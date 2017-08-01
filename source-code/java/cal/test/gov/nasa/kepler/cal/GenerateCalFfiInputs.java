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

package gov.nasa.kepler.cal;

import gov.nasa.kepler.cal.io.CalCosmicRayParameters;
import gov.nasa.kepler.cal.io.CalModuleParameters;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

/**
 * @author Sean McCauliff
 *
 * Need Q5 and Q7 channel 66
 */
public class GenerateCalFfiInputs {

    
    public static void main(String[] argv) throws Exception {
        
        DatabaseServiceFactory.getInstance().getConnection().setReadOnly(true);
        
        List<String> timestamps = 
            ImmutableList.of(/*"2010111125026",*/ "2010140101631", "2010174164113",
                "2010296192119", "2010326181728", "2010356020128");
        
        /**
         * kplr2010111125026_ffi-orig.fits
kplr2010140101631_ffi-orig.fits
kplr2010174164113_ffi-orig.fits

and the Q7 FFIs,are:
kplr2010296192119_ffi-orig.fits
kplr2010326181728_ffi-orig.fits
kplr2010356020128_ffi-orig.fits
         */
        for (String timestamp : timestamps) {
            generateFor(timestamp);
            //TODO:  Hackery
            File srcDir = new File("/path/to/dist/tmp/cal-matlab-0-0");
            File destDir = new File("/path/to/ffi-outputs/" + timestamp);
            FileUtil.mkdirs(destDir);
            FileUtils.copyDirectory(srcDir, destDir);
        }
    }
    
    private static final void generateFor(String timestamp) throws Exception {
        FileUtil.mkdirs(new File("calffi-timestamp"));
        //TODO:  fixme
        CalFfiPipelineModule module = new CalFfiPipelineModule() {
//            @Override
//            protected void updateDataAccountability(PipelineTask pipelineTask) {
//                //This does nothing
//            }
//            
//            @Override
//            protected void storeFfiOutputs(CalOutputs ffiOutputs, FfiModOut ffiModOut,
//                String fileTimeStamp) throws FitsException, IOException { 
//                    //This does nothing
//            }
        };
        
        final CalFfiModuleParameters ffiModuleParamters = new CalFfiModuleParameters(timestamp);
        final CalModuleParameters calModuleParameters = new CalModuleParameters();
        final PouModuleParameters pouModuleParameters = new PouModuleParameters();
        final CalCosmicRayParameters calCosmicRayParameters = new CalCosmicRayParameters();
        final Map<Class<? extends Parameters>, ? extends Parameters> parameters = 
            ImmutableMap.of(CalFfiModuleParameters.class, ffiModuleParamters, 
                CalModuleParameters.class, calModuleParameters,
                PouModuleParameters.class, pouModuleParameters,
                CalCosmicRayParameters.class, calCosmicRayParameters);
        
        PipelineModuleDefinition piModuleDefinition = new PipelineModuleDefinition();
        piModuleDefinition.setExeName("cal");
        PipelineDefinitionNode piDefinitionNode = new PipelineDefinitionNode();
        PipelineInstanceNode piInstNode = new PipelineInstanceNode();
        piInstNode.setPipelineModuleDefinition(piModuleDefinition);
        
        PipelineInstance pipelineInstance = new PipelineInstance();
        PipelineTask pipelineTask = new PipelineTask(pipelineInstance, piDefinitionNode, piInstNode) {
            @SuppressWarnings("unchecked")
            public <T extends Parameters> T getParameters(Class<T> parametersClass) {
                return (T) parameters.get(parametersClass);
            }
        };
        
        Pair<Integer, Integer> modOut = FcConstants.getModuleOutput(66);
        ModOutUowTask uow = new ModOutUowTask(modOut.left, modOut.right);
        pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(uow));
        
        module.processTask(pipelineInstance, pipelineTask);
        
        
    }
}
