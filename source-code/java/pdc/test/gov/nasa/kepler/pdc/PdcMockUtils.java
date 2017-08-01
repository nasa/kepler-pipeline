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

package gov.nasa.kepler.pdc;

import static gov.nasa.spiffy.common.jmock.JMockTest.returnValue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.hibernate.mc.ObservingLogModel;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.DataAnomalyFlags;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PdcMockUtils {

    public static PdcTimestampSeries mockPdcCadenceTimes(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, MjdToCadence mjdToCadence,
        ObservingLogModel observingLogModel, int observingSeason,
        int lcTargetTableId, CadenceType cadenceType, int startCadence,
        int endCadence) {

        PdcTimestampSeries series = createTimestampSeries(jMockTest,
            rollTimeOperations, mjdToCadence, observingLogModel,
            observingSeason, lcTargetTableId, cadenceType, startCadence,
            endCadence);

        if (jMockTest != null && mjdToCadence != null) {
            mockMjdsToSeason(jMockTest, rollTimeOperations,
                series.midTimestamps, observingSeason);
            jMockTest.allowing(mjdToCadence)
                .cadenceTimes(startCadence, endCadence, true, false);
            jMockTest.will(returnValue(series));
        }
        return series;
    }

    private static PdcTimestampSeries createTimestampSeries(
        JMockTest jMockTest, RollTimeOperations rollTimeOperations,
        MjdToCadence mjdToCadence, ObservingLogModel observingLogModel,
        int observingSeason, int lcTargetTableId, CadenceType cadenceType,
        int startCadence, int endCadence) {

        double cadenceLengthDays = 0;
        if (cadenceType == CadenceType.SHORT) {
            cadenceLengthDays = (double) ModifiedJulianDate.SHORT_CADENCE_LENGTH_MINUTES
                / MockUtils.MINUTES_PER_DAY;
        } else {
            cadenceLengthDays = (double) ModifiedJulianDate.CADENCE_LENGTH_MINUTES
                / MockUtils.MINUTES_PER_DAY;
        }

        double[] startTimes = new double[endCadence - startCadence + 1];
        double[] endTimes = new double[endCadence - startCadence + 1];
        double[] midTimes = new double[endCadence - startCadence + 1];
        int[] cadenceNumbers = new int[startTimes.length];
        double startMjd = 55553.5 + startCadence * cadenceLengthDays;
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
            double endMjd = startMjd + cadenceLengthDays;
            startTimes[cadence - startCadence] = startMjd;
            endTimes[cadence - startCadence] = endMjd;
            midTimes[cadence - startCadence] = startMjd + cadenceLengthDays / 2;
            cadenceNumbers[cadence - startCadence] = cadence;
            startMjd = endMjd;
        }

        boolean[] gaps = new boolean[startTimes.length];
        boolean[] requantEnabled = new boolean[startTimes.length];
        boolean[] isSefiAcc = new boolean[startTimes.length];
        boolean[] isSefiCad = new boolean[startTimes.length];
        boolean[] isLdeOos = new boolean[startTimes.length];
        boolean[] isFinePnt = new boolean[startTimes.length];
        boolean[] isMmntmDmp = new boolean[startTimes.length];
        boolean[] isLdeParEr = new boolean[startTimes.length];
        boolean[] isScrcErr = new boolean[startTimes.length];
        Arrays.fill(requantEnabled, true);

        DataAnomalyFlags dataAnomalyFlags = new DataAnomalyFlags(
            new boolean[startTimes.length], new boolean[startTimes.length],
            new boolean[startTimes.length], new boolean[startTimes.length],
            new boolean[startTimes.length], new boolean[startTimes.length],
            new boolean[startTimes.length]);

        mockMjdsToQuarter(jMockTest, rollTimeOperations, startTimes,
            observingSeason);
        mockMjdsToSeason(jMockTest, rollTimeOperations, startTimes,
            observingSeason);
        mockPixelLogs(jMockTest, mjdToCadence, cadenceType, startCadence,
            endCadence, lcTargetTableId);
        mockObservingLogs(jMockTest, observingLogModel, cadenceType,
            startCadence, endCadence);

        PdcTimestampSeries series = new PdcTimestampSeries(rollTimeOperations,
            mjdToCadence, observingLogModel, cadenceType, startCadence,
            endCadence, startTimes, midTimes, endTimes, gaps, requantEnabled,
            cadenceNumbers, isSefiAcc, isSefiCad, isLdeOos, isFinePnt,
            isMmntmDmp, isLdeParEr, isScrcErr, dataAnomalyFlags);
        return series;
    }

    private static int mockMjdsToSeason(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, double[] mjds,
        int observingSeason) {

        if (jMockTest != null && rollTimeOperations != null) {
            for (double mjd : mjds) {
                jMockTest.allowing(rollTimeOperations)
                    .mjdToSeason(mjd);
                jMockTest.will(returnValue(observingSeason));
            }
        }
        return observingSeason;
    }

    private static int[] mockMjdsToQuarter(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, double[] mjds,
        int observingSeason) {

        int[] seasons = new int[mjds.length];
        Arrays.fill(seasons, 0, seasons.length, observingSeason);
        if (jMockTest != null && rollTimeOperations != null) {
            jMockTest.allowing(rollTimeOperations)
                .mjdToQuarter(mjds);
            jMockTest.will(returnValue(seasons));
        }
        return seasons;
    }

    private static List<PixelLog> mockPixelLogs(JMockTest jMockTest,
        MjdToCadence mjdToCadence, CadenceType cadenceType, int startCadence,
        int endCadence, int lcTargetTableId) {

        double cadenceLengthDays = 0;
        if (cadenceType == CadenceType.SHORT) {
            cadenceLengthDays = (double) ModifiedJulianDate.SHORT_CADENCE_LENGTH_MINUTES
                / MockUtils.MINUTES_PER_DAY;
        } else {
            cadenceLengthDays = (double) ModifiedJulianDate.CADENCE_LENGTH_MINUTES
                / MockUtils.MINUTES_PER_DAY;
        }

        List<PixelLog> pixelLogs = new ArrayList<PixelLog>();
        Map<Integer, PixelLog> pixelLogByCadence = new HashMap<Integer, PixelLog>();
        for (int cadence = startCadence; cadence <= endCadence; cadence++) {
            // Use the same time that is in TestDataSetDescriptor.
            // Must be in the range (54000, 64000).
            double startMjd = 55553.5 + cadence * cadenceLengthDays;
            double endMjd = startMjd + cadenceLengthDays;
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(DataSetType.Target);
            pixelLog.setLcTargetTableId((short) lcTargetTableId);
            pixelLog.setCadenceNumber(cadence);
            pixelLog.setCadenceType(cadenceType.intValue());
            pixelLog.setMjdStartTime(startMjd);
            pixelLog.setMjdEndTime(endMjd);
            pixelLog.setMjdMidTime(startMjd + cadenceLengthDays / 2);
            pixelLogs.add(pixelLog);
            pixelLogByCadence.put(cadence, pixelLog);
        }

        if (jMockTest != null && mjdToCadence != null) {
            for (int cadence = startCadence; cadence <= endCadence; cadence++) {
                jMockTest.allowing(mjdToCadence)
                    .pixelLogForCadence(cadence);
                jMockTest.will(returnValue(pixelLogByCadence.get(cadence)));
            }
        }

        return pixelLogs;
    }

    public static List<ObservingLog> mockObservingLogs(JMockTest jMockTest,
        ObservingLogModel observingLogModel, CadenceType cadenceType,
        int startCadence, int endCadence) {
        ObservingLog observingLog = new ObservingLog(cadenceType.intValue(),
            startCadence, endCadence, 0, 0, 0, 1, 2, 0);
        List<ObservingLog> observingLogs = Arrays.asList(observingLog);

        if (jMockTest != null && observingLogModel != null) {
            jMockTest.allowing(observingLogModel)
                .observingLogsFor(cadenceType.intValue(), startCadence, endCadence);
            jMockTest.will(returnValue(observingLogs));
        }

        return observingLogs;
    }
}
