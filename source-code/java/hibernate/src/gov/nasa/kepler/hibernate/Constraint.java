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

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Restrictions;

/**
 * A query constraint object. This object provides a bridge between strings
 * (which are saved in the database or used for queries) and individual,
 * editable, items in a UI list.
 * <p>
 * Column names are <i>canonicalizable</i>. That way, their short names can be
 * displayed in UIs with their {@link Object#toString()} methods, and their
 * fully-qualified names can be used in SQL queries. Typically, an object's
 * {@link Canonicalizable#canonicalize(String)} method prefixes the column name
 * with the table name. In order to turn a string into a Constraint object, a
 * {@link CanonicalizableConverter} object is passed into
 * {@link #parseExpression(String, Constraint.CanonicalizableConverter)}.
 * 
 * @author Bill Wohler
 */
public class Constraint {
    private static final Log log = LogFactory.getLog(Constraint.class);

    /**
     * Enum of conjunctions "and" and "or". Use NONE to get an empty string,
     * which is useful for the first term in a series.
     * <p>
     * N.B. Use {@link #parse(String)} instead of {@link #valueOf(String)}.
     */
    public static enum Conjunction {
        NONE(""), AND("and"), OR("or");

        private String s;

        private Conjunction() {
        }

        private Conjunction(String s) {
            this.s = s;
        }

        @Override
        public String toString() {
            if (s != null) {
                return s;
            }
            return super.toString();
        }

        /**
         * Calls {@link #valueOf(String)} after converting "" to NONE.
         * 
         * @param name the name of the constant to return.
         * @return the enum constant for the given name.
         */
        public static Conjunction parse(String name) {
            if (name.length() == 0) {
                return valueOf("NONE");
            }
            return valueOf(name.toUpperCase());
        }
    }

    /**
     * Enum of comparison operators.
     */
    public static enum Operator {
        LESS_THAN("<"),
        LESS_THAN_OR_EQUAL("<="),
        EQUAL("="),
        NOT_EQUAL("!="),
        GREATER_THAN_OR_EQUAL(">="),
        GREATER_THAN(">");

        private String op;

        private Operator(String op) {
            this.op = op;
        }

        @Override
        public String toString() {
            return op;
        }

        /**
         * Returns the enum constant with the specified name.
         * 
         * @param name the name of the constant to return.
         * @return the enum constant with the specified name.
         * @throws IllegalArgumentException if there is no constant with the
         * specified name.
         * @throws NullPointerException if <tt>name</tt> is null.
         */
        public static Operator parse(String name) {
            for (Operator c : values()) {
                if (c.toString()
                    .equals(name)) {
                    return c;
                }
            }

            // Maybe the actual constant name was used.
            return valueOf(name);
        }
    }

    private Conjunction conjunction;
    private Canonicalizable columnName;
    private Operator operator;
    private String value;

    protected static Pattern pattern = createPattern();

    /**
     * Creates a constraint with the given conjunction, column name, operator,
     * and value.
     * 
     * @param conjunction the conjunction.
     * @param columnName the column name.
     * @param operator the comparison.
     * @param value the value.
     * @throws IllegalArgumentException if <code>value</code> is
     * <code>null</code> and <code>operator</code> isn't one of
     * {@link Operator#EQUAL} or {@link Operator#NOT_EQUAL}. If the string null
     * is desired, then use 'null'.
     */
    public Constraint(Conjunction conjunction, Canonicalizable columnName,
        Operator operator, String value) {
        this.conjunction = conjunction;
        this.columnName = columnName;
        this.operator = operator;
        this.value = value;

        if (value.equals("null")) {
            if (operator != Operator.EQUAL && operator != Operator.NOT_EQUAL) {
                throw new IllegalArgumentException(
                    "Operator must be = or != if value is null");
            }
        }
    }

    /**
     * Returns the conjunction in this constraint.
     * 
     * @return the conjunction.
     */
    public Object getConjunction() {
        return conjunction;
    }

    /**
     * Returns the column name in this constraint.
     * 
     * @return the column name.
     */
    public Canonicalizable getColumnName() {
        return columnName;
    }

    /**
     * Returns the operator in this constraint.
     * 
     * @return the operator.
     */
    public Operator getOperator() {
        return operator;
    }

