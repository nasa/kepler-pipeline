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
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class parses output from ps(1) on a MacOSX box and provides the contents
 * as a {@link Map}.
 * 
 * @author Forrest Girouard
 */
public class MacOSXProcInfo extends AbstractSysInfo implements ProcInfo {

    private static final Log log = LogFactory.getLog(LinuxProcInfo.class);

    private static final String PS_COMMAND = "ps -p %d -o pid=,ppid=,command=";
    private static final String PS_LIST_COMMAND = "ps -xA -o pid=,ppid=,command=";
    private static final String ULIMIT_COMMAND = "sh ulimit -n";
    private static final int MAX_PID_VALUE = 99999;

    private int pid;

    public MacOSXProcInfo(int pid) throws IOException {
        super(new InputStreamReader(Runtime.getRuntime()
            .exec(String.format(PS_COMMAND, pid))
            .getInputStream()));
        this.pid = pid;
    }

    public MacOSXProcInfo() throws IOException {
        super(new InputStreamReader(Runtime.getRuntime()
            .exec(
                String.format(PS_COMMAND,
                    gov.nasa.spiffy.common.os.ProcessUtils.getPid()))
            .getInputStream()));
        pid = gov.nasa.spiffy.common.os.ProcessUtils.getPid();
    }

    @Override
    protected void parse(BufferedReader procInfoReader) throws IOException {

        String line;
        do {
            line = procInfoReader.readLine();

            log.debug("line = " + line);

            if (line != null && line.trim()
                .length() > 0) {
                String[] tokens = line.trim()
                    .split("[\\s]+");
                if (tokens.length < 2) {
                    log.debug("ignoring line with two few tokens: " + line);
                    continue;
                }
                put("Pid", tokens[0]);
                put("PPid", tokens[1]);
                put("Name", tokens[2]);
            }
        } while (line != null);
    }

    @Override
    public List<Integer> getChildPids() throws IOException {

        return getChildPids(null);
    }

    @Override
    public List<Integer> getChildPids(String name) throws IOException {

        int currentPid = Integer.valueOf(get("Pid"));
        BufferedReader psListReader = new BufferedReader(new InputStreamReader(
            Runtime.getRuntime()
                .exec(PS_LIST_COMMAND)
                .getInputStream()));
        List<Integer> childPids = new LinkedList<Integer>();

        String line;
        do {
            line = psListReader.readLine();

            log.debug("line = " + line);

            if (line != null && line.trim()
                .length() > 0) {
                String[] tokens = line.trim()
                    .split("[\\s]+");
                if (tokens.length < 2) {
                    log.debug("ignoring line with two few tokens: " + line);
                    continue;
                }
                if (Integer.valueOf(tokens[1]) == currentPid
                    && (name == null || tokens[2].endsWith(name))) {
                    // found a match
                    int pid = Integer.valueOf(tokens[0]);
                    log.info("Found child process, pid=" + pid + ", name="
                        + tokens[2]);
                    childPids.add(pid);
                }
            }
        } while (line != null);

        return childPids;
    }

    @Override
    public int getParentPid() throws Exception {
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
     */
    @Override
    public int getOpenFileLimit() throws IOException {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(
                Runtime.getRuntime()
                    .exec(ULIMIT_COMMAND)
                    .getInputStream()));

            return Integer.parseInt(reader.readLine());
        } catch (NumberFormatException e) {
            return -1;
        } finally {
            FileUtil.close(reader);
        }
    }

    /**
     * Return the maximum process id value.
     */
    @Override
    public int getMaximumPid() {
        return MAX_PID_VALUE;
    }
}
