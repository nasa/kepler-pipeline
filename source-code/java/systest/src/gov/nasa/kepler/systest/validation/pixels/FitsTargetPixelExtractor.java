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

import static gov.nasa.kepler.common.FitsConstants.KEPLERID_KW;
import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OBSMODE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.AperturePixel;
import gov.nasa.kepler.systest.validation.FitsAperture;
import gov.nasa.kepler.systest.validation.SimpleDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.SimpleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
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
 * Extracts a cadence slice of pixel data from FITS file.
 * 
 * @author Forrest Girouard
 */
public class FitsTargetPixelExtractor {

    private enum TargetPixelFileFormat {
        TIME(0),
        TIME_CORRECTION(1),
        CADENCES(2),
        RAW_COUNTS(3),
        FLUX(4),
        FLUX_ERR(5),
        BACKGROUND(6),
        BACKGROUND_ERR(7),
        COSMIC_RAY(8),
        QUALITY(9);

        private int column;

        private TargetPixelFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private static final Log log = LogFactory.getLog(FitsTargetPixelExtractor.class);

    // Indices into Number list that appear in returned maps.
    public static final int ORIGINAL_VALUE = 0;
    public static final int CALIBRATED_VALUE = 1;
    public static final int CALIBRATED_UNCERTAINTY = 2;

    /**
     * Filename format for FITS target pixel files. The %ss contain: 1. The
     * Kepler ID. 2. The date (see {@link #mjdToDate(double)}). 3. The cadence
     * type (`l' or `s').
     * 
     */
    private static final String FITS_PIXEL_FILE_REGEXP = "kplr%s-%s_%spd-targ.fits";

    private static final String FITS_SUFFIX = ".fits";
    private int keplerId = -1;
    private int ccdModule;
    private int ccdOutput;
    private CadenceType cadenceType;
    private int startCadence;
    private int endCadence = -1;
    private TimestampSeries cadenceTimes;
    private File fitsDirectory;
    Map<Pair<Integer, Integer>, File> filesByCadenceRange;

    private Map<Pixel, List<Integer>> rawTimeSeriesByPixel;
    private Map<Pixel, List<Float>> fluxTimeSeriesByPixel;
    private Map<Pixel, List<Float>> fluxErrTimeSeriesByPixel;
    private Map<Pixel, List<Float>> backgroundTimeSeriesByPixel;
    private Map<Pixel, List<Float>> backgroundErrTimeSeriesByPixel;
    private Map<Pixel, List<Float>> cosmicRaySeriesByPixel;

    public FitsTargetPixelExtractor(int keplerId, int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        TimestampSeries cadenceTimes, File fitsDirectory) {

        this(ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, fitsDirectory);

        this.keplerId = keplerId;
    }

    public FitsTargetPixelExtractor(int ccdModule, int ccdOutput,
        CadenceType cadenceType, int startCadence, int endCadence,
        TimestampSeries cadenceTimes, File fitsDirectory) {

        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }
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

    protected void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
        filesByCadenceRange = null;
        rawTimeSeriesByPixel = null;
        fluxTimeSeriesByPixel = null;
        fluxErrTimeSeriesByPixel = null;
        backgroundTimeSeriesByPixel = null;
        backgroundErrTimeSeriesByPixel = null;
        cosmicRaySeriesByPixel = null;
    }

