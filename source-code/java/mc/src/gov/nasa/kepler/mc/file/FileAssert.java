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

package gov.nasa.kepler.mc.file;

import static junit.framework.Assert.fail;

import java.io.File;
import java.io.IOException;
import java.util.regex.Pattern;

import junit.framework.AssertionFailedError;

/**
 * A collection of methods for asserting equality between files or directories.
 * 
 * @see junix.framework.FileAssert
 * 
 * @author Forrest Girouard
 * 
 */
public class FileAssert {

    protected FileAssert() {
    }

    public static void assertBinaryEquals(String message, File expected,
        File actual) throws IOException {

        String result = FileEquals.binaryEquals(message, expected, actual);
        if (result != null) {
            throw new AssertionFailedError(result);
        }
    }

    public static void assertBinaryEquals(File expected, File actual)
        throws IOException {

        assertBinaryEquals(null, expected, actual);
    }

    public static void assertEquals(String message, File expected, File actual) {

        try {
            String result = FileEquals.equals(message, expected, actual);
            if (result != null) {
                throw new AssertionFailedError(result);
            }
        } catch (IOException e) {
            fail(message + "unexpected exception: " + e.getMessage());
        }
    }

    public static void assertEquals(File expected, File actual) {

        assertEquals(null, expected, actual);
    }

    public static void assertEquals(String message, File expected, File actual,
        String[] regexs) throws IOException {

        String result = FileEquals.equals(message, expected, actual, regexs);
        if (result != null) {
            throw new AssertionFailedError(result);
        }
    }

    public static void assertEquals(File expected, File actual, String[] regexs) {

        try {
            assertEquals(null, expected, actual, regexs);
        } catch (IOException e) {
            fail("unexpected exception: " + e.getMessage());
        }
    }

    public static void assertDirectoryEquals(String message, File expected,
        File actual, String[] regexs) {

        try {
            String result = FileEquals.directoryEquals(message, expected,
                actual, regexs);
            if (result != null) {
                throw new AssertionFailedError(result);
            }
        } catch (IOException e) {
            fail("unexpected exception: " + e.getMessage());
        }
    }

    public static void assertDirectoryEquals(File expected, File actual,
        String[] regexs) {

        assertDirectoryEquals(null, expected, actual, regexs);
    }

    public static void assertEquals(String message, File expected, File actual,
        Pattern[] patterns) throws IOException {

        String result = FileEquals.equals(message, expected, actual, patterns);
        if (result != null) {
            throw new AssertionFailedError(result);
        }
    }

    public static void assertEquals(File expected, File actual,
        Pattern[] patterns) throws IOException {

        assertEquals(null, expected, actual, patterns);
    }

    public static void assertDirectoryEquals(String message, File expected,
        File actual, Pattern[] patterns) throws IOException {

        String result = FileEquals.directoryEquals(message, expected, actual,
            null, patterns);
        if (result != null) {
            throw new AssertionFailedError(result);
        }
    }

    public static void assertDirectoryEquals(File expected, File actual,
        Pattern[] patterns) throws IOException {

        assertDirectoryEquals(null, expected, actual, patterns);
    }

    public static void assertDirectoryEquals(String message, File expected,
        File actual) throws IOException {

        assertDirectoryEquals(message, expected, actual, (Pattern[]) null);
    }

    public static void assertDirectoryEquals(File expected, File actual)
        throws IOException {

        assertDirectoryEquals(null, expected, actual);
    }

    public static void assertDirectoryBinaryEquals(String message,
        File expected, File actual) throws IOException {

        String result = FileEquals.directoryBinaryEquals(message, expected,
            actual);
        if (result != null) {
            throw new AssertionFailedError(result);
        }
    }

    public static void assertDirectoryBinaryEquals(File expected, File actual)
        throws IOException {

        assertDirectoryBinaryEquals(null, expected, actual);
    }
}
