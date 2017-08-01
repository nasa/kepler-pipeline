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

package gov.nasa.kepler.dr.thruster;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Sets.newHashSet;
import static gov.nasa.kepler.dr.thruster.ThrusterDataDispatcher.MAX_ERROR_COUNT;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.dr.thruster.ThrusterDataItem.ThrusterMnemonic;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.IOException;
import java.io.StringReader;
import java.util.List;
import java.util.Set;

import org.junit.Test;

/**
 * Tests the {@link ThrusterDataDispatcher} class.
 * 
 * @author Bill Wohler
 */
public class ThrusterDataDispatcherTest extends JMockTest {

    @Test(expected = NullPointerException.class)
    public void testParseNullLine() {
        new ThrusterDataDispatcher().parseLine(null);
    }

    @Test
    public void testParseLine() {
        ThrusterDataDispatcher dispatcher = new ThrusterDataDispatcher();

        ThrusterDataItem item = dispatcher.parseLine("");
        assertNull(item);

        item = dispatcher.parseLine("# This is a comment");
        assertNull(item);

        item = dispatcher.parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
        testItem(item);

        item = dispatcher.parseLine("  56728.00001505  ,  0.0000000000000E+00  ,  1.8000000854954E+00  ,  1.6000000759959E+00  ,  2.0000000949949E-01  ,  5.0000002374873E-01  ,  1.0000000474975E-01  ,  0.0000000000000E+00  ,  1.0000000474975E+00");
        testItem(item);
    }

