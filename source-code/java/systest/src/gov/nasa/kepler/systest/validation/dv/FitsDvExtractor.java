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

package gov.nasa.kepler.systest.validation.dv;

import static gov.nasa.kepler.common.FitsConstants.KEPLERID_KW;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
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
 * Extracts flux and single event statistics time series from FITS file.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class FitsDvExtractor {

    private static final int SINGLE_EVENT_STATISTICS_COLUMN_OFFSET = 6;
    private static final Float GAP_FILL_VALUE = Float.NaN;

    private enum FluxFileFormat {
        RESIDUAL_FLUX(2), RESIDUAL_FLUX_UNCERTAINTIES(3),

        // Per-planet.
        INITIAL_FLUX(4),
        INITIAL_FLUX_UNCERTAINTIES(5);

        private final int column;

        private FluxFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private static final Log log = LogFactory.getLog(FitsDvExtractor.class);

    private File fitsDirectory;

    public FitsDvExtractor(File fitsDirectory) {

        if (fitsDirectory == null) {
            throw new NullPointerException("fitsDirectory can't be null");
        }

        this.fitsDirectory = fitsDirectory;
    }

    public void extractTimeSeries(int keplerId,
        Map<FsId, SimpleFloatTimeSeries> simpleFloatTimeSeries,
        Map<FsId, CompoundFloatTimeSeries> compoundFloatTimeSeries)
        throws FitsException, IOException {

        if (simpleFloatTimeSeries == null) {
            throw new NullPointerException("simpleTimeSeries can't be null");
        }
        if (compoundFloatTimeSeries == null) {
            throw new NullPointerException("compoundTimeSeries can't be null");
        }

        File[] files = fitsDirectory.listFiles(new FitsFluxFilter(keplerId));
        if (files.length != 1) {
            throw new IllegalStateException(String.format(
                "Expected only one file in %s for Kepler ID %d, not %d",
                fitsDirectory, keplerId, files.length));
        }

        Fits fitsFile = new Fits(files[0]);
        try {
            BasicHDU headerHdu = fitsFile.readHDU();
            Header header = headerHdu.getHeader();
            if (header.getIntValue(KEPLERID_KW) != keplerId) {
                throw new IllegalStateException(
                    String.format(
                        "Expected Kepler ID %d within header in FITS file %s, not %d",
                        keplerId, files[0].getName(),
                        header.getIntValue(KEPLERID_KW)));
            }

            headerHdu = fitsFile.readHDU();
            header = headerHdu.getHeader();
            int planetCount = header.getIntValue("NPLANETS");
            if (planetCount < 1) {
                throw new IllegalStateException(String.format(
                    "Expected at least one planet in FITS file %s",
                    files[0].getName()));
            }

            List<Float> trialTransitPulseDurations = extractTrialTransitPulseDurations(header);

            Data data = headerHdu.getData();
            if (!(data instanceof BinaryTable)) {
                throw new IllegalStateException(
                    String.format(
                        "Expected BinaryTable data section in FITS file %s, not %s",
                        files[0].getName(), data.getClass()
                            .getSimpleName()));
            }
            BinaryTable table = (BinaryTable) data;

            extractSimpleTimeSeries(table, keplerId, planetCount,
                trialTransitPulseDurations, simpleFloatTimeSeries);
            extractCompoundTimeSeries(table, keplerId, planetCount,
                compoundFloatTimeSeries);

        } finally {
            fitsFile.getStream()
                .close();
        }

        log.debug("Successfully processed " + files[0]);
    }

    private List<Float> extractTrialTransitPulseDurations(Header header) {

        List<Float> trialTransitPulseDurations = new ArrayList<Float>();
        int index = 1;
        while (true) {
            float value = header.getFloatValue("TTPULS" + index++, -1.0F);
            if (value < 0) {
                break;
            }
            trialTransitPulseDurations.add(value);
        }
        return trialTransitPulseDurations;
    }

    private void extractSimpleTimeSeries(BinaryTable table, int keplerId,
        int planetCount, List<Float> trialTransitPulseDurations,
        Map<FsId, SimpleFloatTimeSeries> simpleFloatTimeSeries)
        throws FitsException {

        for (int i = 0; i < trialTransitPulseDurations.size(); i++) {
            float trialTransitPulseDuration = trialTransitPulseDurations.get(i);
            simpleFloatTimeSeries.put(
                DvFsIdFactory.getSingleEventStatisticsFsId(FluxType.SAP,
                    DvSingleEventStatisticsType.CORRELATION, 0L, keplerId,
                    trialTransitPulseDuration),
                ValidationUtils.extractSimpleTimeSeries(GAP_FILL_VALUE, table,
                    SINGLE_EVENT_STATISTICS_COLUMN_OFFSET + i * 2 + 2
                        * (planetCount - 1)));
            simpleFloatTimeSeries.put(
                DvFsIdFactory.getSingleEventStatisticsFsId(FluxType.SAP,
                    DvSingleEventStatisticsType.NORMALIZATION, 0L, keplerId,
                    trialTransitPulseDuration),
                ValidationUtils.extractSimpleTimeSeries(GAP_FILL_VALUE, table,
                    SINGLE_EVENT_STATISTICS_COLUMN_OFFSET + i * 2 + 1 + 2
                        * (planetCount - 1)));

        }
    }

    private void extractCompoundTimeSeries(BinaryTable table, int keplerId,
        int planetCount,
        Map<FsId, CompoundFloatTimeSeries> compoundFloatTimeSeries)
        throws FitsException {

        compoundFloatTimeSeries.put(DvFsIdFactory.getResidualTimeSeriesFsId(
            FluxType.SAP, DvTimeSeriesType.FLUX, 0L, keplerId),
            ValidationUtils.extractCompoundTimeSeries(GAP_FILL_VALUE, table,
                FluxFileFormat.RESIDUAL_FLUX.getColumn(),
                FluxFileFormat.RESIDUAL_FLUX_UNCERTAINTIES.getColumn()));

        for (int planetNumber = 0; planetNumber < planetCount; planetNumber++) {
            compoundFloatTimeSeries.put(
                DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(FluxType.SAP,
                    DvCorrectedFluxType.INITIAL, DvTimeSeriesType.FLUX, 0L,
                    keplerId, planetNumber + 1),
                ValidationUtils.extractCompoundTimeSeries(GAP_FILL_VALUE,
                    table, FluxFileFormat.INITIAL_FLUX.getColumn() + 2
                        * planetNumber,
                    FluxFileFormat.INITIAL_FLUX_UNCERTAINTIES.getColumn() + 2
                        * planetNumber));
        }
    }

    private static class FitsFluxFilter implements FilenameFilter {

        // TODO 14 might be 13
        private static final String FITS_FLUX_FILE_REGEXP = "kplr0*%d-[0-9]{14}_dvt.fits";

        private int keplerId;

        public FitsFluxFilter(int keplerId) {
            this.keplerId = keplerId;
        }

        @Override
        public boolean accept(File dir, String name) {
            return Pattern.matches(
                String.format(FITS_FLUX_FILE_REGEXP, keplerId), name);
        }
    }
}
