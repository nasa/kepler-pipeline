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

package gov.nasa.kepler.ui.common;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * A collection of useful methods that do not have UI components.
 * 
 * @see gov.nasa.kepler.ui.swing.KeplerSwingUtilities
 * @author Bill Wohler
 */
public class KeplerUtilities {
    /**
     * Returns an unused name from the given list of names based upon the given
     * name. The naming strategy is based upon Nautilus. That is, the following
     * names are tried until one isn't already taken: "name (copy)", "name
     * (another copy)", "name (3rd copy)", "name (4th copy)", ...
     * <p>
     * In the unlikely event that there are {@link Integer#MAX_VALUE} copies
     * already (and you have enough memory to have passed that large of a Set),
     * this method returns <code>null</code>.
     * 
     * @param name the original name.
     * @param names a set of existing names.
     * @return a new name, or null if one could not be created.
     * @throws NullPointerException if either <code>name</code> or
     * <code>names</code> are <code>null</code>.
     */
    public static String createNewName(String name, Set<String> names) {
        String baseName = name;

        // If the name already has (nth copy) in it, strip this text, determine
        // count, and start from there.
        int next = 1;
        int start = -1;
        if (baseName.endsWith(" (copy)")) {
            start = baseName.indexOf(" (copy)");
            next = 2;
        } else if (baseName.endsWith(" (another copy)")) {
            start = baseName.indexOf(" (another copy)");
            next = 3;
        } else {
            Pattern p = Pattern.compile(" \\((\\d+)[nrst][dht] copy\\)$");
            Matcher m = p.matcher(baseName);
            if (m.find()) {
                start = m.start();
                next = Integer.valueOf(baseName.substring(m.start(1), m.end(1))) + 1;
            }
        }
        // Strip text.
        if (start >= 0) {
            baseName = baseName.substring(0, start);
        }

        // Create new name.
        String newName = null;
        for (int i = next; i < Integer.MAX_VALUE; i++) {
            // Create a new name.
            switch (i) {
                case 1:
                    newName = baseName + " (copy)";
                    break;
                case 2:
                    newName = baseName + " (another copy)";
                    break;
                default:
                    String suffix = "th";
                    if (i < 10 || i > 20) {
                        switch (i % 10) {
                            case 1:
                                suffix = "st";
                                break;
                            case 2:
                                suffix = "nd";
                                break;
                            case 3:
                                suffix = "rd";
                                break;
                        }
                    }
                    newName = baseName + " (" + i + suffix + " copy)";
                    break;
            }

            // If that name isn't taken, return it. Otherwise, try another name.
            if (!names.contains(newName)) {
                return newName;
            }
        }

        return null;
    }

    /**
     * Reads the given file and returns a list of strings. Each line becomes a
     * separate item in the list. Any text following a pound sign, #, is
     * ignored. Leading and trailing white space is trimmed.
     * 
     * @return a non-null list of strings.
     * @throws FileNotFoundException if there was a problem opening the file.
     * @throws IOException if there was a problem reading the file.
     */
    public static List<String> readFileAsList(String file) throws IOException {
        return readFileAsList(new FileInputStream(file));
    }

    /**
     * Reads the given input stream and returns a list of strings. Each line
     * becomes a separate item in the list. Any text following a pound sign, #,
     * is ignored. Leading and trailing white space is trimmed.
     * 
     * @return a non-null list of strings.
     * @throws IOException if there was a problem reading the file.
     */
    public static List<String> readFileAsList(InputStream is)
        throws IOException {

        BufferedReader file = new BufferedReader(new InputStreamReader(is));

        List<String> strings = new ArrayList<String>();
        Pattern pattern = Pattern.compile("([^#]+)(#.*)?$");

        while (file.ready()) {
            Matcher matcher = pattern.matcher(file.readLine());
            if (!matcher.matches()) {
                // Line contains only comment.
                continue;
            }
            String line = matcher.group(1);
            line = line.trim();
            if (line.length() > 0) {
                strings.add(line);
            }
        }

        return strings;
    }
}
