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

//package gov.nasa.kepler.tad;
//
//import gov.nasa.kepler.common.FcConstants;
//import gov.nasa.kepler.common.ModuleFatalProcessingException;
//import gov.nasa.kepler.common.PipelineException;
//import gov.nasa.kepler.common.file.FileUtil;
//import gov.nasa.kepler.common.pi.UnitOfWorkTask;
//import gov.nasa.kepler.hibernate.pi.PipelineInstance;
//import gov.nasa.kepler.hibernate.pi.PipelineModule;
//import gov.nasa.kepler.hibernate.pi.PipelineTask;
//import gov.nasa.kepler.mc.uow.CadenceUowTask;
//
//import org.apache.commons.logging.Log;
//import org.apache.commons.logging.LogFactory;
//
//public class TadToFitsPipelineModule extends PipelineModule {
//
//    private static final String MODULE_NAME = "tadtofits";
//    private static final String MODULE_VERSION = "1.0";
//
//    private CadenceUowTask task;
//    private TadToFitsPipelineParameters pipelineParameters;
//
//    private static final Log log = LogFactory.getLog(TadToFitsPipelineModule.class);
//
//    public TadToFitsPipelineModule() {
//    }
//
//    @Override
//    public String getModuleName() {
//        return MODULE_NAME;
//    }
//
//    @Override
//    public String getModuleVersion() {
//        return MODULE_VERSION;
//    }
//
//    @Override
//    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
//        return CadenceUowTask.class;
//    }
//
//    @Override
//    public void processTask(PipelineInstance pipelineInstance,
//        PipelineTask pipelineTask) {
//        try {
//            task = (CadenceUowTask) pipelineTask.getUowTask().getInstance();
//
//            pipelineParameters = (TadToFitsPipelineParameters) pipelineInstance.getPipelineParameters()
//                .getInstance();
//
//            FileUtil.cleanDir(pipelineParameters.getFitsDir());
//
//            for (int module : FcConstants.modulesList) {
//                for (int output : FcConstants.outputsList) {
//                    log.info(module + "/" + output);
//
//                    TadToFitsLong tadToFitsLong = new TadToFitsLong(
//                        pipelineParameters.getLcTargetListSetName(),
//                        pipelineParameters.getFitsDir(),
//                        task.getStartCadence(), task.getEndCadence());
//                    tadToFitsLong.export(module, output);
//                    
//                    TadToFitsShort tadToFitsShort = new TadToFitsShort(
//                        pipelineParameters.getScTargetListSetName(),
//                        pipelineParameters.getFitsDir(),
//                        task.getStartCadence(), task.getEndCadence());
//                    tadToFitsShort.export(module, output);
//                }
//            }
//        } catch (Exception e) {
//            throw new ModuleFatalProcessingException(2001,
//                "failed to execute Etem2Fits", e);
//        }
//    }
//
//}
