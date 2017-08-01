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

import gov.nasa.kepler.hibernate.Canonicalizable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.util.Locale;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;

import org.hibernate.annotations.Index;

/**
 * A record in the Kepler Input Catalog (KIC). Each record describes a star in
 * the Kepler field of view plus 5 arc minutes.
 * <p>
 * The {@link #toString()} method converts a {@link Kic} object back to the SCP
 * format. The format* methods which perform the actual formatting are package
 * visible in the rare case that they are needed. If the value for the attribute
 * is null in these methods, then nothing will be formatted.
 * <p>
 * Because of the number of fields, constructors that cover any or all of the
 * fields are impractical and therefore not provided. To create a Kic object,
 * use the Builder inner class. For example,
 * 
 * <pre>
 * Kic kic = new Kic.Builder(keplerId, ra, dec).raProperMotion(1.234F)
 *     .decProperMotion(5.678F)
 *     .build();
 * </pre>
 * 
 * See KSOC-21163 Catalog Management.<br>
 * See KSOC-21113 SOC SCP ICD.
 * 
 * @author Bill Wohler
 * @author Sean McCauliff
 * @author Thomas Han
 */
@Entity
@Table(name = "CM_KIC")
@ProxyIgnoreStatics
public class Kic implements CelestialObject {

    private static final String KIC_PROVENANCE = "KIC";

    public static final int SCP_FIELD_COUNT = 41;
    public static final String SCP_DELIMITER = "|";
    public static final char SCP_DELIMITER_CHAR = '|';

    // Format constants. The latter constants are for the exceptions.
    static final String DEFAULT_INT_FMT = "%d";
    static final String DEFAULT_FLOAT_FMT = "%.3f";
    static final String DEFAULT_DOUBLE_FMT = "%.6f";
    static final String DEFAULT_STRING_FMT = "%s";

    private static final String RA_FMT = "%.7f";
    private static final String PMRA_FMT = "%.4f";
    private static final String PMDEC_FMT = "%.4f";
    private static final String PARALLAX_FMT = "%.4f";
    private static final String PMTOTAL_FMT = "%.4f";

    /**
     * An enum of the KIC's columns. These use the same text and appear in the
     * same order as they appear in the ICD. The skyGroupId field comes first
     * since it will probably be the most oft-used in the UI.
     */
    public static enum Field implements Canonicalizable {
        SKY_GROUP_ID("skyGroupId", Integer.TYPE, DEFAULT_INT_FMT),
        RA("ra", Double.TYPE, RA_FMT),
        DEC("dec", Double.TYPE, DEFAULT_DOUBLE_FMT),
        PMRA("raProperMotion", Float.class, PMRA_FMT),
        PMDEC("decProperMotion", Float.class, PMDEC_FMT),
        UMAG("uMag", Float.class, DEFAULT_FLOAT_FMT),
        GMAG("gMag", Float.class, DEFAULT_FLOAT_FMT),
        RMAG("rMag", Float.class, DEFAULT_FLOAT_FMT),
        IMAG("iMag", Float.class, DEFAULT_FLOAT_FMT),
        ZMAG("zMag", Float.class, DEFAULT_FLOAT_FMT),
        GREDMAG("gredMag", Float.class, DEFAULT_FLOAT_FMT),
        D51MAG("d51Mag", Float.class, DEFAULT_FLOAT_FMT),
        JMAG("twoMassJMag", Float.class, DEFAULT_FLOAT_FMT),
        HMAG("twoMassHMag", Float.class, DEFAULT_FLOAT_FMT),
        KMAG("twoMassKMag", Float.class, DEFAULT_FLOAT_FMT),
        KEPMAG("keplerMag", Float.class, DEFAULT_FLOAT_FMT),
        KEPLER_ID("keplerId", Integer.TYPE, DEFAULT_INT_FMT),
        TMID("twoMassId", Integer.class, DEFAULT_INT_FMT),
        SCPID("internalScpId", Integer.class, DEFAULT_INT_FMT),
        ALTID("alternateId", Integer.class, DEFAULT_INT_FMT),
        ALTSOURCE("alternateSource", Integer.class, DEFAULT_INT_FMT),
        GALAXY("galaxyIndicator", Integer.class, DEFAULT_INT_FMT),
        BLEND("blendIndicator", Integer.class, DEFAULT_INT_FMT),
        VARIABLE("variableIndicator", Integer.class, DEFAULT_INT_FMT),
        TEFF("effectiveTemp", Integer.class, DEFAULT_INT_FMT),
        LOGG("log10SurfaceGravity", Float.class, DEFAULT_FLOAT_FMT),
        FEH("log10Metallicity", Float.class, DEFAULT_FLOAT_FMT),
        EBMINUSV("ebMinusVRedding", Float.class, DEFAULT_FLOAT_FMT),
        AV("avExtinction", Float.class, DEFAULT_FLOAT_FMT),
        RADIUS("radius", Float.class, DEFAULT_FLOAT_FMT),
        CQ("source", String.class, DEFAULT_STRING_FMT),
        PQ("photometryQuality", Integer.class, DEFAULT_INT_FMT),
        AQ("astrophysicsQuality", Integer.class, DEFAULT_INT_FMT),
        CATKEY("catalogId", Integer.class, DEFAULT_INT_FMT),
        SCPKEY("scpId", Integer.class, DEFAULT_INT_FMT),
        PARALLAX("parallax", Float.class, PARALLAX_FMT),
        GLON("galacticLongitude", Double.class, DEFAULT_DOUBLE_FMT),
        GLAT("galacticLatitude", Double.class, DEFAULT_DOUBLE_FMT),
        PMTOTAL("totalProperMotion", Float.class, PMTOTAL_FMT),
        GRCOLOR("grColor", Float.class, DEFAULT_FLOAT_FMT),
        JKCOLOR("jkColor", Float.class, DEFAULT_FLOAT_FMT),
        GKCOLOR("gkColor", Float.class, DEFAULT_FLOAT_FMT);

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
    @Column(nullable = false)
    private int keplerId;

