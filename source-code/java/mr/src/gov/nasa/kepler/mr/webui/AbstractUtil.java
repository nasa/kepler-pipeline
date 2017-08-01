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

package gov.nasa.kepler.mr.webui;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.mr.ParameterUtil;

import java.io.PrintWriter;
import java.io.StringWriter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Abstract class that contains helper methods used by utility classes in this
 * package.
 * 
 * @author Bill Wohler
 */
public abstract class AbstractUtil {

    private static final Log log = LogFactory.getLog(AbstractUtil.class);

    public static final String NO_DATA = ParameterUtil.NO_DATA;

    /**
     * Initializes the database for use. All methods that access the database
     * should call this first. One of the things it does is to close an existing
     * database session so that queries don't return stale data.
     */
    protected void dbPrepare() {
        // Ensure that queries don't return stale data.
        DatabaseServiceFactory.getInstance()
            .closeCurrentSession();
    }

    /**
     * Display the given error with its stack trace. The error is logged.
     * 
     * @param errorText the error text.
     * @param e the exception which should also be displayed.
     */
    protected String displayError(String errorText, Exception e) {
        log.error(errorText);

        StringWriter stringWriter = new StringWriter();
        PrintWriter printWriter = new PrintWriter(stringWriter);
        e.printStackTrace(printWriter);
        printWriter.flush();
        String exceptionStack = stringWriter.toString();
        log.error(exceptionStack);

        String text = "<b>" + errorText + "</b>\n" + exceptionStack + "\n";
        Throwable t = e.getCause();
        if (t != null) {
            stringWriter = new StringWriter();
            printWriter = new PrintWriter(stringWriter);
            printWriter.flush();
            String throwableStack = stringWriter.toString();
            log.error(throwableStack);
            text = text + throwableStack + "\n";
        }

        return displayError(text, false);
    }

    /**
     * Display the given error in red. This error expects to be within an
     * {@code &lt;select&gt;} tag. The error is logged.
     * 
     * @param errorText the error text.
     */
    protected String displayError(String errorText) {
        log.error(errorText);

        return displayError(errorText, true);
    }

    /**
     * Display the given error in red. This error expects to be within an
     * {@code &lt;select&gt;} tag.
     * 
     * @param errorText the error text.
     * @param emphasize if {@code true}, then the text is displayed in red;
     * otherwise, the default color is used.
     */
    protected String displayError(String errorText, boolean emphasize) {
        String style = emphasize ? "style=\"color: red;\"" : "";

        return "</select>\n<pre" + style + ">" + errorText
            + "</pre><select style=\"display: none;\">\n";
    }

    /**
     * Capitalizes the given string. For example, this method converts "foo",
     * "FOO", and "fOo" to "Foo".
     * 
     * @param s the original string
     * @return the original string, capitalized.
     */
    protected String capitalize(String s) {
        if (s.length() == 0) {
            return s;
        }
        StringBuilder newString = new StringBuilder(s.toLowerCase());
        newString.setCharAt(0, Character.toUpperCase(newString.charAt(0)));

        return newString.toString();
    }

    /**
     * Converts all spaces to &amp;amp;. Tabs and newlines are not converted.
     * 
     * @param string an input string, with spaces.
     * @return a converted string.
     * @throws NullPointerException if {@code string} is {@code null}.
     */
    protected String toNbsp(String string) {
        return string.replaceAll(" ", "&nbsp;");
    }
}
