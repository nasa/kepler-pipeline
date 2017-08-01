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

package gov.nasa.kepler.aft.gar;

import gov.nasa.kepler.aft.AbstractTestDataGenerator;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.gar.requant.RequantPipelineModule;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;

import java.io.File;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Creates an HSQLDB database seeded with one {@code GAR_REQUANT_TABLE}, 84
 * {@code GAR_RT_MEAN_BLACK_ENTRIES}, and 65536 {@code GAR_RT_REQUANT_ENTRIES}
 * seeded from test data.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class RequantTestDataGenerator extends AbstractTestDataGenerator {

    private static final Log log = LogFactory.getLog(RequantTestDataGenerator.class);

    public static final String GENERATOR_NAME = RequantPipelineModule.MODULE_NAME;
    private static final String REQUANT_TRIGGER_NAME = "REQUANT";

    private static final long MILLIS_PER_MONTH = 1000L * 60 * 60 * 24 * 30;

    public RequantTestDataGenerator() {
        super(GENERATOR_NAME);
    }

    @Override
    protected void createDatabaseContents() throws Exception {
        // This can't be in the constructor because sub-classes don't
        // necessarily have this restriction.
        if (getTestDescriptor().getType() != TestDataSetDescriptorFactory.Type.ALL_MOD_OUT) {
            throw new IllegalArgumentException(
                String.format(
                    "The requant pipeline requires that the property %s be set to %s",
                    TEST_DESCRIPTOR_PROPERTY,
                    TestDataSetDescriptorFactory.Type.ALL_MOD_OUT.toString()));
        }

        log.info(getLogName() + ": Importing pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + "requant.xml"));
    }

    @Override
    protected void process() throws Exception {
        runPipeline(REQUANT_TRIGGER_NAME);

        TransactionService transactionService = TransactionServiceFactory.getInstance();
        transactionService.beginTransaction();
        log.info(getLogName() + ": Modifying database objects");
        readyRequantTableForExport();
        transactionService.commitTransaction();
    }

    protected void readyRequantTableForExport() {
        CompressionCrud compressionCrud = new CompressionCrud();

        List<RequantTable> requantTables = compressionCrud.retrieveAllRequantTables();
        RequantTable requantTable = requantTables.get(0);

        // Update ExportTable fields.
        requantTable.setExternalId(retrievePlannedPhotometerConfigParameters().getCompressionExternalId());
        requantTable.setPlannedStartTime(new Date());
        requantTable.setPlannedEndTime(new Date(
            requantTable.getPlannedStartTime()
                .getTime() + MILLIS_PER_MONTH));
        requantTable.setState(State.UPLINKED);
        requantTable.setPipelineTask(null);
    }

    // See also RequantTestDataGenerateTest harness.
    public static void main(String[] args) {
        try {
            new RequantTestDataGenerator().generate();
        } catch (Exception e) {
            log.error(e.getMessage(), e);
            System.err.println(e.getMessage());
            System.exit(1);
        }
        System.exit(0);
    }
}
