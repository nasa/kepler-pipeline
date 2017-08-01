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
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.SimpleDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
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
 * Extract the pixels from the ARP Fits file.
 * 
 * @author Forrest Girouard
 */
public class FitsArpPixelExtractor {

    private enum ArpPixelTableFormat {
        TIME(0),
        CADENCES(1),
        RAW_COUNTS(2),
        FLUX(3),
        FLUX_ERR(4),
        COSMIC_RAY(5),
        QUALITY(6);

        private int column;

        private ArpPixelTableFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private enum ArpPixelCoordinatesTableFormat {
        COLUMNS(0), ROWS(1);

        private int column;

        private ArpPixelCoordinatesTableFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private static final Log log = LogFactory.getLog(FitsArpPixelExtractor.class);

    private static final String FITS_SUFFIX = ".fits";

    private static final String FITS_PIXEL_FILE_REGEXP = "kplr%02d%1d-%s_arp.fits";
    private int ccdModule;
    private int ccdOutput;
    private int startCadence;
    private int endCadence = -1;
    private TimestampSeries cadenceTimes;
    private File fitsDirectory;
    Map<Pair<Integer, Integer>, File> filesByCadenceRange;

    private Map<Pixel, List<Integer>> rawTimeSeriesByPixel;
    private Map<Pixel, List<Float>> fluxTimeSeriesByPixel;
    private Map<Pixel, List<Float>> fluxErrTimeSeriesByPixel;
    private Map<Pixel, List<Float>> cosmicRaySeriesByPixel;

    public FitsArpPixelExtractor(int ccdModule, int ccdOutput,
        int startCadence, int endCadence, TimestampSeries cadenceTimes,
        File fitsDirectory) {

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
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceTimes = cadenceTimes;
        this.fitsDirectory = fitsDirectory;
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
        Map<SimpleDoubleTimeSeriesType, SimpleDoubleTimeSeries> simpleDoubleTimeSeriesByType)
        throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        double[] timesColumn = (double[]) binaryTable.getFlattenedColumn(ArpPixelTableFormat.TIME.getColumn());
        double[] times = new double[length];
        System.arraycopy(timesColumn, offset, times, 0, length);
        boolean[] timeGaps = new boolean[times.length];
        setGapIndicators(times, timeGaps);
        simpleDoubleTimeSeriesByType.put(SimpleDoubleTimeSeriesType.TIME,
            new SimpleDoubleTimeSeries(times, timeGaps));
    }

    public boolean extractTimeSeries(
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

    public void extractPixels(int cadence, int startCadence,
        Map<Integer, Pixel> pixelsByIndex,
        Map<Pixel, List<Number>> pixelValuesByPixel) throws FitsException,
        IOException {

        if (pixelValuesByPixel == null) {
            throw new NullPointerException("pixelValuesByPixel can't be null");
        }

        int cadenceIndex = cadence - startCadence;

        extractPixelValues(cadence, pixelsByIndex);

        for (Pixel pixel : pixelsByIndex.values()) {

            List<Integer> rawTimeSeries = rawTimeSeriesByPixel.get(pixel);
            List<Float> fluxTimeSeries = fluxTimeSeriesByPixel.get(pixel);
            List<Float> fluxErrTimeSeries = fluxErrTimeSeriesByPixel.get(pixel);

            List<Number> pixelValues = new ArrayList<Number>();
            pixelValues.add(rawTimeSeries.get(cadenceIndex));
            pixelValues.add(fluxTimeSeries.get(cadenceIndex));
            pixelValues.add(fluxErrTimeSeries.get(cadenceIndex));

            pixelValuesByPixel.put(pixel, pixelValues);
        }
    }

    private void extractPixelValues(int cadence,
        Map<Integer, Pixel> pixelsByIndex) throws FitsException, IOException {
        File file = getFitsFile(cadence);
        log.debug(String.format("Opening FITS file %s for cadence %d",
            file.getAbsolutePath(), cadence));
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            extractPixelValues(pixelsByIndex,
                ValidationUtils.extractBinaryTable(file.getName(), fitsFile));
        } finally {
            fitsFile.getStream()
                .close();
        }
    }

