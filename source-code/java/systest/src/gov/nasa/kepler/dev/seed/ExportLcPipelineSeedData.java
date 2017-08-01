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

package gov.nasa.kepler.dev.seed;

import gov.nasa.kepler.ar.exporter.cdpp.CdppExporterModuleParameters;
import gov.nasa.kepler.ar.exporter.cdpp.CdppExporterPipelineModule;
import gov.nasa.kepler.ar.exporter.cdpp.TpsResultUowGenerator;
import gov.nasa.kepler.ar.exporter.cdpp.TpsResultUowParameters;
import gov.nasa.kepler.ar.exporter.dv.DvTimeSeriesExporterPipelineModule;
import gov.nasa.kepler.ar.exporter.dv.DvTimeSeriesExporterPipelineModuleParameters;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.mc.TargetTableParameters;
import gov.nasa.kepler.mc.pi.PipelineLauncherParameters;
import gov.nasa.kepler.mc.pi.PipelineLauncherPipelineModule;
import gov.nasa.kepler.mc.uow.CadenceUowTaskGenerator;
import gov.nasa.kepler.mc.uow.DvResultUowTaskGenerator;
import gov.nasa.kepler.mc.uow.ModOutUowTaskGenerator;
import gov.nasa.kepler.mc.uow.SingleUowTaskGenerator;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.PipelineSeedData;
import gov.nasa.kepler.ops.seed.SciencePipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;
import gov.nasa.kepler.systest.SystestCalExporterPipelineModule;
import gov.nasa.kepler.systest.SystestCatalogsExporterPipelineModule;
import gov.nasa.kepler.systest.SystestCombinedFlatFieldExporterPipelineModule;
import gov.nasa.kepler.systest.SystestDvExporterPipelineModule;
import gov.nasa.kepler.systest.SystestDvReportsExporterPipelineModule;
import gov.nasa.kepler.systest.SystestPdqExporterPipelineModule;
import gov.nasa.kepler.systest.SystestUplinkedTablesExporterPipelineModule;
import gov.nasa.kepler.tad.peer.chartable.TadProductsToCharTablePipelineModule;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * {@link PipelineSeedData} to create a pipeline to export lc data.
 * 
 * @author Miles Cote
 * 
 */
public class ExportLcPipelineSeedData extends PipelineSeedData {

    public static final String PIPELINE_NAME = "ExportLc";

    public static final String LC_TARGET_TABLE = "lc"
        + TargetTableParameters.class.getSimpleName();

    public void loadSeedData(String launcherName,
        PipelineLauncherParameters launcherParameters) {
        PipelineConfigurator pc = new PipelineConfigurator();

        // Retrieve param sets.
        ParameterSet modOutListsPs = retrieveParameterSet(CommonPipelineSeedData.MODULE_OUTPUT_LISTS);
        ParameterSet dataGen = retrieveParameterSet(CommonPipelineSeedData.DATA_GEN);
        ParameterSet packer = retrieveParameterSet(CommonPipelineSeedData.PACKER);
        ParameterSet photometerConfig = retrieveParameterSet(CommonPipelineSeedData.PHOTOMETER_CONFIG);
        ParameterSet dataRepo = retrieveParameterSet(CommonPipelineSeedData.DATA_REPO);
        ParameterSet paParams = retrieveParameterSet(SciencePipelineSeedData.PA_PARAMS);
        ParameterSet tadLc = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC);
        ParameterSet lcCadenceRange = retrieveParameterSet(SciencePipelineSeedData.QUARTERLY_LONG_CADENCE_RANGE);
        ParameterSet lcCadenceType = retrieveParameterSet(SciencePipelineSeedData.LONG_CADENCE_TYPE);
        ParameterSet fluxType = retrieveParameterSet(SciencePipelineSeedData.FLUX_TYPE);
        ParameterSet completedDvPipelineInstanceSelection = retrieveParameterSet(SciencePipelineSeedData.COMPLETED_DV_PIPELINE_INSTANCE_SELECTION_PS);

        // Create pipeline-specific parameter sets.
        ParameterSet tpsResultUowPs = pc.createParamSet(
            TpsResultUowParameters.class.getSimpleName(),
            new TpsResultUowParameters());
        ParameterSet cdppExporterModulePs = pc.createParamSet(
            CdppExporterModuleParameters.class.getSimpleName(),
            new CdppExporterModuleParameters());
        ParameterSet dvTimeSeriesExporterPipelineModulePs = pc.createParamSet(
            DvTimeSeriesExporterPipelineModuleParameters.class.getSimpleName(),
            new DvTimeSeriesExporterPipelineModuleParameters());

        // Create pipeline.
        pc.createPipeline(PIPELINE_NAME);

        pc.addPipelineParameterSet(modOutListsPs);
        pc.addPipelineParameterSet(dataGen);
        pc.addPipelineParameterSet(packer);
        pc.addPipelineParameterSet(photometerConfig);
        pc.addPipelineParameterSet(dataRepo);
        pc.addPipelineParameterSet(paParams);
        pc.addPipelineParameterSet(tpsResultUowPs);
        pc.addPipelineParameterSet(cdppExporterModulePs);
        pc.addPipelineParameterSet(tadLc);
        pc.addPipelineParameterSet(fluxType);
        pc.addPipelineParameterSet(dvTimeSeriesExporterPipelineModulePs);
        pc.addPipelineParameterSet(completedDvPipelineInstanceSelection);

        // Add nodes.
        pc.addNode(
            retrieveModule(TadProductsToCharTablePipelineModule.MODULE_NAME),
            new ModOutUowTaskGenerator());
        pc.addNode(
            retrieveModule(SystestPdqExporterPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(
            retrieveModule(SystestUplinkedTablesExporterPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(
            retrieveModule(SystestCatalogsExporterPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(
            retrieveModule(SystestCombinedFlatFieldExporterPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(
            retrieveModule(SystestCalExporterPipelineModule.MODULE_NAME),
            new CadenceUowTaskGenerator(), lcCadenceType, lcCadenceRange);
        pc.addNode(retrieveModule(CdppExporterPipelineModule.MODULE_NAME),
            new TpsResultUowGenerator());
        pc.addNode(retrieveModule(SystestDvExporterPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(
            retrieveModule(SystestDvReportsExporterPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(
            retrieveModule(DvTimeSeriesExporterPipelineModule.MODULE_NAME),
            new DvResultUowTaskGenerator());

        ParameterSet launcher = new ParameterSet(launcherName);
        launcher.setDescription("Created by " + getClass().getSimpleName());
        launcher.setParameters(new BeanWrapper<Parameters>(launcherParameters));
        parameterSetCrud.create(launcher);

        pc.addNode(retrieveModule(PipelineLauncherPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), launcher);

        pc.createTrigger(PIPELINE_NAME);
        pc.finalizePipeline();
    }

    public static void main(String[] args) {
        ExportLcPipelineSeedData seedData = new ExportLcPipelineSeedData();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        PipelineLauncherParameters launcherParameters = new PipelineLauncherParameters();
        launcherParameters.setEnabled(true);
        launcherParameters.setTriggerName(ExportLcPipelineSeedData.class.getSimpleName());
        seedData.loadSeedData("exportLcPipeline", launcherParameters);
        databaseService.commitTransaction();
    }

}
