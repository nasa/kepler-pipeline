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
import javax.persistence.OrderBy;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

@Entity
@Table(name = "MC_EXTERNAL_TCE_MODEL", uniqueConstraints = { @UniqueConstraint(columnNames = { "revision" }) })
public class ExternalTceModel implements Model {

    static final String COMMENT_START_CHARACTER = "#";

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "MC_ETM_SEQ")
    @Column(nullable = false)
    private long id;

    private int revision;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "MC_ETM_ET")
    @OrderBy(value = "id")
    private List<ExternalTce> externalTces;

    /**
     * For Hibernate use only.
     */
    public ExternalTceModel() {
    }

    public ExternalTceModel(int revision,
        List<ExternalTce> externalTces) {
        this.revision = revision;
        this.externalTces = externalTces;

        validate();
    }

    private void validate() {

        Map<Pair<Integer, Integer>, ExternalTce> externalTceByKeplerIdPlanetNumber = new LinkedHashMap<Pair<Integer, Integer>, ExternalTce>();
        for (ExternalTce externalTce : externalTces) {
            Pair<Integer, Integer> keplerIdPlanetNumberPair = Pair.of(
                externalTce.getKeplerId(), externalTce.getPlanetNumber());
            ExternalTce existingExternalTce = externalTceByKeplerIdPlanetNumber.get(keplerIdPlanetNumberPair);
            if (existingExternalTce != null) {
                if (!externalTce.equals(existingExternalTce)) {
                    throw new IllegalArgumentException(
                        "External TCEs with the same keplerId and planetNumber must be equal.\n"
                            + externalTce.toString() + "\n"
                            + existingExternalTce.toString());
                }
            }

            externalTceByKeplerIdPlanetNumber.put(keplerIdPlanetNumberPair,
                externalTce);
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

    public List<ExternalTce> getExternalTces() {
        return externalTces;
    }

    /**
     * Creates an {@link ExternalTceModel} object for the string argument.
     * 
     * @param s a String containing the {@link ExternalTceModel} object
     * representation to be parsed.
     * @return the {@link ExternalTceModel} object represented by the
     * argument
     * @throws NullPointerException if the string is null.
     */
    public static ExternalTceModel valueOf(String s) {
        List<ExternalTce> externalTces = new ArrayList<ExternalTce>();
        for (String line : s.split("\n")) {
            if (line.contains(COMMENT_START_CHARACTER)) {
                String[] lineArray = line.split(COMMENT_START_CHARACTER);
                line = (lineArray.length == 0) ? "" : lineArray[0];
            }

            if (!line.trim()
                .isEmpty()) {
                ExternalTce externalTce = ExternalTce.valueOf(line);
                if (externalTce != null) {
                    externalTces.add(externalTce);
                }
            }
        }

        return new ExternalTceModel(Model.NULL_REVISION, externalTces);
    }
    
    public static Map<Integer, List<ExternalTce>> parseModel(
        ExternalTceModel externalTceModel) {

        Map<Integer, List<ExternalTce>> parsedModel = new HashMap<Integer, List<ExternalTce>>();

        for (ExternalTce externalTce : externalTceModel.getExternalTces()) {
            List<ExternalTce> externalTces = parsedModel.get(externalTce.getKeplerId());
            if (externalTces == null) {
                externalTces = new ArrayList<ExternalTce>();
                parsedModel.put(externalTce.getKeplerId(), externalTces);
            }
            externalTces.add(externalTce);
        }

        return parsedModel;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((externalTces == null) ? 0 : externalTces.hashCode());
        result = prime * result + revision;
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
        if (!(obj instanceof ExternalTceModel)) {
            return false;
        }
        ExternalTceModel other = (ExternalTceModel) obj;
        if (externalTces == null) {
            if (other.externalTces != null) {
                return false;
            }
        } else if (!externalTces.equals(other.externalTces)) {
            return false;
        }
        if (revision != other.revision) {
            return false;
        }
        return true;
    }

    /**
     * Formats this {@link ExternalTceModel} as it is expected to be
     * imported and exported.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        for (ExternalTce externalTce : externalTces) {
            s.append(externalTce.toString());
            s.append("\n");
        }

        return s.toString();
    }

}
