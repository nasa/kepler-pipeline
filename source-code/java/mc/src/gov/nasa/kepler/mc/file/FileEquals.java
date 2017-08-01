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

import gov.nasa.kepler.common.RegexEditor;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.LineNumberReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

import org.apache.commons.lang.text.StrBuilder;

/**
 * A collection of methods for testing equality between files or directories.
 * 
 * @author Forrest Girouard
 * 
 */
public class FileEquals {

    private static final int BUFFER_SIZE = 16384;
    private static final int BYTE_DISPLAY_MAX = 32;

    public static String binaryEquals(String message, File expected, File actual)
        throws IOException {

        if (expected == actual) {
            return null;
        }

        String prefix = (message != null ? message + ": " : "");
        if ((!expected.isDirectory() && actual.isDirectory())
            || (expected.isDirectory() && !actual.isDirectory())) {
            return prefix + actual
                + ": directory attributes differ: expected.isDirectory()="
                + expected.isDirectory() + "; actual.isDirectory()="
                + actual.isDirectory();
        }

        if (!expected.isDirectory()) {
            return binaryFileEquals(message, expected, actual);
        }
        return directoryBinaryEquals(message, expected, actual);
    }

    public static String binaryEquals(File expected, File actual)
        throws IOException {

        return binaryEquals(null, expected, actual);
    }

    public static String directoryEquals(String message, File expected,
        File actual, String[] regexs) throws IOException {

        return directoryEquals(message, expected, actual, null, regexs);
    }

    public static String directoryEquals(String message, File expected,
        File actual, FileFilter directoryFilter, String[] regexs)
        throws IOException {

        if (expected == actual) {
            return null;
        }

        if (regexs == null) {
            throw new NullPointerException("regexs is null");
        }
        if (regexs.length == 0) {
            throw new IllegalArgumentException("regexs is zero length");
        }

        String prefix = (message != null ? message + ": " : "");
        if (!expected.isDirectory()) {
            return prefix + expected + ": not a directory";
        }
        if (!actual.isDirectory()) {
            return prefix + actual + ": not a directory";
        }

        StringBuffer compoundExpression = null;
        for (String regex : regexs) {
            if (compoundExpression == null) {
                compoundExpression = new StringBuffer(regex);
            } else {
                compoundExpression.append("|");
                compoundExpression.append(regex);
            }
        }
        return directoryEquals(message, expected, actual, directoryFilter,
            new Pattern[] { Pattern.compile(compoundExpression.toString()) });
    }

    public static String directoryEquals(File expected, File actual,
        String[] regexs) throws IOException {

        return directoryEquals(null, expected, actual, regexs);
    }

    public static String directoryEquals(String message, File expected,
        File actual, FileFilter directoryFilter, Pattern[] patterns)
        throws IOException {

        if (expected == actual) {
            return null;
        }

        String prefix = (message != null ? message + ": " : "");
        if (!expected.isDirectory()) {
            return prefix + expected + ": not a directory";
        }
        if (!actual.isDirectory()) {
            return prefix + actual + ": not a directory";
        }

        File[] expectedFiles = expected.listFiles(directoryFilter);
        File[] files = actual.listFiles(directoryFilter);
        Set<File> actualFiles = new HashSet<File>();
        for (File file : files) {
            actualFiles.add(file);
        }
        if (expectedFiles != null) {
            List<String> results = new ArrayList<String>();
            for (File expectedFile : expectedFiles) {
                String result = null;
                File actualFile = new File(actual, expectedFile.getName());
                if (!actual.exists()) {
                    return prefix + actualFile + ": missing";
                }
                if ((!expected.isDirectory() && actual.isDirectory())
                    || (expected.isDirectory() && !actual.isDirectory())) {
                    results.add(prefix
                        + actual
                        + ": directory attributes differ: expected.isDirectory()="
                        + expected.isDirectory() + "; actual.isDirectory()="
                        + actual.isDirectory());
                    continue;
                }
                if (!expectedFile.isDirectory()) {
                    result = equals(message, expectedFile, actualFile, patterns);
                } else {
                    result = directoryEquals(message, expectedFile, actualFile,
                        directoryFilter, patterns);
                }
                if (result != null) {
                    results.add(result);
                }
                actualFiles.remove(actualFile);
            }
            if (actualFiles.size() > 0) {
                StringBuffer filesListing = new StringBuffer();
                for (File file : actualFiles) {
                    if (filesListing.length() > 0) {
                        filesListing.append(", ");
                    }
                    filesListing.append(file);
                }
                results.add(prefix + "unexpected files: " + filesListing);
            }
            if (results.size() > 0) {
                return new StrBuilder().appendWithSeparators(results, "\n")
                    .toString();
            }
        }
        return null;
    }

