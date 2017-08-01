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

import gov.nasa.kepler.pi.module.remote.sup.SupPortal;
import gov.nasa.kepler.pi.worker.WorkerEventLog;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class provides an interface to the Pleiades
 * scheduler, the Portable Batch System (PBS[1]).
 * 
 * This class uses the 'qsub' and 'qstat' commands
 * using SUP[2] to submit and monitor jobs.
 * 
 * [1] http://www.nas.nasa.gov/hecc/support/kb/Portable-Batch-System-(PBS)-Overview_126.html
 * [2] http://www.nas.nasa.gov/hecc/support/kb/Using-the-Secure-Unattended-Proxy-(SUP)_145.html
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class PbsPortalSup {
    private static final Log log = LogFactory.getLog(PbsPortalSup.class);

    private SupPortal supPortal = null;
    
    private File remoteStateFileDir;
    private File remoteTaskRootDir;
    private File remoteDistDir;
    
    public PbsPortalSup(SupPortal supPortal, File remoteStateFileDir, File remoteTaskRootDir, File remoteDistDir) {
        this.supPortal = supPortal;
        this.remoteStateFileDir = remoteStateFileDir;
        this.remoteTaskRootDir = remoteTaskRootDir;
        this.remoteDistDir = remoteDistDir;
    }

    public void submit(StateFile stateFile){
        
        stateFile.getProps().addProperty(PleiadesDirect.PBS_SUBMIT_STATEFILE_PROPNAME, 
            System.currentTimeMillis());
        try {
            stateFile.persist(remoteStateFileDir);
        } catch (Exception e) {
            log.warn("Failed to persist state file with updated submit time");
        }

        submitJob(stateFile);
    }
    
    private void submitJob(StateFile stateFile) {
        log.info("Launching job for state file: " + stateFile);
        
        String archType = stateFile.getRemoteNodeArchitecture();
        PbsNodeDescriptor nodeDescriptor = PbsArchitectures.getDescriptor(archType);
        
        if(nodeDescriptor == null){
            throw new PipelineException("Unknown architecture type: " + archType);
        }
        
        int numRemainingSubtasks = stateFile.getNumTotal() - stateFile.getNumComplete();
        
        // If there are no remaining subtasks, then just allocate one core.
        numRemainingSubtasks = (numRemainingSubtasks == 0) ? 1 : numRemainingSubtasks;
        
        double numCores = Math.ceil((double)numRemainingSubtasks / stateFile.getTasksPerCore());

        int coresPerNode = PbsArchitectures.coresPerNode(archType, stateFile.getGigsPerCore()); 
        
        int numNodes = (int) Math.ceil(numCores / coresPerNode);
        
        WorkerEventLog.event("Launching job, name=" + stateFile.invariantPart() 
            + ", numCores=" + numCores 
            + ", coresPerNode=" + coresPerNode 
            + ", numNodes=" + numNodes); 

        String jobName = stateFile.jobName();
        String scriptPath = new File(remoteDistDir, "/bin/nas-task-master.sh").getAbsolutePath();
        
        String workingDir = new File(remoteTaskRootDir, stateFile.taskDirName()).getAbsolutePath();
        String distDir = remoteDistDir.getAbsolutePath();
        String stateFilePath = new File(remoteStateFileDir, stateFile.name()).getAbsolutePath();
        
        String[] scriptArgs = new String[]{workingDir, distDir, stateFilePath};
        
        Qsub qsub = new Qsub(supPortal, jobName, stateFile.getQueueName(), stateFile.isReRunnable(), stateFile.getRequestedWallTime(),
            numNodes, archType, stateFile.getRemoteGroup(), scriptPath, scriptArgs);

        int retcode = qsub.call();
        
        if(retcode != 0){
            log.error("Failed to launch job for state file: " + stateFile);
        }
    }
}
