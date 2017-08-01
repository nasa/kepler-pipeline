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

package gov.nasa.kepler.systest;

import gov.nasa.spiffy.common.os.MemInfo;
import gov.nasa.spiffy.common.os.OperatingSystemType;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.ArrayList;
import java.util.List;

/**
 * Sets the max memory heap size in the wrapper.conf based on total
 * physical memory.
 * 
 * @author Miles Cote
 * 
 */
public class WrapperHeapSizeSetter {
    private static final String JVM_MAX_HEAP_PROP_NAME = "wrapper.java.maxmemory";

    private void setWrapperHeapSize(File wrapperConf) {
        try {
            // Read the file.
            List<String> lines = new ArrayList<String>();
            BufferedReader br = new BufferedReader(new FileReader(
                wrapperConf));
            for (String line = br.readLine(); line != null; line = br.readLine()) {
                lines.add(line);
            }
            br.close();

            lines = setWrapperHeapSize(lines, wrapperConf.getName());

            // Write the file.
            BufferedWriter bw = new BufferedWriter(new FileWriter(
                wrapperConf));
            for (String line : lines) {
                bw.write(line + "\n");
            }
            bw.close();
        } catch (Exception e) {
            throw new IllegalArgumentException(
                "Unable to set wrapper heap size.\n  file: " + wrapperConf,
                e);
        }
    }

    private List<String> setWrapperHeapSize(List<String> inputLines, String wrapperConfFileName)
        throws Exception {
        List<String> outputLines = new ArrayList<String>();
        for (String inputLine : inputLines) {
            String outputLine = inputLine;
            if (inputLine.trim()
                .startsWith(JVM_MAX_HEAP_PROP_NAME)) {
                MemInfo memInfo = OperatingSystemType.getInstance()
                    .getMemInfo();
                long totalMemoryMB = memInfo.getTotalMemoryKB() / 1000;

                long heapSize;
                if (wrapperConfFileName.startsWith("worker")) {
                    // Historically, the worker java process gets half of the
                    // physical memory, which leaves half for matlab and other
                    // processes.
                    heapSize = totalMemoryMB / 2;
                } else if (wrapperConfFileName.startsWith("fs")) {
                    // For fs, the old machines have ~64G, so they get 32G for the fs heap.
                    // The middle-age machines have ~128G, so they get 64G for the fs heap.
                    // The new mahchines have ~395G, so they get 128G for the fs heap.
                    if (totalMemoryMB < 67000) {
                        heapSize = 32000;
                    } else if (totalMemoryMB < 134000) {
                        heapSize = 32000;
                    } else {
                        heapSize = 32000;
                    }
                } else {
                    throw new IllegalArgumentException("Unexpected file name: " + wrapperConfFileName);
                }

                outputLine = JVM_MAX_HEAP_PROP_NAME + "=" + heapSize;
            }

            outputLines.add(outputLine);
        }

        return outputLines;
    }

    public static void main(String[] args) {
        if (args.length != 1) {
            System.err.println("USAGE: set-wrapper-heap-size WRAPPER_CONF");
            System.err.println("EXAMPLE: set-wrapper-heap-size /path/to/dist/etc/worker.wrapper.conf");
            System.exit(-1);
        }

        File wrapperConf = new File(args[0]);

        WrapperHeapSizeSetter setter = new WrapperHeapSizeSetter();
        setter.setWrapperHeapSize(wrapperConf);

        System.out.println("Complete.");
        System.exit(0);
    }
}
