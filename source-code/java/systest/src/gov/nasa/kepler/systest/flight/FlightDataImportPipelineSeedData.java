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
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.mc.uow.SingleUowTaskGenerator;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.PipelineSeedData;
import gov.nasa.kepler.pi.pipeline.PipelineConfigurator;

/**
 * {@link PipelineSeedData} to create a pipeline to import flight data.
 * 
 * @author Miles Cote
 * 
 */
public class FlightDataImportPipelineSeedData extends PipelineSeedData {

    public static final String PIPELINE_NAME = "Flight Data Import";
    public static final String TRIGGER_NAME = "Flight Data Import";

    private static final String COMPRESSION_PATH_SUFFIX = "flight/so/tables/compression/id200";
    private static final String CONFIG_MAP_PATH_SUFFIX = "flight/moc/config-map/09121_03_jhall_config_map_ID46";
    private static final String ANCILLARY_PATH_SUFFIX = "flight/commissioning/c043_cdpp/data/ancillary";
    private static final String PMRF_PATH_SUFFIX = "flight/commissioning/dmc/pmrf/cdpp_ID014";
    private static final String CADENCE_FITS_PATH_SUFFIX = "flight/commissioning/c043_cdpp/data_dmc_k8a_reprocessed/lc";

    private static final String COMPRESSION_SRC_DIR = SocEnvVars.getLocalDataDir() + "/"
        + COMPRESSION_PATH_SUFFIX;
    private static final String CONFIG_MAP_SRC_DIR = SocEnvVars.getLocalDataDir() + "/"
        + CONFIG_MAP_PATH_SUFFIX;
    private static final String ANCILLARY_SRC_DIR = "/path/to/"
        + ANCILLARY_PATH_SUFFIX;
    private static final String PMRF_SRC_DIR = "/path/to/"
        + PMRF_PATH_SUFFIX;
    private static final String CADENCE_FITS_SRC_DIR = "/path/to/"
        + CADENCE_FITS_PATH_SUFFIX;

    private static final String PMRF_OUTPUT_DIR = "/path/to/"
        + PMRF_PATH_SUFFIX;
    private static final String CADENCE_FITS_OUTPUT_DIR = "/path/to/"
        + CADENCE_FITS_PATH_SUFFIX;

    private static final String CONFIG_MAP_FLIGHT_DATA_COPIER = "Config Map Flight Data Copier";
    private static final String ANCILLARY_FLIGHT_DATA_COPIER = "Ancillary Flight Data Copier";
    private static final String PMRF_FLIGHT_DATA_COPIER = "PMRF Flight Data Copier";
    private static final String CADENCE_FITS_FLIGHT_DATA_COPIER = "Cadence Fits Flight Data Copier";

    public void loadSeedData() {
        PipelineConfigurator pc = new PipelineConfigurator();

        // Create modules.
        pc.createModule(CompressionXmlImportPipelineModule.MODULE_NAME,
            CompressionXmlImportPipelineModule.class);
        pc.createModule(FitsTrimmerPipelineModule.MODULE_NAME,
            FitsTrimmerPipelineModule.class);
        pc.createModule(FlightDataCopierPipelineModule.MODULE_NAME,
            FlightDataCopierPipelineModule.class);

        // Retrieve param sets.
        ParameterSet moduleOutputLists = retrieveParameterSet(CommonPipelineSeedData.MODULE_OUTPUT_LISTS);

        // Create pipeline-specific parameter sets.
        ParameterSet compressionXmlImportPs = pc.createParamSet(
            CompressionXmlImportParameters.class.getSimpleName(),
            new CompressionXmlImportParameters(COMPRESSION_SRC_DIR));
        ParameterSet fitsTrimmerPs = pc.createParamSet(
            FitsTrimmerParameters.class.getSimpleName(),
            new FitsTrimmerParameters(PMRF_SRC_DIR, CADENCE_FITS_SRC_DIR,
                PMRF_OUTPUT_DIR, CADENCE_FITS_OUTPUT_DIR));
        ParameterSet configMapFlightDataCopierPs = pc.createParamSet(
            CONFIG_MAP_FLIGHT_DATA_COPIER, new FlightDataCopierParameters(
                CONFIG_MAP_SRC_DIR));
        ParameterSet ancillaryFlightDataCopierPs = pc.createParamSet(
            ANCILLARY_FLIGHT_DATA_COPIER, new FlightDataCopierParameters(
                ANCILLARY_SRC_DIR));
        ParameterSet pmrfFlightDataCopierPs = pc.createParamSet(
            PMRF_FLIGHT_DATA_COPIER, new FlightDataCopierParameters(
                PMRF_OUTPUT_DIR));
        ParameterSet cadenceFitsFlightDataCopierPs = pc.createParamSet(
            CADENCE_FITS_FLIGHT_DATA_COPIER, new FlightDataCopierParameters(
                CADENCE_FITS_OUTPUT_DIR));

        // Create pipeline.
        pc.createPipeline(PIPELINE_NAME);

        pc.addPipelineParameterSet(moduleOutputLists);
        pc.addPipelineParameterSet(compressionXmlImportPs);
        pc.addPipelineParameterSet(fitsTrimmerPs);

        // Add nodes.
        pc.addNode(
            retrieveModule(CompressionXmlImportPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(retrieveModule(FitsTrimmerPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator());
        pc.addNode(retrieveModule(FlightDataCopierPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), configMapFlightDataCopierPs);
        pc.addNode(retrieveModule(FlightDataCopierPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), ancillaryFlightDataCopierPs);
        pc.addNode(retrieveModule(FlightDataCopierPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), pmrfFlightDataCopierPs);
        pc.addNode(retrieveModule(FlightDataCopierPipelineModule.MODULE_NAME),
            new SingleUowTaskGenerator(), cadenceFitsFlightDataCopierPs);

        pc.createTrigger(TRIGGER_NAME);
        pc.finalizePipeline();
    }

    public static void main(String[] args) {
        FlightDataImportPipelineSeedData seedData = new FlightDataImportPipelineSeedData();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.beginTransaction();
        seedData.loadSeedData();
        databaseService.commitTransaction();
    }

}
