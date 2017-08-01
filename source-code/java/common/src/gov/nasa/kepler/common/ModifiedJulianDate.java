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

import gov.nasa.spiffy.common.collect.Pair;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;

public class ModifiedJulianDate extends GregorianCalendar {

    /**
     * 
     */
    private static final long serialVersionUID = -1199626129141969115L;

    // Statics:
    /**
     * This is the MJD offset from JD. In order to get JD add this number to JD.
     */
    public static final double MJD_OFFSET_FROM_JD = 2400000.5;
    private static final ModifiedJulianDate MJD_ZERO_DATE = new ModifiedJulianDate(
        1858, NOVEMBER, 17, 0, 0, 0, 0);
    public static double KJD_OFFSET_FROM_MJD = 54832.5;
    static final ModifiedJulianDate KJD_ZERO_DATE = new ModifiedJulianDate(
        2009, JANUARY, 1, 12, 0, 0, 0);
    private static final ModifiedJulianDate UNIX_EPOCH_DATE = new ModifiedJulianDate(
        1970, JANUARY, 1, 0, 0, 0, 0);

    public static final long CADENCE_LENGTH_MINUTES = 30;
    public static final long SHORT_CADENCE_LENGTH_MINUTES = 1;
    public static final int SHORT_CADENCES_PER_LONG = (int) (CADENCE_LENGTH_MINUTES / SHORT_CADENCE_LENGTH_MINUTES);

    public static double MJD_BEFORE_MISSION_STARTS = 0.0;
    public static double MJD_AFTER_MISSION_ENDS = 100000.0;
     
    /**
     * 
     * @return  The whole number part, before the decimal, of the start of the
     * Kepler epoch (BKJD) in JD
     */
    public static int kjdReferenceIntegerPart() {
        return (int) Math.floor(mjdToJd(ModifiedJulianDate.KJD_OFFSET_FROM_MJD));
    }
    
    /**
     * 
     * @return The fractional part, after the decimal, of the start of the 
     * Kepler epoch (BKJD) in JD.
     */
    public static double kjdReferenceFractionalPart() {
        double startOfKeplerEpochInJd = ModifiedJulianDate.mjdToJd(ModifiedJulianDate.KJD_OFFSET_FROM_MJD);
        return startOfKeplerEpochInJd - (double) (int) startOfKeplerEpochInJd;
    }

    public static ModifiedJulianDate valueOf(String ymdhmss)
        throws ParseException {
        Date d = dateFormat().parse(ymdhmss);
        ModifiedJulianDate rv = new ModifiedJulianDate();
        rv.setTime(d);
        return rv;
    }

    public static Date mjdToDate(int mjd) {
        return jdToDate(mjd + MJD_OFFSET_FROM_JD);
    }

    public static Date mjdToDate(double mjd) {
        return jdToDate(mjd + MJD_OFFSET_FROM_JD);
    }

    public static Date jdToDate(long jd) {
        return jdToDate((double) jd);
    }

    /**
     * Convert seconds since Kepler epoch to a MJD double.
     * 
     * @param secondsSinceKeplerEpoch
     * @return Modified Julian Date
     */
    public static double secondsSinceKeplerEpochToMjd(
        double secondsSinceKeplerEpoch) {
        double mjd = secondsSinceKeplerEpoch / 3600.0 / 24.0
            + KJD_OFFSET_FROM_MJD;
        return mjd;
    }

    public static double mjdToKjd(double mjd) {
        return mjd - KJD_OFFSET_FROM_MJD;
    }

    public static double mjdToJd(double mjd) {
        return mjd + MJD_OFFSET_FROM_JD;
    }

    /**
     * Converts a Julian date (not a modified Julian date) to a java Date
     * object.
     * 
     * @param jd
     * @return
     */
    public static Date jdToDate(double jd) {
        double mjd = jd - MJD_OFFSET_FROM_JD;
        long mjdMsec = (long) (mjd * 24.0 * 3600.0 * 1000.0);
        long offsetMsec = mjdMsec - UNIX_EPOCH_DATE.getTimeInMillis()
            + MJD_ZERO_DATE.getTimeInMillis();
        ModifiedJulianDate outMjd = new ModifiedJulianDate(offsetMsec);
        return outMjd.getTime();
    }

