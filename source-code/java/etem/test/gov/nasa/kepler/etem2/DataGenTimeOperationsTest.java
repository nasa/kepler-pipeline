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

package gov.nasa.kepler.etem2;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;

import java.text.ParseException;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class DataGenTimeOperationsTest {

    private static final String P1_START_DATE = "17-Mar-2009 17:30:04.33080";
    private static final String P2_START_DATE = "17-Mar-2009 18:28:55.26660";
    private static final String P3_START_DATE = "15-Apr-2009 14:56:15.94140";
    private static final String P4_START_DATE = "17-Apr-2009 16:28:08.19930";
    private static final String P5_START_DATE = "15-Apr-2009 14:56:15.94140";
    private static final String P6_START_DATE = "19-May-2009 15:27:59.99490";
    private static final String P7_START_DATE = "19-May-2009 15:27:59.99490";
    private static final String P8_START_DATE = "20-May-2009 15:00:22.45410";
    private static final String TA_END_DATE = "16-Apr-2009 17:25:43.973";
    private static final String TB_END_DATE = "16-Apr-2009 17:25:43.973";
    private static final String TC_END_DATE = "18-May-2009 17:53:52.189";
    private static final String TD_END_DATE = "16-Apr-2009 17:25:43.973";
    private static final String TX_END_DATE = "17-Mar-2009 17:30:04.33080";

    private static final int P1_EXPECTED_LONG_CADENCE = 0;
    private static final int P2_EXPECTED_LONG_CADENCE = 2;
    private static final int P3_EXPECTED_LONG_CADENCE = 1414;
    private static final int P4_EXPECTED_LONG_CADENCE = 1515;
    private static final int P5_EXPECTED_LONG_CADENCE = 1414;
    private static final int P6_EXPECTED_LONG_CADENCE = 3079;
    private static final int P7_EXPECTED_LONG_CADENCE = 3079;
    private static final int P8_EXPECTED_LONG_CADENCE = 3127;
    private static final int TA_END_EXPECTED_LONG_CADENCE = 1468;
    private static final int TB_END_EXPECTED_LONG_CADENCE = 1468;
    private static final int TC_END_EXPECTED_LONG_CADENCE = 3035;
    private static final int TD_END_EXPECTED_LONG_CADENCE = 1468;
    private static final int TX_END_EXPECTED_LONG_CADENCE = 0;

    @Test
    public void testGetCadenceAndGetMatlabDateRoundTripLongCadence()
        throws ParseException {
        int cadence = 42;

        int cadenceConvertedThroughMatlabDate = convertToMatlabDateAndBack(
            CadenceType.LONG, cadence);

        assertEquals(cadence, cadenceConvertedThroughMatlabDate);
    }

    @Test
    public void testGetCadenceAndGetMatlabDateRoundTripShortCadence()
        throws ParseException {
        int cadence = 69738;

        int cadenceConvertedThroughMatlabDate = convertToMatlabDateAndBack(
            CadenceType.SHORT, cadence);

        assertEquals(cadence, cadenceConvertedThroughMatlabDate);
    }

    private int convertToMatlabDateAndBack(CadenceType cadenceType, int cadence)
        throws ParseException {
        DataGenTimeOperations dataGenTimeOperations = new DataGenTimeOperations();

        DataGenParameters dataGenParameters = new DataGenParameters();
        dataGenParameters.setCadenceZeroDate("30-Apr-2009 00:00:00.000");

        PlannedSpacecraftConfigParameters plannedSpacecraftConfigParameters = new PlannedSpacecraftConfigParameters();
        plannedSpacecraftConfigParameters.setShortCadencesPerLongCadence(30);
        plannedSpacecraftConfigParameters.setFgsFramesPerIntegration(58);
        plannedSpacecraftConfigParameters.setMillisecondsPerFgsFrame(103.7897052288);
        plannedSpacecraftConfigParameters.setMillisecondsPerReadout(518.948526144);
        plannedSpacecraftConfigParameters.setIntegrationsPerShortCadence(9);

        String matlabDate = dataGenTimeOperations.getMatlabDate(
            dataGenParameters, plannedSpacecraftConfigParameters, cadenceType,
            cadence);

        int cadenceToReturn = dataGenTimeOperations.getCadence(
            dataGenParameters, plannedSpacecraftConfigParameters, cadenceType,
            matlabDate);

        return cadenceToReturn;
    }

    @Test
    public void testGetMatlabDateAndGetCadenceRoundTripLongCadence()
        throws ParseException {
        String matlabDate = "16-Jun-2009 12:11:41.209";

        String matlabDateConvertedThroughLongCadence = convertToCadenceAndBack(
            CadenceType.LONG, matlabDate);

        assertEquals(matlabDate, matlabDateConvertedThroughLongCadence);
    }

    @Test
    public void testGetMatlabDateAndGetCadenceRoundTripShortCadence()
        throws ParseException {
        String matlabDate = "16-Jun-2009 12:11:41.209";

        String matlabDateConvertedThroughShortCadence = convertToCadenceAndBack(
            CadenceType.SHORT, matlabDate);

        assertEquals(matlabDate, matlabDateConvertedThroughShortCadence);
    }

    @Test
    public void testMatlabDatesForEachQuarter() throws ParseException {
        testMatlabDatesForEachQuarterInternal("01-May-2009 11:47:58.790");
        testMatlabDatesForEachQuarterInternal("12-May-2009 12:07:43.286");
        testMatlabDatesForEachQuarterInternal("16-Jun-2009 12:11:41.209");
        testMatlabDatesForEachQuarterInternal("17-Sep-2009 12:02:02.803");
        testMatlabDatesForEachQuarterInternal("17-Dec-2009 11:48:49.034");
        testMatlabDatesForEachQuarterInternal("20-Mar-2010 12:08:36.091");
        testMatlabDatesForEachQuarterInternal("24-Jun-2010 12:04:20.729");
        testMatlabDatesForEachQuarterInternal("24-Sep-2010 11:52:54.642");
    }

    private void testMatlabDatesForEachQuarterInternal(String matlabDate)
        throws ParseException {
        String matlabDateConvertedThroughLongCadence = convertToCadenceAndBack(
            CadenceType.LONG, matlabDate);

        assertEquals(matlabDate, matlabDateConvertedThroughLongCadence);
    }

    private String convertToCadenceAndBack(CadenceType cadenceType,
        String matlabDate) throws ParseException {
        DataGenTimeOperations dataGenTimeOperations = new DataGenTimeOperations();

        DataGenParameters dataGenParameters = new DataGenParameters();
        dataGenParameters.setCadenceZeroDate("30-Apr-2009 00:00:00.000");

        PlannedSpacecraftConfigParameters plannedSpacecraftConfigParameters = new PlannedSpacecraftConfigParameters();
        plannedSpacecraftConfigParameters.setShortCadencesPerLongCadence(30);
        plannedSpacecraftConfigParameters.setFgsFramesPerIntegration(58);
        plannedSpacecraftConfigParameters.setMillisecondsPerFgsFrame(103.7897052288);
        plannedSpacecraftConfigParameters.setMillisecondsPerReadout(518.948526144);
        plannedSpacecraftConfigParameters.setIntegrationsPerShortCadence(9);

        int cadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, cadenceType, matlabDate);

        String matlabDateToReturn = dataGenTimeOperations.getMatlabDate(
            dataGenParameters, plannedSpacecraftConfigParameters, cadenceType,
            cadence);

        return matlabDateToReturn;
    }

    @Test
    public void testGsit5aDates() throws ParseException {
        DataGenTimeOperations dataGenTimeOperations = new DataGenTimeOperations();

        DataGenParameters dataGenParameters = new DataGenParameters();
        dataGenParameters.setCadenceZeroDate(P1_START_DATE);
        PlannedSpacecraftConfigParameters plannedSpacecraftConfigParameters = new PlannedSpacecraftConfigParameters();
        plannedSpacecraftConfigParameters.setShortCadencesPerLongCadence(30);
        plannedSpacecraftConfigParameters.setFgsFramesPerIntegration(58);
        plannedSpacecraftConfigParameters.setMillisecondsPerFgsFrame(103.7897052288);
        plannedSpacecraftConfigParameters.setMillisecondsPerReadout(518.948526144);
        plannedSpacecraftConfigParameters.setIntegrationsPerShortCadence(9);

        int p1LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P1_START_DATE);
        assertEquals(P1_EXPECTED_LONG_CADENCE, p1LongCadence);

        int p2LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P2_START_DATE);
        assertEquals(P2_EXPECTED_LONG_CADENCE, p2LongCadence);

        int p3LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P3_START_DATE);
        assertEquals(P3_EXPECTED_LONG_CADENCE, p3LongCadence);

        int p4LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P4_START_DATE);
        assertEquals(P4_EXPECTED_LONG_CADENCE, p4LongCadence);

        int p5LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P5_START_DATE);
        assertEquals(P5_EXPECTED_LONG_CADENCE, p5LongCadence);

        int p6LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P6_START_DATE);
        assertEquals(P6_EXPECTED_LONG_CADENCE, p6LongCadence);

        int p7LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P7_START_DATE);
        assertEquals(P7_EXPECTED_LONG_CADENCE, p7LongCadence);

        int p8LongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, P8_START_DATE);
        assertEquals(P8_EXPECTED_LONG_CADENCE, p8LongCadence);

        int txLongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, TX_END_DATE);
        assertEquals(TX_END_EXPECTED_LONG_CADENCE, txLongCadence);

        int taLongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, TA_END_DATE);
        assertEquals(TA_END_EXPECTED_LONG_CADENCE, taLongCadence);

        int tbLongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, TB_END_DATE);
        assertEquals(TB_END_EXPECTED_LONG_CADENCE, tbLongCadence);

        int tcLongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, TC_END_DATE);
        assertEquals(TC_END_EXPECTED_LONG_CADENCE, tcLongCadence);

        int tdLongCadence = dataGenTimeOperations.getCadence(dataGenParameters,
            plannedSpacecraftConfigParameters, CadenceType.LONG, TD_END_DATE);
        assertEquals(TD_END_EXPECTED_LONG_CADENCE, tdLongCadence);
    }

}