    // If the sky group is 0, then the object is off the field of view (FOV)
    // (SOC-specific column).
    // SOC_REQ_IMPL 164.CM.2
    @Column(nullable = false)
    @Index(name = "CM_KIC_SKY_GROUP_ID_IDX")
    private int skyGroupId;

    @Column(nullable = false)
    private double ra;

    @Column(name = "`DEC`", nullable = false)
    private double dec;

    @Column(name = "PMRA")
    private Float raProperMotion;

    @Column(name = "PMDEC")
    private Float decProperMotion;

    @Column(name = "UMAG")
    private Float uMag;

    @Column(name = "GMAG")
    private Float gMag;

    @Column(name = "RMAG")
    private Float rMag;

    @Column(name = "IMAG")
    private Float iMag;

    @Column(name = "ZMAG")
    private Float zMag;

    @Column(name = "GREDMAG")
    private Float gredMag;

    @Column(name = "D51MAG")
    private Float d51Mag;

    @Column(name = "JMAG")
    private Float twoMassJMag;

    @Column(name = "HMAG")
    private Float twoMassHMag;

    @Column(name = "KMAG")
    private Float twoMassKMag;

    @Column(name = "KEPMAG")
    @Index(name = "CM_KIC_KEPMAG_IDX")
    private Float keplerMag;

    @Column(name = "TMID")
    private Integer twoMassId;

    @Column(name = "SCPID")
    private Integer internalScpId;

    @Column(name = "ALTID")
    private Integer alternateId;

    @Column(name = "ALTSOURCE")
    private Integer alternateSource;

    @Column(name = "GALAXY")
    private Integer galaxyIndicator;

    @Column(name = "BLEND")
    private Integer blendIndicator;

    @Column(name = "VARIABLE")
    private Integer variableIndicator;

    @Column(name = "TEFF")
    private Integer effectiveTemp;

    @Column(name = "LOGG")
    private Float log10SurfaceGravity;

    @Column(name = "FEH")
    private Float log10Metallicity;

    @Column(name = "EBMINUSV")
    private Float ebMinusVRedding;

    @Column(name = "AV")
    private Float avExtinction;

    @Column(name = "RADIUS")
    private Float radius;

    @Column(name = "CQ")
    private String source;

