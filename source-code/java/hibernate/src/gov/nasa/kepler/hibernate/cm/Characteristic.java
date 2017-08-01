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

import static gov.nasa.kepler.hibernate.cm.Kic.SCP_DELIMITER;
import static gov.nasa.kepler.hibernate.cm.Kic.SCP_DELIMITER_CHAR;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Index;

/**
 * Additional information about each record in the Kepler Input Catalog (KIC).
 * This class is immutable.
 * <p>
 * See KSOC-21163 Catalog Management.<br>
 * See KSOC-21113 SOC SCP ICD.
 * 
 * @author Bill Wohler
 * @author Sean McCauliff
 * @author Thomas Han
 */
@Entity
@Table(name = "CM_CHAR")
public class Characteristic {

    private static final String CHAR_DELIMITER = SCP_DELIMITER;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_CHAR_SEQ")
    @Column(nullable = false)
    private long id;

    @Index(name = "CM_CHAR_KEPLER_ID_IDX")
    private int keplerId;

    @ManyToOne
    @JoinColumn(name = "TYPE_ID", nullable = false)
    private CharacteristicType type;

    @Column(nullable = false)
    private double value;

    private Integer quarter;

    /**
     * Use
     * {@link Characteristic#Characteristic(int, CharacteristicType, double)}
     * instead. This constructor is for mock objects and Hibernate only.
     */
    Characteristic() {
    }

    /**
     * Creates a {@link Characteristic} object with the given parameters.
     */
    public Characteristic(int keplerId, CharacteristicType type, double value) {
        this(keplerId, type, value, null);
    }

    /**
     * Creates a {@link Characteristic} object with the given parameters.
     */
    public Characteristic(int keplerId, CharacteristicType type, double value,
        Integer quarter) {
        this.keplerId = keplerId;
        this.type = type;
        this.value = value;
        this.quarter = quarter;
    }

    /**
     * Returns the database id of this characteristic.
     */
    public long getId() {
        return id;
    }

    /**
     * Returns the Kepler ID that is associated with this characteristic.
     */
    public int getKeplerId() {
        return keplerId;
    }

    /**
     * Returns the characteristic type.
     */
    public CharacteristicType getType() {
        return type;
    }

    /**
     * Returns the characteristic value.
     */
    public double getValue() {
        return value;
    }

    public Integer getQuarter() {
        return quarter;
    }

    /**
     * Creates a {@link Characteristic} object for the string argument. The
     * format of the string is similar to that of the KIC as defined by SOC SCP
     * ICD (KSOC-21113). In particular, the fields are separated by the pipe (|)
     * symbol, in the order Kepler ID, characteristic type, and floating point
     * value. For example, "12345|Some type|5.0".
     * 
     * @param s a String containing the {@link Characteristic} object
     * representation to be parsed.
     * @param charCrud the {@link CharacteristicCrud} object which is used to
     * access the {@link CharacteristicType}.
     * @return the {@link Characteristic} object represented by the argument
     * @throws NullPointerException if the string is null.
     * @throws IllegalArgumentException if the characteristic type in the given
     * string isn't in the database.
     * @throws ArrayIndexOutOfBoundsException if there aren't enough fields.
     */
    public static Characteristic valueOf(String s, CharacteristicCrud charCrud) {

        String[] fields = s.split("\\" + CHAR_DELIMITER);

        String charTypeStr = fields[1];
        CharacteristicType charType = charCrud.retrieveCharacteristicType(charTypeStr);
        if (charType == null) {
            throw new IllegalArgumentException("Invalid character type:"
                + charTypeStr);
        }

        int keplerId = Integer.parseInt(fields[0]);

        return new Characteristic(keplerId, charType,
            Double.parseDouble(fields[2]));
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + keplerId;
        result = prime * result + ((quarter == null) ? 0 : quarter.hashCode());
        result = prime * result + ((type == null) ? 0 : type.hashCode());
        long temp;
        temp = Double.doubleToLongBits(value);
        result = prime * result + (int) (temp ^ (temp >>> 32));
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
        Characteristic other = (Characteristic) obj;
        if (keplerId != other.keplerId)
            return false;
        if (quarter == null) {
            if (other.quarter != null)
                return false;
        } else if (!quarter.equals(other.quarter))
            return false;
        if (type == null) {
            if (other.type != null)
                return false;
        } else if (!type.equals(other.type))
            return false;
        if (Double.doubleToLongBits(value) != Double.doubleToLongBits(other.value))
            return false;
        return true;
    }

    /**
     * Formats this {@link Characteristic} as it is expected to be imported and
     * exported.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        s.append(keplerId);
        s.append(SCP_DELIMITER_CHAR);
        s.append(type.getName());
        s.append(SCP_DELIMITER_CHAR);

        DoubleFormatter.format(s, type.getFormat(), value);

        return s.toString();
    }
}
