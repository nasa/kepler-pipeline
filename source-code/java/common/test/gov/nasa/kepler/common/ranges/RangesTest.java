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
import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.pojo.PojoTest;

import java.util.List;

import org.junit.Test;

import com.google.common.collect.Lists;

/**
 * @author Miles Cote
 * 
 */
public class RangesTest {

    private int start = 1;
    private int end = 3;
    private Range range = new Range(start, end);
    private List<Range> list = newArrayList(range);

    private Ranges ranges = new Ranges(list);
    private Ranges rangesWithSameKeys = new Ranges(list);
    private Ranges rangesWithDifferentList = new Ranges(
        Lists.<Range> newArrayList());

    @Test
    public void testGettersSetters() {
        PojoTest.testGettersSetters(range);
    }

    @Test
    public void testHashCodeEquals() {
        PojoTest.testHashCodeEquals(ranges, rangesWithSameKeys,
            rangesWithDifferentList);
    }

    @Test
    public void testToStringForString() {
        String string = ranges.toString();
        Ranges actualRanges = Ranges.forString(string);

        assertEquals(ranges, actualRanges);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testForStringWithNullString() {
        Ranges.forString(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testForStringWithEmptyString() {
        Ranges.forString("");
    }

    @Test
    public void testForStringWithTrailingSeparator() {
        Ranges actualRanges = Ranges.forString(start + Range.SEPARATOR + end
            + Ranges.SEPARATOR);

        assertEquals(ranges, actualRanges);
    }

    @Test
    public void testForStringWithSpaceAfterSeparator() {
        Ranges actualRanges = Ranges.forString(start + Range.SEPARATOR + end
            + Ranges.SEPARATOR + " ");

        assertEquals(ranges, actualRanges);
    }

    @Test
    public void testForStringWithTwoSeparatorsInARow() {
        Ranges actualRanges = Ranges.forString(start + Range.SEPARATOR + end
            + Ranges.SEPARATOR + Ranges.SEPARATOR);

        assertEquals(ranges, actualRanges);
    }

    @Test
    public void testToStringsForStrings() {
        List<String> strings = ranges.toStrings();
        Ranges actualRanges = Ranges.forStrings(strings);

        assertEquals(ranges, actualRanges);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testForStringsWithNullStrings() {
        Ranges.forStrings(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testForStringsWithEmptyStrings() {
        Ranges.forStrings(Lists.<String> newArrayList());
    }

    @Test
    public void testToIntegersForIntegers() {
        List<Integer> integers = ranges.toIntegers();
        Ranges actualRanges = Ranges.forIntegers(integers);

        assertEquals(ranges, actualRanges);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testForIntegersWithNullIntegers() {
        Ranges.forIntegers(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testForIntegersWithEmptyIntegers() {
        Ranges.forIntegers(Lists.<Integer> newArrayList());
    }

    @Test
    public void testForIntegersWithIntegersDecreasing() {
        Ranges actualRanges = Ranges.forIntegers(newArrayList(3, 2, 1));

        Ranges ranges = new Ranges(newArrayList(new Range(1, 3)));

        assertEquals(ranges, actualRanges);
    }

    @Test
    public void testForIntegersWithIntegersIncreasingByTwo() {
        Ranges actualRanges = Ranges.forIntegers(newArrayList(2, 4, 5, 6, 8));

        Ranges ranges = new Ranges(newArrayList(new Range(2, 2),
            new Range(4, 6), new Range(8, 8)));

        assertEquals(ranges, actualRanges);
    }

}
