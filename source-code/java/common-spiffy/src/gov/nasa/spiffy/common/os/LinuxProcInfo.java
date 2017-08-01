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

package gov.nasa.spiffy.common.os;

import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class parses /proc/PID/status on a Linux box and provides the contents
 * as a {@link Map}.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Forrest Girouard
 */
public class LinuxProcInfo extends AbstractSysInfo implements ProcInfo {

    private static final Log log = LogFactory.getLog(LinuxProcInfo.class);

    private static final String PROC_STATUS_FILE = "/proc/%d/status";
    private static final String PROC_LIMITS_FILE = "/proc/%d/limits";

    private static final String MAX_OPEN_FILES = "Max open files";

    private int pid;

    public LinuxProcInfo(int pid) throws IOException {
        super(new FileReader(String.format(PROC_STATUS_FILE, pid)));
        this.pid = pid;
    }

    public LinuxProcInfo() throws IOException {
        super(new FileReader(String.format(PROC_STATUS_FILE,
            gov.nasa.spiffy.common.os.ProcessUtils.getPid())));
        pid = gov.nasa.spiffy.common.os.ProcessUtils.getPid();
    }

    @Override
    public List<Integer> getChildPids() throws IOException {

        return getChildPids(null);
    }

    @Override
    public List<Integer> getChildPids(String name) throws IOException {

        int currentPid = Integer.valueOf(get("Pid"));
        File procDir = new File("/proc");
        File[] procFiles = procDir.listFiles();
        List<Integer> childPids = new LinkedList<Integer>();

        for (File procFile : procFiles) {
            try {
                int pid = Integer.parseInt(procFile.getName());
                LinuxProcInfo procInfo = new LinuxProcInfo(pid);
                String processName = procInfo.get("Name");
                int ppid = Integer.parseInt(procInfo.get("PPid"));

                if (ppid == currentPid
                    && (name == null || name.equals(processName))) {
                    // found a match
                    log.info("Found child process, pid=" + pid + ", name="
                        + processName);
                    childPids.add(pid);
                }
            } catch (Exception e) {
                // ignore files that are not a number (PID) or can't be read
            }
        }

        return childPids;
    }

    @Override
    public int getParentPid() {
        return Integer.valueOf(get("PPid"));
    }

    @Override
    public int getPid() {
        return pid;
    }

    /**
     * Return the maximum number of open files for this process.
     * 
     * @return -1 for unlimited.
     * @throws IOException
     */
    @Override
    public int getOpenFileLimit() throws IOException {
        int openFileLimit = -1;
        
        File f = new File(String.format(PROC_LIMITS_FILE,
            Integer.valueOf(get("Pid"))));
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(f));
            for (String line = reader.readLine(); line != null; line = reader.readLine()) {
                if (!line.startsWith(MAX_OPEN_FILES)) {
                    continue;
                }
                String[] parts = line.split("\\s+");

                openFileLimit = Integer.parseInt(parts[parts.length - 3]);
            }
        } finally {
            FileUtil.close(reader);
        }

        return openFileLimit;
    }

    /**
     * Return the maximum process id value.
     * This value can be found in "/proc/sys/kernel/pid_max". By default, it is
     * 32768, but on 64-bit systems it can be increased up to 1 << 22. See 
     * "man 5 proc" and search for "pid_max".
     */
    @Override
    public int getMaximumPid() {
        // This is true for all systems, 32-bit or 64-bit
        return 1 << 22;
    }
}
