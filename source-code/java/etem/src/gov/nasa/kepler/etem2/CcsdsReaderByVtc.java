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

import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;

class CcsdsReaderByVtc extends AbstractCcsdsReader {
    private File[] ccsdsFiles;
    private double[] firstVtcPerFile;
    private Pair<Double, Double>[] startEndTimes;
    private double secsPerShortCadence;
    private int shortCadencesPerLongCadence;
    private int currentTimeSpanIndex = 0;
    private int lastTimeSpanIndex = 0;
    private double startVtc = 0;
    private double endVtc = 0;
    /*
     * private PacketType startType; private PacketType endType; private int
     * numCadences = 0;
     */

    private int ccsdsFileNum = 0;
    private int pktCountInCurrentTimespan = 0;

    public CcsdsReaderByVtc(String[] inputCcsdsFilenames,
        double secsPerShortCadence, int shortCadencesPerLongCadence,
        Pair<Double, Double>[] startEndTimes) throws Exception {
        String err = "";
        if (inputCcsdsFilenames.length == 0) {
            err += "Empty array of input ccsds data files.";
        }
        ccsdsFiles = new File[inputCcsdsFilenames.length];
        for (int i = 0; i < inputCcsdsFilenames.length; i++) {
            VcduPacker.log.info("inputCcsdsFilename=" + inputCcsdsFilenames[i]);
            ccsdsFiles[i] = new File(inputCcsdsFilenames[i]);
            if (!ccsdsFiles[i].exists()) {
                err += "Missing file: " + inputCcsdsFilenames[i] + "\n";
            }
        }
        if (err.length() > 0) {
            throw new Exception(err);
        }

        this.startEndTimes = startEndTimes;
        for (int i = 0; i < startEndTimes.length; i++) {
            VcduPacker.log.info("start VTC #" + i + " = "
                + startEndTimes[i].left + ", end VTC #" + i + " = "
                + startEndTimes[i].right);
        }

        this.secsPerShortCadence = secsPerShortCadence;
        this.shortCadencesPerLongCadence = shortCadencesPerLongCadence;
        this.startEndTimes = startEndTimes;

        currentTimeSpanIndex = 0;
        lastTimeSpanIndex = startEndTimes.length - 1;
        setCurrentStartEndTimes();
        /*
         * this.startType = startType; this.endType = endType; this.startVtc =
         * startVtc; this.endVtc = endVtc; this.numCadences = numCadences;
         */

        firstVtcPerFile = new double[ccsdsFiles.length];

        readingToEnd = (startEndTimes[lastTimeSpanIndex].right == VcduPacker.ANY_TIME);
        // readingToEnd = ( endType.isAny() && endVtc == ANY_TIME );
        VcduPacker.log.info("readingToEnd=" + readingToEnd);
        ccsdsFileNum = -1; // prep for reading first file
        nextFile();
        findStart();
        VcduPacker.log.info("After findStart");
    }

    private boolean findStart() throws Exception {
        VcduPacker.log.info("Looking for starting packet");
        boolean foundStart = false;
        while (!foundStart) {
            readPacket();
            if (hitEnd) {
                return false;
            }

            if (pktCount % 10000 == 0) {
                VcduPacker.log.info("checking packet #" + pktCount + ": vtc="
                    + pktVtc + " (" + VtcFormat.toDateString(pktVtc) + ")");
            }
            /*
             * if ( ccsdsFileNum > 0 ) { throw new Exception("start time " +
             * startVtc + " with start type " + startType + " not found in first
             * input file " + ccsdsFiles[0].getAbsolutePath() ); }
             */
            foundStart = (pktVtc >= startVtc);
            if (foundStart) {
                VcduPacker.log.info("found packet #" + pktCount + " with vtc="
                    + pktVtc + " (" + VtcFormat.toDateString(pktVtc) + ")");
            }
            /*
             * boolean startVtcMatches = ( startVtc == ANY_TIME || startVtc ==
             * pktVtc ); foundStart = ( startType.equals( pktType ) &&
             * startVtcMatches );
             */
        }
        repositioned = true;
        return foundStart;
    }

