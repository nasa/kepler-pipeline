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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.common.persistable.SdfPersistableOutputStream;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.kepler.mc.CalibratedPixel;
import gov.nasa.kepler.mc.CalibratedPixelOperations;
import gov.nasa.kepler.mc.CollateralTimeSeriesOperations;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SbtRetrievePixelTimeSeries {

    private static final String SDF_FILE_NAME = "sbt-retrieve-pixel-time-series.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public static class SbtPixelTimeSeries {
        List<ChannelData> channelData;

        public SbtPixelTimeSeries() {
            channelData = new ArrayList<ChannelData>();
        }

        public SbtPixelTimeSeries(List<ChannelData> channelData) {
            this.channelData = channelData;
        }
    }

    /**
     * This class contains all the data for one mod/out
     * 
     */
    public static class ChannelData {
        public int module;
        public int output;
        public double[] mjdArray;
        public boolean isLongCadence;
        public boolean isOriginalData;

        public List<KeplerIdTimeSeriesStruct> keplerIdTimeSeriesStruct;
        public List<CalibratedPixelData> calibratedBackgroundPixelData;
        public List<UncalibratedPixelData> uncalibratedBackgroundPixelData;
        public List<CollateralPixelData> collateralData;

        public ChannelData(int ccdModule, int ccdOutput, double[] mjds,
            boolean isLongCadence, boolean isCalibrated,
            List<TargetData> dataForTargets,
            List<CollateralPixelData> collateralPixelData,
            List<CalibratedPixelData> calibratedBackgroundPixelData,
            List<UncalibratedPixelData> uncalibratedBackgroundPixelData) {

            module = ccdModule;
            output = ccdOutput;
            mjdArray = mjds;
            this.isLongCadence = isLongCadence;
            isOriginalData = !isCalibrated;
            // this.targetData = dataForTargets;
            collateralData = collateralPixelData;
            this.calibratedBackgroundPixelData = calibratedBackgroundPixelData;
            this.uncalibratedBackgroundPixelData = uncalibratedBackgroundPixelData;

            keplerIdTimeSeriesStruct = new ArrayList<KeplerIdTimeSeriesStruct>();
            for (TargetData dataForTarget : dataForTargets) {
                keplerIdTimeSeriesStruct.add(new KeplerIdTimeSeriesStruct(
                    dataForTarget, isCalibrated));
            }
        }
    }

    /**
     * This class is used to repackage TargetData objects into the data
     * structure that the matlab user expects
     * 
     */
    public static class KeplerIdTimeSeriesStruct {
        public int keplerId;
        public int[] row = new int[0];
        public int[] column = new int[0];
        public boolean[] isInOptimalAperture = new boolean[0];
        public float[][] timeSeries = new float[0][];
        public float[][] uncertainties = new float[0][];
        public int[][] timeSeriesUncalibrated = new int[0][];
        public boolean[][] gapIndicators = new boolean[0][];

        public KeplerIdTimeSeriesStruct(TargetData targetData,
            boolean isCalibrated) {
            keplerId = targetData.keplerId;

            if (isCalibrated) {
                row = new int[targetData.calibratedPixelData.size()];
                column = new int[row.length];
                isInOptimalAperture = new boolean[row.length];

                timeSeries = new float[row.length][];
                uncertainties = new float[row.length][];
                gapIndicators = new boolean[row.length][];

                int numPixels = targetData.calibratedPixelData.size();
                for (int ipix = 0; ipix < numPixels; ++ipix) {
                    CalibratedPixelData pixel = targetData.calibratedPixelData.get(ipix);
                    row[ipix] = pixel.row;
                    column[ipix] = pixel.column;
                    isInOptimalAperture[ipix] = pixel.isInOptimalAperture;

                    int numCadences = pixel.timeSeries.length;
                    timeSeries[ipix] = new float[numCadences];

                    timeSeries[ipix] = pixel.timeSeries;
                    uncertainties[ipix] = pixel.uncertainties;
                    gapIndicators[ipix] = pixel.gapIndicators;
                }
            } else {
                row = new int[targetData.uncalibratedPixelData.size()];
                column = new int[row.length];
                isInOptimalAperture = new boolean[row.length];

                timeSeriesUncalibrated = new int[row.length][];
                gapIndicators = new boolean[row.length][];

                int numPixels = targetData.uncalibratedPixelData.size();
                for (int ipix = 0; ipix < numPixels; ++ipix) {
                    UncalibratedPixelData pixel = targetData.uncalibratedPixelData.get(ipix);
                    row[ipix] = pixel.row;
                    column[ipix] = pixel.column;
                    isInOptimalAperture[ipix] = pixel.isInOptimalAperture;

                    int numCadences = pixel.timeSeries.length;
                    timeSeriesUncalibrated[ipix] = new int[numCadences];

                    timeSeriesUncalibrated[ipix] = pixel.timeSeries;
                    gapIndicators[ipix] = pixel.gapIndicators;
                }
            }

        }
    }

    /**
     * Container for one target's data.
     * 
     */
    public static class TargetData {
        public int keplerId;
        public List<CalibratedPixelData> calibratedPixelData;
        public List<UncalibratedPixelData> uncalibratedPixelData;

        public TargetData(int keplerId, List<CalibratedPixelData> calPixelData,
            List<UncalibratedPixelData> uncalPixelData) {
            this.keplerId = keplerId;
            calibratedPixelData = calPixelData;
            uncalibratedPixelData = uncalPixelData;
        }
    }

    /**
     * Data for one pixel (calibrated).
     * 
     */
    public static class CalibratedPixelData {
        public int row;
        public int column;
        public boolean isInOptimalAperture;
        public float[] timeSeries;
        public float[] uncertainties;
        public boolean[] gapIndicators;

        public CalibratedPixelData(int row, int column,
            boolean isInOptimalAperture, FloatTimeSeries data,
            FloatTimeSeries uncert) {
            this.row = row;
            this.column = column;
            this.isInOptimalAperture = isInOptimalAperture;
            timeSeries = data.fseries();
            uncertainties = uncert.fseries();
            gapIndicators = data.getGapIndicators();
        }
    }

    /**
     * Data for one pixel (calibrated).
     * 
     */
    public static class UncalibratedPixelData {
        public int row;
        public int column;
        public int[] timeSeries;
        public boolean[] gapIndicators;
        public boolean isInOptimalAperture;

        public UncalibratedPixelData(int row, int column,
            boolean isInOptimalAperture, IntTimeSeries data) {
            this.row = row;
            this.column = column;
            this.isInOptimalAperture = isInOptimalAperture;
            timeSeries = data.iseries();
            gapIndicators = data.getGapIndicators();
        }
    }

    /**
     * Data for one pixel in the collateral data regions. These pixels only have
     * one coordinate, not a (row, column) pair.
     * 
     */
    public static class CollateralPixelData {
        public int coordinate;
        public String type;
        public int[] timeSeries;
        public boolean[] gapIndicators;

        public CollateralPixelData(int coordinate, String type, int[] data,
            boolean[] gapIndicators) {

            this.coordinate = coordinate;
            this.type = type;
            timeSeries = data;
            this.gapIndicators = gapIndicators;
        }
    }

    public static String retrievePixelTimeSeries(int[] ccdModules,
        int[] ccdOutputs, double startMjd, double endMjd,
        boolean isLongCadence, boolean isCalibrated) throws Exception {

        if (!new AbstractSbt(REQUIRES_DATABASE, REQUIRES_FILESTORE).validateDatastores()) {
            return "";
        }

        if (ccdModules.length != ccdOutputs.length) {
            throw new Exception(
                "ccdModules and ccdOutputs must be the same length");
        }

        System.out.println("Retrieving pixel time series...");
        SbtPixelTimeSeries sbtPixelTimeSeries = new SbtPixelTimeSeries();
        for (int ii = 0; ii < ccdModules.length; ++ii) {
            ChannelData channelData = getChannelData(ccdModules[ii],
                ccdOutputs[ii], startMjd, endMjd, isLongCadence, isCalibrated);
            sbtPixelTimeSeries.channelData.add(channelData);
        }
        System.out.println("Done retrieving pixel time series.");

        TicToc.tic("Generating .sdf file");
        File sdfFile = new File("/tmp", SDF_FILE_NAME);
        FileOutputStream fos = new FileOutputStream(sdfFile);
        BufferedOutputStream bos = new BufferedOutputStream(fos);
        DataOutputStream dos = new DataOutputStream(bos);
        SdfPersistableOutputStream spos = new SdfPersistableOutputStream(dos);
        System.out.println("saving to: " + sdfFile);
        spos.save(sbtPixelTimeSeries);
        dos.close();
        TicToc.toc();

        return sdfFile.getCanonicalPath();
    }

    private static ChannelData getChannelData(int ccdModule, int ccdOutput,
        double startMjd, double endMjd, boolean isLongCadence,
        boolean isCalibrated) throws Exception {

        TargetType targetType;
        CadenceType cadenceType;
        TargetCrud targetCrud = new TargetCrud();

        if (isLongCadence) {
            targetType = TargetTable.TargetType.LONG_CADENCE;
            cadenceType = CadenceType.LONG;
        } else {
            targetType = TargetTable.TargetType.SHORT_CADENCE;
            cadenceType = CadenceType.SHORT;
        }

        TicToc.tic("Retrieving cadence range");
        Pair<Integer, Integer> cadenceRange = getCadenceRange(cadenceType,
            startMjd, endMjd);
        int startCadence = cadenceRange.left;
        int endCadence = cadenceRange.right;
        TicToc.toc();

        TicToc.tic("Retrieving target table logs for module " + ccdModule
            + " output " + ccdOutput);
        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            targetType, startCadence, endCadence);
        TicToc.toc();
        if (targetTableLogs.size() > 1) {
            throw new Exception("too many targetTableLogs");
        }
        TargetTableLog targetTableLog = targetTableLogs.get(0);

        // Verify time ranges fall within the target table log's:
        //
        int ttlStartCadence = targetTableLog.getCadenceStart();
        int ttlEndCadence = targetTableLog.getCadenceEnd();
        if (ttlStartCadence > startCadence) {
            System.err.println("target table log start cadence "
                + ttlStartCadence
                + " is greater than the requested start cadence "
                + startCadence
                + ". Data from cadences smaller than ttlStartCadence will not be returned");
        }
        if (ttlEndCadence < endCadence) {
            System.err.println("target table log end cadence "
                + ttlEndCadence
                + "is less than the requested end cadence "
                + endCadence
                + ". Data from cadences larger than ttlEndCadence will not be returned");
        }
        TargetTable targetTable = targetTableLog.getTargetTable();

        TicToc.tic("Retrieving observed targets");
        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, ccdModule, ccdOutput);
        TicToc.toc();

        // Map the observed targets to the FsIds they contain:
        //
        Map<ObservedTarget, List<Pair<FsId, FsId>>> targetToFsIds = new HashMap<ObservedTarget, List<Pair<FsId, FsId>>>();
        for (ObservedTarget observedTarget : observedTargets) {
            List<Pair<FsId, FsId>> targetFsIds = getSingleTargetsFsIds(
                observedTarget, targetType, ccdModule, ccdOutput, startCadence,
                endCadence, isCalibrated);
            targetToFsIds.put(observedTarget, targetFsIds);
        }

        TicToc.tic("Processing targets");
        List<TargetData> allTargets = extractTargetDataForAllFsIds(
            targetToFsIds, startCadence, endCadence, isCalibrated);
        TicToc.toc();

        TicToc.tic("Retrieving collateral data");
        List<CollateralPixelData> collateralData = getCollateralData(
            targetTable, cadenceType, isLongCadence, ccdModule, ccdOutput,
            startCadence, endCadence);
        TicToc.toc();

        double[] mjds = getMjdsBetween(cadenceType, startMjd, endMjd);
        List<CalibratedPixelData> calibratedBackgroundData = new ArrayList<CalibratedPixelData>();
        List<UncalibratedPixelData> uncalibratedBackgroundData = new ArrayList<UncalibratedPixelData>();

        if (isCalibrated) {
            calibratedBackgroundData = getBackgroundCalibratedData(targetTable,
                ccdModule, ccdOutput, startCadence, endCadence);
        } else {
            uncalibratedBackgroundData = getBackgroundUncalibratedData(
                targetTable, ccdModule, ccdOutput, startCadence, endCadence);
        }
        ChannelData singleChannelTimeSeries = new ChannelData(ccdModule,
            ccdOutput, mjds, isLongCadence, isCalibrated, allTargets,
            collateralData, calibratedBackgroundData,
            uncalibratedBackgroundData);

        return singleChannelTimeSeries;
    }

    private static List<CalibratedPixelData> getBackgroundCalibratedData(
        TargetTable regularTargetTable, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) throws IOException {

        List<CalibratedPixelData> backgroundPixels = new ArrayList<CalibratedPixelData>();

        // Get the FS IDs of the pixels:
        //
        TargetTable backgroundTargetTable = getBackgroundTargetTable(regularTargetTable);
        CalibratedPixelOperations ops = new CalibratedPixelOperations(
            regularTargetTable, backgroundTargetTable, ccdModule, ccdOutput);
        CalibratedPixel[] pixels = ops.getBackgroundPixels()
            .toArray(new CalibratedPixel[0]);

        List<FsId> dataFsIds = new ArrayList<FsId>();
        List<FsId> uncertFsIds = new ArrayList<FsId>();
        for (CalibratedPixel pixel : pixels) {
            dataFsIds.add(pixel.getFsId());
            uncertFsIds.add(pixel.getUncertaintiesFsId());
        }

        FileStoreClient fsclient = FileStoreClientFactory.getInstance();
        FloatTimeSeries[] dataTs = fsclient.readTimeSeriesAsFloat(
            dataFsIds.toArray(new FsId[0]), startCadence, endCadence, false);
        FloatTimeSeries[] uncertTs = fsclient.readTimeSeriesAsFloat(
            uncertFsIds.toArray(new FsId[0]), startCadence, endCadence, false);

        for (int ii = 0; ii < dataTs.length; ++ii) {
            FloatTimeSeries ts = dataTs[ii];
            if (ts.exists()) {
                FloatTimeSeries uts = uncertTs[ii];
                int row = pixels[ii].getRow();
                int column = pixels[ii].getColumn();
                backgroundPixels.add(new CalibratedPixelData(row, column, true,
                    ts, uts));
            }
        }
        fsclient.close();
        return backgroundPixels;
    }

    private static List<UncalibratedPixelData> getBackgroundUncalibratedData(
        TargetTable regularTargetTable, int ccdModule, int ccdOutput,
        int startCadence, int endCadence) throws IOException {

        List<UncalibratedPixelData> backgroundPixels = new ArrayList<UncalibratedPixelData>();

        // Get the FS IDs of the pixels:
        //
        TargetTable backgroundTargetTable = getBackgroundTargetTable(regularTargetTable);
        SciencePixelOperations ops = new SciencePixelOperations(
            regularTargetTable, backgroundTargetTable, ccdModule, ccdOutput);
        Pixel[] pixels = ops.getBackgroundPixels()
            .toArray(new Pixel[0]);

        List<FsId> dataFsIds = new ArrayList<FsId>();
        for (Pixel pixel : pixels) {
            dataFsIds.add(pixel.getFsId());
        }

        FileStoreClient fsclient = FileStoreClientFactory.getInstance();
        IntTimeSeries[] dataTs = fsclient.readTimeSeriesAsInt(
            dataFsIds.toArray(new FsId[0]), startCadence, endCadence, false);
        for (int ii = 0; ii < dataTs.length; ++ii) {
            IntTimeSeries ts = dataTs[ii];
            if (ts.exists()) {
                int row = pixels[ii].getRow();
                int column = pixels[ii].getColumn();
                backgroundPixels.add(new UncalibratedPixelData(row, column,
                    true, ts));
            }
        }
        fsclient.close();
        return backgroundPixels;
    }

    private static TargetTable getBackgroundTargetTable(TargetTable targetTable) {
        TargetCrud targetCrud = new TargetCrud();
        List<TargetTable> targetTables = targetCrud.retrieveBackgroundTargetTable(targetTable);
        TargetTable backgroundTargetTable = targetTables.get(0);
        return backgroundTargetTable;
    }

    private static List<CollateralPixelData> getCollateralData(
        TargetTable targetTable, CadenceType cadenceType,
        boolean isLongCadence, int ccdModule, int ccdOutput, int startCadence,
        int endCadence) {

        CollateralTimeSeriesOperations ops = new CollateralTimeSeriesOperations(
            cadenceType, targetTable.getExternalId(), ccdModule, ccdOutput);
        IntTimeSeries[] collateralTimeSeries = ops.readCollateralTimeSeries(
            startCadence, endCadence);

        List<CollateralPixelData> collateralPixels = new ArrayList<CollateralPixelData>();
        for (int ii = 0; ii < collateralTimeSeries.length; ++ii) {
            IntTimeSeries ts = collateralTimeSeries[ii];
            // The coordinate and the type of the collateral pixel are in the
            // first pipe-delimitted element of the ts.toString. They're the
            // last and third-to-last, respectively, slash- or colon-delimitted
            // elements of that element.
            //
            int coordinate = getCollateralTimeSeriesCoordinate(ts);
            String type = getCollateralTimeSeriesType(ts);

            CollateralPixelData cpd = new CollateralPixelData(coordinate, type,
                ts.iseries(), ts.getGapIndicators());
            collateralPixels.add(cpd);
        }
        return collateralPixels;
    }

    public static String[] getFsIdParts(IntTimeSeries ts) {
        String tsString = ts.toPipeString();
        String[] parts = tsString.split("\\|");
        String fsId = parts[0];
        String[] fsIdParts = fsId.split("/|:");
        return fsIdParts;
    }

    public static int getCollateralTimeSeriesCoordinate(IntTimeSeries ts) {
        String[] fsIdParts = getFsIdParts(ts);
        int coordinate = Integer.parseInt(fsIdParts[fsIdParts.length - 1]);
        return coordinate;
    }

    public static String getCollateralTimeSeriesType(IntTimeSeries ts) {
        String[] fsIdParts = getFsIdParts(ts);
        String type = fsIdParts[fsIdParts.length - 4];
        return type;
    }

    private static double[] getMjdsBetween(CadenceType cadenceType,
        double startMjd, double endMjd) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        LogCrud logCrud = new LogCrud(databaseService);
        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(
            cadenceType.intValue(), startMjd, endMjd);
        Set<Double> mjds = new HashSet<Double>();
        for (PixelLog pixelLog : pixelLogs) {
            mjds.add(pixelLog.getMjdMidTime());
        }

        List<Double> mjdsList = new ArrayList<Double>();
        for (Double mjd : mjds) {
            mjdsList.add(mjd);
        }

        Collections.sort(mjdsList);
        double[] plainMjds = new double[mjdsList.size()];
        for (int ii = 0; ii < mjdsList.size(); ++ii) {
            plainMjds[ii] = mjdsList.get(ii);
        }
        return plainMjds;
    }

    /**
     * Get the cadence numbers that fall between startMjd and endMjd.
     * 
     */
    private static List<Integer> getCadencesBetweenMjds(
        CadenceType cadenceType, double startMjd, double endMjd)
        throws Exception {
        LogCrud logCrud = new LogCrud(DatabaseServiceFactory.getInstance());
        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(
            cadenceType.intValue(), startMjd, endMjd);

        // Get a set of the cadence numbers, to remove any duplicates:
        //
        Set<Integer> cadences = new HashSet<Integer>();
        for (PixelLog pixelLog : pixelLogs) {
            cadences.add(pixelLog.getCadenceNumber());
        }

        // Convert the Set into a sorted list:
        //
        List<Integer> cadencesList = new ArrayList<Integer>();
        for (Integer cadence : cadences) {
            cadencesList.add(cadence);
        }
        Collections.sort(cadencesList);

        return cadencesList;
    }

    private static Pair<Integer, Integer> getCadenceRange(
        CadenceType cadenceType, double startMjd, double endMjd)
        throws Exception {
        List<Integer> cadences = getCadencesBetweenMjds(cadenceType, startMjd,
            endMjd);
        if (cadences.size() < 2) {
            throw new Exception("not enough cadences in MJD range " + startMjd
                + " to " + endMjd + ": only " + cadences.size() + ".");
        }

        return Pair.of(cadences.get(0), cadences.get(cadences.size() - 1));
    }

    private static Set<Pair<Integer, Integer>> getUniquePixels(
        Collection<TargetDefinition> targetDefinitions) {
        // Generate a set of the unique pixels for this target (overlapping
        // pixels
        // are allowed in a set of target definitions, but only one copy of each
        // pixel should be returned.
        //
        Set<Pair<Integer, Integer>> pixels = new HashSet<Pair<Integer, Integer>>();

        for (TargetDefinition targetDefinition : targetDefinitions) {
            int refRow = targetDefinition.getReferenceRow();
            int refCol = targetDefinition.getReferenceColumn();

            for (Offset offset : targetDefinition.getMask()
                .getOffsets()) {
                Pair<Integer, Integer> pixel = Pair.of(
                    offset.getRow() + refRow, offset.getColumn() + refCol);
                pixels.add(pixel);
            }
        }

        return pixels;
    }

    private static List<Pair<FsId, FsId>> getSingleTargetsFsIds(
        ObservedTarget observedTarget, TargetType targetType, int ccdModule,
        int ccdOutput, int startCadence, int endCadence, boolean isCalibrated) {

        List<Pair<FsId, FsId>> fsIds = new ArrayList<Pair<FsId, FsId>>();
        Set<Pair<Integer, Integer>> pixels = getUniquePixels(observedTarget.getTargetDefinitions());
        for (Pair<Integer, Integer> pixel : pixels) {
            int row = pixel.left;
            int column = pixel.right;
            FsId dataFsId;
            FsId uncertFsId = null;
            ;
            if (isCalibrated) {
                dataFsId = CalFsIdFactory.getTimeSeriesFsId(
                    CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, targetType,
                    ccdModule, ccdOutput, row, column);

                uncertFsId = CalFsIdFactory.getTimeSeriesFsId(
                    CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                    targetType, ccdModule, ccdOutput, row, column);
            } else {
                dataFsId = DrFsIdFactory.getSciencePixelTimeSeries(
                    DrFsIdFactory.TimeSeriesType.ORIG, targetType, ccdModule,
                    ccdOutput, row, column);
            }
            fsIds.add(Pair.of(dataFsId, uncertFsId));
        }
        return fsIds;
    }

    private static Integer[] getRows(ObservedTarget observedTarget) {
        List<Integer> rows = new ArrayList<Integer>();

        Set<Pair<Integer, Integer>> pixels = getUniquePixels(observedTarget.getTargetDefinitions());
        for (Pair<Integer, Integer> pixel : pixels) {
            int row = pixel.left;
            rows.add(row);
        }
        return rows.toArray(new Integer[0]);
    }

    private static Integer[] getColumns(ObservedTarget observedTarget) {
        List<Integer> columns = new ArrayList<Integer>();

        Set<Pair<Integer, Integer>> pixels = getUniquePixels(observedTarget.getTargetDefinitions());
        for (Pair<Integer, Integer> pixel : pixels) {
            int column = pixel.right;
            columns.add(column);
        }
        return columns.toArray(new Integer[0]);
    }

    private static Boolean[] getIsInOptimalApertures(
        ObservedTarget observedTarget) {
        List<Offset> apertureOffsets = observedTarget.getAperture()
            .getOffsets();
        int refRow = observedTarget.getAperture()
            .getReferenceRow();
        int refCol = observedTarget.getAperture()
            .getReferenceColumn();

        List<Boolean> isInOptimalApertures = new ArrayList<Boolean>();

        Set<Pair<Integer, Integer>> pixels = getUniquePixels(observedTarget.getTargetDefinitions());
        for (Pair<Integer, Integer> pixel : pixels) {
            int row = pixel.left - refRow;
            int column = pixel.right - refCol;
            Offset offset = new Offset(row, column);
            boolean isInOptimalAperture = apertureOffsets.contains(offset);

            isInOptimalApertures.add(isInOptimalAperture);
        }
        return isInOptimalApertures.toArray(new Boolean[0]);
    }

    private static List<TargetData> extractTargetDataForAllFsIds(
        Map<ObservedTarget, List<Pair<FsId, FsId>>> targetToFsIds,
        int startCadence, int endCadence, boolean isCalibrated)
        throws Exception {

        // Get all the time series:
        //
        Set<FsId> allDataFsIdsSet = new HashSet<FsId>();
        Set<FsId> allUncertFsIdsSet = new HashSet<FsId>();

        for (List<Pair<FsId, FsId>> fsIds : targetToFsIds.values()) {
            for (Pair<FsId, FsId> fsId : fsIds) {
                allDataFsIdsSet.add(fsId.left);
                if (isCalibrated) {
                    allUncertFsIdsSet.add(fsId.right);
                }
            }
        }

        System.out.println("Size of fsIds: " + allDataFsIdsSet.size());

        FsId[] allDataFsIds = allDataFsIdsSet.toArray(new FsId[0]);
        FsId[] allUncertFsIds = allUncertFsIdsSet.toArray(new FsId[0]);

        // Chunk by chunkSize FsIds here:
        //
        int chunkSize = 5000;

        int numDataFsIds = allDataFsIds.length;
        int numDataChunks = (int) Math.ceil((float) numDataFsIds
            / (float) chunkSize);

        int numUncertFsIds = allUncertFsIds.length;
        int numUncertChunks = (int) Math.ceil((float) numUncertFsIds
            / (float) chunkSize);

        // Allocate TimeSeries results:
        //
        TimeSeries[] dataTimeSeries = new TimeSeries[numDataFsIds];
        TimeSeries[] uncertTimeSeries = new TimeSeries[numUncertFsIds];

        // Get the TimeSeries for data in chunks:
        //
        for (int ii = 0; ii < numDataChunks; ++ii) {
            Pair<Integer, Integer> startEnd = getChunkIndices(ii, chunkSize,
                numDataFsIds);
            FsId[] fsIds = javaOneFiveCopyOfRange(allDataFsIds, startEnd.left,
                startEnd.right);
            TimeSeries[] timeSeries = getTimeSeries(fsIds, startCadence,
                endCadence, isCalibrated);

            for (int jj = startEnd.left; jj < startEnd.right; ++jj) {
                dataTimeSeries[jj] = timeSeries[jj - startEnd.left];
            }
        }

        // Get the TimeSeries for uncert in chunks:
        //
        for (int ii = 0; ii < numUncertChunks; ++ii) {
            Pair<Integer, Integer> startEnd = getChunkIndices(ii, chunkSize,
                numUncertFsIds);
            FsId[] fsIds = javaOneFiveCopyOfRange(allUncertFsIds,
                startEnd.left, startEnd.right);
            TimeSeries[] timeSeries = getTimeSeries(fsIds, startCadence,
                endCadence, isCalibrated);

            for (int jj = startEnd.left; jj < startEnd.right; ++jj) {
                uncertTimeSeries[jj] = timeSeries[jj - startEnd.left];
            }
        }

        // Map FsId to TimeSeries:
        //
        Map<FsId, TimeSeries> fsIdToTimeSeries = new HashMap<FsId, TimeSeries>();
        int ifsid = 0;
        for (FsId fsId : allDataFsIds) {
            fsIdToTimeSeries.put(fsId, dataTimeSeries[ifsid]);
            ++ifsid;
        }
        ifsid = 0;
        for (FsId fsId : allUncertFsIds) {
            fsIdToTimeSeries.put(fsId, uncertTimeSeries[ifsid]);
            ++ifsid;
        }

        return generateTargetDataList(targetToFsIds, fsIdToTimeSeries,
            isCalibrated);
    }

    private static FsId[] javaOneFiveCopyOfRange(FsId[] fullArray,
        int startIndex, int endIndexPlusOne) {
        FsId[] outputArray = new FsId[endIndexPlusOne - startIndex];
        for (int ii = startIndex; ii < endIndexPlusOne; ++ii) {
            outputArray[ii - startIndex] = fullArray[ii];
        }
        return outputArray;
    }

    private static List<TargetData> generateTargetDataList(
        Map<ObservedTarget, List<Pair<FsId, FsId>>> targetToFsIds,
        Map<FsId, TimeSeries> fsIdToTimeSeries, boolean isCalibrated) {

        List<TargetData> allTargetData = new ArrayList<TargetData>();

        for (ObservedTarget observedTarget : targetToFsIds.keySet()) {
            List<CalibratedPixelData> calPixelDataForTarget = new ArrayList<CalibratedPixelData>();
            List<UncalibratedPixelData> uncalPixelDataForTarget = new ArrayList<UncalibratedPixelData>();

            int keplerId = observedTarget.getKeplerId();
            Integer[] rows = getRows(observedTarget);
            Integer[] columns = getColumns(observedTarget);

            // Skip data extraction if this target is a INVALID_KEPLER_ID
            // target:
            //
            if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                TargetData targetData = new TargetData(keplerId,
                    calPixelDataForTarget, uncalPixelDataForTarget);
                allTargetData.add(targetData);
                continue;
            }

            Boolean[] isInOptimalApertures = getIsInOptimalApertures(observedTarget);

            List<Pair<FsId, FsId>> fsIds = targetToFsIds.get(observedTarget);

            // Get the timeSeries that this target's fsIds are associated with:
            //
            for (int ii = 0; ii < fsIds.size(); ++ii) {
                FsId dataFsId = fsIds.get(ii).left;
                FsId uncertFsId = fsIds.get(ii).right;
                TimeSeries dataTs = fsIdToTimeSeries.get(dataFsId);

                if (isCalibrated) {
                    TimeSeries uncertTs = fsIdToTimeSeries.get(uncertFsId);
                    CalibratedPixelData calibratedPixelData = new CalibratedPixelData(
                        rows[ii], columns[ii], isInOptimalApertures[ii],
                        (FloatTimeSeries) dataTs, (FloatTimeSeries) uncertTs);
                    calPixelDataForTarget.add(calibratedPixelData);
                } else {
                    UncalibratedPixelData uncalibratedPixelData = new UncalibratedPixelData(
                        rows[ii], columns[ii], isInOptimalApertures[ii],
                        (IntTimeSeries) dataTs);
                    uncalPixelDataForTarget.add(uncalibratedPixelData);
                }
            }

            TargetData targetData = new TargetData(keplerId,
                calPixelDataForTarget, uncalPixelDataForTarget);
            allTargetData.add(targetData);
        }

        return allTargetData;
    }

    // The indicies returned for this are the right ones for the [start, end)
    // (inclusive, exclusive) syntax that Arrays.copyOfRange uses:
    //
    private static Pair<Integer, Integer> getChunkIndices(int ii,
        int chunkSize, int length) {
        int start = ii * chunkSize;
        int end = start + chunkSize;
        if (end > length) {
            end = length;
        }
        return Pair.of(new Integer(start), new Integer(end));
    }

    private static TimeSeries[] getTimeSeries(FsId[] fsIds, int startCadence,
        int endCadence, boolean isCalibrated) throws IOException {
        FileStoreClient fsclient = FileStoreClientFactory.getInstance();
        TimeSeries[] dataTimeSeries;
        if (isCalibrated) {
            dataTimeSeries = fsclient.readTimeSeriesAsFloat(fsIds,
                startCadence, endCadence, false);
        } else {
            dataTimeSeries = fsclient.readTimeSeriesAsInt(fsIds, startCadence,
                endCadence, false);
        }
        fsclient.close();
        return dataTimeSeries;
    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        int[] ccdModules = { 7 };// , 7};
        int[] ccdOutputs = { 3 };// , 4};
        double startMjd = 55003.0;
        double endMjd = 55089.0;
        boolean isLongCadence = true;
        boolean isCalibrated = true;

        System.out.println("Retrieving calibrated pixel data");
        String path1 = retrievePixelTimeSeries(ccdModules, ccdOutputs,
            startMjd, endMjd, isLongCadence, isCalibrated);
        System.out.println("calibrated path=" + path1);

        // System.out.println("Retrieving uncalibrated pixel data");
        // String path2 = retrievePixelTimeSeries(ccdModules, ccdOutputs,
        // startMjd, endMjd, isLongCadence, !isCalibrated);
        // System.out.println("uncalibrated path=" + path2);
    }
}
