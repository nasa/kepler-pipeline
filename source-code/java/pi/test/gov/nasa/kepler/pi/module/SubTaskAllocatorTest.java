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

package gov.nasa.kepler.pi.module;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.pi.module.SubTaskServer.ResponseType;
import gov.nasa.spiffy.common.collect.Pair;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

public class SubTaskAllocatorTest {
    private static final Log log = LogFactory.getLog(SubTaskAllocatorTest.class);

    private static final int GROUP_0 = 0;
    private static final int GROUP_1 = 1;
    
    private static final int SUBTASK_0 = 0;
    private static final int SUBTASK_1 = 1;
    private static final int SUBTASK_2 = 2;
    private static final int SUBTASK_3 = 3;
    private static final int SUBTASK_4 = 4;
    
    @Test
    public void testSingleGroup4() throws Exception {
        header();
        
        InputsHandler inputsHandler = new InputsHandler();
        InputsGroup group = inputsHandler.createGroup();
        
        group.add(SUBTASK_0);
        group.add(SUBTASK_1,SUBTASK_2);
        group.add(SUBTASK_3);
        
        SubTaskAllocator allocator = new SubTaskAllocator(inputsHandler);
        
        verifyGetNext(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, GROUP_0, SUBTASK_1);
        verifyGetNext(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);
        
        verifyReport(allocator, GROUP_0, SUBTASK_1);
        //verifyGetNext(allocator);

        verifyReport(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, GROUP_0, SUBTASK_3);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);

        verifyReport(allocator, GROUP_0, SUBTASK_3);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);
    }

    @Test
    public void testSingleGroup5() throws Exception {
        header();
        
        InputsHandler inputsHandler = new InputsHandler();
        InputsGroup group = inputsHandler.createGroup();
        
        group.add(SUBTASK_0);
        group.add(SUBTASK_1,SUBTASK_3);
        group.add(SUBTASK_4);
        
        SubTaskAllocator allocator = new SubTaskAllocator(inputsHandler);
        
        verifyGetNext(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, GROUP_0, SUBTASK_1);
        verifyGetNext(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, GROUP_0, SUBTASK_3);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);
        
        verifyReport(allocator, GROUP_0, SUBTASK_1);
        verifyReport(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);
        verifyReport(allocator, GROUP_0, SUBTASK_3);

        verifyGetNext(allocator, GROUP_0, SUBTASK_4);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);

        verifyReport(allocator, GROUP_0, SUBTASK_4);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);
    }

    @Test
    public void testMultipleGroup() throws Exception {
        header();
        
        InputsHandler sequence = new InputsHandler();
        InputsGroup g0 = sequence.createGroup();
        
        g0.add(SUBTASK_0);
        g0.add(SUBTASK_1,SUBTASK_2);
        g0.add(SUBTASK_3);
        
        InputsGroup g1 = sequence.createGroup();
        
        g1.add(SUBTASK_0);
        g1.add(SUBTASK_1,SUBTASK_2);
        g1.add(SUBTASK_3);

        SubTaskAllocator allocator = new SubTaskAllocator(sequence);
        
        /* Group 0
         * 
         *    1
         * 0     3
         *    2
         *    
         * Group 1
         * 
         *    5
         * 4     7
         *    6
         */
        verifyGetNext(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, GROUP_1, SUBTASK_0);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, GROUP_0, SUBTASK_1);
        verifyGetNext(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);
        
        verifyReport(allocator, GROUP_1, SUBTASK_0);
        verifyGetNext(allocator, GROUP_1, SUBTASK_1);
        verifyGetNext(allocator, GROUP_1, SUBTASK_2);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);
        
        verifyReport(allocator, GROUP_0, SUBTASK_1);
        verifyReport(allocator, GROUP_1, SUBTASK_1);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, GROUP_0, SUBTASK_3);

        verifyReport(allocator, GROUP_1, SUBTASK_2);
        verifyGetNext(allocator, GROUP_1, SUBTASK_3);

        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);

        verifyReport(allocator, GROUP_0, SUBTASK_3);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);

        verifyReport(allocator, GROUP_1, SUBTASK_3);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);
    }

    @Test
    public void testAllParallel() throws Exception {
        header();
        
        InputsHandler sequence = new InputsHandler();
        InputsGroup group = sequence.createGroup();
        group.add(SUBTASK_0, SUBTASK_3);
        
        SubTaskAllocator allocator = new SubTaskAllocator(sequence);
        
        verifyGetNext(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, GROUP_0, SUBTASK_1);
        verifyGetNext(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, GROUP_0, SUBTASK_3);

        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);
    }

    @Test
    public void testAllSerial() throws Exception {
        header();
        
        InputsHandler sequence = new InputsHandler();
        InputsGroup group = sequence.createGroup();
        group.add(0);
        group.add(1);
        group.add(2);
        group.add(3);
        
        SubTaskAllocator allocator = new SubTaskAllocator(sequence);
        
        verifyGetNext(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_0);
        verifyGetNext(allocator, GROUP_0, SUBTASK_1);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_1);
        verifyGetNext(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, SubTaskServer.ResponseType.TRY_AGAIN);

        verifyReport(allocator, GROUP_0, SUBTASK_2);
        verifyGetNext(allocator, GROUP_0, SUBTASK_3);
        verifyGetNext(allocator, SubTaskServer.ResponseType.NO_MORE);
}

    private void verifyGetNext(SubTaskAllocator allocator, ResponseType expectedStatus){
        SubTaskAllocation response = allocator.nextSubTask();
        log.info("response: " + response);
        assertEquals("subTaskResponse.status", expectedStatus, response.getStatus());
    }
    
    private void verifyGetNext(SubTaskAllocator allocator, int expectedGroupIndex, int expectedSubTaskIndex){
        SubTaskAllocation response = allocator.nextSubTask();
        log.info("response: " + response);
        assertEquals("subTaskResponse.expectedGroupIndex", expectedGroupIndex, response.getGroupIndex());
        assertEquals("subTaskResponse.expectedSubTaskIndex", expectedSubTaskIndex, response.getSubTaskIndex());
    }

    private void verifyReport(SubTaskAllocator allocator, int groupIndex, int subTaskNumber){
        log.info("marking complete: " + Pair.of(groupIndex,subTaskNumber));
        boolean response = allocator.markSubTaskComplete(groupIndex, subTaskNumber);
        assertEquals("markSubTaskComplete", true, response);
    }

    private void header() {
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        String methodName = stackTrace[2].getMethodName();
        
        log.info("---------------------------------------------------------------------");
        log.info("Running: " + methodName);
        log.info("---------------------------------------------------------------------");
    }
}
