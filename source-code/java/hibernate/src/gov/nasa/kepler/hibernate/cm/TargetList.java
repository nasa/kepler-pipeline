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

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Version;

/**
 * A single target list. The actual targets are not included here as a
 * collection to reduce this object's memory footprint. Instead, the
 * {@link PlannedTarget} object contains a {@link TargetList} field.
 * <p>
 * The target list name and category must be non-{@code null} and non-empty and
 * the name must also be unique.
 * <p>
 * See KSOC-21163 Catalog Management.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "CM_TARGET_LIST")
public class TargetList implements Comparable<TargetList> {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "CM_TARGET_LIST_SEQ")
    @Column(nullable = false)
    private long id;

    @Version
    int version;

    @Column(unique = true, nullable = false)
    private String name;

    /**
     * Target category. See Operations Scenario 6.4, Target Management,
     * KKPO-16038, for a description of this field. This is (currently) just a
     * string and contains text such as Planet Detection Targets or Guest
     * Observer Targets.
     */
    @Column(nullable = false)
    private String category;

    public enum SourceType {
        /** Source contains a query. */
        QUERY,
        /** Source contains a file name. */
        FILE,
    };

    /** The type of source of this target list. */
    private SourceType sourceType = SourceType.QUERY;

    /** The source of this target list. */
    private String source;

    private Date lastModified;

    /**
     * This constructor is for use by mock objects and Hibernate only.
     */
    TargetList() {
    }

    /**
     * Creates a TargetList object with the given name, type LONG_CADENCE, null
     * query, exclude set to {@code false} and an empty list of Kepler IDs.
     * 
     * @param name the name of the target list
     * @throws NullPointerException if the name is {@code null}
     * @throws IllegalArgumentException if the name is empty
     */
    public TargetList(String name) {
        setName(name);
    }

    /**
     * Creates a target list by copying the given target list. The copy is a
     * deep copy.
     * 
     * @param name the name
     * @param targetList the target list to copy
     * @throws NullPointerException if {@code targetList is {@code null}
     */
    public TargetList(String name, TargetList targetList) {
        this(name); // updates lastModified
        category = targetList.category;
        sourceType = targetList.sourceType;
        source = targetList.source;
    }

    /**
     * Returns the database ID for this object.
     */
    public long getId() {
        return id;
    }

    /**
     * Returns the date when this list was last modified.
     * 
     * @return a date
     */
    public Date getLastModified() {
        return lastModified;
    }

    /**
     * Gets the name of this list.
     * 
     * @return the name of this list
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name of this target list.
     * 
     * @param name the name of the target list
     * @throws NullPointerException if the name is {@code null}
     * @throws IllegalArgumentException if the name is empty
     */
    public void setName(String name) {
        if (name == null) {
            throw new NullPointerException("Target list name can't be null");
        }
        if (name.length() == 0) {
            throw new IllegalArgumentException(
                "Target list name can't be empty");
        }

        this.name = name;
        lastModified = new Date(System.currentTimeMillis());
    }

    /**
     * Gets this list's category.
     * 
     * @return this list's category, may be {@code null} or empty
     */
    public String getCategory() {
        return category;
    }

    /**
     * Sets the category of this target list.
     * 
     * @param category the category of the target list
     * @throws NullPointerException if the category is {@code null}
     * @throws IllegalArgumentException if the category is empty
     */
    public void setCategory(String category) {
        if (category == null) {
            throw new NullPointerException("Target list category can't be null");
        }
        if (category.length() == 0) {
            throw new IllegalArgumentException(
                "Target list category can't be empty");
        }
        this.category = category;
        lastModified = new Date(System.currentTimeMillis());
    }

    /**
     * Returns the source of this target list.
     * 
     * @return depends on the value of {@code sourceType} (see
     * {@link SourceType})
     */
    public String getSource() {
        return source;
    }

    /**
     * Sets the source of this target list.
     * 
     * @param source depends on the value of {@code sourceType} (see
     * {@link SourceType})
     */
    public void setSource(String source) {
        this.source = source;
        lastModified = new Date(System.currentTimeMillis());
    }

    /**
     * Returns the source type.
     * 
     * @return one of the values from the {@link SourceType} enum
     */
    public SourceType getSourceType() {
        return sourceType;
    }

    /**
     * Sets the source type.
     * 
     * @param sourceType one of the values from the {@link SourceType} enum
     */
    public void setSourceType(SourceType sourceType) {
        this.sourceType = sourceType;
        lastModified = new Date(System.currentTimeMillis());
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
        final TargetList other = (TargetList) obj;
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
     * {@link TargetList}s are sorted by their {@code name}.
     * 
     * @see Comparable#compareTo(Object)
     */
    @Override
    public int compareTo(TargetList targetList) {
        return name.compareTo(targetList.getName());
    }

    @Override
    public String toString() {
        return name;
    }
}
