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

import java.util.List;

/**
 * Contains a range of contigous integers.
 * 
 * @author Miles Cote
 * 
 */
public final class Range {

    static final String SEPARATOR = ":";

    private final int start;
    private final int end;

    public String toString() {
        StringBuilder b = new StringBuilder();
        b.append(start);

        if (start != end) {
            b.append(SEPARATOR);
            b.append(end);
        }

        String string = b.toString();
        return string;
    }

    public static final Range forString(String string) {
        if (string == null) {
            throw new IllegalArgumentException("string cannot be null.");
        }

        if (string.isEmpty()) {
            throw new IllegalArgumentException("string cannot be empty.");
        }

        String[] strings = string.split(SEPARATOR);
        if (strings.length > 2) {
            throw new IllegalArgumentException(
                "The string cannot have more than one separator."
                    + "\n  string: " + string + "\n  separator: " + SEPARATOR);
        }

        int start = Integer.valueOf(strings[0]);
        int end = Integer.valueOf(strings[strings.length - 1]);

        return new Range(start, end);
    }

    public List<Integer> toIntegers() {
        List<Integer> integers = newArrayList();

        for (int i = start; i <= end; i++) {
            integers.add(i);
        }

        return integers;
    }

    public static final Range forIntegers(List<Integer> integers) {
        if (integers == null) {
            throw new IllegalArgumentException("integers cannot be null.");
        }

        if (integers.isEmpty()) {
            throw new IllegalArgumentException("integers cannot be empty.");
        }

        Integer start = integers.get(0);
        Integer end = null;
        for (Integer integer : integers) {
            if (end != null) {
                if (integer != end + 1) {
                    throw new IllegalArgumentException(
                        "integers must be monotonically increasing."
                            + "\n  startOfDiscontinuity: " + end
                            + "\n  endOfDiscontinuity: " + integer);
                }
            }

            end = integer;
        }

        return new Range(start, end);
    }

    public Range(int start, int end) {
        if (start > end) {
            throw new IllegalArgumentException(
                "start cannot be greater than end." + "\n  start: " + start
                    + "\n  end: " + end);
        }

        this.start = start;
        this.end = end;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + end;
        result = prime * result + start;
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
        Range other = (Range) obj;
        if (end != other.end)
            return false;
        if (start != other.start)
            return false;
        return true;
    }

    public int getStart() {
        return start;
    }

    public int getEnd() {
        return end;
    }

}