    public static String directoryEquals(File expected, File actual,
        Pattern[] patterns) throws IOException {

        return directoryEquals(null, expected, actual, null, patterns);
    }

    public static String directoryEquals(String message, File expected,
        File actual) throws IOException {

        return directoryEquals(message, expected, actual, null,
            (Pattern[]) null);
    }

    public static String directoryEquals(String message, File expected,
        File actual, FileFilter directoryFilter) throws IOException {

        return directoryEquals(message, expected, actual, directoryFilter,
            (Pattern[]) null);
    }

    public static String directoryEquals(File expected, File actual)
        throws IOException {

        return directoryEquals(null, expected, actual);
    }

    public static String directoryBinaryEquals(String message, File expected,
        File actual) throws IOException {

        if (expected == actual) {
            return null;
        }

        String result = null;
        String prefix = (message != null ? message + ": " : "");
        if (!expected.isDirectory()) {
            return prefix + expected + ": not a directory";
        }
        if (!actual.isDirectory()) {
            return prefix + actual + ": not a directory";
        }

        File[] expectedFiles = expected.listFiles();
        File[] files = actual.listFiles();
        Set<File> actualFiles = new HashSet<File>();
        for (File file : files) {
            actualFiles.add(file);
        }
        if (expectedFiles != null) {
            for (File expectedFile : expectedFiles) {
                File actualFile = new File(actual, expectedFile.getName());
                if (!actual.exists()) {
                    return prefix + actualFile + ": missing";
                }
                if ((!expected.isDirectory() && actual.isDirectory())
                    || (expected.isDirectory() && !actual.isDirectory())) {
                    return prefix
                        + actual
                        + ": directory attributes differ: expected.isDirectory()="
                        + expected.isDirectory() + "; actual.isDirectory()="
                        + actual.isDirectory();
                }
                if (!expectedFile.isDirectory()) {
                    result = binaryEquals(message, expectedFile, actualFile);
                } else {
                    result = directoryBinaryEquals(message, expectedFile,
                        actualFile);
                }
                if (result != null) {
                    return result;
                }
                actualFiles.remove(actualFile);
            }
            if (actualFiles.size() > 0) {
                StringBuffer filesListing = new StringBuffer();
                for (File file : actualFiles) {
                    if (filesListing.length() > 0) {
                        filesListing.append(", ");
                    }
                    filesListing.append(file);
                }
                return prefix + "unexpected files: " + filesListing;
            }
        }
        return null;
    }

    public static String directoryBinaryEquals(File expected, File actual)
        throws IOException {

        return directoryBinaryEquals(null, expected, actual);
    }

    public static String equals(String message, File expected, File actual)
        throws IOException {

        if (expected == actual) {
            return null;
        }

        String prefix = (message != null ? message + ": " : "");
        if ((!expected.isDirectory() && actual.isDirectory())
            || (expected.isDirectory() && !actual.isDirectory())) {
            return prefix + actual
                + ": directory attributes differ: expected.isDirectory()="
                + expected.isDirectory() + "; actual.isDirectory()="
                + actual.isDirectory();
        }

        if (!expected.isDirectory()) {
            return fileEquals(message, expected, actual, null);
        }
        return directoryEquals(message, expected, actual);
    }

