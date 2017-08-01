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

import gov.nasa.kepler.cal.CalPipelineModule;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.common.pi.SkyGroupIdListsParameters;
import gov.nasa.kepler.dv.DvPipelineModule;
import gov.nasa.kepler.fpg.FpgPipelineModule;
import gov.nasa.kepler.gar.hac.HacPipelineModule;
import gov.nasa.kepler.gar.hgn.HgnPipelineModule;
import gov.nasa.kepler.gar.huffman.HuffmanPipelineModule;
import gov.nasa.kepler.gar.requant.RequantPipelineModule;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.pi.PipelineLauncherPipelineModule;
import gov.nasa.kepler.pa.PaCoaModuleParameters;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.pdc.PdcPipelineModule;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;
import gov.nasa.kepler.ppa.pad.PadPipelineModule;
import gov.nasa.kepler.ppa.pag.PagPipelineModule;
import gov.nasa.kepler.ppa.pmd.PmdPipelineModule;
import gov.nasa.kepler.prf.PrfPipelineModule;
import gov.nasa.kepler.sggen.SkyGroupGenPipelineModule;
import gov.nasa.kepler.tad.peer.AmaModuleParameters;
import gov.nasa.kepler.tad.peer.AmtModuleParameters;
import gov.nasa.kepler.tad.peer.BpaModuleParameters;
import gov.nasa.kepler.tad.peer.CoaModuleParameters;
import gov.nasa.kepler.tad.peer.MaskTableParameters;
import gov.nasa.kepler.tad.peer.RptsModuleParameters;
import gov.nasa.kepler.tad.peer.ama.AmaPipelineModule;
import gov.nasa.kepler.tad.peer.amt.AmtPipelineModule;
import gov.nasa.kepler.tad.peer.bpa.BpaPipelineModule;
import gov.nasa.kepler.tad.peer.bpasetup.BpaSetupPipelineModule;
import gov.nasa.kepler.tad.peer.coa.CoaPipelineModule;
import gov.nasa.kepler.tad.peer.merge.MergePipelineModule;
import gov.nasa.kepler.tad.peer.rpts.RptsPipelineModule;
import gov.nasa.kepler.tad.peer.rptscleanup.RptsCleanupPipelineModule;
import gov.nasa.kepler.tad.peer.tadval.TadValPipelineModule;
import gov.nasa.kepler.tps.TpsPipelineModule;

/**
 * Loads common ParameterSets used by several pipelines
 * 
 * @author tklaus
 * 
 */
public class CommonPipelineSeedData extends PipelineSeedData {

    public static final String PLANNED_SPACECRAFT_CONFIG = "plannedSpacecraftConfig";
    public static final String PLANNED_PHOTOMTER_CONFIG = "plannedPhotometerConfig";
    public static final String SKY_GROUP_ID_LISTS = "skyGroupIdLists";
    public static final String MODULE_OUTPUT_LISTS = "moduleOutputLists";
    public static final String DATA_REPO = "dataRepo";
    public static final String MASK_TABLE_PARAMS = "maskTableParams";
    public static final String TARGET_LIST_PARAMS = "targetList";
    public static final String PHOTOMETER_CONFIG = "photometerConfig";
    public static final String PACKER = "packer";
    public static final String DATA_GEN = "dataGen";
    public static final String CADENCE_TYPE = "cadenceType";
    public static final String DEV_SETUP_PIPELINE_NAME = "devSetup";

    public static final String LC_TARGET_TABLE = "lc"
        + TargetTableParameters.class.getSimpleName();

    public static final String SC_M1_TARGET_TABLE = "scM1"
        + TargetTableParameters.class.getSimpleName();

    private static final int CAL_MIN_MEMORY = 2000;

    public CommonPipelineSeedData() {
    }

