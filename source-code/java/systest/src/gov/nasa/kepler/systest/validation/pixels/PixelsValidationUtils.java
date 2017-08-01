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

import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.CALIBRATED_UNCERTAINTY;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.CALIBRATED_VALUE;
import static gov.nasa.kepler.systest.validation.pixels.FitsPixelExtractor.ORIGINAL_VALUE;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.systest.validation.FluxConverter;
import gov.nasa.kepler.systest.validation.SimpleDoubleTimeSeriesType;
import gov.nasa.kepler.systest.validation.ValidationUtils;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public final class PixelsValidationUtils {

    private static final Log log = LogFactory.getLog(PixelsValidationUtils.class);

    public static boolean validateTimes(int maxErrorsDisplayed,
        int startCadence, int endCadence,
        Pair<Integer, Integer> paCadenceRange, TimestampSeries cadenceTimes,
        SimpleDoubleTimeSeries fitsTimeTimeSeries) {

        SimpleDoubleTimeSeries times = PixelsValidationUtils.convertTimes(cadenceTimes);
        SimpleDoubleTimeSeries fitsTimes = ValidationUtils.resizeSimpleDoubleTimeSeries(
            startCadence, endCadence, paCadenceRange, fitsTimeTimeSeries);

        if (!ValidationUtils.diffSimpleDoubleTimeSeries(maxErrorsDisplayed,
            SimpleDoubleTimeSeriesType.TIME.toString(), -1, times, fitsTimes)) {
            return false;
        }

        return true;
    }

    public static boolean diffQualityFlags(String type, int cadence,
        int taskValue, int fitsValue) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ", type));
        output.append("\nCadence\tTask file (value)\tFITS file (value)\n");

        if (taskValue != fitsValue) {
            equals = false;

            output.append(cadence)
                .append("\t");
            output.append(taskValue)
                .append("\t");
            output.append(fitsValue)
                .append("\n");
        }

        if (!equals) {
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated 1 %s", type.toLowerCase()));
        }

        return equals;
    }

    public static boolean diffData(int maxErrorsDisplayed, String type,
        int cadence, FluxConverter fluxConverter,
        Map<Pixel, Float> taskCosmicRaysByPixel,
        Map<Pixel, List<Number>> taskPixelValuesByPixel,
        Map<Pixel, List<Number>> fitsPixelValuesByPixel) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nRow,Column\tTask file (orig, flux, flux err)\tFITS file (orig, flux, flux err)\n");

        int errorCount = 0;
        for (Pixel pixel : taskPixelValuesByPixel.keySet()) {
            List<Number> taskValues = PixelsValidationUtils.convertValues(
                fluxConverter, taskCosmicRaysByPixel.get(pixel),
                taskPixelValuesByPixel.get(pixel));
            List<Number> fitsValues = fitsPixelValuesByPixel.get(pixel);

            if (!taskValues.get(ORIGINAL_VALUE)
                .equals(fitsValues.get(ORIGINAL_VALUE))
                || !ValidationUtils.numbersEqual(
                    taskValues.get(CALIBRATED_VALUE),
                    fitsValues.get(CALIBRATED_VALUE), 0.000001)
                || !ValidationUtils.numbersEqual(
                    taskValues.get(CALIBRATED_UNCERTAINTY),
                    fitsValues.get(CALIBRATED_UNCERTAINTY), 0.000001)) {

                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(pixel.getRow())
                    .append(",")
                    .append(pixel.getColumn())
                    .append("\t");
                output.append(taskValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(taskValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(taskValues.get(CALIBRATED_UNCERTAINTY))
                    .append("\t");
                output.append(fitsValues.get(ORIGINAL_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_VALUE))
                    .append(" ")
                    .append(fitsValues.get(CALIBRATED_UNCERTAINTY))
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                taskPixelValuesByPixel.size(), (double) errorCount
                    / taskPixelValuesByPixel.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskPixelValuesByPixel.size(), type.toLowerCase()));
        }

        if (taskPixelValuesByPixel.size() != fitsPixelValuesByPixel.size()) {
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskPixelValuesByPixel.size(), type.toLowerCase(),
                fitsPixelValuesByPixel.size()));
            equals = false;
        }

        return equals;
    }

    public static boolean diffCosmicRays(int maxErrorsDisplayed, String type,
        int cadence, FluxConverter fluxConverter,
        Map<Pixel, Float> taskCosmicRayByPixel,
        Map<Pixel, Float> fitsCosmicRayByPixel) {

        boolean equals = true;
        StringBuffer output = new StringBuffer();
        output.append(String.format("\n%s differ for cadence %d", type, cadence));
        output.append("\nRow,Column\tTask file (value)\tFITS file (value)\n");

        int errorCount = 0;
        for (Pixel pixel : taskCosmicRayByPixel.keySet()) {
            Float taskValue = fluxConverter.fluxPerCadenceToFluxPerSecond(taskCosmicRayByPixel.get(pixel));
            Float fitsValue = fitsCosmicRayByPixel.get(pixel);
            if (!taskValue.equals(fitsValue)) {
                equals = false;
                if (errorCount++ >= maxErrorsDisplayed) {
                    continue;
                }

                output.append(pixel.getRow())
                    .append(",")
                    .append(pixel.getColumn())
                    .append("\t");
                output.append(taskValue)
                    .append("\t");
                output.append(fitsValue)
                    .append("\n");
            }
        }

        if (!equals) {
            if (errorCount >= maxErrorsDisplayed) {
                output.append("...\n");
            }
            output.append(String.format("%d error%s in %d values (%.2f%%)\n",
                errorCount, errorCount > 1 ? "s" : "",
                taskCosmicRayByPixel.size(), (double) errorCount
                    / taskCosmicRayByPixel.size() * 100.0));
            log.error(output.toString());
        } else {
            log.debug(String.format("Validated %d %s",
                taskCosmicRayByPixel.size(), type.toLowerCase()));
        }

        if (taskCosmicRayByPixel.size() != fitsCosmicRayByPixel.size()) {
            log.debug(String.format(
                "%s in task files contain %d time series while the %s in FITS files contain %d time series",
                type, taskCosmicRayByPixel.size(), type.toLowerCase(),
                fitsCosmicRayByPixel.size()));
            equals = false;
        }

        return equals;
    }

    private static SimpleDoubleTimeSeries convertTimes(
        TimestampSeries cadenceTimes) {

        double[] times = new double[cadenceTimes.midTimestamps.length];
        System.arraycopy(cadenceTimes.midTimestamps, 0, times, 0, times.length);
        boolean[] gaps = new boolean[cadenceTimes.gapIndicators.length];
        System.arraycopy(cadenceTimes.gapIndicators, 0, gaps, 0, gaps.length);

        return new SimpleDoubleTimeSeries(times, gaps);
    }

    private static List<Number> convertValues(FluxConverter fluxConverter,
        Float cosmicRayValue, List<Number> values) {

        ArrayList<Number> updatedTaskValues = new ArrayList<Number>();
        updatedTaskValues.add(ORIGINAL_VALUE, values.get(ORIGINAL_VALUE));

        updatedTaskValues.add(
            CALIBRATED_VALUE,
            fluxConverter.fluxPerCadenceToFluxPerSecond((double) (Float) values.get(CALIBRATED_VALUE)
                - (cosmicRayValue != null && !Float.isNaN(cosmicRayValue) ? (double) cosmicRayValue
                    : 0.0)));

        updatedTaskValues.add(
            CALIBRATED_UNCERTAINTY,
            fluxConverter.fluxPerCadenceToFluxPerSecond((Float) values.get(CALIBRATED_UNCERTAINTY)));

        return updatedTaskValues;
    }

    public static Map<Pixel, Float> convertCosmicRaysByRowColumnToByPixel(
        Map<Integer, Pixel> pixelsByIndex,
        Map<Pair<Integer, Integer>, Float> taskCosmicRaysByRowColumn) {

        Map<Pixel, Float> taskCosmicRaysByPixel = new HashMap<Pixel, Float>();
        for (Pixel pixel : pixelsByIndex.values()) {
            Float value = taskCosmicRaysByRowColumn.get(Pair.of(pixel.getRow(),
                pixel.getColumn()));
            if (value != null && !Float.isNaN(value)) {
                taskCosmicRaysByPixel.put(pixel, value);
            }
        }

        return taskCosmicRaysByPixel;
    }

    public static boolean extractTaskPixelValuesByPixel(
        int cadence,
        CalExtractor calExtractor,
        Map<Integer, Pixel> pixelsByIndex,
        Map<Pair<Integer, Integer>, List<Number>> fitsInputPixelValuesByRowColumn,
        Map<Pixel, List<Number>> taskPixelValuesByPixel) {

        Map<Pair<Integer, Integer>, List<Number>> allOutputTaskPixelValuesByRowColumn = new HashMap<Pair<Integer, Integer>, List<Number>>();
        if (!calExtractor.extractOutputPixels(cadence,
            allOutputTaskPixelValuesByRowColumn, null)) {
            return false;
        }

        for (Pixel pixel : pixelsByIndex.values()) {
            List<Number> mergedValues = new ArrayList<Number>();
            Pair<Integer, Integer> rowColumn = Pair.of(pixel.getRow(),
                pixel.getColumn());
            mergedValues.add(fitsInputPixelValuesByRowColumn.get(rowColumn)
                .get(ORIGINAL_VALUE));
            mergedValues.add(allOutputTaskPixelValuesByRowColumn.get(rowColumn)
                .get(CALIBRATED_VALUE));
            mergedValues.add(allOutputTaskPixelValuesByRowColumn.get(rowColumn)
                .get(CALIBRATED_UNCERTAINTY));
            taskPixelValuesByPixel.put(pixel, mergedValues);
        }

        return true;
    }
}
