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

package gov.nasa.kepler.mc.obslog;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dbservice.TransactionWrapper;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class ObservingLogOperationsTest {
    private static final Log log = LogFactory.getLog(ObservingLogOperationsTest.class);

    private DatabaseService databaseService = null;
    private DdlInitializer ddlInitializer = null;
    
    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     * @throws ClassNotFoundException
     * @throws IOException
     */
    @Before
    public void setUp() throws SQLException, ClassNotFoundException, IOException {

        // System.setProperty("hibernate.show_sql", "true");

        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();
    }

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     */
    @After
    public void tearDown() throws SQLException {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
    }

    @Test
    public void testSingleImportAndRetrieve() throws Exception {
        ObservingLogOperations ops = new ObservingLogOperations();
        File file = new File("test-data/observing-log/observing-log-seed.xml");

        ObservingLogImporter importer = new ObservingLogImporter();
        importTransacted(importer, file, "Created by unit test");
        
        List<TaskData> tasks = TestData.parse();

        for (TaskData td : tasks) {
            String uowString = ops.generateUowDateString(Cadence.CADENCE_LONG, td.startCadence, td.endCadence, true);
            log.info("taskId: " + td.id + ", s=" + td.startCadence + ", e=" + td.endCadence 
                + ", uow: " + uowString);
        }
    }
    
    private void importTransacted(ObservingLogImporter importer, final File file, final String description){
        TransactionWrapper.run(new Runnable() {
            @Override
            public void run(){
                ObservingLogImporter importer = new ObservingLogImporter();
                try {
                    importer.importFile(file, description);
                } catch (Exception e) {
                    System.err.println("Unable to import, caught e = " + e);
                }
            }
        });
    }
}