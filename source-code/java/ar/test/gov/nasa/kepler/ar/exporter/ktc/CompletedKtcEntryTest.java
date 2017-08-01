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

package gov.nasa.kepler.ar.exporter.ktc;

import static gov.nasa.kepler.hibernate.tad.TargetTable.TargetType.LONG_CADENCE;
import static gov.nasa.kepler.hibernate.tad.TargetTable.TargetType.SHORT_CADENCE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.cli.CliUtils;
import gov.nasa.kepler.hibernate.tad.KtcInfo;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.Date;

import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class CompletedKtcEntryTest {

    @Test
    public void testCompletedKtcEntryCompareTo() throws Exception {
        double start = 0.0;
        double end = 1.0;
        int fakeExternalId = 1;
        int fakeTargetTableId = 1;
        Date initialDataTake = CliUtils.parseDate("2009-04-29");
        Date roughEndQ3 = CliUtils.parseDate("2009-12-01");

        // Order by kepler id.
        KtcInfo ktcInfo0 = new KtcInfo(0, LONG_CADENCE, initialDataTake,
            roughEndQ3, 1, fakeExternalId, fakeTargetTableId);
        CompletedKtcEntry c0 = new CompletedKtcEntry(ktcInfo0, "PLANETARY",
            start, end, "DONTMESSWITHPI");

        KtcInfo ktcInfo1 = new KtcInfo(1, LONG_CADENCE, initialDataTake,
            roughEndQ3, 1, fakeExternalId, fakeTargetTableId);
        CompletedKtcEntry c1 = new CompletedKtcEntry(ktcInfo1, "PLANETARY",
            start, end, "DONTMESSWITHPI");
        assertTrue(c0.compareTo(c1) < 0);
        assertTrue(c1.compareTo(c0) > 0);
        assertTrue(c0.equals(c0));
        assertTrue(c1.equals(c1));
        assertFalse(c0.equals(c1));
        assertFalse(c1.equals(c0));
        assertEquals(0, c0.compareTo(c0));
        assertFalse(c1.hashCode() == c0.hashCode());

        // Order by cadence type.
        KtcInfo ktcInfo2 = new KtcInfo(0, SHORT_CADENCE, initialDataTake,
            roughEndQ3, 1, fakeExternalId, fakeTargetTableId);
        CompletedKtcEntry c2 = new CompletedKtcEntry(ktcInfo2, "PLANETARY",
            start, end, "DONTMESSWITHPI");
        assertTrue(c0.compareTo(c2) < 0);
        assertTrue(c2.compareTo(c0) > 0);

        // Order by planned start.
        Date differentPlannedStart = CliUtils.parseDate("2009-04-30");
        Date differentPlannedEnd = CliUtils.parseDate("2010-01-01");
        KtcInfo ktcInfo3 = new KtcInfo(0, LONG_CADENCE, differentPlannedStart,
            roughEndQ3, 1, fakeExternalId, fakeTargetTableId);
        CompletedKtcEntry c3 = new CompletedKtcEntry(ktcInfo3, "PLANETARY",
            start, end, "DONTMESSWITHPI");
        assertTrue(c3.compareTo(c0) > 0);
        assertTrue(c0.compareTo(c3) < 0);

        KtcInfo ktcInfo4 = new KtcInfo(0, LONG_CADENCE, initialDataTake,
            differentPlannedEnd, 1, fakeExternalId, fakeTargetTableId);
        CompletedKtcEntry c4 = new CompletedKtcEntry(ktcInfo4, "PLANETARY",
            start, end, "DONTMESSWITHPI");
        assertTrue(c4.compareTo(c0) > 0);
        assertTrue(c0.compareTo(c4) < 0);

        // Order by having actual times vs. not having actual times.
        KtcInfo ktcInfo5 = new KtcInfo(0, LONG_CADENCE, initialDataTake,
            differentPlannedEnd, 1, fakeExternalId, fakeTargetTableId);
        CompletedKtcEntry c5 = new CompletedKtcEntry(ktcInfo5, "PLANETARY",
            null, null, "DONTMESSWITHPI");
        assertTrue(c5.compareTo(c0) > 0);
        assertTrue(c0.compareTo(c5) < 0);
        assertEquals(0, c5.compareTo(c5));

        // Order by actual times
        CompletedKtcEntry c6 = new CompletedKtcEntry(ktcInfo0, "PLANETARY",
            start - 1, end, "DONTMESSWITHPI");
        assertTrue(c6.compareTo(c0) < 0);
        assertTrue(c0.compareTo(c6) > 0);

        CompletedKtcEntry c7 = new CompletedKtcEntry(ktcInfo0, "PLANETARY",
            start, end + 1, "DONTMESSWITHPI");
        assertTrue(c7.compareTo(c0) > 0);
        assertTrue(c0.compareTo(c7) < 0);

        // Order by category
        CompletedKtcEntry c8 = new CompletedKtcEntry(ktcInfo0, "ASTERO", start,
            end, "DONTMESSWITHPI");
        assertTrue(c8.compareTo(c0) < 0);
        assertTrue(c0.compareTo(c8) > 0);

        // Order by investigation id
        CompletedKtcEntry c9 = new CompletedKtcEntry(ktcInfo0, "PLANETARY",
            start, end, "BLAH");
        assertTrue(c9.compareTo(c0) < 0);
        assertTrue(c0.compareTo(c9) > 0);
    }

    @Test
    public void testParse() {
        final CompletedKtcEntry ktcEntry = new CompletedKtcEntry("category",
            1.1, 2.2, "investigation", 3.3, 4.4, 5, TargetType.LONG_CADENCE);

        final String lineFromFile = "5|LC|category|3.3|4.4|1.1|2.2|investigation";
        CompletedKtcEntry actualKtcEntry = CompletedKtcEntry.parseInstance(lineFromFile);

        assertEquals(ktcEntry, actualKtcEntry);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseIncorrectNumberOfFields() {
        final String lineFromFile = "5|LC|category|3.3|4.4|";
        CompletedKtcEntry.parseInstance(lineFromFile);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testParseIncorrectTypeOfFields() {
        final String lineFromFile = "a|LC|category|b|c|d|e|investigation";
        CompletedKtcEntry.parseInstance(lineFromFile);
    }

    @Test
    public void testParseActualTimesBothNull() {
        final CompletedKtcEntry ktcEntry = new CompletedKtcEntry("category",
            null, null, "investigation", 3.3, 4.4, 5, TargetType.LONG_CADENCE);

        final String lineFromFile = "5|LC|category|3.3|4.4|||investigation";
        CompletedKtcEntry actualKtcEntry = CompletedKtcEntry.parseInstance(lineFromFile);

        assertEquals(ktcEntry, actualKtcEntry);
    }

    @Test(expected = NullPointerException.class)
    public void testParseActualStartIsNull() {
        final String lineFromFile = "5|LC|category|3.3|4.4||2.2|investigation";
        CompletedKtcEntry.parseInstance(lineFromFile);
    }

}