    private void extractPixelValues(Map<Integer, Pixel> pixelsByIndex,
        BinaryTable binaryTable) throws FitsException {

        if (rawTimeSeriesByPixel != null) {
            return;
        }

        rawTimeSeriesByPixel = new HashMap<Pixel, List<Integer>>();
        fluxTimeSeriesByPixel = new HashMap<Pixel, List<Float>>();
        fluxErrTimeSeriesByPixel = new HashMap<Pixel, List<Float>>();
        cosmicRaySeriesByPixel = new HashMap<Pixel, List<Float>>();

        for (Pixel pixel : pixelsByIndex.values()) {

            rawTimeSeriesByPixel.put(pixel, new ArrayList<Integer>());
            fluxTimeSeriesByPixel.put(pixel, new ArrayList<Float>());
            fluxErrTimeSeriesByPixel.put(pixel, new ArrayList<Float>());
            cosmicRaySeriesByPixel.put(pixel, new ArrayList<Float>());
        }

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        int[][] rawData = (int[][]) binaryTable.getColumn(ArpPixelTableFormat.RAW_COUNTS.getColumn());
        float[][] fluxData = (float[][]) binaryTable.getColumn(ArpPixelTableFormat.FLUX.getColumn());
        float[][] fluxErrData = (float[][]) binaryTable.getColumn(ArpPixelTableFormat.FLUX_ERR.getColumn());
        float[][] cosmicRayData = (float[][]) binaryTable.getColumn(ArpPixelTableFormat.COSMIC_RAY.getColumn());
        for (int cadence = offset; cadence < offset + length; cadence++) {
            for (int index = 0; index < rawData[cadence].length; index++) {
                Pixel pixel = pixelsByIndex.get(index);
                if (pixel != null) {
                    rawTimeSeriesByPixel.get(pixel)
                        .add(rawData[cadence][index]);
                    fluxTimeSeriesByPixel.get(pixel)
                        .add(fluxData[cadence][index]);
                    fluxErrTimeSeriesByPixel.get(pixel)
                        .add(fluxErrData[cadence][index]);
                    cosmicRaySeriesByPixel.get(pixel)
                        .add(cosmicRayData[cadence][index]);
                }
            }
        }
    }

    public boolean extractCosmicRays(int cadence,
        Map<Integer, Pixel> pixelsByIndex, Map<Pixel, Float> cosmicRaysByPixel)
        throws FitsException, IOException {

        extractPixelValues(cadence, pixelsByIndex);
        boolean success = true;

        for (Pixel pixel : pixelsByIndex.values()) {
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

    private void extractTimeSeries(BinaryTable binaryTable,
        Set<SimpleIntTimeSeries> simpleIntTimeSeries) throws FitsException {

        int length = endCadence - startCadence + 1;
        int offset = extractCadenceOffset(binaryTable);

        int[] qualityColumn = (int[]) binaryTable.getFlattenedColumn(ArpPixelTableFormat.QUALITY.getColumn());
        int[] quality = new int[length];
        System.arraycopy(qualityColumn, offset, quality, 0, length);
        boolean[] qualityGaps = new boolean[quality.length];
        // setGapIndicators(quality, qualityGaps);
        simpleIntTimeSeries.add(new SimpleIntTimeSeries(quality, qualityGaps));
    }

    private int extractCadenceOffset(BinaryTable binaryTable)
        throws FitsException {

        int[] cadences = (int[]) binaryTable.getFlattenedColumn(ArpPixelTableFormat.CADENCES.getColumn());
        int offset = startCadence - cadences[0];

        return offset;
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
            ccdModule, ccdOutput, "\\d{13}"));
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
                int[] cadenceNumbers = (int[]) table.getFlattenedColumn(ArpPixelTableFormat.CADENCES.getColumn());
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

    public boolean extractPixelsByIndex(Map<Integer, Pixel> pixelsByIndex)
        throws FitsException, IOException {

        boolean success = true;

        File file = getFitsFile(startCadence);
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            ValidationUtils.extractBinaryTable(file.getName(), fitsFile);
            extractPixelsByIndex(
                ValidationUtils.extractBinaryTable(file.getName(), fitsFile),
                pixelsByIndex);
        } finally {
            fitsFile.getStream()
                .close();
        }

        return success;
    }

    private void extractPixelsByIndex(BinaryTable binaryTable,
        Map<Integer, Pixel> pixelsByIndex) throws FitsException {

        int[] columns = (int[]) binaryTable.getColumn(ArpPixelCoordinatesTableFormat.COLUMNS.getColumn());
        int[] rows = (int[]) binaryTable.getColumn(ArpPixelCoordinatesTableFormat.ROWS.getColumn());
        for (int index = 0; index < rows.length; index++) {
            pixelsByIndex.put(index, new Pixel(rows[index], columns[index]));
        }
    }

    private String mjdToDate(double mjd) {

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