    /**
     * Returns the value in this constraint.
     * 
     * @return the value.
     */
    public String getValue() {
        return value;
    }

    /**
     * Returns this constraint as a string. It varies from
     * {@link #toCanonicalString(String)} in that it uses
     * <code>columnName.toString()</code> to display the column name.
     */
    @Override
    public String toString() {
        String conjunctionTrailingSpace = conjunction == Conjunction.NONE ? ""
            : " ";
        String columnNameQuote = columnName.toString()
            .contains(" ") ? "'" : "";
        String valueQuote = value.contains(" ") ? "'" : "";

        return conjunction.toString() + conjunctionTrailingSpace
            + columnNameQuote + columnName.toString() + columnNameQuote + " "
            + operator + " " + valueQuote + value + valueQuote;
    }

    /**
     * Returns this constraint as an SQL string. It varies from
     * {@link #toString()} in that it calls
     * {@link Canonicalizable#canonicalize(String)} on <code>columnName</code>
     * to obtain the column's name (instead of {@link Object#toString()}) and
     * quotes the value if {@link Canonicalizable#getObjectClass()} returns
     * <code>String.class</code>. This method also replaces
     * <code>foo = null</code> with <code>foo is null</code> and
     * <code>foo != null</code> with <code>foo is not null</code>. This means
     * that the value will have to be quoted (<code>'null'</code>) if the string null is
     * intended.
     * 
     * @param alias an alias which is passed to the
     * {@link Canonicalizable#canonicalize(String)} method.
     * @return a string representation of this constraint.
     */
    public String toCanonicalString(String alias) {
        String conjunctionTrailingSpace = conjunction == Conjunction.NONE ? ""
            : " ";
        String columnNameQuote = columnName.canonicalize(alias)
            .contains(" ") ? "'" : "";
        String valueQuote = value.contains(" ")
            || columnName.getObjectClass() == String.class
            && !columnName.toString()
                .equals("null") ? "'" : "";

        // If value is "null", then ensure that operator is one of = or != and
        // convert these to is and is not.
        String op;
        if (value.equals("null")) {
            if (operator == Operator.EQUAL) {
                op = "is";
            } else if (operator == Operator.NOT_EQUAL) {
                op = "is not";
            } else {
                // Don't document this since this really is an assertion as the
                // condition is already checked in the constructor.
                throw new IllegalArgumentException(
                    "Operator must be = or != if value is null");
            }
        } else {
            op = operator.toString();
        }

        return conjunction.toString() + conjunctionTrailingSpace
            + columnNameQuote + columnName.canonicalize(alias)
            + columnNameQuote + " " + op + " " + valueQuote + value
            + valueQuote;
    }

