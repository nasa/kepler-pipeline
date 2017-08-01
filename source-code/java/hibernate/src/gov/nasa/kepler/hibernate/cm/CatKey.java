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

import static gov.nasa.kepler.hibernate.cm.Kic.DEFAULT_FLOAT_FMT;
import static gov.nasa.kepler.hibernate.cm.Kic.DEFAULT_INT_FMT;
import static gov.nasa.kepler.hibernate.cm.Kic.DEFAULT_STRING_FMT;
import static gov.nasa.kepler.hibernate.cm.Kic.SCP_DELIMITER;
import static gov.nasa.kepler.hibernate.cm.Kic.SCP_DELIMITER_CHAR;
import gov.nasa.kepler.hibernate.Canonicalizable;

import java.util.Locale;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

/**
 * A record in the CATKEY database. This class is immutable.
 * <p>
 * See KSOC-21163 Catalog Management.<br>
 * See KSOC-21113 SOC SCP ICD.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "CM_CATKEY")
public class CatKey {
    private static final int CATKEY_FIELD_COUNT = 14;

    /**
     * An enum of the CATKEY columns. These use the same text and appear in the
     * same order as they appear in the ICD.
     */
    public static enum Field implements Canonicalizable {
        CATKEY("id", Integer.TYPE, DEFAULT_INT_FMT),
        CATFLAG("flag", Integer.TYPE, DEFAULT_INT_FMT),
        TYCHOID("tychoId", Integer.class, DEFAULT_INT_FMT),
        UCACID("ucacId", Integer.class, DEFAULT_INT_FMT),
        GCVSID("gcvsId", Integer.class, DEFAULT_INT_FMT),
        SOURCE("source", String.class, DEFAULT_STRING_FMT),
        SOURCEID("sourceId", Integer.class, DEFAULT_INT_FMT),
        FLUX1("firstFlux", Integer.class, DEFAULT_INT_FMT),
        FLUX2("secondFlux", Integer.class, DEFAULT_INT_FMT),
        RAEPOCH("raEpoch", Float.class, DEFAULT_FLOAT_FMT),
        DECEPOCH("decEpoch", Float.class, DEFAULT_FLOAT_FMT),
        JMAG("jMag", Float.class, DEFAULT_FLOAT_FMT),
        HMAG("hMag", Float.class, DEFAULT_FLOAT_FMT),
        KMAG("kMag", Float.class, DEFAULT_FLOAT_FMT);

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
    @Column(name = "CATKEY", nullable = false)
    private int id;

    @Column(name = "CATFLAG", nullable = false)
    private int flag;

    @Column(name = "TYCHOID")
    private Integer tychoId;

    @Column(name = "UCACID")
    private Integer ucacId;

    @Column(name = "GCVSID")
    private Integer gcvsId;

    @Column(name = "SOURCE", nullable = false)
    private String source;

    @Column(name = "SOURCEID")
    private Integer sourceId;

    @Column(name = "FLUX1")
    private Integer firstFlux;

    @Column(name = "FLUX2")
    private Integer secondFlux;

    @Column(name = "RAEPOCH")
    private Float raEpoch;

    @Column(name = "DECEPOCH")
    private Float decEpoch;

    @Column(name = "JMAG")
    private Float jMag;

    @Column(name = "HMAG")
    private Float hMag;

    @Column(name = "KMAG")
    private Float kMag;

    /**
     * Default constructor for Hibernate use only.
     */
    CatKey() {
    }

    /**
     * Creates a {@link CatKey} object.
     * 
     * @throws IllegalArgumentException if source is null.
     */
    public CatKey(int id, int flag, Integer tychoId, Integer ucacId,
        Integer gcvsId, String source, Integer sourceId, Integer firstFlux,
        Integer secondFlux, Float raEpoch, Float decEpoch, Float jMag,
        Float hMag, Float kMag) {

        if (source == null) {
            throw new IllegalArgumentException("source can't be null");
        }

        this.id = id;
        this.flag = flag;
        this.tychoId = tychoId;
        this.ucacId = ucacId;
        this.gcvsId = gcvsId;
        this.source = source;
        this.sourceId = sourceId;
        this.firstFlux = firstFlux;
        this.secondFlux = secondFlux;
        this.raEpoch = raEpoch;
        this.decEpoch = decEpoch;
        this.jMag = jMag;
        this.hMag = hMag;
        this.kMag = kMag;
    }

    // Accessors, in alphabetical order.

    public Float getDecEpoch() {
        return decEpoch;
    }

    public Integer getFirstFlux() {
        return firstFlux;
    }

    public int getFlag() {
        return flag;
    }

    public Integer getGcvsId() {
        return gcvsId;
    }

    public Float getHMag() {
        return hMag;
    }

    public int getId() {
        return id;
    }

    public Float getJMag() {
        return jMag;
    }

    public Float getKMag() {
        return kMag;
    }

    public Float getRaEpoch() {
        return raEpoch;
    }

    public Integer getSecondFlux() {
        return secondFlux;
    }

    public String getSource() {
        return source;
    }

    public Integer getSourceId() {
        return sourceId;
    }

    public Integer getTychoId() {
        return tychoId;
    }

    public Integer getUcacId() {
        return ucacId;
    }

    /**
     * Creates a {@link CatKey} object for the string argument. The format of
     * the string is defined by SOC SCP ICD (KSOC-21113). In particular, the
     * fields are separated by the pipe (|) symbol, in the same order as the
     * fields are defined.
     * 
     * @param s a {@link String} containing the {@link CatKey} object
     * representation to be parsed.
     * @return the {@link CatKey} object represented by the argument
     * @throws NullPointerException if the string is null.
     * @throws IllegalArgumentException if there aren't enough fields.
     * @throws ArrayIndexOutOfBoundsException if there aren't enough required
     * values.
     */
    public static CatKey valueOf(String s) throws Exception {
        // Check that we have the correct number of delimiters.
        int delimiterCount = 0;
        for (int i = s.length() - 1; i >= 0; i--) {
            if (s.charAt(i) == SCP_DELIMITER_CHAR) {
                delimiterCount++;
            }
        }
        if (delimiterCount + 1 < CATKEY_FIELD_COUNT) {
            throw new IllegalArgumentException(
                "Not enough fields in record: \n" + s);
        }

        String[] fields = s.split("\\" + SCP_DELIMITER);

        return new CatKey(Integer.valueOf(fields[0]),
            Integer.valueOf(fields[1]), Kic.intValueOf(fields, 2),
            Kic.intValueOf(fields, 3), Kic.intValueOf(fields, 4), fields[5],
            Kic.intValueOf(fields, 6), Kic.intValueOf(fields, 7),
            Kic.intValueOf(fields, 8), Kic.floatValueOf(fields, 9),
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
        final CatKey other = (CatKey) obj;
        if (id != other.id) {
            return false;
        }

        return true;
    }

    /**
     * Formats this {@link CatKey} record as it is expected to be imported and
     * exported.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();

        s.append(Field.CATKEY.format(id))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.CATFLAG.format(flag))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.TYCHOID.format(tychoId))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.UCACID.format(ucacId))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.GCVSID.format(gcvsId))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SOURCE.format(source))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.SOURCEID.format(sourceId))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.FLUX1.format(firstFlux))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.FLUX2.format(secondFlux))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.RAEPOCH.format(raEpoch))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.DECEPOCH.format(decEpoch))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.JMAG.format(jMag))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.HMAG.format(hMag))
            .append(SCP_DELIMITER_CHAR)
            .append(Field.KMAG.format(kMag));

        return s.toString();
    }
}
