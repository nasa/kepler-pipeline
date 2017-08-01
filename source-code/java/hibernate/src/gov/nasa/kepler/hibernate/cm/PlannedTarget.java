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

import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Offset;

import java.util.LinkedHashSet;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Version;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.Index;

/**
 * Information about a target known before running the pipeline.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "CM_PLANNED_TARGET")
public class PlannedTarget implements Comparable<PlannedTarget> {

    public static final String PAIR_DELIMITER = ",";
    private static final String OFFSET_DELIMITER = ";";

    /**
     * Set of label types that can be attached to a Target. A Target contains a
     * Set of labels, so any number of unique labels may be applied to a Target.
     * These labels are only used for internal SOC processing (e.g, so that PPA
     * determine which of the long cadence targets to use for its analysis, or
     * so that PDQ can determine which of the targets are to be used for the
     * background estimate, etc.). Labels are applied by the user using the CM
     * (target selection) GUI.
     */
    public static enum TargetLabel {
        PDQ_STELLAR,
        PDQ_BACKGROUND,
        PDQ_BLACK_COLLATERAL,
        PDQ_SMEAR_COLLATERAL,
        PDQ_GUIDE_STAR,
        PDQ_DYNAMIC_RANGE,
        PPA_STELLAR,
        PPA_2DBLACK,
        PPA_LDE_UNDERSHOOT,
        PLANETARY,
        TAD_NO_HALO,
        TAD_ONE_HALO,
        TAD_TWO_HALOS,
        TAD_THREE_HALOS,
        TAD_FOUR_HALOS,
        TAD_FIVE_HALOS,
        TAD_SIX_HALOS,
        TAD_SEVEN_HALOS,
        TAD_EIGHT_HALOS,
        TAD_NINE_HALOS,
        TAD_TEN_HALOS,
        TAD_ELEVEN_HALOS,
        TAD_TWELVE_HALOS,
        TAD_THIRTEEN_HALOS,
        TAD_FOURTEEN_HALOS,
        TAD_FIFTEEN_HALOS,
        TAD_SIXTEEN_HALOS,
        TAD_SEVENTEEN_HALOS,
        TAD_EIGHTEEN_HALOS,
        TAD_NINETEEN_HALOS,
        TAD_TWENTY_HALOS,
        TAD_ADD_UNDERSHOOT_COLUMN,
        TAD_NO_UNDERSHOOT_COLUMN,
        TAD_DEDICATED_MASK,
        CDPP_TARGET;

        public static boolean isTadLabel(String label) {
            return label.startsWith("TAD_");
        }

        public static boolean isHaloLabel(String label) {
            return label.contains("HALO");
        }

        public static boolean isUndershootLabel(String label) {
            return label.contains("UNDERSHOOT");
        }

        public static boolean isArpLabel(String label) {
            return label.contains("ARTIFACT_REMOVAL");
        }

        public static TargetLabel getHaloLabel(String label) {
            if (label.equals("TAD_NO_HALO") || label.equals("TAD_NO_HALOS")) {
                return TAD_NO_HALO;
            } else if (label.equals("TAD_ONE_HALO")
                || label.equals("TAD_ONE_HALOS")) {
                return TAD_ONE_HALO;
            } else if (label.equals("TAD_TWO_HALO")
                || label.equals("TAD_TWO_HALOS")) {
                return TAD_TWO_HALOS;
            } else if (label.equals("TAD_THREE_HALO")
                || label.equals("TAD_THREE_HALOS")) {
                return TAD_THREE_HALOS;
            } else if (label.equals("TAD_FOUR_HALO")
                || label.equals("TAD_FOUR_HALOS")) {
                return TAD_FOUR_HALOS;
            } else if (label.equals("TAD_FIVE_HALO")
                || label.equals("TAD_FIVE_HALOS")) {
                return TAD_FIVE_HALOS;
            } else if (label.equals("TAD_SIX_HALO")
                || label.equals("TAD_SIX_HALOS")) {
                return TAD_SIX_HALOS;
            } else if (label.equals("TAD_SEVEN_HALO")
                || label.equals("TAD_SEVEN_HALOS")) {
                return TAD_SEVEN_HALOS;
            } else if (label.equals("TAD_EIGHT_HALO")
                || label.equals("TAD_EIGHT_HALOS")) {
                return TAD_EIGHT_HALOS;
            } else if (label.equals("TAD_NINE_HALO")
                || label.equals("TAD_NINE_HALOS")) {
                return TAD_NINE_HALOS;
            } else if (label.equals("TAD_TEN_HALO")
                || label.equals("TAD_TEN_HALOS")) {
                return TAD_TEN_HALOS;
            } else if (label.equals("TAD_ELEVEN_HALO")
                || label.equals("TAD_ELEVEN_HALOS")) {
                return TAD_ELEVEN_HALOS;
            } else if (label.equals("TAD_TWELVE_HALO")
                || label.equals("TAD_TWELVE_HALOS")) {
                return TAD_TWELVE_HALOS;
            } else if (label.equals("TAD_THIRTEEN_HALO")
                || label.equals("TAD_THIRTEEN_HALOS")) {
                return TAD_THIRTEEN_HALOS;
            } else if (label.equals("TAD_FOURTEEN_HALO")
                || label.equals("TAD_FOURTEEN_HALOS")) {
                return TAD_FOURTEEN_HALOS;
            } else if (label.equals("TAD_FIFTEEN_HALO")
                || label.equals("TAD_FIFTEEN_HALOS")) {
                return TAD_FIFTEEN_HALOS;
            } else if (label.equals("TAD_SIXTEEN_HALO")
                || label.equals("TAD_SIXTEEN_HALOS")) {
                return TAD_SIXTEEN_HALOS;
            } else if (label.equals("TAD_SEVENTEEN_HALO")
                || label.equals("TAD_SEVENTEEN_HALOS")) {
                return TAD_SEVENTEEN_HALOS;
            } else if (label.equals("TAD_EIGHTEEN_HALO")
                || label.equals("TAD_EIGHTEEN_HALOS")) {
                return TAD_EIGHTEEN_HALOS;
            } else if (label.equals("TAD_NINETEEN_HALO")
                || label.equals("TAD_NINETEEN_HALOS")) {
                return TAD_NINETEEN_HALOS;
            } else if (label.equals("TAD_TWENTY_HALO")
                || label.equals("TAD_TWENTY_HALOS")) {
                return TAD_TWENTY_HALOS;
            } else {
                throw new IllegalArgumentException("Unexpected halo label: "
                    + label);
            }
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_PLANNED_TARGET_SEQ")
    @Column(nullable = false)
    private long id;

    @Version
    int version;

    @Index(name = "CM_PT_KEPLER_ID")
    private int keplerId;

    @Index(name = "CM_PT_SKY_GROUP_ID_IDX")
    private int skyGroupId;

    @OneToOne(optional = true)
    @JoinTable(name = "CM_PT_APERTURE", joinColumns = @JoinColumn(name = "PLANNED_TARGET_ID"))
    @Cascade(CascadeType.ALL)
    private Aperture aperture;

    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @JoinTable(name = "CM_PT_LABELS", joinColumns = @JoinColumn(name = "PLANNED_TARGET_ID"))
    @Cascade(CascadeType.ALL)
    private Set<String> labels = new LinkedHashSet<String>();

    // Do not cascade evict here as it causes errors in the UI (as it's like the
    // tail wagging the dog).
    // NOTE:
    @ManyToOne(optional = true, fetch = FetchType.LAZY)
    @JoinColumn(name = "TARGET_LIST_ID", nullable = true)
    private TargetList targetList;

    PlannedTarget() {
    }

    public PlannedTarget(TargetList targetList) {
        this(TargetManagementConstants.INVALID_KEPLER_ID,
            TargetManagementConstants.INVALID_SKY_GROUP_ID, targetList);
    }

    public PlannedTarget(int keplerId, int skyGroupId) {
        this(keplerId, skyGroupId, null);
    }

    public PlannedTarget(int keplerId, int skyGroupId, TargetList targetList) {
        this.keplerId = keplerId;
        this.skyGroupId = skyGroupId;
        this.targetList = targetList;
    }

    public PlannedTarget(PlannedTarget target) {
        keplerId = target.keplerId;
        skyGroupId = target.skyGroupId;
        targetList = target.targetList;
        if (target.aperture != null) {
            aperture = new Aperture(target.aperture);
        }
        for (String label : target.labels) {
            labels.add(label);
        }
    }

    /**
     * Returns this target's database ID.
     * 
     * @return a database id
     */
    public long getId() {
        return id;
    }

    /**
     * Returns this target's {@link Aperture}.
     * 
     * @return an {@link Aperture}
     */
    public Aperture getAperture() {
        return aperture;
    }

    /**
     * Sets this target's {@link Aperture}.
     * 
     * @param aperture an {@link Aperture}
     */
    public void setAperture(Aperture aperture) {
        this.aperture = aperture;
    }

    /**
     * Returns this target's labels.
     * 
     * @return a non-{@code null} set of labels
     */
    public Set<String> getLabels() {
        return labels;
    }

    /**
     * Sets this target's labels.
     * 
     * @param labels a non-{@code null} set of labels
     */
    public void setLabels(Set<String> labels) {
        if (labels == null) {
            throw new NullPointerException("labels can't be null");
        }
        this.labels = labels;
    }

    public boolean addLabel(TargetLabel label) {
        return labels.add(label.toString());
    }

    public boolean containsLabel(TargetLabel label) {
        return labels.contains(label.toString());
    }

    public boolean removeLabel(TargetLabel label) {
        return labels.remove(label.toString());
    }

    public TargetList getTargetList() {
        return targetList;
    }

    public void setTargetList(TargetList targetList) {
        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }

        this.targetList = targetList;
    }

    public int getKeplerId() {
        return keplerId;
    }

    public void setKeplerId(int keplerId) {
        this.keplerId = keplerId;
    }

    public int getSkyGroupId() {
        return skyGroupId;
    }

    public void setSkyGroupId(int skyGroupId) {
        this.skyGroupId = skyGroupId;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + keplerId;
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
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PlannedTarget other = (PlannedTarget) obj;
        if (keplerId != other.keplerId) {
            return false;
        }
        return true;
    }

    /**
     * {@link PlannedTarget}s are sorted by their {@code keplerId}.
     * 
     * @see Comparable#compareTo(Object)
     */
    @Override
    public int compareTo(PlannedTarget target) {
        return getKeplerId() - target.getKeplerId();
    }

    /**
     * Displays a string representation of this object.
     * <p>
     * This format is used by {@code TargetSelectionOperations.targetToString}
     * which with {@code TargetSelectionOperations.stringToTarget} defines the
     * import/export format. Therefore, please do not modify this method unless
     * changing the official import/export format.
     */
    @Override
    public String toString() {
        StringBuilder s = new StringBuilder();

        if (getKeplerId() == TargetManagementConstants.INVALID_KEPLER_ID) {
            s.append("NEW");
        } else {
            s.append(getKeplerId());
        }
        s.append(Kic.SCP_DELIMITER);

        if ((TargetManagementConstants.isCustomTarget(getKeplerId()) || getKeplerId() == TargetManagementConstants.INVALID_KEPLER_ID)
            && getSkyGroupId() != TargetManagementConstants.INVALID_SKY_GROUP_ID) {
            s.append(getSkyGroupId());
        }
        s.append(Kic.SCP_DELIMITER);

        if (labels.size() > 0) {
            int count = 0;
            for (String label : labels) {
                if (count++ > 0) {
                    s.append(PAIR_DELIMITER);
                }
                s.append(label);
            }
        }
        s.append(Kic.SCP_DELIMITER);

        if (aperture != null && aperture.isUserDefined()) {
            s.append(String.format("%d%s%d%s", aperture.getReferenceRow(),
                Kic.SCP_DELIMITER, aperture.getReferenceColumn(),
                Kic.SCP_DELIMITER));
            int count = 0;
            for (Offset offset : aperture.getOffsets()) {
                if (count++ > 0) {
                    s.append(OFFSET_DELIMITER);
                }
                s.append(String.format("%d%s%d", offset.getRow(),
                    PAIR_DELIMITER, offset.getColumn()));
            }
        } else {
            s.append(Kic.SCP_DELIMITER)
                .append(Kic.SCP_DELIMITER);
        }

        return s.toString();
    }
}
