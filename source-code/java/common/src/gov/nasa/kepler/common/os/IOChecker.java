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

package gov.nasa.kepler.common.os;

import gov.nasa.spiffy.common.io.DirectoryWalker;
import gov.nasa.spiffy.common.io.FileVisitor;
import gov.nasa.spiffy.common.lang.DefaultSystemProvider;
import gov.nasa.spiffy.common.lang.SystemProvider;
import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.os.ProcessUtils;
import gov.nasa.spiffy.common.os.ProcessUtils.ProcessOutput;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.MissingOptionException;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableSet;

/**
 * Verifies that the current I/O subsystem is correct.  This is only useful
 * on Linux.  This looks in /sys/block/... directories for misconfigured
 * I/O scheduler parameters.
 * 
 * @author Sean McCauliff
 *
 */
public class IOChecker {
    private static final Log log = LogFactory.getLog(IOChecker.class);
    
    private static final File BLOCK_DEVICES = new File("/sys/block");
    public static final String EXPECTED_LEAF_NODE_SCHEDULER_DEFAULT = "noop";
    public static final int EXPECTED_INTERNAL_NODE_READ_AHEAD_KB_DEFAULT = 0;
    public static final int EXPECTED_LEAF_NODE_READ_AHEAD_KB_DEFAULT = 32;
    public static final String EXPECTED_INTERAL_NODE_SCHEDULER_DEFAULT = "noop";
    
    /**
     * This device does not have a scheduler algorithm associated with it.
     */
    private static final String NONE_SCHEDULER = "none";
    
    /**
     * from: http://www.lanana.org/docs/device-list/devices-2.6+.txt
     * 
     * SCSI device major numbers have been allocated permanent major numbers,
     * but device mapper devices have no such dedicated region of numbers.
     */
    private static final Set<Integer> scsiDeviceMajorNumbers =
        ImmutableSet.of(8, 65, 66, 67, 68, 69, 70, 71, 128, 129, 130, 131, 132, 133, 143, 135);
    
    private static final Set<String> pruneDirectoryNames =
        ImmutableSet.of("holders", "subsystem", "device");
    
    @SuppressWarnings("static-access")
    private final Option deviceDirOption = OptionBuilder.isRequired()
        .hasArg()
        .withArgName("mounted dir")
        .withDescription("The mounted directory or subdirectory which needs it's underlying scheduling devices reconfigured.")
        .withLongOpt("mounted-dir")
        .create('d');
    
    @SuppressWarnings("static-access")
    private final Option dryRunOption = OptionBuilder.hasArg(false)
        .withDescription("Dry run.  Just print out the current state of the cpnfiguration noting which devices our not conforming.  This does not usually require root access.")
        .withLongOpt("dry-run")
        .create('r');
    
    @SuppressWarnings("static-access")
    private final Option readAheadKbInternalOption = OptionBuilder.hasArg()
        .withArgName("kb")
        .withDescription("The number of kilobytes of read ahead an internal node in the block device tree should have.  Default : " + EXPECTED_INTERNAL_NODE_READ_AHEAD_KB_DEFAULT)
        .withLongOpt("internal-read-ahead-kb")
        .create('e');
    
    @SuppressWarnings("static-access")
    private final Option readAheadKbLeafOption = OptionBuilder.hasArg()
        .withArgName("kb")
        .withDescription("The number of kilobytes of read ahead a leaf node in the block device tree should have.  Leaf nodes are typicall disk devices.  Default : " + EXPECTED_LEAF_NODE_READ_AHEAD_KB_DEFAULT)
        .withLongOpt("leaf-read-ahead-kb")
        .create('h');
    
    @SuppressWarnings("static-access")
    private final Option internalSchedulerOption = OptionBuilder.hasArg()
        .withArgName("scheduler")
        .withDescription("The scheduling algorithm an internal node in the" +
        		" block device tree should have.  Valid strings are \"noop\",\"deadline\",\"cfq\".  Default is : "  + EXPECTED_INTERAL_NODE_SCHEDULER_DEFAULT)
        .withLongOpt("internal-scheduler")
        .create('c');
    
