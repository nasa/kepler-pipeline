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

import java.util.Formatter;
import java.util.Locale;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * An enumeration of {@link Characteristic} types. This class is immutable.
 * <p>
 * See KSOC-21163 Catalog Management.<br>
 * See KSOC-21113 SOC SCP ICD.
 * 
 * @author Bill Wohler
 * @author Sean McCauliff
 * @author Thomas Han
 */
@Entity
@Table(name = "CM_CHAR_TYPE")
public class CharacteristicType implements Canonicalizable {

    public static final String CROWDING = "CROWDING";
    public static final String RANKING_1 = "RANKING_1";
    public static final String RANKING_2 = "RANKING_2";
    public static final String RANKING_3 = "RANKING_3";
    public static final String RANKING_4 = "RANKING_4";
    public static final String RANKING_5 = "RANKING_5";

    public static final String SOC_MAG = "SOC_MAG";
    public static final String RA = "RA";
    public static final String DEC = "DEC";

    /**
     * Characteristic type name suffix for uncertainties in KIC values.
     */
    public static final String CHARACTERISTIC_TYPE_UNCERTAINTY = "_UNCERTAINTY";

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_CHAR_TYPE_SEQ")
    @Column(nullable = false)
    private long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String format;

    /**
     * Use {@link CharacteristicType#CharacteristicType(String, String)}
     * instead. This constructor is for mock objects and Hibernate only.
     */
    CharacteristicType() {
    }

    /**
     * Creates a {@link CharacteristicType} object with the given parameters.
     */
    public CharacteristicType(String name, String format) {
        this.name = name;
        this.format = format;

        // Validate the format string.
        if (format.length() < 2) {
            throw new IllegalArgumentException(String.format(
                "Invalid format \"%s\"", format));
        }
        StringBuilder s = new StringBuilder();
        Formatter fmt = new Formatter(s, Locale.US);

        switch (format.charAt(format.length() - 1)) {
            case 'b':
            case 'B':
            case 'H':
            case 'h':
            case 's':
            case 'S':
            case 'e':
            case 'E':
            case 'f':
            case 'g':
            case 'G':
            case 'a':
            case 'A':
                fmt.format(format, 1.0f);
                break;
            case 'd':
            case 'o':
            case 'x':
            case 'X':
                fmt.format(format, 1);
                break;
            default:
                fmt.close();
                throw new IllegalArgumentException(String.format(
                    "Invalid format \"%s\"", format));
        }
        
        fmt.close();
    }

    public long getId() {
        return id;
    }

    /**
     * Returns the mnemonic.
     */
    public String getName() {
        return name;
    }

    /**
     * Returns a floating point string format supported by {@link Formatter}.
     */
    public String getFormat() {
        return format;
    }

    @Override
    public int hashCode() {
        return name.hashCode();
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
        final CharacteristicType other = (CharacteristicType) obj;
        if (name == null) {
            if (other.name != null) {
                return false;
            }
        } else if (!name.equals(other.name)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return name;
    }

    /**
     * Formats this {@link CharacteristicType} as it is expected to be imported
     * and exported.
     */
    public String format() {
        StringBuilder s = new StringBuilder();

        s.append(name);
        s.append(Kic.SCP_DELIMITER);
        s.append(format);

        return s.toString();
    }

    @Override
    public String canonicalize(String alias) {
        return Long.valueOf(id)
            .toString();
    }

    /**
     * Returns the return type of {@link Characteristic#getValue()}.
     * 
     * @return the return type of {@link Characteristic#getValue()}, or
     * <code>null</code> if its type can't be determined.
     */
    @Override
    public Class<?> getObjectClass() {
        try {
            return Characteristic.class.getDeclaredMethod("getValue")
                .getReturnType();
        } catch (Exception e) {
            // SecurityException & NoSuchFieldException.
            return null;
        }
    }
}
