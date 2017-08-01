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

import java.io.FileReader;
import java.io.IOException;

import org.apache.commons.logging.Log;

/**
 * Determines the total memory for the current hardware at runtime under the
 * Linux operating system.
 * 
 * @author Forrest Girouard
 * 
 */
public class LinuxMemInfo extends AbstractMemInfo {

    private static final String MEMINFO_FILE = "/proc/meminfo";

    /*
     * <pre>
     * MemTotal: Total amount of physical RAM, in kilobytes.
     * MemFree: The amount of physical RAM, in kilobytes, left unused by the system.
     * Buffers: The amount of physical RAM, in kilobytes, used for file buffers.
     * Cached: The amount of physical RAM, in kilobytes, used as cache memory.
     * SwapCached: The amount of swap, in kilobytes, used as cache memory.
     * SwapTotal: The total amount of swap available, in kilobytes.
     * SwapFree: The total amount of swap free, in kilobytes.
     * 
     * MemTotal: 4061040 kB
     * MemFree: 587856 kB
     * Buffers: 21848 kB
     * Cached: 331860 kB
     * SwapCached: 73708 kB
     * SwapTotal: 2031608 kB
     * SwapFree: 1884796 kB
     * </pre>
     */

    private static final String TOTAL_MEMORY_KEY = "MemTotal";
    private static final String FREE_MEMORY_KEY = "MemFree";
    private static final String BUFFERS_KEY = "Buffers";
    private static final String CACHED_KEY = "Cached";
    private static final String SWAP_CACHED_KEY = "SwapCached";
    private static final String SWAP_TOTAL_KEY = "SwapTotal";
    private static final String SWAP_FREE_KEY = "SwapFree";

    public LinuxMemInfo() throws IOException {
        super(new FileReader(MEMINFO_FILE));
    }

    @Override
    public String getTotalMemoryKey() {
        return TOTAL_MEMORY_KEY;
    }

    @Override
    public String getBuffersKey() {
        return BUFFERS_KEY;
    }

    @Override
    public String getCachedKey() {
        return CACHED_KEY;
    }

    @Override
    public String getCachedSwapKey() {
        return SWAP_CACHED_KEY;
    }

    @Override
    public String getFreeMemoryKey() {
        return FREE_MEMORY_KEY;
    }

    @Override
    public String getFreeSwapKey() {
        return SWAP_FREE_KEY;
    }

    @Override
    public String getTotalSwapKey() {
        return SWAP_TOTAL_KEY;
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
