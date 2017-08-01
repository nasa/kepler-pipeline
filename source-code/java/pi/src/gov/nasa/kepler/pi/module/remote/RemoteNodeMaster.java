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

import java.io.IOException;
import java.util.concurrent.Semaphore;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecuteResultHandler;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteWatchdog;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Launches and monitors sub-tasks running on a single node
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class RemoteNodeMaster {
    private static final Log log = LogFactory.getLog(RemoteNodeMaster.class);

    private int coresPerNode;    
    private String node;
    private String headNode;    
    private String binaryName;
    private String workingDir;
    private int timeoutSecs;
    private String distDir;
    private boolean memdroneEnabled;
    
    private ExecuteWatchdog memoryMonitorProcess;

    public RemoteNodeMaster(int coresPerNode, String node, String headNode, String binaryName, String workingDir,
        int timeoutSecs, String distDir, boolean memdroneEnabled) {
        this.coresPerNode = coresPerNode;
        this.node = node;
        this.headNode = headNode;
        this.binaryName = binaryName;
        this.workingDir = workingDir;
        this.timeoutSecs = timeoutSecs;
        this.distDir = distDir;
        this.memdroneEnabled = memdroneEnabled;
    }

    private void go() {
        try{
            if(memdroneEnabled){
                startMemoryMonitor();
            }
            
            log.info("Launching SubTaskMasters for node: " + node);

            Semaphore complete = new Semaphore(coresPerNode);
            
            for (int i = 0; i < coresPerNode; i++) {
                complete.acquire();
                Thread t = new Thread(new RemoteSubTaskMaster(i, node, headNode, complete, 
                    binaryName, workingDir, timeoutSecs, distDir),
                    "SubTaskMaster[" + i + "]");
                t.start();
            }
            
            log.info("Waiting for SubTaskMasters to complete");
            
            while(complete.availablePermits() != coresPerNode){
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ignore) {
                }
            }
            
            log.info("All sub-tasks DONE for node: " + node);
        } catch(Exception e){
            log.fatal("Failed to start sub-task threads, giving up!");
        } finally{
            if(memdroneEnabled){
                shutdownMemoryMonitor();
            }
        }

        log.info("Done, exiting");
    }
        
    private void startMemoryMonitor() {
        log.info("Starting memdrone.sh");
        
        try {
            CommandLine commandLine = new CommandLine(distDir + "/bin/memdrone.sh");
            commandLine.addArgument(binaryName);
            commandLine.addArgument("0.1");
            commandLine.addArgument(workingDir);
            
            DefaultExecutor executor = new DefaultExecutor();            
            memoryMonitorProcess = new ExecuteWatchdog(ExecuteWatchdog.INFINITE_TIMEOUT);
            executor.setWatchdog(memoryMonitorProcess);
            
            DefaultExecuteResultHandler resultsHandler = new DefaultExecuteResultHandler();
            
            executor.execute(commandLine, resultsHandler);
        } catch (IOException e) {
            log.warn("Failed to start memdrone.sh", e);
        }
    }

    private void shutdownMemoryMonitor() {
        if(memoryMonitorProcess != null){
            log.info("killing memory monitor...");
            memoryMonitorProcess.destroyProcess();
            log.info("DONE killing memory monitor");
        }
    }

    public static void main(String[] args) {
        
        if(args.length != 8){
            System.err.println("USAGE: RemoteNodeMaster coresPerNode node headNode binaryName workingDir timeoutSecs distDir memdroneEnabled");
            System.exit(-1);
        }

        try {
            int coresPerNode = Integer.parseInt(args[0]);
            String node = args[1];
            String headNode = args[2];
            String binaryName = args[3];
            String workingDir = args[4];
            int timeoutSecs = Integer.parseInt(args[5]);
            String distDir = args[6];
            boolean memdroneEnabled = Boolean.parseBoolean(args[7]);
            
            RemoteNodeMaster remoteTaskMaster = 
                new RemoteNodeMaster(coresPerNode, node, headNode, binaryName, workingDir, timeoutSecs, distDir, memdroneEnabled);
            remoteTaskMaster.go();
        } catch (Exception e) {
            System.err.println("failed, caught e = " + e);
            e.printStackTrace();
        }
    }
}
