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

import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * This class represents an aperture table that is sent to the MOC and uploaded
 * to the spacecraft. Each {@link Mask} has a reference to its {@link MaskTable}
 * .
 * 
 * @author Miles Cote
 */
@Entity
@Table(name = "TAD_MASK_TABLE")
public class MaskTable extends ExportTable implements TypedTable {

    public static enum MaskType {
        TARGET("Target", "tad"), BACKGROUND("Background", "bad");

        private String display;
        private String shortName;

        private MaskType(String display, String shortName) {
            this.display = display;
            this.shortName = shortName;
        }

        public static MaskType valueOf(TargetType type) {
            if (type == TargetType.BACKGROUND) {
                return BACKGROUND;
            } else {
                return TARGET;
            }
        }

        public static MaskType valueOfShortName(String shortNameString) {
            if (shortNameString.equals(TARGET.shortName())) {
                return TARGET;
            }
            if (shortNameString.equals(BACKGROUND.shortName())) {
                return BACKGROUND;
            }
            throw new IllegalArgumentException("Invalid short name string \""
                + shortNameString + "\".");
        }

        public String shortName() {
            return shortName;
        }

        @Override
        public String toString() {
            return display;
        }
    }

    @Column(nullable = false)
    private MaskType type;

    MaskTable() {
    }

    public MaskTable(MaskType type) {
        this.type = type;
    }

    public MaskTable(MaskTable maskTable) {
        this.type = maskTable.type;
        this.plannedStartTime = maskTable.plannedStartTime;
        this.plannedEndTime = maskTable.plannedEndTime;
    }

    @Override
    public void validate() {
        super.validate();
        if (plannedEndTime == null) {
            throw new IllegalStateException("Table (" + getShortName()
                + ") must have a planned end time");
        }
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }

    @Override
    protected String getShortName() {
        return type.shortName();
    }

    public MaskType getType() {
        return type;
    }

}
