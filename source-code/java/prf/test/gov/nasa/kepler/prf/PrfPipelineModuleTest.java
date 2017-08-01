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

package gov.nasa.kepler.prf;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import junit.framework.JUnit4TestAdapter;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;

/**
 * @author Forrest Girouard
 * 
 */
public class PrfPipelineModuleTest extends AbstractPrfPipelineModuleTest {

    private static final Log log = LogFactory.getLog(PrfPipelineModuleTest.class);

    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer = null;

    public PrfPipelineModuleTest() {
    }

    public static junit.framework.Test suite() {
        return new JUnit4TestAdapter(PrfPipelineModuleTest.class);
    }

    @BeforeClass
    public static void initialize() throws Exception {
        System.setProperty(DefaultProperties.MODULE_XML_DIR_PROPERTY_NAME,
            "xml");
    }

    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();

        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        FileUtils.forceMkdir(MATLAB_WORKING_DIR);
    }

    @After
    public void tearDown() throws Exception {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
        FileUtils.cleanDirectory(MATLAB_WORKING_DIR);
    }

    // SOC_REQ 252.PA.2 J.taskType
    @Test
    public void taskType() {

        assertEquals("unit of work", ModOutCadenceUowTask.class,
            getPipelineModule().unitOfWorkTaskType());
    }


    @Ignore
    public void processTaskTest() {

        processTask();
        getMockery().assertIsSatisfied();
    }

    // SOC_REQ PI2: J.forceFatalException
    @Test(expected = ModuleFatalProcessingException.class)
    public void forceFatalException() {

        setForceFatalException(true);
        try {
            processTask();
            fail("expected fatal processing exception");
        } catch (ModuleFatalProcessingException mfpe) {
            assertNotNull("exception message null", mfpe.getMessage());
            throw mfpe;
        }
    }

    @Test(expected = ModuleFatalProcessingException.class)
    public void forceMultipleTables() {

        setForceMultipleTables(true);
        processTask();
    }


    private void processTask() {

        populateObjects();
        createInputs(true);

        PipelineTask task = getPipelineModule().getPipelineTask();
        try {
            databaseService.beginTransaction();
            log.info("Running prf ...");
            getPipelineModule().processTask(createPipelineInstance(), task);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        log.info("Completed prf test.");
    }

}