    public static String equals(File expected, File actual) throws IOException {

        return equals(null, expected, actual);
    }

    public static String equals(String message, File expected, File actual,
        String[] regexs) throws IOException {

        if (expected == actual) {
            return null;
        }

        if (regexs == null) {
            throw new NullPointerException("regexs is null");
        }
        if (regexs.length == 0) {
            throw new IllegalArgumentException("regexs is zero length");
        }

        StringBuffer compoundExpression = null;
        for (String regex : regexs) {
            if (compoundExpression == null) {
                compoundExpression = new StringBuffer(regex);
            } else {
                compoundExpression.append("|");
                compoundExpression.append(regex);
            }
        }
        return equals(message, expected, actual,
            new Pattern[] { Pattern.compile(compoundExpression.toString()) });
    }

    public static String equals(File expected, File actual, String[] regexs)
        throws IOException {

        return equals(null, expected, actual, regexs);
    }

    public static String equals(String message, File expected, File actual,
        Pattern[] patterns) throws IOException {

        if (expected == actual) {
            return null;
        }

        String prefix = (message != null ? message + ": " : "");
        if ((expected.isDirectory() && !actual.isDirectory())
            || (!expected.isDirectory() && actual.isDirectory())) {
            return prefix + actual
                + ": directory attributes differ: expected.isDirectory()="
                + expected.isDirectory() + "; actual.isDirectory()="
                + actual.isDirectory();
        }

        if (!expected.isDirectory()) {
            return fileEquals(message, expected, actual, patterns);
        }
        return directoryEquals(message, expected, actual, null, patterns);
    }

    public static String equals(File expected, File actual, Pattern[] patterns)
        throws IOException {

        return equals(null, expected, actual, patterns);
    }

    public static String equals(String message, Reader expected, Reader actual)
        throws IOException {

        return equals(message, expected, actual, null);
    }

    public static String equals(String message, Reader expected, Reader actual,
        Pattern[] patterns) throws IOException {

        String prefix = (message != null ? message + ": " : "");
        if (expected == null) {
            return prefix + "expected is null.";
        }
        if (actual == null) {
            return prefix + "actual is null.";
        }

        String result = null;
        LineNumberReader expectedReader = new LineNumberReader(expected);
        LineNumberReader actualReader = new LineNumberReader(actual);
        while (true) {
            if (!expectedReader.ready() && !actualReader.ready()) {
                return null;
            }

            String expectedLine = expectedReader.readLine();
            String actualLine = actualReader.readLine();
            if (expectedLine == null && actualLine == null) {
                return null;
            }

            int line = expectedReader.getLineNumber();
            if (actualLine == null) {
                return prefix + "line: " + line + ": was <EOF> but expected: "
                    + expectedLine;
            }
            if (expectedLine == null) {
                return prefix + "line: " + line + ": expected <EOF> but was: "
                    + actualLine;
            }
            result = stringEquals(prefix + "line: " + line, expectedLine,
                actualLine, patterns);
            if (result != null) {
                return result;
            }
        }
    }

    public static String equals(String message, InputStream expected,
        InputStream actual) throws IOException {

        String prefix = (message != null ? message + ": " : "");
        if (expected == null) {
            return prefix + "expected is null.";
        }
        if (actual == null) {
            return prefix + "actual is null.";
        }

        String result = null;
        byte[] expectedBuffer = new byte[BUFFER_SIZE];
        byte[] actualBuffer = new byte[BUFFER_SIZE];
        int offset = 0;
        while (true) {
            if (expected.available() == 0 && actual.available() == 0) {
                return null;
            }

            int expectedBytes = expected.read(expectedBuffer);
            int actualBytes = actual.read(actualBuffer);
            if (expectedBytes == 0 && actualBytes == 0) {
                return null;
            }
            result = equals(prefix, offset, expectedBuffer, expectedBytes,
                actualBuffer, actualBytes);
            if (result != null) {
                return result;
            }
        }
    }

