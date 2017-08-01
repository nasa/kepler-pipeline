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

package gov.nasa.kepler.aft.etem;

import gov.nasa.kepler.aft.AbstractTestDataGenerator;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptor;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;
import gov.nasa.kepler.aft.seeder.ConfigMapSeeder;
import gov.nasa.kepler.aft.seeder.RefPixelSeeder;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineLauncherPipelineModule;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.dispatch.NotificationMessageHandler;
import gov.nasa.kepler.dr.pmrf.PmrfDispatcher;
import gov.nasa.kepler.etem.PmrfFits;
import gov.nasa.kepler.etem2.DataGenDirManager;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PmrfLog.PmrfType;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.mc.DataRepoParameters;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.kepler.ops.seed.CommonPipelineSeedData;
import gov.nasa.kepler.ops.seed.TadQuarterlyPipelineSeedData;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.File;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Date;

import javax.transaction.HeuristicCommitException;
import javax.transaction.HeuristicMixedException;
import javax.transaction.HeuristicRollbackException;
import javax.transaction.RollbackException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Creates an HSQLDB database containing the necessary and sufficient DR tables
 * to run Automated Feature Tests (AFTs) seeded by running the relevant pipeline
 * modules.
 * 
 * @author Forrest Girouard
 * @author Todd Klaus
 * 
 */
public class EtemTestDataGenerator extends AbstractTestDataGenerator {

    private static final Log log = LogFactory.getLog(EtemTestDataGenerator.class);

    public static final String GENERATOR_NAME = "etem";

    private static final String LC_TRIGGER_NAME = "DATAGEN_LC";
    private static final String SC_TRIGGER_NAME = "DATAGEN_SC";
    private static final String DATAGEN_LC_PARAMETERS_NAME = CommonPipelineSeedData.DATA_GEN
        + QuarterlyPipelineLauncherPipelineModule.parameterSetNameVariantString("LC");
    private static final String DATAGEN_SC_PARAMETERS_NAME = CommonPipelineSeedData.DATA_GEN
        + QuarterlyPipelineLauncherPipelineModule.parameterSetNameVariantString("SC");

    private DataGenDirManager dataGenDirManager;

    private PlannedPhotometerConfigParameters photometerConfigParameters;

    public EtemTestDataGenerator() {
        super(GENERATOR_NAME);
    }