    public boolean extractAperture(FitsAperture fitsAperture)
        throws FitsException, IOException {

        if (fitsAperture == null) {
            throw new NullPointerException("fitsAperture can't be null");
        }

        boolean success = true;

        File file = getFitsFile(startCadence);
        Fits fitsFile = new Fits(file);
        ValidationUtils.extractAperture(file.getName(), fitsFile, false,
            fitsAperture);

        return success;
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
                simpleTimeSeriesByType, simpleDoubleTimeSeriesByType);
        } finally {
            fitsFile.getStream()
                .close();
        }

        return success;
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

    private void extractTimeSeries(
        BinaryTable binaryTable,
        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> simpleTimeSeriesByType,
        Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> simpleDoubleTimeSeriesByType)
        throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        double[] timesColumn = (double[]) binaryTable.getFlattenedColumn(TargetPixelFileFormat.TIME.getColumn());
        double[] times = new double[length];
        System.arraycopy(timesColumn, offset, times, 0, length);
        boolean[] timeGaps = new boolean[times.length];
        setGapIndicators(times, timeGaps);
        simpleDoubleTimeSeriesByType.put(SimpleDoubleTimeSeriesType.TIME,
            new SimpleDoubleTimeSeries(times, timeGaps));

        float[] correctionsColumn = (float[]) binaryTable.getFlattenedColumn(TargetPixelFileFormat.TIME_CORRECTION.getColumn());
        float[] corrections = new float[length];
        System.arraycopy(correctionsColumn, offset, corrections, 0, length);
        boolean[] correctionGaps = new boolean[corrections.length];
        setGapIndicators(corrections, correctionGaps);
        simpleTimeSeriesByType.put(SimpleTimeSeriesType.TIME_CORRECTION,
            new SimpleFloatTimeSeries(corrections, correctionGaps));
    }

    public void extractPixels(int cadence, int startCadence,
        FitsAperture fitsAperture,
        Map<Pixel, List<Number>> targetPixelValuesByPixel)
        throws FitsException, IOException {

        if (targetPixelValuesByPixel == null) {
            throw new NullPointerException(
                "targetPixelValuesByPixel can't be null");
        }

        int cadenceIndex = cadence - startCadence;

        extractPixelValues(cadence, fitsAperture);

        for (AperturePixel aperturePixel : fitsAperture.getPixels()) {
            Pixel pixel = new Pixel(aperturePixel.getRow(),
                aperturePixel.getColumn());
            List<Integer> rawTimeSeries = rawTimeSeriesByPixel.get(pixel);
            List<Float> fluxTimeSeries = fluxTimeSeriesByPixel.get(pixel);
            List<Float> fluxErrTimeSeries = fluxErrTimeSeriesByPixel.get(pixel);
            List<Float> backgroundTimeSeries = backgroundTimeSeriesByPixel.get(pixel);
            List<Float> backgroundErrTimeSeries = backgroundErrTimeSeriesByPixel.get(pixel);

            List<Number> pixelValues = new ArrayList<Number>();
            pixelValues.add(rawTimeSeries.get(cadenceIndex));
            pixelValues.add(fluxTimeSeries.get(cadenceIndex));
            pixelValues.add(fluxErrTimeSeries.get(cadenceIndex));
            pixelValues.add(backgroundTimeSeries.get(cadenceIndex));
            pixelValues.add(backgroundErrTimeSeries.get(cadenceIndex));

            targetPixelValuesByPixel.put(pixel, pixelValues);
        }
    }

    private void extractPixelValues(int cadence, FitsAperture fitsAperture)
        throws FitsException, IOException {
        File file = getFitsFile(cadence);
        log.debug(String.format("Opening FITS file %s for cadence %d",
            file.getAbsolutePath(), cadence));
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            extractPixelValues(fitsAperture,
                ValidationUtils.extractBinaryTable(file.getName(), fitsFile));
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    private void extractPixelValues(FitsAperture fitsAperture,
        BinaryTable binaryTable) throws FitsException {

        if (rawTimeSeriesByPixel != null) {
            return;
        }

        rawTimeSeriesByPixel = new HashMap<Pixel, List<Integer>>();
        fluxTimeSeriesByPixel = new HashMap<Pixel, List<Float>>();
        fluxErrTimeSeriesByPixel = new HashMap<Pixel, List<Float>>();
        backgroundTimeSeriesByPixel = new HashMap<Pixel, List<Float>>();
        backgroundErrTimeSeriesByPixel = new HashMap<Pixel, List<Float>>();
        cosmicRaySeriesByPixel = new HashMap<Pixel, List<Float>>();

        for (AperturePixel aperturePixel : fitsAperture.getPixels()) {
            Pixel pixel = new Pixel(aperturePixel.getRow(),
                aperturePixel.getColumn());
            rawTimeSeriesByPixel.put(pixel, new ArrayList<Integer>());
            fluxTimeSeriesByPixel.put(pixel, new ArrayList<Float>());
            fluxErrTimeSeriesByPixel.put(pixel, new ArrayList<Float>());
            backgroundTimeSeriesByPixel.put(pixel, new ArrayList<Float>());
            backgroundErrTimeSeriesByPixel.put(pixel, new ArrayList<Float>());
            cosmicRaySeriesByPixel.put(pixel, new ArrayList<Float>());
        }

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        int[][][] rawData = (int[][][]) binaryTable.getColumn(TargetPixelFileFormat.RAW_COUNTS.getColumn());
        float[][][] fluxData = (float[][][]) binaryTable.getColumn(TargetPixelFileFormat.FLUX.getColumn());
        float[][][] fluxErrData = (float[][][]) binaryTable.getColumn(TargetPixelFileFormat.FLUX_ERR.getColumn());
        float[][][] backgroundData = (float[][][]) binaryTable.getColumn(TargetPixelFileFormat.BACKGROUND.getColumn());
        float[][][] backgroundErrData = (float[][][]) binaryTable.getColumn(TargetPixelFileFormat.BACKGROUND_ERR.getColumn());
        float[][][] cosmicRayData = (float[][][]) binaryTable.getColumn(TargetPixelFileFormat.COSMIC_RAY.getColumn());
        for (int cadence = offset; cadence < offset + length; cadence++) {
            for (int row = 0; row < rawData[cadence].length; row++) {
                for (int column = 0; column < rawData[cadence][row].length; column++) {
                    AperturePixel aperturePixel = fitsAperture.getPixel(Pair.of(
                        row, column));
                    if (aperturePixel != null) {
                        Pixel pixel = new Pixel(aperturePixel.getRow(),
                            aperturePixel.getColumn());
                        rawTimeSeriesByPixel.get(pixel)
                            .add(rawData[cadence][row][column]);
                        fluxTimeSeriesByPixel.get(pixel)
                            .add(fluxData[cadence][row][column]);
                        fluxErrTimeSeriesByPixel.get(pixel)
                            .add(fluxErrData[cadence][row][column]);
                        backgroundTimeSeriesByPixel.get(pixel)
                            .add(backgroundData[cadence][row][column]);
                        backgroundErrTimeSeriesByPixel.get(pixel)
                            .add(backgroundErrData[cadence][row][column]);
                        cosmicRaySeriesByPixel.get(pixel)
                            .add(cosmicRayData[cadence][row][column]);
                    }
                }
            }
        }
    }

    private int extractCadenceOffset(BinaryTable binaryTable)
        throws FitsException {

        int[] cadences = (int[]) binaryTable.getFlattenedColumn(TargetPixelFileFormat.CADENCES.getColumn());
        int offset = startCadence - cadences[0];

        return offset;
    }

    public boolean extractCosmicRays(int cadence,
        FitsAperture targetPixelsAperture, Map<Pixel, Float> cosmicRaysByPixel)
        throws FitsException, IOException {

        extractPixelValues(cadence, targetPixelsAperture);
        boolean success = true;

        for (AperturePixel aperturePixel : targetPixelsAperture.getPixels()) {
            Pixel pixel = new Pixel(aperturePixel.getRow(),
                aperturePixel.getColumn());
            float value = cosmicRaySeriesByPixel.get(pixel)
                .get(cadence - startCadence);
            if (!Float.isNaN(value)) {
                cosmicRaysByPixel.put(pixel, value);
            }
        }
        return success;
    }

    public boolean extractQuality(Set<SimpleIntTimeSeries> simpleIntTimeSeries)
        throws FitsException, IOException {

        boolean success = true;

        File file = getFitsFile(startCadence);
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            extractTimeSeries(
                ValidationUtils.extractBinaryTable(file.getName(), fitsFile),
                simpleIntTimeSeries);
        } finally {
            fitsFile.getStream()
                .close();
        }

        return success;
    }

    public void extractIntKeywords(Set<String> keywords,
        Map<String, Integer> valueByKeyword) throws FitsException, IOException {

        File file = getFitsFile(startCadence);
        ValidationUtils.extractIntKeywords(file, keywords, valueByKeyword);
    }

    public void extractStringKeywords(Set<String> keywords,
        Map<String, String> valueByKeyword) throws FitsException, IOException {

        File file = getFitsFile(startCadence);
        ValidationUtils.extractStringKeywords(file, keywords, valueByKeyword);
    }

    public void extractFloatKeywords(Set<String> keywords,
        Map<String, Float> valueByKeyword) throws FitsException, IOException {

        File file = getFitsFile(startCadence);
        ValidationUtils.extractFloatKeywords(file, keywords, valueByKeyword);
    }

    private void extractTimeSeries(BinaryTable binaryTable,
        Set<SimpleIntTimeSeries> simpleIntTimeSeries) throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        int[] qualityColumn = (int[]) binaryTable.getFlattenedColumn(TargetPixelFileFormat.QUALITY.getColumn());
        int[] quality = new int[length];
        System.arraycopy(qualityColumn, offset, quality, 0, length);
        boolean[] qualityGaps = new boolean[quality.length];
        // setGapIndicators(quality, qualityGaps);
        simpleIntTimeSeries.add(new SimpleIntTimeSeries(quality, qualityGaps));
    }

    public Pair<Integer, Integer> getFitsFileCadenceRange(int cadence)
        throws FitsException, IOException {

        Map<Pair<Integer, Integer>, File> filesByCadenceRange = getFilesByCadenceRange();
        for (Map.Entry<Pair<Integer, Integer>, File> entry : filesByCadenceRange.entrySet()) {
            if (cadence >= entry.getKey().left
                && cadence <= entry.getKey().right) {
                return entry.getKey();
            }
        }
        throw new IllegalStateException(String.format(
            "Could not find FITS file in %s for cadence %d (approx %s)",
            fitsDirectory, cadence,
            mjdToDate(cadenceTimes.endTimestamps[cadence - startCadence])));
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
            "Reading cadence numbers from FITS files in %s for keplerId %d...",
            fitsDirectory, keplerId));

        Map<Pair<Integer, Integer>, File> fileByCadenceRange = new TreeMap<Pair<Integer, Integer>, File>(
            new IntegerPairComparator());

        Pattern pattern = Pattern.compile(String.format(FITS_PIXEL_FILE_REGEXP,
            "(\\d{9})", "\\d{13}", "[ls]"));
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
            if (Integer.parseInt(matcher.group(1)) != keplerId) {
                continue;
            }

            Fits fitsFile = new Fits(file);
            int fileStartCadence = -1;
            int fileEndCadence = -1;
            try {
                Header fitsFileHeader = ValidationUtils.getFitsFileHeader(fitsFile);
                int fileKeplerId = fitsFileHeader.getIntValue(KEPLERID_KW);
                if (fileKeplerId != keplerId) {
                    log.warn(String.format(
                        "Unexpected Kepler ID %s of FITS file %s",
                        fileKeplerId, file.getAbsolutePath()));
                    continue;
                }
                String observingMode = cadenceType == CadenceType.LONG ? "long "
                    : "short ";
                if (!fitsFileHeader.getStringValue(OBSMODE_KW)
                    .startsWith(observingMode)) {
                    continue;
                }
                if (fitsFileHeader.getIntValue(MODULE_KW) != ccdModule) {
                    continue;
                }
                if (fitsFileHeader.getIntValue(OUTPUT_KW) != ccdOutput) {
                    continue;
                }
                BinaryTable table = ValidationUtils.extractBinaryTable(
                    file.getName(), fitsFile);
                int[] cadenceNumbers = (int[]) table.getFlattenedColumn(TargetPixelFileFormat.CADENCES.getColumn());
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

    private String mjdToDate(double mjd) {

        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyyDDDHHmmss",
            Locale.US);
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        String date = dateFormat.format(ModifiedJulianDate.mjdToDate(mjd));

        return date;
    }

    List<Integer> extractKeplerIds() throws IOException, FitsException {

        long start = System.currentTimeMillis();
        log.info(String.format(
            "Extracting Kepler IDs from FITS filenames in %s...", fitsDirectory));

        List<Integer> keplerIds = new ArrayList<Integer>();

        Pattern pattern = Pattern.compile(String.format(FITS_PIXEL_FILE_REGEXP,
            "(\\d{9})", "\\d{13}", "[ls]"));
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
            int keplerId = Integer.parseInt(matcher.group(1));

            Fits fitsFile = new Fits(file);
            try {
                Header fitsFileHeader = ValidationUtils.getFitsFileHeader(fitsFile);
                int fileKeplerId = fitsFileHeader.getIntValue(KEPLERID_KW);
                if (fileKeplerId != keplerId) {
                    log.warn(String.format(
                        "Unexpected Kepler ID %s of FITS file %s",
                        fileKeplerId, file.getAbsolutePath()));
                    continue;
                }
                String observingMode = cadenceType == CadenceType.LONG ? "long "
                    : "short ";
                if (!fitsFileHeader.getStringValue(OBSMODE_KW)
                    .startsWith(observingMode)) {
                    continue;
                }
                if (fitsFileHeader.getIntValue(MODULE_KW) != ccdModule) {
                    continue;
                }
                if (fitsFileHeader.getIntValue(OUTPUT_KW) != ccdOutput) {
                    continue;
                }
            } finally {
                fitsFile.getStream()
                    .close();
            }

            keplerIds.add(keplerId);
        }

        log.info(String.format(
            "Extracting Kepler IDs from FITS filenames in %s...done (%d seconds)",
            fitsDirectory, (System.currentTimeMillis() - start) / 1000));

        return keplerIds;
    }

    private static void setGapIndicators(float[] values, boolean[] gapIndicators) {
        for (int i = 0; i < values.length; i++) {
            if (Float.isNaN(values[i])) {
                gapIndicators[i] = true;
            }
        }
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
