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

package gov.nasa.kepler.mr.scriptlet;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.kepler.mr.scriptlet.PipelineScriptlet.TestFacade;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

public class PipelineScriptletTest {

    @Test(expected = NullPointerException.class)
    //@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "NP")
    public void testTotalTaskCountWithNullTaskCounts() {
        TestFacade scriptlet = new PipelineScriptlet().new TestFacade();
        scriptlet.totalTaskCount(null);
    }

    @Test
    public void testTotalTaskCount() {
        TestFacade scriptlet = new PipelineScriptlet().new TestFacade();

        Map<State, Integer> taskCounts = new HashMap<State, Integer>();
        assertEquals(0, (int) scriptlet.totalTaskCount(taskCounts));

        taskCounts = createTaskCounts();
        assertEquals(42, (int) scriptlet.totalTaskCount(taskCounts));
    }

    @Test(expected = NullPointerException.class)
    public void testTaskCountWithNullTaskCounts() {
        TestFacade scriptlet = new PipelineScriptlet().new TestFacade();
        scriptlet.taskCount(null, State.COMPLETED);
    }

    @Test(expected = NullPointerException.class)
    public void testTaskCountWithNullState() {
        TestFacade scriptlet = new PipelineScriptlet().new TestFacade();
        scriptlet.taskCount(new HashMap<State, Integer>(), null);
    }

    @Test(expected = IllegalStateException.class)
    public void testTaskCountWithUnknownState() {
        TestFacade scriptlet = new PipelineScriptlet().new TestFacade();
        scriptlet.taskCount(new HashMap<State, Integer>(), State.COMPLETED);
    }

    @Test
    public void testTaskCount() {
        TestFacade scriptlet = new PipelineScriptlet().new TestFacade();

        Map<State, Integer> taskCounts = createTaskCounts();
        assertEquals(0, (int) scriptlet.taskCount(taskCounts, State.SUBMITTED));
        assertEquals(42, (int) scriptlet.taskCount(taskCounts, State.COMPLETED));
    }

    private Map<State, Integer> createTaskCounts() {
        Map<State, Integer> taskCounts = new HashMap<State, Integer>();
        taskCounts.put(State.SUBMITTED, 0);
        taskCounts.put(State.COMPLETED, 42);

        return taskCounts;
    }
}
