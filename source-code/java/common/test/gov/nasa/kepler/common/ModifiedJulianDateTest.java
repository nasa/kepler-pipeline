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

package gov.nasa.kepler.common;

import static gov.nasa.kepler.common.ModifiedJulianDate.dateToMjd;
import static gov.nasa.kepler.common.ModifiedJulianDate.jdToDate;
import static gov.nasa.kepler.common.ModifiedJulianDate.KJD_OFFSET_FROM_MJD;
import static gov.nasa.kepler.common.ModifiedJulianDate.KJD_ZERO_DATE;
import static gov.nasa.kepler.common.ModifiedJulianDate.mjdToDate;
import static gov.nasa.kepler.common.ModifiedJulianDate.mjdToKjd;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;

import org.junit.Test;

public class ModifiedJulianDateTest {

    public static double START_MJD = 55553.5;
    public static double END_MJD = 55644.5;

    public static ModifiedJulianDate mjdZeroPointP1 = new ModifiedJulianDate(
        1858, Calendar.NOVEMBER, 18, 00, 00, 00);
    public static ModifiedJulianDate mjdZeroPointM1 = new ModifiedJulianDate(
        1858, Calendar.NOVEMBER, 16, 00, 00, 00);

    public static String utcHalloween = "2006-10-31 23:59:59.999";


    @Test
    public void constructor() {
        ModifiedJulianDate now = new ModifiedJulianDate();
        ModifiedJulianDate before = new ModifiedJulianDate(2004,
            Calendar.OCTOBER, 9, 13, 6, 0);
        assertTrue(now.after(before));
    }

    @Test
    public void defaultConstructor() {
        ModifiedJulianDate now = new ModifiedJulianDate();
        assertTrue(now.getClass().equals(ModifiedJulianDate.class));
    }

    @Test
    public void getMjd() {
        ModifiedJulianDate twoThousandFour = new ModifiedJulianDate(2004,
            Calendar.OCTOBER, 9, 13, 6, 0);
        double mjd2004 = twoThousandFour.getMjd();
        assertTrue(mjd2004 > 53287 && mjd2004 < 53288);
    }


    @Test
    public void getUtc() {
        ModifiedJulianDate halloween = new ModifiedJulianDate(2006,
            Calendar.OCTOBER, 31, 23, 59, 59, 999);
        assertTrue(utcHalloween.equals(halloween.getUtc()));
    }


    @Test
    public void testMjdToDate() {
        GregorianCalendar mjdZero = new GregorianCalendar(1858,
            Calendar.NOVEMBER, 17, 0, 0, 0);
        mjdZero.setTimeZone(TimeZone.getTimeZone("UTC"));
        GregorianCalendar mjdZeroDate = new GregorianCalendar(
            TimeZone.getTimeZone("UTC"));
        mjdZeroDate.setTimeInMillis(mjdToDate(0).getTime());
        assertEquals(mjdZero, mjdZeroDate);
        assertEquals(0, dateToMjd(mjdZero.getTime()), 0);

        assertEquals("mjd to date and back", START_MJD,
            dateToMjd(mjdToDate(START_MJD)), 0);
    }

    @Test
    public void testDateToMjd() {

        Date startDate = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
            .getTime();
        long startTime = startDate.getTime();
        long endTime = ModifiedJulianDate.mjdToDate(
            ModifiedJulianDate.dateToMjd(startDate)).getTime();

        assertTrue("date to mjd and back", startTime == endTime
            || startTime + 1 == endTime || startTime - 1 == endTime);
    }

    @Test
    public void testMjdToKjd() {
        // Ensure that Kepler epoch constants are consistent with each other.
        assertEquals(KJD_OFFSET_FROM_MJD, KJD_ZERO_DATE.getMjd(), 0);

        assertEquals(0, mjdToKjd(KJD_ZERO_DATE.getMjd()), 0);
        System.out.println(jdToDate(2454833));
        System.out.println(dateToMjd(jdToDate(2454833)));
        System.out.println(mjdToKjd(dateToMjd(jdToDate(2454833))));
        assertEquals(0, mjdToKjd(dateToMjd(jdToDate(2454833))), 0);
    }
}
