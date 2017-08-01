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

package gov.nasa.kepler.dr.dispatch;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.FileLog;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.dr.ReceiveLog.State;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.io.FileOutputStream;
import java.util.Date;
import java.util.List;

import junitx.framework.FileAssert;

/**
 * @author Miles Cote
 * 
 */
public abstract class DispatcherAbstractTest extends JMockTest {

    private static final int EXPECTED_TOTAL_FILE_COUNT = 1;

    public static final String UNIT_TEST_PATH = SocEnvVars.getLocalTestDataDir()
        + "/dr";

    protected DispatcherWrapper dispatcher;

    protected FileLog expectedFileLog;

    protected DatabaseService databaseService;
    protected FileStoreClient fsClient;
    protected LogCrud logCrud;
    protected AlertLogCrud alertLogCrud;

    protected String sourceDir;
    protected String filename;
    protected DispatcherType dispatcherType;

    protected ReflectionEquals comparer;

    protected PipelineLauncher mockPipelineLauncher;

    protected NotificationMessageHandler handler = new NotificationMessageHandler();

    protected void setUp() throws Exception {
        FileUtil.cleanDir(FilenameConstants.ACTIVEMQ_DATA);

        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    protected void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    protected void populateObjects() throws Exception {
        comparer = new ReflectionEquals();
        comparer.excludeField(".*\\.id");
        comparer.excludeField(".*\\.startProcessingTime");
        comparer.excludeField(".*\\.endProcessingTime");

        databaseService = DatabaseServiceFactory.getInstance();
        fsClient = FileStoreClientFactory.getInstance();
        logCrud = new LogCrud(databaseService);
        alertLogCrud = new AlertLogCrud(databaseService);

        ((FileStoreTestInterface) fsClient).cleanFileStore();

        databaseService.beginTransaction();
        ReceiveLog receiveLog = new ReceiveLog(new Date(), null, null);
        logCrud.createReceiveLog(receiveLog);
        databaseService.commitTransaction();

        handler.setReceiveLog(receiveLog);

        DispatchLog dispatchLog = new DispatchLog(receiveLog, dispatcherType);
        dispatchLog.setState(State.SUCCESS);
        dispatchLog.setTotalFileCount(EXPECTED_TOTAL_FILE_COUNT);

        expectedFileLog = new FileLog(dispatchLog, filename);
    }

    protected void testDispatch() throws Exception {
        populateObjects();

        // Dispatch.
        databaseService.beginTransaction();
        fsClient.beginLocalFsTransaction();

        dispatcher.addFileName(filename);
        dispatcher.dispatch();

        fsClient.commitLocalFsTransaction();
        databaseService.commitTransaction();

        FileLog actualFileLog = logCrud.retrieveLatestFileLog(dispatcherType);

        // Check database.
        comparer.assertEquals(expectedFileLog, actualFileLog);

        DrFileOperations drFileOperations = new DrFileOperations();
        BlobResult actualResult = drFileOperations.retrieveLatest(dispatcherType);
        FileOutputStream stream = new FileOutputStream(new File(
            Filenames.BUILD_TMP, filename));
        stream.write(actualResult.data());
        stream.close();

        // Check filestore.
        FileAssert.assertBinaryEquals(new File(sourceDir, filename), new File(
            Filenames.BUILD_TMP, filename));

        // Check alerts.
        List<AlertLog> alertLogs = alertLogCrud.retrieve(new Date(0),
            new Date());
        assertEquals(0, alertLogs.size());
    }

    protected void attemptToDispatchNullFile() throws Exception {
        populateObjects();

        dispatcher.addFileName(null);
        dispatcher.dispatch();

        // Check alerts.
        List<AlertLog> alertLogs = alertLogCrud.retrieve(new Date(0),
            new Date());
        assertEquals(1, alertLogs.size());
    }

}