    @Column(name = "PQ")
    private Integer photometryQuality;

    @Column(name = "AQ")
    private Integer astrophysicsQuality;

    @Column(name = "CATKEY")
    private Integer catalogId;

    @Column(name = "SCPKEY")
    private Integer scpId;

    @Column(name = "PARALLAX")
    private Float parallax;

    @Column(name = "GLON")
    private Double galacticLongitude;

    @Column(name = "GLAT")
    private Double galacticLatitude;

    @Column(name = "PMTOTAL")
    private Float totalProperMotion;

    @Column(name = "GRCOLOR")
    private Float grColor;

    @Column(name = "JKCOLOR")
    private Float jkColor;

    @Column(name = "GKCOLOR")
    private Float gkColor;

    /**
     * Creates a Kic object. For use only by the inner {@link Builder} class,
     * mock objects, and Hibernate.
     */
    Kic() {
    }

    /**
     * Creates a copy of the given {@link Kic} object.
     */
    private Kic(Kic kic) {

        ra = kic.ra;
        dec = kic.dec;
        raProperMotion = kic.raProperMotion;
        decProperMotion = kic.decProperMotion;
        uMag = kic.uMag;
        gMag = kic.gMag;
        rMag = kic.rMag;
        iMag = kic.iMag;
        zMag = kic.zMag;
        gredMag = kic.gredMag;
        d51Mag = kic.d51Mag;
        twoMassJMag = kic.twoMassJMag;
        twoMassHMag = kic.twoMassHMag;
        twoMassKMag = kic.twoMassKMag;
        keplerMag = kic.keplerMag;
        keplerId = kic.keplerId;
        twoMassId = kic.twoMassId;
        internalScpId = kic.internalScpId;
        alternateId = kic.alternateId;
        alternateSource = kic.alternateSource;
        galaxyIndicator = kic.galaxyIndicator;
        blendIndicator = kic.blendIndicator;
        variableIndicator = kic.variableIndicator;
        effectiveTemp = kic.effectiveTemp;
        log10SurfaceGravity = kic.log10SurfaceGravity;
        log10Metallicity = kic.log10Metallicity;
        ebMinusVRedding = kic.ebMinusVRedding;
        avExtinction = kic.avExtinction;
        radius = kic.radius;
        source = kic.source;
        photometryQuality = kic.photometryQuality;
        astrophysicsQuality = kic.astrophysicsQuality;
        catalogId = kic.catalogId;
        scpId = kic.scpId;
        parallax = kic.parallax;
        galacticLongitude = kic.galacticLongitude;
        galacticLatitude = kic.galacticLatitude;
        totalProperMotion = kic.totalProperMotion;
        grColor = kic.grColor;
        jkColor = kic.jkColor;
        gkColor = kic.gkColor;
        skyGroupId = kic.skyGroupId;
    }

    /**
     * Creates a {@link Kic} object with the given builder.
     */
    private Kic(Builder builder) {

        ra = builder.kic.ra;
        dec = builder.kic.dec;
        raProperMotion = builder.kic.raProperMotion;
        decProperMotion = builder.kic.decProperMotion;
        uMag = builder.kic.uMag;
        gMag = builder.kic.gMag;
        rMag = builder.kic.rMag;
        iMag = builder.kic.iMag;
        zMag = builder.kic.zMag;
        gredMag = builder.kic.gredMag;
        d51Mag = builder.kic.d51Mag;
        twoMassJMag = builder.kic.twoMassJMag;
        twoMassHMag = builder.kic.twoMassHMag;
        twoMassKMag = builder.kic.twoMassKMag;
        keplerMag = builder.kic.keplerMag;
        keplerId = builder.kic.keplerId;
        twoMassId = builder.kic.twoMassId;
        internalScpId = builder.kic.internalScpId;
        alternateId = builder.kic.alternateId;
        alternateSource = builder.kic.alternateSource;
        galaxyIndicator = builder.kic.galaxyIndicator;
        blendIndicator = builder.kic.blendIndicator;
        variableIndicator = builder.kic.variableIndicator;
        effectiveTemp = builder.kic.effectiveTemp;
        log10SurfaceGravity = builder.kic.log10SurfaceGravity;
        log10Metallicity = builder.kic.log10Metallicity;
        ebMinusVRedding = builder.kic.ebMinusVRedding;
        avExtinction = builder.kic.avExtinction;
        radius = builder.kic.radius;
        source = builder.kic.source;
        photometryQuality = builder.kic.photometryQuality;
        astrophysicsQuality = builder.kic.astrophysicsQuality;
        catalogId = builder.kic.catalogId;
        scpId = builder.kic.scpId;
        parallax = builder.kic.parallax;
        galacticLongitude = builder.kic.galacticLongitude;
        galacticLatitude = builder.kic.galacticLatitude;
        totalProperMotion = builder.kic.totalProperMotion;
        grColor = builder.kic.grColor;
        jkColor = builder.kic.jkColor;
        gkColor = builder.kic.gkColor;
        skyGroupId = builder.kic.skyGroupId;
    }

