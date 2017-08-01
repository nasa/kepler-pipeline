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

package gov.nasa.kepler.systest.flight;

import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.mc.pi.PipelineLauncherParameters;
import gov.nasa.kepler.mc.pi.PipelineLauncherPipelineModule;
import gov.nasa.kepler.mc.uow.SingleUowTaskGenerator;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.PipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;
import gov.nasa.kepler.tad.operations.TadXmlImportParameters;
import gov.nasa.kepler.tad.peer.ama.AmaPipelineModule;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.kepler.tad.xml.TadXmlImportPipelineModule;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * {@link PipelineSeedData} to create a pipeline to import tad xml into a
 * {@link TargetListSet}.
 * 
 * @author Miles Cote
 * 
 */
public class TadXmlImportPipelineSeedData extends PipelineSeedData {

    public static final String PIPELINE_NAME = "TAD Xml Import";
    public static final String TRIGGER_NAME = "TAD Xml Import Trigger";

    private static final String TAD_XML_ABS_PATH = SocEnvVars.getLocalDataDir()
        + "/flight/so/tables/tad/cdpp_tdt_ID14/";

    private static final String SUPPLEMENTAL_TAD_LAUNCHER = "supplementalTadLauncher";

    public void loadSeedData() {
        PipelineConfigurator pc = new PipelineConfigurator();

        // Create modules.
        pc.createModule(TadXmlImportPipelineModule.MODULE_NAME,
            TadXmlImportPipelineModule.class);
        pc.createModule(SupplementalTargetImportPipelineModule.MODULE_NAME,
            SupplementalTargetImportPipelineModule.class);

        // Retrieve param sets.
        ParameterSet moduleOutputLists = retrieveParameterSet(CommonPipelineSeedData.MODULE_OUTPUT_LISTS);
        ParameterSet amaMps = retrieveParameterSet(AmaPipelineModule.MODULE_NAME);
        ParameterSet tadLcPs = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC);
        ParameterSet tadSc1Ps = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M1);
        ParameterSet tadSc2Ps = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M2);
        ParameterSet tadSc3Ps = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M3);
        ParameterSet tadRpPs = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_RP);

        // create pipeline-specific parameter sets
        ParameterSet tadXmlImportPs = pc.createParamSet(
            TadXmlImportParameters.class.getSimpleName(),
            new TadXmlImportParameters(TAD_XML_ABS_PATH));

        // Create pipeline.
        pc.createPipeline(PIPELINE_NAME);

        pc.addPipelineParameterSet(moduleOutputLists);
        pc.addPipelineParameterSet(amaMps);
        pc.addPipelineParameterSet(tadXmlImportPs);

        // add nodes

        // LC
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadLcPs);
        pc.addNode(retrieveModule(TadXmlImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadLcPs);
        pc.addNode(
            retrieveModule(SupplementalTargetImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadLcPs);

        // SC1
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc1Ps);
        pc.addNode(retrieveModule(TadXmlImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc1Ps);
        pc.addNode(
            retrieveModule(SupplementalTargetImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc1Ps);

        // SC2
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc2Ps);
        pc.addNode(retrieveModule(TadXmlImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc2Ps);
        pc.addNode(
            retrieveModule(SupplementalTargetImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc2Ps);

        // SC3
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc3Ps);
        pc.addNode(retrieveModule(TadXmlImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc3Ps);
        pc.addNode(
            retrieveModule(SupplementalTargetImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc3Ps);

        // RP
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadRpPs);
        pc.addNode(retrieveModule(TadXmlImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadRpPs);

        // Configure launch of next pipeline.
        PipelineLauncherParameters launcherParams = new PipelineLauncherParameters();
        launcherParams.setEnabled(true);
        launcherParams.setTriggerName(SupplementalTadPipelineSeedData.PIPELINE_NAME);
        launcherParams.setInstanceName("Launched by " + PIPELINE_NAME);

        ParameterSet launcherParamsPs = new ParameterSet(
            SUPPLEMENTAL_TAD_LAUNCHER);
        launcherParamsPs.setDescription("Created by " + getClass());
        launcherParamsPs.setParameters(new BeanWrapper<Parameters>(
            launcherParams));
        parameterSetCrud.create(launcherParamsPs);

        pc.addNode(retrieveModule(PipelineLauncherPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), launcherParamsPs);

        pc.createTrigger(TRIGGER_NAME);
        pc.finalizePipeline();
    }

    public static void main(String[] args) {
        TadXmlImportPipelineSeedData seedData = new TadXmlImportPipelineSeedData();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        seedData.loadSeedData();
        databaseService.commitTransaction();
    }

}