    public static String equals(String message, int fileOffset,
        byte[] expected, int expectedBytes, byte[] actual, int actualBytes) {

        StringBuilder result = new StringBuilder();

        if (expectedBytes != 0 && actualBytes == 0) {
            result.append(message);
            result.append("offset: ");
            result.append(fileOffset);
            result.append(": was <EOF> but expected: ");
            result.append(Arrays.toString(Arrays.copyOfRange(expected, 0,
                Math.min(expectedBytes, BYTE_DISPLAY_MAX))));
        } else if (expectedBytes == 0 && actualBytes != 0) {
            result.append(message);
            result.append("offset: ");
            result.append(fileOffset);
            result.append(": expected <EOF> but was: ");
            result.append(Arrays.toString(Arrays.copyOfRange(actual, 0,
                Math.min(actualBytes, BYTE_DISPLAY_MAX))));
        } else if (expectedBytes != 0 && actualBytes != 0) {
            for (int position = 0; position < expectedBytes; position++) {
                if (position == actualBytes) {
                    result.append(message);
                    result.append(": expected <");
                    result.append(Arrays.toString(Arrays.copyOfRange(actual,
                        position, Math.min(actualBytes - position,
                            BYTE_DISPLAY_MAX))));
                    result.append("> but was <EOL>.");
                    break;
                } else if (expected[position] != actual[position]) {
                    result.append(message);
                    result.append(": expected <");
                    result.append(Arrays.toString(Arrays.copyOfRange(expected,
                        position, Math.min(expectedBytes - position,
                            BYTE_DISPLAY_MAX))));
                    result.append("> but was <");
                    result.append(Arrays.toString(Arrays.copyOfRange(actual,
                        position, Math.min(actualBytes - position,
                            BYTE_DISPLAY_MAX))));
                    result.append(">.");
                    break;
                }
            }
            if (result.length() == 0 && expectedBytes < actualBytes) {
                result.append(message);
                result.append(": expected <EOL> but was <");
                result.append(Arrays.toString(Arrays.copyOfRange(actual,
                    expectedBytes, Math.min(actualBytes - expectedBytes,
                        BYTE_DISPLAY_MAX))));
                result.append(">.");
            }
        }
        if (result.length() > 0) {
            return result.toString();
        }
        return null;
    }

    public static String binaryEquals(String message, InputStream expected,
        InputStream actual) throws IOException {

        String prefix = (message != null ? message + ": " : "");
        if (expected == null) {
            return prefix + "expected is null.";
        }
        if (actual == null) {
            return prefix + "actual is null.";
        }

        String result = null;
        byte[] expectedBuffer = new byte[BUFFER_SIZE];
        byte[] actualBuffer = new byte[BUFFER_SIZE];
        int offset = 0;
        while (true) {
            if (expected.available() == 0 && actual.available() == 0) {
                return null;
            }

            int expectedBytes = expected.read(expectedBuffer);
            int actualBytes = actual.read(actualBuffer);
            if (expectedBytes == 0 && actualBytes == 0) {
                return null;
            }
            result = binaryEquals(prefix, offset, expectedBuffer,
                expectedBytes, actualBuffer, actualBytes);
            offset += expectedBytes;
            if (result != null) {
                return result;
            }
        }
    }

    public static String binaryEquals(String message, int fileOffset,
        byte[] expected, int expectedBytes, byte[] actual, int actualBytes) {

        int position = 0;
        for (; position < expectedBytes; position++) {
            if (position >= actualBytes
                || expected[position] != actual[position]) {
                return message + "byte " + (fileOffset + position + 1);
            }
        }
        if (position < actualBytes) {
            return message + "byte " + (fileOffset + position + 1);
        }

        return null;
    }

    public static String stringEquals(String message, String expectedInput,
        String actualInput, Pattern[] ignore) {

        if (!RegexEditor.stringEquals(expectedInput, actualInput, ignore)) {
            return getMessage(message, expectedInput, actualInput);
        }
        return null;
    }

