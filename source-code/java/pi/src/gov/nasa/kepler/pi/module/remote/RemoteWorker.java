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

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.pi.module.remote.StateFile.State;
import gov.nasa.kepler.pi.worker.WorkerEventLog;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class is used to launch and monitor MATLAB
 * tasks that are running on a node other than the node
 * where the worker is running (remote cluster scenario)
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class RemoteWorker implements Runnable {
    private static final Log log = LogFactory.getLog(RemoteWorker.class);

    /** How often we look for new SUBMITTED tasks */
    private static final int POLL_INTERVAL_MILLIS = 10 * 1000; // 10 secs

    private static final String STATE_FILE_PROP = "pi.remote.statefile.dir";
    private static final String TASK_FILE_PROP = "pi.remote.taskfile.dir";
    private static final String DIST_DIR_PROP = "pi.remote.dist.dir";

    private static final long MINIMUM_STATEFILE_AGE_MILLIS = 60 * 1000; // 60 secs 

    private File stateFileDir;
    private File taskRootDir;
    private File distDir;

    private PbsPortalLocal pbsPortal;
    
    public RemoteWorker() {
    }

    public void go(){
        WorkerEventLog.event("Remote worker process starting");
        
        log.info(KeplerSocVersion.getProject());
        log.info("  Release: " + KeplerSocVersion.getRelease());
        log.info("  Revision: " + KeplerSocVersion.getRevision());
        log.info("  SVN URL: " + KeplerSocVersion.getUrl());
        log.info("  Build Date: " + KeplerSocVersion.getBuildDate());

        log.info("jvm version:");
        log.info("  java.runtime.name="
            + System.getProperty("java.runtime.name"));
        log.info("  sun.boot.library.path="
            + System.getProperty("sun.boot.library.path"));
        log.info("  java.vm.version=" + System.getProperty("java.vm.version"));
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        String stateFilePath = config.getString(STATE_FILE_PROP);
        if(stateFilePath == null){
            throw new PipelineException(STATE_FILE_PROP + " is not set");            
        }
        stateFileDir = new File(stateFilePath);
        if(!stateFileDir.exists() || !stateFileDir.isDirectory()){
            throw new PipelineException(STATE_FILE_PROP + " does not exist or is not a directory");            
        }
        
        String taskFilePath = config.getString(TASK_FILE_PROP);
        if(taskFilePath == null){
            throw new PipelineException(TASK_FILE_PROP + " is not set");            
        }
        taskRootDir = new File(taskFilePath);
        if(!taskRootDir.exists() || !taskRootDir.isDirectory()){
            throw new PipelineException(TASK_FILE_PROP + " does not exist or is not a directory");            
        }
        
        String distPath = config.getString(DIST_DIR_PROP);
        if(distPath == null){
            throw new PipelineException(DIST_DIR_PROP + " is not set");            
        }
        distDir = new File(distPath);
        if(!distDir.exists() || !distDir.isDirectory()){
            throw new PipelineException(DIST_DIR_PROP + " does not exist or is not a directory");            
        }
        
        log.info("  " + STATE_FILE_PROP + ": " + stateFileDir.getAbsolutePath());
        log.info("  " + TASK_FILE_PROP + ": " + taskRootDir.getAbsolutePath());
        
        log.info("Starting launcher thread...");
        new Thread(this, "Launcher").start();
    }
    
    @Override
    public void run(){
        pbsPortal = new PbsPortalLocal(stateFileDir, taskRootDir, distDir);
        
        log.info("Checking for new tasks...");
        while(true){
            try {
                launchNewTasks();
            } catch (Exception e) {
                log.error("RemoteLauncher failed, caught e = " + e, e );
            }
            
            try {
                Thread.sleep(POLL_INTERVAL_MILLIS);
            } catch (InterruptedException e) {
            }
        }
    }
    
    private void launchNewTasks() throws Exception{
        List<State> stateFilters = new ArrayList<State>();
        stateFilters.add(StateFile.State.SUBMITTED);
        
        List<StateFile> submittedTasks = StateFile.fromDirectory(stateFileDir, stateFilters, MINIMUM_STATEFILE_AGE_MILLIS);
        
        int numNewtasks = submittedTasks.size();
        if(numNewtasks != 0){
            log.debug("Found " + numNewtasks + " new tasks ready for processing");
            
            pbsPortal.submit(submittedTasks);
        }
    }

    public static void main(String[] args) {
        RemoteWorker remoteWorker = new RemoteWorker();
        remoteWorker.go();
    }
}
