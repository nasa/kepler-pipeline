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

package gov.nasa.kepler.systest.validation.pixels;

import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.SimpleDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.SimpleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;
import java.util.TreeMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import nom.tam.fits.BinaryTable;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Forrest Girouard
 */
public class FitsCollateralPixelExtractor {

    public enum CollateralBinaryTable {
        BLACK(0, CollateralType.BLACK_LEVEL), BLACK_PIXEL_LIST(1,
            CollateralType.BLACK_LEVEL), VIRTUAL_SMEAR(2,
            CollateralType.VIRTUAL_SMEAR), VIRTUAL_SMEAR_PIXEL_LIST(3,
            CollateralType.VIRTUAL_SMEAR), MASKED_SMEAR(4,
            CollateralType.MASKED_SMEAR), MASKED_SMEAR_PIXEL_LIST(5,
            CollateralType.MASKED_SMEAR), BLACK_MASKED(6,
            CollateralType.BLACK_MASKED), BLACK_VIRTUAL(6,
            CollateralType.BLACK_VIRTUAL);

        private int binaryTable;
        private CollateralType type;

        private CollateralBinaryTable(int binaryTable, CollateralType type) {
            this.binaryTable = binaryTable;
            this.type = type;
        }

        private int getBinaryTable() {
            return binaryTable;
        }

        private CollateralType getType() {
            return type;
        }

        private static CollateralBinaryTable getPixelList(
            CollateralBinaryTable collateralBinaryTable) {

            CollateralBinaryTable pixelList = null;
            switch (collateralBinaryTable) {
                case BLACK:
                    pixelList = BLACK_PIXEL_LIST;
                    break;
                case VIRTUAL_SMEAR:
                    pixelList = VIRTUAL_SMEAR_PIXEL_LIST;
                    break;
                case MASKED_SMEAR:
                    pixelList = MASKED_SMEAR_PIXEL_LIST;
                    break;
                default:
                    break;
            }

            return pixelList;
        }
    }

    private enum CollateralPixelTableFormat {
        TIME(0),
        CADENCES(1),
        RAW_COUNTS(2),
        FLUX(3),
        FLUX_ERR(4),
        COSMIC_RAY(5);

        private int column;

        private CollateralPixelTableFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private enum CollateralPixelOffsetsTableFormat {
        OFFSETS(0);

        private int column;

        private CollateralPixelOffsetsTableFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private static final Log log = LogFactory.getLog(FitsCollateralPixelExtractor.class);

    private static final String FITS_PIXEL_FILE_REGEXP = "kplr%02d%d-%s_col%c.fits";

    private static final String FITS_SUFFIX = ".fits";
    private int ccdModule;
    private int ccdOutput;
    private CadenceType cadenceType;
    private int startCadence;
    private int endCadence = -1;
    private TimestampSeries cadenceTimes;
    private File fitsDirectory;
    private static Map<Pair<Integer, Integer>, File> filesByCadenceRange;

    private HashMap<Pair<CollateralType, Integer>, List<Integer>> rawTimeSeriesByCollateralTypeOffset;
    private HashMap<Pair<CollateralType, Integer>, List<Float>> fluxTimeSeriesByCollateralTypeOffset;
    private HashMap<Pair<CollateralType, Integer>, List<Float>> fluxErrTimeSeriesByCollateralTypeOffset;
    private HashMap<Pair<CollateralType, Integer>, List<Float>> cosmicRaySeriesByCollateralTypeOffset;

    public FitsCollateralPixelExtractor(int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        TimestampSeries cadenceTimes, File fitsDirectory) {

        if (cadenceTimes == null) {
            throw new NullPointerException("cadenceTimes can't be null");
        }
        if (fitsDirectory == null) {
            throw new NullPointerException("fitsDirectory can't be null");
        }
        if (endCadence < startCadence) {
            throw new IllegalArgumentException(String.format(
                "endCadence, %s, must be greater than or equal"
                    + " to startCadence, %s", endCadence, startCadence));
        }

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.cadenceType = cadenceType;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceTimes = cadenceTimes;
        this.fitsDirectory = fitsDirectory;
    }

    public static void clear() {
        filesByCadenceRange = null;
    }

    public boolean extractTimeSeries(
        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> simpleTimeSeriesByType,
        Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> simpleDoubleTimeSeriesByType)
        throws FitsException, IOException {

        boolean success = true;

        File file = getFitsFile(startCadence);
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            extractTimeSeries(
                ValidationUtils.extractBinaryTable(file.getName(), fitsFile),
                simpleDoubleTimeSeriesByType);
        } finally {
            fitsFile.getStream()
                .close();
        }

        return success;
    }

