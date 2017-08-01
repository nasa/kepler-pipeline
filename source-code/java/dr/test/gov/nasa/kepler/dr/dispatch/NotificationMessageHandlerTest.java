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
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.dr.ReceiveLog.State;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.Date;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class NotificationMessageHandlerTest {

    private static final String INVALID_INCOMING_DIR = "INVALID_INCOMING_DIR";
    private static final String INVALID_NM_FILE_NAME = "INVALID_NM_FILE_NAME";

    private DatabaseService databaseService;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test(expected = DispatchException.class)
    public void attemptToParseInvalidNm() {
        NotificationMessageHandler handler = new NotificationMessageHandler();
        handler.handleFile(new File(INVALID_INCOMING_DIR), new File(
            INVALID_INCOMING_DIR), new File(INVALID_INCOMING_DIR,
            INVALID_NM_FILE_NAME));
    }

    @Test
    public void testValidNmFollowedByInvalidNm() throws IOException,
        InterruptedException {
        System.setProperty("dr.importer.allowNonExistentModelMetadata", "true");

        File incomingDir = new File(Filenames.BUILD_TMP, "dr-incoming");
        File processingDir = new File(Filenames.BUILD_TMP,
            "dr-processing");

        File validNmSourceDir = new File(SocEnvVars.getLocalTestDataDir()
            + "/dr/nm-handler/valid-nm");
        copyTestData(incomingDir, processingDir, validNmSourceDir);

        NotificationMessageHandler handler = new NotificationMessageHandler();
        handler.handleFile(incomingDir, processingDir,
            processingDir.listFiles()[0]);

        File invalidNmSourceDir = new File(SocEnvVars.getLocalTestDataDir()
            + "/dr/nm-handler/invalid-nm");
        copyTestData(incomingDir, processingDir, invalidNmSourceDir);

        try {
            handler.handleFile(incomingDir, processingDir,
                processingDir.listFiles()[0]);
        } catch (Throwable e) {
            // For testing, let the exception fall through.
        }

        Thread.sleep(1000);
        LogCrud logCrud = new LogCrud();
        List<ReceiveLog> actualReceiveLogs = logCrud.retrieveReceiveLogs(
            new Date(0), new Date());

        assertEquals(1, actualReceiveLogs.size());
        assertEquals(1, actualReceiveLogs.get(0)
            .getTotalFileCount());
        assertEquals(State.SUCCESS, actualReceiveLogs.get(0)
            .getState());
    }

    private void copyTestData(File incomingDir, File processingDir,
        File sourceDir) throws IOException {
        FileUtil.cleanDir(incomingDir);
        FileUtil.cleanDir(processingDir);

        for (File file : sourceDir.listFiles()) {
            if (!file.isDirectory()) {
                if (file.getName()
                    .contains("nm.xml")) {
                    FileUtils.copyFileToDirectory(file, processingDir);
                } else {
                    FileUtils.copyFileToDirectory(file, incomingDir);
                }
            }
        }
    }

}
