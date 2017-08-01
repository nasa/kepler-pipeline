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
@Table(name = "MC_TRANSIT_NAME_MODEL", uniqueConstraints = { @UniqueConstraint(columnNames = { "revision" }) })
public class TransitNameModel implements Model {

    static final String COMMENT_START_CHARACTER = "#";

    static final String COMMA_DELIMITER = ",";

    static final String ROW_ID_COLUMN = "rowid";
    static final String KEPLER_ID_COLUMN = "kepid";
    static final String KOI_COLUMN = "kepoi_name";
    public static final String KEPLER_NAME_COLUMN = "kepler_name";

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_TNM_SEQ")
    @Column(nullable = false)
    private long id;

    private int revision;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "MC_TNM_TN")
    private List<TransitName> transitNames;

    /**
     * Only used by Hibernate.
     */
    public TransitNameModel() {
    }

    public TransitNameModel(int revision, List<TransitName> transitNames) {
        this.revision = revision;
        this.transitNames = transitNames;

        validate();
    }

    private void validate() {

        Map<Pair<String, String>, TransitName> transitNameByKeplerIdKoiIdName = new LinkedHashMap<Pair<String, String>, TransitName>();
        for (TransitName transitName : transitNames) {
            Pair<String, String> keplerIdKoiIdNamePair = Pair.of(
                transitName.getKeplerId() + COMMA_DELIMITER
                    + transitName.getKoiId(), transitName.getName());
            TransitName existingTransitName = transitNameByKeplerIdKoiIdName.get(keplerIdKoiIdNamePair);
            if (existingTransitName != null) {
                if (!transitName.getValue()
                    .equals(existingTransitName.getValue())) {
                    throw new IllegalArgumentException(
                        "Transit names with the same keplerId, koiId, and parameter name must have the same value.\n  keplerId: "
                            + transitName.getKeplerId()
                            + "\n  koiId: "
                            + transitName.getKoiId()
                            + "\n  name: "
                            + transitName.getName()
                            + "\n  value: "
                            + transitName.getValue()
                            + "\n  differingValue: "
                            + existingTransitName.getValue());
                }
            }

            transitNameByKeplerIdKoiIdName.put(keplerIdKoiIdNamePair,
                transitName);
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

    public List<TransitName> getTransitNames() {
        return transitNames;
    }

    /**
     * Creates a {@link TransitNameModel} object for the string argument.
     * 
     * @param s a String containing the {@link TransitNameModel} object
     * representation to be parsed.
     * @return the {@link TransitNameModel} object represented by the argument
     * @throws NullPointerException if the string is null.
     */
    public static TransitNameModel valueOf(String s) {
        List<TransitName> transitNames = new ArrayList<TransitName>();
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
                List<TransitName> transitNameList = TransitName.valueOf(line,
                    columnNames);
                if (transitNameList != null && !transitNameList.isEmpty()) {
                    transitNames.addAll(transitNameList);
                }
            }
        }

        return new TransitNameModel(Model.NULL_REVISION, transitNames);
    }

    public static Map<Integer, Map<String, Map<String, String>>> parseModel(
        TransitNameModel transitNameModel) {

        Map<Integer, Map<String, Map<String, String>>> parsedModel = new HashMap<Integer, Map<String, Map<String, String>>>();
        if (transitNameModel != null
            && transitNameModel.getTransitNames() != null) {
            for (TransitName transitName : transitNameModel.getTransitNames()) {
                Map<String, Map<String, String>> transitNamesByKoiId = parsedModel.get(transitName.getKeplerId());
                if (transitNamesByKoiId == null) {
                    transitNamesByKoiId = new HashMap<String, Map<String, String>>();
                    parsedModel.put(transitName.getKeplerId(),
                        transitNamesByKoiId);
                }
                Map<String, String> transitNames = transitNamesByKoiId.get(transitName.getKoiId());
                if (transitNames == null) {
                    transitNames = new HashMap<String, String>();
                    transitNamesByKoiId.put(transitName.getKoiId(),
                        transitNames);
                }
                transitNames.put(transitName.getName(), transitName.getValue());
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
            + (transitNames == null ? 0 : transitNames.hashCode());
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
        if (!(obj instanceof TransitNameModel)) {
            return false;
        }
        TransitNameModel other = (TransitNameModel) obj;
        if (revision != other.revision) {
            return false;
        }
        if (transitNames == null) {
            if (other.transitNames != null) {
                return false;
            }
        } else if (!transitNames.equals(other.transitNames)) {
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
        builder.append(KEPLER_NAME_COLUMN);
        builder.append("\n");
        int row = 1;
        for (TransitName transitName : transitNames) {
            builder.append(row++);
            builder.append(COMMA_DELIMITER);
            builder.append(transitName.toString());
            builder.append("\n");
        }

        return builder.toString();
    }

    public String getType() {
        return TransitNameModelCrud.TYPE;
    }

}