    static String binaryFileEquals(String message, File expected, File actual)
        throws IOException {

        String prefix = (message != null ? message + ": " : "");

        if (expected == null) {
            return prefix + "expected file is null.";
        }
        if (!expected.exists()) {
            return prefix + expected + ": does not exist.";
        }
        if (!expected.canRead()) {
            return prefix + expected + ": unreadable.";
        }

        if (actual == null) {
            return prefix + "actual file is null.";
        }
        if (!actual.exists()) {
            return prefix + actual + ": does not exist.";
        }
        if (!actual.canRead()) {
            return prefix + actual + ": unreadable.";
        }

        FileInputStream expectedStream = null;
        FileInputStream actualStream = null;
        try {
            expectedStream = new FileInputStream(expected);
            actualStream = new FileInputStream(actual);
            BufferedInputStream expectedBufferedStream = new BufferedInputStream(
                expectedStream);
            BufferedInputStream actualBufferedStream = new BufferedInputStream(
                actualStream);

            prefix += expected.getName() + " " + actual.getName() + " differ";
            return binaryEquals(prefix, expectedBufferedStream,
                actualBufferedStream);
        } finally {
            FileUtil.close(expectedStream);
            FileUtil.close(actualStream);
        }
    }

    static String fileEquals(String message, File expected, File actual,
        Pattern[] patterns) throws IOException {

        String prefix = (message != null ? message + ": " : "");

        if (expected == null) {
            return prefix + "expected file is null.";
        }
        if (!expected.exists()) {
            return prefix + expected + ": does not exist.";
        }
        if (!expected.canRead()) {
            return prefix + expected + ": unreadable.";
        }

        if (actual == null) {
            return prefix + "actual file is null.";
        }
        if (!actual.exists()) {
            return prefix + actual + ": does not exist.";
        }
        if (!actual.canRead()) {
            return prefix + actual + ": unreadable.";
        }

        prefix += actual.getPath();
        FileInputStream expectedStream = null;
        FileInputStream actualStream = null;
        try {
            expectedStream = new FileInputStream(expected);
            actualStream = new FileInputStream(actual);
            BufferedReader expectedReader = new BufferedReader(
                new InputStreamReader(expectedStream));
            BufferedReader actualReader = new BufferedReader(
                new InputStreamReader(actualStream));

            return equals(prefix, expectedReader, actualReader, patterns);
        } finally {
            FileUtil.close(expectedStream);
            FileUtil.close(actualStream);
        }
    }

    private static String substring(String str) {
        return substring(str, BYTE_DISPLAY_MAX);
    }

    private static String substring(String str, int maxLength) {
        if (str.length() > maxLength) {
            return str.substring(0, maxLength) + "...";
        }
        return str;
    }

    private static String getMessage(String message, String expected,
        String actual) {

        StringBuilder result = new StringBuilder();
        if (expected == null && actual != null) {
            result.append(message);
            result.append(": expected <EOF> but was <");
            result.append(substring(actual));
            result.append(">.\n");
        } else if (expected != null && actual == null) {
            result.append(message);
            result.append(": expected <");
            result.append(substring(expected));
            result.append("> but was <EOF>.\n");
        } else if (expected != null && actual != null) {
            for (int position = 0; position < expected.length(); position++) {
                if (position == actual.length()) {
                    result.append(message);
                    result.append(": expected <");
                    result.append(substring(expected.substring(position)));
                    result.append("> but was <EOL>.\n");
                    break;
                } else if (expected.charAt(position) != actual.charAt(position)) {
                    result.append(message);
                    result.append(": expected <");
                    result.append(substring(expected.substring(position)));
                    result.append("> but was <");
                    result.append(substring(actual.substring(position)));
                    result.append(">.\n");
                    break;
                }
            }
            if (result.length() == 0 && expected.length() < actual.length()) {
                result.append(message);
                result.append(": expected <EOL> but was <");
                result.append(substring(actual.substring(expected.length())));
                result.append(">.\n");
            }
        }
        if (result.length() > 0) {
            return result.toString();
        }
        return null;
    }
}
