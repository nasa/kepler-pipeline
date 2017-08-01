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
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

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
@Table(name = "MC_EB_TRANSIT_PARAM_MODEL", uniqueConstraints = { @UniqueConstraint(columnNames = { "revision" }) })
public class EbTransitParameterModel implements Model {

    static final String COMMENT_START_CHARACTER = "#";

    public static final String PIPE_DELIMITER = "|";

    public static final String DURATION_NAME = "koi_duration";
    public static final String PERIOD_NAME = "koi_period";
    public static final String EPOCH_NAME = "koi_time0bk";

    private static final List<String> PARAMETER_NAMES = Arrays.asList(
        DURATION_NAME, PERIOD_NAME, EPOCH_NAME);

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_EB_TPM_SEQ")
    @Column(nullable = false)
    private long id;

    private int revision;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "MC_EB_TPM_TP")
    private List<TransitParameter> transitParameters;

    /**
     * For Hibernate use only.
     */
    public EbTransitParameterModel() {
    }

    public EbTransitParameterModel(int revision,
        List<TransitParameter> transitParameters) {
        this.revision = revision;
        this.transitParameters = transitParameters;

        validate();
    }

    private void validate() {

        Map<Pair<String, String>, TransitParameter> transitParameterByKeplerIdKoiIdName = new LinkedHashMap<Pair<String, String>, TransitParameter>();
        for (TransitParameter transitParameter : transitParameters) {
            Pair<String, String> keplerIdKoiIdNamePair = Pair.of(
                transitParameter.getKeplerId() + PIPE_DELIMITER
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
     * Creates a {@link EbTransitParameterModel} object for the string argument.
     * 
     * @param s a String containing the {@link EbTransitParameterModel} object
     * representation to be parsed.
     * @return the {@link EbTransitParameterModel} object represented by the
     * argument
     * @throws NullPointerException if the string is null.
     */
    public static EbTransitParameterModel valueOf(String s) {
        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>();
        for (String line : s.split("\n")) {
            if (line.contains(COMMENT_START_CHARACTER)) {
                String[] lineArray = line.split(COMMENT_START_CHARACTER);
                line = lineArray.length == 0 ? "" : lineArray[0];
            }

            if (!line.trim()
                .isEmpty()) {
                List<TransitParameter> transitParametersList = TransitParameter.valueOf(line);
                if (transitParametersList != null
                    && !transitParametersList.isEmpty()) {
                    for (TransitParameter transitParameter : transitParametersList) {
                        if (PARAMETER_NAMES.contains(transitParameter.getName())) {
                            transitParameters.add(transitParameter);
                        }
                    }
                }
            }
        }

        return new EbTransitParameterModel(Model.NULL_REVISION,
            transitParameters);
    }

    /**
     * 
     * @param transitParameterModel
     * @return Map of keplerId -> (koiId -> (modelParameterKey -> modelParameterValue))
     */
    public static Map<Integer, Map<String, Map<String, String>>> parseModel(
        EbTransitParameterModel transitParameterModel) {

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
        if (!(obj instanceof EbTransitParameterModel)) {
            return false;
        }
        EbTransitParameterModel other = (EbTransitParameterModel) obj;
        if (revision != other.revision) {
            return false;
        }
        if (transitParameters == null) {
            if (other.transitParameters != null) {
                return false;
            }
        } else {
            Set<TransitParameter> transitParametersSet = new HashSet<TransitParameter>(
                transitParameters);
            Set<TransitParameter> otherTransitParametersSet = new HashSet<TransitParameter>(
                other.transitParameters);
            if (!transitParametersSet.equals(otherTransitParametersSet)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Formats this {@link EbTransitParameterModel} as it is expected to be
     * imported and exported.
     */
    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        Map<Integer, Map<String, Map<String, String>>> parsedModel = parseModel(this);
        for (Integer keplerId : parsedModel.keySet()) {
            Map<String, Map<String, String>> transitParametersByKoiId = parsedModel.get(keplerId);
            for (String koiId : transitParametersByKoiId.keySet()) {
                Map<String, String> valuesByName = transitParametersByKoiId.get(koiId);
                for (String name : valuesByName.keySet()) {
                    builder.append(keplerId);
                    builder.append(PIPE_DELIMITER);
                    builder.append(koiId);
                    builder.append(PIPE_DELIMITER);
                    builder.append(name);
                    builder.append(PIPE_DELIMITER);
                    builder.append(valuesByName.get(name));
                    builder.append("\n");
                }
            }
        }

        return builder.toString();
    }

}
