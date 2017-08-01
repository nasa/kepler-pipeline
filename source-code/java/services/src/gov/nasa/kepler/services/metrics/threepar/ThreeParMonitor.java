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

package gov.nasa.kepler.services.metrics.threepar;

import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.spiffy.common.os.ProcessUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * @author Sean McCauliff
 *
 */
public class ThreeParMonitor extends AbstractPipelineProcess {

    public ThreeParMonitor() {
        super("3Par Monitor");
    }

    private static final String SSH_AGENT_PID_ENV = "SSH_AGENT_PID";
    private static final String SSH_ASK_PASS_ENV = "SSH_ASKPASS";
    private static final int POLL_SECONDS = 30;
    
    public static void main(String[] argv) throws Exception {
        ThreeParMonitor monitor = new ThreeParMonitor();
        monitor.initialize();
        monitor.startMonitoring();
    }
    
    private void startMonitoring() throws IOException, InterruptedException {
        if (!System.getenv().containsKey(SSH_AGENT_PID_ENV) && !System.getenv().containsKey(SSH_ASK_PASS_ENV)) {
            throw new IllegalStateException("ssh agent must be running.");
        }
        
        List<String> sshAddLines = ProcessUtils.grabOutput("ssh-add -l").allAsList();
        if (sshAddLines.size() == 0) {
            throw new IllegalStateException("You must add a key using ssh-add.");
        }
        

        final List<AbstractMonitor> monitors = new ArrayList<AbstractMonitor>();
        monitors.add( new LunMonitor(POLL_SECONDS));
        monitors.add(new PhysicalDiskMonitor(POLL_SECONDS));
        
        final List<Thread> monitorThreads = new ArrayList<Thread>();
        for (AbstractMonitor am : monitors) {
            am.init();
            Thread t = new Thread(am, am.name());
            t.setDaemon(true);
            t.start();
        }

        
        Runtime r = Runtime.getRuntime();
        r.addShutdownHook(new Thread() {
            {
                setName("Monitor Shutdown Hook.");
            }
            
            @Override
            public void run() {
                for (AbstractMonitor am : monitors) {
                    am.terminate();
                }
            }
        });
        
        for (Thread t : monitorThreads) {
            t.join();
        }
        
    }
}
