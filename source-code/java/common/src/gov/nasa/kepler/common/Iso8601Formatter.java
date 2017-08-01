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

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

/**
 * A date formatter that parses and emits ISO 8601 dates in UTC. The formats
 * used in this class include date:yyyy-MM-dd; dateTime: yyyy-MM-ddTHH:mm:ssZ;
 * dateTimeMillis: yyyyMMddTHHmmss,SSSZ; and relaxedDateTime: yyyy-MM-dd
 * HH:mm:ss. Use this formatter to keep the dates uniform throughout.
 * <p>
 * Usage is via the static methods {@link #dateFormatter()},
 * {@link #dateTimeFormatter()}, {@link #dateTimeMillisFormatter()} and
 * {@link #relaxedDateTimeFormatter()}. DO NOT SHARE THE RETURNED INSTANCES
 * BETWEEN THREADS as they are not thread-safe (see {@link DateFormat}).
 * <p>
 * See <a
 * href="http://nlp.fi.muni.cz/nlp/files/iso8601.txt">http://nlp.fi.muni.cz/nlp/files/iso8601.txt</a>.
 * 
 * @author Bill Wohler
 */
public class Iso8601Formatter {

    /** The {@link SimpleDateFormat} format string for a date-only formatter. */
    private static final String DATE_FORMAT_STRING = "yyyy-MM-dd";

    /**
     * The {@link SimpleDateFormat} format string for a combined date/time
     * formatter.
     */
    private static final String DATE_TIME_FORMAT_STRING = "yyyy-MM-dd'T'HH:mm:ss'Z'";

    /**
     * The {@link SimpleDateFormat} format string for a combined date/time
     * formatter with millisecond precision. This format lacks dashes and
     * colons.
     */
    private static final String DATE_TIME_MILLIS_FORMAT_STRING = "yyyyMMdd'T'HHmmss,SSS'Z'";

    /**
     * The {@link SimpleDateFormat} format string for a combined date/time
     * formatter. This formatter is "relaxed" in that it lacks the T and Z
     * characters and its use is discouraged.
     */
    private static final String RELAXED_DATE_TIME_FORMAT_STRING = "yyyy-MM-ddHH:mm:ss";

    /**
     * No instances.
     */
    private Iso8601Formatter() {
    }

    /**
     * Creates a date formatter for the given format and sets its time zone to
     * UTC.
     * 
     * @param format the format.
     * @return a date format.
     */
    private static DateFormat createDateFormatter(String format) {
        DateFormat dateFormatter = new SimpleDateFormat(format);
        dateFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        return dateFormatter;
    }

    /**
     * Returns a new instance of a ISO 8601 date-only formatter that displays
     * time in UTC. The returned formatter should only be used on the thread
     * that called this method.
     * 
     * @return a date formatter.
     */
    public static DateFormat dateFormatter() {
        return createDateFormatter(DATE_FORMAT_STRING);
    }

    /**
     * Returns a new instance of a ISO 8601 combined date/time formatter that
     * displays time in UTC. The returned formatter should only be used on the
     * thread that called this method.
     * 
     * @return a date/time formatter.
     */
    public static DateFormat dateTimeFormatter() {
        return createDateFormatter(DATE_TIME_FORMAT_STRING);
    }

    /**
     * Returns a new instance of a ISO 8601 combined date/time formatter with
     * millisecond precision that displays time in UTC. The returned formatter
     * should only be used on the thread that called this method.
     * 
     * @return a date/time formatter with millisecond precision.
     */
    public static DateFormat dateTimeMillisFormatter() {
        return createDateFormatter(DATE_TIME_MILLIS_FORMAT_STRING);
    }

    /**
     * Returns a new instance of a ISO 8601 relaxed combined date/time formatter
     * that displays time in UTC. The returned formatter should only be used on
     * the thread that called this method.
     * 
     * @return a relaxed date/time formatter.
     */
    public static DateFormat relaxedDateTimeFormatter() {
        return createDateFormatter(RELAXED_DATE_TIME_FORMAT_STRING);
    }
}
