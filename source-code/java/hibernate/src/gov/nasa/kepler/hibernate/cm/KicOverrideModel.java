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
import gov.nasa.kepler.hibernate.pi.Model;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
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

/**
 * Contains a model for {@link KicOverride}s. The model is simply a collection
 * of {@link KicOverride}s with a revision for use with {@link ModelMetadata}.
 * 
 * @author Miles Cote
 * 
 */
@Entity
@Table(name = "CM_KIC_OVERRIDE_MODEL", uniqueConstraints = { @UniqueConstraint(columnNames = { "revision" }) })
public class KicOverrideModel implements Model {

    static final String COMMENT_START_CHARACTER = "#";

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_KOM_SEQ")
    @Column(nullable = false)
    private long id;

    private int revision;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "CM_KOM_KO")
    private List<KicOverride> kicOverrides;

    /**
     * Only used by hibernate.
     */
    KicOverrideModel() {
    }

    public KicOverrideModel(int revision, List<KicOverride> kicOverrides) {
        this.revision = revision;
        this.kicOverrides = kicOverrides;

        validate();
    }

    private void validate() {
        Map<Pair<Integer, Field>, KicOverride> keplerIdFieldPairToKicOverride = new LinkedHashMap<Pair<Integer, Field>, KicOverride>();
        for (KicOverride kicOverride : kicOverrides) {
            Pair<Integer, Field> keplerIdFieldPair = Pair.of(
                kicOverride.getKeplerId(), kicOverride.getField());
            KicOverride existingKicOverride = keplerIdFieldPairToKicOverride.get(keplerIdFieldPair);
            if (existingKicOverride != null) {
                if (!Double.valueOf(kicOverride.getValue())
                    .equals(existingKicOverride.getValue())) {
                    throw new IllegalArgumentException(
                        "Kic overrides with the same keplerId and field name must have the same value.\n  keplerId: "
                            + keplerIdFieldPair.left
                            + "\n  field: "
                            + keplerIdFieldPair.right
                            + "\n  value: "
                            + kicOverride.getValue()
                            + "\n  differingValue: "
                            + existingKicOverride.getValue());
                }

                if (!Double.valueOf(kicOverride.getUncertainty())
                    .equals(existingKicOverride.getUncertainty())) {
                    throw new IllegalArgumentException(
                        "Kic overrides with the same keplerId and field name must have the same uncertainty.\n  keplerId: "
                            + keplerIdFieldPair.left
                            + "\n  field: "
                            + keplerIdFieldPair.right
                            + "\n  uncertainty: "
                            + kicOverride.getUncertainty()
                            + "\n  differingUncertainty: "
                            + existingKicOverride.getUncertainty());
                }
            }

            keplerIdFieldPairToKicOverride.put(keplerIdFieldPair, kicOverride);
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

    public List<KicOverride> getKicOverrides() {
        return kicOverrides;
    }

    /**
     * Creates a {@link KicOverrideModel} object for the string argument.
     * 
     * @param s a String containing the {@link KicOverrideModel} object
     * representation to be parsed.
     * @return the {@link KicOverrideModel} object represented by the argument
     * @throws NullPointerException if the string is null.
     */
    public static KicOverrideModel valueOf(String s) {
        List<KicOverride> kicOverrides = new ArrayList<KicOverride>();
        for (String line : s.split("\n")) {
            if (line.contains(COMMENT_START_CHARACTER)) {
                String[] lineArray = line.split(COMMENT_START_CHARACTER);
                line = (lineArray.length == 0) ? "" : lineArray[0];
            }

            if (!line.trim()
                .isEmpty()) {
                KicOverride kicOverride = KicOverride.valueOf(line);
                kicOverrides.add(kicOverride);
            }
        }

        return new KicOverrideModel(Model.NULL_REVISION, kicOverrides);
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((kicOverrides == null) ? 0 : kicOverrides.hashCode());
        result = prime * result + revision;
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
        KicOverrideModel other = (KicOverrideModel) obj;
        if (kicOverrides == null) {
            if (other.kicOverrides != null)
                return false;
        } else if (!kicOverrides.equals(other.kicOverrides))
            return false;
        if (revision != other.revision)
            return false;
        return true;
    }

    /**
     * Formats this {@link KicOverrideModel} as it is expected to be imported
     * and exported.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();
        for (KicOverride kicOverride : kicOverrides) {
            s.append(kicOverride.toString());
            s.append("\n");
        }

        return s.toString();
    }

}
