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

package gov.nasa.kepler.hibernate.gar;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;

import java.util.Date;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.MappedSuperclass;
import javax.persistence.SequenceGenerator;

/**
 * This class represents tables that are sent to the MOC. This class is the
 * superclass of {@link TargetTable}s, {@link MaskTable}s, {@link HuffmanTable}
 * s, and {@link RequantTable}s. It holds the common fields of these classes.
 * 
 * @author Miles Cote
 * @author Bill Wohler
 */
@MappedSuperclass
public abstract class ExportTable {

    /**
     * Marks an invalid {@link #externalId}.
     */
    public static final int INVALID_EXTERNAL_ID = -1;

    /**
     * Maximum value of {@link #externalId}.
     */
    public static final int MAX_EXTERNAL_ID = 255;

    public static enum State {
        UNLOCKED("Unlocked"),
        LOCKED("Locked"),
        TAD_COMPLETED("TAD completed and validated"),
        UPLINKED("Uplinked to spacecraft"),
        REVISED("Revised for post-processing");

        private String display;

        private State(String display) {
            this.display = display;
        }

        @Override
        public String toString() {
            return display;
        }

        /**
         * Is this item unlocked?
         * 
         * @return <code>true</code> if this item is unlocked; otherwise,
         * returns <code>false</code>.
         */
        public boolean unlocked() {
            return this == UNLOCKED;
        }

        /**
         * Is this item locked?
         * 
         * @return <code>true</code> if this item is locked; otherwise, returns
         * <code>false</code>.
         */
        public boolean locked() {
            return this == LOCKED || this == TAD_COMPLETED || this == UPLINKED;
        }

        /**
         * Has this item been run through TAD?
         * 
         * @return <code>true</code> if this item has been run through TAD;
         * otherwise, returns <code>false</code>.
         */
        public boolean tadCompleted() {
            return this == TAD_COMPLETED || this == UPLINKED;
        }

        /**
         * Has this item been uplinked to the spacecraft?
         * 
         * @return <code>true</code> if this item has been uplinked to the
         * spacecraft; otherwise, returns <code>false</code>.
         */
        public boolean uplinked() {
            return this == UPLINKED;
        }

        /**
         * Can this item can be modified?
         * 
         * @return <code>true</code> if this item can be modified; otherwise,
         * returns <code>false</code>.
         */
        public boolean modifiable() {
            return unlocked();
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "GAR_ET_SEQ")
    @Column(nullable = false)
    protected long id;

    @Column(nullable = false)
    protected State state = State.UNLOCKED;

    /**
     * The ID that is sent to the MOC. Valid range is [0, 255]. Use
     * {@link #INVALID_EXTERNAL_ID} to represent unset or invalid IDs.
     */
    @Column(nullable = true)
    protected int externalId = INVALID_EXTERNAL_ID;

    @Column(nullable = true)
    protected Date plannedStartTime;

    @Column(nullable = true)
    protected Date plannedEndTime;

    /**
     * This is the file name that is generated for this {@link ExportTable} when
     * it is exported from the database.
     */
    @Column(nullable = true)
    protected String fileName;

    public int getExternalId() {
        return externalId;
    }

    public void setExternalId(int externalId) {
        this.externalId = externalId;
    }

    public Date getPlannedEndTime() {
        return plannedEndTime;
    }

    public void setPlannedEndTime(Date plannedEndTime) {
        this.plannedEndTime = plannedEndTime;
    }

    public Date getPlannedStartTime() {
        return plannedStartTime;
    }

    public void setPlannedStartTime(Date plannedStartTime) {
        this.plannedStartTime = plannedStartTime;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    protected ExportTable() {
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + (int) (id ^ (id >>> 32));
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
        final ExportTable other = (ExportTable) obj;
        if (id != other.id) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return getClass().getSimpleName() + ": id=" + id;
    }

    /**
     * Generates a file name for an {@link ExportTable}. The format is defined
     * in the DMC-SOC-ICD. An example filename is
     * <code>kplr1969365160001_lct-001.xml</code>.
     */
    public String generateFileName() {
        return generateFileName(getShortName(), new Date());
    }

    /**
     * Generates a file name for an {@link ExportTable} using the given date.
     * The format is defined in the DMC-SOC-ICD. An example filename is
     * <code>kplr1969365160001_lct-001.xml</code>.
     */
    public String generateFileName(Date date) {
        return generateFileName(getShortName(), date);
    }

    /**
     * Generates a file name for an {@link ExportTable} using the given short
     * name and date. The format is defined in the DMC-SOC-ICD. An example
     * filename is <code>kplr1969365160001_lct-001.xml</code>.
     */
    protected String generateFileName(String shortName, Date date) {
        fileName = String.format("kplr%s-%03d_%s.xml",
            DateUtils.formatLikeDmc(date), externalId, shortName);

        return fileName;
    }

    /**
     * Returns the short name for this table (for example, "lct");
     */
    protected abstract String getShortName();

    public void validate() {
        if (plannedStartTime == null) {
            throw new IllegalStateException("Table (" + getShortName()
                + ") must have a planned start time");
        }

        if (externalId < 0) {
            throw new IllegalStateException("Table (" + getShortName()
                + ") must have a table ID");
        }

        if (externalId == 0) {
            throw new IllegalStateException("Table (" + getShortName()
                + ") must have a table ID that is not equal to 0.  This "
                + "is reserved for MOC and Flight Segment use.");
        }
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public long getId() {
        return id;
    }
}