    private void testItem(ThrusterDataItem item) {
        assertEquals(56728.00001505, item.getSpacecraftTime(), 0);
        assertEquals(0.0000000000000E+00f, item.getThrusterData(1), 0);
        assertEquals(1.8000000854954E+00f, item.getThrusterData(2), 0);
        assertEquals(1.6000000759959E+00f, item.getThrusterData(3), 0);
        assertEquals(2.0000000949949E-01f, item.getThrusterData(4), 0);
        assertEquals(5.0000002374873E-01f, item.getThrusterData(5), 0);
        assertEquals(1.0000000474975E-01f, item.getThrusterData(6), 0);
        assertEquals(0.0000000000000E+00f, item.getThrusterData(7), 0);
        assertEquals(1.0000000474975E+00f, item.getThrusterData(8), 0);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyFields() {
        new ThrusterDataDispatcher().parseLine(",,,,,,,,");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyTime() {
        new ThrusterDataDispatcher().parseLine(",0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster1() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster2() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster3() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster4() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster5() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster6() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster7() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithEmptyThruster8() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadTimeData() {
        new ThrusterDataDispatcher().parseLine("foo,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster1Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,foo,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster2Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,foo,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster3Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,foo,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster4Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,foo,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster5Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,foo,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster6Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,foo,0.0000000000000E+00,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster7Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,foo,1.0000000474975E+00");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseLineWithBadThruster8Data() {
        new ThrusterDataDispatcher().parseLine("56728.00001505,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,foo");
    }

    @Test
    public void testParseFile() {
        try {
            ThrusterDataDispatcher thrusterDataDispatcher = new ThrusterDataDispatcher();
            List<ThrusterDataItem> thrusterDataItems = thrusterDataDispatcher.parseFile(new StringReader(
                generateInputString()));
            assertEquals(3, thrusterDataItems.size());
            assertEquals(56807.602832, thrusterDataItems.get(0)
                .getSpacecraftTime(), 0);
            assertEquals(56807.602925, thrusterDataItems.get(1)
                .getSpacecraftTime(), 0);
            assertEquals(56807.603018, thrusterDataItems.get(2)
                .getSpacecraftTime(), 0);

            thrusterDataItems = thrusterDataDispatcher.parseFile(new StringReader(
                generateInputString(2 * MAX_ERROR_COUNT, 0, 0, 0)));
            assertEquals(3 + 2 * MAX_ERROR_COUNT, thrusterDataItems.size());
            assertEquals(56807.602832, thrusterDataItems.get(0)
                .getSpacecraftTime(), 0);
            assertEquals(56807.602925, thrusterDataItems.get(1)
                .getSpacecraftTime(), 0);
            assertEquals(56807.603018, thrusterDataItems.get(2)
                .getSpacecraftTime(), 0);
            assertEquals(56807.603018,
                thrusterDataItems.get(thrusterDataItems.size() - 1)
                    .getSpacecraftTime(), 0);
        } catch (IOException e) {
            fail("Unexpected IOException");
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseFileWithOneBadLine() throws IOException {
        new ThrusterDataDispatcher().parseFile(new StringReader(
            generateInputString(0, 1, 0, 0)));
    }

    @Test
    public void testParseFileWithMaxMinusOneBadLines() throws IOException {
        try {
            new ThrusterDataDispatcher().parseFile(new StringReader(
                generateInputString(0, MAX_ERROR_COUNT - 1, 0, 0)));
        } catch (IllegalArgumentException e) {
            String[] strings = e.getMessage()
                .split("\n");
            assertEquals(2 * (MAX_ERROR_COUNT - 1), strings.length);
        }
    }

    @Test
    public void testParseFileWithMaxBadLines() throws IOException {
        try {
            new ThrusterDataDispatcher().parseFile(new StringReader(
                generateInputString(0, MAX_ERROR_COUNT, 0, 0)));
        } catch (IllegalArgumentException e) {
            String[] strings = e.getMessage()
                .split("\n");
            assertEquals(2 * MAX_ERROR_COUNT, strings.length);
        }
    }

    @Test
    public void testParseFileWithMaxPlusOneBadLines() throws IOException {
        try {
            new ThrusterDataDispatcher().parseFile(new StringReader(
                generateInputString(0, MAX_ERROR_COUNT + 1, 0, 0)));
        } catch (IllegalArgumentException e) {
            String[] strings = e.getMessage()
                .split("\n");
            assertEquals(2 * MAX_ERROR_COUNT, strings.length);
        }
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseFileWithOneBadTimestamp() throws IOException {
        new ThrusterDataDispatcher().parseFile(new StringReader(
            generateInputString(0, 0, 1, 0)));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseFileWithOneBadThrusterValue() throws IOException {
        new ThrusterDataDispatcher().parseFile(new StringReader(
            generateInputString(0, 0, 0, 1)));
    }

    private String generateInputString() {
        return generateInputString(0, 0, 0, 0);
    }

    private String generateInputString(int extraGoodLines, int extraBadLines,
        int extraBadTimestamps, int extraBadThrusterValues) {
        StringBuilder s = new StringBuilder();

        for (int i = 0; i < extraBadLines; i++) {
            s.append("This is line noise\n");
        }

        s.append(
            "#SPACECRAFT_TIME,KP ADTHR1CNTNIC,KP ADTHR2CNTNIC,KP ADTHR3CNTNIC,KP ADTHR4CNTNIC,KP ADTHR5CNTNIC,KP ADTHR6CNTNIC,KP ADTHR7CNTNIC,KP ADTHR8CNTNIC\n")
            .append("#mjd,SEC,SEC,SEC,SEC,SEC,SEC,SEC,SEC\n")
            .append(
                "56807.602832,3.20800015237182379E+01,1.57160007464699447E+02,1.34900006407406181E+02,1.88000008929520845E+01,9.39800044638104737E+01,3.13200014876201749E+01,1.67400007951073349E+01,1.02040004846639931E+02\n")
            .append(
                "56807.602925,3.20800015237182379E+01,1.57160007464699447E+02,1.34900006407406181E+02,1.88000008929520845E+01,9.39800044638104737E+01,3.13200014876201749E+01,1.67400007951073349E+01,1.02040004846639931E+02\n")
            .append(
                "56807.603018,3.20800015237182379E+01,1.57160007464699447E+02,1.34900006407406181E+02,1.88000008929520845E+01,9.39800044638104737E+01,3.13200014876201749E+01,1.67400007951073349E+01,1.02040004846639931E+02\n");

        for (int i = 0; i < extraGoodLines; i++) {
            s.append("56807.603018,3.20800015237182379E+01,1.57160007464699447E+02,1.34900006407406181E+02,1.88000008929520845E+01,9.39800044638104737E+01,3.13200014876201749E+01,1.67400007951073349E+01,1.02040004846639931E+02\n");
        }
        for (int i = 0; i < extraBadTimestamps; i++) {
            s.append("foo,0.0000000000000E+00,1.8000000854954E+00,1.6000000759959E+00,2.0000000949949E-01,5.0000002374873E-01,1.0000000474975E-01,0.0000000000000E+00,1.0000000474975E+00\n");
        }
        for (int i = 0; i < extraBadThrusterValues; i++) {
            s.append("56728.00015394,0.0000000000000Y+00,1.8000000854954Y+00,1.6000000759959Y+00,2.0000000949949Y-01,5.0000002374873Y-01,1.0000000474975Y-01,0.0000000000000Y+00,1.0000000474975Y+00\n");
        }

        return s.toString();
    }

    @Test
    public void testDispatch() {
        Set<String> filenames = newHashSet();
        filenames.add("foo");
        String sourceDirectory = ".";
        DispatchLog dispatchLog = null;
        DispatcherWrapper dispatcherWrapper = new DispatcherWrapper(null, null,
            null, null);

        ThrusterDataDispatcher thrusterDataDispatcher = new ThrusterDataDispatcher();
        thrusterDataDispatcher.setFileReader(new StringReader(
            generateInputString()));
        thrusterDataDispatcher.setAncillaryOperations(mockAncillaryOperations());
        thrusterDataDispatcher.dispatch(filenames, sourceDirectory,
            dispatchLog, dispatcherWrapper);
    }

    private AncillaryOperations mockAncillaryOperations() {
        AncillaryOperations mockAncillaryOperations = mock(AncillaryOperations.class);
        List<AncillaryEngineeringData> ancillaryEngineeringDataList = newArrayList();
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR1CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                3.20800015237182379E+01F, 3.20800015237182379E+01F,
                3.20800015237182379E+01F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR2CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                1.57160007464699447E+02F, 1.57160007464699447E+02F,
                1.57160007464699447E+02F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR3CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                1.34900006407406181E+02F, 1.34900006407406181E+02F,
                1.34900006407406181E+02F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR4CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                1.88000008929520845E+01F, 1.88000008929520845E+01F,
                1.88000008929520845E+01F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR5CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                9.39800044638104737E+01F, 9.39800044638104737E+01F,
                9.39800044638104737E+01F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR6CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                3.13200014876201749E+01F, 3.13200014876201749E+01F,
                3.13200014876201749E+01F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR7CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                1.67400007951073349E+01F, 1.67400007951073349E+01F,
                1.67400007951073349E+01F });
        addAncillaryEngineeringData(ancillaryEngineeringDataList,
            ThrusterMnemonic.ADTHR8CNTNIC.toString(), new double[] {
                56807.602832, 56807.602925, 56807.603018 }, new float[] {
                1.02040004846639931E+02F, 1.02040004846639931E+02F,
                1.02040004846639931E+02F });
        oneOf(mockAncillaryOperations).storeAncillaryEngineeringData(
            ancillaryEngineeringDataList,
            DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID);

        return mockAncillaryOperations;
    }

    private void addAncillaryEngineeringData(
        List<AncillaryEngineeringData> ancillaryEngineeringDataList,
        String mnemonic, double[] timestamps, float[] values) {

        AncillaryEngineeringData ancillaryEngineeringData = new AncillaryEngineeringData(
            mnemonic);
        ancillaryEngineeringData.setTimestamps(timestamps);
        ancillaryEngineeringData.setValues(values);
        ancillaryEngineeringDataList.add(ancillaryEngineeringData);
    }
}
