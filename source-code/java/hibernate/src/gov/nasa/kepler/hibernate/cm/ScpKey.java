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

package gov.nasa.kepler.hibernate.cm;

import static gov.nasa.kepler.hibernate.cm.Kic.DEFAULT_DOUBLE_FMT;
import static gov.nasa.kepler.hibernate.cm.Kic.DEFAULT_FLOAT_FMT;
import static gov.nasa.kepler.hibernate.cm.Kic.DEFAULT_INT_FMT;
import static gov.nasa.kepler.hibernate.cm.Kic.SCP_DELIMITER;
import static gov.nasa.kepler.hibernate.cm.Kic.SCP_DELIMITER_CHAR;
import gov.nasa.kepler.hibernate.Canonicalizable;

import java.util.Locale;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * A record in the SCPKEY database. This class is immutable.
 * <p>
 * See KSOC-21163 Catalog Management.<br>
 * See KSOC-21113 SOC SCP ICD.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "CM_SCPKEY")
public class ScpKey {
    private static final int SCPKEY_FIELD_COUNT = 14;

    // Exceptions for format constants.
    private static final String SCP_FIBER_RA_FMT = "%.7f";
    private static final String SCP_VSINI_FMT = "%.2f";

    /**
     * An enum of the SCPKEY's columns. These use the same text and appear in
     * the same order as they appear in the ICD.
     */
    public static enum Field implements Canonicalizable {
        SCPKEY("id", Integer.TYPE, DEFAULT_INT_FMT),
        SCP_FIBER_RA("fiberRa", Double.class, SCP_FIBER_RA_FMT),
        SCP_FIBER_DEC("fiberDec", Double.class, DEFAULT_DOUBLE_FMT),
        SCP_TEFF("effectiveTemp", Integer.class, DEFAULT_INT_FMT),
        SCP_TEFF_ERR("effectiveTempErr", Integer.class, DEFAULT_INT_FMT),
        SCP_LOGG("log10SurfaceGravity", Float.class, DEFAULT_FLOAT_FMT),
        SCP_LOGG_ERR("log10SurfaceGravityErr", Float.class, DEFAULT_FLOAT_FMT),
        SCP_FEH("log10Metallicity", Float.class, DEFAULT_FLOAT_FMT),
        SCP_FEH_ERR("log10MetallicityErr", Float.class, DEFAULT_FLOAT_FMT),
        SCP_VSINI("rotationalVelocitySin", Float.class, SCP_VSINI_FMT),
        SCP_VSINI_ERR("rotationalVelocitySinErr",
            Float.class,
            DEFAULT_FLOAT_FMT),

        SCP_RV("radialVelocity", Float.class, DEFAULT_FLOAT_FMT),
        SCP_RV_ERR("radialVelocityErr", Float.class, DEFAULT_FLOAT_FMT),
        SCP_CCPH("crossCorrelationPeak", Float.class, DEFAULT_FLOAT_FMT);

        private String name;
        private Class<?> c;
        private final String format;

        private Field(String name, Class<?> c, String format) {
            this.name = name;
            this.c = c;
            this.format = format;
        }

        /**
         * Returns the class of the column.
         */
        @Override
        public Class<?> getObjectClass() {
            return c;
        }

        /**
         * Returns the fully qualified name of the column which includes the
         * table's alias.
         * 
         * @param alias the alias used for the CM_KIC table in the query. If
         * <code>null</code>, then "kic" is used.
         */
        @Override
        public String canonicalize(String alias) {
            return (alias != null ? alias : "kic") + "." + name;
        }

        /**
         * Returns a formatted string for the given value using an appropriate
         * format string for this field. An empty string is returned if the
         * value is {@code null}.
         * 
         * @param value the value to format
         * @return the value, formatted
         */
        public String format(Object value) {
            if (value == null) {
                return "";
            }
            return String.format(Locale.US, format, value);
        }

        /**
         * Returns the appropriate format string for this field.
         * 
         * @return the format string
         */
        public String getFormat() {
            return format;
        }
    }

    @Id
    @Column(name = "SCPKEY", nullable = false)
    private int id;

    @Column(name = "SCP_FIBER_RA")
    private Double fiberRa;

    @Column(name = "SCP_FIBER_DEC")
    private Double fiberDec;

    @Column(name = "SCP_TEFF")
    private Integer effectiveTemp;

    @Column(name = "SCP_TEFF_ERR")
    private Integer effectiveTempErr;

    @Column(name = "SCP_LOGG")
    private Float log10SurfaceGravity;

    @Column(name = "SCP_LOGG_ERR")
    private Float log10SurfaceGravityErr;

    @Column(name = "SCP_FEH")
    private Float log10Metallicity;

    @Column(name = "SCP_FEH_ERR")
    private Float log10MetallicityErr;

    @Column(name = "SCP_VSINI")
    private Float rotationalVelocitySin;

    @Column(name = "SCP_VSINI_ERR")
    private Float rotationalVelocitySinErr;

    @Column(name = "SCP_RV")
    private Float radialVelocity;

    @Column(name = "SCP_RV_ERR")
    private Float radialVelocityErr;

    @Column(name = "SCP_CCPH")
    private Float crossCorrelationPeak;