    @SuppressWarnings("static-access")
    private final Option leafSchedulerOption = OptionBuilder.hasArg()
        .withArgName("scheduler")
        .withDescription("The scheduling algorithm a leaf node in the" +
                " block device tree should have.  Leaf nodes are typically disk devices."  +
            "  Valid strings are \"noop\",\"deadline\",\"cfq\".  Default is : " 
                + EXPECTED_LEAF_NODE_SCHEDULER_DEFAULT)
        .withLongOpt("leaf-scheduler")
        .create('s');
    
    private final Options cliOptions;
    
    private final SystemProvider system;
    
    File directory;
    int expectedInternalReadAheadKb = EXPECTED_INTERNAL_NODE_READ_AHEAD_KB_DEFAULT;
    int expectedLeafReadAheadKb = EXPECTED_LEAF_NODE_READ_AHEAD_KB_DEFAULT;
    String expectedInternalScheduler = EXPECTED_INTERAL_NODE_SCHEDULER_DEFAULT;
    String expectedLeafScheduler = EXPECTED_LEAF_NODE_SCHEDULER_DEFAULT;
    boolean dryRun = false;
    
    public IOChecker(SystemProvider system, File directory,
        int expectedInternalReadAheadKb, int expectedLeafReadAheadKb,
        String expectedInternalScheduler, String expectedLeafScheduler,
        boolean dryRun) throws IOException {
        this(system);

        this.directory = directory.getCanonicalFile();
        this.expectedInternalReadAheadKb = expectedInternalReadAheadKb;
        this.expectedLeafReadAheadKb = expectedLeafReadAheadKb;
        this.expectedInternalScheduler = expectedInternalScheduler;
        this.expectedLeafScheduler = expectedLeafScheduler;
        this.dryRun = dryRun;
    }

    public IOChecker(SystemProvider system) {
        this.system = system;
        cliOptions = new Options();
        cliOptions.addOption(deviceDirOption);
        cliOptions.addOption(dryRunOption);
        cliOptions.addOption(internalSchedulerOption);
        cliOptions.addOption(leafSchedulerOption);
        cliOptions.addOption(readAheadKbInternalOption);
        cliOptions.addOption(readAheadKbLeafOption);
    }
    
    /**
     * Start descending the system directory structure from the top by
     * specifying a directory on a mounted file system where checking should
     * start.
     * @param directory  Some directory in the mounted file system where
     * checking should start.  This need not be the mount point of the file
     * system.
     * @param fixErrors When true this will fix the errors found in the 
     * block device configuration tree.  This requires root permissions.
     * @throws InterruptedException 
     * @throws IOException 
     */
    public Report topDownCheck() throws IOException, InterruptedException {
        OperatingSystemType osType = OperatingSystemType.getInstance();
        if (osType != OperatingSystemType.LINUX) {
            throw new IllegalStateException("This can only be run on Linux.");
        }
        
        List<String> mountedFileSystems = FileUtils.readLines(new File("/proc/mounts"));

        String deviceName = fileSystemDeviceName(directory, mountedFileSystems);
        log.info("File system is mounted on device " + deviceName);
        
        String deviceLsOutput = lsDashLFollowSymlink(deviceName);
        String[] deviceNumberFields = deviceLsOutput.split("\\s+");
        int majorDeviceNumber = Integer.parseInt(StringUtils.chop(deviceNumberFields[4]));
        int minorDeviceNumber = Integer.parseInt(deviceNumberFields[5]);
        File sysFileRoot = (scsiDeviceMajorNumbers.contains(majorDeviceNumber)) ?
            new File(BLOCK_DEVICES, createScsiSystemName(deviceName)) :
            new File(BLOCK_DEVICES, "dm-" + minorDeviceNumber ); //guessing this is a device mapper device
        log.info("Checking device " + sysFileRoot);
        DirectoryWalker directoryWalker = new DirectoryWalker(sysFileRoot);
        TopDownSystemVisitor topDown = new TopDownSystemVisitor(sysFileRoot, BLOCK_DEVICES);
        directoryWalker.traverse(topDown);
        
        Map<String, IODeviceDependencyNode> nodes = topDown.assembledMap();
        Report report = dotReportString(nodes.values(), expectedInternalReadAheadKb,
            expectedLeafReadAheadKb, expectedInternalScheduler,
            expectedLeafScheduler);
        if (!report.ok && !dryRun) {
            fixErrors(nodes.values(), expectedInternalReadAheadKb, expectedLeafReadAheadKb,
                expectedInternalScheduler, expectedLeafScheduler);
        }
        return report;
    }
    
