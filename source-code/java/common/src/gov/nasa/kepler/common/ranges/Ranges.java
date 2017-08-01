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

package gov.nasa.kepler.common.ranges;

import static com.google.common.collect.Lists.newArrayList;

import java.util.Collections;
import java.util.List;

/**
 * Contains a {@link List} of {@link Range}s.
 * 
 * @author Miles Cote
 * 
 */
public final class Ranges {

    static final String SEPARATOR = ",";

    private final List<Range> ranges;

    @Override
    public String toString() {
        StringBuilder b = new StringBuilder();

        for (Range range : ranges) {
            b.append(range.toString());
            b.append(SEPARATOR);
        }

        String string = b.toString();
        string = string.substring(0, string.length() - 1);

        return string;
    }

    public static final Ranges forString(String string) {
        if (string == null) {
            throw new IllegalArgumentException("string cannot be null.");
        }

        if (string.isEmpty()) {
            throw new IllegalArgumentException("string cannot be empty.");
        }

        List<Range> ranges = newArrayList();
        for (String splitString : string.split(SEPARATOR)) {
            String trimmedString = splitString.trim();
            if (!trimmedString.isEmpty()) {
                ranges.add(Range.forString(trimmedString));
            }
        }

        return new Ranges(ranges);
    }
    
    public List<String> toStrings() {
        List<String> strings = newArrayList();
        for (Range range : ranges) {
            strings.add(range.toString());
        }

        return strings;
    }
    
    public static final Ranges forStrings(List<String> strings) {
        if (strings == null) {
            throw new IllegalArgumentException("strings cannot be null.");
        }

        if (strings.isEmpty()) {
            throw new IllegalArgumentException("strings cannot be empty.");
        }

        List<Range> ranges = newArrayList();
        for (String string : strings) {
            ranges.add(Range.forString(string));
        }
        
        return new Ranges(ranges);
    }

    public List<Integer> toIntegers() {
        List<Integer> integers = newArrayList();

        for (Range range : ranges) {
            integers.addAll(range.toIntegers());
        }

        return integers;
    }

    public static final Ranges forIntegers(List<Integer> integers) {
        if (integers == null) {
            throw new IllegalArgumentException("integers cannot be null.");
        }

        if (integers.isEmpty()) {
            throw new IllegalArgumentException("integers cannot be empty.");
        }

        List<Range> ranges = newArrayList();

        Collections.sort(integers);

        Integer start = integers.get(0);
        Integer end = null;
        for (Integer integer : integers) {
            if (end != null) {
                if (integer != end + 1) {
                    ranges.add(new Range(start, end));
                    start = integer;
                }
            }

            end = integer;
        }

        ranges.add(new Range(start, end));

        return new Ranges(ranges);
    }

    public Ranges(List<Range> ranges) {
        this.ranges = ranges;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((ranges == null) ? 0 : ranges.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        Ranges other = (Ranges) obj;
        if (ranges == null) {
            if (other.ranges != null)
                return false;
        } else if (!ranges.equals(other.ranges))
            return false;
        return true;
    }

    public List<Range> getRanges() {
        return ranges;
    }

}
