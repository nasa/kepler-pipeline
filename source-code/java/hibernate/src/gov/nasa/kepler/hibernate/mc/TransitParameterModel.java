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

import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

@Entity
@Table(name = "MC_TRANSIT_PARAM_MODEL", uniqueConstraints = { @UniqueConstraint(columnNames = { "revision" }) })
public class TransitParameterModel implements Model {

    static final String COMMENT_START_CHARACTER = "#";

    static final String COMMA_DELIMITER = ",";

    static final String ROW_ID_COLUMN = "rowid";
    public static final String KEPLER_ID_COLUMN = "kepid";
    static final String KOI_COLUMN = "kepoi_name";

    public static final String DURATION_NAME = "koi_duration";
    public static final String PERIOD_NAME = "koi_period";
    public static final String EPOCH_NAME = "koi_time0bk";
    /** String value used in the model to indicate missing data. */
    public static final String NULL = "NULL";

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_TPM_SEQ")
    @Column(nullable = false)
    private long id;

    private int revision;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "MC_TPM_TP")
    private List<TransitParameter> transitParameters;

    /**
     * For Hibernate use only.
     */
    public TransitParameterModel() {
    }

    public TransitParameterModel(int revision,
        List<TransitParameter> transitParameters) {
        this.revision = revision;
        this.transitParameters = transitParameters;

        validate();
    }

    private void validate() {

        Map<Pair<String, String>, TransitParameter> transitParameterByKeplerIdKoiIdName = new LinkedHashMap<Pair<String, String>, TransitParameter>();
        for (TransitParameter transitParameter : transitParameters) {
            Pair<String, String> keplerIdKoiIdNamePair = Pair.of(
                transitParameter.getKeplerId() + COMMA_DELIMITER
                    + transitParameter.getKoiId(), transitParameter.getName());
            TransitParameter existingTransitParameter = transitParameterByKeplerIdKoiIdName.get(keplerIdKoiIdNamePair);
            if (existingTransitParameter != null) {
                if (!transitParameter.getValue()
                    .equals(existingTransitParameter.getValue())) {
                    throw new IllegalArgumentException(
                        "Transit parameters with the same keplerId, koiId, and parameter name must have the same value.\n  keplerId: "
                            + transitParameter.getKeplerId()
                            + "\n  koiId: "
                            + transitParameter.getKoiId()
                            + "\n  name: "
                            + transitParameter.getName()
                            + "\n  value: "
                            + transitParameter.getValue()
                            + "\n  differingValue: "
                            + existingTransitParameter.getValue());
                }
            }

            transitParameterByKeplerIdKoiIdName.put(keplerIdKoiIdNamePair,
                transitParameter);
        }
    }

    public long getId() {
        return id;
    }

    @Override
    public int getRevision() {
        return revision;
    }

    @Override
    public void setRevision(int revision) {
        this.revision = revision;
    }

    public List<TransitParameter> getTransitParameters() {
        return transitParameters;
    }

    /**
     * Creates a {@link TransitParameterModel} object for the string argument.
     * 
     * @param s a String containing the {@link TransitParameterModel} object
     * representation to be parsed.
     * @return the {@link TransitParameterModel} object represented by the
     * argument
     * @throws NullPointerException if the string is null.
     */
    public static TransitParameterModel valueOf(String s) {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        String[] columnNames = null;
        for (String line : s.split("\n")) {
            if (line.contains(COMMENT_START_CHARACTER)) {
                String[] lineArray = line.split(COMMENT_START_CHARACTER);
                line = lineArray.length == 0 ? "" : lineArray[0];
            }

            if (!line.trim()
                .isEmpty()) {
                if (columnNames == null) {
                    if (line.startsWith(ROW_ID_COLUMN)) {
                        columnNames = line.split(COMMA_DELIMITER);
                    }
                    continue;
                }
                List<TransitParameter> transitParametersList = TransitParameter.valueOf(
                    line, columnNames);
                if (transitParametersList != null
                    && !transitParametersList.isEmpty()) {
                    transitParameters.addAll(transitParametersList);
                }
            }
        }

        return new TransitParameterModel(Model.NULL_REVISION, transitParameters);
    }

    public static Map<Integer, Map<String, Map<String, String>>> parseModel(
        TransitParameterModel transitParameterModel) {

        Map<Integer, Map<String, Map<String, String>>> parsedModel = new HashMap<Integer, Map<String, Map<String, String>>>();
        if (transitParameterModel != null
            && transitParameterModel.getTransitParameters() != null) {
            for (TransitParameter transitParameter : transitParameterModel.getTransitParameters()) {
                Map<String, Map<String, String>> transitParametersByKoiId = parsedModel.get(transitParameter.getKeplerId());
                if (transitParametersByKoiId == null) {
                    transitParametersByKoiId = new HashMap<String, Map<String, String>>();
                    parsedModel.put(transitParameter.getKeplerId(),
                        transitParametersByKoiId);
                }
                Map<String, String> transitParameters = transitParametersByKoiId.get(transitParameter.getKoiId());
                if (transitParameters == null) {
                    transitParameters = new HashMap<String, String>();
                    transitParametersByKoiId.put(transitParameter.getKoiId(),
                        transitParameters);
                }
                transitParameters.put(transitParameter.getName(),
                    transitParameter.getValue());
            }
        }

        return parsedModel;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + revision;
        result = prime * result
            + (transitParameters == null ? 0 : transitParameters.hashCode());
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
        if (!(obj instanceof TransitParameterModel)) {
            return false;
        }
        TransitParameterModel other = (TransitParameterModel) obj;
        if (revision != other.revision) {
            return false;
        }
        if (transitParameters == null) {
            if (other.transitParameters != null) {
                return false;
            }
        } else if (!transitParameters.equals(other.transitParameters)) {
            return false;
        }
        return true;
    }

    /**
     * Formats this {@link TransitParameterModel} as it is expected to be
     * imported and exported.
     */
    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        builder.append(ROW_ID_COLUMN);
        builder.append(COMMA_DELIMITER);
        builder.append(KEPLER_ID_COLUMN);
        builder.append(COMMA_DELIMITER);
        builder.append(KOI_COLUMN);
        builder.append(COMMA_DELIMITER);
        builder.append(PERIOD_NAME);
        builder.append(COMMA_DELIMITER);
        builder.append(EPOCH_NAME);
        builder.append(COMMA_DELIMITER);
        builder.append(DURATION_NAME);
        builder.append("\n");
        int row = 1;
        Map<Integer, Map<String, Map<String, String>>> parsedModel = parseModel(this);
        for (Integer keplerId : parsedModel.keySet()) {
            builder.append(row++);
            builder.append(COMMA_DELIMITER);
            builder.append(keplerId);
            Map<String, Map<String, String>> transitParametersByKoiId = parsedModel.get(keplerId);
            for (String koiId : transitParametersByKoiId.keySet()) {
                builder.append(COMMA_DELIMITER);
                builder.append(koiId);
                Map<String, String> valuesByName = transitParametersByKoiId.get(koiId);
                builder.append(COMMA_DELIMITER);
                if (valuesByName.get(PERIOD_NAME) != null) {
                    builder.append(valuesByName.get(PERIOD_NAME));
                }
                builder.append(COMMA_DELIMITER);
                if (valuesByName.get(EPOCH_NAME) != null) {
                    builder.append(valuesByName.get(EPOCH_NAME));
                }
                builder.append(COMMA_DELIMITER);
                if (valuesByName.get(DURATION_NAME) != null) {
                    builder.append(valuesByName.get(DURATION_NAME));
                }
            }
            builder.append("\n");
        }

        return builder.toString();
    }

    public Object getType() {
        return TransitParameterModelCrud.TYPE;
    }

}