    // Accessors and formatters, in alphabetical order.

    @Override
    public Integer getAlternateId() {
        return alternateId;
    }

    @Override
    public Integer getAlternateSource() {
        return alternateSource;
    }

    @Override
    public Integer getAstrophysicsQuality() {
        return astrophysicsQuality;
    }

    @Override
    public Float getAvExtinction() {
        return avExtinction;
    }

    @Override
    public Integer getBlendIndicator() {
        return blendIndicator;
    }

    @Override
    public Integer getCatalogId() {
        return catalogId;
    }

    @Override
    public Float getD51Mag() {
        return d51Mag;
    }

    @Override
    public double getDec() {
        return dec;
    }

    @Override
    public Float getDecProperMotion() {
        return decProperMotion;
    }

    @Override
    public Float getEbMinusVRedding() {
        return ebMinusVRedding;
    }

    @Override
    public Integer getEffectiveTemp() {
        return effectiveTemp;
    }

    @Override
    public Double getGalacticLatitude() {
        return galacticLatitude;
    }

    @Override
    public Double getGalacticLongitude() {
        return galacticLongitude;
    }

    @Override
    public Integer getGalaxyIndicator() {
        return galaxyIndicator;
    }

    @Override
    public Float getGkColor() {
        return gkColor;
    }

    @Override
    public Float getGMag() {
        return gMag;
    }

    @Override
    public Float getGrColor() {
        return grColor;
    }

    @Override
    public Float getGredMag() {
        return gredMag;
    }

    @Override
    public Float getIMag() {
        return iMag;
    }

    @Override
    public Float getJkColor() {
        return jkColor;
    }

    @Override
    public Integer getInternalScpId() {
        return internalScpId;
    }

    @Override
    public int getKeplerId() {
        return keplerId;
    }

    @Override
    public Float getKeplerMag() {
        return keplerMag;
    }

    @Override
    public Float getLog10Metallicity() {
        return log10Metallicity;
    }

    @Override
    public Float getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    @Override
    public Float getParallax() {
        return parallax;
    }

    @Override
    public Integer getPhotometryQuality() {
        return photometryQuality;
    }

    @Override
    public String getProvenance() {
        return KIC_PROVENANCE;
    }

    @Override
    public double getRa() {
        return ra;
    }

    @Override
    public Float getRadius() {
        return radius;
    }

    @Override
    public Float getRaProperMotion() {
        return raProperMotion;
    }

    @Override
    public Float getRMag() {
        return rMag;
    }

    @Override
    public Integer getScpId() {
        return scpId;
    }

    @Override
    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    @Override
    public String getSource() {
        return source;
    }

    @Override
    public Float getTotalProperMotion() {
        return totalProperMotion;
    }

    @Override
    public Float getTwoMassHMag() {
        return twoMassHMag;
    }

    @Override
    public Integer getTwoMassId() {
        return twoMassId;
    }

    @Override
    public Float getTwoMassJMag() {
        return twoMassJMag;
    }

    @Override
    public Float getTwoMassKMag() {
        return twoMassKMag;
    }

    @Override
    public Float getUMag() {
        return uMag;
    }

    @Override
    public Integer getVariableIndicator() {
        return variableIndicator;
    }

    @Override
    public Float getZMag() {
        return zMag;
    }

