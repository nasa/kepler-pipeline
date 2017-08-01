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

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.services.cmdrunner.CommandResults;
import gov.nasa.kepler.services.cmdrunner.CommandRunnerClient;
import gov.nasa.kepler.services.cmdrunner.Log4jLogOutputStream;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class SubTaskUtils {
    private static final Log log = LogFactory.getLog(SubTaskUtils.class);

    private static final long COMMAND_SERVER_TIMEOUT_MILLIS = 5 * 60 * 1000;
    private static final String USE_CMD_SERVER_PROP_NAME = "pi.subTaskUtils.useCommandServer";
    private static final boolean USE_CMD_SERVER_DEFAULT = false;
    private static boolean useCommandServer = USE_CMD_SERVER_DEFAULT;
    
    {
        /* Since the heap size of the worker can be large, we use the command
         * server to run commands in order to avoid launching a new process 
         * directly from the worker via fork/exec. */
        log.info("SubTaskUtils: checking to see if command server should be used");
        Configuration config = ConfigurationServiceFactory.getInstance();
        useCommandServer = config.getBoolean(USE_CMD_SERVER_PROP_NAME, USE_CMD_SERVER_DEFAULT);
    }
    
    public static void makeSymlinks(File taskDir) {
        log.info("Creating sub-task symlinks where necessary");

        File[] files = taskDir.listFiles();
        ArrayList<File> linkedFiles = new ArrayList<File>();

        for (File f : files) {
            if (f.isFile()) {
                linkedFiles.add(f);
            }
        }

        for (File f : linkedFiles) {
            log.info("Creating symlink from sub-task dir for: "
                + f.getName());
        }

        if (!linkedFiles.isEmpty()) {
            TaskDirectoryIterator it = new TaskDirectoryIterator(taskDir);

            while (it.hasNext()) {
                Pair<File, File> d = it.next();
                File gDir = d.left;
                File sDir = d.right;
                String relativePath = "";

                if (gDir.equals(taskDir)) {
                    relativePath = "../";
                } else {
                    relativePath = "../../";
                }

                for (File f : linkedFiles) {
                    String source = relativePath + f.getName();
                    File linkName = new File(sDir, f.getName());
                    mkLink(source, linkName);
                }
            }
        }
    }
 
    public static void removeSymlinks(File workingDir) {
        log.info("Removing sub-task symlinks where necessary");
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        String binDir = config.getString(MatlabMcrExecutable.BIN_DIR_PROPERTY_NAME);
        File cmd = new File(binDir, "rm-subtask-links.sh");
        List<String> commandAndArgs = new LinkedList<String>();
        commandAndArgs.add(cmd.getAbsolutePath());
        commandAndArgs.add(workingDir.getAbsolutePath());
        
        execLocalCommand(commandAndArgs);
    }

    private static void mkLink(String source, File dest){
        List<String> commandAndArgs = new LinkedList<String>();
        commandAndArgs.add("rm");
        commandAndArgs.add("-f");
        commandAndArgs.add(dest.getAbsolutePath());
        execLocalCommand(commandAndArgs);
        
        commandAndArgs = new LinkedList<String>();
        commandAndArgs.add("ln");
        commandAndArgs.add("-s");
        commandAndArgs.add(source);
        commandAndArgs.add(dest.getAbsolutePath());
        execLocalCommand(commandAndArgs);
      }
      
    private static void execLocalCommand(List<String> commandAndArgs) throws PipelineException{
        int retCode = -1;

        try {
            if(useCommandServer){
                CommandRunnerClient c = new CommandRunnerClient();
                c.setUseServer(useCommandServer);
                CommandResults r = c.run(commandAndArgs, COMMAND_SERVER_TIMEOUT_MILLIS);
                retCode = r.getReturnCode();
            }else{
                DefaultExecutor executor = new DefaultExecutor();
                PumpStreamHandler outputHandler = new PumpStreamHandler(new Log4jLogOutputStream());
                executor.setStreamHandler(outputHandler);
                
                CommandLine commandLine = new CommandLine(commandAndArgs.get(0));
                for (int i = 1; i < commandAndArgs.size(); i++) {
                    commandLine.addArgument(commandAndArgs.get(i));
                }
                retCode = executor.execute(commandLine);
            }
        } catch (Exception e) {
            throw new PipelineException("Failed to run: " + commandAndArgs + ", caught e=" + e, e);
        }
        
        if(retCode != 0){
            throw new PipelineException("Failed to run: " + commandAndArgs + ", retCode=" + retCode);
        }
    }
}
