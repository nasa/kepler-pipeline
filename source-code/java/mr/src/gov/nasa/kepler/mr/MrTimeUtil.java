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

package gov.nasa.kepler.mr;

import gov.nasa.kepler.common.Iso8601Formatter;

import java.text.DateFormat;
import java.util.Date;

/**
 * Time/date formatting methods for mission reports. This is a facade to
 * specific time/date formatting classes to enable switching the time/date
 * format in MR in one place. The current format is ISO 8601; see
 * {@link Iso8601Formatter} for information on thread safety.
 * 
 * @author Bill Wohler
 * @author jbrittain
 */
public class MrTimeUtil {

    /**
     * No instances.
     */
    private MrTimeUtil() {
    }

    /**
     * Returns a date formatter that formats dates in ISO 8601 UTC format. For
     * dates that will be used in filenames and URLs, use
     * {@link #urlDateFormatter()}.
     * 
     * @return a date/time formatter.
     */
    public static DateFormat dateFormatter() {
        return Iso8601Formatter.dateTimeFormatter();
    }

    /**
     * Returns a date formatter that formats dates in ISO 8601 UTC format with
     * millisecond precision. It should be used for dates that must be used in
     * filenames and URLs since the format eschews undesirable characters and
     * provides millisecond precision to minimize the chance of name collisions.
     * 
     * @return a date/time formatter with millisecond precision.
     */
    public static DateFormat urlDateFormatter() {
        return Iso8601Formatter.dateTimeMillisFormatter();
    }

    /**
     * Returns the current time as a String as formatted by
     * {@link #urlDateFormatter()}.
     * 
     * @return a string containing the current date.
     */
    public static String getUrlFormattedTimeNow() {
        return urlDateFormatter().format(new Date().getTime());
    }
}
