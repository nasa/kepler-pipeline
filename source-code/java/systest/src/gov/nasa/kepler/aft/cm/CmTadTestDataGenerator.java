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

package gov.nasa.kepler.aft.cm;

import gov.nasa.kepler.aft.AbstractTestDataGenerator;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Creates an HSQLDB database containing the necessary and sufficient CM and TAD
 * tables to run ETEM seeded by running the relevant pipeline modules.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class CmTadTestDataGenerator extends AbstractTestDataGenerator {

    private static final Log log = LogFactory.getLog(CmTadTestDataGenerator.class);

    public static final String GENERATOR_NAME = "cmtad";

    public static final String TARGET_IMPORT_TRIGGER_NAME = "TARGET_IMPORT";
    public static final String TAD_LC_TRIGGER_NAME = "TAD_LC";
    public static final String TAD_SC_TRIGGER_NAME = "TAD_SC";
    public static final String TAD_RP_TRIGGER_NAME = "TAD_RP";

    public CmTadTestDataGenerator() {
        super(GENERATOR_NAME);
    }

    @Override
    public void createDatabaseContents() throws Exception {

        log.info(getLogName() + ": Importing pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + GENERATOR_NAME + ".xml"));

        seedSpice();
    }

    @Override
    protected void process() throws Exception {

        TransactionService transactionService = TransactionServiceFactory.getInstance();
        runPipeline(TARGET_IMPORT_TRIGGER_NAME);

        // Clear the cache to make sure we see the changes made by the
        // target importer pipeline.
        transactionService.beginTransaction();
        DatabaseServiceFactory.getInstance()
            .clear();
        transactionService.commitTransaction();

        runPipeline(TAD_LC_TRIGGER_NAME);
        runPipeline(TAD_SC_TRIGGER_NAME);
        runPipeline(TAD_RP_TRIGGER_NAME);

        transactionService.beginTransaction();

        // Clear the cache to make sure we see the changes made by the
        // workers.
        DatabaseServiceFactory.getInstance()
            .clear();

        uplinkTables();
        transactionService.commitTransaction();
    }

    private void uplinkTables() {

        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud(
            DatabaseServiceFactory.getInstance());

        ParameterSet tadLcParameterSet = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC);
        TadParameters tadLcParameters = tadLcParameterSet.parametersInstance();
        TargetListSet longCadenceSet = targetSelectionCrud.retrieveTargetListSet(tadLcParameters.getTargetListSetName());

        ParameterSet tadSc1ParameterSet = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M1);
        TadParameters tadSc1Parameters = tadSc1ParameterSet.parametersInstance();
        TargetListSet shortCadenceSet = targetSelectionCrud.retrieveTargetListSet(tadSc1Parameters.getTargetListSetName());

        ParameterSet tadRpParameterSet = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_RP);
        TadParameters tadRpParameters = tadRpParameterSet.parametersInstance();
        TargetListSet referencePixelSet = targetSelectionCrud.retrieveTargetListSet(tadRpParameters.getTargetListSetName());

        TargetTable longCadenceTargetTable = longCadenceSet.getTargetTable();
        TargetTable backgroundTargetTable = longCadenceSet.getBackgroundTable();
        MaskTable longCadenceMaskTable = longCadenceTargetTable.getMaskTable();
        MaskTable backgroundMaskTable = backgroundTargetTable.getMaskTable();
        TargetTable referencePixelTargetTable = referencePixelSet.getTargetTable();
        TargetTable shortCadenceTargetTable = shortCadenceSet.getTargetTable();

        PlannedPhotometerConfigParameters plannedPhotometerConfigParameters = retrievePlannedPhotometerConfigParameters();
        longCadenceTargetTable.setExternalId(plannedPhotometerConfigParameters.getLctExternalId());
        backgroundTargetTable.setExternalId(plannedPhotometerConfigParameters.getBgpExternalId());
        longCadenceMaskTable.setExternalId(plannedPhotometerConfigParameters.getTadExternalId());
        backgroundMaskTable.setExternalId(plannedPhotometerConfigParameters.getBadExternalId());
        referencePixelTargetTable.setExternalId(plannedPhotometerConfigParameters.getRptExternalId());
        shortCadenceTargetTable.setExternalId(plannedPhotometerConfigParameters.getSctExternalId());

        // Mark tls's uplinked.
        longCadenceSet.setState(State.UPLINKED);
        shortCadenceSet.setState(State.UPLINKED);
        referencePixelSet.setState(State.UPLINKED);

        // Mark tables as uplinked.
        longCadenceTargetTable.setState(State.UPLINKED);
        backgroundTargetTable.setState(State.UPLINKED);
        longCadenceMaskTable.setState(State.UPLINKED);
        backgroundMaskTable.setState(State.UPLINKED);
        referencePixelTargetTable.setState(State.UPLINKED);
        shortCadenceTargetTable.setState(State.UPLINKED);
    }

    public static void main(String[] args) {
        try {
            new CmTadTestDataGenerator().generate();
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            System.err.println(e.getMessage());
            System.exit(1);
        }
        System.exit(0);
    }
}
