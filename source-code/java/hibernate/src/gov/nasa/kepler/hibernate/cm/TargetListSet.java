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

import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.OrderBy;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Version;

/**
 * A single target list.
 * <p>
 * This class defines a complete group of target and aperture tables that are on
 * the spacecraft at one time. A TargetListSet has exactly one
 * targetApertureTable and exactly one backgroundApertureTable.
 * <p>
 * See KSOC-21163 Catalog Management.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "CM_TARGET_LIST_SET")
public class TargetListSet implements Comparable<TargetListSet>, DateRange {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_TARGET_LIST_SET_SEQ")
    @Column(nullable = false)
    private long id;

    @Version
    int version;

    @Column(unique = true, nullable = false)
    private String name;

    /** Type of target list set. See {@link TargetType} for values. */
    private TargetType type = TargetType.LONG_CADENCE;

    /** State of target list set. See {@link State} for values. */
    private State state = State.UNLOCKED;

    /** Date that target list should go into effect. */
    // To be consistent with endTime.
    @Column(name = "START_TIME")
    private Date start;

    /** Date that target list should no longer be in effect. */
    // end is a reserved word.
    @Column(name = "END_TIME")
    private Date end;

    @ManyToMany
    @JoinTable(name = "CM_TLS_TL")
    @OrderBy(value = "name")
    private List<TargetList> targetLists = new ArrayList<TargetList>();

    @ManyToMany
    @JoinTable(name = "CM_TLS_ETL")
    @OrderBy(value = "name")
    private List<TargetList> excludedTargetLists = new ArrayList<TargetList>();

    /**
     * TargetTable created from this object. Either long cadence, short cadence,
     * or reference pixel. The type of table created depends on the type of this
     * object.
     */
    @OneToOne(fetch = FetchType.LAZY)
    @JoinTable(name = "CM_TLS_TT")
    private TargetTable targetTable;

    /**
     * Optional. Only populated if the type of this object is long cadence.
     */
    @OneToOne(fetch = FetchType.LAZY)
    @JoinTable(name = "CM_TLS_BT")
    private TargetTable backgroundTable;

    /**
     * Optional. Only populated if the type of this object is long cadence and
     * if RPTS has run associated with this object.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private TargetTable refPixTable;

    /**
     * Optional. Only populated if the type of this object is short cadence or
     * refrence pixel.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    private TargetListSet associatedLcTls;

    /**
     * Optional. Only populated if a supplemental TLS has been configured for
     * this TLS.
     */
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "SUPP_TLS_ID")
    private TargetListSet supplementalTls;

    /**
     * This constructor is for use by mock objects and Hibernate only.
     */
    TargetListSet() {
    }

    /**
     * Creates a target list set with the given name.
     * 
     * @param name the name.
     * @throws NullPointerException if the name is {@code null}.
     * @throws IllegalArgumentException if the name is empty.
     */
    public TargetListSet(String name) {
        setName(name);
    }

    /**
     * Creates a target list set by copying the given target list set. The copy
     * is a deep copy. The target lists are also copied.
     * 
     * @param name the name.
     * @param targetListSet the target list set to copy.
     * @throws NullPointerException if {@code targetListSet} is {@code null}.
     */
    public TargetListSet(String name, TargetListSet targetListSet) {
        this(name);
        type = targetListSet.type;
        state = targetListSet.state;
        start = targetListSet.start;
        end = targetListSet.end;
        targetLists = new ArrayList<TargetList>(targetListSet.getTargetLists());
        excludedTargetLists = new ArrayList<TargetList>(
            targetListSet.getExcludedTargetLists());
        if (targetListSet.getTargetTable() != null) {
            targetTable = new TargetTable(targetListSet.getTargetTable());
        }
        if (targetListSet.getBackgroundTable() != null) {
            backgroundTable = new TargetTable(
                targetListSet.getBackgroundTable());
        }
    }

    /**
     * Clears the fields added by TAD. These include {@code targetTable},
     * {@code backgroundTable}, {@code associatedLcTls}, and {@code refPixTable}
     * .
     */
    public void clearTadFields() {
        targetTable = null;
        backgroundTable = null;
        associatedLcTls = null;
        supplementalTls = null;
        refPixTable = null;
    }

    /**
     * Returns the database ID for this target list set.
     */
    public long getId() {
        return id;
    }

    /**
     * Returns the name of this target list set.
     * 
     * @return the name.
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name of this target list set.
     * 
     * @param name the name of the target list set.
     * @throws NullPointerException if the name is {@code null}.
     * @throws IllegalArgumentException if the name is empty.
     * @throws IllegalStateException if this set is not UNLOCKED.
     */
    public void setName(String name) {
        if (name.length() == 0) {
            throw new IllegalArgumentException("Name can't be empty");
        }
        if (!getState().modifiable()) {
            throw new IllegalStateException("Target list set is not "
                + "in the UNLOCKED state");
        }
        this.name = name;
    }

    /**
     * Returns the type of this target list set.
     * 
     * @return one of the values from the {@link TargetType} enum.
     */
    public TargetType getType() {
        return type;
    }

    /**
     * Sets the type of this target list set.
     * 
     * @param type one of the values from the {@link TargetType} enum.
     * @throws NullPointerException if {@code start} is {@code null}.
     * @throws IllegalStateException if this set is not UNLOCKED.
     */
    public void setType(TargetType type) {
        if (type == null) {
            throw new NullPointerException("type can't be null");
        }
        if (!getState().modifiable()) {
            throw new IllegalStateException("Target list set is not "
                + "in the UNLOCKED state");
        }
        this.type = type;
    }

    /**
     * Returns the state of this target list.
     * 
     * @return one of the values from the {@link State} enum.
     */
    public State getState() {
        return state;
    }

    /**
     * Sets the state of this target list.
     * 
     * @param state one of the values from the {@link State} enum.
     * @throws NullPointerException if {@code state} is {@code null}.
     */
    public void setState(State state) {
        if (state == null) {
            throw new NullPointerException("state can't be null");
        }
        this.state = state;
    }

    /**
     * Returns the date that this target list set should go into effect.
     * 
     * @return the start.
     */
    @Override
    public Date getStart() {
        return start;
    }

    /**
     * Sets the date that this target list set should go into effect.
     * 
     * @param start the date this target list set should go into effect.
     * @throws NullPointerException if {@code start} is {@code null}.
     * @throws IllegalStateException if this set is not UNLOCKED.
     */
    public void setStart(Date start) {
        if (start == null) {
            throw new NullPointerException("start can't be null");
        }
        if (!getState().modifiable()) {
            throw new IllegalStateException("Target list set is not "
                + "in the UNLOCKED state");
        }
        this.start = start;
    }

    /**
     * Returns the date that this target list set should no longer be in effect.
     * 
     * @return the end.
     */
    @Override
    public Date getEnd() {
        return end;
    }

    /**
     * Sets the date that this target list set should no longer be in effect.
     * 
     * @param end the date this target list set should no longer be in effect.
     * @throws NullPointerException if {@code end} is {@code null}.
     * @throws IllegalStateException if this set is not UNLOCKED.
     */
    public void setEnd(Date end) {
        if (end == null) {
            throw new NullPointerException("end can't be null");
        }
        if (!getState().modifiable()) {
            throw new IllegalStateException("Target list set is not "
                + "in the UNLOCKED state");
        }
        this.end = end;
    }

    /**
     * Returns the target lists.
     * 
     * @return the target lists.
     */
    public List<TargetList> getTargetLists() {
        return getState().modifiable() ? targetLists
            : Collections.unmodifiableList(targetLists);
    }

    /**
     * Sets the target lists.
     * 
     * @param targetLists the new target lists.
     * @throws NullPointerException if {@code targetLists} is {@code null}.
     * @throws IllegalStateException if this set is not UNLOCKED.
     */
    public void setTargetLists(List<TargetList> targetLists) {
        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }
        if (!getState().modifiable()) {
            throw new IllegalStateException("Target list set is not "
                + "in the UNLOCKED state");
        }
        this.targetLists = targetLists;
    }

    /**
     * Returns the excluded target lists.
     * 
     * @return the excluded target lists.
     */
    public List<TargetList> getExcludedTargetLists() {
        return getState().modifiable() ? excludedTargetLists
            : Collections.unmodifiableList(excludedTargetLists);
    }

    /**
     * Sets the target lists.
     * 
     * @param targetLists the new target lists.
     * @throws NullPointerException if {@code targetLists} is {@code null}.
     * @throws IllegalStateException if this set is not UNLOCKED.
     */
    public void setExcludedTargetLists(List<TargetList> targetLists) {
        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }
        if (!getState().modifiable()) {
            throw new IllegalStateException("Target list set is not "
                + "in the UNLOCKED state");
        }
        excludedTargetLists = targetLists;
    }

    /**
     * Returns the target table.
     * 
     * @return the target table.
     */
    public TargetTable getTargetTable() {
        return targetTable;
    }

    /**
     * Sets the target table.
     * 
     * @param targetTable the new target table.
     * @throws NullPointerException if {@code targetTable} is {@code null}.
     * @throws IllegalStateException if this set has been UPLINKED.
     */
    public void setTargetTable(TargetTable targetTable) {
        if (targetTable == null) {
            throw new NullPointerException("targetTable can't be null");
        }
        if (state == State.UPLINKED) {
            throw new IllegalStateException("Target list set has been uplinked");
        }
        this.targetTable = targetTable;
    }

    /**
     * Returns the background target table.
     * 
     * @return the background target table.
     */
    public TargetTable getBackgroundTable() {
        return backgroundTable;
    }

    /**
     * Sets the background target table.
     * 
     * @param backgroundTable the new target table.
     * @throws NullPointerException if {@code backgroundTable} is {@code null}.
     * @throws IllegalStateException if this set has been UPLINKED.
     */
    public void setBackgroundTable(TargetTable backgroundTable) {
        if (backgroundTable == null) {
            throw new NullPointerException("backgroundTable can't be null");
        }
        if (state == State.UPLINKED) {
            throw new IllegalStateException("Target list set has been uplinked");
        }
        this.backgroundTable = backgroundTable;
    }

    public TargetListSet getAssociatedLcTls() {
        return associatedLcTls;
    }

    public void setAssociatedLcTls(TargetListSet associatedLcTls) {
        this.associatedLcTls = associatedLcTls;
    }

    public TargetListSet getSupplementalTls() {
        return supplementalTls;
    }

    public void setSupplementalTls(TargetListSet supplementalTls) {
        this.supplementalTls = supplementalTls;
    }

    public TargetTable getRefPixTable() {
        return refPixTable;
    }

    public void setRefPixTable(TargetTable refPixTable) {
        this.refPixTable = refPixTable;
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
        final TargetListSet other = (TargetListSet) obj;
        if (name == null) {
            if (other.name != null) {
                return false;
            }
        } else if (!name.equals(other.name)) {
            return false;
        }
        return true;
    }

    /**
     * {@link TargetListSet}s are sorted by their {@code name}.
     * 
     * @see Comparable#compareTo(Object)
     */
    @Override
    public int compareTo(TargetListSet targetListSet) {
        return name.compareTo(targetListSet.getName());
    }

    @Override
    public String toString() {
        return name;
    }
}
