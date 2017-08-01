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

package gov.nasa.kepler.hibernate;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.hibernate.Constraint.Conjunction;
import gov.nasa.kepler.hibernate.Constraint.Operator;
import gov.nasa.kepler.hibernate.cm.Kic;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

public class ConstraintTest implements Constraint.CanonicalizableConverter {

    private Constraint constraint;
    private Canonicalizable columnName = toCanonicalizable("columnName");

    @Before
    public void createCondition() {
        constraint = new Constraint(Conjunction.AND, columnName,
            Operator.EQUAL, "42");
    }

    @Test
    public void testConstructorAndAccessors() {
        assertEquals(Conjunction.AND, constraint.getConjunction());
        assertEquals(columnName, constraint.getColumnName());
        assertEquals(Operator.EQUAL, constraint.getOperator());
        assertEquals("42", constraint.getValue());
    }

    @Test
    public void testToStringAndToCanonicalString() {
        assertEquals("and columnName = 42", constraint.toString());
        assertEquals("and FOO.columnName = 42",
            constraint.toCanonicalString("FOO"));
        constraint = new Constraint(Conjunction.NONE,
            toCanonicalizable("columnName"), Operator.EQUAL, "42");
        assertEquals("columnName = 42", constraint.toString());
        assertEquals("FOO.columnName = 42", constraint.toCanonicalString("FOO"));
        constraint = new Constraint(Conjunction.OR,
            toCanonicalizable("foo bar"), Operator.GREATER_THAN, "42 42");
        assertEquals("or 'foo bar' > '42 42'", constraint.toString());
        assertEquals("or 'FOO.foo bar' > '42 42'",
            constraint.toCanonicalString("FOO"));
        constraint = new Constraint(Conjunction.NONE,
            toCanonicalizable("string"), Operator.EQUAL, "foo");
        assertEquals("string = foo", constraint.toString());
        assertEquals("FOO.string = 'foo'", constraint.toCanonicalString("FOO"));
    }

    @Test
    public void testParseExpressionNull() throws ParseException {
        assertEquals(Collections.EMPTY_LIST, Constraint.parseExpression(null));
        assertEquals(Collections.EMPTY_LIST, Constraint.parseExpression(""));
    }

    @Test(expected = ParseException.class)
    public void testParseExpressionInvalid1() throws ParseException {
        Constraint.parseExpression("BAD columnName = 42 and columnName = 42 or 'foo bar' > 42");
    }

    @Test(expected = ParseException.class)
    public void testParseExpressionInvalid2() throws ParseException {
        Constraint.parseExpression("columnName BAD 42 and columnName = 42 or 'foo bar' > 42");
    }

    @Test(expected = ParseException.class)
    public void testParseExpressionInvalid3() throws ParseException {
        Constraint.parseExpression("columnName = and columnName = 42 or 'foo bar' > 42");
    }

    @Test(expected = ParseException.class)
    public void testParseExpressionInvalid4() throws ParseException {
        Constraint.parseExpression("columnName and columnName = 42 or 'foo bar' > 42");
    }

    @Test
    public void testParseExpression() throws ParseException {
        List<Constraint> constraints = new ArrayList<Constraint>();
        constraints.add(new Constraint(Conjunction.NONE,
            toCanonicalizable("columnName"), Operator.EQUAL, "42"));
        constraints.add(new Constraint(Conjunction.AND,
            toCanonicalizable("columnName"), Operator.EQUAL, "42"));
        constraints.add(new Constraint(Conjunction.OR,
            toCanonicalizable("foo bar"), Operator.GREATER_THAN, "42"));

        assertEquals(constraints, Constraint.parseExpression(
            "columnName = 42 and columnName = 42 or 'foo bar' > 42", this));
    }

    @Test
    public void testListToStringNull() {
        assertEquals("", Constraint.listToString(null));
        List<Constraint> constraints = Collections.emptyList();
        assertEquals("", Constraint.listToString(constraints));
    }

    @Test
    public void testListToString() {
        List<Constraint> constraints = new ArrayList<Constraint>();
        constraints.add(new Constraint(Conjunction.NONE,
            toCanonicalizable("columnName"), Operator.EQUAL, "42"));
        constraints.add(new Constraint(Conjunction.AND, Kic.Field.KEPLER_ID,
            Operator.EQUAL, "42"));
        String query = "columnName = 42 and KEPLER_ID = 42";
        assertEquals(query, Constraint.listToString(constraints));
        query = "FOO.columnName = 42 and kic.keplerId = 42";
        assertEquals(query,
            Constraint.listToCanonicalizedString(constraints, null));
    }

    @Test(expected = NullPointerException.class)
    public void testValueOfNull() throws ParseException {
        assertEquals("doesn't matter", Constraint.valueOf(null));
    }

    @Test(expected = ParseException.class)
    public void testValueOfInvalidConjunction() throws ParseException {
        assertEquals("doesn't matter",
            Constraint.valueOf("XXX columnName = 42"));
    }

    @Test(expected = ParseException.class)
    public void testValueOfInvalidComparison() throws ParseException {
        assertEquals("doesn't matter",
            Constraint.valueOf("and columnName == 42"));
    }

    @Test(expected = ParseException.class)
    public void testValueOfInvalidValue() throws ParseException {
        assertEquals("doesn't matter", Constraint.valueOf("and columnName = "));
    }

    @Test
    public void testValueOf() throws ParseException {
        assertEquals(constraint.toString(),
            Constraint.valueOf("and columnName = 42")
                .toString());
        constraint = new Constraint(Conjunction.NONE,
            toCanonicalizable("columnName"), Operator.EQUAL, "42");
        assertEquals(constraint.toString(),
            Constraint.valueOf("columnName = 42")
                .toString());
        constraint = new Constraint(Conjunction.OR,
            toCanonicalizable("foo bar"), Operator.GREATER_THAN, "42");
        assertEquals(constraint.toString(),
            Constraint.valueOf("or 'foo bar' > 42")
                .toString());
    }

    @Override
    public Canonicalizable toCanonicalizable(final String string) {
        return new Canonicalizable() {
            @Override
            public String canonicalize(String alias) {
                return (alias != null ? alias : "FOO") + "." + string;
            }

            @Override
            public String toString() {
                return string;
            }

            @Override
            public Class<?> getObjectClass() {
                return string.equals("string") ? String.class : Integer.class;
            }

            @Override
            public boolean equals(Object other) {
                return canonicalize(null).equals(
                    ((Canonicalizable) other).canonicalize(null))
                    && toString().equals(other.toString());
            }
        };
    }
}
