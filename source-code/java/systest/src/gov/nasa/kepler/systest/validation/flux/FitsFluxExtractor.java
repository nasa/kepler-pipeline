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

package gov.nasa.kepler.systest.validation.flux;

import static gov.nasa.kepler.common.FitsConstants.KEPLERID_KW;
import static gov.nasa.kepler.common.FitsConstants.MODULE_KW;
import static gov.nasa.kepler.common.FitsConstants.OUTPUT_KW;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.systest.validation.CompoundDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.CompoundTimeSeriesType;
import gov.nasa.kepler.systest.validation.FitsAperture;
import gov.nasa.kepler.systest.validation.SimpleIntTimeSeriesType;
import gov.nasa.kepler.systest.validation.SimpleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.FitsException;
import nom.tam.fits.Header;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts flux time series from FITS file.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class FitsFluxExtractor {

    // These column numbers are 0-based.
    private enum FluxFileFormat {
        TIME(0),
        TIME_CORRECTION(1),
        CADENCES(2),
        SAP_RAW_FLUX(3),
        SAP_RAW_FLUX_UNCERTAINTIES(4),
        SAP_BACKGROUND(5),
        SAP_BACKGROUND_UNCERTAINTIES(6),
        SAP_CORRECTED_FLUX(7),
        SAP_CORRECTED_FLUX_UNCERTAINTIES(8),
        SAP_QUALITY(9),
        PSF_CENTROID_COLUMN(10),
        PSF_CENTROID_COLUMN_UNCERTAINTIES(11),
        PSF_CENTROID_ROW(12),
        PSF_CENTROID_ROW_UNCERTAINTIES(13),
        CENTROID_COLUMN(14),
        CENTROID_COLUMN_UNCERTAINTIES(15),
        CENTROID_ROW(16),
        CENTROID_ROW_UNCERTAINTIES(17),
        COLUMN_POSITION_CORRECTION(18),
        ROW_POSITION_CORRECTION(19);

        private int column;

        private FluxFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private static final Log log = LogFactory.getLog(FitsFluxExtractor.class);

    private CadenceType cadenceType;
    private int ccdModule;
    private int ccdOutput;
    private File fitsDirectory;

    private Map<Integer, File> fileByKeplerId = new HashMap<Integer, File>();

    public FitsFluxExtractor(CadenceType cadenceType, int ccdModule,
        int ccdOutput, File fitsDirectory) {

        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }
        if (fitsDirectory == null) {
            throw new NullPointerException("fitsDirectory can't be null");
        }

        this.cadenceType = cadenceType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.fitsDirectory = fitsDirectory;
    }

    public int extractCadenceOffset(int startCadence, int keplerId)
        throws FitsException, IOException {

        int offset = 0;

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        try {
            ValidationUtils.getFitsFileHeader(file, fitsFile);
            offset = extractCadenceOffset(startCadence,
                ValidationUtils.extractBinaryTable(file.getName(), fitsFile));
        } finally {
            fitsFile.getStream()
                .close();
        }

        return offset;
    }

    private int extractCadenceOffset(int startCadence, BinaryTable binaryTable)
        throws FitsException {

        int[] cadences = (int[]) binaryTable.getFlattenedColumn(FluxFileFormat.CADENCES.getColumn());
        int offset = startCadence - cadences[0];

        return offset;
    }

    public boolean extractAperture(int keplerId, FitsAperture fitsAperture)
        throws FitsException, IOException {

        if (fitsAperture == null) {
            throw new NullPointerException("fitsAperture can't be null");
        }

        boolean success = true;

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        ValidationUtils.extractAperture(file.getName(), fitsFile, true,
            fitsAperture);

        return success;
    }

    public Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries> extractSimpleIntTimeSeries(
        int keplerId) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        Map<SimpleIntTimeSeriesType, SimpleIntTimeSeries> timeSeriesByType = new HashMap<SimpleIntTimeSeriesType, SimpleIntTimeSeries>();
        try {
            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeSeriesByType.put(SimpleIntTimeSeriesType.SAP_QUALITY,
                ValidationUtils.extractSimpleIntTimeSeries(-1, table,
                    FluxFileFormat.SAP_QUALITY.getColumn()));
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeSeriesByType;
    }

    public Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> extractSimpleTimeSeries(
        int keplerId) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        Map<SimpleTimeSeriesType, SimpleFloatTimeSeries> timeSeriesByType = new HashMap<SimpleTimeSeriesType, SimpleFloatTimeSeries>();
        try {
            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeSeriesByType.put(SimpleTimeSeriesType.TIME_CORRECTION,
                ValidationUtils.extractSimpleTimeSeries(Float.NaN, table,
                    FluxFileFormat.TIME_CORRECTION.getColumn()));
            timeSeriesByType.put(
                SimpleTimeSeriesType.COLUMN_POSITION_CORRECTION,
                ValidationUtils.extractSimpleTimeSeries(Float.NaN, table,
                    FluxFileFormat.COLUMN_POSITION_CORRECTION.getColumn()));
            timeSeriesByType.put(SimpleTimeSeriesType.ROW_POSITION_CORRECTION,
                ValidationUtils.extractSimpleTimeSeries(Float.NaN, table,
                    FluxFileFormat.ROW_POSITION_CORRECTION.getColumn()));
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeSeriesByType;
    }

    public SimpleDoubleTimeSeries extractTimeSimpleDoubleTimeSeries(int keplerId)
        throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        SimpleDoubleTimeSeries timeSimpleDoubleTimeSeries = null;
        try {
            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeSimpleDoubleTimeSeries = ValidationUtils.extractSimpleDoubleTimeSeries(
                Float.NaN, table, FluxFileFormat.TIME.getColumn());
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeSimpleDoubleTimeSeries;
    }

    public Map<CompoundTimeSeriesType, CompoundFloatTimeSeries> extractCompoundTimeSeries(
        int keplerId) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        Map<CompoundTimeSeriesType, CompoundFloatTimeSeries> timeSeriesByType = new HashMap<CompoundTimeSeriesType, CompoundFloatTimeSeries>();
        try {
            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeSeriesByType.put(CompoundTimeSeriesType.SAP_RAW_FLUX,
                ValidationUtils.extractCompoundTimeSeries(Float.NaN, table,
                    FluxFileFormat.SAP_RAW_FLUX.getColumn(),
                    FluxFileFormat.SAP_RAW_FLUX_UNCERTAINTIES.getColumn()));
            timeSeriesByType.put(CompoundTimeSeriesType.SAP_BACKGROUND,
                ValidationUtils.extractCompoundTimeSeries(Float.NaN, table,
                    FluxFileFormat.SAP_BACKGROUND.getColumn(),
                    FluxFileFormat.SAP_BACKGROUND_UNCERTAINTIES.getColumn()));
            timeSeriesByType.put(
                CompoundTimeSeriesType.SAP_CORRECTED_FLUX,
                ValidationUtils.extractCompoundTimeSeries(Float.NaN, table,
                    FluxFileFormat.SAP_CORRECTED_FLUX.getColumn(),
                    FluxFileFormat.SAP_CORRECTED_FLUX_UNCERTAINTIES.getColumn()));
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeSeriesByType;
    }

    public Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries> extractDoubleTimeSeries(
        int keplerId) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        Map<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries> timeSeriesByType = new HashMap<CompoundDoubleTimeSeriesType, CompoundDoubleTimeSeries>();
        try {
            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeSeriesByType.put(CompoundDoubleTimeSeriesType.PSF_CENTROID_ROW,
                ValidationUtils.extractCompoundDoubleTimeSeries(Double.NaN,
                    table, FluxFileFormat.PSF_CENTROID_ROW.getColumn(),
                    FluxFileFormat.PSF_CENTROID_ROW_UNCERTAINTIES.getColumn()));
            timeSeriesByType.put(
                CompoundDoubleTimeSeriesType.PSF_CENTROID_COL,
                ValidationUtils.extractCompoundDoubleTimeSeries(
                    Double.NaN,
                    table,
                    FluxFileFormat.PSF_CENTROID_COLUMN.getColumn(),
                    FluxFileFormat.PSF_CENTROID_COLUMN_UNCERTAINTIES.getColumn()));

            timeSeriesByType.put(CompoundDoubleTimeSeriesType.CENTROID_ROW,
                ValidationUtils.extractCompoundDoubleTimeSeries(Double.NaN,
                    table, FluxFileFormat.CENTROID_ROW.getColumn(),
                    FluxFileFormat.CENTROID_ROW_UNCERTAINTIES.getColumn()));
            timeSeriesByType.put(CompoundDoubleTimeSeriesType.CENTROID_COL,
                ValidationUtils.extractCompoundDoubleTimeSeries(Double.NaN,
                    table, FluxFileFormat.CENTROID_COLUMN.getColumn(),
                    FluxFileFormat.CENTROID_COLUMN_UNCERTAINTIES.getColumn()));
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeSeriesByType;
    }

    public SimpleFloatTimeSeries extractTimeCorrection(int keplerId)
        throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        Fits fitsFile = new Fits(file);
        SimpleFloatTimeSeries timeCorrectionSeries = null;
        try {
            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeCorrectionSeries = ValidationUtils.extractSimpleTimeSeries(
                Float.NaN, table, FluxFileFormat.TIME_CORRECTION.getColumn());
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeCorrectionSeries;
    }

    public void extractIntKeywords(int keplerId, Set<String> keywords,
        Map<String, Integer> valueByKeyword) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        ValidationUtils.extractIntKeywords(file, keywords, valueByKeyword);
    }

    public void extractStringKeywords(int keplerId, Set<String> keywords,
        Map<String, String> valueByKeyword) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        ValidationUtils.extractStringKeywords(file, keywords, valueByKeyword);
    }

    public void extractFloatKeywords(int keplerId, Set<String> keywords,
        Map<String, Float> valueByKeyword) throws FitsException, IOException {

        File file = getFitsFile(keplerId);
        ValidationUtils.extractFloatKeywords(file, keywords, valueByKeyword);
    }

    public File getFitsFile(int keplerId) {

        File file = fileByKeplerId.get(keplerId);
        if (file == null) {
            File[] files = fitsDirectory.listFiles(new FitsFluxFilter(keplerId,
                cadenceType));

            if (files.length != 1) {
                if (files.length == 0
                    && TargetManagementConstants.isCustomTarget(keplerId)) {
                    return null;
                }
                throw new IllegalStateException(String.format(
                    "Expected only one file in %s for Kepler ID %d, not %d",
                    fitsDirectory, keplerId, files.length));
            }

            file = files[0];
            fileByKeplerId.put(keplerId, file);
        }

        return file;
    }

    private BinaryTable extractBinaryTable(File file, Fits fitsFile,
        int keplerId) throws FitsException, IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        Header header = headerHdu.getHeader();
        if (header.getIntValue(KEPLERID_KW) != keplerId) {
            throw new IllegalStateException(String.format(
                "Expected Kepler ID %d within header in FITS file %s, not %d",
                keplerId, file.getName(), header.getIntValue(KEPLERID_KW)));
        }
        if (header.getIntValue(MODULE_KW) != ccdModule) {
            throw new IllegalStateException(String.format(
                "Expected CCD module %d within header in FITS file %s, not %d",
                ccdModule, file.getName(), header.getIntValue(MODULE_KW)));
        }
        if (header.getIntValue(OUTPUT_KW) != ccdOutput) {
            throw new IllegalStateException(String.format(
                "Expected CCD output %d within header in FITS file %s, not %d",
                ccdOutput, file.getName(), header.getIntValue(OUTPUT_KW)));
        }

        headerHdu = fitsFile.readHDU();
        header = headerHdu.getHeader();

        Data data = headerHdu.getData();
        if (!(data instanceof BinaryTable)) {
            throw new IllegalStateException(String.format(
                "Expected BinaryTable data section in FITS file %s, not %s",
                file.getName(), data.getClass()
                    .getSimpleName()));
        }

        return (BinaryTable) data;
    }

    private static class FitsFluxFilter implements FilenameFilter {

        private static final String FITS_FLUX_FILE_REGEXP = "kplr0*%d-[0-9]{13}_%clc.fits";

        private int keplerId;
        private CadenceType cadenceType;

        public FitsFluxFilter(int keplerId, CadenceType cadenceType) {
            this.keplerId = keplerId;
            this.cadenceType = cadenceType;
        }

        @Override
        public boolean accept(File dir, String name) {
            return Pattern.matches(String.format(FITS_FLUX_FILE_REGEXP,
                keplerId, cadenceType == CadenceType.LONG ? 'l' : 's'), name);
        }
    }
}
