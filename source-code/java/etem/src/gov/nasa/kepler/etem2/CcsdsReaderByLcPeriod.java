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

package gov.nasa.kepler.etem2;

import static gov.nasa.kepler.etem2.DataSetPacker.LC_APP_ID;
import static gov.nasa.kepler.etem2.DataSetPacker.SC_APP_ID;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.util.List;

public class CcsdsReaderByLcPeriod extends AbstractCcsdsReader {

    private static final int NO_PREV_PKT_APP_ID = 0;
    private List<VcduPackerInputDatasetSpec> specs;
    private VcduPackerInputDatasetSpec spec;
    private int currentSpec = 0;
    private int periodCount = 0;
    private int prevPktAppId;

    public CcsdsReaderByLcPeriod(String datasetRootDir, String specString)
        throws Exception {
        specs = VcduPackerInputDatasetSpec.parse(datasetRootDir, specString);
        currentSpec = -1;
        nextFile();
    }

    protected void nextFile() throws Exception {
        if (currentSpec >= 0) {
            if (!readingToEnd) {
                periodCount++;
                if (periodCount <= spec.getEndLongCadencePeriod()) {
                    throw new Exception("(found " + periodCount 
                        + " periods, could not fulfill spec: " + spec);
                }
            }
        }
        
        currentSpec++;
        if (currentSpec >= specs.size()) {
            hitEnd = true;
            doneProcessing = true;
        } else {
            spec = specs.get(currentSpec);
            VcduPacker.log.info("Current spec: " + spec);
            String fileName = spec.getCcsdsFilename();
            VcduPacker.log.info("Opening input file: " + fileName);
            if ( ccsdsInput != null ) {
                ccsdsInput.close(); 
            }
            ccsdsInput = new DataInputStream(new BufferedInputStream(
                new FileInputStream(fileName)));
            readingToEnd = (spec.getEndLongCadencePeriod() == VcduPackerInputDatasetSpec.LAST);
        prevPktAppId = NO_PREV_PKT_APP_ID;
        periodCount = 0;
        findStart();
        }
    }

    protected boolean findStart() throws Exception {
        // readHeaders, counting to startLongCadencePeriod transitions from LC
        // to SC
        VcduPacker.log.info("Looking for starting packet");
        boolean foundStart = false;
        while (!foundStart) {
            readPacket();
            pktOffset = 0;
            if (hitEnd) {
                VcduPacker.log.info("failed to find start for spec: " + spec);
                return false;
            }

            if (pktCount % 1000 == 0) {
                VcduPacker.log.info("checking packet #" + pktCount 
                    + ": vtc=" + pktVtc 
                    + " (" + VtcFormat.toDateString(pktVtc) + ")"
                    + " (period #" + periodCount + ")");
            }
            foundStart = (periodCount == spec.getStartLongCadencePeriod());
            if (foundStart) {
                VcduPacker.log.info("found packet #" + pktCount 
                    + " with vtc=" + pktVtc 
                    + " (" + VtcFormat.toDateString(pktVtc) + ")"
                    + " (period #" + periodCount + ")");
            }
        }
        if (!foundStart) {
            throw new Exception("(transitionNum=" + periodCount + ") "
                + "not found: start period value too large in spec:" + spec);
        }
        repositioned = true;
        return foundStart;
    }

    protected void readHeader() throws Exception {
        super.readHeader();
        if (hitEnd) {
            return;
        }
        
        // a transition from LC packets to SC packets 
        // marks the end of an LC period
        if (prevPktAppId == LC_APP_ID && pktAppId == SC_APP_ID) {
            periodCount++;
            System.err.println("periodCount="+periodCount+", pktCount="+pktCount);
            if (!readingToEnd
                && periodCount > spec.getEndLongCadencePeriod()) {
                nextFile();
            }
        }
        prevPktAppId = pktAppId;
    }

}
