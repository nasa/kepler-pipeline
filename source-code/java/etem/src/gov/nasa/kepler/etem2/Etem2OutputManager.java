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

package gov.nasa.kepler.etem2;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.services.process.ExternalProcess;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;

import org.apache.commons.configuration.Configuration;

/**
 * Manages the local and NFS directories for ETEM output
 * 
 * @author tklaus
 *
 */
public class Etem2OutputManager {
    private static final Log log = LogFactory.getLog(Etem2OutputManager.class);

    private static final int COPY_TIMEOUT = 10 * 60 * 60 * 1000; // 10 hour timeout

    /** Relative directory that etem2 will create and populate with the outputs */
//    private String runDir;
    
    /** Local directory where all runDirs are created */
    private String localDir;
    
    /** NFS directory where files are copied after etem completes */
    private String outputDir;
    
    /** Local runDir directory for this run */
    private File localRunDir;

    /** Run number.  When non-zero, the runNumber is incorporated
     * into the outputDir (dithering use case) */
    private int runNumber = 0;
    
    /** Used to make the localDir name unique, in case there are multiple
     * ETEM pipelines running on the same worker  */
    private long taskId;
    
    private DataGenDirManager dataGenDirManager;

    public Etem2OutputManager(DataGenDirManager dataGenDirManager, long taskId) {
        this.dataGenDirManager = dataGenDirManager;
        this.taskId = taskId;
        
        setRunNumber(0); // default is no runNumber in the paths
    }

    /**
     * Create the local ETEM output dir, deleting contents from
     * previous runs if necessary
     * 
     * @param runNumber If > 0, this number is included in the output dir name (dithering use case)
     * @throws IOException 
     */
    public void initializeDirectories(String runDir) throws IOException{
        /* Have etem write the outputs to the local disk, then copy to NFS drive */
        Configuration configService = ConfigurationServiceFactory.getInstance();
        String relativeDir = configService.getString(
            ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME,
            ".");

        // relative to worker working dir
        File localFile = null;
        
        if(runNumber > 0){
            localFile = new File(relativeDir, "etem2out-" + taskId + "/" + runNumber); 
        }else{
            localFile = new File(relativeDir, "etem2out-" + taskId); 
        }

        localDir = localFile.getAbsolutePath();
        localRunDir = new File(localDir, runDir);

        log.info("outputDir=" + outputDir);
        log.info("localDir=" + localDir);
        log.info("runDir=" + runDir);
        log.info("localRunDir=" + localRunDir.getAbsolutePath());

        log.info("clearing localRunDir");
        checkOutputDir(localRunDir.getAbsolutePath());
    }
    
    /**
     * Copy the contents of the local ETEM output dir to the
     * NFS directory specified in the parameters, then remove
     * the local dir
     * 
     * @throws IOException 
     */
    public void publishResults(String runDir) throws Exception{
        String oldRunDir = new File(outputDir, runDir).getAbsolutePath();
        log.info("clearing oldRunDir=" + oldRunDir);
        checkOutputDir(oldRunDir);

        /* Copy the output files to NFS */
        LinkedList<String> command = new LinkedList<String>();
        command = new LinkedList<String>();
        command.add("cp");
        command.add("-R");
        command.add(localRunDir.getAbsolutePath());
        command.add(outputDir);

        ExternalProcess p = new ExternalProcess(command);
        p.setThreadLabel(Thread.currentThread().getName());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int triesLeft = 3;
        
        while(true){
            log.info("copying local files to outputDir=" + outputDir + ", triesLeft=" + triesLeft);
            int retcode = p.run(true, COPY_TIMEOUT);

            if (retcode != 0) {
                if(triesLeft == 0){
                    throw new ModuleFatalProcessingException(
                        "failed to cp output files, retcode = " + retcode);
                }else{
                    triesLeft--;
                }
            }else{
                break; // done
            }
        }

        // delete the local files
        log.info("clearing localRunDir=" + localRunDir.getAbsolutePath());
        checkOutputDir(localRunDir.getAbsolutePath());
    }

    /**
     * @return the localDir
     */
    public String getLocalDir() {
        return localDir;
    }

    private void checkOutputDir(String outputDir) throws IOException {
        // delete output dir, if it exists
        File outputFile = new File(outputDir);
        if (outputFile.exists()) {
            FileUtils.deleteDirectory(outputFile);
        }

        // make sure output dir exists
        outputFile.mkdirs();
    }

    public int getRunNumber() {
        return runNumber;
    }

    public void setRunNumber(int runNumber) {
        this.runNumber = runNumber;

        outputDir = dataGenDirManager.getEtemDir();

        if (!outputDir.endsWith("/")) {
            outputDir = outputDir + "/";
        }

        if(runNumber > 0){
            outputDir = outputDir + runNumber + "/";
        }
        
    }

    public String getOutputDir() {
        return outputDir;
    }
}
