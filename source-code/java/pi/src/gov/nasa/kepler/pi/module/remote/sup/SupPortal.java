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

package gov.nasa.kepler.pi.module.remote.sup;

import gov.nasa.kepler.services.cmdrunner.CommandResults;
import gov.nasa.kepler.services.cmdrunner.CommandRunnerClient;
import gov.nasa.spiffy.common.lang.Retry;
import gov.nasa.spiffy.common.lang.Retryable;
import gov.nasa.spiffy.common.metrics.CounterMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.io.Files;

/**
 * This class provides wrappers for the SUP command used to perform
 * transfers to/from the Pleiades supercomputer. 
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class SupPortal {
    private static final Log log = LogFactory.getLog(SupPortal.class);

    private static String HOST_OPT = "host";
    private static String USER_OPT = "user";
    private static String OPERATION_OPT = "operation";
    private static String COMMAND_OPT = "command";
    private static String SRC_OPT = "src";
    private static String DEST_OPT = "dest";

    private static final String JAVA_IO_TMPDIR = "java.io.tmpdir";

    private static final int SSH_EXEC_TIMEOUT_SECS = 300;
    
    /* Constants for NAS SUP (Secure Unattended Proxy, see http://www.nas.nasa.gov/hecc/support/kb/23/) */
    private static final String SUP_CMD = "/path/to/dist/bin/sup";

	private static final int REMOTE_STATEFILE_POLL_TIMEOUT_MILLIS = 30000; // 30 secs
    private static final long REMOTE_TRANSFER_RETRY_INTERVAL_MILLIS = 30000; // 30 secs

    private String[] hosts;
    private String username;
    private boolean bbftpEnabled = false;
    private boolean useArcFourCiphers = false;
    private boolean useCommandServer = true;
    
    public class RemoteFile {
        public String name;
        public boolean isDirectory = false;

        @Override
        public String toString() {
            StringBuffer sb = new StringBuffer(name);
            if (isDirectory) {
                sb.append("/");
            }
            return sb.toString();
        }
    }

    /**
     * Construct a new SupPortal using public key authentication with ssh-agent.
     * 
     * @param host
     * @param username
     */
    public SupPortal(String host, String username) {
        this.hosts = new String[]{host};
        this.username = username;
    }

    /**
     * Construct a new SupPortal using public key authentication with ssh-agent.
     * 
     * @param hosts
     * @param username
     */
    public SupPortal(String[] hosts, String username) {
        this.hosts = hosts;
        this.username = username;
    }

    public SupCommandResults getFiles(String source, String destDir, boolean verbose, int timeoutMillis, int retries) {
        return execCopy(source, destDir, true, verbose, timeoutMillis, retries);
    }

    public SupCommandResults getFiles(String source, String destDir) {
        return execCopy(source, destDir, true, false);
    }

    public SupCommandResults putFiles(String source, String destDir, boolean verbose, int timeoutMillis, int retries) {
        return execCopy(source, destDir, false, verbose, timeoutMillis, retries);
    }

    public SupCommandResults putFiles(String source, String destDir) {
        return execCopy(source, destDir, false, false);
    }

    public SupCommandResults removeFile(String path) throws SupPortalException {
        List<String> commandLine = new LinkedList<String>();
        commandLine.add("rm");
        commandLine.add(path);
        SupCommandResults response = execCommand(commandLine);

		return response;
    }

    public List<RemoteFile> listRemoteDirectoryContents(String remoteDirectory) throws SupPortalException {
        return listRemoteDirectoryContents(remoteDirectory, null);
    }

    public List<RemoteFile> listRemoteDirectoryContents(String remoteDirectory, String prefixFilter) throws SupPortalException {
        File stagingDir = null;
        IntervalMetricKey key = IntervalMetric.start();
        try {
            stagingDir = Files.createTempDir();
            SupCommandResults results = getFiles(remoteDirectory + "/*", stagingDir.getAbsolutePath(), 
                true, REMOTE_STATEFILE_POLL_TIMEOUT_MILLIS, 0);
            if(results.failed()){
                CounterMetric.increment("SupPortal.listRemoteDirectoryContents.failureCount");

                log.warn("stdOut=" + results.getStdOut());
                log.warn("stdErr=" + results.getStdErr());
                throw new SupPortalException("failed to retrieve remote dir contents for "+remoteDirectory+", " + results);
            }else{
                CounterMetric.increment("SupPortal.listRemoteDirectoryContents.successCount");
            }
            
            File[] filesInDir = stagingDir.listFiles();            
            LinkedList<RemoteFile> remoteFiles = new LinkedList<RemoteFile>();
    
            for (File file : filesInDir) {
                if(!file.isDirectory()){
                    if (prefixFilter == null || file.getName().startsWith(prefixFilter)) {
                        RemoteFile rf = new RemoteFile();
                        rf.name = file.getName();
                        remoteFiles.add(rf);
                    }
                }
            }
            return remoteFiles;
        } catch (Exception e) {
            throw new SupPortalException("Failed to retrieve remote directory [" 
                + remoteDirectory + "] contents, caught e=" + e, e);
        } finally {
            FileUtils.deleteQuietly(stagingDir);
            IntervalMetric.stop("SupPortal.listRemoteDirectoryContents.execTimeMillis", key);
        }
    }

    private SupCommandResults execCopy(String source, String destDir, boolean pull, boolean verbose) {
    	return execCopy(source, destDir, pull, verbose, 0, 0);
    }
    
    private SupCommandResults execCopy(final String source, final String destDir, final boolean pull, 
        final boolean verbose, final int timeoutMillis, int retries) {
        
        Retry<SupCommandResults> retry = new Retry<SupCommandResults>(retries, REMOTE_TRANSFER_RETRY_INTERVAL_MILLIS);   
        retry.setMetricPrefix("SupPortal.Retry.call.");
        
        SupCommandResults results = null;
        try {
            results = retry.execute(new Retryable<SupCommandResults>(){
                @Override
                public SupCommandResults call(int retryNumber) throws Exception { // returns retCode
                    SupCommandResults copyResults = execSupCopy(source, destDir, pull, timeoutMillis, verbose, retryNumber);
                    boolean transferOk = verifySupCopy(source, destDir, pull, timeoutMillis, verbose, retryNumber);
                    
                    if(!transferOk){
                        log.error("validation failed for " + destDir);

                        CounterMetric.increment("SupPortal.verifySupCopy.all.failureCount");
                        if(bbftpEnabled){
                            CounterMetric.increment("SupPortal.verifySupCopy.bbftp.failureCount");
                        }else{
                            CounterMetric.increment("SupPortal.verifySupCopy.scp.failureCount");
                        }
                        
                        throw new SupCommandException("verifySupCopy failed", "", -1);
                    }else{
                        CounterMetric.increment("SupPortal.verifySupCopy.all.successCount");
                        if(bbftpEnabled){
                            CounterMetric.increment("SupPortal.verifySupCopy.bbftp.successCount");
                        }else{
                            CounterMetric.increment("SupPortal.verifySupCopy.scp.successCount");
                        }
                    }

                    return new SupCommandResults(copyResults.getStdOut(), copyResults.getStdErr(), 0);
                }
            });
        } catch (Exception e) {
            log.warn("Copy [" + source + " -> " + destDir + "] failed (exhausted retries, caught e=" + e, e);
            
            if(e instanceof SupCommandException){
                SupCommandException sce = (SupCommandException) e;
                return new SupCommandResults(sce.getStdOut(), sce.getStdErr(), sce.getRetCode());
            }else{
                return new SupCommandResults(e);
            }
        }
        return results;
    }

    private String selectHost(){
        int index = (int) Math.floor(Math.random() * hosts.length);
        return hosts[index];
    }
    
    private SupCommandResults execSupCopy(String source, String destDir, boolean pull, int timeoutMillis, boolean verbose, int retryNumber) throws Exception{
        List<String> commandLine = new LinkedList<String>();
        
        String host = selectHost();
        
        log.info("Randomly selected host: " + host);
        
        commandLine.add(SUP_CMD);
        commandLine.add("-v");
        commandLine.add("-n");
        commandLine.add("-b");
        commandLine.add("-u");
        commandLine.add(username);
        if(useArcFourCiphers ){
            commandLine.add("-oCiphers=arcfour128");
            commandLine.add("-oMACs=umac-64@openssh.com");
        }

        if(bbftpEnabled){
            IntervalMetricKey key = IntervalMetric.start();
            try {
                return execBbftp(commandLine, pull, host, username, source, destDir, timeoutMillis);
            } finally {
                IntervalMetric.stop("SupPortal.execSupCopy.all.execTimeMillis", key);
                IntervalMetric.stop("SupPortal.execSupCopy.bbftp.execTimeMillis", key);
                
                if(retryNumber > 0){
                    CounterMetric.increment("SupPortal.execSupCopy.all.retryCount");
                    CounterMetric.increment("SupPortal.execSupCopy.bbftp.retryCount");
                }
            }        
        }else{
            // scp
            IntervalMetricKey key = IntervalMetric.start();
            try {
                return execScp(commandLine, pull, host, source, destDir, timeoutMillis);
            } finally {
                IntervalMetric.stop("SupPortal.execSupCopy.all.execTimeMillis", key);
                IntervalMetric.stop("SupPortal.execSupCopy.scp.execTimeMillis", key);
                
                if(retryNumber > 0){
                    CounterMetric.increment("SupPortal.execSupCopy.all.retryCount");
                    CounterMetric.increment("SupPortal.execSupCopy.scp.retryCount");
                }
            }        
        }
    }
    
    private SupCommandResults execScp(List<String> commandLine, boolean pull, String remoteHost, 
        String source, String destDir, int timeoutMillis){
        commandLine.add("scp");
        commandLine.add("-r");
        
        if (pull) {
            commandLine.add(remoteHost + ":" + source);
            commandLine.add(destDir);
        } else {
            // push
            commandLine.add(source);
            commandLine.add(remoteHost + ":" + destDir);
        }
        
        return exec(commandLine, timeoutMillis);        
    }
    
    private SupCommandResults execBbftp(List<String> commandLine, boolean pull, String remoteHost, String user, 
        String source, String destDir, int timeoutMillis) throws IOException{
        
        File sourceFile = new File(source);
        // bbftp needs the filename in dest, not just the directory
        String filename = sourceFile.getName();
        File destFile = new File(destDir,filename);        

        // bbftp seems to be unable to parse the -e option when called from Java,
        // so we use the -i option with a control file instead
        File controlFile = File.createTempFile("bbftp", ".control");
        BufferedWriter out = new BufferedWriter(new FileWriter(controlFile));

        String bbftpCommand = "";
        
        if (pull) {
            bbftpCommand = "get " + sourceFile.getAbsolutePath() + " " + destFile.getAbsolutePath();
        } else {
            // push
            bbftpCommand = "put " + sourceFile.getAbsolutePath() + " " + destFile.getAbsolutePath();
        }
        
        log.info("bbftpCommand = [" + bbftpCommand + "]");
        
        out.write(bbftpCommand);
        out.newLine();
        out.close();

        // Invoke the sup balancer to pick a host. Assumes remoteHost is generic, like host
        //String supBalancerHostCommand = "`sup -u " + user + " -b ssh-balance -l " + remoteHost + "`";
        
        commandLine.add("bbftp");
        commandLine.add("-d");
        commandLine.add("-s");
        commandLine.add("-u");
        commandLine.add(user);
        commandLine.add("-i");
        commandLine.add(controlFile.getAbsolutePath());
//        commandLine.add(supBalancerHostCommand);
        commandLine.add(remoteHost);

        SupCommandResults results = exec(commandLine, timeoutMillis);
        
        if (!FileUtils.deleteQuietly(controlFile)){
            log.warn("Failed to delete control file: " + controlFile.getAbsolutePath());
        }
        
        return results;
    }
    
    public SupCommandResults execCommand(List<String> command) {
        int retCode = -1;
        Exception exception = null;
        String host = selectHost();
    
        try {
            List<String> commandLine = new LinkedList<String>();
            String usernameString = "";
    
            commandLine.add(SUP_CMD);
            commandLine.add("-v");
            commandLine.add("-n");
            commandLine.add("-b");
            commandLine.add("-u");
            commandLine.add(username);
            if(useArcFourCiphers ){
                commandLine.add("-oCiphers=arcfour128");
                commandLine.add("-oMACs=umac-64@openssh.com");
            }
    
            commandLine.add("ssh");
            commandLine.add(usernameString + host);
            commandLine.addAll(command);

            return exec(commandLine, SSH_EXEC_TIMEOUT_SECS * 1000);
        } catch (Exception e) {
            log.error("Command [" + command + "] failed, caught e=" + e, e);
            exception = e;
        }
    
        return new SupCommandResults("<exception>", "<exception>", retCode, exception);
    }

    private SupCommandResults exec(List<String> commandLine, int timeoutMillis){
        log.info(commandLineToString(commandLine));
        
        IntervalMetricKey key = IntervalMetric.start();

        try {
            CommandRunnerClient c = new CommandRunnerClient();
            c.setUseServer(useCommandServer);
            CommandResults r = c.run(commandLine, timeoutMillis);
            log.info("rc = " + r.getReturnCode() + " (ignored due to unreliability)");
            
            return new SupCommandResults(r.getStdOut(), r.getStdErr(), r.getReturnCode());
        } finally {
            IntervalMetric.stop("SupPortal.exec.execTime", key);
        }        
    }

    private boolean verifySupCopy(String source, String destDir, boolean pull, int timeoutMillis, boolean verbose, int retryNumber){

    	File sourceFile = new File(source);
        File destFile = new File(destDir);
        File fileToTest = null;

        log.info("verifySupCopy:sourceFile=" + sourceFile.getAbsolutePath());
        log.info("verifySupCopy:destFile=" + destFile.getAbsolutePath());
        
        if(pull){
            // just check that the local file exists
        	if(sourceFile.getName().endsWith(".tar")){
            	// must be a .tar file
            	fileToTest = new File(destFile, sourceFile.getName());

                log.info("fileToTest=" + fileToTest.getAbsolutePath());
            	
            	return fileToTest.exists();
        	}else{
        		return true; // broken for state files for now
        	}
        }else{
        	// push
            fileToTest = new File(destFile,sourceFile.getName());
            log.info("fileToTest=" + fileToTest.getAbsolutePath());

            List<String> commandLine = new LinkedList<String>();
            String host = hosts[retryNumber % (hosts.length)];
            
            // ./sup -b -u tklaus ssh host test -e /path/to/dist/bin/sup
            
            commandLine.add(SUP_CMD);
            commandLine.add("-v");
            commandLine.add("-n");
            commandLine.add("-b");
            commandLine.add("-u");
            commandLine.add(username);

            if(useArcFourCiphers ){
                commandLine.add("-oCiphers=arcfour128");
                commandLine.add("-oMACs=umac-64@openssh.com");
            }
                    
            commandLine.add("ssh");
            commandLine.add(host);
            commandLine.add("test");
            commandLine.add("-e");
            commandLine.add(fileToTest.getAbsolutePath());
            
            log.info(commandLineToString(commandLine));
            
            int rc = -1;

            IntervalMetricKey key = IntervalMetric.start();

            try {
                CommandRunnerClient c = new CommandRunnerClient();
                CommandResults r = c.run(commandLine, timeoutMillis);
                rc = r.getReturnCode();
            } catch(Exception e){
                log.warn("ExternalProcess.run() failed, e = " + e, e);
                return false;
            } finally {
                IntervalMetric.stop("SupPortal.verifySupCopy.execTime", key);
            }
            
            log.info("rc = " + rc);
            
            return rc == 0;
        }
    }
    
    private String commandLineToString(List<String> commandLine){
        StringBuffer sb = new StringBuffer();
        sb.append("cmd = [");
        for (String arg : commandLine) {
            sb.append(arg);
            sb.append(" ");
        }
        sb.append("]");
        return sb.toString();
    }
    
    /**
     * Copy the specified file to the remote system
     * 
     * @param path
     * @return true if the operation was successful, false otherwise
     * @throws SupPortalException
     */