    /**
     * Convert a java Date object to the corresponding MJD.
     * 
     * @param date
     * @return
     */
    public static double dateToMjd(Date date) {
        long msec = date.getTime();
        long msecSinceMjd = msec + UNIX_EPOCH_DATE.getTimeInMillis()
            - MJD_ZERO_DATE.getTimeInMillis();
        double mjd = msecSinceMjd / 1000.0 / 3600.0 / 24.0;
        return mjd;
    }

    /**
     * MJD constructor
     * 
     */
    public ModifiedJulianDate() {
        setTimeZone(TimeZone.getTimeZone("UTC"));
        set(DST_OFFSET, 0);
        setLenient(false);
    }

    public ModifiedJulianDate(long epochMilliseconds) {
        setTimeZone(TimeZone.getTimeZone("UTC"));
        set(DST_OFFSET, 0);
        setTimeInMillis(epochMilliseconds);
        setLenient(false);
    }

    public ModifiedJulianDate(double mjd) {
        setTimeZone(TimeZone.getTimeZone("UTC"));
        set(DST_OFFSET, 0);
        long millisec = (long) (24.0 * 3600.0 * 1000.0 * mjd);
        millisec += MJD_ZERO_DATE.getTimeInMillis();
        setTimeInMillis(millisec);
        setLenient(false);

    }

    public ModifiedJulianDate(int year, int month, int day, int hour,
        int minute, int second, int msecond) {
        setTimeZone(TimeZone.getTimeZone("UTC"));
        setLenient(false);
        setYMDHMS(year, month, day, hour, minute, second);
        set(MILLISECOND, msecond);
    }

    public ModifiedJulianDate(int year, int month, int day, int hour,
        int minute, int second) {
        setTimeZone(TimeZone.getTimeZone("UTC"));
        setLenient(false);
        setYMDHMS(year, month, day, hour, minute, second);
    }

    private void setYMDHMS(int year, int month, int day, int hour, int minute,
        int second) {
        set(YEAR, year);
        set(MONTH, month);
        set(DAY_OF_MONTH, day);
        set(HOUR_OF_DAY, hour);
        set(MINUTE, minute);
        set(SECOND, second);
        set(ZONE_OFFSET, 0);
        set(DST_OFFSET, 0);
        complete();
    }

    public double getMjd() {
        double nowMillisec = getTimeInMillis();
        double mjdMillisec = MJD_ZERO_DATE.getTimeInMillis();

        return (nowMillisec - mjdMillisec) / 1000.0 / 3600.0 / 24.0;
    }

    public double getJd() {
        return getMjd() + MJD_OFFSET_FROM_JD;
    }

    public String getUtc() {
        return toStringYMDHMS();
    }

    @Override
    public String toString() {
        return toStringYMDHMS();
    }

    public String toStringYMDHMS() {
        return dateFormat().format(getTime());
    }

    public void printMe() {
        System.out.println(toString());
    }

    public static DateFormat dateFormat() {
        SimpleDateFormat ymdhmsFormat = new SimpleDateFormat(
            "yyyy-MM-dd HH:mm:ss.SSS");
        ymdhmsFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        return ymdhmsFormat;
    }

    /**
     * Convert a long cadence range into a short cadence range. This method is
     * intended for use in tests where the assumption that both the short and
     * long cadences values started at zero is not a problem.
     * 
     * @param longCadenceRange
     * @return the corresponding short cadence range.
     */
    public static Pair<Integer, Integer> longToShortCadences(
        Pair<Integer, Integer> longCadenceRange) {

        int startCadence = longCadenceRange.left * SHORT_CADENCES_PER_LONG;
        int endCadence = (longCadenceRange.right + 1) * SHORT_CADENCES_PER_LONG
            - 1;
        return Pair.of(startCadence, endCadence);
    }

    /**
     * Convert a short cadence range into a long cadence range. This method is
     * intended for use in tests where the assumption that both the short and
     * long cadences values started at zero is not a problem.
     * 
     * @param shortCadenceRange
     * @return the corresponding long cadence range.
     */
    public static Pair<Integer, Integer> shortToLongCadences(
        Pair<Integer, Integer> shortCadenceRange) {

        int startCadence = shortCadenceRange.left / SHORT_CADENCES_PER_LONG;
        int endCadence = (shortCadenceRange.right + 1)
            / SHORT_CADENCES_PER_LONG - 1;
        return Pair.of(startCadence, endCadence);
    }
}
