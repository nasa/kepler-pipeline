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

package gov.nasa.kepler.dynablack;

import java.io.*;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.spiffy.common.os.ProcessUtils;
import gov.nasa.spiffy.common.os.ProcessUtils.ProcessOutput;

public class FindFailedDynablackBlobs {


    private static final String DYNABLACK_BLOB_VALID_OUT = "dynablack-blob-valid.out";

    private static final class DynablackBlobInterval implements Comparable<DynablackBlobInterval> {
        public final int startCadence;
        public final int endCadence;
        public final int ccdModule;
        public final int ccdOutput;
        public final int valid;
        public DynablackBlobInterval(int startCadence, int endCadence,
            int ccdModule, int ccdOutput, int valid) {
            super();
            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.ccdModule = ccdModule;
            this.ccdOutput = ccdOutput;
            this.valid = valid;
        }
        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ccdModule;
            result = prime * result + ccdOutput;
            result = prime * result + endCadence;
            result = prime * result + startCadence;
            return result;
        }
        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            DynablackBlobInterval other = (DynablackBlobInterval) obj;
            if (ccdModule != other.ccdModule)
                return false;
            if (ccdOutput != other.ccdOutput)
                return false;
            if (endCadence != other.endCadence)
                return false;
            if (startCadence != other.startCadence)
                return false;
            return true;
        }
        @Override
        public String toString() {
            StringBuilder bldr = new StringBuilder();
            bldr.append(startCadence).append(' ').append(endCadence).append(' ').append(ccdModule).append(' ').append(ccdOutput).append(' ').append(valid);
            return bldr.toString();
        }
        
        @Override
        public int compareTo(DynablackBlobInterval o) {
            int diff = this.startCadence - o.endCadence;
            if (diff != 0) {
                return diff;
            }
            diff = this.endCadence - o.endCadence;
            if (diff != 0) {
                return diff;
            }
            diff = this.ccdModule - o.ccdModule;
            if (diff != 0) {
                return diff;
            }
            diff = this.ccdOutput - o.ccdOutput;
            if (diff != 0) {
                return diff;
            }
            return 0;
        }
        
        
    }
    
    
    public static void main(String[] argv) throws Exception {
        
        File dynFile = new File(DYNABLACK_BLOB_VALID_OUT);
        SortedSet<DynablackBlobInterval> blobsSeen = new TreeSet<DynablackBlobInterval>();
        
        if (dynFile.exists()) {
            parseExistingFile(dynFile, blobsSeen);
        }
        BufferedWriter bout = new BufferedWriter(new FileWriter(dynFile));
        for (DynablackBlobInterval oldInterval : blobsSeen) {
            bout.append(oldInterval.toString()).append('\n');
        }
        BlobOperations blobOps = new BlobOperations(new File("."));
        TargetCrud targetCrud  = new TargetCrud();
        List<TargetTableLog>  ttableLogs = targetCrud.retrieveTargetTableLogs(TargetType.LONG_CADENCE, 2977, 70914);
        for (TargetTableLog ttableLog : ttableLogs) {
            int startCadence = ttableLog.getCadenceStart();
            int endCadence = ttableLog.getCadenceEnd();
            for (int ccdModule : FcConstants.modulesList) {
                for (int ccdOutput : FcConstants.outputsList) {
                    
                    
                    DynablackBlobInterval blobInterval = 
                        new DynablackBlobInterval(startCadence , endCadence, ccdModule, ccdOutput, -1);
                    if (blobsSeen.contains(blobInterval)) {
                        System.out.println("Skipping blob " + blobInterval);
                        continue;
                    }
                    BlobSeries<String> blobSeries = 
                        blobOps.retrieveDynamicTwoDBlackBlobFileSeries(ccdModule, ccdOutput, ttableLog.getCadenceStart(), ttableLog.getCadenceEnd());
             
                    //ProcessUtils.grabOutput("matlab -")
                    for (Object fname : blobSeries.blobFilenames()) {
                        Process matlabProcess = null;
                        try {
                            ProcessBuilder processBuilder = 
                                new ProcessBuilder("matlab", "-nodisplay", "-r", "load " + fname + "; fprintf('valid: %d\\n',  inputStruct.validDynablackFit); exit;");
                            matlabProcess = processBuilder.start();
                            ProcessOutput processOutput = ProcessUtils.grabOutput(matlabProcess, "Achtung MATLAB! " + fname);
                            Pattern validRegex = Pattern.compile("valid: (\\d)");
                            Matcher m = validRegex.matcher(processOutput.output());
                            Integer isValid = null;
                            if (m.find()) {
                                isValid = Integer.parseInt(m.group(1));
                            } else {
                                throw new IllegalStateException("Bad process output." + processOutput.all());
                            }
                            blobInterval = new DynablackBlobInterval(startCadence, endCadence, ccdModule, ccdOutput, isValid);
                            bout.append(blobInterval.toString()).append("\n");
                            bout.flush();
                            File f = new File(fname.toString());
                            f.delete();
                        } finally {
                            ProcessUtils.closeProcess(matlabProcess);
                        }
                    }
                }
            }
            
        }
        bout.close();
    }


    private static void parseExistingFile(File dynFile,
        Set<DynablackBlobInterval> blobsSeen) throws FileNotFoundException,
        IOException {
        BufferedReader breader = new BufferedReader(new FileReader(dynFile));
        for (String line = breader.readLine(); line != null; line = breader.readLine()) {
            String[] parts = line.split(" ");
            DynablackBlobInterval blobInterval = 
                new DynablackBlobInterval(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]),
                    Integer.parseInt(parts[2]), Integer.parseInt(parts[3]),
                   Integer.parseInt(parts[4]));
            blobsSeen.add(blobInterval);
        }
        breader.close();
    }

}
