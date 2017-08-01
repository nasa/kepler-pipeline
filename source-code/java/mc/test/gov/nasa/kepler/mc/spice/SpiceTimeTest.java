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

package gov.nasa.kepler.mc.spice;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.mc.spice.KeplerSclkTime;
import gov.nasa.kepler.mc.spice.SpiceException;
import gov.nasa.kepler.mc.spice.SpiceTime;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class SpiceTimeTest {

    /**
     * chronos calculations are accurate to one millisecond because the UTC is
     * specified to the millisecond resolution. e.g. 2099-01-01 12:00:00.000.
     */
    static final double CHRONOS_PRECISION_IN_MILLIS = 1E0;
    static final double CHRONOS_PRECISION_IN_SECONDS = CHRONOS_PRECISION_IN_MILLIS / 1000E0;
    static final double CHRONOS_PRECISION_IN_MJDS = CHRONOS_PRECISION_IN_SECONDS
        / SpiceTime.SECONDS_PER_DAY;

    private SimpleDateFormat simpleDateFormat;

    @Before
    public void setUp() {
        simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        simpleDateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from sclk -fromtype sclk
     * -to utc -totype scet -time 1/-1 Could not parse SCLK component from -1 as
     * a number.
     * 
     * @throws Exception
     */
    @Test(expected = SpiceException.class)
    public void testSclkTimeJustBeforeSmallestSclkTime() throws Exception {
        String expectedDateString = "-1";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(-1L, 0L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from sclk -fromtype sclk
     * -to utc -totype scet -time 1/0000000000.000000 2000-01-01 11:58:55.816
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeExactlyAtSmallestSclkTime() throws Exception {
        String expectedDateString = "2000-01-01 11:58:55.816";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(0L, 0L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from sclk -fromtype sclk
     * -to utc -totype scet -time 1/0000000000.000001 2000-01-01 11:58:55.816
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustAfterSmallestSclkTime() throws Exception {
        String expectedDateString = "2000-01-01 11:58:55.816";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(0L, 1L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from sclk -fromtype sclk
     * -to utc -totype scet -time 1/4908535265.183599 2155-09-04 22:39:41.432
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustBeforeLargestSclkTime() throws Exception {
        String expectedDateString = "2155-09-04 22:39:41.432";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(4908535265L,
            183599L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from sclk -fromtype sclk
     * -to utc -totype scet -time 1/4908535265.183600 2155-09-04 22:39:41.432
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeExactlyAtLargestSclkTime() throws Exception {
        String expectedDateString = "2155-09-04 22:39:41.432";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(4908535265L,
            183600L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from sclk -fromtype sclk
     * -to utc -totype scet -time 1/4908535265.183601 SCLK count
     * 1/4908535265.183601 does not fall in the boundaries of partition number
     * 1.
     * 
     * @throws Exception
     */
    @Test(expected = SpiceException.class)
    public void testSclkTimeJustAfterLargestSclkTime() throws Exception {
        String expectedDateString = "-1";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(4908535265L,
            183601L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0189345664.182926 2005-12-31 23:59:59.999
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustBeforeLeapSecondStart() throws Exception {
        String expectedDateString = "2005-12-31 23:59:59.999";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(189345664L,
            182926L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0189345664.183926 2005-12-31 23:59:60.000
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeExactlyAtLeapSecondStart() throws Exception {
        String expectedDateString = "2005-12-31 23:59:60.000";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(189345664L,
            183926L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0189345664.184926 2005-12-31 23:59:60.001
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustAfterLeapSecondStart() throws Exception {
        String expectedDateString = "2005-12-31 23:59:60.001";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(189345664L,
            184926L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0189345665.182926 2005-12-31 23:59:60.999
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustBeforeLeapSecondEnd() throws Exception {
        String expectedDateString = "2005-12-31 23:59:60.999";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(189345665L,
            182926L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0189345665.183926 2006-01-01 00:00:00.000
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeExactlyAtLeapSecondEnd() throws Exception {
        String expectedDateString = "2006-01-01 00:00:00.000";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(189345665L,
            183926L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0189345665.184926 2006-01-01 00:00:00.001
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustAfterLeapSecondEnd() throws Exception {
        String expectedDateString = "2006-01-01 00:00:00.001";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(189345665L,
            184926L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0268154697.762340 2008-07-01 03:23:52.578
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustBeforeSclkAdjustmentBackwardInTime()
        throws Exception {
        String expectedDateString = "2008-07-01 03:23:52.578";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(268154697L,
            762340L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0268154697.763340 2008-06-28 00:00:00.000
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeExactlyAtSclkAdjustmentBackwardInTime()
        throws Exception {
        String expectedDateString = "2008-06-28 00:00:00.000";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(268154697L,
            763340L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0268154697.764340 2008-06-28 00:00:00.001
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustAfterSclkAdjustmentBackwardInTime()
        throws Exception {
        String expectedDateString = "2008-06-28 00:00:00.001";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(268154697L,
            764340L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0468154697.762340 2014-10-27 11:19:14.232
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustBeforeSclkAdjustmentForwardInTime()
        throws Exception {
        String expectedDateString = "2014-10-27 11:19:14.232";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(468154697L,
            762340L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0468154697.763340 2014-10-28 15:05:54.233
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeExactlyAtSclkAdjustmentForwardInTime()
        throws Exception {
        String expectedDateString = "2014-10-28 15:05:54.233";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(468154697L,
            763340L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from sclk -fromtype sclk -to
     * utc -totype scet -time 1/0468154697.764340 2014-10-28 15:05:54.234
     * (UTC/SCET)
     * 
     * @throws Exception
     */
    @Test
    public void testSclkTimeJustAfterSclkAdjustmentForwardInTime()
        throws Exception {
        String expectedDateString = "2014-10-28 15:05:54.234";
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(468154697L,
            764340L);

        testGetMjd(expectedDateString, inputKeplerSclkTime);
    }

    private void testGetMjd(String expectedDateString,
        KeplerSclkTime inputKeplerSclkTime) throws Exception, ParseException {

        SpiceTime spiceTime = new SpiceTime(FcConstants.J2000_MJD,
            SpiceKernelFileReaderTest.SPACECRAFT_CLOCK_KERNEL_FILE,
            SpiceKernelFileReaderTest.LEAP_SECONDS_KERNEL_FILE);
        double actualMjd = spiceTime.getMjd(inputKeplerSclkTime);
        Date actualDate = ModifiedJulianDate.mjdToDate(actualMjd);

        Date expectedDate;
        expectedDate = simpleDateFormat.parse(expectedDateString);

        double expectedMjd = ModifiedJulianDate.dateToMjd(expectedDate);
        assertEquals(expectedMjd, actualMjd, CHRONOS_PRECISION_IN_MJDS);
        assertEquals(expectedDate.getTime(), actualDate.getTime(),
            CHRONOS_PRECISION_IN_MILLIS);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from utc -fromtype scet
     * -to sclk -totype sclk -time 2000-01-01 11:58:55.816 Invalid value of ET.
     * Value was -7.2737133821675E-05.
     * 
     * @throws Exception
     */
    @Test(expected = SpiceException.class)
    public void testMjdJustBeforeSmallestMjd() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(4242L, 4242L);
        String inputDateString = "2000-01-01 11:58:55.816";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from utc -fromtype scet
     * -to sclk -totype sclk -time 2000-01-01 11:58:55.817 1/0000000000.000927
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtSmallestMjd() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(0L, 927L);
        String inputDateString = "2000-01-01 11:58:55.817";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from utc -fromtype scet
     * -to sclk -totype sclk -time 2000-01-01 11:58:55.818 1/0000000000.001927
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustAfterSmallestMjd() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(0L, 1927L);
        String inputDateString = "2000-01-01 11:58:55.818";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from utc -fromtype scet
     * -to sclk -totype sclk -time 2155-9-04 22:39:41.431 1/4908535265.182230
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustBeforeLargestMjd() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(4908535265L,
            182230L);
        String inputDateString = "2155-9-04 22:39:41.431";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from utc -fromtype scet
     * -to sclk -totype sclk -time 2155-9-04 22:39:41.432 1/4908535265.183228
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtLargestMjd() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(4908535265L,
            183228L);
        String inputDateString = "2155-9-04 22:39:41.432";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/test-data/common/spice/setup.mpf -from utc -fromtype scet
     * -to sclk -totype sclk -time 2155-9-04 22:39:41.433 Invalid value of ET.
     * Value was 4.9126560476156E+09.
     * 
     * @throws Exception
     */
    @Test(expected = SpiceException.class)
    public void testMjdJustAfterLargestMjd() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(4242L, 4242L);
        String inputDateString = "2155-9-04 22:39:41.433";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2005-12-31 23:59:59.999 1/0189345664.182926
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustBeforeLeapSecond() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(189345664L,
            182926L);
        String inputDateString = "2005-12-31 23:59:59.999";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2006-01-01 00:00:01.000 1/0189345666.183926
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtLeapSecond() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(189345666L,
            183926L);
        String inputDateString = "2006-01-01 00:00:01.000";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2006-01-01 00:00:01.001 1/0189345666.184926
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustAfterLeapSecond() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(189345666L,
            184926L);
        String inputDateString = "2006-01-01 00:00:01.001";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2008-06-28 00:00:00.000 1/0267883265.184188
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustBeforeStartOfDuplicateUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(267883265L,
            184188L);
        String inputDateString = "2008-06-28 00:00:00.000";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2008-06-28 00:00:00.000 1/0267883265.184188
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtStartOfDuplicateUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(267883265L,
            184188L);
        String inputDateString = "2008-06-28 00:00:00.000";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2008-06-28 00:00:00.000 1/0267883265.184188
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustAfterStartOfDuplicateUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(267883265L,
            184188L);
        String inputDateString = "2008-06-28 00:00:00.000";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2008-07-01 03:23:52.578 1/0268426405.370169
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustBeforeEndOfDuplicateUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(268426405L,
            370169L);
        String inputDateString = "2008-07-01 03:23:52.578";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2008-07-01 03:23:52.578 1/0268426405.370169
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtEndOfDuplicateUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(268426405L,
            370169L);
        String inputDateString = "2008-07-01 03:23:52.578";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2008-07-01 03:23:52.578 1/0268426405.370169
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustAfterEndOfDuplicateUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(268426405L,
            370169L);
        String inputDateString = "2008-07-01 03:23:52.578";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2014-10-27 11:19:14.232 1/0468154697.762553
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustBeforeStartOfSkippedUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(468154697L,
            762553L);
        String inputDateString = "2014-10-27 11:19:14.232";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2014-10-27 11:19:14.232 1/0468154697.762553
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtStartOfSkippedUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(468154697L,
            762553L);
        String inputDateString = "2014-10-27 11:19:14.232";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2014-10-27 11:19:14.232 1/0468154697.762553
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustAfterStartOfSkippedUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(468154697L,
            762553L);
        String inputDateString = "2014-10-27 11:19:14.232";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2014-10-28 15:05:54.233 1/0468154697.763572
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustBeforeEndOfSkippedUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(468154697L,
            763572L);
        String inputDateString = "2014-10-28 15:05:54.233";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2014-10-28 15:05:54.233 1/0468154697.763572
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdExactlyAtEndOfSkippedUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(468154697L,
            763572L);
        String inputDateString = "2014-10-28 15:05:54.233";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    /**
     * $ ./chronos -setup
     * /path/to/spice-files/setup.mpf -from utc -fromtype scet -to
     * sclk -totype sclk -time 2014-10-28 15:05:54.233 1/0468154697.763572
     * (SCLK/SCLK)
     * 
     * @throws Exception
     */
    @Test
    public void testMjdJustAfterEndOfSkippedUtcs() throws Exception {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(468154697L,
            763572L);
        String inputDateString = "2014-10-28 15:05:54.233";

        testGetKeplerSclkTime(expectedKeplerSclkTime, inputDateString);
    }

    private void testGetKeplerSclkTime(KeplerSclkTime expectedKeplerSclkTime,
        String inputDateString) throws Exception, ParseException {
        Date inputDate;
        inputDate = simpleDateFormat.parse(inputDateString);
        double inputMjd = ModifiedJulianDate.dateToMjd(inputDate);

        SpiceTime spiceTime = new SpiceTime(FcConstants.J2000_MJD,
            SpiceKernelFileReaderTest.SPACECRAFT_CLOCK_KERNEL_FILE,
            SpiceKernelFileReaderTest.LEAP_SECONDS_KERNEL_FILE);
        KeplerSclkTime actualKeplerSclkTime = spiceTime.getKeplerSclkTime(inputMjd);

        assertEquals(expectedKeplerSclkTime.getSeconds(),
            actualKeplerSclkTime.getSeconds(), CHRONOS_PRECISION_IN_SECONDS);
    }

}
