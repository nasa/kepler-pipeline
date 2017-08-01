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

import gov.nasa.kepler.tps.TpsResult;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Extracts TPS results from the exported ASCII text file.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class TextTpsExtractor {

    private enum TextFileFormat {
        KEPLER_ID(0),
        TRIAL_TRANSIT_PULSE_DURATION(1),
        FLUX_TYPE(2),
        THRESHOLD(3),
        DETECTED_ORBITAL_PERIOD(4),
        TIME_OF_FIRST_TRANSIT(5),
        MAX_MULTIPLE_EVENT_STATISTIC(6),
        MAX_SINGLE_EVENT_STATISTIC(7),
        IS_PLANET_A_CANDIDATE(8);

        private int column;

        private TextFileFormat(int column) {
            this.column = column;
        }

        private int getColumn() {
            return column;
        }
    }

    private static final Log log = LogFactory.getLog(TextTpsExtractor.class);

    private File outputDirectory;

    public TextTpsExtractor(File outputDirectory) {
        if (outputDirectory == null) {
            throw new NullPointerException("outputDirectory can't be null");
        }

        this.outputDirectory = outputDirectory;
    }

    public void extractTpsResults(
        Map<Pair<Integer, Float>, TpsResult> exportedTargetByKeplerIdAndPulse)
        throws IOException {

        File[] files = outputDirectory.listFiles(new TpsResultFilter());
        if (files.length != 1) {
            throw new IllegalStateException(String.format(
                "Expected one file in %s, not %d", outputDirectory,
                files.length));
        }

        for (File file : files) {
            exportedTargetByKeplerIdAndPulse.putAll(extractTpsResults(file));
        }

        log.debug("Successfully processed " + files[0]);
    }

    private Map<Pair<Integer, Float>, TpsResult> extractTpsResults(File file)
        throws IOException {

        Map<Pair<Integer, Float>, TpsResult> tpsResults = new HashMap<Pair<Integer, Float>, TpsResult>();
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(file));
            String line = reader.readLine();
            while (line != null) {
                if (!line.startsWith("#")) {
                    TpsResult tpsResult = parseLine(line);
                    tpsResults.put(
                        Pair.of(tpsResult.getKeplerId(),
                            tpsResult.getTrialTransitPulseInHours()), tpsResult);
                }
                line = reader.readLine();
            }
        } finally {
            FileUtil.close(reader);
        }
        return tpsResults;
    }

    private TpsResult parseLine(String input) {

        // Check that we have the correct number of delimiters.
        int delimiterCount = 0;
        for (int i = input.length() - 1; i >= 0; i--) {
            if (input.charAt(i) == '|') {
                delimiterCount++;
            }
        }
        if (delimiterCount + 1 != TextFileFormat.values().length) {
            throw new IllegalArgumentException(String.format(
                "Input string \"%s\" has %d fields when %d are expected",
                input, delimiterCount + 1, TextFileFormat.values().length));
        }

        String[] fields = input.split("\\|");

        TpsResult tpsResult = new TpsResult();
        tpsResult.setKeplerId(parseInt(fields,
            TextFileFormat.KEPLER_ID.getColumn()));
        tpsResult.setTrialTransitPulseInHours(parseFloat(fields,
            TextFileFormat.TRIAL_TRANSIT_PULSE_DURATION.getColumn()));
        tpsResult.setDetectedOrbitalPeriodInDays(parseFloat(fields,
            TextFileFormat.DETECTED_ORBITAL_PERIOD.getColumn()));
        tpsResult.setTimeOfFirstTransitInMjd(parseDouble(fields,
            TextFileFormat.TIME_OF_FIRST_TRANSIT.getColumn()));
        tpsResult.setMaxMultipleEventStatistic(parseFloat(fields,
            TextFileFormat.MAX_MULTIPLE_EVENT_STATISTIC.getColumn()));
        tpsResult.setMaxSingleEventStatistic(parseFloat(fields,
            TextFileFormat.MAX_SINGLE_EVENT_STATISTIC.getColumn()));
        if (parseInt(fields, TextFileFormat.IS_PLANET_A_CANDIDATE.getColumn()) != 0) {
            tpsResult.setPlanetACandidate(true);
        }

        return tpsResult;
    }

    private int parseInt(String[] fields, int n) {
        return fields.length > n && fields[n].length() > 0 ? Integer.parseInt(fields[n].trim())
            : Integer.MIN_VALUE;
    }

    private float parseFloat(String[] fields, int n) {
        return fields.length > n && fields[n].length() > 0 ? Float.parseFloat(fields[n].trim())
            : Float.NaN;
    }

    private double parseDouble(String[] fields, int n) {
        return fields.length > n && fields[n].length() > 0 ? Double.parseDouble(fields[n].trim())
            : Double.NaN;
    }

    private static class TpsResultFilter implements FilenameFilter {

        private static final String TEXT_FILE_REGEXP = "kplr20[0-9]{12}_tps_results.txt";

        @Override
        public boolean accept(File dir, String name) {
            return Pattern.matches(TEXT_FILE_REGEXP, name);
        }
    }
}
