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

import gov.nasa.kepler.pi.worker.WorkerEventLog;
import gov.nasa.kepler.services.process.ExternalProcess;

import java.io.File;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This {@link JobLauncher} implementation uses the PBS 'qsub' command
 * to execute a script which launches one job per sub-task on the pool of 
 * nodes allocated to the qsub job.
 * 
 * This implementation was designed for and tested on the NASA Ames
 * Supercomputer (NAS) Pleiades system.
 * 
 * @author tklaus
 *
 */
public class PleiadesPbsJobLauncher implements JobLauncher {
	private static final Log log = LogFactory.getLog(PleiadesPbsJobLauncher.class);

    private static final int QSUB_TIMEOUT_SECS = 300; // usually returns immediately
    
    public PleiadesPbsJobLauncher() {
	}

	@Override
	public int launchJobsForTask(String stateFilePath, File taskDir, int numNodes, int coresPerNode, File distDir) {
	    
        int retCode = -1;
        List<String> commandArgs = new LinkedList<String>();
        String commandLine = null;

        try {
            StateFile stateFile = new StateFile(new File(stateFilePath));
            String jobName = stateFile.jobName();
            
            commandArgs.add(distDir + "/bin/nas-qsub.sh");
            commandArgs.add(jobName);
            commandArgs.add(stateFile.getRequestedWallTime());
            commandArgs.add(""+numNodes);
            commandArgs.add(stateFile.getRemoteGroup());
            commandArgs.add(stateFile.getQueueName());
            commandArgs.add(stateFile.getRemoteNodeArchitecture());
            commandArgs.add(taskDir.getAbsolutePath());
            commandArgs.add(distDir.getAbsolutePath());
            commandArgs.add(stateFilePath);
            
            commandLine = singleLine(commandArgs);

            WorkerEventLog.event("Launching jobs for: " + stateFile);
            WorkerEventLog.event(" cmd: " + commandLine);
            
            ExternalProcess p = new ExternalProcess(commandArgs);
            p.setThreadLabel(Thread.currentThread().getName());
            p.setLogStdOut(true);
            p.setLogStdErr(true);
            p.setVerbose(true);
            
            retCode = p.run(true, QSUB_TIMEOUT_SECS * 1000);
            
            QsubLog qsubLog = new QsubLog(new File(distDir, "logs"));
            qsubLog.log(commandLine);
        } catch (Exception e) {
            log.error("Failed to run qsub, cmd: " + commandLine, e);
        }
        
        if(retCode != 0){
            log.error("Failed to run qsub, retCode: " + retCode + ", cmd: " + commandLine);
        }
        
        return retCode;
    }
    
    /**
     * @param commandLine
     * @return
     */
    private String singleLine(List<String> commandLine) {
        StringBuffer sb = new StringBuffer();
        for (String s : commandLine) {
            sb.append(s);
            sb.append(" ");
        }
        return sb.toString();
    }
}
