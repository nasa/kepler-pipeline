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

package gov.nasa.kepler.hibernate.mc;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.annotations.Index;

/**
 * Contains a transit parameter. This class is immutable.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "MC_TRANSIT_PARAMETER")
public class TransitParameter {

    private static final Log log = LogFactory.getLog(TransitParameter.class);

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_TP_SEQ")
    @Column(nullable = false)
    private long id;

    @Index(name = "MC_TP_KEPLER_ID_IDX")
    private int keplerId;

    @Column(nullable = false)
    private String koiId;

    @Column(nullable = false)
    private String name;

    private String value;

    /**
     * Only used by Hibernate.
     */
    TransitParameter() {
    }

    public TransitParameter(int keplerId, String koiId, String name,
        String value) {
        this.keplerId = keplerId;
        this.koiId = koiId;
        this.name = name;
        this.value = value;
    }

    public long getId() {
        return id;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public String getKoiId() {
        return koiId;
    }

    public String getName() {
        return name;
    }

    public String getValue() {
        return value;
    }

    public static List<TransitParameter> valueOf(String s, String[] columnNames) {

        int tokenCount = columnNames.length;
        String[] fields = s.split("\\" + TransitParameterModel.COMMA_DELIMITER,
            tokenCount + 1);

        if (fields.length < tokenCount) {
            log.debug(String.format(
                "Expected %d tokens but only found %d: %s\n", tokenCount,
                fields.length, s));
            return null;
        }

        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        String keplerId = null;
        String koiId = null;
        int index = 0;
        for (String columnName : columnNames) {

            String value = null;
            if (columnName.equals(TransitParameterModel.KEPLER_ID_COLUMN)) {
                keplerId = fields[index++].trim();
                continue;
            } else if (columnName.equals(TransitParameterModel.KOI_COLUMN)) {
                koiId = fields[index++].trim();
                continue;
            } else if (columnName.equals(TransitParameterModel.PERIOD_NAME)) {
                value = fields[index++].trim();
            } else if (columnName.equals(TransitParameterModel.EPOCH_NAME)) {
                value = fields[index++].trim();
            } else if (columnName.equals(TransitParameterModel.DURATION_NAME)) {
                value = fields[index++].trim();
            } else {
                index++;
            }

            if (keplerId != null && koiId != null && value != null) {
                transitParameters.add(new TransitParameter(
                    Integer.parseInt(keplerId), koiId, columnName, value));
                value = null;
            }
        }

        return transitParameters;
    }

    public static List<TransitParameter> valueOf(String s) {

        String[] fields = s.split(
            "\\" + EbTransitParameterModel.PIPE_DELIMITER, 5);

        if (fields.length < 4) {
            return null;
        }

        String keplerId = fields[0].trim();
        String koiId = fields[1].trim();
        String name = fields[2].trim();
        String value = fields[3].trim();

        TransitParameter transitParameter = new TransitParameter(Integer.parseInt(keplerId),
            koiId, name, value);

        return Collections.singletonList(transitParameter);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + keplerId;
        result = prime * result + (koiId == null ? 0 : koiId.hashCode());
        result = prime * result + (name == null ? 0 : name.hashCode());
        result = prime * result + (value == null ? 0 : value.hashCode());
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
        if (!(obj instanceof TransitParameter)) {
            return false;
        }
        TransitParameter other = (TransitParameter) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        if (koiId == null) {
            if (other.koiId != null) {
                return false;
            }
        } else if (!koiId.equals(other.koiId)) {
            return false;
        }
        if (name == null) {
            if (other.name != null) {
                return false;
            }
        } else if (!name.equals(other.name)) {
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

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append(keplerId);
        builder.append(TransitParameterModel.COMMA_DELIMITER);
        builder.append(koiId);
        builder.append(TransitParameterModel.COMMA_DELIMITER);
        builder.append(name);
        builder.append(TransitParameterModel.COMMA_DELIMITER);
        builder.append(value);

        return builder.toString();
    }

}
