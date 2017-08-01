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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.os.IOChecker.IODeviceDependencyNode;
import gov.nasa.kepler.common.os.IOChecker.Report;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;
import gov.nasa.spiffy.common.os.OperatingSystemType;

import java.io.File;
import java.util.Arrays;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.junit.Before;
import org.junit.Test;

/**
 * 
 * @author Sean McCauiff
 *
 */
public class IOCheckerTest {

    private File testDir = new File(Filenames.BUILD_TEST, "IOCheckerTest");
    @Before
    public void setUp() throws Exception {
        FileUtil.cleanDir(testDir);
        FileUtil.mkdirs(testDir);
    }
    
    @Test
    public void findMountedFileSystemTest() throws Exception {
        String[] procMountsCentos = new String[] {
            
            "rootfs / rootfs rw 0 0",
            "/dev/root / ext3 rw,data=ordered 0 0",
            "/dev /dev tmpfs rw 0 0",
            "/proc /proc proc rw 0 0",
            "/sys /sys sysfs rw 0 0",
            "/proc/bus/usb /proc/bus/usb usbfs rw 0 0",
            "devpts /dev/pts devpts rw 0 0",
            "/dev/sda1 /boot ext3 rw,nodev,data=ordered 0 0",
            "tmpfs /dev/shm tmpfs rw 0 0",
            "none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0",
            "sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw 0 0",
            "/etc/auto.misc /misc autofs rw,fd=7,pgrp=3042,timeout=300,minproto=5,maxproto=5,indirect 0 0",
            "-hosts /net autofs rw,fd=13,pgrp=3042,timeout=300,minproto=5,maxproto=5,indirect 0 0",
        };
      
        
        String deviceName = 
            IOChecker.fileSystemDeviceName(new File("/rootdir"), Arrays.asList(procMountsCentos));
        assertEquals("/dev/root", deviceName);
        
        String[] testfsMountsFedora13 = new String[] {
            "rootfs / rootfs rw 0 0",
            "/proc /proc proc rw,relatime 0 0",
            "/sys /sys sysfs rw,relatime 0 0",
            "udev /dev devtmpfs rw,relatime,size=33044520k,nr_inodes=8261130,mode=755 0 0",
            "devpts /dev/pts devpts rw,relatime,gid=5,mode=620,ptmxmode=000 0 0",
            "tmpfs /dev/shm tmpfs rw,relatime 0 0",
            "/dev/mapper/vg_testfs-lv_root / ext4 rw,relatime,barrier=1,data=ordered 0 0",
            "/proc/bus/usb /proc/bus/usb usbfs rw,relatime 0 0",
            "/dev/sda1 /boot ext3 rw,nodev,relatime,errors=continue,user_xattr,acl,data=ordered 0 0",
            "none /proc/sys/fs/binfmt_misc binfmt_misc rw,relatime 0 0",
            "sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw,relatime 0 0",
            "/etc/auto.misc /misc autofs rw,relatime,fd=6,pgrp=2956,timeout=300,minproto=5,maxproto=5,indirect 0 0",
            "-hosts /net autofs rw,relatime,fd=12,pgrp=2956,timeout=300,minproto=5,maxproto=5,indirect 0 0",
            "nfsd /proc/fs/nfsd nfsd rw,relatime 0 0",
        };
        
        List<String> testfsMountsAsList = Arrays.asList(testfsMountsFedora13);
        
        File fileStoreData = new File("/path/to/spq-test-fsdata01-rw-12Oct2010/fsdatadir/");
        File fileStoreTransactionLog = 
            new File("/path/to/spq-test-fsdata01-rw-12Oct2010/fsdatadir/transactionLog");
        deviceName = IOChecker.fileSystemDeviceName(fileStoreData, testfsMountsAsList);
        assertEquals("/dev/mapper/blah", deviceName);
        deviceName = IOChecker.fileSystemDeviceName(fileStoreTransactionLog, testfsMountsAsList);
        assertEquals("/dev/mapper/blah", deviceName);
        
    }
    
    
    @Test
    public void reportAndFixTest() throws Exception {
        File sysDeviceRoot = new File(testDir, "sysRoot");
        FileUtil.mkdirs(sysDeviceRoot);
        File dm0 = new File(sysDeviceRoot, "dm0");
        FileUtil.mkdirs(dm0);
        File dm0Slaves = new File(dm0, "slaves");
        FileUtil.mkdirs(dm0Slaves);
        File dm0Queue = new File(dm0, "queue");
        FileUtil.mkdirs(dm0Queue);
        File dm0Scheduler = new File(dm0Queue, "scheduler");
        FileUtils.writeStringToFile(dm0Scheduler, "noop deadline [cfq]\n");
        File dm0ReadAhead = new File(dm0Queue, "read_ahead_kb");
        FileUtils.writeStringToFile(dm0ReadAhead,"32");
        File sda = new File(dm0Slaves, "sda");
        File sdaQueue = new File(sda, "queue");
        FileUtil.mkdirs(sdaQueue);
        File sdaScheduler = new File(sdaQueue, "scheduler");
        FileUtils.writeStringToFile(sdaScheduler, "noop [deadline] cfq\n");
        File sdaReadAhead = new File(sdaQueue, "read_ahead_kb");
        FileUtils.writeStringToFile(sdaReadAhead, "64");
        File sda1 = new File(sda, "sda1");
        FileUtil.mkdirs(sda1);
        
        IODeviceDependencyNode dm0Node = new IODeviceDependencyNode(dm0);
        IODeviceDependencyNode sdaNode = new IODeviceDependencyNode(sda);
        IODeviceDependencyNode sda1Node = new IODeviceDependencyNode(sda1);
        dm0Node.addSlave(sdaNode);
        sdaNode.addMaster(dm0Node);
        sdaNode.addMaster(sda1Node);
        sda1Node.addSlave(sdaNode);
        
        List<IODeviceDependencyNode> nodes = Arrays.asList(new IODeviceDependencyNode[] {
            dm0Node, sdaNode, sda1Node
        });
        Report report = IOChecker.dotReportString(nodes, 1, 0, "deadline", "noop");
        assertFalse(report.ok);
        
        IOChecker.fixErrors(nodes, 1, 0, "deadline", "noop");
        
        
        assertEquals("0", FileUtils.readFileToString(sdaReadAhead));
        assertEquals("1", FileUtils.readFileToString(dm0ReadAhead));
        assertEquals("deadline", FileUtils.readFileToString(dm0Scheduler));
        assertEquals("noop", FileUtils.readFileToString(sdaScheduler));
        report = IOChecker.dotReportString(nodes, 1, 0, "deadline", "noop");
        assertTrue(report.ok);
        
    }
    
    @Test
    public void parseCommandLineTest() throws Exception {
        TestSystemProvider system = new TestSystemProvider(this.testDir);
        IOChecker checker = new IOChecker(system);
        checker.parse(new String[] { "-d", "/tmp", "-s",
            "noop", "-c", "deadline", "-r", "-e", "128", "-h", "55"
        });
        
        File tmp = null;
        if (OperatingSystemType.getInstance() == OperatingSystemType.MAC_OS_X) {
            tmp = new File("/private/tmp");
        } else {
            tmp = new File("/tmp");
        }
        assertEquals(0, system.returnCode());
        assertEquals(tmp, checker.directory);
        assertEquals(true, checker.dryRun);
        assertEquals("deadline", checker.expectedInternalScheduler);
        assertEquals(128, checker.expectedInternalReadAheadKb);
        assertEquals(55, checker.expectedLeafReadAheadKb);
        assertEquals("noop", checker.expectedLeafScheduler);
    }
}