//    private boolean createRemoteFile(String path) throws SupPortalException {
//        File file = new File(path);
//        File tmpFile = new File(System.getProperty(JAVA_IO_TMPDIR), file.getName());
//        try {
//            tmpFile.createNewFile();
//            SupCommandResults results = putFiles(tmpFile.getAbsolutePath(), path);
//            if(results.failed()){
//                log.warn("failed to copy file [" + path + "] to remote server, " + results);
//                return false;
//            }
//        } catch (Exception e) {
//            log.warn("failed to create remote file [" + path + "], caught e = " + e, e);
//            return false;
//        } finally {
//            tmpFile.delete();
//        }
//        return true;
//    }

    public boolean isUseArcFourCiphers() {
        return useArcFourCiphers;
    }

    public void setUseArcFourCiphers(boolean useArcFourCiphers) {
        this.useArcFourCiphers = useArcFourCiphers;
    }
    
    public boolean isBbftpEnabled() {
        return bbftpEnabled;
    }

    public void setBbftpEnabled(boolean bbftpEnabled) {
        this.bbftpEnabled = bbftpEnabled;
    }

    public boolean isUseCommandServer() {
        return useCommandServer;
    }

    public void setUseCommandServer(boolean useCommandServer) {
        this.useCommandServer = useCommandServer;
    }

    private static void usageAndExit(String msg, Options options) {
        System.err.println(msg);
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("SupPortal", options);
        System.exit(-1);
    }

    public static void main(String[] args) throws Exception {
        Options options = new Options();
        options.addOption(HOST_OPT, true, "remote host");
        options.addOption(USER_OPT, true, "remote user");
        options.addOption(OPERATION_OPT, true, "operation (exec or cp)");
        options.addOption(COMMAND_OPT, true, "command to exec (exec only)");
        options.addOption(SRC_OPT, true, "source file/directory (cp only)");
        options.addOption(DEST_OPT, true, "destination file/directory (cp only)");

        CommandLineParser parser = new GnuParser();
        CommandLine cmdLine = null;
        try {
            cmdLine = parser.parse(options, args);
        } catch (ParseException e) {
            usageAndExit("Illegal argument: " + e.getMessage(), options);
        }

        String host = cmdLine.getOptionValue(HOST_OPT);
        String user = cmdLine.getOptionValue(USER_OPT);
        String operation = cmdLine.getOptionValue(OPERATION_OPT);

        if (host == null || user == null || operation == null) {
            usageAndExit("host, user, and operation must be specified", options);
        }

        SupPortal supPortal = new SupPortal(new String[]{host}, user);

        if (operation.equals("exec")) {
            String command = cmdLine.getOptionValue(COMMAND_OPT);
            if (command == null) {
                usageAndExit("command must be specified when using --exec", options);
            }

            List<String> commandLine = new LinkedList<String>();
            commandLine.add(command);
            SupCommandResults response = supPortal.execCommand(commandLine);

            System.out.println("stdout:");
            System.out.println(response.getStdOut());
            System.out.println("stderr:");
            System.out.println(response.getStdErr());
            System.out.println(response);

        } else if (operation.equals("get") || operation.equals("put")) {
            String src = cmdLine.getOptionValue(SRC_OPT);
            String dest = cmdLine.getOptionValue(DEST_OPT);

            if (src == null || dest == null) {
                usageAndExit("--src and --dest must be specified when using --get or --put", options);
            }

            if (operation.equals("get")) {
                supPortal.getFiles(src, dest);
            } else if (operation.equals("put")) {
                supPortal.putFiles(src, dest);
            }
        } else {
            usageAndExit("Unknown operation, must be exec or cp, was: " + operation, options);
        }
    }
}
