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

package gov.nasa.kepler.pi.module.remote;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal;

import org.junit.Test;


public class QsubTest {

    @Test
    public void testQsub(){

        MockSupPortal supPortal = new MockSupPortal();
        String jobName = "tps-42-424242";
        String queueName = "kepler";
        boolean reRunnable = true;
        String wallTime = "01:00:00";
        int numNodes = 1;
        String model = "wes";
        String groupName = "g42";
        String scriptPath = "/usr/bin/myscript.sh";
        String[] scriptArgs = {"foo", "bar"};
        
        Qsub qsub = new Qsub(supPortal, jobName, queueName, reRunnable, wallTime, numNodes, model, groupName, scriptPath, scriptArgs);
        qsub.call();
        
        String expectedCommand = "[qsub, -N, tps-42-424242, -q, kepler, -rn, -l, " +
        		"walltime=01:00:00, -l, select=1:model=wes, -W, group_list=g42, " +
        		"--, /usr/bin/myscript.sh, foo, bar]";
        String actualCommand = supPortal.getCommandLine().toString();
        
        assertEquals("command", expectedCommand, actualCommand);
    }
    
    @Test
    public void testNoMock(){
        SupPortal supPortal = new SupPortal("host", "username");
        supPortal.setUseCommandServer(false);
        
        String jobName = "cal-32-113";
        String queueName = "devel";
        boolean reRunnable = true;
        String wallTime = "01:00:00";
        int numNodes = 1;
        String model = "wes";
        String groupName = "s1089";
        String scriptPath = "/path/to/dist/bin/nas-task-master.sh";
        String[] scriptArgs = {"/path/to/task-data/cal-matlab-32-113", 
            "/path/to/dist",
            "/path/to/state/kepler.32.113.cal.SUBMITTED_10-0-0"};

        Qsub qsub = new Qsub(supPortal, jobName, queueName, reRunnable, wallTime, numNodes, model, groupName, scriptPath, scriptArgs);
        int results = qsub.call();
        
        assertEquals("rc", 0, results);
    }
}
