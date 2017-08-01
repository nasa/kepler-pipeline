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

package gov.nasa.kepler.pi.worker;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;


/**
 * Unit test for {@link TaskLog}
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TaskLogTest {
    private static final Log log = LogFactory.getLog(TaskLogTest.class);

    private static final String TEST_LOG_MESSAGE_1 = "test log message 1";
    private static final String TEST_LOG_MESSAGE_2 = "test log message 2";

    private static final int THREAD_NUMBER_1 = 5;
    private static final int THREAD_NUMBER_2 = 6;

    private static final int INSTANCE_ID = 2;
    private static final int TASK_ID = 42;

    private static final int STEP_INDEX = 0;
    
    @Test
    public void testTaskLog() throws IOException{
        
        System.setProperty(TaskLog.TASK_LOG_DIR_PROP, "build/test/TaskLog");
        
        File expectedTaskLogFile = TaskLog.createTaskFile(INSTANCE_ID, TASK_ID, STEP_INDEX);
        expectedTaskLogFile.delete();
        
        TaskLog taskLog = new TaskLog(THREAD_NUMBER_1, INSTANCE_ID, TASK_ID, STEP_INDEX);
        taskLog.startLogging();
        
        Thread.currentThread().setName("task-" + THREAD_NUMBER_1);
        // should go to the log file
        log.info(TEST_LOG_MESSAGE_1);

        Thread.currentThread().setName("task-" + THREAD_NUMBER_2);
        // should NOT go to the log file (different thread)
        log.info(TEST_LOG_MESSAGE_2);

        taskLog.endLogging();
    
        assertTrue("log file exists", expectedTaskLogFile.exists());
        
        List<String> logContents = FileUtils.readLines(expectedTaskLogFile);
        
        assertEquals("log file # lines", 1, logContents.size());
        assertTrue("log file contents", logContents.get(0).contains(TEST_LOG_MESSAGE_1));
    }
}