    @Override
    protected void createDatabaseContents() throws Exception {

        log.info(getLogName() + ": Seeding etem pipeline");

        ParameterSet moduleOutputListsParameterSet = retrieveParameterSet(CommonPipelineSeedData.MODULE_OUTPUT_LISTS);
        if (moduleOutputListsParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set",
                CommonPipelineSeedData.MODULE_OUTPUT_LISTS));
        }
        ParameterSet tadLcParameterSet = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC);
        if (tadLcParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set",
                TadQuarterlyPipelineSeedData.TAD_PARAMETERS_LC));
        }
        TadParameters lcTadParameters = tadLcParameterSet.parametersInstance();

        ParameterSet tadSc1ParameterSet = retrieveParameterSet(TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M1);
        if (tadSc1ParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set",
                TadQuarterlyPipelineSeedData.TAD_PARAMETERS_SC_M1));
        }
        TadParameters scTadParameters = tadSc1ParameterSet.parametersInstance();

        photometerConfigParameters = retrievePlannedPhotometerConfigParameters();

        ParameterSet dataRepoParameterSet = retrieveParameterSet(CommonPipelineSeedData.DATA_REPO);
        if (dataRepoParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set",
                CommonPipelineSeedData.DATA_REPO));
        }

        String etemDir = TestDataSetDescriptorFactory.getEtemDir(getTestDescriptor());
        FileUtil.cleanDir(etemDir);

        String lcEtemDir = null;
        String scEtemDir = null;
        if (getCadenceType() == CadenceType.LONG) {
            lcEtemDir = etemDir;
            TestDataSetDescriptorFactory.Type type = TestDataSetDescriptorFactory.Type.valueOf(getTestDescriptor());
            Class<? extends TestDataSetDescriptor> testDescriptorClass = type.getSignificantOther();
            if (testDescriptorClass != null) {
                scEtemDir = TestDataSetDescriptorFactory.getEtemDir(testDescriptorClass.newInstance());
            }
        } else {
            scEtemDir = etemDir;
            TestDataSetDescriptorFactory.Type type = TestDataSetDescriptorFactory.Type.valueOf(getTestDescriptor());
            Class<? extends TestDataSetDescriptor> testDescriptorClass = type.getSignificantOther();
            if (testDescriptorClass != null) {
                lcEtemDir = TestDataSetDescriptorFactory.getEtemDir(testDescriptorClass.newInstance());
            }
        }

        PackerParameters packerParameters = retrievePackerParameters();

        DataGenParameters lcDataGenParameters = createDataGenParameters(
            DATAGEN_LC_PARAMETERS_NAME, lcEtemDir != null ? lcEtemDir
                : scEtemDir);
        DataGenParameters scDataGenParameters = createDataGenParameters(
            DATAGEN_SC_PARAMETERS_NAME, scEtemDir != null ? scEtemDir
                : lcEtemDir);

        if (getCadenceType() == CadenceType.LONG) {
            dataGenDirManager = new DataGenDirManager(lcDataGenParameters,
                packerParameters, lcTadParameters);
        } else {
            dataGenDirManager = new DataGenDirManager(scDataGenParameters,
                packerParameters, scTadParameters);
        }

        // Only create pipelines if they don't already exist.
        TriggerDefinition trigger = new TriggerDefinitionCrud().retrieve(LC_TRIGGER_NAME);
        if (trigger == null) {
            log.info(getLogName() + ": Importing pipeline configuration");
            new PipelineConfigurationOperations().importPipelineConfiguration(new File(
                SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                    + GENERATOR_NAME + ".xml"));
        }

        seedSpice();
    }

    private PackerParameters retrievePackerParameters() {

        ParameterSet packerParametersSet = retrieveParameterSet(CommonPipelineSeedData.PACKER);
        if (packerParametersSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", CommonPipelineSeedData.PACKER));
        }

        return packerParametersSet.parametersInstance();
    }

    private DataGenParameters createDataGenParameters(String parameterSetName,
        String etemDir) {

        ParameterSet dataGenParametersSet = retrieveParameterSet(parameterSetName);
        if (dataGenParametersSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", parameterSetName));
        }
        DataGenParameters dataGenParameters = dataGenParametersSet.parametersInstance();

        dataGenParameters.setDataGenOutputPath(etemDir);
        new PipelineOperations().updateParameterSet(dataGenParametersSet,
            dataGenParameters, false);

        return dataGenParameters;
    }

    @Override
    protected void process() throws Exception, HeuristicRollbackException,
        HeuristicMixedException, HeuristicCommitException, RollbackException {

        if (getCadenceType() == CadenceType.LONG) {
            runPipeline(LC_TRIGGER_NAME);
        } else {
            runPipeline(SC_TRIGGER_NAME);
        }

        TransactionService transactionService = TransactionServiceFactory.getInstance();
        transactionService.beginTransaction();

        // Clear the cache to make sure we see the changes made by the
        // workers.
        DatabaseServiceFactory.getInstance()
            .clear();

        if (new File(dataGenDirManager.getConfigMapExportDir()).exists()) {
            log.info(getLogName() + ": Seeding ConfigMap files");
            File dir = new File(dataGenDirManager.getConfigMapExportDir());
            new ConfigMapSeeder(getTestDescriptor(), dir.getAbsolutePath()).seed();
        }

        ingestPixels();

        transactionService.commitTransaction();
    }

    private void ingestPixels() throws Exception {

        String dataDirectory = TestDataSetDescriptorFactory.getLocalDataDir(getTestDescriptor());
        DataRepoParameters dataRepoParameters = new DataRepoParameters();
        dataRepoParameters.setDataRepoPath(dataDirectory);

        log.info(getLogName() + ": Seeding PMRF files");
        receivePmrfs();

        switch (getCadenceType()) {
            case LONG:
                log.info(String.format("%s: %s: Seeding reference pixels",
                    getLogName(), LC_TRIGGER_NAME));
                new RefPixelSeeder(getTestDescriptor(),
                    dataGenDirManager.getRpDir() + "/contact0").seed();

                log.info(String.format("%s: %s: Seeding LC FITS pixels",
                    getLogName(), LC_TRIGGER_NAME));
                new LcFitsPixelSeeder(getTestDescriptor(),
                    dataGenDirManager.getCadenceFitsDir()).seed();
                break;

            case SHORT:
                log.info(String.format("%s: %s: Seeding SC FITS pixels",
                    getLogName(), SC_TRIGGER_NAME));
                new ScFitsPixelSeeder(getTestDescriptor(),
                    dataGenDirManager.getCadenceFitsDir()).seed();
                break;

            default:
                throw new IllegalStateException("Unknown cadenceType: "
                    + getCadenceType());
        }
    }

    private void receivePmrfs() {
        String pmrfPrefix = pmrfPrefix();

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();

        ReceiveLog receiveLog = new ReceiveLog(new Date(), null, null);
        new LogCrud(databaseService).createReceiveLog(receiveLog);

        NotificationMessageHandler handler = new NotificationMessageHandler();
        handler.setReceiveLog(receiveLog);

        DispatcherWrapper pmrfDispatcher;

        switch (getCadenceType()) {
            case LONG:
                pmrfDispatcher = new DispatcherWrapper(new PmrfDispatcher(
                    PmrfType.LONG_CADENCE_TARGET),
                    DispatcherType.LONG_CADENCE_TARGET_PMRF,
                    dataGenDirManager.getPmrfDir(photometerConfigParameters),
                    handler);
                dispatchPmrf(pmrfDispatcher, pmrfPrefix + "_lcm.fits");

                pmrfDispatcher = new DispatcherWrapper(new PmrfDispatcher(
                    PmrfType.LONG_CADENCE_COLLATERAL),
                    DispatcherType.LONG_CADENCE_COLLATERAL_PMRF,
                    dataGenDirManager.getPmrfDir(photometerConfigParameters),
                    handler);
                dispatchPmrf(pmrfDispatcher, pmrfPrefix + "_lcc.fits");

                pmrfDispatcher = new DispatcherWrapper(new PmrfDispatcher(
                    PmrfType.BACKGROUND), DispatcherType.BACKGROUND_PMRF,
                    dataGenDirManager.getPmrfDir(photometerConfigParameters),
                    handler);
                dispatchPmrf(pmrfDispatcher, pmrfPrefix + "_bgm.fits");
                break;

            case SHORT:
                pmrfDispatcher = new DispatcherWrapper(new PmrfDispatcher(
                    PmrfType.SHORT_CADENCE_TARGET),
                    DispatcherType.SHORT_CADENCE_TARGET_PMRF,
                    dataGenDirManager.getPmrfDir(photometerConfigParameters),
                    handler);
                dispatchPmrf(pmrfDispatcher, pmrfPrefix + "_scm.fits");

                pmrfDispatcher = new DispatcherWrapper(new PmrfDispatcher(
                    PmrfType.SHORT_CADENCE_COLLATERAL),
                    DispatcherType.SHORT_CADENCE_COLLATERAL_PMRF,
                    dataGenDirManager.getPmrfDir(photometerConfigParameters),
                    handler);
                dispatchPmrf(pmrfDispatcher, pmrfPrefix + "_scc.fits");
                break;

            default:
                throw new IllegalStateException("Unknown cadenceType: "
                    + getCadenceType());
        }
    }

    private String pmrfPrefix() {
        Date pmrfDate = ModifiedJulianDate.mjdToDate(PmrfFits.PMRF_MJD);
        String dmcTimestamp = DateUtils.formatLikeDmc(pmrfDate);

        int targetTableId;
        switch (getCadenceType()) {
            case LONG:
                targetTableId = photometerConfigParameters.getLctExternalId();
                break;
            case SHORT:
                targetTableId = photometerConfigParameters.getSctExternalId();
                break;
            default:
                throw new IllegalStateException("Unknown cadenceType: "
                    + getCadenceType());
        }

        NumberFormat formatter = new DecimalFormat("000");
        String targetTableIdString = formatter.format(Math.abs(targetTableId));
        String apertureTableIdString = formatter.format(photometerConfigParameters.getTadExternalId());

        String pmrfPrefix = "kplr" + dmcTimestamp + "-" + targetTableIdString
            + "-" + apertureTableIdString;

        return pmrfPrefix;
    }

    private void dispatchPmrf(DispatcherWrapper dispatcher, String filename) {
        // Dispatch.
        dispatcher.addFileName(filename);
        dispatcher.dispatch();
    }

    public static void main(String[] args) {
        try {
            new EtemTestDataGenerator().generate();
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            System.err.println(e.getMessage());
            System.exit(1);
        }
        System.exit(0);
    }
}
