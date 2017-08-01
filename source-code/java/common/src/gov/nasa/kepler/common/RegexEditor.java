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

import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.LineIterator;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;

/**
 * Regular expression processing of text and text files.
 * 
 * @author Forrest Girouard
 * 
 */
public class RegexEditor {

    public interface FindAction {

        /**
         * Updates the current line that has matched a pattern.
         * 
         * @param matcher the Matcher object for the current line
         * @return the updated line, or {@code null} to delete the line
         */
        public String update(Matcher matcher);
    }

    public static class ExtractCaptureGroups implements FindAction {

        public String update(Matcher matcher) {

            StringBuilder builder = new StringBuilder();
            for (int group = 1; group <= matcher.groupCount(); group++) {
                String match = matcher.group(group);
                if (match != null) {
                    builder.append(match);
                }
            }
            return builder.toString();
        }
    }

    public static String findAndReplaceText(String input, Pattern pattern) {

        return findAndReplaceText(input, pattern, new ExtractCaptureGroups());
    }

    public static String findAndReplaceText(String input, Pattern[] patterns) {

        String output = input;
        if (patterns != null) {
            for (Pattern pattern : patterns) {
                output = findAndReplaceText(output, pattern,
                    new ExtractCaptureGroups());
            }
        }
        return output;
    }

    public static String findAndReplaceText(String input, Pattern pattern,
        FindAction action) {

        if (action == null) {
            throw new NullPointerException("null action");
        }

        String output = input;
        if (pattern != null) {
            Matcher matcher = pattern.matcher(input);
            if (matcher.find()) {
                output = action.update(matcher);
            }
        }
        return output;
    }

    public static File findAndReplace(File file, Pattern pattern)
        throws IOException {

        return findAndReplace(file, pattern, null);
    }

    public static File findAndReplace(File file, Pattern pattern, File directory)
        throws IOException {

        return findAndReplace(file, pattern, new ExtractCaptureGroups(),
            directory);
    }

    public static File findAndReplace(File file, Pattern pattern,
        FindAction action, File directory) throws IOException {

        File tmpFile = File.createTempFile(FileUtil.getBasename(file),
            FileUtil.getSuffix(file), directory);
        if (pattern != null) {
            LineIterator lines = FileUtils.lineIterator(file);
            List<String> output = new ArrayList<String>();
            if (lines != null) {
                while (lines.hasNext()) {
                    String line = lines.nextLine();
                    Matcher matcher = pattern.matcher(line);
                    if (matcher.find()) {
                        line = action.update(matcher);
                    }
                    if (line != null) {
                        output.add(line);
                    }
                }
            }
            FileUtils.writeLines(tmpFile, output);
        } else {
            FileUtils.copyFile(file, tmpFile, true);
        }
        return tmpFile;
    }

    public static File findAndReplaceAll(File sourceDir, Pattern pattern,
        FindAction action) throws IOException {

        File output = null;
        if (pattern != null) {
            @SuppressWarnings("unchecked")
            Collection<File> files = FileUtils.listFiles(sourceDir, null, false);
            if (files != null) {
                for (File file : files) {
                    output = findAndReplace(file, pattern, action, null);
                }
            }
        } else {
            output = File.createTempFile(FileUtil.getBasename(sourceDir), null);
            FileUtils.forceMkdir(output);
            FileUtil.copyFiles(sourceDir, output);
        }
        return output;
    }

    public static File findAndReplace(File sourceDir, IOFileFilter[] filters,
        Pattern pattern, FindAction action) throws IOException {

        File output = null;
        if (filters != null) {
            output = new File(Filenames.BUILD_TMP,
                FileUtil.getBasename(sourceDir));
            if (output.exists()) {
                FileUtils.forceDelete(output);
            }
            FileUtils.forceMkdir(output);
            for (IOFileFilter filter : filters) {
                @SuppressWarnings("unchecked")
                Collection<File> files = FileUtils.listFiles(sourceDir, filter,
                    FileFilterUtils.directoryFileFilter());
                if (files != null) {
                    File outputFile = null;
                    File buildTmp = new File(Filenames.BUILD_TMP);
                    for (File file : files) {
                        outputFile = findAndReplace(file, pattern, action,
                            buildTmp);
                        FileUtils.copyFile(outputFile, new File(output,
                            file.getName()));
                    }
                }
            }
        } else {
            output = findAndReplaceAll(sourceDir, pattern, action);
        }
        return output;
    }

    public static boolean stringEquals(String expectedInput,
        String actualInput, Pattern[] ignore) {

        String expected = RegexEditor.findAndReplaceText(expectedInput, ignore);
        String actual = RegexEditor.findAndReplaceText(actualInput, ignore);

        return expected.equals(actual);
    }

    public static String createCompoundRegex(List<String> regexs) {

        if (regexs == null) {
            throw new NullPointerException("regexs is null");
        }
        if (regexs.size() == 0) {
            throw new IllegalArgumentException("regexs is zero length");
        }

        StringBuffer compoundExpression = new StringBuffer();
        for (String regex : regexs) {
            if (compoundExpression.length() > 0) {
                compoundExpression.append("|");
            }
            compoundExpression.append(regex);
        }
        return compoundExpression.toString();
    }

    public static Pattern createCompoundPattern(List<String> regexs) {

        Pattern pattern = Pattern.compile(createCompoundRegex(regexs));
        return pattern;
    }
}
