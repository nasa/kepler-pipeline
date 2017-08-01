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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.mc.pi.PipelineLauncherParameters;
import gov.nasa.kepler.mc.pi.PipelineLauncherPipelineModule;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTaskGenerator;
import gov.nasa.kepler.mc.uow.SingleUowTaskGenerator;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.PipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModule;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * {@link PipelineSeedData} to create a pipeline to do a supplemental tad run.
 * 
 * @author Miles Cote
 * 
 */
public class SupplementalTadPipelineSeedData extends PipelineSeedData {

    private static final String SUPPLEMENTAL = "Supplemental";

    public static final String PIPELINE_NAME = SUPPLEMENTAL + " TAD";
    public static final String TRIGGER_NAME = SUPPLEMENTAL + " TAD";

    public static final String TAD_PARAMETERS_LC_SUPPLEMENTAL = TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC
        + " " + SUPPLEMENTAL;
    public static final String TAD_PARAMETERS_SC1_SUPPLEMENTAL = TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M1
        + " " + SUPPLEMENTAL;
    public static final String TAD_PARAMETERS_SC2_SUPPLEMENTAL = TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M2
        + " " + SUPPLEMENTAL;
    public static final String TAD_PARAMETERS_SC3_SUPPLEMENTAL = TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M3
        + " " + SUPPLEMENTAL;

    private static final String FLIGHT_DATA_IMPORT_LAUNCHER = "flightDataImportLauncher";

    public void loadSeedData() {
        PipelineConfigurator pc = new PipelineConfigurator();

        // retrieve common (already created) param sets
        ParameterSet moduleOutputLists = retrieveParameterSet(CommonPipelineSeedData.MODULE_OUTPUT_LISTS);
        ParameterSet plannedSpacecraftConfig = retrieveParameterSet(CommonPipelineSeedData.PLANNED_SPACECRAFT_CONFIG);
        ParameterSet coaMps = retrieveParameterSet(CoaPipelineModule.MODULE_NAME);

        // create pipeline-specific parameter sets
        ParameterSet suppTadLcPs = pc.createParamSet(
            TAD_PARAMETERS_LC_SUPPLEMENTAL, new TadParameters(
                TadQuarterlyPipelineSeedData.LC + "_supplemental", null));
        ParameterSet suppTadSc1Ps = pc.createParamSet(
            TAD_PARAMETERS_SC1_SUPPLEMENTAL, new TadParameters(
                TadQuarterlyPipelineSeedData.SC1 + "_supplemental", null));
        ParameterSet suppTadSc2Ps = pc.createParamSet(
            TAD_PARAMETERS_SC2_SUPPLEMENTAL, new TadParameters(
                TadQuarterlyPipelineSeedData.SC2 + "_supplemental", null));
        ParameterSet suppTadSc3Ps = pc.createParamSet(
            TAD_PARAMETERS_SC3_SUPPLEMENTAL, new TadParameters(
                TadQuarterlyPipelineSeedData.SC3 + "_supplemental", null));

        // Create pipeline.
        pc.createPipeline(PIPELINE_NAME);

        pc.addPipelineParameterSet(moduleOutputLists);
        pc.addPipelineParameterSet(plannedSpacecraftConfig);
        pc.addPipelineParameterSet(coaMps);

        // add nodes

        // LC
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), suppTadLcPs);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), suppTadLcPs);

        // SC1
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), suppTadSc1Ps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), suppTadSc1Ps);

        // SC2
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), suppTadSc2Ps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), suppTadSc2Ps);

        // SC3
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), suppTadSc3Ps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), suppTadSc3Ps);

        // Configure launch of next pipeline.
        PipelineLauncherParameters launcherParams = new PipelineLauncherParameters();
        launcherParams.setEnabled(true);
        launcherParams.setTriggerName(FlightDataImportPipelineSeedData.PIPELINE_NAME);
        launcherParams.setInstanceName("Launched by " + PIPELINE_NAME);

        ParameterSet launcherParamsPs = new ParameterSet(
            FLIGHT_DATA_IMPORT_LAUNCHER);
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
        TadQuarterlyPipelineSeedData seedData = new TadQuarterlyPipelineSeedData();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        seedData.loadSeedData();
        databaseService.commitTransaction();
    }

}