    void parse(String[] argv) throws Exception {
        if (argv.length == 0) {
            printHelp();
            system.exit(1);
            throw new IllegalArgumentException("Need command line options.");
        }
        
        GnuParser gnuParser = new GnuParser();
        CommandLine commandLine = null;
        try {
            commandLine = gnuParser.parse(cliOptions, argv);
        } catch (MissingOptionException mox) {
            printHelp();
            throw mox;
        }
     
        directory = new File(commandLine.getOptionValue(deviceDirOption.getOpt())).getCanonicalFile();
        
        if (commandLine.hasOption(dryRunOption.getOpt())) {
            dryRun = true;
        }
        
        String optStr = commandLine.getOptionValue(readAheadKbInternalOption.getOpt(), Integer.toString(EXPECTED_INTERNAL_NODE_READ_AHEAD_KB_DEFAULT));
        expectedInternalReadAheadKb = Integer.parseInt(optStr);
        optStr = commandLine.getOptionValue(readAheadKbLeafOption.getOpt(), Integer.toString(EXPECTED_LEAF_NODE_READ_AHEAD_KB_DEFAULT));
        expectedLeafReadAheadKb = Integer.parseInt(optStr);
        expectedInternalScheduler = commandLine.getOptionValue(internalSchedulerOption.getOpt(), EXPECTED_INTERAL_NODE_SCHEDULER_DEFAULT);
        expectedLeafScheduler = commandLine.getOptionValue(leafSchedulerOption.getOpt(), EXPECTED_LEAF_NODE_SCHEDULER_DEFAULT);

        if (checkScheduler(expectedInternalScheduler)) {
            throw new IllegalStateException("Bad scheduler.");
        }
        if (checkScheduler(expectedLeafScheduler)) {
            throw new IllegalStateException("Bad scheduler.");
        }
    }
    
    private boolean checkScheduler(String schedulerString) {
        if (schedulerString.equals("noop") || schedulerString.equals("deadline") ||
            schedulerString.equals("cfq")) {
            return false;
        }
        
        system.err().println("Invalid scheduler \"" + schedulerString + "\".");
        system.err().println("Valid schedulers are \"noop\", \"deadline\", \"cfq\".");
        system.exit(1);
        return true;
    }
    
