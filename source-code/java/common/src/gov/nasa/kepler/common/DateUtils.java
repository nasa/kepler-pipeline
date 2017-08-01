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

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

/**
 * Parses and formats dates like the DMC.
 * 
 * @author Miles Cote
 * 
 */
public class DateUtils {

    private static final String DMC_DATE_FORMAT = "yyyyDDDHHmmss";

    public static final SimpleDateFormat READABLE_LOCAL_FORMAT = new SimpleDateFormat("yyyy-MM-dd--HH.mm.ss");

    /**
     * Disallow instantiation.
     */
    private DateUtils() {
    }

    private static SimpleDateFormat dmcFormatter;
    static {
        dmcFormatter = new SimpleDateFormat(DMC_DATE_FORMAT);
        dmcFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    /**
     * Format the {@link Date} as a {@link String} like the DMC.
     */
    public static synchronized String formatLikeDmc(Date date) {
        return dmcFormatter.format(date);
    }

    /**
     * Parse a {@link String} as a {@link Date} like the DMC.
     */
    public static synchronized Date parseLikeDmc(String string)
        throws ParseException {
        return dmcFormatter.parse(string);
    }

    /**
     * Generates the base filename (for FITS files) using the current date in
     * the same way as the DMC.
     */
    public static String generateDmcRootFileName() {
        return "kplr" + formatLikeDmc(new Date()) + "a";
    }

    /**
     * Generates the base filename using the given date the same way as the DMC.
     */
    public static String generateDmcRootFileName(Date date) {
        return "kplr" + formatLikeDmc(date);
    }

}
