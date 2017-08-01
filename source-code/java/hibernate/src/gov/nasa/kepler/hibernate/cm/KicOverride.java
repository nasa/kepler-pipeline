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

import gov.nasa.kepler.hibernate.cm.Kic.Field;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Index;

/**
 * Contains values for overriding values in the {@link Kic}. This class is
 * immutable.
 * 
 * @author Miles Cote
 * 
 */
@Entity
@Table(name = "CM_KIC_OVERRIDE")
public class KicOverride {

    private static final int TOKEN_COUNT = 5;

    private static final int PROVENANCE_MAX_LENGTH = 30;

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_KO_SEQ")
    @Column(nullable = false)
    private long id;

    @Index(name = "CM_KO_KEPLER_ID_IDX")
    private int keplerId;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private Field field;

    @Column(nullable = false)
    private String provenance;

    @Column(nullable = false)
    private double value;

    @Column(nullable = true)
    private Double uncertainty;

    /**
     * Only used by hibernate.
     */
    KicOverride() {
    }

    public KicOverride(int keplerId, Field field, String provenance,
        double value, Double uncertainty) {
        this.keplerId = keplerId;
        this.field = field;
        this.provenance = provenance;
        this.value = value;
        this.uncertainty = uncertainty;
    }

    public long getId() {
        return id;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public Field getField() {
        return field;
    }

    public String getProvenance() {
        return provenance;
    }

    public double getValue() {
        return value;
    }

    public Double getUncertainty() {
        return uncertainty;
    }

    /**
     * Creates a {@link KicOverride} object for the string argument. The format
     * of the string is similar to that of the KIC as defined by SOC SCP ICD
     * (KSOC-21113). In particular, the fields are separated by the pipe (|)
     * symbol, in the order Kepler ID, KIC {@link Field}, provenance, floating
     * point value, and floating point uncertainty. For example,
     * "12345|ZMAG|Unknown|12.0|1.0|".
     * 
     * @param s a String containing the {@link KicOverride} object
     * representation to be parsed.
     * @return the {@link KicOverride} object represented by the argument
     * @throws NullPointerException if the string is null.
     * @throws IllegalArgumentException if there aren't enough or too many
     * fields or if the provenance field is empty.
     */
    public static KicOverride valueOf(String s) {
        String[] fields = s.split("\\" + Kic.SCP_DELIMITER, TOKEN_COUNT + 1);

        if (fields.length < TOKEN_COUNT) {
            throw new IllegalArgumentException("Invalid KIC override: \"" + s
                + "\". Expected " + TOKEN_COUNT + " tokens, not "
                + fields.length);
        }

        int keplerId = Integer.parseInt(fields[0].trim());

        String kicFieldString = fields[1].trim();
        Field field = Field.valueOf(kicFieldString);

        String provenance = fields[2].trim();
        if (provenance.length() == 0) {
            throw new IllegalArgumentException(
                "The provenance field can't be empty.");
        } else if (provenance.length() > PROVENANCE_MAX_LENGTH) {
            throw new IllegalArgumentException(String.format(
                "The provenance field value \"%s\" is too long (> %d characters).",
                provenance, PROVENANCE_MAX_LENGTH));
        }

        double value = Double.parseDouble(fields[3].trim());

        Double uncertainty = null;
        String uncertaintyString = fields[4].trim();
        if (uncertaintyString.length() > 0) {
            uncertainty = Double.parseDouble(uncertaintyString);
        }

        return new KicOverride(keplerId, field, provenance, value, uncertainty);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (field == null ? 0 : field.hashCode());
        result = prime * result + keplerId;
        result = prime * result
            + (provenance == null ? 0 : provenance.hashCode());
        result = prime * result
            + (uncertainty == null ? 0 : uncertainty.hashCode());
        long temp;
        temp = Double.doubleToLongBits(value);
        result = prime * result + (int) (temp ^ temp >>> 32);
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
        if (!(obj instanceof KicOverride)) {
            return false;
        }
        KicOverride other = (KicOverride) obj;
        if (field != other.field) {
            return false;
        }
        if (keplerId != other.keplerId) {
            return false;
        }
        if (provenance == null) {
            if (other.provenance != null) {
                return false;
            }
        } else if (!provenance.equals(other.provenance)) {
            return false;
        }
        if (uncertainty == null) {
            if (other.uncertainty != null) {
                return false;
            }
        } else if (!uncertainty.equals(other.uncertainty)) {
            return false;
        }
        if (Double.doubleToLongBits(value) != Double.doubleToLongBits(other.value)) {
            return false;
        }
        return true;
    }

    /**
     * Formats this {@link KicOverride} as it is expected to be imported and
     * exported.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        s.append(keplerId);
        s.append(Kic.SCP_DELIMITER);
        s.append(field);
        s.append(Kic.SCP_DELIMITER);
        s.append(provenance);
        s.append(Kic.SCP_DELIMITER);
        DoubleFormatter.format(s, field.getFormat(), value);
        s.append(Kic.SCP_DELIMITER);
        if (uncertainty != null) {
            s.append(uncertainty);
        }
        s.append(Kic.SCP_DELIMITER);

        return s.toString();
    }
}
