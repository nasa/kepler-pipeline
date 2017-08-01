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

package gov.nasa.kepler.ops.seed;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.mc.pi.PipelineLauncherPipelineModule;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.mc.uow.ModOutUowTaskGenerator;
import gov.nasa.kepler.mc.uow.SingleUowTaskGenerator;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;
import gov.nasa.kepler.tad.peer.ama.AmaPipelineModule;
import gov.nasa.kepler.tad.peer.amt.AmtPipelineModule;
import gov.nasa.kepler.tad.peer.bpa.BpaPipelineModule;
import gov.nasa.kepler.tad.peer.bpasetup.BpaSetupPipelineModule;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModule;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.kepler.tad.peer.rpts.RptsPipelineModule;
import gov.nasa.kepler.tad.peer.rptscleanup.RptsCleanupPipelineModule;
import gov.nasa.kepler.tad.peer.tadval.TadValPipelineModule;

/**
 * Creates pipeline and trigger definitions for a nominal, quarterly run of TAD
 * (1 LC, 3 SC, 1 RP).
 * 
 * @author tklaus
 */
public class TadQuarterlyPipelineSeedData extends PipelineSeedData {

    public static final String TAD_PIPELINE_NAME = "TAD Quarterly";
    public static final String TAD_TRIGGER_NAME = "TAD Quarterly Trigger";

    public static final String TAD_PARAMETERS_RP = "tad (RP)";
    public static final String TAD_PARAMETERS_SC_M3 = "tad (SC M3)";
    public static final String TAD_PARAMETERS_SC_M2 = "tad (SC M2)";
    public static final String TAD_PARAMETERS_SC_M1 = "tad (SC)";
    public static final String TAD_PARAMETERS_LC = "tad (LC)";

    public static final String LC = "lc";
    public static final String SC1 = "sc1";
    public static final String SC2 = "sc2";
    public static final String SC3 = "sc3";
    public static final String RP = "rp";

    public void loadSeedData() {
        loadSeedData(null);
    }

    public void loadSeedData(ParameterSet launcherParamSet) {
        PipelineConfigurator pc = new PipelineConfigurator();

        // retrieve common (already created) param sets
        ParameterSet moduleOutputLists = retrieveParameterSet(CommonPipelineSeedData.MODULE_OUTPUT_LISTS);
        ParameterSet plannedSpacecraftConfig = retrieveParameterSet(CommonPipelineSeedData.PLANNED_SPACECRAFT_CONFIG);
        ParameterSet coaMps = retrieveParameterSet(CoaPipelineModule.MODULE_NAME);
        ParameterSet amtMps = retrieveParameterSet(AmtPipelineModule.MODULE_NAME);
        ParameterSet amaMps = retrieveParameterSet(AmaPipelineModule.MODULE_NAME);
        ParameterSet bpaMps = retrieveParameterSet(BpaPipelineModule.MODULE_NAME);
        ParameterSet rptsMps = retrieveParameterSet(RptsPipelineModule.MODULE_NAME);
        ParameterSet maskTablePs = retrieveParameterSet(CommonPipelineSeedData.MASK_TABLE_PARAMS);

        // create pipeline-specific parameter sets
        ParameterSet tadLcPs = pc.createParamSet(TAD_PARAMETERS_LC,
            new TadParameters(LC, null));
        ParameterSet tadSc1Ps = pc.createParamSet(TAD_PARAMETERS_SC_M1,
            new TadParameters(SC1, LC));
        ParameterSet tadSc2Ps = pc.createParamSet(TAD_PARAMETERS_SC_M2,
            new TadParameters(SC2, LC));
        ParameterSet tadSc3Ps = pc.createParamSet(TAD_PARAMETERS_SC_M3,
            new TadParameters(SC3, LC));
        ParameterSet tadRpPs = pc.createParamSet(TAD_PARAMETERS_RP,
            new TadParameters(RP, LC));

        // Create pipeline.
        pc.createPipeline(TAD_PIPELINE_NAME);

        pc.addPipelineParameterSet(moduleOutputLists);
        pc.addPipelineParameterSet(plannedSpacecraftConfig);

        // add nodes

        // LC
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadLcPs, amaMps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), coaMps, tadLcPs);
        pc.addNode(retrieveModule(AmtPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), amtMps, amaMps, tadLcPs, maskTablePs);
        pc.addNode(retrieveModule(AmaPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), amaMps, tadLcPs, maskTablePs);
        pc.addNode(retrieveModule(BpaSetupPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadLcPs);
        pc.addNode(retrieveModule(BpaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), bpaMps, tadLcPs);
        pc.addNode(retrieveModule(TadValPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadLcPs);

        // SC 1
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc1Ps, amaMps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), coaMps, tadSc1Ps);
        pc.addNode(retrieveModule(AmaPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), amaMps, tadSc1Ps, maskTablePs);
        pc.addNode(retrieveModule(TadValPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc1Ps);

        // SC 2
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc2Ps, amaMps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), coaMps, tadSc2Ps);
        pc.addNode(retrieveModule(AmaPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), amaMps, tadSc2Ps, maskTablePs);
        pc.addNode(retrieveModule(TadValPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc2Ps);

        // SC 3
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc3Ps, amaMps);
        pc.addNode(retrieveModule(CoaPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), coaMps, tadSc3Ps);
        pc.addNode(retrieveModule(AmaPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), amaMps, tadSc3Ps, maskTablePs);
        pc.addNode(retrieveModule(TadValPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadSc3Ps);

        // RP
        pc.addNode(retrieveModule(MergePipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadRpPs, amaMps);
        pc.addNode(retrieveModule(RptsPipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator(), rptsMps, tadRpPs);
        pc.addNode(retrieveModule(RptsCleanupPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadRpPs);
        pc.addNode(retrieveModule(TadValPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), tadRpPs);

        if (launcherParamSet != null) {
            pc.addNode(
                retrieveModule(PipelineLauncherPipelineModule.MODULE_NAME),
                new SingleUowTaskGenerator(), launcherParamSet);
        }

        pc.createTrigger(TAD_TRIGGER_NAME);
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
