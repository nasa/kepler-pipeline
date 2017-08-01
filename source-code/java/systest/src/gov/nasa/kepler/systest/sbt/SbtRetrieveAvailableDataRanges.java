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

package gov.nasa.kepler.systest.sbt;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

public class SbtRetrieveAvailableDataRanges extends AbstractSbt {
    private static final String SDF_FILE_NAME = "/tmp/sbt-available-data-ranges.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = false;
    public static final double START_MJD = 54000.0;
    public static final double END_MJD = 64000.0;

    public static class DataRange implements Comparable<DataRange> {
        int tableId;
        String cadenceType;
        int startCadence;
        int endCadence;
        double startMjd;
        double endMjd;

        public DataRange() {
            ;
        }

        public DataRange(int targetTableId, String cadenceType,
            int startCadence, double startMjd) {
            this.tableId = targetTableId;
            this.cadenceType = cadenceType;
            this.startCadence = startCadence;
            this.endCadence = startCadence;
            this.startMjd = startMjd;
            this.endMjd = startMjd;
        }

        public void updateStart(PixelLog pixelLog) {
            this.startMjd = pixelLog.getMjdStartTime();
            this.startCadence = pixelLog.getCadenceNumber();
        }

        public void updateEnd(PixelLog pixelLog) {
            this.endMjd = pixelLog.getMjdEndTime();
            this.endCadence = pixelLog.getCadenceNumber();
        }

        @Override
        public String toString() {
            return "DataRange [targetTableId=" + tableId + " cadenceType="
                + cadenceType + ", startCadence=" + startCadence
                + ", endCadence=" + endCadence + ", startMjd=" + startMjd
                + ", endMjd=" + endMjd + "]";
        }

        @Override
        public int compareTo(DataRange other) {
            return this.tableId - other.tableId;
        }
    }

    public static class AvailableDataRanges implements Persistable {
        public List<DataRange> dataRanges = new LinkedList<DataRange>();

        public String toString() {
            String out = "";
            for (DataRange dataRange : dataRanges) {
                out += dataRange.toString() + "\n";
            }
            return out;
        }
    }

    public SbtRetrieveAvailableDataRanges() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    private static int getCadenceType(boolean isShortCadence) {
        return isShortCadence ? Cadence.CADENCE_SHORT : Cadence.CADENCE_LONG;
    }

    /**
     * Retrieve the available data ranges for the entire mission.
     * 
     * @param isShortCadence
     * @return
     * @throws Exception
     */
    public String retrieveAvailableDataRanges(boolean isShortCadence)
        throws Exception {
        return retrieveAvailableDataRanges(START_MJD, END_MJD, isShortCadence);
    }

    /**
     * Retrieve the available data ranges between the cadence arguments.
     * 
     * @param startMjd
     * @param endMjd
     * @param isShortCadence
     * @return
     * @throws Exception
     */
    public String retrieveAvailableDataRanges(int startCadence, int endCadence,
        boolean isShortCadence) throws Exception {
        if (! validateDatastores()) {
            return "";
        }
        
        int cadenceType = getCadenceType(isShortCadence);
        MjdToCadence mjdToCadence = new MjdToCadence(
            CadenceType.valueOf(cadenceType),
            new ModelMetadataRetrieverLatest());
        double startMjd = mjdToCadence.cadenceToMjd(startCadence);
        double endMjd = mjdToCadence.cadenceToMjd(endCadence);

        return retrieveAvailableDataRanges(startMjd, endMjd, isShortCadence);
    }

    /**
     * Retrieve the available data ranges between the MJD arguments.
     * 
     * @param startMjd
     * @param endMjd
     * @param isShortCadence
     * @return
     * @throws Exception
     */
    public String retrieveAvailableDataRanges(double startMjd, double endMjd,
        boolean isShortCadence) throws Exception {
        int cadenceType = getCadenceType(isShortCadence);

        if (! validateDatastores()) {
            return "";
        }
        
        TicToc.tic("Retrieving available data ranges...");

        LogCrud logCrud = new LogCrud();
        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(cadenceType,
            DataSetType.Target, startMjd, endMjd);

        // Get the DataRangedbquit from the pixelLogs and pack the results into
        // a sorted (by TargetTableId) list to persist:
        //
        AvailableDataRanges availableDataRanges = new AvailableDataRanges();
        availableDataRanges.dataRanges = getDataRanges(pixelLogs,
            isShortCadence);

        System.out.println("...DONE Retrieving available data ranges (found "
            + availableDataRanges.dataRanges.size() + ").");

        return makeSdf(availableDataRanges, SDF_FILE_NAME);
    }

    /**
     * Get a list of the DataRanges from the given list of pixelLogs. The output
     * DataRanges will have the earliest start time and the latest end time of
     * any pixel log with that targetTableId
     * 
     * @param pixelLogs
     * @param isShortCadence
     * @return
     */
    private List<DataRange> getDataRanges(List<PixelLog> pixelLogs,
        boolean isShortCadence) {
        String cadenceTypeName = isShortCadence ? "SHORT" : "LONG";

        // Build up a map of unique targetTableIds to inclusive data ranges:
        Map<Integer, DataRange> idToRange = new HashMap<Integer, DataRange>();
        for (PixelLog pixelLog : pixelLogs) {
            int cadenceNumber = pixelLog.getCadenceNumber();

            // If this is a previously unseen targetTableId, add it t and a
            // corresponding DataRange object:
            //
            Integer targetTableId = (int) (isShortCadence ? pixelLog.getScTargetTableId()
                : pixelLog.getLcTargetTableId());
            boolean isNewTargetTable = !idToRange.containsKey(targetTableId);
            if (isNewTargetTable) {
                DataRange dataRange = new DataRange(targetTableId,
                    cadenceTypeName, cadenceNumber, pixelLog.getMjdStartTime());
                idToRange.put(targetTableId, dataRange);
            }

            // Update the entry for the current targetTableId with an earlier
            // start time
            // or a later end time, if pixelLog has such:
            //
            DataRange dataRange = idToRange.get(targetTableId);
            boolean isCurrentBetterStart = pixelLog.getMjdStartTime() < dataRange.startMjd;
            boolean isCurrentBetterEnd = pixelLog.getMjdEndTime() > dataRange.endMjd;
            if (isCurrentBetterStart) {
                dataRange.updateStart(pixelLog);
                idToRange.put(targetTableId, dataRange);
            }
            if (isCurrentBetterEnd) {
                dataRange.updateEnd(pixelLog);
                idToRange.put(targetTableId, dataRange);
            }
        }

        // Return just the (sorted) values from the map:
        //
        List<DataRange> dataRanges = new ArrayList<DataRange>(
            idToRange.values());
        Collections.sort(dataRanges);
        return dataRanges;
    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        SbtRetrieveAvailableDataRanges sbt = new SbtRetrieveAvailableDataRanges();
        sbt.retrieveAvailableDataRanges(false);
        sbt.retrieveAvailableDataRanges(55004.0, 55070.0, false);
        sbt.retrieveAvailableDataRanges(12000, 13000, false);

        sbt.retrieveAvailableDataRanges(true);

    }

}
