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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.SequenceInputStream;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Determines the total memory for the current hardware at runtime under the Mac
 * OS X operating system.
 * 
 * @author Forrest Girouard
 * 
 */
public class MacOSXMemInfo extends AbstractMemInfo {

    private static final Log log = LogFactory.getLog(LinuxMemInfo.class);

    private static final String TOP_COMMAND = "top -F -l 1 -n 0 -S";
    private static final String SYSTEM_PROFILER = "/usr/sbin/system_profiler SPMemoryDataType";

    private static final String TOTAL_MEMORY = "TotalMemory";
    private static final String FREE_MEMORY = "FreeMemory";
    private static final String TOTAL_SWAP = "TotalSwap";
    private static final String FREE_SWAP = "FreeSwap";

    private static final String UNAVAILABLE = "Unavailable";

    public MacOSXMemInfo() throws IOException {

        super(new InputStreamReader(new SequenceInputStream(
            Runtime.getRuntime()
                .exec(TOP_COMMAND)
                .getInputStream(), Runtime.getRuntime()
                .exec(SYSTEM_PROFILER)
                .getInputStream())));
    }

    @Override
    protected void parse(BufferedReader reader) throws IOException {

        String line;
        do {
            line = reader.readLine();

            log.debug("line = " + line);

            if (line != null && line.trim()
                .length() > 0) {
                String[] tokens = line.trim()
                    .split("[\\s]+");
                String field = tokens[0].trim()
                    .toLowerCase();
                if (field.startsWith("physmem")) {
                    put(TOTAL_MEMORY, valueOf(tokens[7]) + valueOf(tokens[9]));
                    put(FREE_MEMORY, valueOf(tokens[9]));
                } else if (field.startsWith("swap")) {
                    put(TOTAL_SWAP, valueOf(tokens[1]) + valueOf(tokens[3]));
                    put(FREE_SWAP, valueOf(tokens[3]));
                } else if (field.startsWith("Memory:")) {
                    put(TOTAL_MEMORY, parseSystemProfilerMemory(reader));
                }
            }
        } while (line != null);
    }

    private int parseSystemProfilerMemory(BufferedReader reader)
        throws IOException {

        int totalMemory = 0;
        String line;
        do {
            line = reader.readLine();

            log.debug("line = " + line);

            if (line != null && line.trim()
                .length() > 0) {
                String[] tokens = line.trim()
                    .split("[\\s]+");
                if (tokens[0].equalsIgnoreCase("size:")
                    && tokens[2].equals("GB")) {
                    totalMemory += valueOf(tokens[1]);
                } else if (line.matches("^[^ \t]")) {
                    break;
                }
            }
        } while (line != null);

        return totalMemory;
    }

    private static int valueOf(String intString) {
        int value = 0;
        if (intString.endsWith("B")) {
            value += Integer.valueOf(intString.substring(0,
                intString.length() - 1)) / 1024;
        } else if (intString.endsWith("K")) {
            value += Integer.valueOf(intString.substring(0,
                intString.length() - 1));
        } else if (intString.endsWith("M")) {
            value += Integer.valueOf(intString.substring(0,
                intString.length() - 1)) * 1024;
        } else if (intString.endsWith("G")) {
            value += Integer.valueOf(intString.substring(0,
                intString.length() - 1)) * 1024 * 1024;
        } else {
            value += Integer.valueOf(intString);
        }
        return value;
    }

    private void put(String key, int value) {
        put(key.toLowerCase(), String.format("%d KB", value));
    }

    @Override
    public String getBuffersKey() {
        return UNAVAILABLE;
    }

    @Override
    public String getCachedKey() {
        return UNAVAILABLE;
    }

    @Override
    public String getCachedSwapKey() {
        return UNAVAILABLE;
    }

    @Override
    public String getFreeMemoryKey() {
        return FREE_MEMORY;
    }

    @Override
    public String getFreeSwapKey() {
        return FREE_SWAP;
    }

    @Override
    public String getTotalMemoryKey() {
        return TOTAL_MEMORY;
    }

    @Override
    public String getTotalSwapKey() {
        return TOTAL_SWAP;
    }

    @Override
    public void logMemoryUsage(Log log) {
        if (!log.isDebugEnabled()) {
            return;
        }

        log.debug(String.format("%s: %s\n", "Heap Memory Usage",
            getMemoryUsage(true)));
        log.debug(String.format("%s: %s\n", "Nonheap Memory Usage",
            getMemoryUsage(false)));
    }
}