    private void printHelp() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp(80, "./runjava iochecker ", "", cliOptions, "", true);
    }
    
    static void fixErrors(Collection<IODeviceDependencyNode> nodes,
        int expectedInternalReadAheadKb, 
        int expectedLeafReadAheadKb,
        String expectedInternalScheduler,
        String expectedLeafScheduler) 
        throws NumberFormatException, IOException {
        for (IODeviceDependencyNode node : nodes) {
            Integer readAheadKb = node.readAheadKb();
            String scheduler = node.scheduler();
            int expectedReadAheadKb = (node.isLeaf()) ? expectedLeafReadAheadKb : expectedInternalReadAheadKb;
            String expectedScheduler = (node.isLeaf()) ? expectedLeafScheduler : expectedInternalScheduler;
            
            if (readAheadKb != null && readAheadKb != expectedReadAheadKb) {
                node.setReadAheadKb(expectedReadAheadKb);
            }
            if (scheduler != null && !scheduler.equals(expectedScheduler)){
                node.setScheduler(expectedScheduler);
            }
        }
    }

    /**
     * If ls -l returns a symlink then follow the link until it gets to a file.
     * @param deviceName
     * @return ls -l output on file
     * @throws InterruptedException 
     * @throws IOException 
     */
    static String lsDashLFollowSymlink(String deviceName) throws IOException, InterruptedException {
        while (true) {
            ProcessOutput lsOutput = ProcessUtils.grabOutput("ls -l " + deviceName);
            if (lsOutput.returnCode() != 0) {
                throw new IllegalStateException("ls -l" + deviceName + " failed"
                    + lsOutput.err());
            }
            String[] outputParts = lsOutput.output().split("\\s+");
            if (outputParts.length >= 11 && outputParts[9].equals("->")) {
                if (!outputParts[10].startsWith("/")) {
                    File f = new File(deviceName);
                    deviceName = f.getParent() + "/" + outputParts[10];
                } else {
                    deviceName = outputParts[10];
                }
            } else {
                return lsOutput.output();
            }
        }
    }
    
    static Report dotReportString(Collection<IODeviceDependencyNode> nodes,
        int expectedInternalReadAheadKb,
        int expectedLeafReadAheadKb,
        String expectedInternalScheduler,
        String expectedLeafScheduler)
        throws NumberFormatException, IOException {
        boolean isConfiguredCorrectly = true;
        StringBuilder bldr = new StringBuilder();
        bldr.append("digraph IODeviceGraph {\n");

        for (IODeviceDependencyNode node : nodes) {
            boolean isDeviceConfiguredOk = true;
            if (node.isLeaf()) {
                Integer readAhead = node.readAheadKb();
                if (readAhead == null) {
                    throw new IllegalStateException("Leaf node " + node.deviceName() + " does not have read ahead control.");
                }
                String scheduler = node.scheduler();
                if (scheduler == null) {
                    throw new IllegalStateException("Leaf node " + node.deviceName() + " must have scheduler.");
                }
                if (!scheduler.equals(expectedLeafScheduler) ||
                    readAhead != expectedLeafReadAheadKb) {
                    isDeviceConfiguredOk = false;
                    isConfiguredCorrectly = false;
                }
            } else {
                Integer readAhead = node.readAheadKb();
                String scheduler = node.scheduler();
                if ((readAhead != null && readAhead != expectedInternalReadAheadKb) ||
                    (scheduler != null && !scheduler.equals(NONE_SCHEDULER) && !scheduler.equals(expectedInternalScheduler))) {
                    isDeviceConfiguredOk = false;
                    isConfiguredCorrectly = false;
                }
            }
            bldr.append("\t").append(node.toDot(isDeviceConfiguredOk));
        }
        
        for (IODeviceDependencyNode node : nodes) {
            for (IODeviceDependencyNode slaveNode : node.slaves) {
                bldr.append("\t\"").append(node.deviceName()).append("\"->\"")
                    .append(slaveNode.deviceName()).append("\";\n");
            }
        }
        bldr.append("}\n");
        return new Report(bldr.toString(), isConfiguredCorrectly);
    }
    
    /**
     * Trims out the "/dev" and partition numbers.
     * @param deviceName the name in "/dev"
     * @return The "sd<x>" string like "sda" or "sdaa"
     */
    static String createScsiSystemName(String deviceName) {
        int endIndex = deviceName.length();
        while (Character.isDigit(deviceName.charAt(endIndex - 1))) {
            endIndex--;
        }
        return deviceName.substring(4, endIndex);
    }
    
    static String fileSystemDeviceName(File directory, List<String> procMounts) {
        String dirAbsolutePath = directory.getAbsolutePath();
        int maxMatch = -1;
        String bestFileSystemDevice = null;
        for (String dfLine : procMounts) {
            String[] fields = dfLine.split("\\s+");
            String fsDevice = fields[0];
            if (fsDevice.length() == 0 || fsDevice.charAt(0) != '/') {
                continue;
            }
            String fsRoot = fields[1];
            int differenceAt = StringUtils.indexOfDifference(dirAbsolutePath, fsRoot);
            if (differenceAt == -1) {
                differenceAt  = fsRoot.length();
            }
            if (differenceAt < fsRoot.length()) {
                //Does not match the entire device path
                continue;
            }
            
            if (differenceAt > maxMatch) {
                bestFileSystemDevice = fsDevice;
                maxMatch = differenceAt;
            }
        }
        return bestFileSystemDevice;
    }
    
    /**
     * The result of running a check.  The report string contains a description
     * of what is wrong or was fixed.  This is Human readable.  The ok indicates
     * if the configuration is not correct.
     *
     */
    public static final class Report {
        public final String report;
        public final boolean ok;
        
        private Report(String report, boolean ok) {

            this.report = report;
            this.ok = ok;
        }
    }
    
    public static final class IODeviceDependencyNode {
        private final File sysDeviceFile;
        private final List<IODeviceDependencyNode> slaves;
        private final List<IODeviceDependencyNode> masters;
        
        /**
         * 
         * @param sysDeviceFile  This is the device under "/sys/block" where
         * this device resides.
         */
        IODeviceDependencyNode(File sysDeviceFile) {
            slaves = new ArrayList<IODeviceDependencyNode>();
            masters = new ArrayList<IODeviceDependencyNode>();
            this.sysDeviceFile = sysDeviceFile;
        }
        
        void addSlave(IODeviceDependencyNode slaveNode) {
            slaves.add(slaveNode);
        }
        
        void addMaster(IODeviceDependencyNode masterNode) {
            masters.add(masterNode);
        }
        
        String deviceName() {
            return sysDeviceFile.getName();
        }
        
        boolean isLeaf() {
            return slaves.isEmpty();
        }
        
        private File readAheadFile() {
            return new File(sysDeviceFile.getAbsolutePath() + "/queue/read_ahead_kb");
        }
        
        /**
         * 
         * @return  This device may not have a separately configurable 
         * read ahead so this will return null if that is the case.
         * @throws NumberFormatException
         * @throws IOException
         */
        Integer readAheadKb() throws NumberFormatException, IOException {
            File readAheadFile = readAheadFile();
            if (!readAheadFile.exists()) {
                return null;
            }
            return Integer.parseInt(StringUtils.trim(FileUtils.readFileToString(readAheadFile)));
        }
        
        /**
         * 
         * @param newReadAheadKb
         * @throws IOException
         */
        void setReadAheadKb(int newReadAheadKb) throws IOException {
            File readAheadFile = readAheadFile();
            FileUtils.writeStringToFile(readAheadFile, Integer.toString(newReadAheadKb));
        }
        
        private File schedulerFile() {
            return new File(sysDeviceFile.getAbsolutePath() + "/queue/scheduler");
        }
        
        /**
         * 
         * @return  This device may not have a separately configurable scheduler
         * In that case this will return null.
         * @throws IOException
         */
        String scheduler() throws IOException {
            File schedulerFile = schedulerFile();
            if (!schedulerFile.exists()) {
                return null;
            }
            String allSchedulerString = StringUtils.trim(FileUtils.readFileToString(schedulerFile));
            if (allSchedulerString.indexOf(' ') == -1) {
                //This is a test file, not something out of the kernel.
                return allSchedulerString;
            }
            //The kernel's scheduler string looks something like "noop [cfq] deadline"
            //or just the string "none"
            if (allSchedulerString.equals(NONE_SCHEDULER)) {
                return NONE_SCHEDULER;
            }
            int selectedSchedulerStart = allSchedulerString.indexOf('[');
            int selectedSchedulerEnd = allSchedulerString.lastIndexOf(']');
            if (selectedSchedulerStart == -1 || selectedSchedulerEnd == -1) {
                throw new IllegalStateException("Bad scheduler string \"" + allSchedulerString + "\"");
            }
            return allSchedulerString.substring(selectedSchedulerStart+1, selectedSchedulerEnd);
        }
        
        void setScheduler(String newScheduler) throws IOException {
            File schedulerFile = schedulerFile();
            //No need to format this with '[' characters.  The kernel takes
            //care of setting the scheduling algorithm
            FileUtils.writeStringToFile(schedulerFile, newScheduler);
        }
        
        /**
         * The graphviz format for a node in the graph.
         * @return
         * @throws IOException 
         * @throws NumberFormatException 
         */
        String toDot(boolean configuredOk) throws NumberFormatException, IOException {
            StringBuilder b = new StringBuilder();
            b.append('"').append(deviceName()).append('"')
                .append("[shape=\"hexagon\" label =<<table border=\"0\" cellborder=\"0\" cellpadding=\"3\" bgcolor=\"white\"><tr><td bgcolor=\"black\" align=\"center\" colspan=\"2\"><font color=\"white\">")
                .append(deviceName())
                .append("</font></td></tr><tr><td align=\"left\" > read_ahead_kb </td><td>")
                .append(readAheadKb())
                .append("</td></tr><tr><td align=\"left\">scheduler</td><td>")
                .append(scheduler())
                .append("</td></tr><tr><td align=\"left\">configured ok?</td><td>")
                .append(configuredOk).append("</td></tr></table>>];\n");
            return b.toString();
        }
        
        @Override
        public String toString() {
            return "IONode[" + sysDeviceFile.getAbsolutePath() + "]";
        }
    }
    
    public static final class TopDownSystemVisitor implements FileVisitor {
        private final Map<String, IODeviceDependencyNode> deviceNameToDeviceNode
            = new HashMap<String, IOChecker.IODeviceDependencyNode>();
        private IODeviceDependencyNode rootNode;
        private boolean prune = false;

        TopDownSystemVisitor(File rootDeviceFile, File blockDeviceRoot) {
            rootNode = new IODeviceDependencyNode(rootDeviceFile);
            deviceNameToDeviceNode.put(rootNode.deviceName(), rootNode);
        }

        IODeviceDependencyNode rootNode() {
            return rootNode;
        }
        
        Map<String, IODeviceDependencyNode> assembledMap() {
            return deviceNameToDeviceNode;
        }
        
        @Override
        public void enterDirectory(File newDir) throws IOException,
            PipelineException {

            File parentDir = newDir.getParentFile();
            File parentsParentDir = null;
            if (parentDir != null) {
                parentsParentDir = parentDir.getParentFile();
            }
            if (parentDir != null && parentDir.getName().equals("slaves")) {
                IODeviceDependencyNode slaveNode = deviceNameToDeviceNode.get(newDir.getName());
                if (slaveNode == null) {
                    slaveNode = new IODeviceDependencyNode(newDir);
                    deviceNameToDeviceNode.put(newDir.getName(), slaveNode);
                }
                if (parentsParentDir != null) {
                    IODeviceDependencyNode parentNode = deviceNameToDeviceNode.get(parentsParentDir.getName());
                    parentNode.addSlave(slaveNode);
                    slaveNode.addMaster(parentNode);
                }
            } else if (pruneDirectoryNames.contains(newDir.getName())) {
                    prune = true;
            }
        }

        /**
         * This does nothing.
         */
        @Override
        public void exitDirectory(File exitdir) throws IOException,
            PipelineException {
        }

        @Override
        public void visitFile(File dir, File f) throws IOException,
            PipelineException {
            if (!f.getName().equals("dev")) {
                return;
            }
            
            String deviceString = StringUtils.trim(FileUtils.readFileToString(f));
            String[] deviceStringParts = StringUtils.split(deviceString, ':');
            int majorNumber = Integer.parseInt(deviceStringParts[0]);
            int minorNumber = Integer.parseInt(deviceStringParts[1]);
            if (!scsiDeviceMajorNumbers.contains(majorNumber)) {
                return;
            }
            
            int partitionNumber = minorNumber & 0x0f;
            if (partitionNumber == 0) {
                //This device is the scsi disk device.
                return;
            }
            
            //This device is actually a partition, add it's disk to the
            //dependency tree.
            log.info("Found disk partition " + dir.getName()+ 
                " minor number " + minorNumber + " major number "
                + majorNumber + ".");

            //In some kernels' the disk device appears in the tree before the partition.
            String partitionNumberStr = Integer.toString(partitionNumber);
            String diskName = 
                StringUtils.removeEnd(dir.getName(), partitionNumberStr);
            IODeviceDependencyNode diskNode = deviceNameToDeviceNode.get(diskName);
            IODeviceDependencyNode partitionNode = deviceNameToDeviceNode.get(dir.getName());
            if (diskNode == null) {
                File diskDeviceFile = new File(BLOCK_DEVICES, diskName);
                diskNode = new IODeviceDependencyNode(diskDeviceFile);
                deviceNameToDeviceNode.put(diskName, diskNode);
            }
            if (partitionNode == null) {
                //This kernel puts the partition devices under the disk devices
                File partitionDeviceFile = new File(diskNode.sysDeviceFile, dir.getName());
                partitionNode = new IODeviceDependencyNode(partitionDeviceFile);
                deviceNameToDeviceNode.put(partitionNode.deviceName(), partitionNode);
            }
            partitionNode.addSlave(diskNode);   
            diskNode.addMaster(partitionNode);
        }

        @Override
        public boolean prune() {
            boolean old = prune;
            prune = false;
            return old;
        }
    }
    
    public static void main(String[] argv) throws Exception {
        IOChecker ioChecker = new IOChecker(new DefaultSystemProvider());
        ioChecker.parse(argv);
        Report report = ioChecker.topDownCheck();
        System.out.println(report.report);
        if (report.ok) {
            System.out.println("Schedulers are configured correctly.");
        }
    }
}
