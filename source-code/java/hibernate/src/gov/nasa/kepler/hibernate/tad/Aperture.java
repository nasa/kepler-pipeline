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

package gov.nasa.kepler.hibernate.tad;

import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

/**
 * This class contains the {@link Offset}s of interest for an
 * {@link ObservedTarget}.
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "TAD_APERTURE")
public class Aperture {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "TAD_APERTURE_SEQ")
    @Column(nullable = false)
    private long id;

    @ManyToOne(optional = true)
    @Cascade(CascadeType.EVICT)
    private TargetTable targetTable;

    @OneToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    private boolean userDefined;
    private int referenceRow;
    private int referenceColumn;

    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    private List<Offset> offsets = new ArrayList<Offset>();

    Aperture() {
    }

    public Aperture(Aperture aperture) {
        userDefined = aperture.userDefined;
        referenceRow = aperture.referenceRow;
        referenceColumn = aperture.referenceColumn;
        targetTable = aperture.targetTable;

        for (Offset offset : aperture.getOffsets()) {
            offsets.add(new Offset(offset));
        }
    }

    public Aperture(boolean userDefined, int referenceRow, int referenceColumn,
        List<Offset> offsets) {
        this.userDefined = userDefined;
        this.referenceRow = referenceRow;
        this.referenceColumn = referenceColumn;
        this.offsets = offsets;
    }

    public Aperture createCopy() {
        return new Aperture(this);
    }

    public int getPixelCount() {
        return getOffsets().size();
    }

    public boolean isEmpty() {
        return getOffsets().isEmpty();
    }

    // If rebuilding hashCode automatically, be sure to keep custom offset
    // handling to ensure that two lists of similar offsets are the same even if
    // their order is different.
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((offsets == null) ? 0 : new HashSet<Offset>(offsets).hashCode());
        result = prime * result + referenceColumn;
        result = prime * result + referenceRow;
        result = prime * result + (userDefined ? 1231 : 1237);
        return result;
    }

    // If rebuilding equals automatically, be sure to keep custom offset
    // handling to ensure that two lists of similar offsets are the same even if
    // their order is different.
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof Aperture)) {
            return false;
        }
        Aperture other = (Aperture) obj;
        if (offsets == null) {
            if (other.offsets != null) {
                return false;
            }
        } else if (!new HashSet<Offset>(offsets).equals(new HashSet<Offset>(
            other.offsets))) {
            return false;
        }
        if (referenceColumn != other.referenceColumn) {
            return false;
        }
        if (referenceRow != other.referenceRow) {
            return false;
        }
        if (userDefined != other.userDefined) {
            return false;
        }
        return true;
    }

    // ReflectionToStringBuilder doesn't work with embedded fields (both the
    // container and the field). You get NPEs in Aperture.hashCode().
    @Override
    public String toString() {
        return String.format(
            "%s@%x[userDefined=%s,referenceRow=%d,referenceColumn=%d,offsets=%s]",
            getClass().getName(), System.identityHashCode(this), userDefined,
            referenceRow, referenceColumn, offsets);
    }

    public List<Offset> getOffsets() {
        return offsets;
    }

    public int getReferenceColumn() {
        return referenceColumn;
    }

    public int getReferenceRow() {
        return referenceRow;
    }

    public TargetTable getTargetTable() {
        return targetTable;
    }

    public void setTargetTable(TargetTable targetTable) {
        this.targetTable = targetTable;
    }

    public boolean isUserDefined() {
        return userDefined;
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    void setReferenceRow(int referenceRow) {
        this.referenceRow = referenceRow;
    }

    void setReferenceColumn(int referenceColumn) {
        this.referenceColumn = referenceColumn;
    }

}