    /**
     * Creates a {@link Kic} object for the string argument. The format of the
     * string is defined by the SOC SCP ICD (KSOC-21113).
     * 
     * @param s a {@link String} containing the {@link Kic} object
     * representation to be parsed
     * @return the {@link Kic} object represented by the argument
     * @throws NullPointerException if the string is null
     * @throws IllegalArgumentException if there aren't enough fields
     * @throws ArrayIndexOutOfBoundsException if there aren't enough required
     * values
     */
    public static Kic valueOf(String s) throws Exception {
        // Check that we have the correct number of delimiters.
        int delimiterCount = 0;
        for (int i = s.length() - 1; i >= 0; i--) {
            if (s.charAt(i) == SCP_DELIMITER_CHAR) {
                delimiterCount++;
            }
        }
        if (delimiterCount + 1 < SCP_FIELD_COUNT) {
            throw new IllegalArgumentException(
                "Not enough fields in record: \n" + s);
        }

        String[] fields = s.split("\\" + SCP_DELIMITER);

        // Note that split discards trailing empty fields; hence the
        // check for the array length before accessing the elements.
        // Sorry about the long lines.
        Kic kic = new Kic.Builder(Integer.parseInt(fields[15]),
            Double.parseDouble(fields[0]), Double.parseDouble(fields[1])).raProperMotion(
            floatValueOf(fields, 2))
            .decProperMotion(floatValueOf(fields, 3))
            .uMag(floatValueOf(fields, 4))
            .gMag(floatValueOf(fields, 5))
            .rMag(floatValueOf(fields, 6))
            .iMag(floatValueOf(fields, 7))
            .zMag(floatValueOf(fields, 8))
            .gredMag(floatValueOf(fields, 9))
            .d51Mag(floatValueOf(fields, 10))
            .twoMassJMag(floatValueOf(fields, 11))
            .twoMassHMag(floatValueOf(fields, 12))
            .twoMassKMag(floatValueOf(fields, 13))
            .keplerMag(floatValueOf(fields, 14))
            .twoMassId(intValueOf(fields, 16))
            .internalScpId(intValueOf(fields, 17))
            .alternateId(intValueOf(fields, 18))
            .alternateSource(intValueOf(fields, 19))
            .galaxyIndicator(intValueOf(fields, 20))
            .blendIndicator(intValueOf(fields, 21))
            .variableIndicator(intValueOf(fields, 22))
            .effectiveTemp(intValueOf(fields, 23))
            .log10SurfaceGravity(floatValueOf(fields, 24))
            .log10Metallicity(floatValueOf(fields, 25))
            .ebMinusVRedding(floatValueOf(fields, 26))
            .avExtinction(floatValueOf(fields, 27))
            .radius(floatValueOf(fields, 28))
            .source(stringValueOf(fields, 29))
            .photometryQuality(intValueOf(fields, 30))
            .astrophysicsQuality(intValueOf(fields, 31))
            .catalogId(intValueOf(fields, 32))
            .scpId(intValueOf(fields, 33))
            .parallax(floatValueOf(fields, 34))
            .galacticLongitude(doubleValueOf(fields, 35))
            .galacticLatitude(doubleValueOf(fields, 36))
            .totalProperMotion(floatValueOf(fields, 37))
            .grColor(floatValueOf(fields, 38))
            .jkColor(floatValueOf(fields, 39))
            .gkColor(floatValueOf(fields, 40))
            .build();

        return kic;
    }

    /**
     * Convenience method for {@link #valueOf(String)} that returns an
     * {@link String} value for a string if the given array has enough elements
     * and the given element is non-null.
     * 
     * @param fields an array of strings
     * @param index the index of the string to use
     * @return the {@link String} value for the string at location index, or
     * null
     */
    static String stringValueOf(String[] fields, int index) {
        if (fields.length > index) {
            return fields[index];
        }
        return null;
    }

    /**
     * Convenience method for {@link #valueOf(String)} method that returns an
     * {@link Integer} value for a string if the given array has enough elements
     * and the given element is non-null.
     * 
     * @param fields an array of strings
     * @param index the index of the string to use
     * @return the {@link Integer} value for the string at location index, or
     * null
     */
    static Integer intValueOf(String[] fields, int index) {
        if (fields.length > index && fields[index].length() > 0) {
            return Integer.valueOf(fields[index]);
        }
        return null;
    }