    protected void nextFile() throws Exception {
        pktCount = 0;
        ccsdsFileNum++;
        if (ccsdsFileNum >= ccsdsFiles.length) {
            VcduPacker.log.info("Processed all " + ccsdsFiles.length
                + " CCSDS files.");
            if (readingToEnd) {
                VcduPacker.log.info("Reached end of CCSDS input, end time unspecified.");
                hitEnd = true;
                if (currentTimeSpanIndex == lastTimeSpanIndex) {
                    VcduPacker.log.info("Done processing input files for all specified time spans.");
                    doneProcessing = true;
                }
                return;
            } else {
                /*
                 * throw new Exception("Ran out of input cadences before seeing
                 * end type " + endType.getName() + " with endVtc " + endVtc );
                 */
                throw new Exception("Ran out of input before seeing endVtc # "
                    + currentTimeSpanIndex + " = " + endVtc + " ("
                    + VtcFormat.toDateString(endVtc) + ")");
            }
        } else {
            VcduPacker.log.info("Begin reading CCSDS file #" + ccsdsFileNum
                + ": " + ccsdsFiles[ccsdsFileNum].getAbsolutePath());
            ccsdsInput = new DataInputStream(new BufferedInputStream(
                new FileInputStream(ccsdsFiles[ccsdsFileNum])));
        }
    }

    protected void readHeader() throws Exception {
        super.readHeader();
        if (hitEnd) {
            return;
        }

        if (!readingToEnd && pktVtc >= endVtc) {
            VcduPacker.log.info("Found endVtc #" + currentTimeSpanIndex
                + " (end Vtc=" + VtcFormat.toDateString(endVtc) + ") "
                + " at packet #" + pktCount + " (pkt vtc="
                + VtcFormat.toDateString(pktVtc) + ")");
            VcduPacker.log.debug("currentTimeSpanIndex=" + currentTimeSpanIndex);
            VcduPacker.log.debug("lastTimeSpanIndex=" + lastTimeSpanIndex);
            if (pktCountInCurrentTimespan == 0) {
                throw new Exception(
                    "ERROR: zero packets processed for timespan #"
                        + currentTimeSpanIndex + " (start="
                        + VtcFormat.toDateString(startVtc) + ", endVtc="
                        + VtcFormat.toDateString(endVtc)
                        + ").  End time was before first packet timestamp.");
            }
            if (currentTimeSpanIndex == lastTimeSpanIndex) {
                // TODO
                VcduPacker.log.info("done processing (do we ever get here?");
                doneProcessing = true;
                hitEnd = true;
                return;
            } else {
                double prevEndVtc = endVtc;
                pktCountInCurrentTimespan = 0;
                currentTimeSpanIndex++;
                setCurrentStartEndTimes();
                if (startVtc == VcduPacker.ANY_TIME) {
                    VcduPacker.log.info("New start time is ANY, so rewinding to first input file.");
                    ccsdsFileNum = -1;
                    nextFile();
                } else if (startVtc < prevEndVtc) {
                    VcduPacker.log.info("New start time " + startVtc
                        + " precedes previous end time " + prevEndVtc
                        + ".  Rewinding input stream.");
                    for (; ccsdsFileNum >= 0; ccsdsFileNum--) {
                        VcduPacker.log.info("First packet in file #"
                            + ccsdsFileNum + " has VTC="
                            + firstVtcPerFile[ccsdsFileNum]);
                        if (firstVtcPerFile[ccsdsFileNum] <= startVtc) {
                            break;
                        }
                    }
                    if (ccsdsFileNum < 0) {
                        throw new Exception(
                            "Backed up past first file, desired start time not found.");
                    }
                    ccsdsFileNum--;
                    nextFile();
                }
                findStart();
            }
        }

        // bump pktCount
        pktCountInCurrentTimespan++;
        if (pktCount % 10000 == 0) {
            VcduPacker.log.info("reading packet #" + pktCount + ", pktVtc="
                + pktVtc + ", pktAppId=" + pktAppId);
        }
    }

    private void setCurrentStartEndTimes() {
        startVtc = startEndTimes[currentTimeSpanIndex].left;
        endVtc = startEndTimes[currentTimeSpanIndex].right;
        VcduPacker.log.info("Processing timespan #" + currentTimeSpanIndex
            + ", startVtc=" + startVtc + " ("
            + VtcFormat.toDateString(startVtc) + ")" + ", endVtc=" + endVtc
            + " (" + VtcFormat.toDateString(endVtc) + ")");

        // The CCSDS packets we are processing were generated by DataSetPacker,
        // which performs this adjustment to its start time parameter.
        // We must do the same so our start/end times match.
        VcduPacker.log.info("Adding length of long cadence to start and end times.");
        // TODO FIX!! Why are CCSDS pkt timestamps 16 seconds ahead of the same
        // time passed to VcduPacker?
        startVtc += secsPerShortCadence * shortCadencesPerLongCadence - 16;
        endVtc += secsPerShortCadence * shortCadencesPerLongCadence - 16;
        VcduPacker.log.info("Adjusted timespan #" + currentTimeSpanIndex
            + ", startVtc=" + startVtc + " ("
            + VtcFormat.toDateString(startVtc) + ")" + ", endVtc=" + endVtc
            + " (" + VtcFormat.toDateString(endVtc) + ")");
    }
}