    public void loadSeedData() {
        PipelineConfigurator pc = new PipelineConfigurator();

        // Create shared param sets.
        pc.createParamSet(SKY_GROUP_ID_LISTS, new SkyGroupIdListsParameters());
        pc.createParamSet(MODULE_OUTPUT_LISTS,
            new ModuleOutputListsParameters());
        pc.createParamSet(PLANNED_SPACECRAFT_CONFIG,
            new PlannedSpacecraftConfigParameters());

        DataRepoParameters dataRepoParams = new DataRepoParameters(
            SocEnvVars.getLocalDataDir());
        pc.createParamSet(DATA_REPO, dataRepoParams);

        /*
         * These are defined here because these parameter sets only need to be
         * created once, and shared
         */
        pc.createParamSet(CoaPipelineModule.MODULE_NAME,
            new CoaModuleParameters());
        pc.createParamSet(PaPipelineModule.MODULE_NAME,
            new PaCoaModuleParameters());
        pc.createParamSet(AmtPipelineModule.MODULE_NAME,
            new AmtModuleParameters());
        pc.createParamSet(AmaPipelineModule.MODULE_NAME,
            new AmaModuleParameters());
        pc.createParamSet(BpaPipelineModule.MODULE_NAME,
            new BpaModuleParameters());
        pc.createParamSet(RptsPipelineModule.MODULE_NAME,
            new RptsModuleParameters());
        pc.createParamSet(MASK_TABLE_PARAMS, new MaskTableParameters());
        TargetListParameters targetListParameters = new TargetListParameters();
        targetListParameters.setTargetListNames(new String[0]);
        pc.createParamSet(TARGET_LIST_PARAMS, targetListParameters);

        // create modules

        // Monthly Science Processing modules
        PipelineModuleDefinition calModuleDef = pc.createModule(
            CalPipelineModule.MODULE_NAME, CalPipelineModule.class,
            CalPipelineModule.MODULE_NAME);
        calModuleDef.setMinMemoryMegaBytes(CAL_MIN_MEMORY);
        pc.createModule(PaPipelineModule.MODULE_NAME, PaPipelineModule.class,
            PaPipelineModule.MODULE_NAME);
        pc.createModule(PdcPipelineModule.MODULE_NAME, PdcPipelineModule.class,
            PdcPipelineModule.MODULE_NAME);
        pc.createModule(TpsPipelineModule.MODULE_NAME, TpsPipelineModule.class,
            TpsPipelineModule.MODULE_NAME);
        pc.createModule(PmdPipelineModule.MODULE_NAME, PmdPipelineModule.class,
            PmdPipelineModule.MODULE_NAME);
        pc.createModule(PagPipelineModule.MODULE_NAME, PagPipelineModule.class,
            PagPipelineModule.MODULE_NAME);
        pc.createModule(PadPipelineModule.MODULE_NAME, PadPipelineModule.class,
            PadPipelineModule.MODULE_NAME);
        pc.createModule(DvPipelineModule.MODULE_NAME, DvPipelineModule.class,
            DvPipelineModule.MODULE_NAME);

        // Commissioning FPG/PRF modules
        pc.createModule(FpgPipelineModule.MODULE_NAME, FpgPipelineModule.class,
            FpgPipelineModule.MODULE_NAME);
        pc.createModule(PrfPipelineModule.MODULE_NAME, PrfPipelineModule.class,
            PrfPipelineModule.MODULE_NAME);

        // sggen module
        pc.createModule(SkyGroupGenPipelineModule.MODULE_NAME,
            SkyGroupGenPipelineModule.class,
            SkyGroupGenPipelineModule.MODULE_NAME);

        // Compression modules
        pc.createModule(RequantPipelineModule.MODULE_NAME,
            RequantPipelineModule.class, RequantPipelineModule.MODULE_NAME);
        pc.createModule(HgnPipelineModule.MODULE_NAME, HgnPipelineModule.class,
            HgnPipelineModule.MODULE_NAME);
        pc.createModule(HacPipelineModule.MODULE_NAME, HacPipelineModule.class,
            HacPipelineModule.MODULE_NAME);
        pc.createModule(HuffmanPipelineModule.MODULE_NAME,
            HuffmanPipelineModule.class, HuffmanPipelineModule.MODULE_NAME);

        // TAD modules
        pc.createModule(MergePipelineModule.MODULE_NAME,
            MergePipelineModule.class, MergePipelineModule.MODULE_NAME);
        pc.createModule(CoaPipelineModule.MODULE_NAME, CoaPipelineModule.class,
            CoaPipelineModule.MODULE_NAME);
        pc.createModule(AmtPipelineModule.MODULE_NAME, AmtPipelineModule.class,
            AmtPipelineModule.MODULE_NAME);
        pc.createModule(AmaPipelineModule.MODULE_NAME, AmaPipelineModule.class,
            AmaPipelineModule.MODULE_NAME);
        pc.createModule(BpaSetupPipelineModule.MODULE_NAME,
            BpaSetupPipelineModule.class, BpaSetupPipelineModule.MODULE_NAME);
        pc.createModule(BpaPipelineModule.MODULE_NAME, BpaPipelineModule.class,
            BpaPipelineModule.MODULE_NAME);
        pc.createModule(RptsPipelineModule.MODULE_NAME,
            RptsPipelineModule.class, RptsPipelineModule.MODULE_NAME);
        pc.createModule(RptsCleanupPipelineModule.MODULE_NAME,
            RptsCleanupPipelineModule.class,
            RptsCleanupPipelineModule.MODULE_NAME);
        pc.createModule(TadValPipelineModule.MODULE_NAME,
            TadValPipelineModule.class, TadValPipelineModule.MODULE_NAME);

        // misc. modules
        pc.createModule(PipelineLauncherPipelineModule.MODULE_NAME,
            PipelineLauncherPipelineModule.class,
            PipelineLauncherPipelineModule.MODULE_NAME);

    }

    public static void main(String[] args) {
        CommonPipelineSeedData seedData = new CommonPipelineSeedData();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        seedData.loadSeedData();
        databaseService.commitTransaction();
    }

}