    /**
     * Returns this constraint as a Hibernate criterion.
     * 
     * @return a criterion.
     */
    public Criterion toCriterion() {
        // Convert value to an appropriate object.
        Object valueObject;
        Class<?> clazz = columnName.getObjectClass();
        if (clazz == Integer.class || clazz == int.class) {
            valueObject = Integer.parseInt(value);
        } else if (clazz == Float.class || clazz == float.class) {
            valueObject = Float.parseFloat(value);
        } else if (clazz == Double.class || clazz == double.class) {
            valueObject = Double.parseDouble(value);
        } else if (clazz == String.class) {
            valueObject = value;
        } else {
            throw new IllegalStateException("Unexpected type " + clazz
                + " for value in " + toString());
        }

        // Create criterion.
        switch (operator) {
            case EQUAL:
                if (value.equals("null")) {
                    return Restrictions.isNull(columnName.canonicalize(null));
                }
                return Restrictions.eq(columnName.canonicalize(null),
                    valueObject);
            case NOT_EQUAL:
                if (value.equals("null")) {
                    return Restrictions.isNotNull(columnName.canonicalize(null));
                }
                return Restrictions.ne(columnName.canonicalize(null),
                    valueObject);
            case GREATER_THAN:
                return Restrictions.gt(columnName.canonicalize(null),
                    valueObject);
            case GREATER_THAN_OR_EQUAL:
                return Restrictions.ge(columnName.canonicalize(null),
                    valueObject);
            case LESS_THAN:
                return Restrictions.lt(columnName.canonicalize(null),
                    valueObject);
            case LESS_THAN_OR_EQUAL:
                return Restrictions.le(columnName.canonicalize(null),
                    valueObject);
            default:
                throw new IllegalStateException("Unknown operator "
                    + operator.toString());
        }
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result
            + (columnName == null ? 0 : columnName.hashCode());
        result = PRIME * result + (operator == null ? 0 : operator.hashCode());
        result = PRIME * result
            + (conjunction == null ? 0 : conjunction.hashCode());
        result = PRIME * result + (value == null ? 0 : value.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final Constraint other = (Constraint) obj;
        if (columnName == null) {
            if (other.columnName != null) {
                return false;
            }
        } else if (!columnName.equals(other.columnName)) {
            return false;
        }
        if (operator == null) {
            if (other.operator != null) {
                return false;
            }
        } else if (!operator.equals(other.operator)) {
            return false;
        }
        if (conjunction == null) {
            if (other.conjunction != null) {
                return false;
            }
        } else if (!conjunction.equals(other.conjunction)) {
            return false;
        }
        if (value == null) {
            if (other.value != null) {
                return false;
            }
        } else if (!value.equals(other.value)) {
            return false;
        }
        return true;
    }

    /**
     * Parses the given string as a Constraint object.
     * 
     * @param s the string
     * @return the Constraint object.
     * @throws NullPointerException if <code>s</code> is null.
     * @throws ParseException if the string can not be parsed as a Constraint
     * object.
     */
    public static Constraint valueOf(String s) throws ParseException {
        return valueOf(s, null);
    }

    /**
     * Parses the given string as a Constraint object.
     * 
     * @param s the string
     * @param converter a {@link CanonicalizableConverter} object that converts
     * each column name into a {@link Canonicalizable} object.
     * @return the Constraint object.
     * @throws NullPointerException if <code>s</code> is null.
     * @throws ParseException if the string can not be parsed as a Constraint
     * object.
     */
    public static Constraint valueOf(String s,
        CanonicalizableConverter converter) throws ParseException {

        Matcher matcher = pattern.matcher(s);
        if (!matcher.matches() || matcher.group(2) == ""
            || matcher.group(4) == "") {
            throw new ParseException("Could not parse \"" + s + "\"", 0);
        }
        log.debug("s=" + s + ": " + matcher.group(1) + ", " + matcher.group(2)
            + ", " + matcher.group(3) + ", " + matcher.group(4));
        Conjunction conjunction = Conjunction.parse(matcher.group(1));
        final String columnNameString = trimQuotes(matcher.group(2));
        Canonicalizable columnName;
        if (converter != null) {
            columnName = converter.toCanonicalizable(columnNameString);
        } else {
            columnName = new Canonicalizable() {
                public String canonicalize(String alias) {
                    return columnNameString;
                }

                public Class<?> getObjectClass() {
                    return String.class;
                }

                @Override
                public String toString() {
                    return columnNameString;
                }
            };
        }
        Operator operator = Operator.parse(matcher.group(3));
        String value = trimQuotes(matcher.group(4));

        return new Constraint(conjunction, columnName, operator, value);
    }

    /**
     * Parses the given string as a series of Constraint objects. The converse
     * of this operation is {@link #listToString(List)}.
     * 
     * @param s the string
     * @return a non-<code>null</code> list of Constraint objects.
     * @throws ParseException if the string can not be parsed as one or more
     * Constraint objects.
     */
    public static List<Constraint> parseExpression(String s)
        throws ParseException {

        return parseExpression(s, null);
    }

    /**
     * Parses the given string as a series of Constraint objects. The converse
     * of this operation is {@link #listToString(List)}.
     * 
     * @param s the string
     * @param converter a {@link CanonicalizableConverter} object that converts
     * each column name into a {@link Canonicalizable} object.
     * @return a non-<code>null</code> list of Constraint objects.
     * @throws ParseException if the string can not be parsed as one or more
     * Constraint objects.
     */
    public static List<Constraint> parseExpression(String s,
        CanonicalizableConverter converter) throws ParseException {

        List<Constraint> constraintList = new ArrayList<Constraint>();

        if (s == null) {
            return constraintList;
        }

        Matcher matcher = pattern.matcher(s);
        int end = 0;
        while (matcher.find()) {
            if (matcher.start() != end) {
                // We only allow leading whitespace, not garbage.
                throw new ParseException("Unrecognized characters in \"" + s
                    + "\"", end);
            } else if (end > 0 && matcher.group(1)
                .length() == 0) {
                // The conjunction is only optional in the first occurrence.
                throw new ParseException(
                    "Missing conjunction in \"" + s + "\"", matcher.start());
            }
            constraintList.add(valueOf(matcher.group(), converter));
            end = matcher.end();
        }
        if (end != s.length()) {
            throw new ParseException("Could not parse \"" + s + "\"", end);
        }

        return constraintList;
    }

    /**
     * Appends the constraints into a single string. This operation is the
     * converse of {@link #parseExpression(String)}.
     * 
     * @return a string representation of the collection of constraint objects,
     * or an empty string if constraints is <code>null</code> or empty.
     */
    public static String listToString(List<Constraint> constraints) {
        if (constraints == null || constraints.size() == 0) {
            return "";
        }

        StringBuilder s = new StringBuilder();

        int i = 0;
        for (Constraint constraint : constraints) {
            if (i++ > 0) {
                s.append(" ");
            }
            s.append(constraint.toString());
        }

        return s.toString();
    }

    /**
     * Appends the constraints into a single string whose column names are
     * canonicalized. This output is appropriate for an SQL query.
     * 
     * @param alias an alias which is passed to the
     * {@link Canonicalizable#canonicalize(String)} method.
     * @return a string representation of the collection of constraint objects,
     * or an empty string if constraints is <code>null</code> or empty.
     */
    public static String listToCanonicalizedString(
        List<Constraint> constraints, String alias) {
        if (constraints == null || constraints.size() == 0) {
            return "";
        }

        StringBuilder s = new StringBuilder();

        int i = 0;
        for (Constraint constraint : constraints) {
            if (i++ > 0) {
                s.append(" ");
            }
            s.append(constraint.toCanonicalString(alias));
        }

        return s.toString();
    }

    /**
     * Removes single quotes at the beginning and end of string.
     * 
     * @param string a string that may contain single quotes
     * @return a string without single quotes.
     */
    protected static String trimQuotes(String string) {
        StringBuilder s = new StringBuilder(string);
        if (s.charAt(0) == '\'') {
            s.deleteCharAt(0);
            if (s.charAt(s.length() - 1) == '\'') {
                s.deleteCharAt(s.length() - 1);
            }
        }

        return s.toString();
    }

    /**
     * Generates a pattern that matches a string that represents a Constraint
     * object.
     * 
     * @return a pattern.
     */
    private static Pattern createPattern() {
        // Build a string like this:
        // *(|AND|OR) *'?([^ ']+)'? +(<|...|>) +'?([^ ']+)'?
        StringBuilder regexp = new StringBuilder(" *(");
        boolean insertPipe = false;
        for (Conjunction c : Conjunction.values()) {
            insertPipe = appendValue(regexp, insertPipe, c);
        }
        regexp.append(") *('[^']+'|[^ ]+) +(");
        insertPipe = false;
        for (Operator c : Operator.values()) {
            insertPipe = appendValue(regexp, insertPipe, c);
        }
        regexp.append(") +('[^']+'|[^ ]+)");
        log.debug("Built regexp " + regexp.toString());

        return Pattern.compile(regexp.toString());
    }

    /**
     * Simple helper method that appends the object, as a string, to the regexp,
     * inserting a "|" if necessary.
     * 
     * @param regexp the regexp.
     * @param insertPipe whether to insert a pipe.
     * @param o the object to append
     * @return <code>true</code>, always, since once this method is called,
     * subsequent calls must insert a pipe.
     */
    private static boolean appendValue(StringBuilder regexp,
        boolean insertPipe, Object o) {
        String s = o.toString();
        if (insertPipe) {
            regexp.append("|");
        }
        if (s.length() > 0) {
            regexp.append(s);
        }

        return true;
    }

    /**
     * An interface for turning strings into objects.
     * 
     * @author Bill Wohler
     */
    public interface CanonicalizableConverter {
        Canonicalizable toCanonicalizable(String string);
    }
}
