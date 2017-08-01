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
//import gov.nasa.kepler.common.DatabaseService;
//import gov.nasa.kepler.common.PipelineException;
//import gov.nasa.kepler.common.pi.ClassWrapper;
//import gov.nasa.kepler.common.pi.Parameters;
//import gov.nasa.kepler.common.pi.UnitOfWorkTaskGenerator;
//import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
//import gov.nasa.kepler.hibernate.pi.BeanWrapper;
//import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
//import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
//import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
//import gov.nasa.kepler.hibernate.pi.PipelineModule;
//import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
//import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
//import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
//import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
//import gov.nasa.kepler.mc.uow.CadenceUowTaskGenerator;
//
///**
// * Loads metadata about the TAD pipelines into the database.
// * 
// * @author Miles Cote
// */
//public class TadToFitsPipelineSeedData {
//
//    public static final String PIPELINE_NAME = "tadToFits";
//
//    public static final String TRIGGER_NAME = "tadToFitsTrigger";
//
//    private PipelineDefinitionCrud pipelineDefinitionCrud;
//    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
//    private TriggerDefinitionCrud triggerDefinitionCrud;
//
//    /**
//     * Loads metadata about the TadToFits pipelines into the database.
//     * 
//     * @throws Exception if there is a problem loading the default module
//     * parameters.
//     */
//    public void loadSeedData() {
//        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
//
//        pipelineDefinitionCrud = new PipelineDefinitionCrud(databaseService);
//        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud(
//            databaseService);
//        triggerDefinitionCrud = new TriggerDefinitionCrud(databaseService);
//
//        createPipeline();
//    }
//
//    private void createPipeline() {
//        PipelineModuleDefinition modDef = createOrRetrieveModDef(new TadToFitsPipelineModule());
//
//        PipelineDefinition pipelineDef = new PipelineDefinition(PIPELINE_NAME,
//            "Create fits files from tad data.");
//        pipelineDef.setPipelineParameters(new BeanWrapper<Parameters>(
//            new TadToFitsPipelineParameters()));
//
//        CadenceUowTaskGenerator generator = new CadenceUowTaskGenerator();
//
//        PipelineDefinitionNode node1 = new PipelineDefinitionNode();
//        node1.setPipelineModuleDefinition(modDef);
//        node1.setUnitOfWork(new BeanWrapper<UnitOfWorkTaskGenerator>(generator));
//        node1.setStartNewUow(false);
//        pipelineDef.getRootNodes().add(node1);
//
//        pipelineDefinitionCrud.create(pipelineDef);
//
//        TriggerDefinition trigger = new TriggerDefinition(TRIGGER_NAME,
//            pipelineDef);
//        trigger.setType(TriggerDefinition.TYPE_MANUAL);
//
//        triggerDefinitionCrud.create(trigger);
//    }
//
//    private PipelineModuleDefinition createOrRetrieveModDef(
//        PipelineModule module) {
//        String name = module.getModuleName();
//
//        PipelineModuleDefinition modDef = pipelineModuleDefinitionCrud.retrieve(name);
//
//        if (modDef == null) {
//            modDef = new PipelineModuleDefinition(name, name);
//            modDef.setImplementingClass(new ClassWrapper<PipelineModule>(module));
//            modDef.setExeName(name.toLowerCase());
//            modDef.setExeTimeoutSecs(Integer.MAX_VALUE);
//
//            pipelineModuleDefinitionCrud.create(modDef);
//        }
//
//        return modDef;
//    }
//
//    public static void main(String[] args) {
//        DatabaseService dbService = DatabaseServiceFactory.getInstance();
//        try {
//            dbService.beginTransaction();
//            TadToFitsPipelineSeedData seedData = new TadToFitsPipelineSeedData();
//            seedData.loadSeedData();
//            dbService.commitTransaction();
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
//
//}