    /**
     * Convenience method for {@link #valueOf(String)} method that returns a
     * {@link Float} value for a string if the given array has enough elements
     * and the given element is non-null.
     * 
     * @param fields an array of strings
     * @param index the index of the string to use
     * @return the {@link Float} value for the string at location index, or null
     */
    static Float floatValueOf(String[] fields, int index) {
        if (fields.length > index && fields[index].length() > 0) {
            return Float.valueOf(fields[index]);
        }
        return null;
    }

    /**
     * Convenience method for {@link #valueOf(String)} method that returns an
     * {@link Double} value for a string if the given array has enough elements
     * and the given element is non-null.
     * 
     * @param fields an array of strings
     * @param index the index of the string to use
     * @return the {@link Double} value for the string at location index, or
     * null
     */
    static Double doubleValueOf(String[] fields, int index) {
        if (fields.length > index && fields[index].length() > 0) {
            return Double.valueOf(fields[index]);
        }
        return null;
    }

    @Override
    public final int hashCode() {
        return keplerId;
    }

    @Override
    public final boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Kic)) {
            return false;
        }
        final Kic other = (Kic) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        return true;
    }

    /**
     * Format this {@link Kic} entry in the same format as the SCP.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();

        s.append(Field.RA.format(ra))
            .append(SCP_DELIMITER)
            .append(Field.DEC.format(dec))
            .append(SCP_DELIMITER)
            .append(Field.PMRA.format(raProperMotion))
            .append(SCP_DELIMITER)
            .append(Field.PMDEC.format(decProperMotion))
            .append(SCP_DELIMITER)
            .append(Field.UMAG.format(uMag))
            .append(SCP_DELIMITER)
            .append(Field.GMAG.format(gMag))
            .append(SCP_DELIMITER)
            .append(Field.RMAG.format(rMag))
            .append(SCP_DELIMITER)
            .append(Field.IMAG.format(iMag))
            .append(SCP_DELIMITER)
            .append(Field.ZMAG.format(zMag))
            .append(SCP_DELIMITER)
            .append(Field.GREDMAG.format(gredMag))
            .append(SCP_DELIMITER)
            .append(Field.D51MAG.format(d51Mag))
            .append(SCP_DELIMITER)
            .append(Field.JMAG.format(twoMassJMag))
            .append(SCP_DELIMITER)
            .append(Field.HMAG.format(twoMassHMag))
            .append(SCP_DELIMITER)
            .append(Field.KMAG.format(twoMassKMag))
            .append(SCP_DELIMITER)
            .append(Field.KEPMAG.format(keplerMag))
            .append(SCP_DELIMITER)
            .append(Field.KEPLER_ID.format(keplerId))
            .append(SCP_DELIMITER)
            .append(Field.TMID.format(twoMassId))
            .append(SCP_DELIMITER)
            .append(Field.SCPID.format(internalScpId))
            .append(SCP_DELIMITER)
            .append(Field.ALTID.format(alternateId))
            .append(SCP_DELIMITER)
            .append(Field.ALTSOURCE.format(alternateSource))
            .append(SCP_DELIMITER)
            .append(Field.GALAXY.format(galaxyIndicator))
            .append(SCP_DELIMITER)
            .append(Field.BLEND.format(blendIndicator))
            .append(SCP_DELIMITER)
            .append(Field.VARIABLE.format(variableIndicator))
            .append(SCP_DELIMITER)
            .append(Field.TEFF.format(effectiveTemp))
            .append(SCP_DELIMITER)
            .append(Field.LOGG.format(log10SurfaceGravity))
            .append(SCP_DELIMITER)
            .append(Field.FEH.format(log10Metallicity))
            .append(SCP_DELIMITER)
            .append(Field.EBMINUSV.format(ebMinusVRedding))
            .append(SCP_DELIMITER)
            .append(Field.AV.format(avExtinction))
            .append(SCP_DELIMITER)
            .append(Field.RADIUS.format(radius))
            .append(SCP_DELIMITER)
            .append(Field.CQ.format(source))
            .append(SCP_DELIMITER)
            .append(Field.PQ.format(photometryQuality))
            .append(SCP_DELIMITER)
            .append(Field.AQ.format(astrophysicsQuality))
            .append(SCP_DELIMITER)
            .append(Field.CATKEY.format(catalogId))
            .append(SCP_DELIMITER)
            .append(Field.SCPKEY.format(scpId))
            .append(SCP_DELIMITER)
            .append(Field.PARALLAX.format(parallax))
            .append(SCP_DELIMITER)
            .append(Field.GLON.format(galacticLongitude))
            .append(SCP_DELIMITER)
            .append(Field.GLAT.format(galacticLatitude))
            .append(SCP_DELIMITER)
            .append(Field.PMTOTAL.format(totalProperMotion))
            .append(SCP_DELIMITER)
            .append(Field.GRCOLOR.format(grColor))
            .append(SCP_DELIMITER)
            .append(Field.JKCOLOR.format(jkColor))
            .append(SCP_DELIMITER)
            .append(Field.GKCOLOR.format(gkColor));

        return s.toString();
    }

    /**
     * Used to construct a {@link Kic} object. To use this class, a
     * {@link Builder} object is created with the required parameters (keplerId,
     * ra, and dec). Then non-null fields are set using the available builder
     * methods. Finally, a {@link Kic} object is returned by using the build
     * method. For example:
     * 
     * <pre>
     * Kic kic = new Kic.Builder(keplerId, ra, dec).raProperMotion(1.234F)
     *     .decProperMotion(5.678F)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    public static class Builder implements CelestialObjectBuilder {
        Kic kic;

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * 
         * @param keplerId the Kepler ID of the star
         * @param ra the right ascension
         * @param dec the declination
         */
        public Builder(int keplerId, double ra, double dec) {
            kic = new Kic();
            kic.keplerId = keplerId;
            kic.ra = ra;
            kic.dec = dec;
        }

        /**
         * Creates a {@link Builder} object with the given required parameters.
         * Downcasts long to int.
         * 
         * @param keplerId the Kepler ID of the star
         * @param ra the right ascension
         * @param dec the declination
         */
        public Builder(long keplerId, double ra, double dec) {
            kic = new Kic();
            kic.keplerId = (int)keplerId;
            kic.ra = ra;
            kic.dec = dec;
        }

        /**
         * Creates a {@link Builder} object starting with an existing
         * {@link Kic} object.
         * 
         * @param kic an existing {@link Kic} object
         */
        public Builder(Kic kic) {
            this.kic = new Kic(kic);
        }

        /**
         * Creates a {@link Builder} object starting with an existing
         * {@link Kic} object and overriding the RA and DEC with the given
         * parameters.
         * 
         * @param kic an existing {@link Kic} object
         * @param ra the corrected right ascension
         * @param dec the corrected declination
         */
        public Builder(Kic kic, double ra, double dec) {
            this.kic = new Kic(kic);
            this.kic.ra = ra;
            this.kic.dec = dec;
        }

        // Builders, in alphabetical order.

        @Override
        public Builder alternateId(Integer alternateId) {
            kic.alternateId = alternateId;
            return this;
        }

        @Override
        public Builder alternateSource(Integer alternateSource) {
            kic.alternateSource = alternateSource;
            return this;
        }

        @Override
        public Builder astrophysicsQuality(Integer astrophysicsQuality) {
            kic.astrophysicsQuality = astrophysicsQuality;
            return this;
        }

        @Override
        public Builder avExtinction(Float avExtinction) {
            kic.avExtinction = avExtinction;
            return this;
        }

        @Override
        public Builder blendIndicator(Integer blendIndicator) {
            kic.blendIndicator = blendIndicator;
            return this;
        }

        @Override
        public Builder catalogId(Integer catalogId) {
            kic.catalogId = catalogId;
            return this;
        }

        @Override
        public Builder dec(double dec) {
            kic.dec = dec;
            return this;
        }

        @Override
        public Builder d51Mag(Float mag) {
            kic.d51Mag = mag;
            return this;
        }

        @Override
        public Builder decProperMotion(Float decProperMotion) {
            kic.decProperMotion = decProperMotion;
            return this;
        }

        @Override
        public Builder ebMinusVRedding(Float ebMinusVRedding) {
            kic.ebMinusVRedding = ebMinusVRedding;
            return this;
        }

        @Override
        public Builder effectiveTemp(Integer effectiveTemp) {
            kic.effectiveTemp = effectiveTemp;
            return this;
        }

        @Override
        public Builder galacticLatitude(Double galacticLatitude) {
            kic.galacticLatitude = galacticLatitude;
            return this;
        }

        @Override
        public Builder galacticLongitude(Double galacticLongitude) {
            kic.galacticLongitude = galacticLongitude;
            return this;
        }

        @Override
        public Builder galaxyIndicator(Integer galaxyIndicator) {
            kic.galaxyIndicator = galaxyIndicator;
            return this;
        }

        @Override
        public Builder gkColor(Float color) {
            kic.gkColor = color;
            return this;
        }

        @Override
        public Builder gMag(Float mag) {
            kic.gMag = mag;
            return this;
        }

        @Override
        public Builder grColor(Float color) {
            kic.grColor = color;
            return this;
        }

        @Override
        public Builder gredMag(Float mag) {
            kic.gredMag = mag;
            return this;
        }

        @Override
        public Builder iMag(Float mag) {
            kic.iMag = mag;
            return this;
        }

        @Override
        public Builder internalScpId(Integer id) {
            kic.internalScpId = id;
            return this;
        }

        @Override
        public Builder jkColor(Float color) {
            kic.jkColor = color;
            return this;
        }

        @Override
        public Builder keplerMag(Float mag) {
            kic.keplerMag = mag;
            return this;
        }

        @Override
        public Builder log10Metallicity(Float log10Metallicity) {
            kic.log10Metallicity = log10Metallicity;
            return this;
        }

        @Override
        public Builder log10SurfaceGravity(Float log10SurfaceGravity) {
            kic.log10SurfaceGravity = log10SurfaceGravity;
            return this;
        }

        @Override
        public Builder parallax(Float parallax) {
            kic.parallax = parallax;
            return this;
        }

        @Override
        public Builder photometryQuality(Integer photometryQuality) {
            kic.photometryQuality = photometryQuality;
            return this;
        }

        @Override
        public Builder ra(double ra) {
            kic.ra = ra;
            return this;
        }

        @Override
        public Builder radius(Float radius) {
            kic.radius = radius;
            return this;
        }

        @Override
        public Builder raProperMotion(Float raProperMotion) {
            kic.raProperMotion = raProperMotion;
            return this;
        }

        @Override
        public Builder rMag(Float mag) {
            kic.rMag = mag;
            return this;
        }

        @Override
        public Builder scpId(Integer scpId) {
            kic.scpId = scpId;
            return this;
        }

        @Override
        public Builder skyGroupId(int skyGroupId) {
            kic.skyGroupId = skyGroupId;
            return this;
        }

        @Override
        public Builder source(String source) {
            kic.source = source;
            return this;
        }

        @Override
        public Builder totalProperMotion(Float totalProperMotion) {
            kic.totalProperMotion = totalProperMotion;
            return this;
        }

        @Override
        public Builder twoMassHMag(Float twoMassHMag) {
            kic.twoMassHMag = twoMassHMag;
            return this;
        }

        @Override
        public Builder twoMassId(Integer twoMassId) {
            kic.twoMassId = twoMassId;
            return this;
        }

        @Override
        public Builder twoMassJMag(Float twoMassJMag) {
            kic.twoMassJMag = twoMassJMag;
            return this;
        }

        @Override
        public Builder twoMassKMag(Float twoMassKMag) {
            kic.twoMassKMag = twoMassKMag;
            return this;
        }

        @Override
        public Builder uMag(Float mag) {
            kic.uMag = mag;
            return this;
        }

        @Override
        public Builder variableIndicator(Integer variableIndicator) {
            kic.variableIndicator = variableIndicator;
            return this;
        }

        @Override
        public Builder zMag(Float mag) {
            kic.zMag = mag;
            return this;
        }

        @Override
        public Kic build() {
            return new Kic(this);
        }
    }
}
