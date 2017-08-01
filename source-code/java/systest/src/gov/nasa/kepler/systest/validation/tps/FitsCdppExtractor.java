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

package gov.nasa.kepler.systest.validation.tps;

import static gov.nasa.kepler.common.FitsConstants.KEPLERID_KW;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
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
 * Extracts CDPP time series from FITS file.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class FitsCdppExtractor {

    // These column numbers are 0-based.
    private enum CdppFileFormat {
        CADENCE_NO(1, 0F),
        CDPP_3H_AP(2, 3.0F),
        CDPP_6H_AP(3, 6.0F),
        CDPP_12H_AP(4, 12.0F);

        private int column;
        private float pulseDuration;

        private CdppFileFormat(int column, float pulseDuration) {
            this.column = column;
            this.pulseDuration = pulseDuration;
        }

        private int getColumn() {
            return column;
        }

        private float getPulseDuration() {
            return pulseDuration;
        }
    }

    private static final Log log = LogFactory.getLog(FitsCdppExtractor.class);

    private File fitsDirectory;

    public FitsCdppExtractor(File fitsDirectory) {

        if (fitsDirectory == null) {
            throw new NullPointerException("fitsDirectory can't be null");
        }

        this.fitsDirectory = fitsDirectory;
    }

    public Map<Pair<Integer, Float>, SimpleFloatTimeSeries> extractTimeSeries(
        int keplerId, int startCadence, int endCadence) throws FitsException,
        IOException {

        File[] files = fitsDirectory.listFiles(new FitsCdppFilter(keplerId));
        if (files.length != 1) {
            throw new IllegalStateException(String.format(
                "Expected one file in %s for Kepler ID %d, not %d",
                fitsDirectory, keplerId, files.length));
        }

        File file = files[0];
        Fits fitsFile = new Fits(file);
        Map<Pair<Integer, Float>, SimpleFloatTimeSeries> timeSeriesByKeplerIdAndPulse = new HashMap<Pair<Integer, Float>, SimpleFloatTimeSeries>();
        try {
            int fitsStartCadence = extractStartCadence(file, keplerId);
            if (fitsStartCadence > startCadence) {
                throw new IllegalStateException(
                    String.format(
                        "FITS file %s started at cadence %d but should have "
                            + "been less than or equal to task file start cadence of %d",
                        file.getAbsolutePath(), fitsStartCadence, startCadence));
            }

            extractPrimaryHeader(file, fitsFile, keplerId);

            BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);

            timeSeriesByKeplerIdAndPulse.put(
                Pair.of(keplerId, CdppFileFormat.CDPP_3H_AP.getPulseDuration()),
                extractSimpleTimeSeries(file, table,
                    CdppFileFormat.CDPP_3H_AP.getColumn(), fitsStartCadence,
                    startCadence, endCadence));
            timeSeriesByKeplerIdAndPulse.put(
                Pair.of(keplerId, CdppFileFormat.CDPP_6H_AP.getPulseDuration()),
                extractSimpleTimeSeries(file, table,
                    CdppFileFormat.CDPP_6H_AP.getColumn(), fitsStartCadence,
                    startCadence, endCadence));
            timeSeriesByKeplerIdAndPulse.put(
                Pair.of(keplerId, CdppFileFormat.CDPP_12H_AP.getPulseDuration()),
                extractSimpleTimeSeries(file, table,
                    CdppFileFormat.CDPP_12H_AP.getColumn(), fitsStartCadence,
                    startCadence, endCadence));
        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + file);

        return timeSeriesByKeplerIdAndPulse;
    }

    private SimpleFloatTimeSeries extractSimpleTimeSeries(File file,
        BinaryTable table, int valuesColumn, int fitsStartCadence,
        int startCadence, int endCadence) throws FitsException {

        SimpleFloatTimeSeries timeSeries = ValidationUtils.extractSimpleTimeSeries(
            Float.NaN, table, valuesColumn);
        int fitsEndCadence = fitsStartCadence + timeSeries.getValues().length
            - 1;
        if (fitsEndCadence < endCadence) {
            throw new IllegalStateException(
                String.format(
                    "FITS file %s ended at cadence %d but should have "
                        + "been greater than or equal to task file end cadence of %d",
                    file.getAbsolutePath(), fitsEndCadence, endCadence));
        }
        int length = endCadence - startCadence + 1;
        if (timeSeries.getValues().length == length) {
            return timeSeries;
        }

        int fitsStartOffset = startCadence - fitsStartCadence;
        float[] values = new float[length];
        System.arraycopy(timeSeries.getValues(), fitsStartOffset, values, 0,
            length);
        boolean[] gapIndicators = new boolean[length];
        System.arraycopy(timeSeries.getGapIndicators(), fitsStartOffset,
            gapIndicators, 0, length);
        SimpleFloatTimeSeries trimmedTimeSeries = new SimpleFloatTimeSeries(
            values, gapIndicators);

        return trimmedTimeSeries;
    }

    private int extractStartCadence(File file, int keplerId)
        throws FitsException, IOException {

        Fits fitsFile = new Fits(file);
        extractPrimaryHeader(file, fitsFile, keplerId);

        BinaryTable table = extractBinaryTable(file, fitsFile, keplerId);
        SimpleIntTimeSeries timeSeries = ValidationUtils.extractSimpleIntTimeSeries(
            -1, table, CdppFileFormat.CADENCE_NO.getColumn());

        return timeSeries.getValues()[0];
    }

    private BinaryTable extractBinaryTable(File file, Fits fitsFile,
        int keplerId) throws FitsException, IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        Data data = headerHdu.getData();

        if (!(data instanceof BinaryTable)) {
            throw new IllegalStateException(String.format(
                "Expected BinaryTable data section in FITS file %s, not %s",
                file.getName(), data.getClass()
                    .getSimpleName()));
        }

        return (BinaryTable) data;
    }

    private Header extractPrimaryHeader(File file, Fits fitsFile, int keplerId)
        throws FitsException, IOException {

        BasicHDU headerHdu = fitsFile.readHDU();
        Header header = headerHdu.getHeader();

        if (header.getIntValue(KEPLERID_KW) != keplerId) {
            throw new IllegalStateException(String.format(
                "Expected Kepler ID %d within header in FITS file %s, not %d",
                keplerId, file.getName(), header.getIntValue(KEPLERID_KW)));
        }

        return header;
    }

    private static class FitsCdppFilter implements FilenameFilter {

        private static final String FITS_CDPP_FILE_REGEXP = "kplr0*%d-[0-9]{14}_cdpp.fits";

        private int keplerId;

        public FitsCdppFilter(int keplerId) {
            this.keplerId = keplerId;
        }

        @Override
        public boolean accept(File dir, String name) {
            return Pattern.matches(
                String.format(FITS_CDPP_FILE_REGEXP, keplerId), name);
        }
    }
}