    /**
     * Default constructor for Hibernate use only.
     */
    ScpKey() {
    }

    public ScpKey(int id, Double fiberRa, Double fiberDec,
        Integer effectiveTemp, Integer effectiveTempErr,
        Float log10SurfaceGravity, Float log10SurfaceGravityErr,
        Float log10Metallicity, Float log10MetallicityErr,
        Float rotationalVelocitySin, Float rotationalVelocitySinErr,
        Float radialVelocity, Float radialVelocityErr,
        Float crossCorrelationPeak) {

        this.id = id;
        this.fiberRa = fiberRa;
        this.fiberDec = fiberDec;
        this.effectiveTemp = effectiveTemp;
        this.effectiveTempErr = effectiveTempErr;
        this.log10SurfaceGravity = log10SurfaceGravity;
        this.log10SurfaceGravityErr = log10SurfaceGravityErr;
        this.log10Metallicity = log10Metallicity;
        this.log10MetallicityErr = log10MetallicityErr;
        this.rotationalVelocitySin = rotationalVelocitySin;
        this.rotationalVelocitySinErr = rotationalVelocitySinErr;
        this.radialVelocity = radialVelocity;
        this.radialVelocityErr = radialVelocityErr;
        this.crossCorrelationPeak = crossCorrelationPeak;
    }

    // Accessors, in alphabetical order.

    public Float getCrossCorrelationPeak() {
        return crossCorrelationPeak;
    }

    public Integer getEffectiveTemp() {
        return effectiveTemp;
    }

    public Integer getEffectiveTempErr() {
        return effectiveTempErr;
    }

    public Double getFiberDec() {
        return fiberDec;
    }

    public Double getFiberRa() {
        return fiberRa;
    }

    public int getId() {
        return id;
    }

    public Float getLog10Metallicity() {
        return log10Metallicity;
    }

    public Float getLog10MetallicityErr() {
        return log10MetallicityErr;
    }

    public Float getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public Float getLog10SurfaceGravityErr() {
        return log10SurfaceGravityErr;
    }

    public Float getRadialVelocity() {
        return radialVelocity;
    }

    public Float getRadialVelocityErr() {
        return radialVelocityErr;
    }

    public Float getRotationalVelocitySin() {
        return rotationalVelocitySin;
    }

    public Float getRotationalVelocitySinErr() {
        return rotationalVelocitySinErr;
    }

    /**
     * Creates a {@link ScpKey} object for the string argument. The format of
     * the string is defined by SOC SCP ICD (KSOC-21113). In particular, the
     * fields are separated by the pipe (|) symbol, in the same order as the
     * fields are defined.
     * 
     * @param s a {@link String} containing the {@link ScpKey} object
     * representation to be parsed.
     * @return the {@link ScpKey} object represented by the argument
     * @throws NullPointerException if the string is null.
     * @throws IllegalArgumentException if there aren't enough fields.
     * @throws ArrayIndexOutOfBoundsException if there aren't enough required
     * values.
     */
    public static ScpKey valueOf(String s) throws Exception {
        // Check that we have the correct number of delimiters.
        int delimiterCount = 0;
        for (int i = s.length() - 1; i >= 0; i--) {
            if (s.charAt(i) == SCP_DELIMITER_CHAR) {
                delimiterCount++;
            }
        }
        if (delimiterCount + 1 < SCPKEY_FIELD_COUNT) {
            throw new IllegalArgumentException(
                "Not enough fields in record: \n" + s);
        }

        String[] fields = s.split("\\" + SCP_DELIMITER);

        return new ScpKey(Integer.valueOf(fields[0]), Kic.doubleValueOf(fields,
            1), Kic.doubleValueOf(fields, 2), Kic.intValueOf(fields, 3),
            Kic.intValueOf(fields, 4), Kic.floatValueOf(fields, 5),
            Kic.floatValueOf(fields, 6), Kic.floatValueOf(fields, 7),
            Kic.floatValueOf(fields, 8), Kic.floatValueOf(fields, 9),
            Kic.floatValueOf(fields, 10), Kic.floatValueOf(fields, 11),
            Kic.floatValueOf(fields, 12), Kic.floatValueOf(fields, 13));
    }

    @Override
    public int hashCode() {
        return id;
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
        final ScpKey other = (ScpKey) obj;
        if (id != other.id) {
            return false;
        }

        return true;
    }

    /**
     * Formats this {@link ScpKey} record as it is expected to be imported and
     * exported.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();

        s.append(Field.SCPKEY.format(id))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_FIBER_RA.format(fiberRa))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_FIBER_DEC.format(fiberDec))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_TEFF.format(effectiveTemp))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_TEFF_ERR.format(effectiveTempErr))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_LOGG.format(log10SurfaceGravity))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_LOGG_ERR.format(log10SurfaceGravityErr))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_FEH.format(log10Metallicity))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_FEH_ERR.format(log10MetallicityErr))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_VSINI.format(rotationalVelocitySin))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_VSINI_ERR.format(rotationalVelocitySinErr))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_RV.format(radialVelocity))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_RV_ERR.format(radialVelocityErr))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SCP_CCPH.format(crossCorrelationPeak));

        return s.toString();
    }
}