    private void extractTimeSeries(
        BinaryTable binaryTable,
        Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> simpleDoubleTimeSeriesByType)
        throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        double[] timesColumn = (double[]) binaryTable.getFlattenedColumn(CollateralPixelTableFormat.TIME.getColumn());
        double[] times = new double[length];
        System.arraycopy(timesColumn, offset, times, 0, length);
        boolean[] timeGaps = new boolean[times.length];
        setGapIndicators(times, timeGaps);
        simpleDoubleTimeSeriesByType.put(SimpleDoubleTimeSeriesType.TIME,
            new SimpleDoubleTimeSeries(times, timeGaps));
    }

    public int extractCadenceOffset() throws FitsException, IOException {

        int offset = 0;

        File file = getFitsFile(startCadence);
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            offset = extractCadenceOffset(ValidationUtils.extractBinaryTable(
                file.getName(), fitsFile));
        } finally {
            fitsFile.getStream()
                .close();
        }

        return offset;
    }

    private int extractCadenceOffset(BinaryTable binaryTable)
        throws FitsException {

        int[] cadences = (int[]) binaryTable.getFlattenedColumn(CollateralPixelTableFormat.CADENCES.getColumn());
        int offset = startCadence - cadences[0];

        return offset;
    }

    public void extractCollateralValues(
        CollateralBinaryTable collateralBinaryTable) throws FitsException,
        IOException {

        Map<Integer, Pair<CollateralType, Integer>> collateralTypeOffsetByIndex = new HashMap<Integer, Pair<CollateralType, Integer>>();
        if (CollateralBinaryTable.getPixelList(collateralBinaryTable) != null) {
            extractOffsetsByIndex(
                CollateralBinaryTable.getPixelList(collateralBinaryTable),
                collateralTypeOffsetByIndex);
        } else {
            collateralTypeOffsetByIndex.put(0,
                Pair.of(collateralBinaryTable.getType(), 0));
        }

        File file = getFitsFile(startCadence);
        Fits fitsFile = new Fits(file);
        try {
            BinaryTable binaryTable = getCollateralBinaryTable(
                collateralBinaryTable.getBinaryTable(), file, fitsFile);
            extractCollateralValues(collateralBinaryTable,
                collateralTypeOffsetByIndex, binaryTable);
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    private void extractCollateralValues(
        CollateralBinaryTable collateralBinaryTable,
        Map<Integer, Pair<CollateralType, Integer>> collateralTypeOffsetByIndex,
        BinaryTable binaryTable) throws FitsException {

        if (rawTimeSeriesByCollateralTypeOffset != null) {
            return;
        }

        rawTimeSeriesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Integer>>();
        fluxTimeSeriesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Float>>();
        fluxErrTimeSeriesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Float>>();
        cosmicRaySeriesByCollateralTypeOffset = new HashMap<Pair<CollateralType, Integer>, List<Float>>();

        for (Pair<CollateralType, Integer> collateralTypeOffset : collateralTypeOffsetByIndex.values()) {

            rawTimeSeriesByCollateralTypeOffset.put(collateralTypeOffset,
                new ArrayList<Integer>());
            fluxTimeSeriesByCollateralTypeOffset.put(collateralTypeOffset,
                new ArrayList<Float>());
            fluxErrTimeSeriesByCollateralTypeOffset.put(collateralTypeOffset,
                new ArrayList<Float>());
            cosmicRaySeriesByCollateralTypeOffset.put(collateralTypeOffset,
                new ArrayList<Float>());
        }

        switch (collateralBinaryTable) {
            case BLACK_MASKED:
            case BLACK_VIRTUAL:
                extractCollateralValues(collateralBinaryTable.getType(),
                    collateralTypeOffsetByIndex, binaryTable);
                break;
            default:
                extractCollateralValues(collateralTypeOffsetByIndex,
                    binaryTable);
                break;
        }
    }

    private void extractCollateralValues(
        CollateralType collateralType,
        Map<Integer, Pair<CollateralType, Integer>> collateralTypeOffsetByIndex,
        BinaryTable binaryTable) throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);
        int columnOffset = collateralType == CollateralType.BLACK_MASKED ? 0
            : CollateralPixelTableFormat.COSMIC_RAY.getColumn()
                - CollateralPixelTableFormat.RAW_COUNTS.getColumn() + 1;

        int[] rawData = (int[]) binaryTable.getColumn(CollateralPixelTableFormat.RAW_COUNTS.getColumn()
            + columnOffset);
        float[] fluxData = (float[]) binaryTable.getColumn(CollateralPixelTableFormat.FLUX.getColumn()
            + columnOffset);
        float[] fluxErrData = (float[]) binaryTable.getColumn(CollateralPixelTableFormat.FLUX_ERR.getColumn()
            + columnOffset);
        float[] cosmicRayData = (float[]) binaryTable.getColumn(CollateralPixelTableFormat.COSMIC_RAY.getColumn()
            + columnOffset);
        for (int cadence = offset; cadence < offset + length; cadence++) {
            Pair<CollateralType, Integer> collateralTypeOffset = Pair.of(
                collateralType, 0);
            rawTimeSeriesByCollateralTypeOffset.get(collateralTypeOffset)
                .add(rawData[cadence]);
            fluxTimeSeriesByCollateralTypeOffset.get(collateralTypeOffset)
                .add(fluxData[cadence]);
            fluxErrTimeSeriesByCollateralTypeOffset.get(collateralTypeOffset)
                .add(fluxErrData[cadence]);
            cosmicRaySeriesByCollateralTypeOffset.get(collateralTypeOffset)
                .add(cosmicRayData[cadence]);
        }
    }

    private void extractCollateralValues(
        Map<Integer, Pair<CollateralType, Integer>> collateralTypeOffsetByIndex,
        BinaryTable binaryTable) throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        int[][] rawData = (int[][]) binaryTable.getColumn(CollateralPixelTableFormat.RAW_COUNTS.getColumn());
        float[][] fluxData = (float[][]) binaryTable.getColumn(CollateralPixelTableFormat.FLUX.getColumn());
        float[][] fluxErrData = (float[][]) binaryTable.getColumn(CollateralPixelTableFormat.FLUX_ERR.getColumn());
        float[][] cosmicRayData = (float[][]) binaryTable.getColumn(CollateralPixelTableFormat.COSMIC_RAY.getColumn());
        for (int cadence = offset; cadence < offset + length; cadence++) {
            for (int index = 0; index < rawData[cadence].length; index++) {
                Pair<CollateralType, Integer> collateralTypeOffset = collateralTypeOffsetByIndex.get(index);
                if (collateralTypeOffset != null) {
                    rawTimeSeriesByCollateralTypeOffset.get(
                        collateralTypeOffset)
                        .add(rawData[cadence][index]);
                    fluxTimeSeriesByCollateralTypeOffset.get(
                        collateralTypeOffset)
                        .add(fluxData[cadence][index]);
                    fluxErrTimeSeriesByCollateralTypeOffset.get(
                        collateralTypeOffset)
                        .add(fluxErrData[cadence][index]);
                    cosmicRaySeriesByCollateralTypeOffset.get(
                        collateralTypeOffset)
                        .add(cosmicRayData[cadence][index]);
                }
            }
        }
    }

    @SuppressWarnings("unchecked")
    public void extractCadenceSlice(
        int cadence,
        Map<Pair<CollateralType, Integer>, List<Number>> valuesByCollateralTypeOffset) {

        int index = cadence - startCadence;
        for (Pair<CollateralType, Integer> collateralTypeOffset : rawTimeSeriesByCollateralTypeOffset.keySet()) {
            Integer raw = rawTimeSeriesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(index);
            Float flux = fluxTimeSeriesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(index);
            Float fluxErr = fluxErrTimeSeriesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(index);
            Float cosmicRay = cosmicRaySeriesByCollateralTypeOffset.get(
                collateralTypeOffset)
                .get(index);
            valuesByCollateralTypeOffset.put(collateralTypeOffset,
                (List<Number>) (List<? extends Number>) Arrays.asList(raw,
                    flux, fluxErr, cosmicRay));
        }
    }

    private File getFitsFile(int cadence) throws FitsException, IOException {

        File file = null;
        Map<Pair<Integer, Integer>, File> filesByCadenceRange = getFilesByCadenceRange();
        for (Map.Entry<Pair<Integer, Integer>, File> entry : filesByCadenceRange.entrySet()) {
            if (cadence >= entry.getKey().left
                && cadence <= entry.getKey().right) {
                file = entry.getValue();
                break;
            }
        }
        if (file == null) {
            throw new IllegalStateException(String.format(
                "Could not find FITS file in %s for cadence %d (approx %s)",
                fitsDirectory, cadence,
                mjdToDate(cadenceTimes.endTimestamps[cadence - startCadence])));
        }

        return file;
    }

    private Map<Pair<Integer, Integer>, File> getFilesByCadenceRange()
        throws FitsException, IOException {

        if (filesByCadenceRange == null) {
            filesByCadenceRange = createFilesByCadenceRange(fitsDirectory);
        }
        return filesByCadenceRange;
    }

    private Map<Pair<Integer, Integer>, File> createFilesByCadenceRange(
        File fitsDirectory) throws FitsException, IOException {

        long start = System.currentTimeMillis();
        log.info(String.format(
            "Reading cadence numbers from FITS files in %s for module %d output %d...",
            fitsDirectory, ccdModule, ccdOutput));

        Map<Pair<Integer, Integer>, File> fileByCadenceRange = new TreeMap<Pair<Integer, Integer>, File>(
            new IntegerPairComparator());

        Pattern pattern = Pattern.compile(String.format(FITS_PIXEL_FILE_REGEXP,
            ccdModule, ccdOutput, "\\d{13}",
            cadenceType == CadenceType.SHORT ? 's' : 'l'));
        File[] files = fitsDirectory.listFiles();
        for (File file : files) {
            if (!file.getName()
                .endsWith(FITS_SUFFIX)) {
                continue;
            }

            Matcher matcher = pattern.matcher(file.getName());
            if (!matcher.matches()) {
                continue;
            }

            Fits fitsFile = new Fits(file);
            int fileStartCadence = -1;
            int fileEndCadence = -1;
            try {
                Header fitsFileHeader = ValidationUtils.getFitsFileHeader(fitsFile);
                if (fitsFileHeader.getIntValue(MODULE_KW) != ccdModule) {
                    continue;
                }
                if (fitsFileHeader.getIntValue(OUTPUT_KW) != ccdOutput) {
                    continue;
                }
                BinaryTable table = ValidationUtils.extractBinaryTable(
                    file.getName(), fitsFile);
                int[] cadenceNumbers = (int[]) table.getFlattenedColumn(CollateralPixelTableFormat.CADENCES.getColumn());
                if (cadenceNumbers == null) {
                    throw new IllegalStateException(String.format(
                        "Expected non-empty cadence numbers column in %s",
                        file.getName()));
                }
                fileStartCadence = cadenceNumbers[0];
                fileEndCadence = cadenceNumbers[cadenceNumbers.length - 1];
            } finally {
                fitsFile.getStream()
                    .close();
            }

            fileByCadenceRange.put(Pair.of(fileStartCadence, fileEndCadence),
                file);
        }

        log.info(String.format(
            "Reading cadence numbers from FITS files in %s...done (%d seconds)",
            fitsDirectory, (System.currentTimeMillis() - start) / 1000));

        return fileByCadenceRange;
    }

    public boolean extractOffsetsByIndex(
        CollateralBinaryTable collateralBinaryTable,
        Map<Integer, Pair<CollateralType, Integer>> collateralTypeOffsetByIndex)
        throws FitsException, IOException {

        boolean success = false;

        if (collateralBinaryTable == CollateralBinaryTable.BLACK_MASKED
            || collateralBinaryTable == CollateralBinaryTable.BLACK_VIRTUAL) {

            collateralTypeOffsetByIndex.put(0,
                Pair.of(collateralBinaryTable.getType(), 0));
        } else {
            File file = getFitsFile(startCadence);
            Fits fitsFile = new Fits(file);
            try {
                BinaryTable binaryTable = getCollateralBinaryTable(
                    collateralBinaryTable.getBinaryTable(), file, fitsFile);
                extractOffsetsByIndex(collateralBinaryTable.getType(),
                    binaryTable, collateralTypeOffsetByIndex);
                success = true;
            } finally {
                fitsFile.getStream()
                    .close();
            }
        }

        return success;
    }

    private static BinaryTable getCollateralBinaryTable(int table, File file,
        Fits fitsFile) throws FitsException, IOException {
        ValidationUtils.getFitsFileHeader(file, fitsFile);
        for (int i = 0; i < table; i++) {
            ValidationUtils.extractBinaryTable(file.getName(), fitsFile);
        }
        BinaryTable binaryTable = ValidationUtils.extractBinaryTable(
            file.getName(), fitsFile);

        return binaryTable;
    }

    private static void extractOffsetsByIndex(CollateralType collateralType,
        BinaryTable binaryTable,
        Map<Integer, Pair<CollateralType, Integer>> collateralTypeOffsetByIndex)
        throws FitsException {

        int[] offsets = (int[]) binaryTable.getColumn(CollateralPixelOffsetsTableFormat.OFFSETS.getColumn());
        for (int index = 0; index < offsets.length; index++) {
            collateralTypeOffsetByIndex.put(index,
                Pair.of(collateralType, offsets[index]));
        }
    }

    private static String mjdToDate(double mjd) {

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyDDDHHmmss",
            Locale.US);
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        String date = dateFormat.format(ModifiedJulianDate.mjdToDate(mjd));

        return date;
    }

    private static void setGapIndicators(double[] values,
        boolean[] gapIndicators) {
        for (int i = 0; i < values.length; i++) {
            if (Double.isNaN(values[i])) {
                gapIndicators[i] = true;
            }
        }
    }

    private static class IntegerPairComparator implements
        Comparator<Pair<Integer, Integer>> {

        @Override
        public int compare(Pair<Integer, Integer> o1, Pair<Integer, Integer> o2) {

            if (o1.left.compareTo(o2.left) == 0) {
                return o1.right.compareTo(o2.right);
            }

            return o1.left.compareTo(o2.left);
        }
    }

}
